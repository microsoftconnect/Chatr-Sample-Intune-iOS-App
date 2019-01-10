//
//  EnrollmentDelegate.m
//  chatr
//
//  Created by Wilson Spearman on 1/9/19.
//  Copyright © 2019 Microsoft Intune. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <IntuneMAM/IntuneMAMEnrollmentDelegate.h>

@interface enrollmentDelegateClass : NSObject
@property (nonatomic, weak) id <IntuneMAMEnrollmentDelegate> delegate;

-(void) checkEnrollment;
@end

@implementation enrollmentDelegateClass
@synthesize delegate;

- (void)checkEnrollment{
    
    if (self.delegate != nil && [delegate respondsToSelector:@selector(enrollmentRequestWithStatus:)]){
        [[self delegate] enrollmentRequestWithStatus:self];
    }
}
@end

