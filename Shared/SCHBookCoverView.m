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
#import <ImageIO/ImageIO.h>

@interface SCHBookCoverView ()

- (void)initialiseView;
- (void)performWithBook:(void (^)(SCHAppBook *))block;
- (UIImage *)createImageWithSourcePath:(NSString *)sourcePath destinationPath:(NSString *)destinationPath;
- (void)resizeElementsForThumbSize: (CGSize) thumbSize;

@property (nonatomic, retain) UIImageView *coverImageView;
@property (nonatomic, retain) NSString *currentImageName;
@property (nonatomic, retain) UIProgressView *progressView;
@property (nonatomic, retain) UIView *bookTintView;
@property (nonatomic, retain) UIImageView *newBadge;

@end

@implementation SCHBookCoverView

@synthesize identifier;
@synthesize topInset;
@synthesize leftRightInset;

@synthesize coverImageView;
@synthesize currentImageName;
@synthesize progressView;
@synthesize bookTintView;
@synthesize newBadge;

- (void)dealloc 
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[identifier release], identifier = nil;
    [currentImageName release], currentImageName = nil;
    [coverImageView release], coverImageView = nil;
    [progressView release], progressView = nil;
    [bookTintView release], bookTintView = nil;
    [newBadge release], newBadge = nil;
    
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
    self.identifier = nil;
}

- (void)initialiseView 
{
    // add the image view
    self.coverImageView = [[UIImageView alloc] initWithFrame:self.frame];
    [self addSubview:coverImageView];

    // no scaling of the cover view
	self.coverImageView.contentMode = UIViewContentModeTopLeft;
	self.clipsToBounds = YES;
    self.backgroundColor = [UIColor clearColor];

    // add the tint view
    self.bookTintView = [[UIView alloc] initWithFrame:self.frame];
    [self.bookTintView setBackgroundColor:[UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:0.6f]];
    [self addSubview:self.bookTintView];
    
    // add a progress view
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    [self addSubview:self.progressView];
    
//    // add the new graphic view
//    self.newBadge = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""
    
    
}

- (void)setIdentifier:(SCHBookIdentifier *)newIdentifier
{
//	if ([newIdentifier isEqual:identifier]) {
//        return;
//    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SCHBookDownloadPercentageUpdate" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SCHBookStateUpdate" object:nil];
    
    [identifier release];
    identifier = [newIdentifier retain];
    
    if (identifier) {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateFileDownloadPercentage:) 
                                                 name:@"SCHBookDownloadPercentageUpdate" 
                                               object:nil];
    
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(checkForImageUpdateFromNotification:)
                                                     name:@"SCHBookStateUpdate"
                                                   object:nil];
    }
    
    self.coverImageView.image = nil;
    self.currentImageName = nil;
    
    [self refreshBookCoverView];

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
    // if no identifier has been set, then we don't need to refresh the image
    if (!self.identifier) {
        return;
    }

    SCHBookIdentifier *localIdentifier = [self.identifier copy];

    // fetch book state and filename information
    __block NSString *fullImagePath;
    __block NSString *thumbPath;
    __block SCHBookCurrentProcessingState bookState;
    [self performWithBook:^(SCHAppBook *book) {
        //        NSLog(@"Getting book information.");
        bookState = [book processingState];
        fullImagePath = [[book coverImagePath] retain];
        thumbPath = [[book thumbPathForSize:CGSizeMake(self.frame.size.width - (self.leftRightInset * 2), self.frame.size.height - self.topInset)] retain];
    }];
    
    if (bookState <= SCHBookProcessingStateNoCoverImage) {
        // book does not have a cover image downloaded 
        self.coverImageView.image = nil;
        self.currentImageName = nil;
        return;
    }
    
    // check to see if we're already using the right thumb image - if so, skip loading it
    if (self.currentImageName != nil && [self.currentImageName compare:thumbPath] == NSOrderedSame) {
//        NSLog(@"Already using the right thumbnail image.");
    } else {
        NSFileManager *threadLocalFileManager = [[[NSFileManager alloc] init] autorelease];
        
        // check to see if we have the thumb already cached
        if ([threadLocalFileManager fileExistsAtPath:thumbPath]) {
            // load the cached image
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                [thumbPath retain];
                UIImage *thumbImage = [UIImage imageWithContentsOfFile:thumbPath];
                self.currentImageName = thumbPath;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    // check if identifier changed while the thumb was loading
                    if ([self.identifier isEqual:localIdentifier]) {
                        self.coverImageView.image = thumbImage;
                        [self resizeElementsForThumbSize:thumbImage.size];
                    }
                });
                
                [thumbPath release];
            });
            
        } else {
            // dispatch the thumbnail operation
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [fullImagePath retain];
                [thumbPath retain];

                // if the identifier changes, don't process the thumbnail
                if ([self.identifier isEqual:localIdentifier]) {
                    
                    UIImage *thumbImage = nil;
                    [NSThread sleepForTimeInterval:5];
                    
                    // check if the thumb has been created while queued
                    if ([threadLocalFileManager fileExistsAtPath:thumbPath]) {
                        thumbImage = [UIImage imageWithContentsOfFile:thumbPath];
                        self.currentImageName = thumbPath;
                    } else {
                        thumbImage = [self createImageWithSourcePath:fullImagePath destinationPath:thumbPath];
                        self.currentImageName = thumbPath;
                    }
                    
                    [fullImagePath release];
                    [thumbPath release];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // set the thumbnail
                        
                        // first check if the identifier has changed; if so, don't set the processed thumbnail
                        if ([self.identifier isEqual:localIdentifier]) {
                            self.coverImageView.image = thumbImage;
                            [self resizeElementsForThumbSize:thumbImage.size];
                        }
                    });
                }
            });
        }
        
