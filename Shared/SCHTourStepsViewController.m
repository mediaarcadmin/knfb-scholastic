//
//  SCHTourStepsViewController.m
//  Scholastic
//
//  Created by Gordon Christie on 18/09/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHTourStepsViewController.h"
#import "SCHTourFullScreenImageViewController.h"
#import "SCHTourStepImageView.h"
#import "SCHTourStepMovieView.h"
#import "SCHTourStepView.h"

//#define LEFT_TAG 101
//#define RIGHT_TAG 102

@interface SCHTourStepsViewController ()

@property (nonatomic, retain) NSArray *tourData;

@property (nonatomic, assign) NSUInteger currentIndex;

@property (nonatomic, retain) UIView *currentView;
@property (nonatomic, retain) UIView *leftView;
@property (nonatomic, retain) UIView *rightView;

@property (nonatomic, assign) CGFloat viewWidth;
@property (nonatomic, assign) CGFloat viewHeight;


@end

@implementation SCHTourStepsViewController

@synthesize mainScrollView;
@synthesize pageControl;
@synthesize tourData;
@synthesize currentIndex;
@synthesize currentView;
@synthesize leftView;
@synthesize rightView;
@synthesize backButton;
@synthesize forwardingView;
@synthesize viewWidth;
@synthesize viewHeight;
@synthesize titleView;

- (void)dealloc
{
    [self releaseViewObjects];
    
    [tourData release], tourData = nil;
    [super dealloc];
}

- (void)releaseViewObjects
{
    [titleView release], titleView = nil;
    [forwardingView release], forwardingView = nil;
    [pageControl release], pageControl = nil;
    [mainScrollView release], mainScrollView = nil;
    [currentView release], currentView = nil;
    [leftView release], leftView = nil;
    [rightView release], rightView = nil;
    [backButton release], backButton = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            self.viewWidth = 320;
            self.viewHeight = 380;
        } else {
            self.viewWidth = 1024;
            self.viewHeight = 600;
        }
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.forwardingView.forwardedView = self.mainScrollView;
    
    if (self.titleView) {
        self.titleView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.titleView.layer.shadowOffset = CGSizeMake(0, -2);
        self.titleView.layer.shadowOpacity = 0.6;
    }
    
    BOOL iPhone = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
    
    NSString *plistName = [NSString stringWithFormat:@"TourData~%@", iPhone?@"iphone":@"ipad"];
    
    self.tourData = [NSArray arrayWithContentsOfFile:
                     [[NSBundle mainBundle] pathForResource:plistName
                                                     ofType:@"plist"]
                     ];
    
    
    self.currentIndex = 0;
    
    self.pageControl = [[[DDPageControl alloc] initWithType:DDPageControlTypeOnFullOffFull] autorelease];
    self.pageControl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    
    [self.pageControl setNumberOfPages:self.tourData.count];
    [self.pageControl setCurrentPage:self.currentIndex];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.pageControl setIndicatorDiameter:7.0f];
        [self.pageControl setIndicatorSpace:12.0f];
        [self.pageControl setFrame:CGRectMake(401, 678, 145, 66)];
    } else {
        [self.pageControl setFrame:CGRectMake(56, 418, 72, 38)];
        [self.pageControl setIndicatorDiameter:7.0f];
        [self.pageControl setIndicatorSpace:9.0f];
    }
    
    [self.pageControl setOnColor:[UIColor colorWithRed:0.082 green:0.388 blue:0.596 alpha:0.8]];
    [self.pageControl setOffColor:[UIColor colorWithRed:0.082 green:0.388 blue:0.596 alpha:0.4]];
    [self.pageControl addTarget:self action:@selector(pageControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:self.pageControl];
    
    [self setupScrollViewForIndex:self.currentIndex];
    
    UIImage *stretchedBackImage = [[UIImage imageNamed:@"bluetourbutton"] stretchableImageWithLeftCapWidth:11 topCapHeight:0];
    
    [self.backButton setBackgroundImage:stretchedBackImage forState:UIControlStateNormal];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self releaseViewObjects];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}
