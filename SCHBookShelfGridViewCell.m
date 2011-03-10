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


@implementation SCHBookShelfGridViewCell

@synthesize asyncImageView, thumbTintView, statusLabel, progressView, bookInfo;

- (id)initWithFrame:(CGRect)frame reuseIdentifier: (NSString*) identifier {

	if ((self = [super initWithFrame:frame reuseIdentifier:identifier])) {
        
		self.asyncImageView = [SCHThumbnailFactory newAsyncImageWithSize:CGSizeMake(self.frame.size.width - 4, self.frame.size.height - 20)];
		[self.asyncImageView setFrame:CGRectZero];
		[self.contentView addSubview:self.asyncImageView];
		
		self.thumbTintView = [[UIView alloc] initWithFrame:CGRectZero];
		[self.thumbTintView setBackgroundColor:[UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:0.6f]];
		[self.contentView addSubview:self.thumbTintView];
		
		self.statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.statusLabel setFont:[UIFont systemFontOfSize:12.0f]];
        [self.statusLabel setTextColor:[UIColor whiteColor]];
		[self.statusLabel setBackgroundColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.75]];
        [self.statusLabel setHighlightedTextColor:[UIColor whiteColor]];
		[self.statusLabel setNumberOfLines:1];
		[self.statusLabel setTextAlignment:UITextAlignmentCenter];
		
        [self.contentView addSubview:self.statusLabel];
		
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
	
	self.statusLabel.frame = CGRectMake(-10, self.frame.size.height - 20, self.frame.size.width + 20, 14);
	self.asyncImageView.frame = CGRectMake(2, 0, self.frame.size.width - 4, self.frame.size.height - 22);
	self.thumbTintView.frame = CGRectMake(2, 0, self.frame.size.width - 4, self.frame.size.height - 22);
	self.progressView.frame = CGRectMake(10, self.frame.size.height - 42, self.frame.size.width - 20, 10);
}

#pragma mark -
#pragma mark Setter for SCHBookInfo


- (void) setBookInfo: (SCHBookInfo *) newBookInfo
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
	BOOL immediateUpdate = 	[[SCHProcessingManager defaultManager] updateThumbView:self.asyncImageView
																		  withBook:bookInfo
																			  size:CGSizeMake(self.frame.size.width - 6, self.frame.size.height - 20)
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
		self.thumbTintView.hidden = NO;
		self.progressView.hidden = NO;
		self.statusLabel.hidden = NO;
	} else if ([bookInfo isCurrentlyWaitingForURLs]) {
		status = @"Updating...";
		self.thumbTintView.hidden = NO;
		self.progressView.hidden = YES;
		self.statusLabel.hidden = NO;
	} else if ([bookInfo isWaitingForDownload]) {
		status = @"Waiting...";
		self.thumbTintView.hidden = NO;
		self.progressView.hidden = YES;
		self.statusLabel.hidden = NO;
	} else {
		
		// book status
		switch ([bookInfo processingState]) {
			case bookFileProcessingStateError:
				status = @"Error";
				self.thumbTintView.hidden = NO;
				self.progressView.hidden = YES;
				self.statusLabel.hidden = NO;
				break;
			case bookFileProcessingStateFullyDownloaded:
				status = @"";
				self.thumbTintView.hidden = YES;
				self.progressView.hidden = YES;
				self.statusLabel.hidden = YES;
				break;
			case bookFileProcessingStateNoFileDownloaded:
				status = @"Download";
				self.thumbTintView.hidden = NO;
				self.progressView.hidden = YES;
				self.statusLabel.hidden = NO;
				break;
			case bookFileProcessingStatePartiallyDownloaded:
				status = @"Paused";
				self.thumbTintView.hidden = NO;
				self.progressView.hidden = NO;
				self.statusLabel.hidden = NO;
				break;
			default:
				status = @"";
				self.thumbTintView.hidden = YES;
				self.progressView.hidden = YES;
				self.statusLabel.hidden = YES;
				break;
		}
	}	
	[self.progressView setProgress:[bookInfo currentDownloadedPercentage]];
	self.statusLabel.text = status;
	
	[self layoutSubviews];
	
	[self.statusLabel setNeedsDisplay];
	
}

- (void) updatePercentage: (NSNotification *) notification
{
	float newPercentage = [(NSNumber *) [[notification userInfo] objectForKey:@"currentPercentage"] floatValue];
	[self.progressView setProgress:newPercentage];
}

- (void) prepareForReuse
{
	if (self.asyncImageView) {
		[self.asyncImageView prepareForReuse];
	}
}



- (void)dealloc {
	self.statusLabel = nil;
	self.asyncImageView = nil;
	self.thumbTintView = nil;
	self.progressView = nil;
    [super dealloc];
}




@end
