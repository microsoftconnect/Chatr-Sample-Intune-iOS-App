//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PolicyDelegate.h"

#import <ADAL/ADKeychainTokenCache.h>
#import <ADAL/ADAuthenticationError.h>
#import <ADAL/ADTokenCacheItem.h>
#import <ADAL/ADUserInformation.h>

#import "chatr-Swift.h"
@class KeychainManager;
@class ChatPage;

/*
 This policy delegate class can be initialized and set as the enrollment delegate of the IntuneMAMPolicyManager
 (This is done in the AppDelegate.swift file at app initialization)
 Doing this will trigger the wipeDataForAccount and restartApplication methods whenever the Intune SDK needs to do either of these things
 
 NOTE: A number of other methods are avaliable in the IntuneMAMPolicyDelegate. See documentation or header file for more info.
 Methods like identitySwitchRequired and addIdentity are generally used in multi-user apps, unlike this single user app.
 See IntuneMAMPolicyDelegate documentation or header file for more information
 */
@implementation PolicyDelegateClass

/*
 wipeDataForAccount is called by the Intune SDK when the app needs to wipe all the data for a specified user
 With chatr, the only user data stored are the chat messages and drafted chat messages.
 If this is wiped successfully, return TRUE, otherwise return FALSE
 
 @param upn is the upn of the user whoes data is to be wiped (for example "user@example.com")
 */
- (BOOL)wipeDataForAccount:(NSString*_Nonnull)upn{
    //Use the deleteItemForUser function in the KeychainManager class to look into the keychain to wipe any messages stored for a given upn
    if ([KeychainManager deleteItemForUserWithUser:upn key:@"messages"] == true && [KeychainManager deleteItemForUserWithUser:upn key:@"draftMessage"]){
        //If the function call returns true, this indicates it successfully cleared the user's messages from the Keychain
        return TRUE;
    } else{
        //If the function failed to wipe the chat messages and draft messages, log this and return FALSE
        NSLog(@"Data wipe from keychain failed");
        return FALSE;
    }
    
}

/*
 In the case that the app needs to do tasks like save user data before the Intune SDK restarts the app, those tasks can be done here
 With Chatr, drafted messages need to be saved if a restart is forced.
 
 If the app will handle restarting on its own, return TRUE.
 If the app wants the Intune SDK to handle the restart, @return FALSE.
 See IntuneMAMPolicyDelegate documentation or header file for more information
 */
- (BOOL)restartApplication {
    NSLog(@"Restarting...");
    
    //If the current view is the chat page and there is message currently being drafted, then save it to the keychain to repopulate it after the restart.
    UIViewController *currentViewController = [ObjCUtils getCurrentViewController];
    if ([currentViewController isMemberOfClass:[ChatPage class]]){
        ChatPage *ChatPageViewController = (ChatPage*) currentViewController;
        //Call saveDraftedMessage on the ChatPage to save the drafted message to the keychain if there is one present.
        [ChatPageViewController saveDraftedMessage];
    }
    return FALSE;
}


@end
