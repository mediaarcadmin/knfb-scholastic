//
//  SCHRecommendationListView.m
//  Scholastic
//
//  Created by Gordon Christie on 14/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHRecommendationListView.h"
#import "RateView.h"

#define RIGHT_ELEMENTS_PADDING 5.0

@interface SCHRecommendationListView ()

@property (nonatomic, retain) UIImageView *coverImageView;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *subtitleLabel;
@property (nonatomic, retain) RateView *rateView;
@property (nonatomic, retain) UILabel *ratingLabel;
@property (nonatomic, retain) UILabel *onWishListLabel;
@property (nonatomic, retain) UIButton *onWishListButton;

- (void)initialiseView;

@end

@implementation SCHRecommendationListView

@synthesize delegate;
@synthesize ISBN;
@synthesize isOnWishList;

@synthesize coverImageView;
@synthesize titleLabel;
@synthesize subtitleLabel;
@synthesize rateView;
@synthesize ratingLabel;
@synthesize onWishListLabel;
@synthesize onWishListButton;

- (void)dealloc
{
    delegate = nil;
    [ISBN release], ISBN = nil;
    [coverImageView release], coverImageView = nil;
    [titleLabel release], titleLabel = nil;
    [subtitleLabel release], subtitleLabel = nil;
    [rateView release], rateView = nil;
    [ratingLabel release], ratingLabel = nil;
    [onWishListLabel release], onWishListLabel = nil;
    [onWishListButton release], onWishListButton = nil;
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
    
	if (self) {
		[self initialiseView];
	}
    
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
	if (self) {
		[self initialiseView];
	}
    
	return self;
}

- (void)toggledOnWishListButton:(UIButton *)wishListButton
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
    self.titleLabel.text = [item objectForKey:kSCHRecommendationWebServiceName];
    self.subtitleLabel.text = [item objectForKey:kSCHRecommendationWebServiceAuthor];
    self.rateView.rating = [[item objectForKey:kSCHLibreAccessWebServiceAverageRating] floatValue];
    NSLog(@"Object for key: %@", [item objectForKey:kSCHLibreAccessWebServiceAverageRating]);
//    self.coverImageView.image = [item bookCover];
}

- (void)updateWithWishListItem:(NSDictionary *)item
{
    self.titleLabel.text = [item objectForKey:kSCHWishListWebServiceTitle];
    self.subtitleLabel.text = [item objectForKey:kSCHWishListWebServiceAuthor];
//    self.rateView.rating = item.;
//    self.coverImageView.image = [item bookCover];
}

- (void)initialiseView 
{
    UIColor *viewBackgroundColor = [UIColor colorWithRed:0.996 green:0.937 blue:0.718 alpha:1.0];
    
    self.backgroundColor = viewBackgroundColor;
    
    CGRect currentFrame = self.bounds;
    NSLog(@"Current frame: %@", NSStringFromCGRect(self.bounds));
    
    CGFloat imageViewWidth = floorf(currentFrame.size.width * 0.3);
    CGFloat rightStartingPoint = imageViewWidth + RIGHT_ELEMENTS_PADDING;

    CGFloat labelHeight = floorf(currentFrame.size.height * 0.24);
    CGFloat subtitleLabelHeight = floorf(currentFrame.size.height * 0.3);
    
    // cover view
    
    CGRect coverViewFrame = CGRectMake(0, 0, imageViewWidth, currentFrame.size.height);
    coverViewFrame = CGRectInset(coverViewFrame, 15, 15);
    
    self.coverImageView = [[[UIImageView alloc] initWithFrame:coverViewFrame] autorelease];
    self.coverImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.coverImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self addSubview:self.coverImageView];
    
    // title label
    self.titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(rightStartingPoint, 0, 
                                                                 currentFrame.size.width - rightStartingPoint, labelHeight)] autorelease];
    
    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin |
                                       UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.titleLabel.font = [UIFont boldSystemFontOfSize:15];

    self.titleLabel.backgroundColor = viewBackgroundColor;
    
    [self addSubview:self.titleLabel];
    
    // subtitle label
    self.subtitleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(rightStartingPoint, self.titleLabel.frame.size.height, 
                                                                    currentFrame.size.width - rightStartingPoint, subtitleLabelHeight)] autorelease];
    self.subtitleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin |
                                          UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.subtitleLabel.font = [UIFont systemFontOfSize:13];
    self.subtitleLabel.backgroundColor = viewBackgroundColor;
    
    [self addSubview:self.subtitleLabel];
    

    // rating label - FIXME get the width right
    self.ratingLabel = [[[UILabel alloc] initWithFrame:CGRectMake(rightStartingPoint, self.titleLabel.frame.size.height + self.subtitleLabel.frame.size.height, 
                                                                  40, labelHeight)] autorelease];
    self.ratingLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.ratingLabel.font = [UIFont systemFontOfSize:13];
    self.ratingLabel.backgroundColor = viewBackgroundColor;
    
    [self addSubview:self.ratingLabel];
    

    // rating view - FIXME get the width right
    self.rateView = [[[RateView alloc] initWithFrame:CGRectMake(self.ratingLabel.frame.origin.x + self.ratingLabel.frame.size.width, 
                                                                self.ratingLabel.frame.origin.y, 100, self.ratingLabel.frame.size.height)] autorelease];
    self.rateView.editable = NO;
    self.rateView.fullSelectedImage = [UIImage imageNamed:@"storiaStarFull"];
    self.rateView.notSelectedImage = [UIImage imageNamed:@"storiaStarEmpty"];

    self.rateView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    [self addSubview:self.rateView];
    
    // wishlist checkbox button - FIXME fixed width control - get the width right
    self.onWishListButton = [[[UIButton alloc] initWithFrame:CGRectMake(rightStartingPoint, self.titleLabel.frame.size.height + self.subtitleLabel.frame.size.height + self.rateView.frame.size.height,
                                                                        26, labelHeight)] autorelease];
    // FIXME: buttons
    [self.onWishListButton setImage:[UIImage imageNamed:@"popoverTickLight"] forState:UIControlStateNormal];
    [self.onWishListButton setImage:[UIImage imageNamed:@"popoverTick"] forState:UIControlStateSelected];
    
    self.onWishListButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    [self.onWishListButton addTarget:self action:@selector(toggledOnWishListButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.onWishListButton];
    
    // wishlist label
    self.onWishListLabel = [[[UILabel alloc] initWithFrame:CGRectMake(self.onWishListButton.frame.origin.x + self.onWishListButton.frame.size.width, self.onWishListButton.frame.origin.y, 
                                                                    currentFrame.size.width - rightStartingPoint - self.onWishListButton.frame.size.width, self.onWishListButton.frame.size.height)] autorelease];
    self.onWishListLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.onWishListLabel.font = [UIFont systemFontOfSize:13];
    self.onWishListLabel.backgroundColor = viewBackgroundColor;
    
    [self addSubview:self.onWishListLabel];
    
    self.ratingLabel.text = @"Kids Rating:";
    self.onWishListLabel.text = @"Add to Wish List";
    
}
@end
