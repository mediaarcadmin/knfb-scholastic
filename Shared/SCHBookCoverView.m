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
#import <QuartzCore/QuartzCore.h>

@interface SCHBookCoverView ()

- (void)initialiseView;
- (UIImage *)createImageWithSourcePath:(NSString *)sourcePath destinationPath:(NSString *)destinationPath;
- (void)resizeElementsForThumbSize: (CGSize) thumbSize;
- (void)deferredRefreshBookCoverView;

@property (nonatomic, retain) UIImageView *coverImageView;
@property (nonatomic, retain) NSString *currentImageName;
@property (nonatomic, retain) UIProgressView *progressView;
@property (nonatomic, retain) UIView *bookTintView;
@property (nonatomic, retain) UIImageView *newBadge;
@property (nonatomic, retain) UIImageView *errorBadge;
@property (nonatomic, retain) UIActivityIndicatorView *activitySpinner;

@property (nonatomic, assign) BOOL coalesceRefreshes;
@property (nonatomic, assign) BOOL needsRefresh;
@property (nonatomic, assign) BOOL showingPlaceholder;

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
@synthesize errorBadge;
@synthesize trashed;
@synthesize isNewBook;
@synthesize coalesceRefreshes;
@synthesize needsRefresh;
@synthesize showingPlaceholder;
@synthesize coverViewMode;
@synthesize loading;
@synthesize activitySpinner;

#pragma mark - Initialisation and dealloc

- (void)dealloc 
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[identifier release], identifier = nil;
    [currentImageName release], currentImageName = nil;
    [coverImageView release], coverImageView = nil;
    [progressView release], progressView = nil;
    [bookTintView release], bookTintView = nil;
    [newBadge release], newBadge = nil;
    [errorBadge release], errorBadge = nil;
    
    
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

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
	if (self) {
		[self initialiseView];
	}
    
	return self;
}

- (void)initialiseView 
{
    // add the image view
    self.coverImageView = [[UIImageView alloc] initWithFrame:self.frame];
    self.coverImageView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3].CGColor;
    self.coverImageView.layer.borderWidth = 1;
    [self addSubview:self.coverImageView];

    // no scaling of the cover view
	self.coverImageView.contentMode = UIViewContentModeTopLeft;
    self.backgroundColor = [UIColor clearColor];

    // add the tint view
    self.bookTintView = [[UIView alloc] initWithFrame:self.frame];
    [self.bookTintView setBackgroundColor:[UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:0.6f]];
    [self addSubview:self.bookTintView];
    
    // add a progress view
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    [self addSubview:self.progressView];
    self.progressView.hidden = YES;
    
    // add the new graphic view
    self.newBadge = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BookShelfNewIcon"]];
    [self addSubview:self.newBadge];
    self.newBadge.hidden = YES;
    
    // add the error badge
    // FIXME: change this to the correct graphic.
    self.errorBadge = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BookShelfErrorIcon"]];
    [self addSubview:self.errorBadge];
    self.errorBadge.hidden = YES;
    
    // placeholder
    self.showingPlaceholder = YES;
    
    // spinner
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.activitySpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    } else {
        self.activitySpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    self.activitySpinner.hidesWhenStopped = YES;
    [self.activitySpinner stopAnimating];
    [self addSubview:self.activitySpinner];
}

#pragma mark - cell reuse and setters

- (void)prepareForReuse
{
    self.identifier = nil;
}

- (void)setShowingPlaceholder:(BOOL)newShowingPlaceholder
{
    if (showingPlaceholder != newShowingPlaceholder) {
        [self setNeedsDisplay];
    }
    
    showingPlaceholder = newShowingPlaceholder;
    self.bookTintView.hidden = newShowingPlaceholder;
    self.coverImageView.hidden = newShowingPlaceholder;
}

- (void)setIdentifier:(SCHBookIdentifier *)newIdentifier
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SCHBookDownloadPercentageUpdate" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SCHBookStateUpdate" object:nil];
    
    SCHBookIdentifier *oldIdentifier = identifier;
    identifier = [newIdentifier retain];
    [oldIdentifier release];
    
    if (identifier) {
        self.hidden = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateFileDownloadPercentage:) 
                                                     name:@"SCHBookDownloadPercentageUpdate" 
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(checkForImageUpdateFromNotification:)
                                                     name:@"SCHBookStateUpdate"
                                                   object:nil];
        self.coverImageView.image = nil;
        self.currentImageName = nil;
        
        [self refreshBookCoverView];
    } else {
        // if we have no identifier, just hide ourselves until we do
        self.hidden = YES;
    }
}

- (void)setNeedsDisplay
{
    [super setNeedsDisplay];
}

- (void)setTrashed:(BOOL)newTrashed
{
    trashed = newTrashed;
    [self refreshBookCoverView];
}

- (void)setIsNewBook:(BOOL)newIsNewBook
{
    isNewBook = newIsNewBook;
    [self refreshBookCoverView];
}

