//
//  SCHRecommendationContainerView.m
//  Scholastic
//
//  Created by Matt Farrugia on 06/04/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHRecommendationContainerView.h"
#import "UILabel+ScholasticAdditions.h"
#import "SCHAppStateManager.h"
#import "SCHAppRecommendationItem.h"

@interface SCHRecommendationContainerView ()

@property (nonatomic, retain) UINib *recommendationViewNib;

- (void)setRecommendations:(NSArray *)recommendationDictionaries
    modifiedWishListDictionaries:(NSArray *)modifiedWishListDictionaries;

@end

@implementation SCHRecommendationContainerView

@synthesize container;
@synthesize box;
@synthesize heading;
@synthesize subtitle;
@synthesize recommendationViewNib;
@synthesize listViewDelegate;
@synthesize fetchingLabel;
@synthesize maxRecommendations;

- (void)awakeFromNib
{
    self.heading.layer.cornerRadius = 10;
    self.heading.layer.borderWidth = 1;
    self.heading.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    self.box.layer.borderWidth = 1;
    self.box.layer.borderColor = [UIColor lightGrayColor].CGColor;

    self.recommendationViewNib = [UINib nibWithNibName:@"SCHRecommendationListView" bundle:nil];
    self.maxRecommendations = 4;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.heading adjustPointSizeToFitWidthWithPadding:2.0f];
    [self.subtitle adjustPointSizeToFitWidthWithPadding:0.0f];
    [self.fetchingLabel adjustPointSizeToFitWidthWithPadding:0.0f];
}

- (void)dealloc
{
    [recommendationViewNib release], recommendationViewNib = nil;
    [container release], container = nil;
    [box release], box = nil;
    [heading release], heading = nil;
    [subtitle release], subtitle = nil;
    listViewDelegate = nil;
    [fetchingLabel release], fetchingLabel = nil;
    [super dealloc];
}

- (void)setRecommendations:(NSArray *)recommendationDictionaries
modifiedWishListDictionaries:(NSArray *)modifiedWishListDictionaries
{
    for (UIView *view in self.container.subviews) {
        [view removeFromSuperview];
    }
     
    if ([recommendationDictionaries count] > 0) {
        self.fetchingLabel.hidden = YES;
        
        CGFloat count = MIN([recommendationDictionaries count], MIN(self.maxRecommendations, 4));
        CGFloat rowHeight = floorf((self.container.frame.size.height)/MAX(count, 3));

        for (int i = 0; i < count; i++) {
            NSDictionary *recommendationDictionary = [recommendationDictionaries objectAtIndex:i];

            SCHRecommendationListView *listView = [[[self.recommendationViewNib instantiateWithOwner:self options:nil] objectAtIndex:0] retain];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                listView.insets = UIEdgeInsetsMake(4, 0, 4, 0);
            }
            listView.frame = CGRectMake(0, rowHeight * i, self.container.frame.size.width, rowHeight);
            listView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
            listView.backgroundColor = [UIColor clearColor];

            listView.showsBottomRule = NO;
            listView.showOnBackCover = YES;
            listView.delegate = self.listViewDelegate;
            listView.showsWishListButton = [[SCHAppStateManager sharedAppStateManager] shouldShowWishList];

            [listView updateWithRecommendationItem:recommendationDictionary];

            NSString *ISBN = [recommendationDictionary objectForKey:kSCHAppRecommendationItemISBN];

            NSUInteger index = [modifiedWishListDictionaries
                                indexOfObjectPassingTest:^BOOL (id obj, NSUInteger idx, BOOL *stop) {
                                    return [[(NSDictionary *)obj objectForKey:kSCHAppRecommendationItemISBN] isEqualToString:ISBN];
                                }];

            if (index != NSNotFound) {
                [listView setIsOnWishList:YES];
            } else {
                [listView setIsOnWishList:NO];
            }

            [self.container addSubview:listView];
            [listView release];
        }
    } else {
        self.fetchingLabel.hidden = NO;
    }
    
    [self setNeedsLayout];
}

// Only allow taps on the buttons
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *ret = [super hitTest:point withEvent:event];
    
    if (![ret isKindOfClass:[UIControl class]]) {
        ret = nil;
    }
    
    return ret;
}

#pragma mark - SCHRecommendationViewDelegate

- (void)updateWithRecommendationDictionaries:(NSArray *)recommendationDictionaries wishListDictionaries:(NSArray *)wishlistDictionaries;
{
    [self setRecommendations:recommendationDictionaries modifiedWishListDictionaries:wishlistDictionaries];
}


@end
