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

#define IMAGE_FRAME_WIDTH   48.0
#define IMAGE_FRAME_HEIGHT   64.0
#define LEFT_MARGIN			8.0
#define RIGHT_MARGIN		0.0

#define TEXT_TOP_MARGIN		12.0
#define TEXT_LEFT_MARGIN	8.0
//#define THUMBRATIO 1.8


@interface SCHBookShelfTableViewCell ()

@property (readwrite, retain) SCHAsyncImageView *thumbImageView;

@end

@implementation SCHBookShelfTableViewCell

@synthesize titleLabel, subtitleLabel, thumbImageView, bookInfo, thumbContainerView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
		
		self.frame = CGRectMake(0, 0, self.frame.size.width - IMAGE_FRAME_WIDTH, IMAGE_FRAME_HEIGHT);
		[self layoutSubviews];
		
		self.thumbContainerView = [[UIView alloc] initWithFrame:CGRectMake(LEFT_MARGIN, TEXT_TOP_MARGIN, IMAGE_FRAME_WIDTH, IMAGE_FRAME_HEIGHT)];
		
		self.thumbImageView = [SCHThumbnailFactory newAsyncImageWithSize:CGSizeMake(IMAGE_FRAME_WIDTH, IMAGE_FRAME_HEIGHT)];
		[self.thumbContainerView setClipsToBounds:YES];
		
		[self.thumbContainerView addSubview:self.thumbImageView];
		
		[self.contentView addSubview:self.thumbContainerView];
		
        titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [titleLabel setFont:[UIFont boldSystemFontOfSize:22.0f]];
        [titleLabel setTextColor:[UIColor blackColor]];
        [titleLabel setHighlightedTextColor:[UIColor whiteColor]];
		[titleLabel setMinimumFontSize:16.0f];
		[titleLabel setNumberOfLines:2];
		[titleLabel setAdjustsFontSizeToFitWidth:YES];
        [self.contentView addSubview:titleLabel];
		
        subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [subtitleLabel setFont:[UIFont systemFontOfSize:13.0f]];
        [subtitleLabel setTextColor:[UIColor colorWithRed:0.263f green:0.353f blue:0.487f alpha:1.0f]];
        [subtitleLabel setHighlightedTextColor:[UIColor whiteColor]];
		[subtitleLabel setNumberOfLines:1];
		
        [self.contentView addSubview:subtitleLabel];
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
}

#pragma mark -
#pragma mark Setter for SCHBookInfo

- (void) setBookInfo:(SCHBookInfo *) newBookInfo
{
	if (newBookInfo != bookInfo) {
		SCHBookInfo *oldBookInfo = bookInfo;
		bookInfo = [newBookInfo retain];
		[oldBookInfo release];
	}

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
	
	SCHContentMetadataItem *contentMetadata = self.bookInfo.contentMetadata;
	self.titleLabel.text = [contentMetadata Title];
	self.subtitleLabel.text = [contentMetadata Author];
	
	[self layoutSubviews];
	
	[self.titleLabel setNeedsDisplay];
	[self.subtitleLabel setNeedsDisplay];
	
}

- (void) prepareForReuse
{
	if (self.thumbImageView) {
		[self.thumbImageView prepareForReuse];
	}
}

- (void)dealloc {
    [super dealloc];
}


@end
