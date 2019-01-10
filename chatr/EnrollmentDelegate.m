//
//  EnrollmentDelegate.m
//  chatr
//
//  Created by Wilson Spearman on 1/9/19.
//  Copyright © 2019 Microsoft Intune. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EnrollmentDelegate.h"
#import <UIKit/UIKit.h>

/*
 This 
 */
@implementation enrollmentDelegateClass

- (id) initWithViewController:(UIViewController *)presentingViewController {
    self = [super init];
    
    if (self) {
        self.presentingViewController = presentingViewController;
    }
    return self;
}

- (void)enrollmentRequestWithStatus:(IntuneMAMEnrollmentStatus *_Nonnull)status{
    if (status.didSucceed) {
        [self.presentingViewController performSegueWithIdentifier: @"homePage" sender:self.presentingViewController];
    } else {
        printf("Sign in failed");
        
        // present the user with an alert asking them to sign in again.
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error Authenticating"
                                                                       message:@"There was an error while logging you into you account. Please check your log in credentials and try again."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  [self.presentingViewController presentViewController:alert animated:YES completion:nil];
                                                              }];
        printf("Sign in failed, and no alert");
        [alert addAction:defaultAction];
        
    }
}
@end

