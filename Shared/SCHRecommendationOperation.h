//
//  SCHRecommendationOperation.h
//  Scholastic
//
//  Created by Matt Farrugia on 21/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHCoreDataOperation.h"

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
- (void)performWithRecommendationAndSave:(void (^)(SCHAppRecommendationItem *))block;

@end
