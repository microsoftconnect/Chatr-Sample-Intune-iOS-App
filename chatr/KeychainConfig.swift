//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//

import Foundation

@objc public class KeychainManager : NSObject{
    
    /*
     This function updates a user's current item in the keychain with new message data
     @param user: the NSString representing the upn of the user to update the keychain for
     @param messageArray: an NSMutableArray containing the messages to be added to the keychain
     */
    private class func updateItem(user: NSString, messageArray: NSMutableArray){
        let service : String = Bundle.main.bundleIdentifier!
        let key : String = "messages"
        //Convert given array of message data to data that can be stored in the keychain
        let messageData = NSKeyedArchiver.archivedData(withRootObject: messageArray)
        
        //First define a query that will locate the user's data
        let query : [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                    kSecAttrAccount as String: user,
                    kSecAttrService as String: service,
                    kSecAttrLabel as String: key
                    ]
        //Next define the attributes to be updated (message data)
        let attributes : [String: Any] = [kSecValueData as String: messageData]
        
        //Update the item in the keychain
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if status != errSecSuccess {
            //In the case of an unexpected error, log the error information
            print("Unexpected error when updating data in the keychain.")
            print("Error code: \(Int(status))")
        }
    }
    
    /*
    This function is used to check for the current keychain item for a given user
    If an item is found, it returns the array of messages.
    If no item is found, or there is an error in searching for the item, it returns nil.
     @param user: the NSString representing the upn of the user to search the keychain for
    */
    public class func getCurrentItem(user: NSString) -> NSMutableArray?{
        let service : String = Bundle.main.bundleIdentifier!
        let key : String = "messages"
        
        //A query specific to the user is defined
        //Within the query, kSecReturnData is set to true so that the search will return the message data
        let query : [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                     kSecAttrAccount as String: user,
                                     kSecAttrService as String: service,
                                     kSecAttrLabel as String: key,
                                     kSecReturnData as String: true,
                                     kSecReturnAttributes as String: true,
                                     ]
        var item: CFTypeRef?
        //call the search to find a matching item in the keychain
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        //if no item is found, return nil
        guard status != errSecItemNotFound else { return nil }
        
        if status == errSecSuccess {
            //if an item is successfully returned, retrieve the data from the item
            guard let queryReturn = item as? [String : Any]
            else {
                //If the data is not in the appropriate format, log this and return nil
                print("Unexpected data returned from keychain")
                return nil
            }
            //Convert the message back to an NSMutableArray and return it
            let encodedData = queryReturn[kSecValueData as String] as? Data
            let messageArray = NSKeyedUnarchiver.unarchiveObject(with: encodedData!) as? NSMutableArray
            return messageArray
        } else {
            //Some other unexpected error occurred
            print("Unexpected error when searching for data in the keychain.")
            print("Error code: \(Int(status))")
            return nil
        }
    }
    
    /*
    This function is used to add messages to the keychain. It first searches to see if any item is present for the given user already.
    If the user already has an item, update this item. Otherwise, create a new keychain item.
     @param user: the NSString representing the upn of the user to add a message for
     @param messages: the NSMutableArray containing the message to be added to the keychain
    */
    public class func addMessage(messages messageArray:NSMutableArray, user:NSString){
        if let currentMessages : NSMutableArray = KeychainManager.getCurrentItem(user: user) {
            //If an item is already in the keychain for a given user, then update the keychain with the new message
            currentMessages.addObjects(from: messageArray as! [Any])
            KeychainManager.updateItem(user: user, messageArray: currentMessages)
            
        } else {
            //Otherwise define a query to add an item for the user containing the messages
            let service : String = Bundle.main.bundleIdentifier!
            let key : String = "messages"
            let messageData = NSKeyedArchiver.archivedData(withRootObject: messageArray)
            
            let query : [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                         kSecAttrAccount as String: user,
                                         kSecAttrService as String: service,
                                         kSecValueData as String: messageData,
                                         kSecAttrLabel as String: key,
                                         ]
            //Add the new item to the query
            let status = SecItemAdd(query as CFDictionary, nil)
            if status != errSecSuccess {
                //Some other unexpected error occured
                print("Error occurred when adding data to the keychain.")
                print("Error code: \(Int(status))")
            }
        }
    }
    
    /*
    Function used to delete the item containing messages for a given user from the keychain
    Returns true if the deletion was successful, and false if the deletion failed.
    @param user: the NSString representing the upn of the user to remove keychain items for
    */
    public class func deleteItemForUser(user:NSString) -> Bool{
        let service : String = Bundle.main.bundleIdentifier!
        let key : String = "messages"
        
        //Define a query that will locate the messages item in the keychain
        let query : [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                     kSecAttrAccount as String: user,
                                     kSecAttrService as String: service,
                                     kSecAttrLabel as String: key,
                                     ]
        //Delete the item the query finds
        let status = SecItemDelete(query as CFDictionary)
        //Even if the item was not found, this is considered successful as the item may never have been there
        if status != errSecSuccess || status != errSecItemNotFound {
            print("Error occurred when removing data from the keychain.")
            print("Error code: \(Int(status))")
            return false
        }
        return true
    }
}
