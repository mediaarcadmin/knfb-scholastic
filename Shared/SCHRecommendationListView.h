//
//  SCHRecommendationListView.h
//  Scholastic
//
//  Created by Gordon Christie on 14/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCHRecommendationItem.h"
#import "SCHWishListItem.h"

@protocol SCHRecommendationListViewDelegate;

@interface SCHRecommendationListView : UIView

@property (nonatomic, assign) id <SCHRecommendationListViewDelegate> delegate;
@property (nonatomic, retain) NSString *ISBN;
@property (nonatomic, assign) BOOL isOnWishList;

- (void)updateWithRecommendationItem:(NSDictionary *)item;
- (void)updateWithWishListItem:(NSDictionary *)item;

@end

@protocol SCHRecommendationListViewDelegate <NSObject>

- (void)recommendationListView:(SCHRecommendationListView *)listView addedISBNToWishList:(NSString *)ISBN;
- (void)recommendationListView:(SCHRecommendationListView *)listView removedISBNFromWishList:(NSString *)ISBN;

@end
