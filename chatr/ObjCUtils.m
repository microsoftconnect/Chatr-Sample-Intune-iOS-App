//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//
//  Error alert code adapted from: https://stackoverflow.com/questions/1747510/alert-view-in-iphone answer by krakover
//

#import <Foundation/Foundation.h>

#import <IntuneMAM/IntuneMAMEnrollmentManager.h>
#import <IntuneMAM/IntuneMAMPolicyManager.h>
#import <IntuneMAM/IntuneMAMAppConfigManager.h>
#import <IntuneMAM/IntuneMAMAppConfig.h>
#import <IntuneMAM/IntuneMAMDiagnosticConsole.h>
#import "ObjCUtils.h"
#import "EnrollmentDelegate.h"
#import "PolicyDelegate.h"

@implementation ObjCUtils


/*!
    Gets the userID of the user that is logged into the app using the Intune API method enrolledAccount
    NOTE: This implementation is specific to a single user scenario
 
    @return userID, nil if no-one is logged in
 */
+ (NSString*_Nullable) getSignedInUser
{
    return [[IntuneMAMEnrollmentManager instance] enrolledAccount];
}


/*!
 Function authenticates the user and enrolls the app into the Intune MAM Service via the Intune SDK's loginAndEnrollAccount API
 
 Note: Alternatively, apps can directly use ADAL to authenticate, and then call the Intune SDK's registerAndEnrollAccount API to initiate a silent enrollment upon success.
 
 @param presentingViewController - The view controller calling this function
 */
+ (void)login: ( UIViewController* )presentingViewController
{
    //Give the IntuneMAMEnrollmentManager an instance of the EnrollmentDelegateClass as its delegate to check the status of attempted enrollments. Also initialize this class with the current view controller
    //This is done on launch, but here it is done again to give the delegate the current view controller
    [IntuneMAMEnrollmentManager instance].delegate = [[EnrollmentDelegateClass alloc] initWithViewController:presentingViewController];
    
    //Login the user through the Intune sign in flow. EnrollmentDelegateClass will handle the outcome of this.
    [[IntuneMAMEnrollmentManager instance] loginAndEnrollAccount:nil];
    
}


/*!
    This will log out the user that is currently signed into the app.
 */
+ (void)logout
{
    // Find the user that is signed in
    NSString* userID = [self getSignedInUser];
        
    // deregister the user from the SDK and initate a selective wipe of the app
    //In the EnrollmentDelegate, the unenrollRequestWithStatus block is executed, and includes logic to wipe tokens on unenrollment
    [[IntuneMAMEnrollmentManager instance] deRegisterAndUnenrollAccount:userID withWipe:YES];
    
}

/*!
 Displays the Intune Diagnostics Console on top of the app.
 This console can be used to send diagnostics logs from the end users.
 */
+ (void)displayConsole
{
    [IntuneMAMDiagnosticConsole displayDiagnosticConsoleInDarkMode:NO];
}

/*!
    Checks if saving to local drive is allowed by policy. Used by the app to check if save is allowed, before the action is executed.
    Modify the parameter in isSaveToAllowedForLocation to check for other APP controlled save locations. Documentation in IntuneMAMPolicy.h
 
    @return True if allowed, false otherwise
 */
+ (BOOL) isSaveToLocalDriveAllowed
{
    // Find the user that is signed in
    NSString* userID = [self getSignedInUser];
    
    // Check if save to is allowed by policy
    return [[[IntuneMAMPolicyManager instance] policy] isSaveToAllowedForLocation: IntuneMAMSaveLocationLocalDrive withAccountName: userID];
}

/*!
    Gets the string value associated with "GroupName" from the app config setting on portal.azure.com
 
    @return groupName, Chatr if one is not set
 */
+ (NSString*) getUserGroupName
{
    // Find the user that is signed in
    NSString* userID = [self getSignedInUser];
    
    // Get the groupName value for the user - key value pairing set in the portal
    id<IntuneMAMAppConfig> data = [[IntuneMAMAppConfigManager instance] appConfigForIdentity: userID];
    
    // if there are no conflicts for that key, find the value associated with the key
    if (! [data hasConflict:@"GroupName"]) {
        NSString* groupName = [data stringValueForKey:@"GroupName" queryType:IntuneMAMStringAny];
        
        if (groupName) {
            return groupName;
        }
    } else {
        // resolve the conflict by taking the max value
        return [data stringValueForKey:@"GroupName" queryType:IntuneMAMStringMax];
    }
    return @"Chatr";    // default, if none is set
}

/*
 This method retrieves the current view controller by going from the rootViewController to the currently presented view
 */
+ (UIViewController *) getCurrentViewController
{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    if (topController) {
        UIViewController *presentedViewController = topController.presentedViewController;
        //Loop until there are no more view controllers to go to
        while (presentedViewController){
            topController = presentedViewController;
            presentedViewController = topController.presentedViewController;
        }
    }
    //Return the final view controller
    return topController;
}

@end
