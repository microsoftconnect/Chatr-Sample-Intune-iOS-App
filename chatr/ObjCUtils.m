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
#import "ObjCUtils.h"

@implementation ObjCUtils

/*!
    Gets the userID of the user that is logged into the app based on the tokens in the cache
 
    @return userID, nil if no-one is logged in
 */
+ (NSString*) getSignedInUser
{
    ADKeychainTokenCache* cache = [ADKeychainTokenCache defaultKeychainCache];
    NSString* userID = nil;
    
    // Finds all of the tokens stored in the cache
    NSArray<ADTokenCacheItem *> *cacheItems= [cache allItems:nil];
    
    // Find all tokens for the chatr client, and remove it from the cache. This will log out all of the users that are signed into the app
    for (ADTokenCacheItem *token in cacheItems) {
        NSString* clientID = token.clientId;
        
        // ** change the string for the clientID to be the Azure AD Application ID from the Azure portal
        if ([clientID isEqualToString:@"3b8b98a5-94d4-48e7-af6a-d96dfc69763a"]) {
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
    ADAuthenticationContext *authContext = [ADAuthenticationContext authenticationContextWithAuthority:@"https://login.microsoftonline.com/common" error:&error];
    
    // ** TO CHANGE:
    //    clientID          --> Azure AD Application ID for your app from the Azure portal
    //    redirectUri       --> <app-scheme>://<bundle-id> | further details can be found @ https://docs.microsoft.com/en-gb/azure/active-directory/develop/quickstart-v1-ios
    //    completionBlock   --> this is a function written by the developer that defines what happens in a success and failure case of authentication.
    [authContext acquireTokenWithResource:@"https://graph.windows.net"
                                 clientId:@"3b8b98a5-94d4-48e7-af6a-d96dfc69763a"                          // Comes from App Portal
                              redirectUri:[NSURL URLWithString:@"chatr://Intune.chatr"]                    // Comes from App Portal
                          completionBlock:^(ADAuthenticationResult *result)
     {
         // Handles the case that sign in has failed
         if (AD_SUCCEEDED != result.status){
             printf("Sign in failed");
             
             // present the user with an alert asking them to sign in again.
             UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error Authenticating"
                                                                            message:@"There was an error while logging you into you account. Please check your log in credentials and try again."
                                                                     preferredStyle:UIAlertControllerStyleAlert];
             
             UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                   handler:^(UIAlertAction * action) {
                                                                       [presentingViewController presentViewController:alert animated:YES completion:nil];
                                                                   }];
             [alert addAction:defaultAction];
             
         } else { // Sign in successful case
             printf("Successfully signed in");
             
             // get the id of the user that is currently signed in
             NSString* userID = [self getSignedInUser];
             
             // register the user account and attempt to enroll the app on behalf of this account
             [[IntuneMAMEnrollmentManager instance] registerAndEnrollAccount:userID];
             
             [presentingViewController performSegueWithIdentifier: @"homePage" sender:presentingViewController];
             //completionBlock(result.accessToken); --> TODO: Figure out what this function does
         }
     }];
}


/*!
    Removes all of the tokens from the Cache. This will log out all of the users that are currently signed into the app.
    For your apps: be sure to change the clientID --> This is the Application ID in the Azure portal
 */
+ (void)removeAppTokens
{
    ADKeychainTokenCache* cache = [ADKeychainTokenCache defaultKeychainCache];
    
    // Find the user that is signed in and log them out
    NSString* userID = [self getSignedInUser];
    
    // deregister the user from the SDK and initate a selective wipe of the app
    [[IntuneMAMEnrollmentManager instance] deRegisterAndUnenrollAccount:userID withWipe:YES];
    
    [cache removeAllForUserId: userID
                     clientId: @"3b8b98a5-94d4-48e7-af6a-d96dfc69763a"
                        error: nil];
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
