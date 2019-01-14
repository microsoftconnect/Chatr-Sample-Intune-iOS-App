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
 
 NOTE: A number of other methods are avaliable in the IntuneMAMEnrollmentDelegate. See documentation or header file for more info.
 */
@interface enrollmentDelegateClass : NSObject <IntuneMAMEnrollmentDelegate>

@property (nonatomic, strong) UIViewController *presentingViewController;

/*
 To be able to change the view, the class should be initialzed with the curent view controller. Then this view controller can segue to the desired view based on the login success
 
 @param initWithViewController - the view controller this class should use when triggered
 */
- (id)initWithViewController:(UIViewController *)presentingViewController;

/*
 This is a method of the delegate that is triggered when an instance of this class is set as the delegate of the IntuneMAMEnrollmentManager and an enrollment is attemted.
 The status is the IntuneMAMEnrollmentStatus object. This object can be used to check for the status of an attempted login/enrollment
 If successful, logic for login is initiated
 */
- (void)enrollmentRequestWithStatus:(IntuneMAMEnrollmentStatus *_Nonnull)status;

/*
 This is a method of the delegate that is triggered when an instance of this class is set as the delegate of the IntuneMAMEnrollmentManager and an unenrollment is attemted.
 The status is the IntuneMAMEnrollmentStatus object. This object can be used to check for the status of an attempted unenrollment
 If successful, logic for logout/token clearing is initiated
 
 */
- (void)unenrollRequestWithStatus:(IntuneMAMEnrollmentStatus *_Nonnull)status;

@end

#endif /* EnrollmentDelegateHeader_h */
