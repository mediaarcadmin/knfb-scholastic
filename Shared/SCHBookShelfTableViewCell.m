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
#import "SCHBookIdentifier.h"
#import <CoreText/CoreText.h>
#import "SCHThemeManager.h"

static NSInteger const CELL_TEXT_LABEL_TAG = 100;
static NSInteger const CELL_BOOK_COVER_VIEW_TAG = 101;
static NSInteger const CELL_NEW_INDICATOR_TAG = 102;
static NSInteger const CELL_SAMPLE_SI_INDICATOR_TAG = 103;
static NSInteger const CELL_BOOK_TINT_VIEW_TAG = 104;
static NSInteger const CELL_DELETE_BUTTON = 105;
static NSInteger const CELL_BACKGROUND_VIEW = 200;

@interface SCHBookShelfTableViewCell ()

@property (readonly) TTTAttributedLabel *textLabel;
@property (readonly) SCHAsyncBookCoverImageView *bookCoverImageView;
@property (readonly) UIImageView *newIndicatorIcon;
@property (readonly) UIImageView *sampleAndSIIndicatorIcon;
@property (readonly) UIView *bookTintView;
@property (readonly) UIView *backgroundView;
@property (readonly) UIButton *deleteButton;

- (void)updateTheme;

@end

#pragma mark -

@implementation SCHBookShelfTableViewCell

@synthesize identifier;
@synthesize delegate;

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.bookCoverImageView.thumbSize = CGSizeMake(self.bookCoverImageView.frame.size.width, self.bookCoverImageView.frame.size.height);
        [self updateTheme];
        [self.deleteButton addTarget:self action:@selector(pressedDeleteButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return self;
}

- (void)dealloc 
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [identifier release], identifier = nil;
    [super dealloc];
}

- (void)refreshCell
{
    NSAssert([NSThread isMainThread], @"must refreshCell on main thread");
    
    SCHBookManager *bookManager = [SCHBookManager sharedBookManager];
   	SCHAppBook *book = [bookManager bookWithIdentifier:self.identifier inManagedObjectContext:bookManager.mainThreadManagedObjectContext];    
	// image processing
    [[SCHProcessingManager sharedProcessingManager] requestThumbImageForBookCover:self.bookCoverImageView
                                                                             size:self.bookCoverImageView.thumbSize
                                                                             book:book];
	[self setNeedsDisplay];
    
	// book status
	switch ([book processingState]) {
		case SCHBookProcessingStateReadyToRead:
			self.bookTintView.hidden = YES;
			break;
//		case SCHBookProcessingStateDownloadStarted:
//		case SCHBookProcessingStateDownloadPaused:
//			self.bookTintView.hidden = NO;
//			break;
        default:
			self.bookTintView.hidden = NO;
			break;
	}
    
    NSString *titleString = nil;
    float fontSize = 16.0f;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        titleString = [NSString stringWithFormat:@"%@\n%@", book.Title, book.Author];
    } else {
        titleString = [NSString stringWithFormat:@"%@ - %@", book.Title, book.Author];
        fontSize = 11.0f;
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
    }
    
    [self.textLabel setText:attrString];
    self.textLabel.backgroundColor = [UIColor clearColor];
    [attrString release];
 
}

- (void)updateTheme
{
    self.backgroundView.backgroundColor = [[SCHThemeManager sharedThemeManager] colorForListBackground];
}

- (void)setIdentifier:(SCHBookIdentifier *)newIdentifier
{	
	if (![newIdentifier isEqual:self.identifier]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SCHBookStatusUpdate" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SCHNewImageAvailable" object:nil];

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
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(checkForCellUpdateFromNotification:)
                                                     name:@"SCHNewImageAvailable"
                                                   object:nil];
        
        [self.bookCoverImageView setIdentifier:self.identifier];
        [self refreshCell];        
	}
}

#pragma mark - Delete Button

- (void)pressedDeleteButton:(UIButton *) sender
{
    NSLog(@"Pressed delete button!");
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(bookShelfTableViewCellSelectedDeleteForIdentifier:)]) {
        [self.delegate bookShelfTableViewCellSelectedDeleteForIdentifier:self.identifier];
    }
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

- (UIButton *)deleteButton
{
    return (UIButton *)[self.contentView viewWithTag:CELL_DELETE_BUTTON];
}


@end
