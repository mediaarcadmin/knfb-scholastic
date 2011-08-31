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
#import "AppDelegate_Shared.h"
#import "SCHCoreDataHelper.h"

@interface SCHBookCoverView ()

- (void)initialiseView;
- (UIImage *)createImageWithSourcePath:(NSString *)sourcePath destinationPath:(NSString *)destinationPath;
- (void)resizeElementsForThumbSize: (CGSize) thumbSize;
- (void)deferredRefreshBookCoverView;

@property (nonatomic, retain) UIImageView *coverImageView;
@property (nonatomic, retain) NSString *currentImageName;
@property (nonatomic, retain) UIProgressView *progressView;
@property (nonatomic, retain) UIView *bookTintView;
@property (nonatomic, retain) UIImageView *isNewBadge;
@property (nonatomic, retain) UIImageView *errorBadge;
@property (nonatomic, retain) UIImageView *featureTab;
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
@synthesize isNewBadge;
@synthesize errorBadge;
@synthesize trashed;
@synthesize isNewBook;
@synthesize coalesceRefreshes;
@synthesize needsRefresh;
@synthesize showingPlaceholder;
@synthesize coverViewMode;
@synthesize loading;
@synthesize activitySpinner;
@synthesize featureTab;

#pragma mark - Initialisation and dealloc

