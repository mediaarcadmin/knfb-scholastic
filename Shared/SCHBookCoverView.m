//
//  SCHBookCoverView.m
//  Scholastic
//
//  Created by Gordon Christie on 21/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBookCoverView.h"
#import "SCHAppBook.h"
#import "SCHBookManager.h"

//// FIXME: remove or improve references to SCHThumbnailFactory
//#import "SCHThumbnailFactory.h"

#import <ImageIO/ImageIO.h>

@interface SCHBookCoverView ()

- (void)initialiseView;
- (void)performWithBook:(void (^)(SCHAppBook *))block;
- (UIImage *)createImageWithSourcePath:(NSString *)sourcePath destinationPath:(NSString *)destinationPath;

@property (nonatomic, retain) UIImageView *coverImageView;
@property (nonatomic, retain) NSString *currentImageName;

@end

@implementation SCHBookCoverView

@synthesize identifier;
@synthesize coverSize;

@synthesize coverImageView;
@synthesize currentImageName;

- (void)dealloc 
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[identifier release], identifier = nil;
    [currentImageName release], currentImageName = nil;
    [coverImageView release], coverImageView = nil;
    
	[super dealloc];
}

- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
    
	if (self) {
		[self initialiseView];
	}
    
	return self;
}

- (void)prepareForReuse
{
    self.coverImageView.image = nil;
    self.currentImageName = nil;
    self.identifier = nil;
}

- (void)initialiseView 
{
    // add the image view
    // assume the image view is the same size as the frame size for now
    self.coverSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
    self.coverImageView = [[UIImageView alloc] initWithFrame:self.frame];
    
//    NSLog(@"Frames: %@ %@", NSStringFromCGRect(self.frame), NSStringFromCGSize(coverSize));
    
//    self.backgroundColor = [UIColor purpleColor];
    self.coverImageView.backgroundColor = [UIColor orangeColor];
    [self addSubview:coverImageView];
    [self bringSubviewToFront:coverImageView];
    
    // no scaling of the cover view
	self.coverImageView.contentMode = UIViewContentModeBottomLeft;
	self.clipsToBounds = YES;
    self.backgroundColor = [UIColor clearColor];
    
}

- (void)setIdentifier:(SCHBookIdentifier *)newIdentifier
{
    
	if ([newIdentifier isEqual:identifier]) {
        return;
    }
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SCHBookDownloadPercentageUpdate" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SCHBookStateUpdate" object:nil];
    
    [identifier release];
    identifier = [newIdentifier retain];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(updatePercentage:) 
//                                                 name:@"SCHBookDownloadPercentageUpdate" 
//                                               object:nil];
//    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkForImageUpdateFromNotification:)
                                                 name:@"SCHBookStateUpdate"
                                               object:nil];
    self.coverImageView.image = nil;
    self.currentImageName = nil;

}

- (void)setFrame:(CGRect)newFrame
{
//    NSLog(@"Setting new frame. %@", NSStringFromCGRect(newFrame));
//    NSLog(@"Image view frame :%@", NSStringFromCGRect(self.coverImageView.frame));
    self.coverImageView.frame = CGRectMake(0, 0, self.coverSize.width, self.coverSize.height);
    [super setFrame:newFrame];
}

- (void)setCoverSize:(CGSize)newCoverSize
{
    if (newCoverSize.width == coverSize.width && newCoverSize.height == coverSize.height) {
        NSLog(@"Setting cover size to the same value. Returning.");
        return;
    }
    
    if (newCoverSize.width == self.frame.size.width && newCoverSize.height == self.frame.size.height) {
        NSLog(@"Setting cover size the the same size as the frame...");
    }
    
    coverSize = newCoverSize;
    
    self.coverImageView.frame = CGRectMake(0, 0, self.coverSize.width, self.coverSize.height);
    
    NSLog(@"Cover size set. Needs refresh!");
    
}

- (void)performWithBook:(void (^)(SCHAppBook *))block
{
    if (!self.identifier || !block) {
        return;
    }
    
    dispatch_block_t accessBlock = ^{
        NSManagedObjectContext *mainThreadContext = [(id)[[UIApplication sharedApplication] delegate] managedObjectContext];
        SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.identifier inManagedObjectContext:mainThreadContext];
        block(book);
    };
    
    if ([NSThread isMainThread]) {
        accessBlock();
    } else {
        dispatch_sync(dispatch_get_main_queue(), accessBlock);
    }
}


