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
#import "SCHRecommendationURLRequestOperation.h"
#import "SCHRecommendationThumbnailOperation.h"

#define RIGHT_ELEMENTS_PADDING 5.0
#define TOP_BOTTOM_PADDING 18.0

@interface SCHRecommendationListView ()

- (void)initialiseView;
- (void)setupImages;
- (void)setTitle:(NSString *)title subtitle:(NSString *)subtitle pointSize:(CGFloat)pointSize;

@property (nonatomic, retain) UIImage *initialNormalStateImage;
@property (nonatomic, retain) UIImage *initialSelectedStateImage;
@property (nonatomic, retain) NSString *titleText;
@property (nonatomic, retain) NSString *subtitleText;

@end

@implementation SCHRecommendationListView

@synthesize delegate;
@synthesize ISBN;
@synthesize isOnWishList;
@synthesize showsWishListButton;
@synthesize showsBottomRule;
@synthesize recommendationBackgroundColor;

@synthesize coverImageView;
@synthesize titleAndSubtitleLabel;
@synthesize rateView;
@synthesize ratingLabel;
@synthesize ratingBackgroundImageView;
@synthesize onWishListButton;
@synthesize middleView;
@synthesize leftView;
@synthesize ruleImageView;
@synthesize initialNormalStateImage;
@synthesize initialSelectedStateImage;
@synthesize showOnBackCover;
@synthesize insets;
@synthesize ratingContainer;
@synthesize titleText;
@synthesize subtitleText;
@synthesize titleLabel;
@synthesize subtitleLabel;

- (void)dealloc
{
    delegate = nil;
    [recommendationBackgroundColor release], recommendationBackgroundColor = nil;
    [ISBN release], ISBN = nil;
    [coverImageView release], coverImageView = nil;
    [titleAndSubtitleLabel release], titleAndSubtitleLabel = nil;
    [rateView release], rateView = nil;
    [ratingLabel release], ratingLabel = nil;
    [onWishListButton release], onWishListButton = nil;
    [ratingBackgroundImageView release], ratingBackgroundImageView = nil;
    [ruleImageView release], ruleImageView = nil;
    [initialNormalStateImage release], initialNormalStateImage = nil;
    [initialSelectedStateImage release], initialSelectedStateImage = nil;
    [ratingContainer release], ratingContainer = nil;
    [titleText release], titleText = nil;
    [subtitleText release], subtitleText = nil;
    [titleLabel release], titleLabel = nil;
    [subtitleLabel release], subtitleLabel = nil;
    
    [middleView release];
    [leftView release];
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
    self.showsBottomRule = YES;
    self.showsWishListButton = YES;
    self.rateView.editable = NO;
    self.showOnBackCover = NO;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.maxPointSize = 19;
    } else {
        self.maxPointSize = 15;
    }
}

