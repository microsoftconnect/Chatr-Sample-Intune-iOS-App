//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EnrollmentDelegate.h"
#import <UIKit/UIKit.h>
#import <ADAL/ADKeychainTokenCache.h>
#import <ADAL/ADAuthenticationError.h>

/*
 This enrollment delegate class can be initialized and set as the enrollment delegate of the IntuneMAMEnrollmentManager
 Doing this will trigger the enrollmentRequestWithStatus method whenever an enrollment is attempted.
 It can also be used to trigger unenrollRequestWithStatus whenever unenrollment is attempted.
 This allows for the app to check if an enrollment was successful
 
 NOTE: A number of other methods are avaliable in the IntuneMAMEnrollmentDelegate. See documentation or header file for more info.
 */
@implementation EnrollmentDelegateClass{
    UIViewController *presentingViewController;
}

/*
 This method retrieves the current view controller by going from the rootViewController to the currently presented view
 */
+ (UIViewController *) getCurrentViewController
{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    if (topController) {
        UIViewController *presentedViewController = topController.presentedViewController;
        //Loop until there are no more view controllers to go to
        while (presentedViewController){
            topController = presentedViewController;
            presentedViewController = topController.presentedViewController;
        }
    }
    //Return the final view controller
    return topController;
}


///*
// To be able to change the view, the class should be initialzed with the curent view controller. Then this view controller can segue to the desired view based on the enrollment success
//
// @param viewController - the view controller this class should use when triggered
// */
- (id) initWithViewController:(UIViewController *)viewController {
    self = [super init];

    if (self) {
        presentingViewController = viewController;
    }
    return self;
}

/*
This is a method of the delegate that is triggered when an instance of this class is set as the delegate of the IntuneMAMEnrollmentManager and an enrollment is attempted.
The status parameter is a member of the IntuneMAMEnrollmentStatus class. This object can be used to check for the status of an attempted enrollment
If successful, logic for enrollment is initiated
 */
- (void)enrollmentRequestWithStatus:(IntuneMAMEnrollmentStatus *_Nonnull)status{
    if (status.didSucceed) {
        //If enrollment was successful, change from the current view (which should have been initialized with the class) to the desired page on the app (in this case homePage)
        NSLog(@"Login Successful");
        [presentingViewController performSegueWithIdentifier: @"homePage" sender:presentingViewController];
    } else {
        //In the case of a failure, log failure error status and code
        NSLog(@"enrollment result for identity %@ with status code %ld", status.identity, (unsigned long)status.statusCode);
        NSLog(@"Debug Message: %@", status.errorString);
        
        // present the user with an alert asking them to sign in again.
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error Authenticating"
                                                                       message:@"There was an error while logging you into you account. Please check your log in credentials and try again."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  [presentingViewController presentViewController:alert animated:YES completion:nil];
                                                              }];
        [alert addAction:defaultAction];
    }
}

/*
 This is a method of the delegate that is triggered when an instance of this class is set as the delegate of the IntuneMAMEnrollmentManager and an unenrollment is attempted.
 The status parameter is a member of the IntuneMAMEnrollmentStatus class. This object can be used to check for the status of an attempted unenrollment.
 Logic for logout/token clearing is initiated here.
 */
- (void)unenrollRequestWithStatus:(IntuneMAMEnrollmentStatus *_Nonnull)status{
    //NOTE: The tokens could be shared by multiple apps, and in this case developers may choose to not clear them. In the case of this app, they are cleared as they are not being shared.
    
    ADKeychainTokenCache* cache = [ADKeychainTokenCache defaultKeychainCache];
    // Find the user that is unenrolling
    NSString* userID = status.identity;
    ADAuthenticationError *error = nil;
    
    //Wipe cache with ADAL API, this code goes through all tokens in the cache and clears those with the same userID as the unenrolling user
    [cache wipeAllItemsForUserId: userID
                           error: &error];
    
    //If there is an error clearing tokens, log it
    NSLog(@"Error details: %@", error.errorDetails);
    
    //Go back to login page from current view controller
    UIViewController*presentingViewController = [EnrollmentDelegateClass getCurrentViewController];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *mainPage = [storyboard instantiateViewControllerWithIdentifier: @"LoginPage"];
    
    [presentingViewController presentViewController:mainPage animated:YES completion:nil];
    
    if (status.didSucceed != TRUE){
        //In the case unenrollment failed, log error
        NSLog(@"Unenrollment failed");
        NSLog(@"Failure details: %@", status.errorString);
    }
}
@end