- (IBAction)goBack:(UIButton *)sender {
    [self stopCurrentPlayingVideo];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)signIn:(UIButton *)sender {
    [self stopCurrentPlayingVideo];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)tourStepContainer:(SCHTourStepContainerView *)container pressedButtonAtIndex:(NSUInteger)containerIndex
{
    // this will be the currently visible view
    
    if (!self.tourData || self.currentIndex >= self.tourData.count) {
        NSLog(@"Warning: could not get tour view for index %d", self.currentIndex);
        return;
    }
    
    NSDictionary *tourItem = [self.tourData objectAtIndex:self.currentIndex];
    
    if (!tourItem) {
        NSLog(@"Warning: no data for tour view for index %d", self.currentIndex);
        return;
    }
    
    SCHTourStepsViewType type = [[tourItem objectForKey:@"type"] intValue];
    
    switch (type) {
        case SCHTourStepsViewTypeSingleImage:
        case SCHTourStepsViewTypeDoubleImage:
        {
            NSString *title = [tourItem objectForKey:[NSString stringWithFormat:@"fullScreenTitle%d", containerIndex]];

            SCHTourFullScreenImageViewController *fullScreenController = [[SCHTourFullScreenImageViewController alloc] initWithNibName:nil bundle:nil];
            fullScreenController.imageTitle = title;
            fullScreenController.imageName = [NSString stringWithFormat:@"tour_full_image_%d_%d.jpg", self.currentIndex, containerIndex];

            NSLog(@"Loading %@", fullScreenController.imageName);

            [self presentModalViewController:fullScreenController animated:YES];
            
            break;
         }
        case SCHTourStepsViewTypeReadthrough:
        {
            if ([[container mainTourStepView] isKindOfClass:[SCHTourStepMovieView class]]) {
            
                SCHTourStepMovieView *movieView = (SCHTourStepMovieView *)[container mainTourStepView];
                [movieView startVideo];
                
            } else {
                NSLog(@"Warning: tried to play on a view that wasn't a movie view.");
            }
            
            break;
        }
        case SCHTourStepsViewTypeBeginTour:
        {
            break;
        }
        default:
        {
            NSLog(@"Warning: tour view type unknown.");
            break;
        }
    }    
}


- (void)setupScrollViewForIndex:(NSInteger)index
{
    NSInteger visibleViewCount = 0;
    
    if ((index - 1) >= 0) {
        self.leftView = [self tourViewAtIndex:index - 1];
        visibleViewCount++;
    } else {
        self.leftView = nil;
    }
    
    self.currentView = [self tourViewAtIndex:index];
    visibleViewCount++;
    
    if ((index + 1) < self.tourData.count) {
        self.rightView = [self tourViewAtIndex:index + 1];
        visibleViewCount++;
    } else {
        self.rightView = nil;
    }
    
    
    
    self.mainScrollView.contentSize = CGSizeMake(visibleViewCount * self.viewWidth, self.viewHeight);
    
    CGRect leftRect = self.leftView.frame;
    CGRect currentRect = self.currentView.frame;
    CGRect rightRect = self.rightView.frame;
    
    if (self.leftView && self.rightView) {
        leftRect.origin.x = 0;
        currentRect.origin.x = self.viewWidth;
        rightRect.origin.x = self.viewWidth * 2;
        
        self.mainScrollView.contentOffset = CGPointMake(self.viewWidth,0);
        
    } else if (!self.leftView && self.rightView) {
        currentRect.origin.x = 0;
        rightRect.origin.x = self.viewWidth;
        
        self.mainScrollView.contentOffset = CGPointMake(0,0);
        
    } else if (self.leftView && !self.rightView) {
        leftRect.origin.x = 0;
        currentRect.origin.x = self.viewWidth;
        
        self.mainScrollView.contentOffset = CGPointMake(self.viewWidth,0);
    }
    
    self.leftView.frame = leftRect;
    self.currentView.frame = currentRect;
    self.rightView.frame = rightRect;
    
    for (UIView *subview in self.mainScrollView.subviews) {
        if (subview != self.leftView && subview != self.currentView && subview != self.rightView) {
            [subview removeFromSuperview];
        }
    }
    
    if (!self.leftView.superview) {
        [self.mainScrollView addSubview:self.leftView];
    }
    
    if (!self.currentView.superview) {
        [self.mainScrollView addSubview:self.currentView];
    }
    
    if (!self.rightView.superview) {
        [self.mainScrollView addSubview:self.rightView];
    }
    
}

