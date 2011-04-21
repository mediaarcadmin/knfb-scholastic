//
//  SCHAsyncBookCoverImageView.m
//  Scholastic
//
//  Created by Gordon Christie on 10/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHAsyncBookCoverImageView.h"
#import "SCHBookManager.h"
#import "SCHAppBook.h"
#import "SCHThumbnailFactory.h"

@interface SCHAsyncBookCoverImageView () 

- (void) newImageAvailable:(NSNotification *)notification;
- (void) calculateCoverSize;

@end


@implementation SCHAsyncBookCoverImageView

@synthesize isbn, thumbSize, coverSize;

- (void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super dealloc];
}

- (void) initialiseView {
	self.contentMode = UIViewContentModeBottom;
	self.clipsToBounds = YES;
    self.backgroundColor = [UIColor clearColor];
    
    self.coverSize = CGSizeZero;
}

- (id) initWithFrame: (CGRect) frame {
	if ((self = [super initWithFrame:frame])) {
		[self initialiseView];
	}
	return self;
}

- (id) initWithImage: (UIImage *) image {
	if ((self = [super initWithImage:image])) {
		[self initialiseView];
	}
	return self;
}

- (void) setIsbn:(NSString *) newIsbn
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	NSString *oldIsbn = isbn;
	isbn = [newIsbn retain];
	[oldIsbn release];
	
	self.image = [UIImage imageNamed:@"PlaceholderBook"];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(newImageAvailable:)
												 name:@"SCHNewImageAvailable"
											   object:nil];
    
    [self calculateCoverSize];
	
}

- (void) setImage:(UIImage *)image
{
    [super setImage:image];
    [self calculateCoverSize];
}

- (void) newImageAvailable:(NSNotification *)notification {
	NSDictionary *userInfo = [notification userInfo];
    
    if ([self.isbn compare:[userInfo objectForKey:@"isbn"]] == NSOrderedSame) {
        id image = [userInfo valueForKey:@"image"];
        CGSize itemSize = [[userInfo valueForKey:@"thumbSize"] CGSizeValue];
        
        if (image && self.thumbSize.width == itemSize.width && self.thumbSize.height == itemSize.height) {
            [self setImage:image];
            [self calculateCoverSize];
            [self setNeedsDisplay];
        }
    }
	
}

- (void) calculateCoverSize
{
    SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.isbn];
    CGSize fullImageSize = [book bookCoverImageSize];
    
    if (book && self.image && !CGSizeEqualToSize(fullImageSize, CGSizeZero)) {
        
        CGSize aCoverSize = [SCHThumbnailFactory coverSizeForImageOfSize:fullImageSize thumbNailOfSize:self.image.size aspect:YES];
        
        self.coverSize = aCoverSize;
        
    } else {
        self.coverSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
    }
}

@end
