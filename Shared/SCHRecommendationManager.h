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

@interface SCHRecommendationManager : NSObject

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (void)cancelAllOperations;
- (void)cancelAllOperationsForIsbn:(NSString *)isbn
waitUntilFinished:(BOOL)waitUntilFinished;
- (SCHAppRecommendationItem *)appRecommendationForIsbn:(NSString *)isbn;
- (void)setProcessing:(BOOL)processing forIsbn:(NSString *)isbn;

+ (SCHRecommendationManager *)sharedManager;
+ (BOOL)urlIsValid:(NSString *)urlString;

@end