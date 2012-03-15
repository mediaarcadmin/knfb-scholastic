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

- (void)initialiseView 
{
    CGRect currentFrame = self.bounds;
    NSLog(@"Current frame: %@", NSStringFromCGRect(self.bounds));
    
    CGFloat imageViewWidth = floorf(currentFrame.size.width * 0.3);
    CGFloat rightStartingPoint = imageViewWidth + RIGHT_ELEMENTS_PADDING;

    CGFloat labelHeight = floorf(currentFrame.size.height * 0.2);
    CGFloat subtitleLabelHeight = floorf(currentFrame.size.height * 0.4);
    
    // cover view
    self.coverImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 
                                                                         imageViewWidth, currentFrame.size.height)] autorelease];
    self.coverImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self addSubview:self.coverImageView];
    
    // title label
    self.titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(rightStartingPoint, 0, 
                                                                 currentFrame.size.width - rightStartingPoint, labelHeight)] autorelease];
    
    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin |
                                       UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    self.titleLabel.layer.borderColor = [UIColor orangeColor].CGColor;
    self.titleLabel.layer.borderWidth = 1;
    
    [self addSubview:self.titleLabel];
    
    // subtitle label
    self.subtitleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(rightStartingPoint, self.titleLabel.frame.size.height, 
                                                                    currentFrame.size.width - rightStartingPoint, subtitleLabelHeight)] autorelease];
    self.subtitleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin |
                                          UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.subtitleLabel.font = [UIFont systemFontOfSize:13];
    
    self.subtitleLabel.layer.borderColor = [UIColor greenColor].CGColor;
    self.subtitleLabel.layer.borderWidth = 1;
    
    [self addSubview:self.subtitleLabel];
    

    // rating label - FIXME get the width right
    self.ratingLabel = [[[UILabel alloc] initWithFrame:CGRectMake(rightStartingPoint, self.titleLabel.frame.size.height + self.subtitleLabel.frame.size.height, 
                                                                  74, labelHeight)] autorelease];
    self.ratingLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.ratingLabel.font = [UIFont systemFontOfSize:13];
    self.ratingLabel.layer.borderColor = [UIColor blueColor].CGColor;
    self.ratingLabel.layer.borderWidth = 1;

    
    [self addSubview:self.ratingLabel];
    

    // rating view - FIXME get the width right
    self.rateView = [[[RateView alloc] initWithFrame:CGRectMake(self.ratingLabel.frame.origin.x + self.ratingLabel.frame.size.width, 
                                                                self.ratingLabel.frame.origin.y, 142, self.ratingLabel.frame.size.height)] autorelease];
    self.rateView.editable = NO;
    self.rateView.fullSelectedImage = [UIImage imageNamed:@"storiaStarFull"];
    self.rateView.notSelectedImage = [UIImage imageNamed:@"storiaStarEmpty"];

    self.rateView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.rateView.layer.borderColor = [UIColor yellowColor].CGColor;
    self.rateView.layer.borderWidth = 1;

    [self addSubview:self.rateView];
    

    
    // wishlist checkbox button - FIXME fixed width control - get the width right
    self.onWishListButton = [[[UIButton alloc] initWithFrame:CGRectMake(rightStartingPoint, self.titleLabel.frame.size.height + self.subtitleLabel.frame.size.height + self.rateView.frame.size.height,
                                                                        36, labelHeight)] autorelease];
    // FIXME: buttons
    [self.onWishListButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [self.onWishListButton setImage:[UIImage imageNamed:@""] forState:UIControlStateSelected];
    
    self.onWishListButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    self.onWishListButton.layer.borderColor = [UIColor orangeColor].CGColor;
    self.onWishListButton.layer.borderWidth = 1;
    
    [self addSubview:self.onWishListButton];
    
    // wishlist label
    self.onWishListLabel = [[[UILabel alloc] initWithFrame:CGRectMake(self.onWishListButton.frame.origin.x + self.onWishListButton.frame.size.width, self.onWishListButton.frame.origin.y, 
                                                                    currentFrame.size.width - rightStartingPoint - self.onWishListButton.frame.size.width, self.onWishListButton.frame.size.height)] autorelease];
    self.onWishListLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.onWishListLabel.font = [UIFont systemFontOfSize:13];

    self.onWishListLabel.layer.borderColor = [UIColor greenColor].CGColor;
    self.onWishListLabel.layer.borderWidth = 1;
    
    [self addSubview:self.onWishListLabel];
    
    // FIXME: debug text etc.
    
    self.titleLabel.text = @"Sample Book Title";
    self.subtitleLabel.text = @"Sample Book Subtitle";
    self.ratingLabel.text = @"Kids Rating:";
    self.rateView.rating = 3.0f;
    self.onWishListLabel.text = @"Add to Wish List";
    self.coverImageView.backgroundColor = [UIColor purpleColor];
    
    
}
@end
