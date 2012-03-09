//
//  SCHBookShelfGridViewCell.m
//  Scholastic
//
//  Created by Gordon Christie on 07/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBookShelfGridViewCell.h"

#import "SCHAppBook.h"
#import "SCHBookManager.h"
#import "SCHBookCoverView.h"

#define RATING_VIEW_HEIGHT 88
#define RATING_VIEW_WIDTH_PADDING 20


@interface SCHBookShelfGridViewCell ()

@property (nonatomic, retain) UIView *ratingContainerView;
@property (nonatomic, retain) RateView *othersRateView;
@property (nonatomic, retain) RateView *personalRateView;

@end;

@implementation SCHBookShelfGridViewCell

@synthesize bookCoverView;
@synthesize identifier;
@synthesize isNewBook;
@synthesize loading;
@synthesize disabledForInteractions;
@synthesize showRatings;
@synthesize ratingContainerView;
@synthesize othersRateView;
@synthesize personalRateView;
@synthesize delegate;
@synthesize userRating;

#pragma mark - Object lifecycle

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)aReuseIdentifier 
{
	if ((self = [super initWithFrame:frame reuseIdentifier:aReuseIdentifier])) {
        self.bookCoverView = [[[SCHBookCoverView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width - 4, self.frame.size.height - 22)] autorelease];

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.bookCoverView.topInset = 0;
            self.bookCoverView.leftRightInset = 40;
        } else {
            self.bookCoverView.topInset = 0;
            self.bookCoverView.leftRightInset = 0;
        }
        
        self.bookCoverView.coverViewMode = SCHBookCoverViewModeGridView;
        
        [self.deleteButton setShowsTouchWhenHighlighted:NO]; // Needed to remove a "puff" visual glitch when pushing directly into the samples shelf
        [self.contentView addSubview:self.bookCoverView];
        
        self.ratingContainerView = [[[UIView alloc] initWithFrame:CGRectMake(RATING_VIEW_WIDTH_PADDING, frame.size.height - RATING_VIEW_HEIGHT - 22, frame.size.width - (2 * RATING_VIEW_WIDTH_PADDING), RATING_VIEW_HEIGHT)] autorelease];
        self.ratingContainerView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.4];
        self.ratingContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        
        UILabel *othersRatingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 70, floorf(self.ratingContainerView.frame.size.height/2))];
        othersRatingLabel.text = @"All Kids:";
        othersRatingLabel.font = [UIFont systemFontOfSize:13.0f];
        othersRatingLabel.textColor = [UIColor colorWithRed:0.310 green:0.302 blue:0.306 alpha:1.0];
        othersRatingLabel.backgroundColor = [UIColor colorWithRed:0.957 green:0.953 blue:0.843 alpha:1.];
        othersRatingLabel.textAlignment = UITextAlignmentRight;
        [self.ratingContainerView addSubview:othersRatingLabel];
        [othersRatingLabel release];
        
        UILabel *myRatingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, floorf(self.ratingContainerView.frame.size.height/2), 70, floorf(self.ratingContainerView.frame.size.height/2))];
        myRatingLabel.text = @"My Rating:";
        myRatingLabel.font = [UIFont systemFontOfSize:13.0f];
        myRatingLabel.textColor = [UIColor colorWithRed:0.310 green:0.302 blue:0.306 alpha:1.0];
        myRatingLabel.backgroundColor = [UIColor whiteColor];
        myRatingLabel.textAlignment = UITextAlignmentRight;
        [self.ratingContainerView addSubview:myRatingLabel];
        [myRatingLabel release];
        
        self.othersRateView = [[[RateView alloc] initWithFrame:CGRectMake(70, 0, self.ratingContainerView.frame.size.width - 70, floorf(self.ratingContainerView.frame.size.height/2))] autorelease];
        
        self.personalRateView = [[[RateView alloc] initWithFrame:CGRectMake(70, floorf(self.ratingContainerView.frame.size.height/2), self.ratingContainerView.frame.size.width - 70, floorf(self.ratingContainerView.frame.size.height/2))] autorelease];


        self.personalRateView.fullSelectedImage = [UIImage imageNamed:@"storiaStarFull"];
        self.personalRateView.notSelectedImage = [UIImage imageNamed:@"storiaStarEmpty"];
        self.personalRateView.rating = 0;
        self.personalRateView.editable = YES;
        self.personalRateView.maxRating = 5;
        self.personalRateView.backgroundColor = [UIColor whiteColor];
        self.personalRateView.delegate = self;
        
        self.othersRateView.fullSelectedImage = [UIImage imageNamed:@"storiaStarFull"];
        self.othersRateView.notSelectedImage = [UIImage imageNamed:@"storiaStarEmpty"];
        self.othersRateView.rating = 3;
        self.othersRateView.editable = NO;
        self.othersRateView.maxRating = 5;
        self.othersRateView.backgroundColor = [UIColor colorWithRed:0.957 green:0.953 blue:0.843 alpha:1.];

        
        [self.ratingContainerView addSubview:self.personalRateView];
        [self.ratingContainerView addSubview:self.othersRateView];
        
        
        [self.contentView addSubview:self.ratingContainerView];
        
        
    }
	
	return(self);
}

