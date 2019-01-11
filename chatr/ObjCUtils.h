//
//  ObjCUtils.h
//  chatr
//
//  Created by Meseret  Kebede on 23/07/2018.
//  Copyright © 2018 Microsoft Intune. All rights reserved.
//

#import <IntuneMAM/IntuneMAMPolicyDelegate.h>
#import <IntuneMAM/IntuneMAMEnrollmentDelegate.h>

#ifndef ObjCUtils_h
#define ObjCUtils_h

@class UIViewController;
@interface ObjCUtils : NSObject 

/*!
 Gets the userID of the user that is logged into the app based on the tokens in the cache.
 NOTE: This implementation is specific to a single user scenario
 
 @return userID, nil if no-one is logged in
 */
+ (NSString*) getSignedInUser;

/*!
 Function logs in user through the Intune sign in flow. It will point them back to the app after authentication is complete.
 This function also handles enrolling the user account to be managed by the MAM service. This is a feature of loginAndEnrollAccount
 
 Note that this can be done using ADAL if desired, but is done with Intune in this app.
 
 @param presentingViewController - The view controller calling this function
 */
+ (void)login: (UIViewController*) presentingViewController;

/*!
 Removes all of the tokens from the Cache.
 This will log out the user that are currently signed into the app. Specific to a single user scenario
 */
+ (void)removeAppTokens;

/*!
 Displays the Intune Console on top of the app.
 This console can be used to send diagnostics logs from the end users.
 */
+ (void)displayConsole;

/*!
 Checks if saving to local drive is allowed by policy. Used by the app to check if save is allowed, before the action is executed.
 Modify the parameter in isSaveToAllowedForLocation to check for other APP controlled save locations. Documentation in IntuneMAMPolicy.h
 
 @return True if allowed, false otherwise
 */
+ (BOOL) isSaveToLocalDriveAllowed;

/*!
 Gets the string value associated with "GroupName" from the app config setting on portal.azure.com
 
 @return groupName, Chatr if one is not set
 */
+ (NSString*) getUserGroupName;

/*!
 Function as per IntuneMAMPolicyDelegate.h documentation.
 
 Lets the SDK know that the restart of application when new MAM policies are recieved for the first time should be handled by the SDK.
 @return false
 */
+ (BOOL) restartApplication;

/*!
 Function as per IntuneMAMPolicyDelegate.h documentation.
 
 Lets the SDK handle the removal of data associated with a specified user. This is a design choice, developers can implement this function to handle the removal of the specified user data and return True when finished. Refer to detailed specs in the IntuneMAMPolicyDelegate.h documentation.
 @return false
 */
- (BOOL) wipeDataForAccount:(NSString*)upn;

@end
#endif /* ObjCUtils_h */