//        [fullImagePath release];
//        [thumbPath release];
    }
    
    [localIdentifier release];
}

- (void)resizeElementsForThumbSize: (CGSize) thumbSize
{
    // resize and position the thumb image view - the image view should never scale, and should always
    // be set to an integer value for positioning to avoid blurring
    
    CGRect coverFrame = CGRectMake(floor((self.frame.size.width - thumbSize.width)/2), self.topInset, thumbSize.width, thumbSize.height);
    
    if (thumbSize.width + (self.leftRightInset * 2) == self.frame.size.width) {
        coverFrame = CGRectMake(self.leftRightInset, self.frame.size.height - thumbSize.height, thumbSize.width, thumbSize.height);
    }
    
    self.coverImageView.frame = coverFrame;
    self.bookTintView.frame = coverFrame;
    
    // resize and position the progress view
    CGRect progressViewFrame = CGRectMake(10 + leftRightInset, self.frame.size.height - 32, self.frame.size.width - (leftRightInset * 2) - 20, 10);
    NSLog(@"Progress view frame: %@", NSStringFromCGRect(progressViewFrame));
    self.progressView.frame = progressViewFrame;

}

- (UIImage *)createImageWithSourcePath:(NSString *)sourcePath destinationPath:(NSString *)destinationPath 
{
    __block UIImage *resizedImage = nil;
    
    dispatch_sync([SCHProcessingManager sharedProcessingManager].thumbnailAccessQueue, ^{

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
        
        CGSize frameSizeWithInsets = CGSizeMake(self.frame.size.width - (self.leftRightInset * 2), 
                                                self.frame.size.height - self.topInset);
        
        CGFloat scale = 1.0f;
        
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
            scale = [[UIScreen mainScreen] scale];
            frameSizeWithInsets = CGSizeApplyAffineTransform(frameSizeWithInsets, CGAffineTransformMakeScale(scale, scale));
        }
        
        NSInteger maxDimension = frameSizeWithInsets.height;
        
        if (width > height) {
            maxDimension = frameSizeWithInsets.width;
        }
        
        
        NSDictionary* d = [NSDictionary dictionaryWithObjectsAndKeys:
                           (id)kCFBooleanFalse, kCGImageSourceShouldAllowFloat,
                           (id)kCFBooleanTrue, kCGImageSourceCreateThumbnailWithTransform,
                           (id)kCFBooleanTrue, kCGImageSourceCreateThumbnailFromImageAlways,
                           [NSNumber numberWithInt:maxDimension], kCGImageSourceThumbnailMaxPixelSize,
                           nil];
        
        CGImageRef thumbnailRef = CGImageSourceCreateThumbnailAtIndex(src, 0, (CFDictionaryRef) d);
        
        resizedImage = [[UIImage alloc] initWithCGImage:thumbnailRef scale:scale orientation:UIImageOrientationUp];
        
        CGImageRelease(thumbnailRef);
        CFRelease(src);
        
        if (resizedImage) {
            NSData *pngData = UIImagePNGRepresentation(resizedImage);
            [pngData writeToFile:destinationPath atomically:YES];
//        NSLog(@"Success? %@", success?@"Yes":@"No");
        }
        
    });

    return resizedImage;
}

// listen for file download progress
- (void)updateFileDownloadPercentage:(NSNotification *)notification
{
    SCHBookIdentifier *bookIdentifier = [[notification userInfo] objectForKey:@"bookIdentifier"];
    if ([bookIdentifier isEqual:self.identifier]) {
//        float newPercentage = [(NSNumber *) [[notification userInfo] objectForKey:@"currentPercentage"] floatValue];
//        [self.progressView setProgress:newPercentage];
        [self.progressView setHidden:NO];
    }
}


// this method listens for updates to book state
- (void)checkForImageUpdateFromNotification:(NSNotification *)notification
{
    SCHBookIdentifier *bookIdentifier = [[notification userInfo] objectForKey:@"bookIdentifier"];
    if ([bookIdentifier isEqual:self.identifier]) {
        [self refreshBookCoverView];
    }
}	


@end
