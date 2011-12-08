//
//  SCHBookShelfTableViewCell.m
//  Scholastic
//
//  Created by Gordon Christie on 17/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBookShelfTableViewCell.h"
#import "TTTAttributedLabel.h"
#import "SCHBookCoverView.h"
#import "SCHAppBook.h"
#import "SCHBookManager.h"
#import "SCHBookIdentifier.h"
#import <CoreText/CoreText.h>
#import "SCHThemeManager.h"

static NSInteger const CELL_TEXT_LABEL_TAG = 100;
static NSInteger const CELL_BOOK_COVER_VIEW_TAG = 101;
static NSInteger const CELL_NEW_INDICATOR_TAG = 102;
static NSInteger const CELL_SAMPLE_SI_INDICATOR_TAG = 103;
static NSInteger const CELL_BOOK_TINT_VIEW_TAG = 104;
static NSInteger const CELL_BACKGROUND_VIEW = 200;
static NSInteger const CELL_THUMB_BACKGROUND_VIEW = 201;
static NSInteger const CELL_RULE_IMAGE_VIEW = 202;
static NSInteger const CELL_ACTIVITY_SPINNER = 203;

@interface SCHBookShelfTableViewCell ()

@property (readonly) TTTAttributedLabel *textLabel;
@property (readonly) SCHBookCoverView *bookCoverView;
@property (readonly) UIImageView *sampleAndSIIndicatorIcon;
@property (readonly) UIView *backgroundView;
@property (readonly) UIView *thumbBackgroundView;
@property (readonly) UIImageView *ruleImageView;
@property (nonatomic, assign) BOOL coalesceRefreshes;
@property (nonatomic, assign) BOOL needsRefresh;

- (void)updateTheme;
- (void)deferredRefreshCell;

@end

#pragma mark -

@implementation SCHBookShelfTableViewCell

@synthesize identifier;
@synthesize isNewBook;
@synthesize lastCell;
@synthesize loading;
@synthesize coalesceRefreshes;
@synthesize needsRefresh;
@synthesize disabledForInteractions;

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.text = [[[NSAttributedString alloc] initWithString:@""] autorelease];
        [self updateTheme];
        self.ruleImageView.image = [[UIImage imageNamed:@"ListViewRule"] stretchableImageWithLeftCapWidth:6 topCapHeight:0];
        self.lastCell = NO;
        
        self.bookCoverView.coverViewMode = SCHBookCoverViewModeListView;
        self.bookCoverView.topInset = 0;
        self.bookCoverView.leftRightInset = 0;
    }
    
    return self;
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
    
    [identifier release], identifier = nil;
    [super dealloc];
}

- (void)beginUpdates
{
    self.coalesceRefreshes = YES;
    [self.bookCoverView beginUpdates];
}

- (void)endUpdates
{
    [self.bookCoverView endUpdates];
    
    self.coalesceRefreshes = NO;
    if (self.needsRefresh) {
        [self deferredRefreshCell];
    }
}

- (void)refreshCell
{
    if (self.coalesceRefreshes) {
        self.needsRefresh = YES;
    } else {
        [self deferredRefreshCell];
    }
}

- (void)deferredRefreshCell
{
    NSAssert([NSThread isMainThread], @"must refreshCell on main thread");
    
//    [self.bookCoverView refreshBookCoverView];
    
    SCHBookManager *bookManager = [SCHBookManager sharedBookManager];
   	SCHAppBook *book = [bookManager bookWithIdentifier:self.identifier inManagedObjectContext:bookManager.mainThreadManagedObjectContext];    
    
    self.textLabel.alpha = 1.0f;
    self.sampleAndSIIndicatorIcon.hidden = NO;

    [self setNeedsDisplay];

    NSString *titleString = nil;
    float fontSize = 16.0f;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        titleString = [NSString stringWithFormat:@"%@\n%@", book.Title, book.Author];
    } else {
        titleString = [NSString stringWithFormat:@"%@ - %@", book.Title, book.Author];
        fontSize = 10.0f;
    }
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:titleString];

    UIFont *boldLabelFont = [UIFont fontWithName:@"Arial-BoldMT" size:fontSize];
    UIFont *labelFont = [UIFont fontWithName:@"Arial" size:fontSize];
    
    CTFontRef boldArialFont = CTFontCreateWithName((CFStringRef)boldLabelFont.fontName, boldLabelFont.pointSize, NULL);
    CTFontRef arialFont = CTFontCreateWithName((CFStringRef)labelFont.fontName, labelFont.pointSize, NULL);

    if (arialFont && boldArialFont) {
        [attrString addAttribute:(NSString *)kCTFontAttributeName value:(id)boldArialFont range:NSMakeRange(0, [book.Title length])];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [attrString addAttribute:(NSString *)kCTFontAttributeName value:(id)arialFont range:NSMakeRange([book.Title length], [book.Author length] + 1)];
        } else {
            [attrString addAttribute:(NSString *)kCTFontAttributeName value:(id)arialFont range:NSMakeRange([book.Title length], [book.Author length] + 3)];
        }
        
        CFRelease(arialFont);
        CFRelease(boldArialFont);
        
        [attrString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[UIColor SCHDarkBlue1Color].CGColor range:NSMakeRange(0, [titleString length])];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [attrString addAttribute:(NSString *)kCTKernAttributeName value:(id)[NSNumber numberWithFloat:-0.4] range:NSMakeRange(0, [titleString length])];
        } else {
            [attrString addAttribute:(NSString *)kCTKernAttributeName value:(id)[NSNumber numberWithFloat:-0.3] range:NSMakeRange(0, [titleString length])];
        }
    }
    
    [self.textLabel setText:attrString];
    
    self.textLabel.backgroundColor = [UIColor clearColor];
    [attrString release];
    
    SCHAppBookFeatures bookFeatures = book.bookFeatures;
    
    if (self.disabledForInteractions) {
        switch (bookFeatures) {
            case kSCHAppBookFeaturesNone:
            case kSCHAppBookFeaturesSample:
                break;
            case kSCHAppBookFeaturesStoryInteractions:
                bookFeatures = kSCHAppBookFeaturesNone;
                break;
            case kSCHAppBookFeaturesSampleWithStoryInteractions:
                bookFeatures = kSCHAppBookFeaturesSample;
                break;
        }
    }
    
    switch (bookFeatures) {
        case kSCHAppBookFeaturesNone:
        {
            self.sampleAndSIIndicatorIcon.image = nil;
            break;
        }   
        case kSCHAppBookFeaturesSample:
        {
            self.sampleAndSIIndicatorIcon.image = [UIImage imageNamed:@"SampleIcon"];
            break;
        }   
        case kSCHAppBookFeaturesStoryInteractions:
        {
            self.sampleAndSIIndicatorIcon.image = [UIImage imageNamed:@"SIIcon"];
            break;
        }   
        case kSCHAppBookFeaturesSampleWithStoryInteractions:
        {
            self.sampleAndSIIndicatorIcon.image = [UIImage imageNamed:@"SISampleIcon"];
            break;
        }   
        default:
        {
            NSLog(@"Warning: unknown type for book features.");
            self.sampleAndSIIndicatorIcon.image = nil;
            break;
        }
    }
    
    if (self.lastCell) {
        self.ruleImageView.hidden = YES;
    } else {
        self.ruleImageView.hidden = NO;
    }

