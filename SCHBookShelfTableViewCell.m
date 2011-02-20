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

#define IMAGE_SIZE          44.0
#define LEFT_MARGIN			8.0
#define RIGHT_MARGIN		8.0
#define TOP_MARGIN			8.0
#define BOTTOM_MARGIN		8.0

#define TEXT_TOP_MARGIN		12.0
#define TEXT_LEFT_MARGIN	8.0
#define THUMBRATIO 1.8


@interface SCHBookShelfTableViewCell ()

@property (readwrite, retain) SCHAsyncImageView *thumbImageView;

@end

@implementation SCHBookShelfTableViewCell

@synthesize titleLabel, subtitleLabel, thumbImageView, bookInfo;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
		
		self.frame = CGRectMake(0, 0, self.frame.size.width - 32, IMAGE_SIZE);
		[self layoutSubviews];
		
		self.thumbImageView = [SCHThumbnailFactory newAsyncImageWithSize:CGSizeMake(IMAGE_SIZE, IMAGE_SIZE)];
		
		[self.contentView addSubview:self.thumbImageView];
		
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
	
	CGRect thumbFrame = self.thumbImageView.frame;
	thumbFrame.origin = CGPointMake(LEFT_MARGIN, floorf((CGRectGetHeight(bounds) - CGRectGetHeight(thumbFrame))/2.0f));
    [self.thumbImageView setFrame:thumbFrame];
	
	CGFloat labelX = ceilf(CGRectGetMaxX(self.thumbImageView.frame) + TEXT_LEFT_MARGIN);
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

	NSLog(@"Thumbview frame: %@", NSStringFromCGRect(self.thumbImageView.frame));
	
	// image processing
	BOOL immediateUpdate = [[SCHProcessingManager defaultManager] updateThumbView:self.thumbImageView
																		 withBook:newBookInfo
																			 size:self.thumbImageView.frame.size
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


- (void)dealloc {
    [super dealloc];
}


@end
