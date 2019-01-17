//
//  Copyright (c) Microsoft Corporation. All rights reserved.
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
 Function authenticates the user and enrolls the app into the Intune MAM Service via the Intune SDK's loginAndEnrollAccount API
 
Note: Alternatively, apps can directly use ADAL to authenticate, and then call the Intune SDK's registerAndEnrollAccount API to initiate a silent enrollment upon success.
 
 @param presentingViewController - The view controller calling this function
 */
+ (void)login: (UIViewController*) presentingViewController;

/*!
 This will log out the user that is currently signed into the app.
 */
+ (void)logout;

/*!
 Displays the Intune Diagnostics Console on top of the app.
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

/*
 This method retrieves the current view controller by going from the rootViewController to the currently presented view
 */
+ (UIViewController *) getCurrentViewController;

@end
#endif /* ObjCUtils_h */
