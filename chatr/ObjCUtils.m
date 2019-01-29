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

@implementation ObjCUtils

/*!
    Checks if saving to local drive is allowed by policy. Used by the app to check if save is allowed, before the action is executed.
    Modify the parameter in isSaveToAllowedForLocation to check for other APP controlled save locations. Documentation in IntuneMAMPolicy.h
 
    @return True if allowed, false otherwise
 */
+ (BOOL) isSaveToLocalDriveAllowed
{
    // Find the user that is signed in
    NSString* userID = [[IntuneMAMEnrollmentManager instance] enrolledAccount];
    
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
    NSString* userID = [[IntuneMAMEnrollmentManager instance] enrolledAccount];
    
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
