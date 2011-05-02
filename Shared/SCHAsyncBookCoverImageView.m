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

@property (nonatomic, assign) BOOL usePlaceholderImage;

- (void)initialiseView;
- (void)newImageAvailable:(NSNotification *)notification;
- (void)calculateCoverSize;

@end


@implementation SCHAsyncBookCoverImageView

@synthesize isbn;
@synthesize thumbSize;
@synthesize coverSize;
@synthesize usePlaceholderImage;

#pragma mark - Object lifecycle

- (id)initWithFrame:(CGRect)frame 
{
	if ((self = [super initWithFrame:frame])) {
		[self initialiseView];
        self.coverSize = CGSizeZero;        
	}
	return(self);
}

- (id)initWithImage:(UIImage *)image 
{
	if ((self = [super initWithImage:image])) {
		[self initialiseView];
	}
	return(self);
}

- (void)initialiseView 
{
	self.contentMode = UIViewContentModeBottom;
	self.clipsToBounds = YES;
    self.backgroundColor = [UIColor clearColor];
}

- (void)dealloc 
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[isbn release], isbn = nil;
    
	[super dealloc];
}

#pragma mark - Accessor methods

- (void)setIsbn:(NSString *)newIsbn
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[isbn release];
	isbn = [newIsbn copy];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(newImageAvailable:)
												 name:@"SCHNewImageAvailable"
											   object:nil];
}

- (void)setImage:(UIImage *)newImage
{
    if (newImage == nil) {
        newImage = [UIImage imageNamed:@"PlaceholderBook"];        
        self.usePlaceholderImage = YES;
    } else {
        self.usePlaceholderImage = NO;        
    }
    [super setImage:newImage];
    [self calculateCoverSize];
}

- (void)newImageAvailable:(NSNotification *)notification 
{
	NSDictionary *userInfo = [notification userInfo];
    
    if ([self.isbn compare:[userInfo objectForKey:@"isbn"]] == NSOrderedSame) {
        id image = [userInfo valueForKey:@"image"];
        CGSize itemSize = [[userInfo valueForKey:@"thumbSize"] CGSizeValue];
        
        if (image && self.thumbSize.width == itemSize.width && self.thumbSize.height == itemSize.height) {
            self.image = image;
            [self setNeedsDisplay];
        }
    }
}

#pragma mark - Private methods

- (void)calculateCoverSize
{
    if (self.usePlaceholderImage == YES) {
        self.coverSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
    } else {
        SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.isbn];
        CGSize fullImageSize = [book bookCoverImageSize];
        
        if (book && !CGSizeEqualToSize(fullImageSize, CGSizeZero)) {
            CGSize aCoverSize = [SCHThumbnailFactory coverSizeForImageOfSize:fullImageSize thumbNailOfSize:self.image.size aspect:YES];
            
            self.coverSize = aCoverSize;
        } else {
            self.coverSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
        }
    }
}

@end
