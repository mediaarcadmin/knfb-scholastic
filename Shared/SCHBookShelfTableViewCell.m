//
//  SCHBookShelfTableViewCell.m
//  Scholastic
//
//  Created by Gordon Christie on 17/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBookShelfTableViewCell.h"
#import "SCHThumbnailFactory.h"
#import "SCHProcessingManager.h"

#define IMAGE_FRAME_WIDTH   72.0
#define IMAGE_FRAME_HEIGHT  96.0
#define IMAGE_TOP_MARGIN	11.0
#define LEFT_MARGIN			8.0
#define RIGHT_MARGIN		0.0

#define TEXT_TOP_MARGIN		24.0
#define TEXT_LEFT_MARGIN	8.0
//#define THUMBRATIO 1.8


@interface SCHBookShelfTableViewCell ()

@property (readwrite, retain) SCHAsyncImageView *thumbImageView;

- (void) updateWithContentMetadata: (SCHContentMetadataItem *) metadata status: (NSString *) status;

@end

@implementation SCHBookShelfTableViewCell

@synthesize titleLabel, subtitleLabel, statusLabel, thumbImageView, thumbTintView, bookInfo, thumbContainerView, progressView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
		
		self.frame = CGRectMake(0, 0, self.frame.size.width - IMAGE_FRAME_WIDTH, IMAGE_FRAME_HEIGHT);
		[self layoutSubviews];
		
		self.thumbContainerView = [[UIView alloc] initWithFrame:CGRectMake(LEFT_MARGIN, IMAGE_TOP_MARGIN, IMAGE_FRAME_WIDTH, IMAGE_FRAME_HEIGHT)];
		
		self.thumbImageView = [SCHThumbnailFactory newAsyncImageWithSize:CGSizeMake(IMAGE_FRAME_WIDTH, IMAGE_FRAME_HEIGHT)];
		[self.thumbContainerView addSubview:self.thumbImageView];
		
		self.thumbTintView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, IMAGE_FRAME_WIDTH, IMAGE_FRAME_HEIGHT)];
		[self.thumbTintView setBackgroundColor:[UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:0.6f]];
		[self.thumbContainerView addSubview:self.thumbTintView];

		[self.thumbContainerView setClipsToBounds:YES];
		
		[self.contentView addSubview:self.thumbContainerView];
		
		self.progressView = [[UIProgressView alloc] initWithFrame:CGRectZero];
		[self.contentView addSubview:self.progressView];
		
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.titleLabel setFont:[UIFont boldSystemFontOfSize:24.0f]];
        [self.titleLabel setTextColor:[UIColor blackColor]];
        [self.titleLabel setHighlightedTextColor:[UIColor whiteColor]];
		[self.titleLabel setMinimumFontSize:16.0f];
		[self.titleLabel setNumberOfLines:2];
		[self.titleLabel setAdjustsFontSizeToFitWidth:YES];
        [self.contentView addSubview:self.titleLabel];
		
        self.subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.subtitleLabel setFont:[UIFont systemFontOfSize:15.0f]];
        [self.subtitleLabel setTextColor:[UIColor colorWithRed:0.263f green:0.353f blue:0.487f alpha:1.0f]];
        [self.subtitleLabel setHighlightedTextColor:[UIColor whiteColor]];
		[self.subtitleLabel setNumberOfLines:1];
		
        [self.contentView addSubview:self.subtitleLabel];

		self.statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.statusLabel setFont:[UIFont systemFontOfSize:12.0f]];
        [self.statusLabel setTextColor:[UIColor lightGrayColor]];
        [self.statusLabel setHighlightedTextColor:[UIColor whiteColor]];
		[self.statusLabel setNumberOfLines:1];
		[self.statusLabel setTextAlignment:UITextAlignmentCenter];
		
        [self.contentView addSubview:self.statusLabel];
		
		self.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
    return self;
}

#pragma mark -
#pragma mark Laying out subviews

