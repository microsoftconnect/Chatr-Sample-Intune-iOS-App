//
//  EnrollmentDelegateHeader.h
//  chatr
//
//  Created by Wilson Spearman on 1/10/19.
//  Copyright © 2019 Microsoft Intune. All rights reserved.
//

#import <IntuneMAM/IntuneMAMEnrollmentDelegate.h>

#ifndef EnrollmentDelegateHeader_h
#define EnrollmentDelegateHeader_h

@class UIViewController;

@interface enrollmentDelegateClass : NSObject <IntuneMAMEnrollmentDelegate>
@property (nonatomic, strong) UIViewController *presentingViewController;
- (id)initWithViewController:(UIViewController *)presentingViewController;
- (void)enrollmentRequestWithStatus:(IntuneMAMEnrollmentStatus *_Nonnull)status;
@end

#endif /* EnrollmentDelegateHeader_h */
