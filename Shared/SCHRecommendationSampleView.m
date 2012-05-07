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

@interface SCHRecommendationSampleView ()

@property (nonatomic, retain) UIImage *initialNormalStateImage;
@property (nonatomic, retain) UIImage *initialSelectedStateImage;

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

- (void)awakeFromNib
{
    self.boxView.layer.cornerRadius = 10;
    self.boxView.layer.borderWidth = 1;
    self.boxView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    [self.wishListButton setImage:[UIImage imageNamed:@"WishListButtonOff"] forState:UIControlStateNormal];
    [self.wishListButton setImage:[UIImage imageNamed:@"WishListButtonOn"] forState:UIControlStateSelected];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.infoLabel adjustPointSizeToFitWidthWithPadding:2.0f];
    
    // wish list button aspect ratio
    UIImage *buttonImage = [self.wishListButton imageForState:self.wishListButton.state];
    
    if (buttonImage) {
        CGSize buttonSize = buttonImage.size;
        CGFloat aspect = buttonSize.width / buttonSize.height;
        
        CGRect buttonFrame = self.wishListButton.frame;
        buttonFrame.size.height = floorf(buttonFrame.size.width / aspect);
        self.wishListButton.frame = buttonFrame;
    }

}

- (void)updateWithRecommendationItemDictionary:(NSDictionary *)recommendationDictionary
{
    if (!recommendationDictionary) {
        self.wishListButton.hidden = YES;
    } else {
        NSString *fullImagePath = [recommendationDictionary objectForKey:kSCHAppRecommendationFullCoverImagePath];
        if (fullImagePath) {
            self.largeCoverImageView.image = [UIImage imageWithContentsOfFile:fullImagePath];
        }
        
        self.ISBN = [recommendationDictionary objectForKey:kSCHAppRecommendationISBN];
        
    }
}

- (UIImage *)initialNormalStateImage
{
    if (!initialNormalStateImage) {
        initialNormalStateImage = [[self.wishListButton imageForState:UIControlStateNormal] retain];
    }
    
    return initialNormalStateImage;
}

- (UIImage *)initialSelectedStateImage
{
    if (!initialSelectedStateImage) {
        initialSelectedStateImage = [[self.wishListButton imageForState:UIControlStateSelected] retain];
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
        [self.wishListButton setImage:selectedImage forState:UIControlStateNormal];
        [self.wishListButton setImage:selectedImage forState:UIControlStateSelected];
    } else {
        [self.wishListButton setImage:normalImage forState:UIControlStateNormal];
        [self.wishListButton setImage:normalImage forState:UIControlStateSelected];
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
    [super dealloc];
}
@end
