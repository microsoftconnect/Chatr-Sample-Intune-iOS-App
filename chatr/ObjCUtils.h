//
//  ObjCUtils.h
//  chatr
//
//  Created by Meseret  Kebede on 23/07/2018.
//  Copyright © 2018 Microsoft Intune. All rights reserved.
//

#ifndef ObjCUtils_h
#define ObjCUtils_h

@interface ObjCUtils : NSObject
/*
 * GET TOKEN FUNCTION TAKEN FROM ACTIVE AD documentation.
 *
 */
+ (void)getToken: ( UIViewController* )presentingViewController;
+ (void)removeToken: ( UIViewController* )presentingViewController;
@end
#endif /* ObjCUtils_h */
