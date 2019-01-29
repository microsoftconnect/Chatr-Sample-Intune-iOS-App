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



@end
#endif /* ObjCUtils_h */
