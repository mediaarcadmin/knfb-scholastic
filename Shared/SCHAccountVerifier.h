//
//  SCHAccountVerifier.h
//  Scholastic
//
//  Created by John Eddie on 20/07/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BITAPIProxyDelegate.h"

// Constants
extern NSString * const kSCHAccountVerifierErrorDomain;
extern NSInteger const kSCHAccountVerifierSPSIDError;
extern NSInteger const kSCHAccountVerifierStoredSPSIDError;

typedef void (^AccountVerifiedBlock)(BOOL accountIsValid, NSError *error);

@interface SCHAccountVerifier : NSObject <BITAPIProxyDelegate>

- (BOOL)verifyAccount:(NSString *)spsID
 accountVerifiedBlock:(AccountVerifiedBlock)anAccountVerifiedBlock;

@end
