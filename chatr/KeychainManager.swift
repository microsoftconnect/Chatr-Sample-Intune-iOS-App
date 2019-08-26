//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//

import Foundation

/*
 Class with methods used to manage adding, updating, and removing user data to the keychain.
 The keychain is used in this app to securely store user messages and drafted messages.
 The data in the keychain persists across app instances unless deleted from the keychain.
 */
@objc public class KeychainManager : NSObject{
    
    //Keys used in keychain to distinguish draft messages from sent messages
    static let draftMessageKey: String = "draftMessage"
    static let sentMessageKey: String = "sentMessages"
    
    /*
     This function updates a user's current item in the keychain with new data
     @param user: the String representing the upn of the user to update the keychain for
     @param data: the data to be stored in the keychain, can be of any type
     @param key: a string representing the key for the data
     */
    private class func updateItem(forUser: String, data: Any, key:String){
        //Convert given data to archived data that can be stored in the keychain
        let archivedData = NSKeyedArchiver.archivedData(withRootObject: data)
        
        //First define a query that will locate the user's keychain item
        let query = [kSecClass: kSecClassGenericPassword,
                    kSecAttrAccount: forUser,
                    kSecAttrService: key,
                    ] as CFDictionary
        
        //Next define the attributes to be updated (the archived data)
        let attributes = [kSecValueData: archivedData] as CFDictionary
        
        //Update the item in the keychain
        let status = SecItemUpdate(query, attributes)
        if status != errSecSuccess {
            //In the case of an unexpected error, log the error information
            print("Unexpected error when updating data in the keychain.")
            print("Error code: \(Int(status))")
        }
    }
    
    /*
    This function is used to retrieve the current sent messages in the keychain for a given user
    If any are found, the function returns an array of the sent messages.
    If none are found, or there is an error in searching for the item, the function returns nil.
    @param forUser: the String representing the upn of the user to search the keychain for
    */
    @objc public class func getSentMessages(forUser: String) -> [String]?{
        //A query specific to the user is defined
        //Within the query, kSecReturnData is set to true so that the search will return the message data
        let query = [kSecClass: kSecClassGenericPassword,
                    kSecAttrAccount: forUser,
                    kSecAttrService: self.sentMessageKey,
                    kSecReturnData: true,
                    kSecReturnAttributes: true,
                    ] as CFDictionary
        
        var item: CFTypeRef?
        //Call the search to find a matching item in the keychain
        let status = SecItemCopyMatching(query, &item)
        //If no item is found, return nil
        guard status != errSecItemNotFound else { return nil }
        
        if status == errSecSuccess {
            //If an item is successfully returned, retrieve the data from the item
            guard let queryReturn = item as? [String : Any]
            else {
                //If the data is not in the appropriate format, log this and return nil
                print("Unexpected data returned from keychain")
                return nil
            }
            //Convert the data back to an array and return it
            let encodedData = queryReturn[kSecValueData as String] as? Data
            let messageArray = NSKeyedUnarchiver.unarchiveObject(with: encodedData!) as? [String]
            return messageArray
        } else {
            //Some other unexpected error occurred
            print("Unexpected error when searching for data in the keychain.")
            print("Error code: \(Int(status))")
            return nil
        }
    }
    
    /*
     This function is used to retrieve the current drafted message in the keychain for a given user
     If one is found, it is returned as an String.
     If no drafted message is found, or there is an error in searching for the item, the function returns nil.
     @param forUser: the String representing the upn of the user to search the keychain for
     */
    @objc public class func getDraftedMessage(forUser: String) -> String?{
        //A query specific to the user is defined
        //Within the query, kSecReturnData is set to true so that the search will return the message data
        let query = [kSecClass: kSecClassGenericPassword,
                    kSecAttrAccount: forUser,
                    kSecAttrService: self.draftMessageKey,
                    kSecReturnData: true,
                    kSecReturnAttributes: true,
                    ] as CFDictionary
        
        var item: CFTypeRef?
        //Call the search to find a matching item in the keychain
        let status = SecItemCopyMatching(query, &item)
        //If no item is found, return nil
        guard status != errSecItemNotFound else { return nil }
        
        if status == errSecSuccess {
            //If an item is successfully returned, retrieve the data from the item
            guard let queryReturn = item as? [String : Any]
                else {
                    //If the data is not in the appropriate format, log this and return nil
                    print("Unexpected data returned from keychain")
                    return nil
            }
            //Convert the message back to a string and return it
            let encodedData = queryReturn[kSecValueData as String] as? Data
            let draftMessage = NSKeyedUnarchiver.unarchiveObject(with: encodedData!) as? String
            return draftMessage
        } else {
            //Some other unexpected error occurred
            print("Unexpected error when searching for data in the keychain.")
            print("Error code: \(Int(status))")
            return nil
        }
    }
    
