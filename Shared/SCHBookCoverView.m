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
#import "UIImage+ScholasticAdditions.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate_Shared.h"
#import "SCHCoreDataHelper.h"
#import <ImageIO/ImageIO.h>

@interface SCHBookCoverView ()

- (void)initialiseView;
- (UIImage *)createImageWithSourcePath:(NSString *)sourcePath destinationPath:(NSString *)destinationPath;
- (void)updateCachedImage:(UIImage *)thumbImage atPath:(NSString *)thumbPath forIdentifier:(SCHBookIdentifier *)localIdentifier;
- (void)updateCachedImage:(UIImage *)thumbImage atPath:(NSString *)thumbPath forIdentifier:(SCHBookIdentifier *)localIdentifier waitUntilDone:(BOOL)wait;
- (void)resizeElementsForThumbSize: (CGSize) thumbSize;
- (void)deferredRefreshBookCoverView;
- (void)cachedImageFailureForBookIdentifier:(SCHBookIdentifier *)identifier;

- (void)setFeatureTabHidden:(BOOL)newHidden;
- (void)setErrorBadgeHidden:(BOOL)newHidden;
- (void)setIsNewBadgeHidden:(BOOL)newHidden;

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
@synthesize isNewBook;
@synthesize disabledForInteractions;
@synthesize coalesceRefreshes;
@synthesize needsRefresh;
@synthesize showingPlaceholder;
@synthesize coverViewMode;
@synthesize loading;
@synthesize activitySpinner;
@synthesize featureTab;
@synthesize shouldWaitForExistingCachedThumbToLoad;
@synthesize hideElementsForRatings;

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
        [self setFeatureTabHidden:YES];
        self.featureTab.contentMode = UIViewContentModeRight;
        [self addSubview:self.featureTab];
    }
    
    // add the new graphic view
    self.isNewBadge = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BookShelfNewIcon"]] autorelease];
    [self addSubview:self.isNewBadge];
    [self setIsNewBadgeHidden:YES];
    
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
    [self setErrorBadgeHidden:YES];
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

- (void)setIsNewBook:(BOOL)newIsNewBook
{
    isNewBook = newIsNewBook;
    [self refreshBookCoverView];
}

