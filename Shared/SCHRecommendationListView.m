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

#define RIGHT_ELEMENTS_PADDING 5.0
#define TOP_BOTTOM_PADDING 18.0

@interface SCHRecommendationListView ()

- (void)initialiseView;

@end

@implementation SCHRecommendationListView

@synthesize delegate;
@synthesize ISBN;
@synthesize isOnWishList;
@synthesize recommendationBackgroundColor;

@synthesize coverImageView;
@synthesize titleLabel;
@synthesize subtitleLabel;
@synthesize descriptionLabel;
@synthesize rateView;
@synthesize ratingLabel;
@synthesize ratingBackgroundImageView;
@synthesize onWishListButton;
@synthesize rightView;
@synthesize middleView;
@synthesize leftView;

- (void)dealloc
{
    delegate = nil;
    [recommendationBackgroundColor release], recommendationBackgroundColor = nil;
    [ISBN release], ISBN = nil;
    [coverImageView release], coverImageView = nil;
    [titleLabel release], titleLabel = nil;
    [subtitleLabel release], subtitleLabel = nil;
    [descriptionLabel release], descriptionLabel = nil;
    [rateView release], rateView = nil;
    [ratingLabel release], ratingLabel = nil;
    [onWishListButton release], onWishListButton = nil;
    [ratingBackgroundImageView release], ratingBackgroundImageView = nil;
    
    [rightView release];
    [middleView release];
    [leftView release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
    
	if (self) {

	}
    
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
	if (self) {

	}
    
	return self;
}

- (IBAction)toggledOnWishListButton:(UIButton *)wishListButton
{
    if (self.delegate) {
        if (!wishListButton.isSelected) {
            [self.delegate recommendationListView:self addedISBNToWishList:self.ISBN];
        } else {
            [self.delegate recommendationListView:self removedISBNFromWishList:self.ISBN];
        }
    }
}

- (void)setIsOnWishList:(BOOL)newIsOnWishList
{
    isOnWishList = newIsOnWishList;
    [self.onWishListButton setSelected:isOnWishList];
}

- (void)updateWithRecommendationItem:(NSDictionary *)item
{
    NSLog(@"Recommendation Item Dictionary: %@", item);

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
    NSLog(@"Wish List Item Dictionary: %@", item);
    
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
    self.rateView.halfSelectedImage = [UIImage imageNamed:@"storyBlueStarHalfFull"];
    
    self.ratingBackgroundImageView.image = [[UIImage imageNamed:@"BookShelfListRatingBackground"] stretchableImageWithLeftCapWidth:19 topCapHeight:0];
    
//    self.leftView.layer.borderWidth = 1;
//    self.rightView.layer.borderWidth = 1;
//    self.middleView.layer.borderWidth = 1;
//    
//    self.leftView.layer.borderColor = [UIColor redColor].CGColor;
//    self.rightView.layer.borderColor = [UIColor greenColor].CGColor;
//    self.middleView.layer.borderColor = [UIColor blueColor].CGColor;
}

//- (void)initialiseView 
//{
//    UIColor *viewBackgroundColor = [UIColor whiteColor];
//    
//    self.layer.borderWidth = 1;
//    self.layer.borderColor = [UIColor redColor].CGColor;
//    
//    self.backgroundColor = viewBackgroundColor;
//    
//    CGRect currentFrame = self.bounds;
//    NSLog(@"Current frame: %@", NSStringFromCGRect(self.bounds));
//    
//    CGFloat imageViewWidth = floorf(currentFrame.size.width * 0.2);
//    CGFloat rightStartingPoint = imageViewWidth + RIGHT_ELEMENTS_PADDING;
//
//    CGFloat labelHeight = 18;
//    
//    // cover view
//    CGRect coverViewFrame = CGRectMake(0, 0, imageViewWidth, currentFrame.size.height);
//    coverViewFrame = CGRectInset(coverViewFrame, 15, 15);
//    
//    self.coverImageView = [[[UIImageView alloc] initWithFrame:coverViewFrame] autorelease];
//    self.coverImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    self.coverImageView.contentMode = UIViewContentModeScaleAspectFit;
//    
//    [self addSubview:self.coverImageView];
//    
//    // title label
//    self.titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(rightStartingPoint, TOP_BOTTOM_PADDING, 
//                                                                 currentFrame.size.width - rightStartingPoint, 18)] autorelease];
//    
//    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin |
//                                       UIViewAutoresizingFlexibleWidth;
//    
//    self.titleLabel.font = [UIFont boldSystemFontOfSize:15];
//
//    self.titleLabel.backgroundColor = viewBackgroundColor;
//    self.titleLabel.layer.borderColor = [UIColor purpleColor].CGColor;
//    self.titleLabel.layer.borderWidth = 1;
//
//    [self addSubview:self.titleLabel];
//    
//    // subtitle label
//    self.subtitleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(rightStartingPoint, self.titleLabel.frame.size.height + 1, 
//                                                                    currentFrame.size.width - rightStartingPoint, 18)] autorelease];
//    self.subtitleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin |
//                                          UIViewAutoresizingFlexibleWidth;
//    self.subtitleLabel.font = [UIFont systemFontOfSize:13];
//    self.subtitleLabel.backgroundColor = viewBackgroundColor;
//    self.subtitleLabel.layer.borderColor = [UIColor orangeColor].CGColor;
//    self.subtitleLabel.layer.borderWidth = 1;
//
//    [self addSubview:self.subtitleLabel];
//    
//
//    // rating label - FIXME get the width right
//    self.ratingLabel = [[[UILabel alloc] initWithFrame:CGRectMake(rightStartingPoint, self.titleLabel.frame.size.height + self.subtitleLabel.frame.size.height, 
//                                                                  50, labelHeight)] autorelease];
//    self.ratingLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin |
//    UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    self.ratingLabel.font = [UIFont systemFontOfSize:13];
//    self.ratingLabel.backgroundColor = viewBackgroundColor;
//    
//    [self addSubview:self.ratingLabel];
//    
//
//    // rating view - FIXME get the width right
//    self.rateView = [[[RateView alloc] initWithFrame:CGRectMake(self.ratingLabel.frame.origin.x + self.ratingLabel.frame.size.width, 
//                                                                self.ratingLabel.frame.origin.y, 60, self.ratingLabel.frame.size.height)] autorelease];
//    self.rateView.editable = NO;
//    self.rateView.fullSelectedImage = [UIImage imageNamed:@"storiaBlueStarFull"];
//    self.rateView.notSelectedImage = [UIImage imageNamed:@"storiaBlueStarEmpty"];
//    self.rateView.halfSelectedImage = [UIImage imageNamed:@"storyBlueStarHalfFull"];
//    self.rateView.layer.borderColor = [UIColor redColor].CGColor;
//    self.rateView.layer.borderWidth = 1;
//
//    self.rateView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin |
//    UIViewAutoresizingFlexibleWidth;
//
//    [self addSubview:self.rateView];
//    
//    // wishlist checkbox button - FIXME fixed width control - get the width right
//    self.onWishListButton = [[[UIButton alloc] initWithFrame:CGRectMake(currentFrame.size.width - RIGHT_ELEMENTS_PADDING - 182, CGRectGetMidY(currentFrame) - 31,
//                                                                        182, 62)] autorelease];
//    self.onWishListButton.layer.borderColor = [UIColor greenColor].CGColor;
//    self.onWishListButton.layer.borderWidth = 1;
//    // FIXME: buttons
//    [self.onWishListButton setImage:[UIImage imageNamed:@"WishListButtonOff"] forState:UIControlStateNormal];
//    [self.onWishListButton setImage:[UIImage imageNamed:@"WishListButtonOn"] forState:UIControlStateSelected];
//    
//    self.onWishListButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
//
//    [self.onWishListButton addTarget:self action:@selector(toggledOnWishListButton:) forControlEvents:UIControlEventTouchUpInside];
//    
//    [self addSubview:self.onWishListButton];
//    
//    self.ratingLabel.text = @"All Kids Rating";
//    
//}
@end
