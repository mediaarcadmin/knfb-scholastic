//
//  SCHBookShelfGridViewCell.m
//  Scholastic
//
//  Created by Gordon Christie on 07/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBookShelfGridViewCell.h"
#import "SCHThumbnailFactory.h"
#import "SCHProcessingManager.h"
#import "SCHAppBook.h"
#import "SCHBookManager.h"

@implementation SCHBookShelfGridViewCell

@synthesize asyncImageView, thumbTintView, progressView, isbn;

- (id)initWithFrame:(CGRect)frame reuseIdentifier: (NSString*) identifier {

	if ((self = [super initWithFrame:frame reuseIdentifier:identifier])) {
        
		self.asyncImageView = [SCHThumbnailFactory newAsyncImageWithSize:CGSizeMake(self.frame.size.width - 4, self.frame.size.height - 20)];
		[self.asyncImageView setFrame:CGRectZero];
		[self.contentView addSubview:self.asyncImageView];
		
		self.thumbTintView = [[UIView alloc] initWithFrame:CGRectZero];
		[self.thumbTintView setBackgroundColor:[UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:0.6f]];
		[self.contentView addSubview:self.thumbTintView];
		
/*		self.statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.statusLabel setFont:[UIFont systemFontOfSize:12.0f]];
        [self.statusLabel setTextColor:[UIColor whiteColor]];
		[self.statusLabel setBackgroundColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.75]];
        [self.statusLabel setHighlightedTextColor:[UIColor whiteColor]];
		[self.statusLabel setNumberOfLines:1];
		[self.statusLabel setTextAlignment:UITextAlignmentCenter];
		
        [self.contentView addSubview:self.statusLabel];
*/		
		self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(10, self.frame.size.height - 42, self.frame.size.width - 20, 10)];
		[self.contentView addSubview:self.progressView];
		self.progressView.hidden = NO;
		
	}
	
	return self;
}

#pragma mark -
#pragma mark Laying out subviews

- (void)layoutSubviews {
    [super layoutSubviews];
    [UIView setAnimationsEnabled:NO];

//	self.statusLabel.frame = CGRectMake(-10, self.frame.size.height - 20, self.frame.size.width + 20, 14);
	self.asyncImageView.frame = CGRectMake(2, 0, self.frame.size.width - 4, self.frame.size.height - 22);
	self.thumbTintView.frame = CGRectMake(2, 0, self.frame.size.width - 4, self.frame.size.height - 22);
	self.progressView.frame = CGRectMake(10, self.frame.size.height - 42, self.frame.size.width - 20, 10);
    
    [UIView setAnimationsEnabled:YES];
}

#pragma mark -
#pragma mark Setter for SCHBookInfo


- (void) setIsbn: (NSString *) newIsbn
{

	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"SCHBookDownloadPercentageUpdate" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"SCHBookStatusUpdate" object:nil];
	
	if (newIsbn != isbn) {
		NSString *oldIsbn = isbn;
		isbn = [newIsbn retain];
		[oldIsbn release];
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(updatePercentage:) 
												 name:@"SCHBookDownloadPercentageUpdate" 
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(checkForCellUpdateFromNotification:)
												 name:@"SCHBookStateUpdate"
											   object:nil];
	[self.asyncImageView setIsbn:self.isbn];
	[self refreshCell];
	
}

- (void) checkForCellUpdateFromNotification: (NSNotification *) notification
{
    if ([self.isbn compare:[[notification userInfo] objectForKey:@"isbn"]] == NSOrderedSame) {
        [self refreshCell];
    }
}

- (void) refreshCell
{
	// image processing
	BOOL immediateUpdate = [[SCHProcessingManager sharedProcessingManager] requestThumbImageForBookCover:self.asyncImageView
																									size:self.asyncImageView.coverSize];
	
	if (immediateUpdate) {
		[self setNeedsDisplay];
	}
	
	SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.isbn];
	
	//NSString *status = [book processingStateAsString];
	
    /*
     
     SCHBookProcessingStateError = -2,
     SCHBookProcessingStateBookVersionNotSupported,
     SCHBookProcessingStateNoURLs,
     SCHBookProcessingStateNoCoverImage,
     SCHBookProcessingStateReadyForBookFileDownload,
     SCHBookProcessingStateDownloadStarted,
     SCHBookProcessingStateDownloadPaused,
     SCHBookProcessingStateReadyForLicenseAcquisition,
     SCHBookProcessingStateReadyForRightsParsing,
     SCHBookProcessingStateReadyForTextFlowPreParse,
     SCHBookProcessingStateReadyForSmartZoomPreParse,
     SCHBookProcessingStateReadyForPagination,
     SCHBookProcessingStateReadyToRead

    */
	// book status
	switch ([book processingState]) {
		case SCHBookProcessingStateError:
        case SCHBookProcessingStateBookVersionNotSupported:
		case SCHBookProcessingStateNoURLs:
		case SCHBookProcessingStateNoCoverImage:
		case SCHBookProcessingStateReadyForBookFileDownload:
        case SCHBookProcessingStateReadyForLicenseAcquisition:
        case SCHBookProcessingStateReadyForRightsParsing:
        case SCHBookProcessingStateReadyForTextFlowPreParse:
        case SCHBookProcessingStateReadyForSmartZoomPreParse:
        case SCHBookProcessingStateReadyForPagination:
			self.thumbTintView.hidden = NO;
			self.progressView.hidden = YES;
//			self.statusLabel.hidden = NO;
			break;
		case SCHBookProcessingStateDownloadStarted:
		case SCHBookProcessingStateDownloadPaused:
			self.thumbTintView.hidden = NO;
			self.progressView.hidden = NO;
//			self.statusLabel.hidden = NO;
			break;
		case SCHBookProcessingStateReadyToRead:
		default:
			self.thumbTintView.hidden = YES;
			self.progressView.hidden = YES;
//			self.statusLabel.hidden = YES;
			break;
	}
	
	[self.progressView setProgress:[book currentDownloadedPercentage]];
//	self.statusLabel.text = status;
	
	[self layoutSubviews];
	
//	[self.statusLabel setNeedsDisplay];
}	
	

- (void) updatePercentage: (NSNotification *) notification
{
    NSString *updateForISBN = [[notification userInfo] objectForKey:@"isbn"];
    
    if ([updateForISBN compare:self.isbn] == NSOrderedSame) {
        float newPercentage = [(NSNumber *) [[notification userInfo] objectForKey:@"currentPercentage"] floatValue];
        [self.progressView setProgress:newPercentage];
    }
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
//	self.statusLabel = nil;
	self.asyncImageView = nil;
	self.thumbTintView = nil;
	self.progressView = nil;
    [super dealloc];
}

@end
