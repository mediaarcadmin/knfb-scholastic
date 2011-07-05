//
//  SCHBookShelfTableViewCell.m
//  Scholastic
//
//  Created by Gordon Christie on 17/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBookShelfTableViewCell.h"
#import "TTTAttributedLabel.h"
#import "SCHAsyncBookCoverImageView.h"
#import "SCHAppBook.h"
#import "SCHBookManager.h"
#import <CoreText/CoreText.h>
#import "SCHThemeManager.h"

static NSInteger const CELL_TEXT_LABEL_TAG = 100;
static NSInteger const CELL_BOOK_COVER_VIEW_TAG = 101;
static NSInteger const CELL_NEW_INDICATOR_TAG = 102;
static NSInteger const CELL_SAMPLE_SI_INDICATOR_TAG = 103;
static NSInteger const CELL_BOOK_TINT_VIEW_TAG = 104;
static NSInteger const CELL_DELETE_BUTTON = 105;
static NSInteger const CELL_BACKGROUND_VIEW = 200;
static NSInteger const CELL_THUMB_BACKGROUND_VIEW = 201;
static NSInteger const CELL_RULE_IMAGE_VIEW = 202;

@interface SCHBookShelfTableViewCell ()

@property (readonly) TTTAttributedLabel *textLabel;
@property (readonly) SCHAsyncBookCoverImageView *bookCoverImageView;
@property (readonly) UIImageView *newIndicatorIcon;
@property (readonly) UIImageView *sampleAndSIIndicatorIcon;
@property (readonly) UIView *bookTintView;
@property (readonly) UIView *backgroundView;
@property (readonly) UIButton *deleteButton;
@property (readonly) UIView *thumbBackgroundView;
@property (readonly) UIImageView *ruleImageView;

- (void)updateTheme;

@end

#pragma mark -

@implementation SCHBookShelfTableViewCell

@synthesize isbn;
@synthesize delegate;
@synthesize isNewBook;
@synthesize trashed;
@synthesize lastCell;

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.bookCoverImageView.thumbSize = CGSizeMake(self.bookCoverImageView.frame.size.width, self.bookCoverImageView.frame.size.height);
        [self updateTheme];
        [self.deleteButton addTarget:self action:@selector(pressedDeleteButton:) forControlEvents:UIControlEventTouchUpInside];
        self.ruleImageView.image = [[UIImage imageNamed:@"ListViewRule"] stretchableImageWithLeftCapWidth:6 topCapHeight:0];
        self.lastCell = NO;
                                    
    }
    
    return self;
}

- (void)dealloc 
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [isbn release], isbn = nil;
    [super dealloc];
}

- (void)refreshCell
{
   	SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.isbn];    
	// image processing
    [[SCHProcessingManager sharedProcessingManager] requestThumbImageForBookCover:self.bookCoverImageView
                                                                             size:self.bookCoverImageView.thumbSize
                                                                             book:book];
   
    if (self.trashed) {
        self.bookTintView.hidden = NO;
    } else {
        // book status
        switch ([book processingState]) {
            case SCHBookProcessingStateReadyToRead:
                self.bookTintView.hidden = YES;
                break;
            default:
            {
                self.bookTintView.hidden = NO;
                break;
            }
        }
    }

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
    
    if (self.isNewBook) {
        self.newIndicatorIcon.hidden = NO;
    } else {
        self.newIndicatorIcon.hidden = YES;
    }
    
    switch (book.bookFeatures) {
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
}

