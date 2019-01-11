//
//  ObjCUtils.m
//  chatr
//
//  Created by Meseret  Kebede on 23/07/2018.
//  Copyright © 2018 Microsoft Intune. All rights reserved.
//
//  Error alert code adapted from: https://stackoverflow.com/questions/1747510/alert-view-in-iphone answer by krakover
//

#import <Foundation/Foundation.h>
#import <ADAL/ADAL.h>
#import <ADAL/ADAuthenticationContext.h>
#import <ADAL/ADAuthenticationError.h>
#import <ADAL/ADAuthenticationParameters.h>
#import <ADAL/ADAuthenticationResult.h>
#import <ADAL/ADAuthenticationSettings.h>
#import <ADAL/ADErrorCodes.h>
#import <ADAL/ADKeychainTokenCache.h>
#import <ADAL/ADLogger.h>
#import <ADAL/ADTelemetry.h>
#import <ADAL/ADTokenCacheItem.h>
#import <ADAL/ADUserIdentifier.h>
#import <ADAL/ADUserInformation.h>
#import <ADAL/ADWebAuthController.h>

#import <IntuneMAM/IntuneMAMEnrollmentManager.h>
#import <IntuneMAM/IntuneMAMPolicyDelegate.h>
#import <IntuneMAM/IntuneMAMPolicyManager.h>
#import <IntuneMAM/IntuneMAMAppConfigManager.h>
#import <IntuneMAM/IntuneMAMAppConfig.h>
#import <IntuneMAM/IntuneMAMDiagnosticConsole.h>
#import "ObjCUtils.h"
#import "EnrollmentDelegate.h"

@implementation ObjCUtils


/*!
    Gets the userID of the user that is logged into the app using the Intune API method registeredAccounts
    NOTE: This implementation is specific to a single user scenario
 
    @return userID, nil if no-one is logged in
 */
+ (NSString*_Nullable) getSignedInUser
{
    return [[IntuneMAMEnrollmentManager instance] enrolledAccount];
}


/*!
 Function logs in user through the Intune sign in flow. It will point them back to the app after authentication is complete.
 This function also handles enrolling the user account to be managed by the MAM service. This is a feature of loginAndEnrollAccount
 
 Note that this can be done using ADAL if desired, but is done with Intune in this app.
 
 @param presentingViewController - The view controller calling this function
 */
+ (void)login: ( UIViewController* )presentingViewController
{
    //first give the IntuneMAMEnrollmentManager an instance of the enrollmentDelegateClass as its delegate to check the status of attempted logins. Also initialize this class with the current view controller
    [IntuneMAMEnrollmentManager instance].delegate = [[enrollmentDelegateClass alloc] initWithViewController:presentingViewController];
    
    //Login the user through the Intune sign in flow. enrollmentDelegateClass will handle the outcome of this.
    [[IntuneMAMEnrollmentManager instance] loginAndEnrollAccount:NULL];
    
    //TODO Figure out token caching and remove old ADAL stuff from this page
}


/*!
    Removes all of the tokens from the Cache.
    This will log out the user that are currently signed into the app. Specific to a single user scenario
 */
+ (void)removeAppTokens
{
    // Find the user that is signed in
    NSString* userID = [self getSignedInUser];
    
    [IntuneMAMEnrollmentManager instance].delegate = [[enrollmentDelegateClass alloc] init];
    
    // deregister the user from the SDK and initate a selective wipe of the app
    //In the EnrollmentDelegate, the unenrollRequestWithStatus block is executed, and includes logic to wipe tokens on successful unenrollment
    [[IntuneMAMEnrollmentManager instance] deRegisterAndUnenrollAccount:userID withWipe:YES];
    
}

/*!
 Displays the Intune Console on top of the app.
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

@end
