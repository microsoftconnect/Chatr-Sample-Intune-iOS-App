//
//  ObjCUtils.h
//  chatr
//
//  Created by Meseret  Kebede on 23/07/2018.
//  Copyright © 2018 Microsoft Intune. All rights reserved.
//

#import <IntuneMAM/IntuneMAMPolicyDelegate.h>
#import <IntuneMAM/IntuneMAMEnrollmentDelegate.h>

#ifndef ObjCUtils_h
#define ObjCUtils_h

@interface ObjCUtils : NSObject <IntuneMAMPolicyDelegate, IntuneMAMEnrollmentDelegate>

+ (NSString*) getSignedInUser;
+ (void)getToken: ( UIViewController* )presentingViewController;
+ (void)removeAppTokens;
+ (BOOL) restartApplication;
+ (BOOL) isSaveToLocalDriveAllowed;
+ (NSString*) getUserFirstName;


@end
#endif /* ObjCUtils_h */