- (void)setupImages
{
    if (self.rateView && !self.rateView.fullSelectedImage) {
        self.rateView.fullSelectedImage = [UIImage imageNamed:@"storiaBlueStarFull"];
        self.rateView.notSelectedImage = [UIImage imageNamed:@"storiaBlueStarEmpty"];
        self.rateView.halfSelectedImage = [UIImage imageNamed:@"storiaBlueStarHalfFull"];
        self.ratingBackgroundImageView.image = [[UIImage imageNamed:@"BookShelfListRatingBackground"] stretchableImageWithLeftCapWidth:19 topCapHeight:0];
        self.ruleImageView.image = [[UIImage imageNamed:@"ListViewRule"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    }
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

- (void)setTitle:(NSString *)title subtitle:(NSString *)subtitle pointSize:(CGFloat)pointSize;
{
    self.titleText = title ? : @"";
    self.subtitleText = subtitle ? : @"";
    // Create the attributes
    UIFont *systemFont = [UIFont systemFontOfSize:pointSize];
    
    CTFontRef boldFont = CTFontCreateWithName(CFSTR("Helvetica-Bold"), systemFont.pointSize, NULL);
    CTFontRef regFont = CTFontCreateWithName(CFSTR("Helvetica"), systemFont.pointSize, NULL);
    
    NSDictionary *boldAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                               (id)boldFont, (NSString *)kCTFontAttributeName, nil];
    NSDictionary *regAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                              (id)regFont, (NSString *)kCTFontAttributeName, nil];
    
    NSMutableAttributedString *attText = [[[NSMutableAttributedString alloc] initWithString:self.titleText attributes:boldAttrs] autorelease];
    
    [attText appendAttributedString:[[[NSAttributedString alloc] initWithString:self.subtitleText attributes:regAttrs] autorelease]];
    
    if (boldFont) {
        CFRelease(boldFont);
    }
    
    if (regFont) {
        CFRelease(regFont);
    }
    
    self.titleAndSubtitleLabel.attributedText = attText;
}

- (void)updateWithRecommendationItem:(NSDictionary *)item
{
    [self setupImages];
    
    self.ISBN = [item objectForKey:kSCHAppRecommendationItemISBN];
    self.rateView.dimEmptyRatings = !self.showOnBackCover;
    self.rateView.rating = [[item objectForKey:kSCHAppRecommendationItemAverageRating] floatValue];
    UIImage *coverImage = [item objectForKey:kSCHAppRecommendationItemCoverImage];
    
    NSString *title = [NSString stringWithFormat:@"%@\n", [item objectForKey:kSCHAppRecommendationItemTitle]];
    NSString *subtitle = [item objectForKey:kSCHAppRecommendationItemAuthor];
    
    [self setTitle:title subtitle:subtitle pointSize:15];

    if (coverImage && ![coverImage isKindOfClass:[NSNull class]]) {
        self.coverImageView.image = coverImage;
    }
    
    if (self.showsBottomRule) {
        self.ruleImageView.hidden = NO;
    } else {
        self.ruleImageView.hidden = YES;
    }
    
    if (self.showsWishListButton) {
        self.onWishListButton.hidden = NO;
    } else {
        self.onWishListButton.hidden = YES;
    }
    
    [self setNeedsLayout];
}

- (void)updateWithWishListItem:(NSDictionary *)item
{
    [self setupImages];
    
    self.ISBN = [item objectForKey:kSCHAppRecommendationItemISBN];
    
    NSString *title = [NSString stringWithFormat:@"%@\n", [item objectForKey:kSCHAppRecommendationItemTitle]];
    NSString *subtitle = [item objectForKey:kSCHAppRecommendationItemAuthor];
    
    [self setTitle:title subtitle:subtitle pointSize:15];

    self.rateView.rating = [[item objectForKey:kSCHAppRecommendationItemAverageRating] floatValue];
    UIImage *coverImage = [item objectForKey:kSCHAppRecommendationItemCoverImage];
    
    if (coverImage && ![coverImage isKindOfClass:[NSNull class]]) {
        self.coverImageView.image = coverImage;
    }
    
    if (self.showsBottomRule) {
        self.ruleImageView.hidden = NO;
    } else {
        self.ruleImageView.hidden = YES;
    }
    
    if (self.showsWishListButton) {
        self.onWishListButton.hidden = NO;
    } else {
        self.onWishListButton.hidden = YES;
    }
    
    [self setNeedsLayout];
}

- (void)setRecommendationBackgroundColor:(UIColor *)newRecommendationBackgroundColor
{
    UIColor *oldColor = recommendationBackgroundColor;
    recommendationBackgroundColor = [newRecommendationBackgroundColor retain];
    [oldColor release];
    
    self.backgroundColor = self.recommendationBackgroundColor;
    self.titleAndSubtitleLabel.backgroundColor = self.recommendationBackgroundColor;
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
    
    CGRect bounds = UIEdgeInsetsInsetRect(self.bounds, self.insets);
    CGFloat maxLeftWidth = floorf(CGRectGetWidth(bounds) * 0.25f);
    CGFloat leftWidth = MIN(maxLeftWidth, CGRectGetHeight(bounds));
    
    self.leftView.frame = CGRectMake(CGRectGetMinX(bounds), CGRectGetMinY(bounds), leftWidth, CGRectGetHeight(bounds));
    self.middleView.frame = CGRectMake(CGRectGetMinX(bounds) + leftWidth, CGRectGetMinY(bounds), CGRectGetWidth(bounds) - leftWidth, CGRectGetHeight(bounds));
    self.ruleImageView.frame = CGRectMake(CGRectGetMinX(bounds) + 10, CGRectGetMaxY(self.bounds) - 2, CGRectGetWidth(bounds) - 20, 2);
    self.coverImageView.frame = CGRectInset(self.leftView.bounds, 4, 4);
    

    CGRect middleBounds = CGRectInset(self.middleView.bounds, 4, 4);
    CGFloat sectionPadding;
    CGFloat minimumFontSize;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        sectionPadding = 8;
        minimumFontSize = 7.0;
    } else {
        sectionPadding = 2;
        minimumFontSize = 4.0;
    }
    
    NSUInteger numSections = 3;
    
    CGFloat ratingMaxHeight;
    CGFloat ratingMaxWidth;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        ratingMaxHeight = 40;
        ratingMaxWidth = 300;
    } else {
        ratingMaxHeight = 22;
        ratingMaxWidth = 260;
    }
    
    CGFloat ratingRatio = ratingMaxWidth/ratingMaxHeight;
    
    CGFloat wishlistButtonMaxHeight = self.initialNormalStateImage.size.height;
    CGFloat wishlistButtonMaxWidth = self.initialNormalStateImage.size.width;
    CGFloat wishlistRatio = wishlistButtonMaxWidth/wishlistButtonMaxHeight;
    
    CGFloat ratingToWishlistRatio = 0.8f;
    CGFloat maxPoint = self.maxPointSize;
    CGFloat pointRatio;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        pointRatio = 3.0f;
    } else {
        pointRatio = 5.0f;
    }
    
    
    if (self.onWishListButton.hidden) {
        wishlistButtonMaxHeight = 0;
        numSections = 2;
    } else {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            maxPoint -= 1;
        } else {
            maxPoint -= 2;
        }
    }
    
    CGFloat equalHeight;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        equalHeight = floorf((CGRectGetHeight(middleBounds) - (numSections * sectionPadding))/numSections);
    } else {
        // On iPhone we want to give extra space to the text
        equalHeight = floorf((CGRectGetHeight(middleBounds) - (numSections * sectionPadding))/(numSections + 1));
    }

    CGFloat wishlistHeight = MIN(equalHeight, wishlistButtonMaxHeight);
    CGFloat wishlistInset;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        wishlistInset = 3;
    } else {
        wishlistInset = 0;
    }
    
    CGFloat wishlistWidth = MIN(MIN(CGRectGetWidth(middleBounds) - wishlistInset, wishlistButtonMaxWidth), wishlistHeight * wishlistRatio);
    
    CGFloat ratingHeight = MIN(equalHeight, ratingMaxHeight);
    
    if (wishlistHeight > 0) {
        ratingHeight = MIN(ratingHeight, wishlistHeight * ratingToWishlistRatio);
    }
    
    CGFloat ratingWidth = MIN(MIN(CGRectGetWidth(middleBounds), ratingMaxWidth), ratingHeight * ratingRatio);
    
    CGFloat textHeight = CGRectGetHeight(middleBounds) - (MAX(numSections - 1, 0) * sectionPadding) - ratingHeight - wishlistHeight;
    
    CGRect textFrame = CGRectMake(CGRectGetMinX(middleBounds), CGRectGetMinY(middleBounds), CGRectGetWidth(middleBounds), textHeight);
    textFrame = CGRectInset(textFrame, 6, 0);
    
    CGFloat pointSize;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        pointSize = floorf(MAX(14, MIN(maxPoint, CGRectGetHeight(textFrame)/pointRatio)));
    } else {
        pointSize = floorf(MAX(6, MIN(maxPoint, CGRectGetHeight(textFrame)/pointRatio)));
    }
    [self setTitle:self.titleText subtitle:self.subtitleText pointSize:pointSize];
    
    CGSize desiredSize = [self.titleAndSubtitleLabel sizeThatFits:textFrame.size];
    textFrame.size.width = MIN(textFrame.size.width, desiredSize.width);
    
    // if the text doesnt fit then use a smaller font
    // in particular if the book is landscape in shape then there will be less space
    for (; pointSize > minimumFontSize &&
         desiredSize.height > textFrame.size.height; pointSize -= 1.0) {
        [self setTitle:self.titleText subtitle:self.subtitleText pointSize:pointSize];
        desiredSize = [self.titleAndSubtitleLabel sizeThatFits:textFrame.size];
    }

    textFrame.size.height = MIN(textFrame.size.height, desiredSize.height);
    
    CGRect ratingFrame = CGRectMake(CGRectGetMinX(middleBounds), CGRectGetMaxY(textFrame) + sectionPadding, ratingWidth, ratingHeight);
    
    CGRect wishlistFrame = CGRectMake(CGRectGetMinX(middleBounds) + wishlistInset, CGRectGetMaxY(ratingFrame) + sectionPadding, wishlistWidth, wishlistHeight);
 
    // Now center all the sections of the middleview
    CGFloat offset = MAX(0, floorf((CGRectGetHeight(middleBounds) - CGRectGetMaxY(wishlistFrame))/2.0f));
    
    textFrame.origin.y += offset;
    ratingFrame.origin.y += offset;
    wishlistFrame.origin.y += offset;
    
    self.titleAndSubtitleLabel.frame = textFrame;
    self.ratingContainer.frame = ratingFrame;
    self.onWishListButton.frame = wishlistFrame;
    
    CGRect rateViewFrame = self.rateView.frame;
    rateViewFrame.size.height = MIN(self.rateView.fullSelectedImage.size.height, CGRectGetHeight(rateViewFrame));
    rateViewFrame.origin.y = floorf((CGRectGetHeight(ratingFrame) - CGRectGetHeight(rateViewFrame))/2.0f);
    self.rateView.frame = rateViewFrame;
}

@end
