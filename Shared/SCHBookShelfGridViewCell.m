//
//  SCHBookShelfGridViewCell.m
//  Scholastic
//
//  Created by Gordon Christie on 07/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBookShelfGridViewCell.h"

#import "SCHThumbnailFactory.h"
#import "SCHAppBook.h"
#import "SCHBookManager.h"
#import "SCHAsyncBookCoverImageView.h"

@implementation SCHBookShelfGridViewCell

@synthesize asyncImageView;
@synthesize thumbTintView;
@synthesize progressView;
@synthesize isbn;

#pragma mark - Object lifecycle

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)identifier 
{
	if ((self = [super initWithFrame:frame reuseIdentifier:identifier])) {
        
		self.asyncImageView = [SCHThumbnailFactory newAsyncImageWithSize:CGSizeMake(self.frame.size.width - 4, self.frame.size.height - 20)];
		[self.asyncImageView setFrame:CGRectZero];
		[self.contentView addSubview:self.asyncImageView];
		
		self.thumbTintView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
		[self.thumbTintView setBackgroundColor:[UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:0.6f]];
        [self.thumbTintView setContentMode:UIViewContentModeBottom];
		[self.contentView addSubview:self.thumbTintView];
		
		self.progressView = [[[UIProgressView alloc] initWithFrame:CGRectMake(10, self.frame.size.height - 42, self.frame.size.width - 20, 10)] autorelease];
		[self.contentView addSubview:self.progressView];
		self.progressView.hidden = NO;		
    }
	
	return(self);
}

- (void)dealloc 
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[asyncImageView release], asyncImageView = nil;
	[thumbTintView release], thumbTintView = nil;
	[progressView release], progressView = nil;
    [isbn release], isbn = nil;
    [super dealloc];
}

#pragma mark - Drawing methods

- (void)layoutSubviews 
{
    [super layoutSubviews];
    [UIView setAnimationsEnabled:NO];

	self.asyncImageView.frame = CGRectMake(2, 0, self.frame.size.width - 4, self.frame.size.height - 22);
	if (self.progressView.hidden == NO) {
        self.progressView.frame = CGRectMake(10, self.frame.size.height - 42, self.frame.size.width - 20, 10);
    }
    
    if (asyncImageView && !CGSizeEqualToSize(self.asyncImageView.coverSize, CGSizeZero)) {
    
        CGRect thumbTintFrame = self.thumbTintView.frame;
        
        thumbTintFrame.size.width = self.asyncImageView.coverSize.width;
        thumbTintFrame.size.height = self.asyncImageView.coverSize.height;
        
        thumbTintFrame.origin.x = (self.contentView.frame.size.width - thumbTintFrame.size.width) / 2;
        thumbTintFrame.origin.y = self.asyncImageView.frame.size.height - thumbTintFrame.size.height;
        
        self.thumbTintView.frame = thumbTintFrame;
    }
    
    [UIView setAnimationsEnabled:YES];
}

- (void)refreshCell
{
	SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.isbn];    
	// image processing
    BOOL immediateUpdate = [[SCHProcessingManager sharedProcessingManager] requestThumbImageForBookCover:self.asyncImageView
																									size:self.asyncImageView.thumbSize
                                                                                                    book:book];

	if (immediateUpdate) {
		[self setNeedsDisplay];
	}
    
	// book status
	switch ([book processingState]) {
		case SCHBookProcessingStateDownloadStarted:
		case SCHBookProcessingStateDownloadPaused:
			self.thumbTintView.hidden = NO;
			self.progressView.hidden = NO;
            [self.progressView setProgress:[book currentDownloadedPercentage]];            
			break;
		case SCHBookProcessingStateReadyToRead:
			self.thumbTintView.hidden = YES;
			self.progressView.hidden = YES;
			break;
        default:
			self.thumbTintView.hidden = NO;
			self.progressView.hidden = YES;
			break;
	}
	
	[self layoutSubviews];
}	

#pragma mark - Accessor methods

- (void)setIsbn:(NSString *)newIsbn
{	
	if (newIsbn != isbn) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SCHBookDownloadPercentageUpdate" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SCHBookStatusUpdate" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SCHNewImageAvailable" object:nil];

		[isbn release];
		isbn = [newIsbn copy];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updatePercentage:) 
                                                     name:@"SCHBookDownloadPercentageUpdate" 
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(checkForCellUpdateFromNotification:)
                                                     name:@"SCHBookStateUpdate"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(checkForCellUpdateFromNotification:)
                                                     name:@"SCHNewImageAvailable"
                                                   object:nil];
        
        [self.asyncImageView setIsbn:self.isbn];
        [self refreshCell];        
	}
}

#pragma mark - Private methods

- (void)checkForCellUpdateFromNotification:(NSNotification *)notification
{
    if ([self.isbn compare:[[notification userInfo] objectForKey:@"isbn"]] == NSOrderedSame) {
        [self refreshCell];
    }
}	

- (void)updatePercentage:(NSNotification *)notification
{
    NSString *updateForISBN = [[notification userInfo] objectForKey:@"isbn"];
    
    if ([updateForISBN compare:self.isbn] == NSOrderedSame) {
        float newPercentage = [(NSNumber *) [[notification userInfo] objectForKey:@"currentPercentage"] floatValue];
        [self.progressView setProgress:newPercentage];
    }
}

@end
