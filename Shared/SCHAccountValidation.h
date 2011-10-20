//
//  SCHAccountValidation.h
//  Scholastic
//
//  Created by John Eddie on 17/10/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BITAPIProxyDelegate.h"

// Constants
extern NSString * const kSCHAccountValidationErrorDomain;
extern NSInteger const kSCHAccountValidationPTokenError;

typedef void (^ValidateBlock)(NSString *pToken, NSError *error);

@interface SCHAccountValidation : NSObject <BITAPIProxyDelegate>

@property (nonatomic, copy, readonly) NSString *pToken;

- (BOOL)validateWithUserName:(NSString *)username 
                withPassword:(NSString *)password 
               validateBlock:(ValidateBlock)validateBlock;

@end
