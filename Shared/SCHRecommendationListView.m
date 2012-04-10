//
//  SCHRecommendationListView.m
//  Scholastic
//
//  Created by Gordon Christie on 14/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHRecommendationListView.h"
#import "SCHAppRecommendationItem.h"
#import <QuartzCore/QuartzCore.h>
#import "UILabel+ScholasticAdditions.h"

#define RIGHT_ELEMENTS_PADDING 5.0
#define TOP_BOTTOM_PADDING 18.0

@interface SCHRecommendationListView ()

- (void)initialiseView;

@property (nonatomic, retain) UIImage *initialNormalStateImage;
@property (nonatomic, retain) UIImage *initialSelectedStateImage;

@end

@implementation SCHRecommendationListView

@synthesize delegate;
@synthesize ISBN;
@synthesize isOnWishList;
@synthesize lastAuthenticationFailed;
@synthesize showsBottomRule;
@synthesize recommendationBackgroundColor;

@synthesize coverImageView;
@synthesize titleLabel;
@synthesize subtitleLabel;
@synthesize rateView;
@synthesize ratingLabel;
@synthesize ratingBackgroundImageView;
@synthesize onWishListButton;
@synthesize middleView;
@synthesize leftView;
@synthesize ruleImageView;
@synthesize initialNormalStateImage;
@synthesize initialSelectedStateImage;

- (void)dealloc
{
    delegate = nil;
    [recommendationBackgroundColor release], recommendationBackgroundColor = nil;
    [ISBN release], ISBN = nil;
    [coverImageView release], coverImageView = nil;
    [titleLabel release], titleLabel = nil;
    [subtitleLabel release], subtitleLabel = nil;
    [rateView release], rateView = nil;
    [ratingLabel release], ratingLabel = nil;
    [onWishListButton release], onWishListButton = nil;
    [ratingBackgroundImageView release], ratingBackgroundImageView = nil;
    [ruleImageView release], ruleImageView = nil;
    [initialNormalStateImage release], initialNormalStateImage = nil;
    [initialSelectedStateImage release], initialSelectedStateImage = nil;

    [middleView release];
    [leftView release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
    
	if (self) {
        self.showsBottomRule = YES;
        self.lastAuthenticationFailed = NO;
	}
    
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
	if (self) {
        self.showsBottomRule = YES;
	}
    
	return self;
}

- (IBAction)toggledOnWishListButton:(UIButton *)wishListButton
{
    if (self.delegate) {
        if (!wishListButton.isSelected) {
            [self.delegate recommendationListView:self addedISBNToWishList:self.ISBN];
            [self setIsOnWishList:YES];
        } else {
            [self.delegate recommendationListView:self removedISBNFromWishList:self.ISBN];
            [self setIsOnWishList:NO];
        }
    }
}

- (void)setIsOnWishList:(BOOL)newIsOnWishList
{
    UIImage *selectedImage = [self initialSelectedStateImage];
    UIImage *normalImage = [self initialNormalStateImage];
    
    isOnWishList = newIsOnWishList;
    
    if (isOnWishList) {
        [self.onWishListButton setImage:selectedImage forState:UIControlStateNormal];
        [self.onWishListButton setImage:selectedImage forState:UIControlStateSelected];
    } else {
        [self.onWishListButton setImage:normalImage forState:UIControlStateNormal];
        [self.onWishListButton setImage:normalImage forState:UIControlStateSelected];
    }
    
    [self.onWishListButton setSelected:isOnWishList];
}

- (void)updateWithRecommendationItem:(NSDictionary *)item
{
    [self initialiseView];

    self.ISBN = [item objectForKey:kSCHAppRecommendationISBN];
    self.titleLabel.text = [item objectForKey:kSCHAppRecommendationTitle];
    self.subtitleLabel.text = [item objectForKey:kSCHAppRecommendationAuthor];
    self.rateView.rating = [[item objectForKey:kSCHAppRecommendationAverageRating] floatValue];
    UIImage *coverImage = [item objectForKey:kSCHAppRecommendationCoverImage];
    
    if (coverImage && ![coverImage isKindOfClass:[NSNull class]]) {
        self.coverImageView.image = coverImage;
    }
}

- (void)updateWithWishListItem:(NSDictionary *)item
{
    [self initialiseView];

    self.ISBN = [item objectForKey:kSCHAppRecommendationISBN];
    self.titleLabel.text = [item objectForKey:kSCHAppRecommendationTitle];
    self.subtitleLabel.text = [item objectForKey:kSCHAppRecommendationAuthor];
    self.rateView.rating = [[item objectForKey:kSCHAppRecommendationAverageRating] floatValue];
    UIImage *coverImage = [item objectForKey:kSCHAppRecommendationCoverImage];
    
    if (coverImage && ![coverImage isKindOfClass:[NSNull class]]) {
        self.coverImageView.image = coverImage;
    }
}

- (void)setRecommendationBackgroundColor:(UIColor *)newRecommendationBackgroundColor
{
    UIColor *oldColor = recommendationBackgroundColor;
    recommendationBackgroundColor = [newRecommendationBackgroundColor retain];
    [oldColor release];
    
    self.backgroundColor = self.recommendationBackgroundColor;
    self.titleLabel.backgroundColor = self.recommendationBackgroundColor;
    self.subtitleLabel.backgroundColor = self.recommendationBackgroundColor;
}

- (void)initialiseView
{
    self.rateView.editable = NO;
    self.rateView.fullSelectedImage = [UIImage imageNamed:@"storiaBlueStarFull"];
    self.rateView.notSelectedImage = [UIImage imageNamed:@"storiaBlueStarEmpty"];
    self.rateView.halfSelectedImage = [UIImage imageNamed:@"storiaBlueStarHalfFull"];
    
    self.ratingBackgroundImageView.image = [[UIImage imageNamed:@"BookShelfListRatingBackground"] stretchableImageWithLeftCapWidth:19 topCapHeight:0];
    
    self.ruleImageView.image = [[UIImage imageNamed:@"ListViewRule"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];

    if (self.showsBottomRule) {
        self.ruleImageView.hidden = NO;
    } else {
        self.ruleImageView.hidden = YES;
    }
    
    if (self.lastAuthenticationFailed) {
        self.onWishListButton.hidden = YES;
    } else {
        self.onWishListButton.hidden = NO;
    }
}

- (UIImage *)initialNormalStateImage
{
    if (!initialNormalStateImage) {
        initialNormalStateImage = [[self.onWishListButton imageForState:UIControlStateNormal] retain];
    }
    
    return initialNormalStateImage;
}

- (UIImage *)initialSelectedStateImage
{
    if (!initialSelectedStateImage) {
        initialSelectedStateImage = [[self.onWishListButton imageForState:UIControlStateSelected] retain];
    }
    
    return initialSelectedStateImage;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.titleLabel adjustPointSizeToFitWidthWithPadding:0];
    [self.subtitleLabel adjustPointSizeToFitWidthWithPadding:0];
}

@end