- (void)layoutSubviews {
    [super layoutSubviews];
	
	CGRect bounds = self.contentView.bounds;
	
//	CGRect thumbFrame = self.thumbContainerView.frame;
//	thumbFrame.origin = CGPointMake(10, floorf((CGRectGetHeight(bounds) - CGRectGetHeight(thumbFrame))/2.0f));
    //[self.thumbContainerView setFrame:thumbFrame];
	
	CGFloat labelX = ceilf(CGRectGetMaxX(self.thumbContainerView.frame) + TEXT_LEFT_MARGIN);
	CGFloat labelWidth = CGRectGetWidth(bounds) - RIGHT_MARGIN - labelX;
	
	CGRect titleFrame = CGRectMake(labelX, TEXT_TOP_MARGIN, labelWidth, 44);
    [self.titleLabel setFrame:titleFrame];
	
	CGRect subtitleFrame = CGRectMake(labelX, CGRectGetMaxY(titleFrame) + 1, labelWidth, 22);
    [self.subtitleLabel setFrame:subtitleFrame];

	CGRect statusFrame = CGRectMake(LEFT_MARGIN - 4, CGRectGetMaxY(self.contentView.bounds) - 21, CGRectGetWidth(self.thumbContainerView.frame) + 8, 15);
    [self.statusLabel setFrame:statusFrame];
	
	CGRect progressFrame = CGRectMake(LEFT_MARGIN + 2, self.thumbContainerView.frame.size.height - 6, IMAGE_FRAME_WIDTH - 4, 10);
	[self.progressView setFrame:progressFrame];
}

#pragma mark -
#pragma mark Setter for SCHBookInfo

- (void) setBookInfo:(SCHBookInfo *) newBookInfo
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"SCHBookDownloadPercentageUpdate" object:bookInfo];

	if (newBookInfo != bookInfo) {
		SCHBookInfo *oldBookInfo = bookInfo;
		bookInfo = [newBookInfo retain];
		[oldBookInfo release];
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(updatePercentage:) 
												 name:@"SCHBookDownloadPercentageUpdate" 
											   object:self.bookInfo.bookIdentifier];

	// image processing
	BOOL immediateUpdate = [[SCHProcessingManager defaultManager] updateThumbView:self.thumbImageView
																		 withBook:newBookInfo
																			 size:CGSizeMake(IMAGE_FRAME_WIDTH, IMAGE_FRAME_HEIGHT)
																			 rect:CGRectNull
																			 flip:NO
																   maintainAspect:YES
																   usePlaceHolder:YES];
	if (immediateUpdate) {
		[self setNeedsDisplay];
	}
	
	NSString *status = @"";
	
	if ([bookInfo isCurrentlyDownloading]) {
		status = @"Downloading...";
		thumbTintView.hidden = NO;
		self.progressView.hidden = NO;
	} else if ([bookInfo isWaitingForDownload]) {
		status = @"Waiting...";
		thumbTintView.hidden = NO;
		self.progressView.hidden = YES;
	} else {
		// book status
		switch ([bookInfo processingState]) {
			case bookFileProcessingStateError:
				status = @"Error";
				self.thumbTintView.hidden = NO;
				self.progressView.hidden = YES;
				break;
			case bookFileProcessingStateFullyDownloaded:
				status = @"";
				self.thumbTintView.hidden = YES;
				self.progressView.hidden = YES;
				break;
			case bookFileProcessingStateNoFileDownloaded:
				status = @"Download";
				self.thumbTintView.hidden = NO;
				self.progressView.hidden = YES;
				break;
			case bookFileProcessingStatePartiallyDownloaded:
				status = @"Paused";
				self.thumbTintView.hidden = NO;
				self.progressView.hidden = NO;
				break;
			default:
				status = @"Unknown!";
				self.thumbTintView.hidden = YES;
				self.progressView.hidden = YES;
				break;
		}
	}	
	if (self.thumbTintView.hidden) {
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	} else {
		self.accessoryType = UITableViewCellAccessoryNone;
	}
	
	[self.progressView setProgress:[bookInfo currentDownloadedPercentage]];
	
	//NSLog(@"Setting status for %@ to \"%@\" (%d).", self.bookInfo.contentMetadata.Title, status, [bookInfo processingState]);
	
	[self updateWithContentMetadata:self.bookInfo.contentMetadata status:status];	
}


- (void) updateWithContentMetadata: (SCHContentMetadataItem *) metadata status: (NSString *) status
{
	self.titleLabel.text = [metadata Title];
	self.subtitleLabel.text = [metadata Author];
	self.statusLabel.text = status;
	
	[self layoutSubviews];
	
	[self.titleLabel setNeedsDisplay];
	[self.subtitleLabel setNeedsDisplay];
	[self.statusLabel setNeedsDisplay];
}

- (void) updatePercentage: (NSNotification *) notification
{
	float newPercentage = [(NSNumber *) [[notification userInfo] objectForKey:@"currentPercentage"] floatValue];
	[self.progressView setProgress:newPercentage];
}

- (void) prepareForReuse
{
	if (self.thumbImageView) {
		[self.thumbImageView prepareForReuse];
	}
}

- (void)dealloc {
	self.titleLabel = nil;
	self.subtitleLabel = nil;
	self.statusLabel = nil;
    [super dealloc];
}


@end