- (void)setLoading:(BOOL)newLoading
{
    loading = newLoading;
    if (self.loading) {
        [self.activitySpinner startAnimating];
    } else {
        [self.activitySpinner stopAnimating];
    }
}

#pragma mark - Drawing and positioning methods

- (void)drawRect:(CGRect)rect
{
    if (self.showingPlaceholder) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSaveGState(context);

        CGFloat radius = 0;
        CGFloat inset = 0;
        NSInteger lineWidth = 0;
        
        switch (self.coverViewMode) {
            case SCHBookCoverViewModeListView:
            {
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                    lineWidth = 4;
                    radius = 6.0f;
                    inset = 4.0f;
                } else {
                    lineWidth = 4;
                    radius = 8.0f;
                    inset = 10.0f;
                }
                break;
            }
                
            case SCHBookCoverViewModeGridView:
            default:
            {
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                    lineWidth = 8;
                    radius = 6.0f;
                    inset = 4.0f;
                } else {
                    lineWidth = 8;
                    radius = 8.0f;
                    inset = 10.0f;
                }
                break;
            }
        }
        
        CGRect boundsRect = CGRectInset(rect, inset, inset);

        CGFloat pathLength = (boundsRect.size.width * 2 + boundsRect.size.height * 2 - radius * 8) + (2 * M_PI * radius);
        CGFloat dashLength = pathLength / 24;
        
//        NSLog(@"Rect length: %f Path length: %f Dash length: %f", (boundsRect.size.width * 2) + (boundsRect.size.height * 2),pathLength, dashLength);
        
        CGFloat kDashLengths[2] = { dashLength, dashLength };

        if (self.coverViewMode == SCHBookCoverViewModeGridView) {
            CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.4].CGColor);
        } else {
            CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.071 green:0.467 blue:0.643 alpha:0.4].CGColor);
        }
        CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);

        UIBezierPath *bezPath = [UIBezierPath bezierPathWithRoundedRect:boundsRect cornerRadius:radius];
        [bezPath setLineWidth:lineWidth];
        [bezPath setLineDash:kDashLengths count:2 phase:0];
        [bezPath stroke];    

        CGContextRestoreGState(context);
    }
}

- (void)beginUpdates
{
    self.coalesceRefreshes = YES;
}

- (void)endUpdates
{
    self.coalesceRefreshes = NO;
    if (self.needsRefresh) {
        [self deferredRefreshBookCoverView];
    }
}

- (void)refreshBookCoverView
{
    if (self.coalesceRefreshes) {
        self.needsRefresh = YES;
    } else {
        [self deferredRefreshBookCoverView];
    }
}

- (void)deferredRefreshBookCoverView
{
    NSLog(@"Actual refresh for %@", self.identifier);
    // if no identifier has been set, then we don't need to refresh the image
    if (!self.identifier) {
        self.showingPlaceholder = YES;
        self.needsRefresh = NO;
        return;
    }

    SCHBookIdentifier *localIdentifier = [self.identifier copy];

    // fetch book state and filename information
    NSString *fullImagePath;
    NSString *thumbPath;
    SCHBookCurrentProcessingState bookState;
    
    NSManagedObjectContext *context = [(id)[[UIApplication sharedApplication] delegate] managedObjectContext];
	SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.identifier inManagedObjectContext:context];    
    
    bookState = [book processingState];
    fullImagePath = [book coverImagePath];
    thumbPath = [book thumbPathForSize:CGSizeMake(self.frame.size.width - (self.leftRightInset * 2), self.frame.size.height - self.topInset)];
    
    if (bookState <= SCHBookProcessingStateNoCoverImage) {
        // book does not have a cover image downloaded 
        self.coverImageView.image = nil;
        self.currentImageName = nil;
        self.showingPlaceholder = YES;
        self.needsRefresh = NO;
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

                UIImage *thumbImage = [UIImage imageWithContentsOfFile:thumbPath];
                self.currentImageName = thumbPath;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    // check if identifier changed while the thumb was loading
                    if ([self.identifier isEqual:localIdentifier]) {
                        self.coverImageView.image = thumbImage;
                        self.showingPlaceholder = NO;
                        [self resizeElementsForThumbSize:thumbImage.size];
                    }
                });
                
            });
            
        } else {
            // dispatch the thumbnail operation
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

                // if the identifier changes, don't process the thumbnail
                if ([self.identifier isEqual:localIdentifier]) {
                    
                    UIImage *thumbImage = nil;
                    
                    // check if the thumb has been created while queued
                    if ([threadLocalFileManager fileExistsAtPath:thumbPath]) {
                        thumbImage = [UIImage imageWithContentsOfFile:thumbPath];
                        self.currentImageName = thumbPath;
                    } else {
                        thumbImage = [self createImageWithSourcePath:fullImagePath destinationPath:thumbPath];
                        self.currentImageName = thumbPath;
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // set the thumbnail
                        
                        // first check if the identifier has changed; if so, don't set the processed thumbnail
                        if ([self.identifier isEqual:localIdentifier]) {
                            self.coverImageView.image = thumbImage;
                            self.showingPlaceholder = NO;
                            [self resizeElementsForThumbSize:thumbImage.size];
                        }
                    });
                }
            });
        }
    }
    
    [localIdentifier release];
    self.needsRefresh = NO;

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
    self.activitySpinner.center = self.coverImageView.center;

    // resize and position the progress view
    CGRect progressViewFrame = CGRectMake(10 + leftRightInset, self.frame.size.height - 32, self.frame.size.width - (leftRightInset * 2) - 20, 10);
    self.progressView.frame = progressViewFrame;
    
    // move the new image view to the right spot, the bottom right hand corner
    CGPoint newCenter = CGPointMake(coverFrame.origin.x + coverFrame.size.width, 
                                    coverFrame.origin.y + coverFrame.size.height);
    
    if (self.coverViewMode == SCHBookCoverViewModeListView) {
        newCenter.y = coverFrame.origin.y + coverFrame.size.height - ceilf(self.newBadge.frame.size.height / 2) + 5;
    } else if (self.coverViewMode == SCHBookCoverViewModeGridView) {
        newCenter.y = coverFrame.origin.y + coverFrame.size.height - ceilf(self.newBadge.frame.size.height / 4);
    }
    
    // make sure the badge isn't cut off
    if (newCenter.x + (self.newBadge.frame.size.width / 2) > self.frame.size.width) {
        float difference = newCenter.x + (self.newBadge.frame.size.width / 2) - self.frame.size.width;
        newCenter.x = coverFrame.origin.x + coverFrame.size.width - difference;
    }
    
