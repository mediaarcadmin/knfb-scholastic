//
//  SCHRecommendationOperation.h
//  Scholastic
//
//  Created by Matt Farrugia on 21/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHCoreDataOperation.h"
#import "SCHAppRecommendationItem.h"

@class SCHAppRecommendationItem;

@interface SCHRecommendationOperation : SCHCoreDataOperation {}

@property (nonatomic, copy) NSString *isbn;
@property (nonatomic, assign) BOOL executing;
@property (nonatomic, assign) BOOL finished;

- (void)beginOperation;
- (void)endOperation;

- (void)setNotCancelledCompletionBlock:(void (^)(void))block;

// thread-safe access
- (void)performWithRecommendation:(void (^)(SCHAppRecommendationItem *item))block;
- (void)performWithRecommendation:(void (^)(SCHAppRecommendationItem *item))block forRecommendationWithIsbn:(NSString *)isbn;
- (void)performWithRecommendationAndSave:(void (^)(SCHAppRecommendationItem *))block;
- (void)performWithRecommendationAndSave:(void (^)(SCHAppRecommendationItem *))block forRecommendationWithIsbn:(NSString *)isbn;
- (void)setProcessingState:(SCHAppRecommendationProcessingState)state;
- (void)setProcessingState:(SCHAppRecommendationProcessingState)state forRecommendationWithIsbn:(NSString *)isbn;

- (void)setCoverURLExpiredStateForRecommendationWithIsbn:(NSString *)isbn;
- (void)resetCoverURLExpiredStateForRecommendationWithIsbn:(NSString *)isbn;

@end
