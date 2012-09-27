//
//  SCHAppProfile.h
//  Scholastic
//
//  Created by John S. Eddie on 06/05/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SCHProfileItem;
@class SCHAppRecommendationProfile;
@class SCHAppRecommendationTopRating;
@class SCHWishListProfile;

// Constants
extern NSString * const kSCHAppProfile;

@interface SCHAppProfile : NSManagedObject 
{
}

@property (nonatomic, retain) NSString * AutomaticallyLaunchBook;
@property (nonatomic, retain) NSNumber * SelectedTheme;
@property (nonatomic, retain) SCHProfileItem * ProfileItem;
@property (nonatomic, retain) NSNumber *FontIndex;
@property (nonatomic, retain) NSNumber *LayoutType;
@property (nonatomic, retain) NSNumber *PaperType;
@property (nonatomic, retain) NSNumber *SortType;
@property (nonatomic, retain) NSNumber *ShowListView;
@property (nonatomic, retain) NSDate * lastEnteredBookshelfDate;

- (SCHAppRecommendationProfile *)appRecommendationProfile;
- (SCHAppRecommendationTopRating *)appRecommendationTopRating;
- (NSArray *)recommendationDictionaries;
- (SCHWishListProfile *)wishListProfile;
- (NSArray *)wishListItemDictionaries;
- (void)addToWishList:(NSDictionary *)wishListItem;
- (void)removeFromWishList:(NSDictionary *)wishListItem;

@end
