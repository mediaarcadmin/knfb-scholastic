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

- (void)updateWithRecommendationItem:(SCHRecommendationItem *)item;
- (void)updateWithWishListItem:(SCHWishListItem *)item;

@end

@protocol SCHRecommendationListViewDelegate <NSObject>

@end