- (void)dealloc 
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[identifier release], identifier = nil;
    [currentImageName release], currentImageName = nil;
    [coverImageView release], coverImageView = nil;
    [progressView release], progressView = nil;
    [bookTintView release], bookTintView = nil;
    [isNewBadge release], isNewBadge = nil;
    [errorBadge release], errorBadge = nil;
    [featureTab release], featureTab = nil;
    
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
    self.coverImageView = [[[UIImageView alloc] initWithFrame:self.frame] autorelease];
    self.coverImageView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7].CGColor;
    
    if (self.contentScaleFactor > 1) {
        self.coverImageView.layer.borderWidth = 0.5f;
    } else {
        self.coverImageView.layer.borderWidth = 1;
    }
    
    [self addSubview:self.coverImageView];

    // no scaling of the cover view
	self.coverImageView.contentMode = UIViewContentModeTopLeft;
    self.backgroundColor = [UIColor clearColor];

    // add the tint view
    self.bookTintView = [[[UIView alloc] initWithFrame:self.frame] autorelease];
    [self.bookTintView setBackgroundColor:[UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:0.6f]];
    [self addSubview:self.bookTintView];
    
    // add a progress view
    self.progressView = [[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault] autorelease];
    [self addSubview:self.progressView];
    self.progressView.hidden = YES;

    // feature tab - only for iPad!
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.featureTab = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BookSampleTab"]] autorelease];
        self.featureTab.hidden = YES;
        self.featureTab.contentMode = UIViewContentModeRight;
        [self addSubview:self.featureTab];
    }
    
    // add the new graphic view
    self.isNewBadge = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BookShelfNewIcon"]] autorelease];
    [self addSubview:self.isNewBadge];
    self.isNewBadge.hidden = YES;
    
    // placeholder
    self.showingPlaceholder = YES;
    
    // spinner
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.activitySpinner = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
    } else {
        self.activitySpinner = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
    }
    self.activitySpinner.hidesWhenStopped = YES;
    [self.activitySpinner stopAnimating];
    [self addSubview:self.activitySpinner];
    
    // add the error badge - on top of everything else
    self.errorBadge = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BookShelfErrorIcon"]] autorelease];
    [self addSubview:self.errorBadge];
    self.errorBadge.hidden = YES;
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SCHBookTextFlowParsePercentageUpdate" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SCHBookDownloadPercentageUpdate" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SCHBookStateUpdate" object:nil];
    
    SCHBookIdentifier *oldIdentifier = identifier;
    identifier = [newIdentifier retain];
    [oldIdentifier release];
    
    if (identifier) {
        self.hidden = NO;
        //SCHBookTextFlowParsePercentageUpdate
        //updateTextflowPercentage
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateTextflowPercentage:) 
                                                     name:@"SCHBookTextFlowParsePercentageUpdate" 
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateFileDownloadPercentage:) 
                                                     name:@"SCHBookDownloadPercentageUpdate" 
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(checkForImageUpdateFromNotification:)
                                                     name:@"SCHBookStateUpdate"
                                                   object:nil];
        self.coverImageView.image = nil;
        self.coverImageView.hidden = YES;
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
    
    AppDelegate_Shared *appDelegate = (AppDelegate_Shared *)[[UIApplication sharedApplication] delegate];    
    NSManagedObjectContext *context = appDelegate.coreDataHelper.managedObjectContext;
	SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.identifier inManagedObjectContext:context];    
    
    bookState = [book processingState];
    fullImagePath = [book coverImagePath];
    
    CGSize thumbSize = CGSizeMake(self.frame.size.width - (self.leftRightInset * 2), 
                                  self.frame.size.height - self.topInset);
    
    thumbPath = [book thumbPathForSize:thumbSize];
    
    if (bookState <= SCHBookProcessingStateNoCoverImage && 
        bookState != SCHBookProcessingStateUnableToAcquireLicense) {
        // book does not have a cover image downloaded 
        self.coverImageView.image = nil;
        self.coverImageView.hidden = YES;
        self.currentImageName = nil;
        self.showingPlaceholder = YES;
        self.needsRefresh = NO;
        [localIdentifier release];
        return;
    }
    
    // check to see if we're already using the right thumb image - if so, skip loading it
    if (self.currentImageName != nil && [self.currentImageName compare:thumbPath] == NSOrderedSame) {
//        NSLog(@"Already using the right thumbnail image.");
        // Using the correct image - just redo the user interface elements
        [self resizeElementsForThumbSize:self.coverImageView.frame.size];
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
                        self.coverImageView.hidden = NO;
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
                            self.coverImageView.hidden = NO;
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
    // fetch the book details
    AppDelegate_Shared *appDelegate = (AppDelegate_Shared *)[[UIApplication sharedApplication] delegate];    
    NSManagedObjectContext *context = appDelegate.coreDataHelper.managedObjectContext;
	SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.identifier inManagedObjectContext:context];    
    
    BOOL tabOnRight = YES;
    
    // resize and position the thumb image view - the image view should never scale, and should always
    // be set to an integer value for positioning to avoid blurring
    
    CGRect coverFrame = CGRectMake(floor((self.frame.size.width - thumbSize.width)/2), self.topInset, thumbSize.width, thumbSize.height);
    
    // if the thumb is not the full height of the view, then calculate differently
    // (cases where the thumb is wider than it is high)
    if (thumbSize.height != self.frame.size.height) {
        tabOnRight = NO;
        
        if (self.coverViewMode == SCHBookCoverViewModeGridView) {
            // cover is attached to the bottom of the frame
            coverFrame = CGRectMake(self.leftRightInset, self.frame.size.height - thumbSize.height, thumbSize.width, thumbSize.height);
        } else if (self.coverViewMode == SCHBookCoverViewModeListView) {
            // cover is centred in the frame
            coverFrame = CGRectMake(self.leftRightInset, floorf((self.frame.size.height - thumbSize.height)/2), thumbSize.width, thumbSize.height);
        }
    }
    
    self.coverImageView.frame = coverFrame;
    self.bookTintView.frame = coverFrame;
    self.activitySpinner.center = self.coverImageView.center;

    // move the new image view to the right spot, the bottom right hand corner
    CGPoint newCenter = CGPointMake(coverFrame.origin.x + coverFrame.size.width, 
                                    coverFrame.origin.y + coverFrame.size.height);
    
    if (self.coverViewMode == SCHBookCoverViewModeListView) {
        newCenter.y = coverFrame.origin.y + coverFrame.size.height - ceilf(self.isNewBadge.frame.size.height / 2) + 5;
    } else if (self.coverViewMode == SCHBookCoverViewModeGridView) {
        newCenter.y = coverFrame.origin.y + coverFrame.size.height - ceilf(self.isNewBadge.frame.size.height / 4);
    }
    
    // make sure the new badge isn't cut off
    if (newCenter.x + (self.isNewBadge.frame.size.width / 2) > self.frame.size.width) {
        float difference = newCenter.x + (self.isNewBadge.frame.size.width / 2) - self.frame.size.width;
        newCenter.x = coverFrame.origin.x + coverFrame.size.width - difference;
    }
    
    CGPoint errorCenter = newCenter;

    // make sure the error badge isn't cut off
    if (errorCenter.x + (self.errorBadge.frame.size.width / 2) > self.frame.size.width) {
        float difference = errorCenter.x + (self.errorBadge.frame.size.width / 2) - self.frame.size.width;
        errorCenter.x = coverFrame.origin.x + coverFrame.size.width - difference;
    }
    
    self.isNewBadge.center = newCenter;
    self.errorBadge.center = errorCenter;

    // resize and position the progress view
    NSLog(@"Progress view frame: %@", NSStringFromCGRect(self.progressView.frame));
    CGRect progressViewFrame = CGRectMake(coverFrame.origin.x + 10, self.isNewBadge.frame.origin.y - 10, coverFrame.size.width - 20, self.progressView.frame.size.height);
    self.progressView.frame = progressViewFrame;
    
    
	[self setNeedsDisplay];
    
	// book status
    if (self.trashed) {
        self.bookTintView.hidden = NO;
        self.progressView.hidden = YES;
    } else {
        switch ([book processingState]) {
            case SCHBookProcessingStateDownloadStarted:
                NSLog(@"Setting started.");
                self.progressView.alpha = 1.0f;
                self.bookTintView.hidden = NO;
                self.progressView.hidden = NO;
                self.errorBadge.hidden = YES;
                [self.progressView setProgress:[book currentDownloadedPercentage] * 0.8];            
                break;
            case SCHBookProcessingStateDownloadPaused:
                NSLog(@"Setting paused.");
                self.progressView.alpha = 0.75f;
                self.bookTintView.hidden = NO;
                self.progressView.hidden = NO;
                self.errorBadge.hidden = YES;
                [self.progressView setProgress:[book currentDownloadedPercentage] * 0.8];            
                break;
            case SCHBookProcessingStateReadyForLicenseAcquisition:
            case SCHBookProcessingStateReadyForRightsParsing:
            case SCHBookProcessingStateReadyForAudioInfoParsing:
            case SCHBookProcessingStateReadyForTextFlowPreParse:
                self.progressView.alpha = 1.0f;
                self.bookTintView.hidden = NO;
                self.progressView.hidden = NO;
                self.errorBadge.hidden = YES;
                [self.progressView setProgress:0.8];            
                break;
            case SCHBookProcessingStateReadyToRead:
                self.progressView.alpha = 1.0f;
                self.bookTintView.hidden = YES;
                self.progressView.hidden = YES;
                self.errorBadge.hidden = YES;
                break;
            case SCHBookProcessingStateError:
            case SCHBookProcessingStateDownloadFailed:
            case SCHBookProcessingStateURLsNotPopulated:
            case SCHBookProcessingStateUnableToAcquireLicense:
            case SCHBookProcessingStateBookVersionNotSupported:
                self.progressView.alpha = 1.0f;
                self.bookTintView.hidden = NO;
                self.progressView.hidden = YES;
                self.errorBadge.hidden = NO;
                break;
            case SCHBookProcessingStateReadyForSmartZoomPreParse:
            case SCHBookProcessingStateReadyForPagination:
            default:
                self.progressView.alpha = 1.0f;
                self.bookTintView.hidden = NO;
                self.progressView.hidden = YES;
                self.errorBadge.hidden = YES;
                break;
        }
    }	
    
    
    if (self.isNewBook && !self.trashed && self.errorBadge.hidden == YES) {
        self.isNewBadge.hidden = NO;
    } else {
        self.isNewBadge.hidden = YES;
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad 
        && self.coverViewMode == SCHBookCoverViewModeGridView) {
        
        // the offset amount that the image tab is over onto the cover
        NSInteger overhang = 0;
        // the size (width for right side, height for top side) of the tab
        NSInteger tabSize = 25;
        // whether to actually do the resizing work
        BOOL doSizing = YES;
        
        switch (book.bookFeatures) {
            case kSCHAppBookFeaturesNone:
            {
                self.featureTab.image = nil;
                self.featureTab.hidden = YES;
                doSizing = NO;
                break;
            }   
            case kSCHAppBookFeaturesStoryInteractions:
            {
                if (tabOnRight) {
                    self.featureTab.image = [UIImage imageNamed:@"BookSITab"];
                    overhang = 13;
                } else {
                    self.featureTab.image = [UIImage imageNamed:@"BookSITabHorizontal"];
                    overhang = 16;
                }
                
                break;
            }   
            case kSCHAppBookFeaturesSampleWithStoryInteractions:
            {
                if (tabOnRight) {
                    self.featureTab.image = [UIImage imageNamed:@"BookSISampleTab"];
                    overhang = 13;
                } else {
                    self.featureTab.image = [UIImage imageNamed:@"BookSISampleTabHorizontal"];
                    overhang = 15;
                }
                
                break;
            }   

            case kSCHAppBookFeaturesSample:
            {
                if (tabOnRight) {
                    self.featureTab.image = [UIImage imageNamed:@"BookSampleTab"];
                    overhang = 3;
               } else {
                    self.featureTab.image = [UIImage imageNamed:@"BookSampleTabHorizontal"];
                   overhang = 3;
                }
                
                break;
            }   
            default:
            {
                NSLog(@"Warning: unknown type for book features.");
                self.featureTab.image = nil;
                self.featureTab.hidden = YES;
                doSizing = NO;
                break;
            }
        }
        
        if (doSizing) {
            if (tabOnRight) {
                // move the tab to the right side of the cover
                self.featureTab.contentMode = UIViewContentModeRight;
                CGRect frame = self.featureTab.frame;
                frame.origin.x = coverFrame.origin.x + coverFrame.size.width + overhang;
                frame.origin.y = floorf(coverFrame.origin.y);
                frame.size.height = coverFrame.size.height;
                frame.size.width = tabSize;
                self.featureTab.frame = frame;
            } else {
                // move the tab across the top of the cover
                self.featureTab.contentMode = UIViewContentModeTop;
                CGRect frame = self.featureTab.frame;
                frame.origin.x = coverFrame.origin.x;
                frame.size.width = coverFrame.size.width;
                frame.size.height = tabSize;
                frame.origin.y = self.frame.size.height - coverFrame.size.height - frame.size.height - overhang;
                self.featureTab.frame = frame;
            }
            
            self.featureTab.hidden = NO;
        }
        
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
        
        if (width >= height) {
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
        float newPercentage = 0.8 * [(NSNumber *) [[notification userInfo] objectForKey:@"currentPercentage"] floatValue];
        [self.progressView setProgress:newPercentage];
        [self.progressView setHidden:NO];
    }
}

// listen for textflow progress
- (void)updateTextflowPercentage:(NSNotification *)notification
{
    SCHBookIdentifier *bookIdentifier = [[notification userInfo] objectForKey:@"bookIdentifier"];
    if ([bookIdentifier isEqual:self.identifier]) {
        float newPercentage = 0.8 + (0.2 * [(NSNumber *) [[notification userInfo] objectForKey:@"currentPercentage"] floatValue]);
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