//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PolicyDelegate.h"

#import <ADAL/ADKeychainTokenCache.h>
#import <ADAL/ADAuthenticationError.h>
#import <ADAL/ADTokenCacheItem.h>
#import <ADAL/ADUserInformation.h>

/*
 This policy delegate class can be initialized and set as the delegate of the IntuneMAMPolicyManager
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
    //Wipe all user data on the app here
    NSLog(@"Wipe successful");
    return TRUE;
    
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
    //Since there is no user data to save, Chatr will let the Intune SDK handle the restart
    return FALSE;
}


@end
