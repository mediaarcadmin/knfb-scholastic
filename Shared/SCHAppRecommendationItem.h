//
//  SCHAppRecommendationItem.h
//  Scholastic
//
//  Created by John Eddie on 19/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SCHContentItem.h"
#import "SCHRecommendationManager.h"
#import "SCHISBNItem.h"

@class SCHRecommendationItem;
@class SCHWishListItem;

// Constants
extern NSString * const kSCHAppRecommendationItem;
extern NSString * const kSCHAppRecommendationItemIsbn;
extern NSUInteger const kSCHRecommendationThumbnailMaxDimensionPad;
extern NSUInteger const kSCHRecommendationThumbnailMaxDimensionPhone;

extern NSString * const kSCHAppRecommendationTitle;
extern NSString * const kSCHAppRecommendationAuthor;
extern NSString * const kSCHAppRecommendationISBN;
extern NSString * const kSCHAppRecommendationAverageRating;
extern NSString * const kSCHAppRecommendationCoverImage;

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

@interface SCHAppRecommendationItem : NSManagedObject <SCHISBNItem>

@property (nonatomic, retain) NSString * ContentIdentifier;
@property (nonatomic, retain) NSString * Author;
@property (nonatomic, retain) NSNumber * AverageRating;
@property (nonatomic, retain) NSString * CoverURL;
@property (nonatomic, retain) NSString * Title;
@property (nonatomic, retain) NSSet *recommendationItems;
@property (nonatomic, retain) NSNumber * state;
@property (nonatomic, retain) NSSet *wishListItems;

- (SCHAppRecommendationProcessingState)processingState;
- (void)setProcessingState:(SCHAppRecommendationProcessingState)processingState;
- (UIImage *)bookCover;
- (BOOL)isInUse;
- (BOOL)isReady;

- (NSString *)coverImagePath;
- (NSString *)thumbPath;
- (NSString *)recommendationDirectory;

- (NSDictionary *)dictionary;

+ (NSString *)recommendationsDirectory;

@end

@interface SCHAppRecommendationItem (CoreDataGeneratedAccessors)

- (void)addRecommendationItemsObject:(SCHRecommendationItem *)value;
- (void)removeRecommendationItemsObject:(SCHRecommendationItem *)value;
- (void)addRecommendationItems:(NSSet *)values;
- (void)removeRecommendationItems:(NSSet *)values;

- (void)addWishListItemsObject:(SCHWishListItem *)value;
- (void)removeWishListItemsObject:(SCHWishListItem *)value;
- (void)addWishListItems:(NSSet *)values;
- (void)removeWishListItems:(NSSet *)values;

@end