- (void)layoutSubviews 
{
    [super layoutSubviews];
    [UIView setAnimationsEnabled:NO];
    
    if (self.bookCoverImageView && !CGSizeEqualToSize(self.bookCoverImageView.coverSize, CGSizeZero)) {
        
        CGRect thumbTintFrame = self.bookTintView.frame;
        
        NSLog(@"coversize: %@, trashed: %@", NSStringFromCGSize(self.bookCoverImageView.coverSize), self.trashed?@"Yes":@"No");
        
        thumbTintFrame.size.width = self.bookCoverImageView.coverSize.width;
        thumbTintFrame.size.height = self.bookCoverImageView.coverSize.height;
        
        thumbTintFrame.origin.x = ceilf((self.thumbBackgroundView.frame.size.width - thumbTintFrame.size.width) / 2);
        thumbTintFrame.origin.y = ceilf(self.bookCoverImageView.frame.size.height - thumbTintFrame.size.height);
        
        self.bookTintView.frame = thumbTintFrame;
        NSLog(@"Thumb tint frame: %@, visible: %@", NSStringFromCGRect(self.bookTintView.frame), self.bookTintView.hidden?@"No":@"Yes");
    }
    

    // code to centre the text label vertically
    CGRect frame = self.textLabel.frame;
    
    float textHeight = [self.textLabel sizeThatFits:self.textLabel.frame.size].height;
    if (textHeight > self.textLabel.frame.size.height) {
        textHeight = self.textLabel.frame.size.height;
    }
    
    frame.origin.y = ceilf(CGRectGetMidY(self.backgroundView.frame) - (textHeight / 2));
    self.textLabel.frame = frame;
    
    [UIView setAnimationsEnabled:YES];
}


- (void)updateTheme
{
    self.backgroundView.backgroundColor = [[SCHThemeManager sharedThemeManager] colorForListBackground];
}

- (void)setIsbn:(NSString *)newIsbn
{	
	if (newIsbn != isbn) {
//        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SCHBookDownloadPercentageUpdate" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SCHBookStatusUpdate" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SCHNewImageAvailable" object:nil];
        
		[isbn release];
		isbn = [newIsbn copy];
        
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(updatePercentage:) 
//                                                     name:@"SCHBookDownloadPercentageUpdate" 
//                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(updateTheme) 
                                                     name:kSCHThemeManagerThemeChangeNotification 
                                                   object:nil]; 
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(checkForCellUpdateFromNotification:)
                                                     name:@"SCHBookStateUpdate"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(checkForCellUpdateFromNotification:)
                                                     name:@"SCHNewImageAvailable"
                                                   object:nil];
        
        [self.bookCoverImageView setIsbn:self.isbn];
        [self refreshCell];        
	}
}

- (void)setTrashed:(BOOL)newTrashed
{
    trashed = newTrashed;
    [self refreshCell];
}

#pragma mark - Delete Button

- (void)pressedDeleteButton:(UIButton *) sender
{
    NSLog(@"Pressed delete button!");
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(bookShelfTableViewCellSelectedDeleteForISBN:)]) {
        [self.delegate bookShelfTableViewCellSelectedDeleteForISBN:self.isbn];
    }
}

#pragma mark - Private methods

- (void)checkForCellUpdateFromNotification:(NSNotification *)notification
{
    if ([self.isbn compare:[[notification userInfo] objectForKey:@"isbn"]] == NSOrderedSame) {
        [self refreshCell];
    }
}	

#pragma mark - Convenience Methods for Tagged Views

- (TTTAttributedLabel *)textLabel
{
    return (TTTAttributedLabel *)[self.contentView viewWithTag:CELL_TEXT_LABEL_TAG];
}

- (SCHAsyncBookCoverImageView *)bookCoverImageView
{
    return (SCHAsyncBookCoverImageView *)[self.contentView viewWithTag:CELL_BOOK_COVER_VIEW_TAG];
}

- (UIImageView *)newIndicatorIcon
{
    return (UIImageView *)[self.contentView viewWithTag:CELL_NEW_INDICATOR_TAG];
}

- (UIImageView *)sampleAndSIIndicatorIcon
{
    return (UIImageView *)[self.contentView viewWithTag:CELL_SAMPLE_SI_INDICATOR_TAG];
}

- (UIView *)bookTintView
{
    return (UIImageView *)[self.contentView viewWithTag:CELL_BOOK_TINT_VIEW_TAG];
}

- (UIView *)backgroundView
{
    return (UIView *)[self.contentView viewWithTag:CELL_BACKGROUND_VIEW];
}

- (UIView *)thumbBackgroundView
{
    return (UIView *)[self.contentView viewWithTag:CELL_THUMB_BACKGROUND_VIEW];
}

- (UIButton *)deleteButton
{
    return (UIButton *)[self.contentView viewWithTag:CELL_DELETE_BUTTON];
}

- (UIImageView *)ruleImageView
{
    return (UIImageView *)[self.contentView viewWithTag:CELL_RULE_IMAGE_VIEW];
}


@end
