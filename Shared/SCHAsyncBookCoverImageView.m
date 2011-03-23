//
//  SCHAsyncBookCoverImageView.m
//  Scholastic
//
//  Created by Gordon Christie on 10/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHAsyncBookCoverImageView.h"

@interface SCHAsyncBookCoverImageView () 

- (void)newImageAvailable:(NSNotification *)notification;

@end


@implementation SCHAsyncBookCoverImageView

@synthesize isbn, coverSize;

- (void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super dealloc];
}

- (void) initialiseView {
	self.contentMode = UIViewContentModeScaleToFill;
	self.clipsToBounds = YES;
}

- (id) initWithFrame: (CGRect) frame {
	if (self = [super initWithFrame:frame]) {
		[self initialiseView];
	}
	return self;
}

- (id) initWithImage: (UIImage *) image {
	if (self = [super initWithImage:image]) {
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
											   object:self.isbn];
	
}


- (void)newImageAvailable:(NSNotification *)notification {
	NSDictionary *userInfo = [notification userInfo];
	id image = [userInfo valueForKey:@"image"];
	CGSize thumbSize = [[userInfo valueForKey:@"thumbSize"] CGSizeValue];
	
	if (image && self.coverSize.width == thumbSize.width && self.coverSize.height == thumbSize.height) {
		[self setImage:image];
		[self setNeedsDisplay];
	}
	
}

@end
