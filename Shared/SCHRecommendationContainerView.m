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

@end

@implementation SCHRecommendationContainerView

@synthesize container;
@synthesize box;
@synthesize heading;
@synthesize subtitle;
@synthesize recommendationViewNib;

- (void)awakeFromNib
{
    self.heading.layer.cornerRadius = 10;
    self.heading.layer.borderWidth = 1;
    self.heading.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    self.box.layer.borderWidth = 1;
    self.box.layer.borderColor = [UIColor lightGrayColor].CGColor;

    self.recommendationViewNib = [UINib nibWithNibName:@"SCHRecommendationListView-ReadingView" bundle:nil];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.heading adjustPointSizeToFitWidthWithPadding:2.0f];
    [self.subtitle adjustPointSizeToFitWidthWithPadding:0.0f];
}

- (void)dealloc
{
    [recommendationViewNib release], recommendationViewNib = nil;
    [container release], container = nil;
    [box release], box = nil;
    [heading release], heading = nil;
    [subtitle release], subtitle = nil;
    [super dealloc];
}

- (void)setRecommendations:(NSArray *)recommendationDictionaries
modifiedWishListDictionaries:(NSArray *)modifiedWishListDictionaries
          listViewDelegate:(id<SCHRecommendationListViewDelegate>)listViewDelegate
{
    for (UIView *view in self.container.subviews) {
        [view removeFromSuperview];
    }
     
    if ([recommendationDictionaries count] > 0) {
        CGFloat count = MIN([recommendationDictionaries count], 4);
        CGFloat rowHeight = floorf((self.container.frame.size.height)/4);

        for (int i = 0; i < count; i++) {
            NSDictionary *recommendationDictionary = [recommendationDictionaries objectAtIndex:i];

            SCHRecommendationListView *listView = [[[self.recommendationViewNib instantiateWithOwner:self options:nil] objectAtIndex:0] retain];
            listView.frame = CGRectMake(0, rowHeight * i, self.container.frame.size.width, rowHeight);
            listView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;

            listView.showsBottomRule = NO;
            listView.showOnBackCover = YES;
            listView.delegate = listViewDelegate;
            listView.showsWishListButton = [[SCHAppStateManager sharedAppStateManager] shouldShowWishList];

            [listView updateWithRecommendationItem:recommendationDictionary];
            [listView acceptUpdatesFromRecommendationManager];

            NSString *ISBN = [recommendationDictionary objectForKey:kSCHAppRecommendationISBN];

            NSUInteger index = [modifiedWishListDictionaries
                                indexOfObjectPassingTest:^BOOL (id obj, NSUInteger idx, BOOL *stop) {
                                    return [[(NSDictionary *)obj objectForKey:kSCHAppRecommendationISBN] isEqualToString:ISBN];
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
        UIFont *labelFont = [UIFont fontWithName:@"Arial-BoldMT" size:26.0f];
        CGRect labelFrame = CGRectMake(0, 0, CGRectGetWidth(self.container.frame), labelFont.lineHeight);
        UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];

        label.text = NSLocalizedString(@"Getting recommendations for this book.", nil);
        label.font = labelFont;
        label.adjustsFontSizeToFitWidth = YES;
        label.minimumFontSize = 4.0;
        label.textColor = [UIColor colorWithRed:0.004 green:0.192 blue:0.373 alpha:1.0];
        label.textAlignment = UITextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        [self.container addSubview:label];
        [label release], label = nil;
    }
}

@end
