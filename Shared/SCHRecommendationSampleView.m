//
//  SCHRecommendationSampleView.m
//  Scholastic
//
//  Created by Gordon Christie on 07/05/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHRecommendationSampleView.h"
#import "UILabel+ScholasticAdditions.h"
#import "SCHAppRecommendationItem.h"
#import "SCHAppStateManager.h"

@interface SCHRecommendationSampleView ()

@property (nonatomic, retain) UIImage *initialNormalStateImage;
@property (nonatomic, retain) UIImage *initialSelectedStateImage;

- (void)updateWithRecommendationItemDictionary:(NSDictionary *)recommendationDictionary;

@end

@implementation SCHRecommendationSampleView
@synthesize largeCoverImageView;
@synthesize wishListButton;
@synthesize infoLabel;
@synthesize boxView;

@synthesize delegate;
@synthesize isOnWishList;
@synthesize ISBN;
@synthesize initialNormalStateImage;
@synthesize initialSelectedStateImage;
@synthesize wishlistButtonContainer;

- (void)awakeFromNib
{
    self.boxView.layer.cornerRadius = 10;
    self.boxView.layer.borderWidth = 1;
    self.boxView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.wishListButton setBackgroundImage:[UIImage imageNamed:@"WishListButtonOff"] forState:UIControlStateNormal];
    [self.wishListButton setBackgroundImage:[UIImage imageNamed:@"WishListButtonOn"] forState:UIControlStateSelected];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // wish list button aspect ratio
    UIImage *buttonImage = [self.wishListButton backgroundImageForState:self.wishListButton.state];
    
    if (buttonImage) {
        CGSize buttonSize = buttonImage.size;
        CGSize containerSize = self.wishlistButtonContainer.bounds.size;
        
        
        CGFloat maxWidth = MIN(buttonSize.width, containerSize.width);
        CGFloat maxHeight = MIN(buttonSize.height, containerSize.height);
        
        CGFloat ratioWidth = maxWidth / buttonSize.width;
        CGFloat ratioHeight = maxHeight / buttonSize.height;
        CGFloat ratio = MIN(ratioWidth, ratioHeight);
        
        CGRect buttonBounds = CGRectZero;
        buttonBounds.size.height = floorf(buttonSize.height * ratio);
        buttonBounds.size.width = floorf(buttonSize.width * ratio);
        self.wishListButton.bounds = buttonBounds;
    }
    
    [self.infoLabel setFont:[[self.infoLabel font] fontWithSize:26.0f]];
    [self.infoLabel adjustPointSizeToFitWidthWithPadding:0];

}

- (void)updateWithRecommendationItemDictionary:(NSDictionary *)recommendationDictionary
{
    if (recommendationDictionary) {
        NSString *fullImagePath = [recommendationDictionary objectForKey:kSCHAppRecommendationItemFullCoverImagePath];
        if (fullImagePath) {
            self.largeCoverImageView.image = [UIImage imageWithContentsOfFile:fullImagePath];
        }
        
        self.ISBN = [recommendationDictionary objectForKey:kSCHAppRecommendationItemISBN];
    }
}

- (UIImage *)initialNormalStateImage
{
    if (!initialNormalStateImage) {
        initialNormalStateImage = [[self.wishListButton backgroundImageForState:UIControlStateNormal] retain];
    }
    
    return initialNormalStateImage;
}

- (UIImage *)initialSelectedStateImage
{
    if (!initialSelectedStateImage) {
        initialSelectedStateImage = [[self.wishListButton backgroundImageForState:UIControlStateSelected] retain];
    }
    
    return initialSelectedStateImage;
}

- (void)hideWishListButton
{
    self.wishListButton.hidden = YES;
}

- (IBAction)toggledOnWishListButton:(UIButton *)theWishListButton
{
    if (self.delegate) {
        if (!theWishListButton.isSelected) {
            [self.delegate recommendationSampleView:self addedISBNToWishList:self.ISBN];
            [self setIsOnWishList:YES];
        } else {
            [self.delegate recommendationSampleView:self removedISBNFromWishList:self.ISBN];
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
        [self.wishListButton setBackgroundImage:selectedImage forState:UIControlStateNormal];
        [self.wishListButton setBackgroundImage:selectedImage forState:UIControlStateSelected];
    } else {
        [self.wishListButton setBackgroundImage:normalImage forState:UIControlStateNormal];
        [self.wishListButton setBackgroundImage:normalImage forState:UIControlStateSelected];
    }
    
    [self.wishListButton setSelected:isOnWishList];
}


- (void)dealloc {
    [initialNormalStateImage release], initialNormalStateImage = nil;
    [initialSelectedStateImage release], initialSelectedStateImage = nil;
    [ISBN release], ISBN = nil;
    [largeCoverImageView release], largeCoverImageView = nil;
    [wishListButton release], wishListButton = nil;
    [infoLabel release], infoLabel = nil;
    [boxView release], boxView = nil;
    [wishlistButtonContainer release], wishlistButtonContainer = nil;
    [super dealloc];
}

#pragma mark - SCHRecommendationViewDelegate

- (void)updateWithRecommendationDictionaries:(NSArray *)recommendationDictionaries wishListDictionaries:(NSArray *)wishlistDictionaries;
{
    if ([recommendationDictionaries count]) {
        [self updateWithRecommendationItemDictionary:[recommendationDictionaries objectAtIndex:0]];
                
        NSUInteger index = [wishlistDictionaries
                            indexOfObjectPassingTest:^BOOL (id obj, NSUInteger idx, BOOL *stop) {
                                return [[(NSDictionary *)obj objectForKey:kSCHAppRecommendationItemISBN] isEqualToString:self.ISBN];
                            }];
        
        if (index != NSNotFound) {
            [self setIsOnWishList:YES];
        } else {
            [self setIsOnWishList:NO];
        }
    }
}

@end
