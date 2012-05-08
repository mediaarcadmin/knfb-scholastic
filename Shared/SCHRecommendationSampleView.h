//
//  SCHRecommendationSampleView.h
//  Scholastic
//
//  Created by Gordon Christie on 07/05/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SCHRecommendationSampleViewDelegate;

@interface SCHRecommendationSampleView : UIView



@property (retain, nonatomic) IBOutlet UIImageView *largeCoverImageView;
@property (retain, nonatomic) IBOutlet UIButton *wishListButton;
@property (retain, nonatomic) IBOutlet UILabel *infoLabel;
@property (retain, nonatomic) IBOutlet UIView *boxView;

@property (nonatomic, assign) id <SCHRecommendationSampleViewDelegate> delegate;
@property (nonatomic, retain) NSString *ISBN;
@property (nonatomic, assign) BOOL isOnWishList;

- (void)updateWithRecommendationItemDictionary:(NSDictionary *)recommendationDictionary;
- (void)hideWishListButton;

@end

@protocol SCHRecommendationSampleViewDelegate <NSObject>

- (void)recommendationSampleView: (SCHRecommendationSampleView *)sampleView addedISBNToWishList:(NSString *)ISBN;
- (void)recommendationSampleView: (SCHRecommendationSampleView *)sampleView removedISBNFromWishList:(NSString *)ISBN;

@end