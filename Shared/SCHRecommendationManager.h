//
//  SCHRecommendationManager.h
//  Scholastic
//
//  Created by Matt Farrugia on 21/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSManagedObjectContext;
@class SCHAppRecommendationItem;

// Constants
extern NSString * const kSCHRecommendationStateUpdateNotification;

@interface SCHRecommendationManager : NSObject

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (void)cancelAllOperationsWaitUntilFinished:(BOOL)waitUntilFinished;
- (void)cancelAllOperationsForIsbn:(NSString *)isbn
waitUntilFinished:(BOOL)waitUntilFinished;
- (void)checkStateForRecommendation:(SCHAppRecommendationItem *)recommendationItem;
- (SCHAppRecommendationItem *)appRecommendationForIsbn:(NSString *)isbn;
- (void)setProcessing:(BOOL)processing forIsbn:(NSString *)isbn;
- (void)beginProcessingForRecommendationItems:(NSArray *)recommendationItems;

+ (SCHRecommendationManager *)sharedManager;
+ (BOOL)urlIsValid:(NSString *)urlString;

@end