//
//  SCHRecommendationManager.h
//  Scholastic
//
//  Created by Matt Farrugia on 21/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSManagedObjectContext;

@interface SCHRecommendationManager : NSObject

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

+ (SCHRecommendationManager *)sharedManager;
- (void)cancelAllOperations;
- (void)cancelAllOperationsForIsbn:(NSString *)isbn;

@end