- (void)setHideElementsForRatings:(BOOL)newHideElementsForRatings
{
    hideElementsForRatings = newHideElementsForRatings;
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

- (void)setFeatureTabHidden:(BOOL)newHidden
{
    if (self.hideElementsForRatings) {
        self.featureTab.hidden = YES;
    } else {
        self.featureTab.hidden = newHidden;
    }
}

- (void)setErrorBadgeHidden:(BOOL)newHidden
{
    if (self.hideElementsForRatings) {
        self.errorBadge.hidden = YES;
    } else {
        self.errorBadge.hidden = newHidden;
    }
}

- (void)setIsNewBadgeHidden:(BOOL)newHidden
{
    if (self.hideElementsForRatings) {
        self.isNewBadge.hidden = YES;
    } else {
        self.isNewBadge.hidden = newHidden;
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

- (void)cachedImageFailureForBookIdentifier:(SCHBookIdentifier *)anIdentifier
{
    NSAssert([NSThread isMainThread] == YES, @"cachedImageFailureForBookIdentifier MUST be executed on the main thread");
    
    AppDelegate_Shared *appDelegate = (AppDelegate_Shared *)[[UIApplication sharedApplication] delegate];    
    NSManagedObjectContext *context = appDelegate.coreDataHelper.managedObjectContext;
    
    SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:anIdentifier inManagedObjectContext:context];
    
    // Nuclear option, delete the locally stored files
    [book setBookCoverExists:[NSNumber numberWithBool:NO]];
    [book setXPSExists:[NSNumber numberWithBool:NO]];
    [book.ContentMetadataItem deleteXPSFile];
    [book.ContentMetadataItem deleteCoverFile];
    
    [book setProcessingState:SCHBookProcessingStateCachedCoverError];
    
    NSError *error;
    
    if (![context save:&error]) {
        NSLog(@"Failed to save book after cachedImageFailureForBookIdentifier: %@", anIdentifier);
    }

    [self deferredRefreshBookCoverView];
}

- (void)deferredRefreshBookCoverView
{
    // if no identifier has been set, then we don't need to refresh the image
    if (!self.identifier) {
        NSLog(@"%p: Clearing identifier.", self);
        self.showingPlaceholder = YES;
        self.needsRefresh = NO;
        return;
    }

    //NSLog(@"%p:\tActual refresh for %@", self, self.identifier);
    
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
    
    if ([book.BookCoverExists boolValue] == NO || (bookState <= SCHBookProcessingStateNoCoverImage && 
                                                    bookState != SCHBookProcessingStateUnableToAcquireLicense &&
                                                    [book.BookCoverExists boolValue] == NO)) {
        // book does not have a cover image downloaded 
        self.coverImageView.image = nil;
        self.coverImageView.hidden = YES;
        self.currentImageName = nil;
        self.showingPlaceholder = YES;
        [self setFeatureTabHidden:YES];
        self.needsRefresh = NO;
        self.activitySpinner.center = [self.superview convertPoint:self.center toView:self];
        self.errorBadge.center = [self.superview convertPoint:self.center toView:self];
        
        // deal with the centre points potentially not being rounded
        CGRect spinnerFrame = self.activitySpinner.frame;
        spinnerFrame.origin.x = floorf(spinnerFrame.origin.x);
        spinnerFrame.origin.y = floorf(spinnerFrame.origin.y);
        self.activitySpinner.frame = spinnerFrame;
        
        CGRect errorFrame = self.errorBadge.frame;
        errorFrame.origin.x = floorf(errorFrame.origin.x);
        errorFrame.origin.y = floorf(errorFrame.origin.y);
        self.errorBadge.frame = errorFrame;

        [self setErrorBadgeHidden:YES];
        [self setIsNewBadgeHidden:YES];
        self.progressView.hidden = YES;
        
        if (bookState >= SCHBookProcessingStateNoURLs) {
            [self.activitySpinner startAnimating];
        }
        
        switch (bookState) {
            case SCHBookProcessingStateURLsNotPopulated:
            case SCHBookProcessingStateDownloadFailed:
            case SCHBookProcessingStateUnableToAcquireLicense:
            case SCHBookProcessingStateCachedCoverError:
            case SCHBookProcessingStateError:
            case SCHBookProcessingStateBookVersionNotSupported:
                [self.activitySpinner stopAnimating];
                [self setErrorBadgeHidden:NO];
                break;
            case SCHBookProcessingStateReadyToRead:
                // Something has gone severely wrong, we have no book cover and yet the book is ready to read
                [self.activitySpinner stopAnimating];
                dispatch_async(dispatch_get_main_queue(), ^{  
                    [self cachedImageFailureForBookIdentifier:localIdentifier];
                });
                break;
            default:
                break;
        }
        
        [localIdentifier release];
        return;
    } else {
        [self.activitySpinner stopAnimating];
    }
    
    // check to see if we're already using the right thumb image - if so, skip loading it
    if (self.currentImageName != nil && [self.currentImageName compare:thumbPath] == NSOrderedSame) {
//        NSLog(@"Already using the right thumbnail image.");
        // Using the correct image - just redo the user interface elements
        [self resizeElementsForThumbSize:self.coverImageView.frame.size];
    } else {
        
        BOOL successfullyLoaded = NO;
        
        if (self.shouldWaitForExistingCachedThumbToLoad) {
            NSFileManager *threadLocalFileManager = [[[NSFileManager alloc] init] autorelease];
            if ([threadLocalFileManager fileExistsAtPath:thumbPath]) {
                UIImage *thumbImage = [UIImage imageWithContentsOfFile:thumbPath];
                [self updateCachedImage:thumbImage atPath:thumbPath forIdentifier:localIdentifier waitUntilDone:YES];
                successfullyLoaded = YES;
            }
        }
        
        if (!successfullyLoaded) {
            dispatch_async([SCHProcessingManager sharedProcessingManager].thumbnailAccessQueue, ^{
                
                NSFileManager *threadLocalFileManager = [[[NSFileManager alloc] init] autorelease];
                
                // check to see if we have the thumb already cached
                if ([threadLocalFileManager fileExistsAtPath:thumbPath]) {
                    UIImage *thumbImage = [UIImage imageWithContentsOfFile:thumbPath];
                    [self updateCachedImage:thumbImage atPath:thumbPath forIdentifier:localIdentifier];
                } else {
                    UIImage *thumbImage = [self createImageWithSourcePath:fullImagePath destinationPath:thumbPath];
                    [self updateCachedImage:thumbImage atPath:thumbPath forIdentifier:localIdentifier];
                }
            });
        }
        
        self.shouldWaitForExistingCachedThumbToLoad = NO;
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
    
    CGRect coverFrame = CGRectMake(floor((self.frame.size.width - thumbSize.width)/2), floorf(self.frame.size.height - thumbSize.height), thumbSize.width, thumbSize.height);
    
    // if the thumb is not the full height of the view, then calculate differently
    // (cases where the thumb is wider than it is high)
    if (thumbSize.height < thumbSize.width) {
        tabOnRight = NO;
        
        if (self.coverViewMode == SCHBookCoverViewModeGridView) {
            // cover is attached to the bottom of the frame
            coverFrame = CGRectMake(floorf((self.frame.size.width - thumbSize.width)/2), self.frame.size.height - thumbSize.height, thumbSize.width, thumbSize.height);
        } else if (self.coverViewMode == SCHBookCoverViewModeListView) {
            // cover is centred in the frame
            coverFrame = CGRectMake(floorf((self.frame.size.width - thumbSize.width)/2), floorf((self.frame.size.height - thumbSize.height)/2), thumbSize.width, thumbSize.height);
        }
    }
    
    self.coverImageView.frame = coverFrame;
    self.bookTintView.frame = coverFrame;
    self.activitySpinner.center = self.coverImageView.center;
    
    // deal with the centre point potentially not being rounded
    CGRect spinnerFrame = self.activitySpinner.frame;
    spinnerFrame.origin.x = floorf(spinnerFrame.origin.x);
    spinnerFrame.origin.y = floorf(spinnerFrame.origin.y);
    self.activitySpinner.frame = spinnerFrame;


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
    
    // move the new badge if the tab is Sample with Story Interactions
    if (tabOnRight && book.bookFeatures == kSCHAppBookFeaturesSampleWithStoryInteractions) {
        newCenter.x -= 8;
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
//    NSLog(@"Progress view frame: %@", NSStringFromCGRect(self.progressView.frame));
    CGRect progressViewFrame = CGRectMake(coverFrame.origin.x + 10, self.isNewBadge.frame.origin.y - 10, coverFrame.size.width - 20, self.progressView.frame.size.height);
    self.progressView.frame = progressViewFrame;
    
    
	[self setNeedsDisplay];
    
	// book status
    switch ([book processingState]) {
        case SCHBookProcessingStateDownloadStarted:
            NSLog(@"Setting started.");
            self.progressView.alpha = 1.0f;
            self.bookTintView.hidden = NO;
            self.progressView.hidden = NO;
            [self setErrorBadgeHidden:YES];
            [self.progressView setProgress:[book currentDownloadedPercentage] * 0.8];            
            break;
        case SCHBookProcessingStateDownloadPaused:
            NSLog(@"Setting paused.");
            self.progressView.alpha = 0.0f;
            self.bookTintView.hidden = NO;
            self.progressView.hidden = NO;
            [self setErrorBadgeHidden:YES];
            [self.progressView setProgress:[book currentDownloadedPercentage] * 0.8];            
            break;
        case SCHBookProcessingStateReadyForLicenseAcquisition:
        case SCHBookProcessingStateReadyForRightsParsing:
        case SCHBookProcessingStateReadyForAudioInfoParsing:
        case SCHBookProcessingStateReadyForTextFlowPreParse:
            self.progressView.alpha = 1.0f;
            self.bookTintView.hidden = NO;
            self.progressView.hidden = NO;
            [self setErrorBadgeHidden:YES];
            [self.progressView setProgress:0.8];            
            break;
        case SCHBookProcessingStateReadyToRead:
            self.progressView.alpha = 1.0f;
            self.bookTintView.hidden = YES;
            self.progressView.hidden = YES;
            [self setErrorBadgeHidden:YES];
            break;
        case SCHBookProcessingStateError:
        case SCHBookProcessingStateDownloadFailed:
        case SCHBookProcessingStateURLsNotPopulated:
        case SCHBookProcessingStateUnableToAcquireLicense:
        case SCHBookProcessingStateCachedCoverError:
        case SCHBookProcessingStateBookVersionNotSupported:
            self.progressView.alpha = 1.0f;
            self.bookTintView.hidden = NO;
            self.progressView.hidden = YES;
            [self setErrorBadgeHidden:NO];
            break;
        case SCHBookProcessingStateReadyForSmartZoomPreParse:
        case SCHBookProcessingStateReadyForPagination:
        default:
            self.progressView.alpha = 1.0f;
            self.bookTintView.hidden = NO;
            self.progressView.hidden = YES;
            [self setErrorBadgeHidden:YES];
            break;
    }

    
    
    if (self.isNewBook && self.errorBadge.hidden == YES) {
        [self setIsNewBadgeHidden:NO];
    } else {
        [self setIsNewBadgeHidden:YES];
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad 
        && self.coverViewMode == SCHBookCoverViewModeGridView) {
        
        // the offset amount that the image tab is over onto the cover
        NSInteger overhang = 0;
        
        // whether to actually do the resizing work
        BOOL doSizing = YES;
        
        SCHAppBookFeatures bookFeatures = book.bookFeatures;
        
        if (self.disabledForInteractions) {
            switch (bookFeatures) {
                case kSCHAppBookFeaturesNone:
                case kSCHAppBookFeaturesSample:
                    break;
                case kSCHAppBookFeaturesStoryInteractions:
                    bookFeatures = kSCHAppBookFeaturesNone;
                    break;
                case kSCHAppBookFeaturesSampleWithStoryInteractions:
                    bookFeatures = kSCHAppBookFeaturesSample;
                    break;
            }
        }
        
        switch (bookFeatures) {
            case kSCHAppBookFeaturesNone:
            {
                self.featureTab.image = nil;
                [self setFeatureTabHidden:YES];
                doSizing = NO;
                break;
            }   
            case kSCHAppBookFeaturesStoryInteractions:
            {
                if (tabOnRight) {
                    self.featureTab.image = [UIImage imageNamed:@"BookSITab"];
                    overhang = 10;
                } else {
                    self.featureTab.image = [UIImage imageNamed:@"BookSITabHorizontal"];
                    overhang = 20;
                }
                
                break;
            }   
            case kSCHAppBookFeaturesSampleWithStoryInteractions:
            {
                if (tabOnRight) {
                    self.featureTab.image = [UIImage imageNamed:@"BookSISampleTab"];
                    overhang = 10;
                } else {
                    self.featureTab.image = [UIImage imageNamed:@"BookSISampleTabHorizontal"];
                    overhang = 21;
                }
                
                break;
            }   

            case kSCHAppBookFeaturesSample:
            {
                if (tabOnRight) {
                    self.featureTab.image = [UIImage imageNamed:@"BookSampleTab"];
                    overhang = 0;
               } else {
                    self.featureTab.image = [UIImage imageNamed:@"BookSampleTabHorizontal"];
                    overhang = 0;
                }
                
                break;
            }   
            default:
            {
                NSLog(@"Warning: unknown type for book features.");
                self.featureTab.image = nil;
                [self setFeatureTabHidden:YES];
                doSizing = NO;
                break;
            }
        }
        
        // resize the feature tab image view to the size of the image - this changes between cells
        CGRect tabFrame = self.featureTab.frame;
        tabFrame.origin.x = 0;
        tabFrame.origin.y = 0;
        tabFrame.size.width = self.featureTab.image.size.width;
        tabFrame.size.height = self.featureTab.image.size.height;
        self.featureTab.frame = tabFrame;
        
        if (doSizing) {
            if (tabOnRight) {
                // move the tab to the right side of the cover
                self.featureTab.contentMode = UIViewContentModeRight;

                tabFrame.origin.x = coverFrame.origin.x + coverFrame.size.width - overhang;
                tabFrame.origin.y = floorf((self.frame.size.height - coverFrame.size.height) + (coverFrame.size.height / 2) - (tabFrame.size.height / 2));
                self.featureTab.frame = tabFrame;
            } else {
                // move the tab across the top of the cover
                self.featureTab.contentMode = UIViewContentModeTop;

                tabFrame.origin.x = floorf(coverFrame.origin.x + (coverFrame.size.width / 2)  - (tabFrame.size.width / 2));
                tabFrame.origin.y = self.frame.size.height - coverFrame.size.height - tabFrame.size.height + overhang;
                self.featureTab.frame = tabFrame;
            }

            [self setFeatureTabHidden:NO];
        }
    }
}

#pragma mark - Thumbnail Creation

- (void)updateCachedImage:(UIImage *)thumbImage atPath:(NSString *)thumbPath forIdentifier:(SCHBookIdentifier *)localIdentifier
{
    [self updateCachedImage:thumbImage atPath:thumbPath forIdentifier:localIdentifier waitUntilDone:NO];
}

- (void)updateCachedImage:(UIImage *)thumbImage atPath:(NSString *)thumbPath forIdentifier:(SCHBookIdentifier *)localIdentifier waitUntilDone:(BOOL)wait
{
    dispatch_block_t updateImage = ^{        
        // first check if the identifier has changed; if so, don't set the processed thumbnail
        if ([self.identifier isEqual:localIdentifier]) {
            if (thumbImage) {
                self.currentImageName = thumbPath;
                self.coverImageView.image = thumbImage;
                self.coverImageView.hidden = NO;
                self.showingPlaceholder = NO;
                [self resizeElementsForThumbSize:thumbImage.size];
            } else {
                [self cachedImageFailureForBookIdentifier:localIdentifier];
            }
        }
    };
    
    if (wait) {
        updateImage();
    } else {
        dispatch_async(dispatch_get_main_queue(), updateImage);
    }
}

- (UIImage *)createImageWithSourcePath:(NSString *)sourcePath destinationPath:(NSString *)destinationPath 
{
    BOOL portraitAspect = YES;
    
    NSURL *sourceURL = [NSURL fileURLWithPath:sourcePath];
    
    // get the full size cover image properties without loading it into memory
    // so we can figure out the aspect
    CGImageSourceRef src = CGImageSourceCreateWithURL((CFURLRef)sourceURL, NULL);
    
    if (src != nil) {
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
        
        if (height < width) {
            portraitAspect = NO;
        }
    }
    
    if (portraitAspect) {
        // standard image - tab is on the right
        return [UIImage SCHCreateThumbWithSourcePath:sourcePath destinationPath:destinationPath maxDimension:self.frame.size.height];
    } else {
        // tab on the top - make sure we provide enough space for it
        
        if (self.coverViewMode == SCHBookCoverViewModeGridView) {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            UIImage *biggestTopTabImage = [UIImage imageNamed:@"BookSampleTabHorizontal"];
                return [UIImage SCHCreateThumbWithSourcePath:sourcePath destinationPath:destinationPath maxDimension:(self.frame.size.height - biggestTopTabImage.size.height - 8)];
            } else {
                return [UIImage SCHCreateThumbWithSourcePath:sourcePath destinationPath:destinationPath maxDimension:(self.frame.size.width)];
            }
        } else {
            return [UIImage SCHCreateThumbWithSourcePath:sourcePath destinationPath:destinationPath maxDimension:self.frame.size.width];
        }
    }
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