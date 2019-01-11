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

/*
 This enrollment delegate class can be initialized and set as the enrollment delegate of the IntuneMAMEnrollmentManager
 Doing this will trigger the enrollmentRequestWithStatus method whenever an enrollment is attempted.
 It can also be used to trigger unenrollRequestWithStatus whenever unenrollment is attempted. 
 This allows for the app to check if an enrollment/login was successful
 */
@interface enrollmentDelegateClass : NSObject <IntuneMAMEnrollmentDelegate>

@property (nonatomic, strong) UIViewController *presentingViewController;
- (id)initWithViewController:(UIViewController *)presentingViewController;
- (void)enrollmentRequestWithStatus:(IntuneMAMEnrollmentStatus *_Nonnull)status;
- (void)unenrollRequestWithStatus:(IntuneMAMEnrollmentStatus *_Nonnull)status;

@end

#endif /* EnrollmentDelegateHeader_h */