- (void)prepareForReuse
{
    [self.bookCoverView prepareForReuse];
    [super prepareForReuse];
}

- (void)dealloc 
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [ratingContainerView release], ratingContainerView = nil;
	[bookCoverView release], bookCoverView = nil;
    [identifier release], identifier = nil;
    [super dealloc];
}

#pragma mark - Drawing methods

- (void)beginUpdates
{
    [self.bookCoverView beginUpdates];
}

- (void)endUpdates
{
    [self.bookCoverView endUpdates];
}

- (BOOL)shouldWaitForExistingCachedThumbToLoad
{
    return [self.bookCoverView shouldWaitForExistingCachedThumbToLoad];
}

- (void)setShouldWaitForExistingCachedThumbToLoad:(BOOL)shouldWait
{
    [self.bookCoverView setShouldWaitForExistingCachedThumbToLoad:shouldWait];
}

#pragma mark - Accessor methods

- (void)setIdentifier:(SCHBookIdentifier *)newIdentifier
{	
    [identifier release];
    identifier = [newIdentifier retain];
    
    [self.bookCoverView setIdentifier:self.identifier];
    [self.bookCoverView refreshBookCoverView];
}

- (void)setIsNewBook:(BOOL)newIsNewBook
{
    isNewBook = newIsNewBook;
    self.bookCoverView.isNewBook = newIsNewBook;
}

- (void)setDisabledForInteractions:(BOOL)newDisabledForInteractions
{
    disabledForInteractions = newDisabledForInteractions;
    self.bookCoverView.disabledForInteractions = newDisabledForInteractions;
}

- (void)setLoading:(BOOL)newLoading
{
    loading = newLoading;
    self.bookCoverView.loading = newLoading;
}

- (void)setUserRating:(NSInteger)newUserRating
{
    userRating = newUserRating;
    self.personalRateView.rating = (float)self.userRating;
}

- (void)setShowRatings:(BOOL)newShowRatings
{
    showRatings = newShowRatings;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.bookCoverView.hideElementsForRatings = showRatings;
        self.personalRateView.rating = (float)self.userRating;
        
        SCHBookManager *bookManager = [SCHBookManager sharedBookManager];
        SCHAppBook *book = [bookManager bookWithIdentifier:self.identifier inManagedObjectContext:bookManager.mainThreadManagedObjectContext];    

        self.othersRateView.rating = [[book AverageRating] floatValue];

        self.ratingContainerView.hidden = !showRatings;
        [self.bookCoverView refreshBookCoverView];
    }
}

#pragma mark - RateViewDelegate

- (void)rateView:(RateView *)rateView ratingDidChange:(float)rating
{
    NSLog(@"Changing rating to %f", rating);
    if (self.delegate) {
        self.userRating = (NSInteger)rating;
        [self.delegate gridCell:self userRatingChanged:self.userRating];
    }
}


@end
