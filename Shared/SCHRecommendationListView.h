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
#import "RateView.h"
#import "TTTAttributedLabel.h"

@protocol SCHRecommendationListViewDelegate;

@interface SCHRecommendationListView : UIView

@property (nonatomic, assign) id <SCHRecommendationListViewDelegate> delegate;
@property (nonatomic, retain) NSString *ISBN;
@property (nonatomic, assign) BOOL isOnWishList;
@property (nonatomic, assign) BOOL showsBottomRule;
@property (nonatomic, assign) BOOL showOnBackCover; // default NO
@property (nonatomic, assign) BOOL showsWishListButton; // default yes
@property (nonatomic, retain) UIColor *recommendationBackgroundColor;

@property (nonatomic, retain) IBOutlet UIImageView *coverImageView;
@property (nonatomic, retain) IBOutlet TTTAttributedLabel *titleAndSubtitleLabel;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *subtitleLabel;
@property (nonatomic, retain) IBOutlet RateView *rateView;
@property (nonatomic, retain) IBOutlet UILabel *ratingLabel;
@property (nonatomic, retain) IBOutlet UIImageView *ratingBackgroundImageView;
@property (nonatomic, retain) IBOutlet UIButton *onWishListButton;

@property (nonatomic, retain) IBOutlet UIView *middleView;
@property (nonatomic, retain) IBOutlet UIView *leftView;
@property (nonatomic, retain) IBOutlet UIImageView *ruleImageView;
@property (nonatomic, retain) IBOutlet UIView *ratingContainer;

@property (nonatomic, assign) UIEdgeInsets insets;
@property (nonatomic, assign) CGFloat maxPointSize;

- (void)updateWithRecommendationItem:(NSDictionary *)item;
- (void)updateWithWishListItem:(NSDictionary *)item;
- (IBAction)toggledOnWishListButton:(UIButton *)wishListButton;

@end

@protocol SCHRecommendationListViewDelegate <NSObject>

- (void)recommendationListView:(SCHRecommendationListView *)listView addedISBNToWishList:(NSString *)ISBN;
- (void)recommendationListView:(SCHRecommendationListView *)listView removedISBNFromWishList:(NSString *)ISBN;

@end
