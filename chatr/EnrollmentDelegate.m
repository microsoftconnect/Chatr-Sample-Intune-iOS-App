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
#import <ADAL/ADKeychainTokenCache.h>
#import <ADAL/ADAuthenticationError.h>
#import <ADAL/ADTokenCacheItem.h>
#import <ADAL/ADUserInformation.h>

/*
 This enrollment delegate class can be initialized and set as the enrollment delegate of the IntuneMAMEnrollmentManager
 Doing this will trigger the enrollmentRequestWithStatus method whenever an enrollment is attempted.
 This allows for the app to check if an enrollment/login was successful
 */
@implementation enrollmentDelegateClass

/*
 To be able to change the view, the class should be initialzed with the curent view controller. Then this view controller can segue to the desired view based on the login success
 
 @param initWithViewController - the view controller this class should use when triggered
 */
- (id) initWithViewController:(UIViewController *)presentingViewController {
    self = [super init];
    
    if (self) {
        self.presentingViewController = presentingViewController;
    }
    return self;
}

/*
This is a method of the delegate that is triggered when an instance of this class is set as the delegate of the IntuneMAMEnrollmentManager and an enrollment is attemted.
The status is the IntuneMAMEnrollmentStatus object. This object can be used to check for the status of an attempted login/enrollment
 If successful, logic for login is initiated
 */
- (void)enrollmentRequestWithStatus:(IntuneMAMEnrollmentStatus *_Nonnull)status{
    if (status.didSucceed) {
        //if login was successful, change from the current view (which should have been initialized with the class) to the desired page on the app (in this case homePage)
        NSLog(@"Login Successful");
        [self.presentingViewController performSegueWithIdentifier: @"homePage" sender:self.presentingViewController];
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
                                                                  [self.presentingViewController presentViewController:alert animated:YES completion:nil];
                                                              }];
        printf("Sign in failed, and no alert");
        [alert addAction:defaultAction];
    }
}

/*
 This is a method of the delegate that is triggered when an instance of this class is set as the delegate of the IntuneMAMEnrollmentManager and an unenrollment is attemted.
 The status is the IntuneMAMEnrollmentStatus object. This object can be used to check for the status of an attempted unenrollment
 If successful, logic for logout/token clearing is initiated
 
 */
- (void)unenrollRequestWithStatus:(IntuneMAMEnrollmentStatus *_Nonnull)status{
    if (status.didSucceed){
        //in the case of succesful logout, the tokens with the account should be cleared.
        
        ADKeychainTokenCache* cache = [ADKeychainTokenCache defaultKeychainCache];
        
        // Find the user that is unenrolling
        NSString* userID = status.identity;
        
        //ADAL only supports clearing the cache for a certain user if the ClientID is also passed in, but since the clientID isn't exposed by the Intune
        //API, this code goes through all tokens in the cache and clears those with the same userId as the unenrolling user
        ADAuthenticationError *allItemsError = nil;
        NSArray <ADTokenCacheItem *> *allItems = [cache allItems:&allItemsError];
        
        for (ADTokenCacheItem *item in allItems) {
            if ([item.userInformation.userId caseInsensitiveCompare:userID] == NSOrderedSame) {
                //for matching tokens, clear them
                [cache removeItem:item error:&allItemsError];
            }
        }

        ADAuthenticationError *error = nil;
        
        //Wipe cache with ADAL method
        [cache wipeAllItemsForUserId: userID
                               error: &error];
        NSLog(@"Error details: %@", error.errorDetails);
        
    }
    }
@end