//    if (self.loading) {
//        [self.activitySpinner startAnimating];
//    } else {
//        [self.activitySpinner stopAnimating];
//    }
    
    self.needsRefresh = NO;
}

- (void)layoutSubviews 
{
    [super layoutSubviews];

    // code to centre the text label vertically
    CGRect frame = self.textLabel.frame;
    
    float textHeight = [self.textLabel sizeThatFits:self.textLabel.frame.size].height;
    if (textHeight > self.textLabel.frame.size.height) {
        textHeight = self.textLabel.frame.size.height;
    }
    
    frame.origin.y = ceilf(CGRectGetMidY(self.backgroundView.frame) - (textHeight / 2));
    self.textLabel.frame = frame;
}


- (void)updateTheme
{
    self.backgroundView.backgroundColor = [[SCHThemeManager sharedThemeManager] colorForListBackground];
}

- (void)setIdentifier:(SCHBookIdentifier *)newIdentifier
{	
    [self.bookCoverView setIdentifier:newIdentifier];
    
	if (![newIdentifier isEqual:self.identifier]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SCHBookStatusUpdate" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kSCHThemeManagerThemeChangeNotification object:nil];

        [identifier release];
        identifier = [newIdentifier retain];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(updateTheme) 
                                                     name:kSCHThemeManagerThemeChangeNotification 
                                                   object:nil]; 
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(checkForCellUpdateFromNotification:)
                                                     name:@"SCHBookStateUpdate"
                                                   object:nil];
	}
}

- (void)setLoading:(BOOL)aLoading
{
    loading = aLoading;
    [self.bookCoverView setLoading:aLoading];
    [self refreshCell];
}

- (void)setIsNewBook:(BOOL)newIsNewBook
{
    isNewBook = newIsNewBook;
    [self.bookCoverView setIsNewBook:newIsNewBook];
    [self refreshCell];
}

- (void)setDisabledForInteractions:(BOOL)newDisabledForInteractions
{
    disabledForInteractions = newDisabledForInteractions;
    self.bookCoverView.disabledForInteractions = newDisabledForInteractions;
    [self refreshCell];
}

#pragma mark - Private methods

- (void)checkForCellUpdateFromNotification:(NSNotification *)notification
{
    if ([self.identifier isEqual:[[notification userInfo] objectForKey:@"bookIdentifier"]]) {
        [self refreshCell];
    }
}	

#pragma mark - Convenience Methods for Tagged Views

- (TTTAttributedLabel *)textLabel
{
    return (TTTAttributedLabel *)[self.contentView viewWithTag:CELL_TEXT_LABEL_TAG];
}

- (SCHBookCoverView *)bookCoverView
{
    return (SCHBookCoverView *)[self.contentView viewWithTag:CELL_BOOK_COVER_VIEW_TAG];
}

- (UIImageView *)sampleAndSIIndicatorIcon
{
    return (UIImageView *)[self.contentView viewWithTag:CELL_SAMPLE_SI_INDICATOR_TAG];
}

- (UIView *)backgroundView
{
    return (UIView *)[self.contentView viewWithTag:CELL_BACKGROUND_VIEW];
}

- (UIView *)thumbBackgroundView
{
    return (UIView *)[self.contentView viewWithTag:CELL_THUMB_BACKGROUND_VIEW];
}

- (UIImageView *)ruleImageView
{
    return (UIImageView *)[self.contentView viewWithTag:CELL_RULE_IMAGE_VIEW];
}


@end
