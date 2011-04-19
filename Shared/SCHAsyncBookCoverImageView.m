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

@synthesize isbn, thumbSize, coverSize;

- (void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super dealloc];
}

- (void) initialiseView {
	self.contentMode = UIViewContentModeBottom;
	self.clipsToBounds = YES;
    self.backgroundColor = [UIColor clearColor];
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
	
}


- (void)newImageAvailable:(NSNotification *)notification {
	NSDictionary *userInfo = [notification userInfo];
    
    if ([self.isbn compare:[userInfo objectForKey:@"isbn"]] == NSOrderedSame) {
        id image = [userInfo valueForKey:@"image"];
        CGSize itemSize = [[userInfo valueForKey:@"thumbSize"] CGSizeValue];
        CGSize newCoverSize = [[userInfo valueForKey:@"coverSize"] CGSizeValue];
        
        if (image && self.thumbSize.width == itemSize.width && self.thumbSize.height == itemSize.height) {
            self.coverSize = newCoverSize;
            [self setImage:image];
            [self setNeedsDisplay];
        }
    }
	
}

@end
