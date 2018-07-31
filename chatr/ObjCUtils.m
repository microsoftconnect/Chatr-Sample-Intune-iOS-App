//
//  ObjCUtils.m
//  chatr
//
//  Created by Meseret  Kebede on 23/07/2018.
//  Copyright © 2018 Microsoft Intune. All rights reserved.
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
#import "ObjCUtils.h"

@implementation ObjCUtils
/*
 * GET TOKEN FUNCTION TAKEN FROM ACTIVE AD DOCUMENTATION.
 *
 */
+ (void)getToken: ( UIViewController* )presentingViewController
{
    ADAuthenticationError *error = nil;
    ADAuthenticationContext *authContext = [ADAuthenticationContext authenticationContextWithAuthority:@"https://login.microsoftonline.com/common"
                                                                        error:&error];
    
    [authContext acquireTokenWithResource:@"https://graph.windows.net"
                                 clientId:@"3b8b98a5-94d4-48e7-af6a-d96dfc69763a"                          // Comes from App Portal
                              redirectUri:[NSURL URLWithString:@"chatr://Intune.chatr"]                    // Comes from App Portal
                          completionBlock:^(ADAuthenticationResult *result)
     {
         if (AD_SUCCEEDED != result.status){
             printf("I failed to sign in");
             // handle a failure in the code to be written by the dev
             UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"My Alert"
                                                                            message:@"This is an alert."
                                                                     preferredStyle:UIAlertControllerStyleAlert];
             
             UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                   handler:^(UIAlertAction * action) {}];
             
             [alert addAction:defaultAction];
             [presentingViewController presentViewController:alert animated:YES completion:nil];
             
         }
         else{
             printf("I was successful to sign in");
             [presentingViewController performSegueWithIdentifier: @"homePage" sender:presentingViewController];
             
             //completionBlock(result.accessToken);
         }
     }];
}

+ (void)removeToken: ( UIViewController* )presentingViewController
{
    
}

@end
