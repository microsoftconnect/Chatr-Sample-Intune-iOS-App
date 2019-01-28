//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//

#import <IntuneMAM/IntuneMAMPolicyDelegate.h>

#ifndef PolicyDelegate_h
#define PolicyDelegate_h

/*
 This policy delegate class can be initialized and set as the delegate of the IntuneMAMPolicyManager
 (This is done in the AppDelegate.swift file at app initialization)
 Doing this will trigger the wipeDataForAccount and restartApplication methods whenever the Intune SDK needs to do either of these things
 
 NOTE: A number of other methods are avaliable in the IntuneMAMPolicyDelegate. See documentation or header file for more info.
 Methods like identitySwitchRequired and addIdentity are generally used in multi-user apps, unlike this single user app.
 See IntuneMAMPolicyDelegate documentation or header file for more information
 */
@interface PolicyDelegateClass : NSObject <IntuneMAMPolicyDelegate>

    /*
     wipeDataForAccount is called by the Intune SDK when the app needs to wipe all the data for a specified user
     With chatr, the only user data stored are the sent chat messages and drafted chat messages.
     If this is wiped successfully, return TRUE, otherwise return FALSE
     
     @param upn is the upn of the user whoes data is to be wiped (for example "user@example.com")
     */
    - (BOOL)wipeDataForAccount:(NSString*_Nonnull)upn;

    /*
     In the case that the app needs to perform tasks like save user data before the Intune SDK restarts the app, those tasks can be done here
     With Chatr, drafted messages need to be saved if a restart is forced.
     
     If the app will handle restarting on its own, return TRUE.
     If the app wants the Intune SDK to handle the restart, @return FALSE.
     See IntuneMAMPolicyDelegate documentation or header file for more information
     */
    - (BOOL)restartApplication;
@end


#endif /* PolicyDelegate_h */