- (void)refreshBookCoverView
{
//    NSLog(@"Refreshing book cover view...");
    // if no identifier has been set, then we don't need to refresh the image
    if (!self.identifier) {
//        NSLog(@"No identifier set. Clearing image.");
        self.coverImageView.image = nil; 
        self.currentImageName = nil;
        return;
    }
    
	__block NSString *fullImagePath;
    __block NSString *thumbPath;
    __block SCHBookCurrentProcessingState bookState;
    [self performWithBook:^(SCHAppBook *book) {
//        NSLog(@"Getting book information.");
        bookState = [book processingState];
        fullImagePath = [[book coverImagePath] retain];
        thumbPath = [[book thumbPathForSize:self.coverSize] retain];
    }];
	
    if (bookState <= SCHBookProcessingStateNoCoverImage) {
//        NSLog(@"Book does not have a cover image downloaded.");
        self.coverImageView.image = nil;
        self.currentImageName = nil;
        return;
    }
    
    if (self.currentImageName != nil && [self.currentImageName compare:thumbPath] == NSOrderedSame) {
//        NSLog(@"Already using the right thumbnail image.");
    } else {
        // first, resize the image view if necessary
        if (self.coverImageView.frame.size.width != self.coverSize.width 
            || self.coverImageView.frame.size.height != self.coverSize.height) {
//            NSLog(@"Resizing image view.");
            self.coverImageView.frame = CGRectMake(0, 0, self.coverSize.width, self.coverSize.height);
        }
        
        NSFileManager *threadLocalFileManager = [[[NSFileManager alloc] init] autorelease];
        
        // check to see if we have the thumb already cached
        if ([threadLocalFileManager fileExistsAtPath:thumbPath]) {
//            NSLog(@"Thumb exists. Loading image from cache.");
            // load the cached image
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                [thumbPath retain];
                UIImage *thumbImage = [UIImage imageWithContentsOfFile:thumbPath];
                
                dispatch_async(dispatch_get_main_queue(), ^{
//                    NSLog(@"Thumb loaded. Setting image.");
                    self.coverImageView.image = thumbImage;
                    self.currentImageName = thumbPath;
                });
                
                [thumbPath release];
            });
            
        } else {
//            NSLog(@"Thumb does not exist. Creating thumb.");
            // dispatch the thumbnail operation
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                
                [fullImagePath retain];
                [thumbPath retain];
//                [NSThread sleepForTimeInterval:5];
                UIImage *thumbImage = [self createImageWithSourcePath:fullImagePath destinationPath:thumbPath];
                self.currentImageName = thumbPath;
                [fullImagePath release];
                [thumbPath release];
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
//                    NSLog(@"Thumb created. Setting image.");
                    self.coverImageView.image = thumbImage;
                });
            });
        }
        
        [fullImagePath release];
        [thumbPath release];
    }
}

//- (UIImage *)createImageWithSourcePath:(NSString *)sourcePath destinationPath:(NSString *)destinationPath 
//{
//    // debug: make sure we're not running the image resizing on the main thread
//	NSAssert([NSThread currentThread] != [NSThread mainThread], @"Don't do image interpolation on the main thread!");
//    
//    UIImage *fullImage = [UIImage imageWithContentsOfFile:sourcePath];
//    UIImage *resizedImage = [SCHThumbnailFactory thumbnailImageOfSize:self.coverSize forImage:fullImage maintainAspect:YES];
//    
//    if (resizedImage) {
//        NSData *pngData = UIImagePNGRepresentation(resizedImage);
//        [pngData writeToFile:destinationPath atomically:YES];
//    }
//
//    return resizedImage;
//}

- (UIImage *)createImageWithSourcePath:(NSString *)sourcePath destinationPath:(NSString *)destinationPath 
{
    // debug: make sure we're not running the image resizing on the main thread
	NSAssert([NSThread currentThread] != [NSThread mainThread], @"Don't do image interpolation on the main thread!");
    
    NSURL *sourceURL = [NSURL fileURLWithPath:sourcePath];
    
    CGImageSourceRef src = CGImageSourceCreateWithURL((CFURLRef)sourceURL, NULL);

    
    // get the main image properties without loading it into memory
    CGFloat width = 0.0f, height = 0.0f;
    CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(src, 0, NULL);
    if (imageProperties != NULL) {
        CFNumberRef widthNum  = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelWidth);
        if (widthNum != NULL) {
            CFNumberGetValue(widthNum, kCFNumberFloatType, &width);
        }
        
        CFNumberRef heightNum = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelHeight);
        if (heightNum != NULL) {
            CFNumberGetValue(heightNum, kCFNumberFloatType, &height);
        }
        
        CFRelease(imageProperties);
    }

    NSInteger maxDimension = self.coverSize.height;
    
    if (width > height) {
        maxDimension = self.coverSize.width;
    }
    
    
    NSDictionary* d = [NSDictionary dictionaryWithObjectsAndKeys:
                       (id)kCFBooleanFalse, kCGImageSourceShouldAllowFloat,
                       (id)kCFBooleanTrue, kCGImageSourceCreateThumbnailWithTransform,
                       (id)kCFBooleanTrue, kCGImageSourceCreateThumbnailFromImageAlways,
                       [NSNumber numberWithInt:maxDimension], kCGImageSourceThumbnailMaxPixelSize,
                       nil];
    
    CGImageRef thumbnailRef = CGImageSourceCreateThumbnailAtIndex(src, 0, (CFDictionaryRef) d);
    UIImage *resizedImage = [UIImage imageWithCGImage:thumbnailRef];
    CGImageRelease(thumbnailRef);
    CFRelease(src);
    
    if (resizedImage) {
        NSData *pngData = UIImagePNGRepresentation(resizedImage);
        [pngData writeToFile:destinationPath atomically:YES];
//        NSLog(@"Success? %@", success?@"Yes":@"No");
    }
    
    return resizedImage;
}


- (void)checkForImageUpdateFromNotification:(NSNotification *)notification
{
    SCHBookIdentifier *bookIdentifier = [[notification userInfo] objectForKey:@"bookIdentifier"];
    if ([bookIdentifier isEqual:self.identifier]) {
        [self refreshBookCoverView];
    }
}	


@end
