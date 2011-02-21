//
//  SCHAsyncImageView.m
//  Scholastic
//
//  Created by Gordon Christie on 10/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHAsyncImageView.h"

@interface SCHAsyncImageView () 

- (void)newImageAvailable:(NSNotification *)notification;

@end


@implementation SCHAsyncImageView

@synthesize operations, imageOfInterest;

- (void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	if (operations) {
		for (NSOperation *op in self.operations) {
			[op cancel];
		}
	}
	
	self.operations = nil;
	self.imageOfInterest = nil;
	[super dealloc];
}

- (void) prepareForReuse
{
	if (operations) {
		for (NSOperation *op in self.operations) {
			[op cancel];
		}
	}
	
	self.operations = nil;
	self.imageOfInterest = nil;
	self.image = nil;
}

- (void) initialiseView {
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(newImageAvailable:)
												 name:@"SCHNewImageAvailable"
											   object:nil];
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

- (void) updateImageOfInterest: (NSString *) newInterest
{
	self.image = [UIImage imageNamed:@"PlaceholderBook"];
	self.imageOfInterest = newInterest;
}


- (void)newImageAvailable:(NSNotification *)notification {
	NSDictionary *userInfo = [notification userInfo];
	id imagePath = [userInfo valueForKey:@"imagePath"];
	id image = [userInfo valueForKey:@"image"];
	
//	NSLog(@"new image available! %@ (looking for %@)", imagePath, self.imageOfInterest);
	if (image && imagePath && [imagePath isEqualToString:self.imageOfInterest]) {
		NSLog(@"Setting image. (matched %@)", imagePath);
		
		[self setImage:image];
		[self setNeedsDisplay];
	}
}


@end
