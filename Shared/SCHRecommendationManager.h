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

typedef enum {
    kSCHAppRecommendationProcessingStateURLsNotPopulated        = -5,
    kSCHAppRecommendationProcessingStateDownloadFailed          = -4,
    kSCHAppRecommendationProcessingStateCachedCoverError        = -3,
    kSCHAppRecommendationProcessingStateThumbnailError          = -2,
	kSCHAppRecommendationProcessingStateError                   = -1,
	kSCHAppRecommendationProcessingStateNoMetadata              = 0,
    kSCHAppRecommendationProcessingStateNoCover                 = 1,
    kSCHAppRecommendationProcessingStateNoThumbnails            = 2,
	kSCHAppRecommendationProcessingStateComplete                = 3
} SCHAppRecommendationProcessingState;

@interface SCHRecommendationManager : NSObject

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (void)cancelAllOperations;
- (void)cancelAllOperationsForIsbn:(NSString *)isbn;
- (SCHAppRecommendationItem *)appRecommendationForIsbn:(NSString *)isbn;
- (void)setProcessing:(BOOL)processing forIsbn:(NSString *)isbn;

+ (SCHRecommendationManager *)sharedManager;
+ (BOOL)urlIsValid:(NSString *)urlString;

@end