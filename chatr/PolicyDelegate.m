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
 With chatr, the only user data stored are the chat messages.
 If this is wiped successfully, return TRUE, otherwise return FALSE
 
 @param upn is the upn of the user whoes data is to be wiped (for example "user@example.com")
 */
- (BOOL)wipeDataForAccount:(NSString*_Nonnull)upn{
    //Use the deleteItemForUser function in the KeychainManager class to look into the keychain to wipe any messages stored for a given upn
    if ([KeychainManager deleteItemForUserWithUser:upn] == true){
        //If the function call returns true, this indicates it successfully cleared the user's messages from the Keychain
        return TRUE;
    } else{
        //If the function failed to wipe the chat message, log this and return FALSE
        NSLog(@"Data wipe from keychain failed");
        return FALSE;
    }
    
}

/*
 In the case that the app needs to do tasks like save user data before the Intune SDK restarts the app, those tasks can be done here
 With Chatr, this is not necessary as no user data is saved by the app.
 
 If the app will handle restarting on its own, return TRUE.
 If the app wants the Intune SDK to handle the restart, @return FALSE.
 See IntuneMAMPolicyDelegate documentation or header file for more information
 */
- (BOOL)restartApplication {
    NSLog(@"Restarting...");
//Is this possible? Won't currentViewController always be the UI from the SDK? How will the app get access to the drafted message?
//    //If the current view is the chat page and there is message currently being drafted, then save it to the keychain to repopulate it after the restart.
//    UIViewController *currentViewController = [ObjCUtils getCurrentViewController];
//    if ([currentViewController.title caseInsensitiveCompare:@"ChatPage"] == NSOrderedSame){
//        //Next check for a drafted message
//
//    }
//        //case insensitive comparision to chat page to check
    return FALSE;
}


@end