- (UIView *)tourViewAtIndex:(NSUInteger)index
{
    if (!self.tourData || index >= self.tourData.count) {
        NSLog(@"Warning: could not get tour view for index %d", index);
        return nil;
    }
    
    NSDictionary *tourItem = [self.tourData objectAtIndex:index];
    
    if (!tourItem) {
        NSLog(@"Warning: no data for tour view for index %d", index);
        return nil;
    }
    
    NSLog(@"Getting tour view for index %d", index);
    
    SCHTourStepsViewType type = [[tourItem objectForKey:@"type"] intValue];
    
    BOOL iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    BOOL retina = ([[UIScreen mainScreen] scale] == 2);
    
    NSString *imagePostfix = [NSString stringWithFormat:@"%@~%@",
                              retina?@"@2x":@"",
                              iPad?@"ipad":@"iphone"];
    
    UIView *tourView = nil;
    
    switch (type) {
        case SCHTourStepsViewTypeSingleImage:
        {
            SCHTourStepImageView *tourStepImageView = [[SCHTourStepImageView alloc] initWithFrame:CGRectMake(0, 0, self.viewWidth, self.viewHeight)];
//            [tourStepImageView setButtonTitle:@"Full Screen"];
            
            if ([tourItem objectForKey:@"subtitle0"]) {
                [tourStepImageView setStepHeaderTitle:[tourItem objectForKey:@"subtitle0"]];
            }
            
            NSLog(@"Loading image: %@", [NSString stringWithFormat:@"tour_full_image_%d_%d%@.jpg", index, 0, imagePostfix]);
            
            UIImage *tourImage = [UIImage imageNamed:[NSString stringWithFormat:@"tour_full_image_%d_%d%@.jpg", index, 0, imagePostfix]];
            tourImage = [UIImage imageWithCGImage:tourImage.CGImage scale:[UIScreen mainScreen].scale orientation:tourImage.imageOrientation];
            [tourStepImageView setTourImage:tourImage];
            
            CGFloat textInset = [[tourItem objectForKey:@"textInset"] floatValue];
            SCHTourStepContainerView *container = [[[SCHTourStepContainerView alloc] initWithFrame:CGRectMake(0, 0, self.viewWidth, self.viewHeight) textInset:textInset] autorelease];
            
            container.containerTitleText = [tourItem objectForKey:@"mainTitle"];
            container.containerSubtitleText = [tourItem objectForKey:@"bodyText"];
            
            container.mainTourStepView = tourStepImageView;
            [tourStepImageView release];
            
            container.delegate = self;
            
            [container layoutForCurrentTourStepViews];
            
            tourView = container;
            
            break;
        }
        case SCHTourStepsViewTypeDoubleImage:
        {
            SCHTourStepImageView *leftTourStepImageView = [[SCHTourStepImageView alloc] initWithFrame:CGRectMake(0, 0, self.viewWidth, self.viewHeight)];
//            [leftTourStepImageView setButtonTitle:@"Full Screen"];
            
            UIImage *tourImage = [UIImage imageNamed:[NSString stringWithFormat:@"tour_full_image_%d_%d%@.jpg", index, 0, imagePostfix]];
            tourImage = [UIImage imageWithCGImage:tourImage.CGImage scale:[UIScreen mainScreen].scale orientation:tourImage.imageOrientation];
            
            [leftTourStepImageView setTourImage:tourImage];
            [leftTourStepImageView setStepHeaderTitle:[tourItem objectForKey:@"subtitle0"]];
            
            SCHTourStepImageView *rightTourStepImageView = [[SCHTourStepImageView alloc] initWithFrame:CGRectMake(0, 0, self.viewWidth, self.viewHeight)];
//            [rightTourStepImageView setButtonTitle:@"Full Screen"];
            
            tourImage = [UIImage imageNamed:[NSString stringWithFormat:@"tour_full_image_%d_%d%@.jpg", index, 1, imagePostfix]];
            tourImage = [UIImage imageWithCGImage:tourImage.CGImage scale:[UIScreen mainScreen].scale orientation:tourImage.imageOrientation];
            [rightTourStepImageView setTourImage:tourImage];

            [rightTourStepImageView setTourImage:tourImage];
            [rightTourStepImageView setStepHeaderTitle:[tourItem objectForKey:@"subtitle1"]];
            
            
            CGFloat textInset = [[tourItem objectForKey:@"textInset"] floatValue];
            SCHTourStepContainerView *container = [[[SCHTourStepContainerView alloc] initWithFrame:CGRectMake(0, 0, self.viewWidth, self.viewHeight) textInset:textInset] autorelease];
            
            container.containerTitleText = [tourItem objectForKey:@"mainTitle"];
            container.containerSubtitleText = [tourItem objectForKey:@"bodyText"];
            
            
            container.mainTourStepView = leftTourStepImageView;
            container.secondTourStepView = rightTourStepImageView;
            
            [leftTourStepImageView release];
            [rightTourStepImageView release];
            
            container.delegate = self;
            
            [container layoutForCurrentTourStepViews];
            
            tourView = container;
            
            break;
        }
        case SCHTourStepsViewTypeReadthrough:
        {
            
            SCHTourStepMovieView *tourStepMovieView = [[SCHTourStepMovieView alloc] initWithFrame:CGRectMake(0, 0, self.viewWidth, self.viewHeight) bottomBarVisible:YES];
            [tourStepMovieView setButtonTitle:@"Play Read-Aloud"];
            
            UIImage *tourImage = [UIImage imageNamed:[NSString stringWithFormat:@"tour_full_image_%d_%d%@.jpg", index, 0, imagePostfix]];
            tourImage = [UIImage imageWithCGImage:tourImage.CGImage scale:[UIScreen mainScreen].scale orientation:tourImage.imageOrientation];
            [tourStepMovieView setTourImage:tourImage];
            
            NSURL *movieURL = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                                      pathForResource:[NSString stringWithFormat:@"tour_video_%d", index]
                                                      ofType:@"mov"]];
            
            tourStepMovieView.movieURL = movieURL;
            
            CGFloat textInset = [[tourItem objectForKey:@"textInset"] floatValue];
            SCHTourStepContainerView *container = [[[SCHTourStepContainerView alloc] initWithFrame:CGRectMake(0, 0, self.viewWidth, self.viewHeight) textInset:textInset] autorelease];
            
            container.containerTitleText = [tourItem objectForKey:@"mainTitle"];
            container.containerSubtitleText = [tourItem objectForKey:@"bodyText"];
            
            container.mainTourStepView = tourStepMovieView;
            [tourStepMovieView release];
            
            container.delegate = self;
            
            [container layoutForCurrentTourStepViews];
            
            tourView = container;
            break;
        }
        case SCHTourStepsViewTypeBeginTour:
        {
            SCHTourStepImageView *tourStepImageView = [[SCHTourStepImageView alloc] initWithFrame:CGRectMake(0, 0, self.viewWidth, self.viewHeight) bottomBarVisible:YES];
            
            UIImage *tourImage = [UIImage imageNamed:[NSString stringWithFormat:@"tour_full_image_%d_%d%@.jpg", index, 0, imagePostfix]];
            tourImage = [UIImage imageWithCGImage:tourImage.CGImage scale:[UIScreen mainScreen].scale orientation:tourImage.imageOrientation];

            [tourStepImageView setTourImage:tourImage];
            
            CGFloat textInset = [[tourItem objectForKey:@"textInset"] floatValue];
            SCHTourStepContainerView *container = [[[SCHTourStepContainerView alloc] initWithFrame:CGRectMake(0, 0, self.viewWidth, self.viewHeight) textInset:textInset] autorelease];
           
            container.containerTitleText = [tourItem objectForKey:@"mainTitle"];
            container.containerSubtitleText = [tourItem objectForKey:@"bodyText"];
            
            container.mainTourStepView = tourStepImageView;
            [tourStepImageView release];
            
            container.delegate = self;
            
            [container layoutForCurrentTourStepViews];
            
            tourView = container;
            
            // button
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            
            UIImage *stretchedBackImage = [[UIImage imageNamed:@"lg_bttn_gray_UNselected_3part"] stretchableImageWithLeftCapWidth:7 topCapHeight:0];
            
            [button setBackgroundImage:stretchedBackImage forState:UIControlStateNormal];
            [button.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:13]];
            [button.titleLabel setTextColor:[UIColor whiteColor]];
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                [button setFrame:CGRectMake(394, 547, 240, 34)];
            } else {
                [button setFrame:CGRectMake(40, 346, 240, 34)];
            }
            [button setTitle:@"Sign In" forState:UIControlStateNormal];
            
            [button addTarget:self action:@selector(signIn:) forControlEvents:UIControlEventTouchUpInside];
            
            // container view
            [tourView addSubview:button];
            
            break;
        }
        default:
        {
            NSLog(@"Warning: tour view type unknown.");
            break;
        }
    }
    
    return tourView;
}

