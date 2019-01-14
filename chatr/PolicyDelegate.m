//
//  PolicyDelegate.m
//  chatr
//
//  Created by Wilson Spearman on 1/11/19.
//  Copyright © 2019 Microsoft Intune. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PolicyDelegate.h"

#import <ADAL/ADKeychainTokenCache.h>
#import <ADAL/ADAuthenticationError.h>
#import <ADAL/ADTokenCacheItem.h>
#import <ADAL/ADUserInformation.h>

/*
 This policy delegate class can be initialized and set as the enrollment delegate of the IntuneMAMPolicyManager
 (This is done in the AppDelegate.swift file at app initialization)
 Doing this will trigger the wipeDataForAccount and restartApplication methods whenever the Intune SDK needs to do either of these things
 
 NOTE: A number of other methods are avaliable in the IntuneMAMPolicyDelegate. See documentation or header file for more info.
 Methods like identitySwitchRequired and addIdentity are generally used in multi-user apps, unlike this single user app.
 See IntuneMAMPolicyDelegate documentation or header file for more information
 */
@implementation policyDelegateClass

/*
 wipeDataForAccount is called by the Intune SDK when the app needs to wipe all the data for a specified user
 With chatr, the only user data stored is the token for the user. If this is wiped successfully, return TRUE.
 Otherwise return FALSE
 
 @param upn is the upn of the user whoes data is to be wiped (for example "user@example.com")
 */
- (BOOL)wipeDataForAccount:(NSString*_Nonnull)upn{
    //only user data stored on this app is tokens, so wipe those for the specified upn
    ADKeychainTokenCache* cache = [ADKeychainTokenCache defaultKeychainCache];
    ADAuthenticationError *error = nil;
    
    //Wipe cache with ADAL API, this code goes through all tokens in the cache and clears those with the same upn as given by the SDK
    [cache wipeAllItemsForUserId: upn
                           error: &error];
    
    ADAuthenticationError *allItemsError = nil;
    NSArray <ADTokenCacheItem *> *allItems = [cache allItems:&allItemsError];
    
    for (ADTokenCacheItem *item in allItems) {
        if ([item.userInformation.userId caseInsensitiveCompare:upn] == NSOrderedSame) {
            //if tokens for the user are found in the cache, return FALSE as the wipe failed
            NSLog(@"Wipe failed");
            return FALSE;
        }
    }
    
    //if the tokens for the user were not found in the cache, the wipe was successful, return TRUE
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
