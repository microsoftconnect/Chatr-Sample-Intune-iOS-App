//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//

/*
 This policy delegate class can be initialized and set as the delegate of the IntuneMAMPolicyManager
 (This is done in the AppDelegate.swift file at app initialization)
 Doing this will trigger the wipeDataForAccount and restartApplication methods whenever the Intune SDK needs to do either of these things
 
 NOTE: A number of other methods are avaliable in the IntuneMAMPolicyDelegate. See documentation or header file for more info.
 Methods like identitySwitchRequired and addIdentity are generally used in multi-user apps, unlike this single user app.
 See IntuneMAMPolicyDelegate documentation or header file for more information
 */

class PolicyDelegateClass: NSObject, IntuneMAMPolicyDelegate {
    
    /*
     wipeDataForAccount is called by the Intune SDK when the app needs to wipe all the data for a specified user
     With chatr, the only user data stored are the sent chat messages and drafted chat messages.
     If this is wiped successfully, return true, otherwise return false
     
     @param upn is the upn of the user whoes data is to be wiped (for example "user@example.com")
     */
    func wipeData(forAccount: String) -> Bool {
        //variable to track if the data wipe was successful
        var wipeSuccess = true
        
        //remove all files in each directory
        let fileManager: FileManager = FileManager.default
        let paths: [String] = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        for fileDirectory in paths {
            do {
                let fileArray = try fileManager.contentsOfDirectory(atPath: fileDirectory)
                for fileName in fileArray {
                    let fileDirectoryURL = URL(fileURLWithPath: fileDirectory)
                    let fullPathURL = fileDirectoryURL.appendingPathComponent(fileName)
                    try fileManager.removeItem(atPath: fullPathURL.path)
                }
            } catch {
                print("Could not successfully remove files from directory. Error: \(error)")
                wipeSuccess = false
            }
        }
        
        //Use the deleteSentMessagesForUser and deleteSentMessagesForUser functions in the KeychainManager class to look into the keychain to wipe any message data stored for a given upn
        if !(KeychainManager.deleteDraftMessage(forUser: forAccount) && KeychainManager.deleteSentMessages(forUser: forAccount)){
            //If either function call returns false, this indicates the app failed clear the user's messages from the keychain
            print("Data wipe from keychain failed")
            wipeSuccess = false
        }
        
        return wipeSuccess
    }
    
    /*
     In the case that the app needs to perform tasks like save user data before the Intune SDK restarts the app, those tasks can be done here
     With Chatr, drafted messages need to be saved if a restart is forced.
     
     If the app will handle restarting on its own, return true.
     If the app wants the Intune SDK to handle the restart, @return false.
     See IntuneMAMPolicyDelegate documentation or header file for more information
     */
    func restartApplication() -> Bool {
        //If the current view is the chat page and there is a message currently being drafted, then save it to the keychain to repopulate it after the restart.
        let currentViewController = UIUtils.getCurrentViewController()
        if currentViewController is ChatPage{
            //Call saveDraftedMessage on the ChatPage to save the drafted message to the keychain if there is one present.
            let page = currentViewController as! ChatPage
            page.saveDraftedMessage()
        }
        return false
    }
}
