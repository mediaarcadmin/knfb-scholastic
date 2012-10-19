//
//  SCHURLManager.h
//  Scholastic
//
//  Created by John S. Eddie on 04/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BITAPIProxyDelegate.h"

@class SCHBookIdentifier;

// Constants
extern NSString * const kSCHURLManagerSuccess;
extern NSString * const kSCHURLManagerFailure;
extern NSString * const kSCHURLManagerBatchComplete;
extern NSString * const kSCHURLManagerError;
extern NSString * const kSCHURLManagerCleared;

@interface SCHURLManager : NSObject <BITAPIProxyDelegate>
{	
}

+ (SCHURLManager *)sharedURLManager;

- (void)requestURLForBook:(SCHBookIdentifier *)bookIdentifier
                  version:(NSNumber *)version;
// book = dictionary of bookIdentifiers and versions
- (void)requestURLForBooks:(NSArray *)arrayOfBooks;
- (void)requestURLForRecommendation:(NSString *)isbn;
- (void)requestURLForRecommendations:(NSArray *)arrayOfISBNs;
- (void)clear;

@end