//    // in list view, check y as well
////    if (self.coverViewMode == SCHBookCoverViewModeListView) {
//        if (newCenter.y + (self.newBadge.frame.size.height / 2) > self.frame.size.height) {
//            float difference = newCenter.y + (self.newBadge.frame.size.height / 2) - self.frame.size.height;
//            newCenter.y = coverFrame.origin.y + coverFrame.size.height - difference;
//        }
////    }
    
    self.newBadge.center = newCenter;
    
    
    // move the error badge to the centre of the cover
    CGPoint errorCenter = CGPointMake(floorf(CGRectGetMidX(coverFrame)), floorf(CGRectGetMidY(coverFrame)));
    self.errorBadge.center = errorCenter;
    
    NSManagedObjectContext *context = [(id)[[UIApplication sharedApplication] delegate] managedObjectContext];
	SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.identifier inManagedObjectContext:context];    
    
	[self setNeedsDisplay];
    
	// book status
    if (self.trashed) {
        self.bookTintView.hidden = NO;
        self.progressView.hidden = YES;
    } else {
        switch ([book processingState]) {
            case SCHBookProcessingStateDownloadStarted:
            case SCHBookProcessingStateDownloadPaused:
                self.bookTintView.hidden = NO;
                self.progressView.hidden = NO;
                self.errorBadge.hidden = YES;
                [self.progressView setProgress:[book currentDownloadedPercentage]];            
                break;
            case SCHBookProcessingStateReadyToRead:
                self.bookTintView.hidden = YES;
                self.progressView.hidden = YES;
                self.errorBadge.hidden = YES;
                break;
            case SCHBookProcessingStateError:
            case SCHBookProcessingStateDownloadFailed:
            case SCHBookProcessingStateURLsNotPopulated:
            case SCHBookProcessingStateUnableToAcquireLicense:
            case SCHBookProcessingStateBookVersionNotSupported:
                self.bookTintView.hidden = NO;
                self.progressView.hidden = YES;
                self.errorBadge.hidden = NO;
                break;
            default:
                self.bookTintView.hidden = NO;
                self.progressView.hidden = YES;
                self.errorBadge.hidden = YES;
                break;
        }
    }	
    
    if (self.isNewBook && !self.trashed) {
        self.newBadge.hidden = NO;
    } else {
        self.newBadge.hidden = YES;
    }

}

#pragma mark - Thumbnail Creation

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
        }

    });
    
    return resizedImage;
}

#pragma mark - Notification Methods

// listen for file download progress
- (void)updateFileDownloadPercentage:(NSNotification *)notification
{
    SCHBookIdentifier *bookIdentifier = [[notification userInfo] objectForKey:@"bookIdentifier"];
    if ([bookIdentifier isEqual:self.identifier]) {
        float newPercentage = [(NSNumber *) [[notification userInfo] objectForKey:@"currentPercentage"] floatValue];
        [self.progressView setProgress:newPercentage];
        [self.progressView setHidden:NO];
    }
}


// this method listens for updates to book state
- (void)checkForImageUpdateFromNotification:(NSNotification *)notification
{
    SCHBookIdentifier *bookIdentifier = [[notification userInfo] objectForKey:@"bookIdentifier"];
    if ([bookIdentifier isEqual:self.identifier]) {
        [self deferredRefreshBookCoverView];
    }
}	


@end
