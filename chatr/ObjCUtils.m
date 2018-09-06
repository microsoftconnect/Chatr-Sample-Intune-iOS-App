//
//  ObjCUtils.m
//  chatr
//
//  Created by Meseret  Kebede on 23/07/2018.
//  Copyright © 2018 Microsoft Intune. All rights reserved.
//
//  Error alert code adapted from: https://stackoverflow.com/questions/1747510/alert-view-in-iphone answer by krakover
//  Azure AD token call from: https://github.com/AzureAD/azure-activedirectory-library-for-objc
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
#import "ObjCUtils.h"

@implementation ObjCUtils

// ** Constants used throughout code, change appropriately:
//    clientID          --> Azure AD Application ID for your app from the Azure portal
//    redirectUri       --> <scheme>://<bundle-id> | further details can be found @ https://docs.microsoft.com/en-gb/azure/active-directory/develop/quickstart-v1-ios
#define CLIENTID @"3b5457ac-5240-43cc-8e93-6cd1b3bfadd5"
#define REDIRECTURI @"chatr://Intune.chatr"


/*!
    Gets the userID of the user that is logged into the app based on the tokens in the cache.
    NOTE: This implementation is specific to a single user scenario
 
    @return userID, nil if no-one is logged in
 */
+ (NSString*) getSignedInUser
{
    ADKeychainTokenCache* cache = [ADKeychainTokenCache defaultKeychainCache];
    NSString* userID = nil;
    
    // Finds all of the tokens stored in the cache
    NSArray<ADTokenCacheItem *> *cacheItems= [cache allItems:nil];
    
    // Go through all of the tokens and grab the userID of the last token associated with the clientID Works for a single user scenario.
    for (ADTokenCacheItem *token in cacheItems) {
        NSString* clientID = token.clientId;
        
        if ([clientID isEqualToString:CLIENTID]) {
            userID = token.userInformation.userId;
        }
    }
    return userID;
}


/*!
    Function adapted from the Azure AD library for objc @ https://github.com/AzureAD/azure-activedirectory-library-for-objc
 
    Directs the user to the Azure AD sign in flow, and will point them back to the app once the authentication token has been acquired.
    This function also handles enrolling the user account to be managed by the MAM service
 
    @param presentingViewController - The view controller calling this function
 */
+ (void)getToken: ( UIViewController* )presentingViewController
{
    ADAuthenticationError *error = nil;
    ADAuthenticationContext *authContext = [ADAuthenticationContext authenticationContextWithAuthority:@"https://login.windows.net/common" error:&error];
    
    // ** TO CHANGE:
    //    completionBlock   --> this is a function written by the developer that defines what happens in a success and failure case of authentication.
    [authContext acquireTokenWithResource:@"https://graph.microsoft.com"
                                 clientId:CLIENTID
                              redirectUri:[NSURL URLWithString:REDIRECTURI]
                          completionBlock:^(ADAuthenticationResult *result)
     {
         if (AD_SUCCEEDED != result.status){    // Handles the case that sign in has failed
             printf("Sign in failed");
             
             // present the user with an alert asking them to sign in again.
             UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error Authenticating"
                                                                            message:@"There was an error while logging you into you account. Please check your log in credentials and try again."
                                                                     preferredStyle:UIAlertControllerStyleAlert];
             
             UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                   handler:^(UIAlertAction * action) {
                                                                       [presentingViewController presentViewController:alert animated:YES completion:nil];
                                                                   }];
             printf("Sign in failed, and no alert");
             [alert addAction:defaultAction];
             
         } else {                               // Handles the case that sign in is successful
             printf("Successfully signed in");
             
             // get the id of the user that is currently signed in
             NSString* userID = [self getSignedInUser];
             
             // register and enroll the user account with the Intune MAM service,
             // - fails silently look at enrollmentRequestWithStatus for debug messages
             [[IntuneMAMEnrollmentManager instance] registerAndEnrollAccount:userID];
             
             // present the Chatr home page
             [presentingViewController performSegueWithIdentifier: @"homePage" sender:presentingViewController];
         }
     }];
}


/*!
    Removes all of the tokens from the Cache.
    This will log out the user that are currently signed into the app. Specific to a single user scenario
 */
+ (void)removeAppTokens
{
    ADKeychainTokenCache* cache = [ADKeychainTokenCache defaultKeychainCache];
    
    // Find the user that is signed in
    NSString* userID = [self getSignedInUser];
    
    // deregister the user from the SDK and initate a selective wipe of the app
    [[IntuneMAMEnrollmentManager instance] deRegisterAndUnenrollAccount:userID withWipe:YES];
    
    // delete all tokens associated with that userID and clientID
    [cache removeAllForUserId: userID
                     clientId: CLIENTID
                        error: nil];
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


/*!
    Function as per IntuneMAMPolicyDelegate.h documentation.
 
    Lets the SDK know that the restart of application when new MAM policies are recieved for the first time should be handled by the SDK.
    @return false
 */
+ (BOOL) restartApplication
{
    return false;
}

/*!
    Function as per IntuneMAMPolicyDelegate.h documentation.
 
    Lets the SDK handle the removal of data associated with a specified user.
    This is a design choice, developers can implement this function to handle the removal of the specified user data and return True when finished. Read IntuneMAMPolicyDelegate.h documentation.
    @return false
 */
- (BOOL) wipeDataForAccount:(NSString*)upn {
    return false;
}

/*!
    Functions taken from https://docs.microsoft.com/en-us/intune/app-sdk-ios as per IntuneMAMEnrollmentDelegate.h documentation.
 */
- (void)enrollmentRequestWithStatus:(IntuneMAMEnrollmentStatus*)status
{
    NSLog(@"enrollment result for identity %@ with status code %ld", status.identity, (unsigned long)status.statusCode);
    NSLog(@"Debug Message: %@", status.errorString);
}

- (void)policyRequestWithStatus:(IntuneMAMEnrollmentStatus*)status
{
    NSLog(@"policy check-in result for identity %@ with status code %ld", status.identity, (unsigned long)status.statusCode);
    NSLog(@"Debug Message: %@", status.errorString);
}

- (void)unenrollRequestWithStatus:(IntuneMAMEnrollmentStatus*)status
{
    NSLog(@"un-enroll result for identity %@ with status code %ld", status.identity, (unsigned long)status.statusCode);
    NSLog(@"Debug Message: %@", status.errorString);
}

@end