- (void)stopCurrentPlayingVideo
{
    if ([self.currentView isKindOfClass:[SCHTourStepContainerView class]]) {
        SCHTourStepView *tourStep = [(SCHTourStepContainerView *)self.currentView mainTourStepView];
        
        if ([tourStep isKindOfClass:[SCHTourStepMovieView class]]) {
            SCHTourStepMovieView *movieView = (SCHTourStepMovieView *)tourStep;
            [movieView stopVideo];
        }
    }
}

#pragma mark - UIPageControl

- (IBAction)pageControlValueChanged:(DDPageControl *)sender {
    
    NSLog(@"Setting page to %d", sender.currentPage);
    self.currentIndex = sender.currentPage;
    [self setupScrollViewForIndex:self.currentIndex];
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self stopCurrentPlayingVideo];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)sender {
    //    self.currentIndex = sender.contentOffset.x / 1024;
    
    NSInteger indexDiff = sender.contentOffset.x  / self.viewWidth;
    NSLog(@"Index diff: %d", indexDiff);
    
    NSInteger savedIndex = self.currentIndex;
    
    if (self.leftView && self.rightView) {
        switch (indexDiff) {
            case 0:
            {
                // scroll left
                self.currentIndex--;
                break;
            }
            case 1:
            {
                // no-op
                break;
            }
            case 2:
            {
                // scroll right
                self.currentIndex++;
                break;
            }
            default:
                break;
        }
    } else if (!self.leftView && self.rightView) {
        switch (indexDiff) {
            case 0:
            {
                // no-op
                break;
            }
            case 1:
            {
                // scroll right
                self.currentIndex++;
                break;
            }
            default:
                break;
        }
        
    } else if (self.leftView && !self.rightView) {
        switch (indexDiff) {
            case 0:
            {
                // scroll left
                self.currentIndex--;
                break;
            }
            case 1:
            {
                // no-op
                break;
            }
            default:
                break;
        }
    }
    
    
    NSLog(@"Switched to index %d, old index %d", self.currentIndex, savedIndex);
    
    if (self.currentIndex != savedIndex) {
        [self setupScrollViewForIndex:self.currentIndex];
        [self.pageControl setCurrentPage:self.currentIndex];
    }
}

@end
