//
//  adalIntegrations.m
//  chatr
//
//  Created by Meseret  Kebede on 19/07/2018.
//  Copyright © 2018 Microsoft Intune. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ADAL/ADAuthenticationError.h>


@implementation adalIntegrations : NSObject

+ (void)getToken:(void (^)(NSString*))completionBlock;
{
    ADAuthenticationError *error = nil;
    authContext = [ADAuthenticationContext authenticationContextWithAuthority:@"https://login.microsoftonline.com/common"
                                                                        error:&error];
    
    [authContext acquireTokenWithResource:@"https://graph.windows.net"
                                 clientId:@"<Your Client ID>"                          // Comes from App Portal
                              redirectUri:[NSURL URLWithString:@"<Your Redirect URI>"] // Comes from App Portal
                          completionBlock:^(ADAuthenticationResult *result)
     {
         if (AD_SUCCEEDED != result.status){
             // display error on the screen
             [self showError:result.error.errorDetails];
         }
         else{
             completionBlock(result.accessToken);
         }
     }];
}

@end