    /*
    This function is used to store a sent message in the keychain. It first searches to see if any sent messages are present for the given user already.
    If the user already has an item in the keychain for sent messages, update this item. Otherwise, create a new keychain item.
     @param forUser: the String representing the upn of the user to add a sent message for
     @param message: the String containing the sent message to be added to the keychain
    */
    @objc public class func storeSentMessage(sentMessage newMessage:String, forUser:String){
        if var currentMessages : [String] = KeychainManager.getSentMessages(forUser: forUser) {
            //When dealing with sent messages, add the new message to the existing messages if any are present
            currentMessages.append(newMessage)
            KeychainManager.updateItem(forUser: forUser, data: currentMessages, key: self.sentMessageKey)
            
        } else {
            //Otherwise define a query to add an item for the user containing the sent message within an array (so that future messages can be added)
            let messageArray = [newMessage]
            let messageData = NSKeyedArchiver.archivedData(withRootObject: messageArray)
            
            let query = [kSecClass: kSecClassGenericPassword,
                        kSecAttrAccount: forUser,
                        kSecAttrService: self.sentMessageKey,
                        kSecValueData: messageData,
                        ] as CFDictionary
            
            //Add the new item to the query
            let status = SecItemAdd(query, nil)
            if status != errSecSuccess {
                //Some other unexpected error occured
                print("Error occurred when adding data to the keychain.")
                print("Error code: \(Int(status))")
            }
        }
    }
    
    /*
     This function is used to store a draft message in the keychain. It first searches to see if any draft messages are present for the given user already.
     If the user already has an draft message in the keychain, replace this draft message with the new one. Otherwise, create a new keychain item.
     @param forUser: the String representing the upn of the user to add a draft message for
     @param message: the String containing the draft message to be added to the keychain
     */
    @objc public class func storeDraftMessage(draftMessage newMessage:String, forUser:String){
        if nil != KeychainManager.getDraftedMessage(forUser: forUser) {
            //When dealing with draft messages, do not add the new draft message to the existing one, but store only the newest value as only one draft message is stored at a time
            KeychainManager.updateItem(forUser: forUser, data: newMessage, key:self.draftMessageKey)
            
        } else {
            //Otherwise define a query to add an item for the user containing the draft message
            let messageData = NSKeyedArchiver.archivedData(withRootObject: newMessage)
            
            let query = [kSecClass: kSecClassGenericPassword,
                        kSecAttrAccount: forUser,
                        kSecAttrService: self.draftMessageKey,
                        kSecValueData: messageData,
                        ] as CFDictionary
            
            //Add the new item to the query
            let status = SecItemAdd(query, nil)
            if status != errSecSuccess {
                //Some other unexpected error occured
                print("Error occurred when adding data to the keychain.")
                print("Error code: \(Int(status))")
            }
        }
    }
    
    /*
    Function used to delete the sent messages data for a given user from the keychain.
    Returns true if the deletion was successful, and false if the deletion failed.
    @param forUser: the String representing the upn of the user to remove keychain items for
    */
    @objc public class func deleteSentMessages(forUser:String) -> Bool{
        
        //Define a query that will locate the sent messages item in the keychain
        let query = [kSecClass: kSecClassGenericPassword,
                    kSecAttrAccount: forUser,
                    kSecAttrService: self.sentMessageKey,
                    ] as CFDictionary
        
        //Delete the item the query finds
        let status = SecItemDelete(query)
        //Even if the item was not found, this is considered successful as the item may never have been there
        if status != errSecSuccess && status != errSecItemNotFound {
            print("Error occurred when removing sent messages from the keychain.")
            print("Error code: \(Int(status))")
            return false
        }
        return true
    }
    
    /*
     Function used to delete the draft message data for a given user from the keychain.
     Returns true if the deletion was successful, and false if the deletion failed.
     @param forUser: the String representing the upn of the user to remove keychain items for
     */
    @objc public class func deleteDraftMessage(forUser:String) -> Bool{
        
        //Define a query that will locate the draft message item in the keychain
        let query = [kSecClass: kSecClassGenericPassword,
                    kSecAttrAccount: forUser,
                    kSecAttrService: self.draftMessageKey,
                    ] as CFDictionary
        
        //Delete the item the query finds
        let status = SecItemDelete(query)
        //Even if the item was not found, this is considered successful as the item may never have been there
        if status != errSecSuccess && status != errSecItemNotFound {
            print("Error occurred when removing the draft message from the keychain.")
            print("Error code: \(Int(status))")
            return false
        }
        return true
    }
}
