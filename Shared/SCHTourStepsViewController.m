//
//  SCHTourStepsViewController.m
//  Scholastic
//
//  Created by Gordon Christie on 18/09/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHTourStepsViewController.h"
#import "SCHTourFullScreenImageViewController.h"
#import <MediaPlayer/MPMoviePlayerController.h>

#define LEFT_TAG 101
#define RIGHT_TAG 102

@interface SCHTourStepsViewController ()

@property (nonatomic, retain) NSArray *tourData;

@property (nonatomic, assign) NSUInteger currentIndex;

@property (nonatomic, retain) UIView *currentView;
@property (nonatomic, retain) UIView *leftView;
@property (nonatomic, retain) UIView *rightView;

@property (nonatomic, retain) MPMoviePlayerController *currentMoviePlayer;

@end

@implementation SCHTourStepsViewController

@synthesize mainScrollView;
@synthesize pageControl;
@synthesize tourData;
@synthesize currentIndex;
@synthesize currentView;
@synthesize leftView;
@synthesize rightView;
@synthesize currentMoviePlayer;
@synthesize backButton;
@synthesize forwardingView;

- (void)dealloc
{
    [self releaseViewObjects];
    
    [tourData release], tourData = nil;
    [super dealloc];
}

- (void)releaseViewObjects
{
    [forwardingView release], forwardingView = nil;
    [pageControl release], pageControl = nil;
    [mainScrollView release], mainScrollView = nil;
    [currentView release], currentView = nil;
    [leftView release], leftView = nil;
    [rightView release], rightView = nil;
    [currentMoviePlayer release], currentMoviePlayer = nil;
    [backButton release], backButton = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.forwardingView.forwardedView = self.mainScrollView;
    
    self.tourData = [NSArray arrayWithContentsOfFile:
                     [[NSBundle mainBundle] pathForResource:@"TourData"
                                                     ofType:@"plist"]
                     ];
    
    
    self.currentIndex = 0;
    
    self.pageControl = [[[DDPageControl alloc] initWithType:DDPageControlTypeOnFullOffFull] autorelease];
    self.pageControl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    
    [self.pageControl setNumberOfPages:self.tourData.count];
    [self.pageControl setCurrentPage:self.currentIndex];
    
    [self.pageControl setFrame:CGRectMake(439, 678, 145, 66)];
    [self.pageControl setOnColor:[UIColor colorWithRed:0.082 green:0.388 blue:0.596 alpha:0.8]];
    [self.pageControl setOffColor:[UIColor colorWithRed:0.082 green:0.388 blue:0.596 alpha:0.4]];
    [self.pageControl setIndicatorDiameter:7.0f];
    [self.pageControl setIndicatorSpace:12.0f];
    [self.pageControl addTarget:self action:@selector(pageControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:self.pageControl];
    
    [self setupScrollViewForIndex:self.currentIndex];
    
    UIImage *stretchedBackImage = [[UIImage imageNamed:@"bluetourbutton"] stretchableImageWithLeftCapWidth:11 topCapHeight:0];
    
    [self.backButton setBackgroundImage:stretchedBackImage forState:UIControlStateNormal];

    // tinting only supported on iOS 6 and above
    
    
    
    if (NSProtocolFromString(@"UIAppearance")) {
        NSLog(@"appearance proxy available");
        
        BOOL hasNewMethod = [UIPageControl instancesRespondToSelector:@selector(setPageIndicatorTintColor:)];

        if (hasNewMethod) {
            //[[UIPageControl appearance] setPageIndicatorTintColor:];
            //[[UIPageControl appearance] setCurrentPageIndicatorTintColor:];
        }
    }

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
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)signIn:(UIButton *)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)playCurrentVideo:(UIButton *)sender
{
    if (self.currentMoviePlayer) {
        [self.currentMoviePlayer stop];
        [self.currentMoviePlayer play];
        return;
    }
    
    NSURL *movieURL = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                              pathForResource:[NSString stringWithFormat:@"tour_video_%d", self.currentIndex]
                                              ofType:@"mov"]];
    
    self.currentMoviePlayer = [[[MPMoviePlayerController alloc] initWithContentURL:movieURL] autorelease];
    
    //            [[NSNotificationCenter defaultCenter] addObserver:self
    //                                                     selector:@selector(moviePlayerPlaybackStateDidChangeNotification:)
    //                                                         name:MPMoviePlayerPlaybackStateDidChangeNotification
    //                                                       object:nil];
    
    // container view
    
    self.currentMoviePlayer.controlStyle = MPMovieControlStyleNone;
    self.currentMoviePlayer.shouldAutoplay = NO;
    //[self.currentMoviePlayer.view setFrame:CGRectMake(0, 0, 556, 382)];
    CGFloat numViewPixelsToTrim  = 30.0f;
    
    [self.currentMoviePlayer.view setFrame:CGRectMake(0, -numViewPixelsToTrim/2.0f, 556, 382 + numViewPixelsToTrim)];
    self.currentMoviePlayer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    UIView *movieContainerView = [[UIView alloc] initWithFrame:CGRectMake(228, 158, 556, 382)];
    movieContainerView.clipsToBounds = YES;
    movieContainerView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    movieContainerView.layer.borderWidth = 1;
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:movieContainerView.bounds
                                                   byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerTopLeft | UIRectCornerTopRight
                                                         cornerRadii:CGSizeMake(6, 6)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = movieContainerView.bounds;
    maskLayer.path = maskPath.CGPath;
    [movieContainerView.layer setMask:maskLayer];
    [maskLayer release];

    
    
    [movieContainerView addSubview:self.currentMoviePlayer.view];
    [self.currentView addSubview:movieContainerView];
    
    [self.currentMoviePlayer play];
}

- (IBAction)pickedFullScreenImage:(UIButton *)sender
{
    // determine if we picked the left or the right image
    NSInteger multiIndex = 0;
    
    if (sender.tag == RIGHT_TAG) {
        multiIndex = 1;
    }
    
    NSDictionary *tourItem = [self.tourData objectAtIndex:self.currentIndex];
    NSString *title = [tourItem objectForKey:[NSString stringWithFormat:@"title%d", multiIndex]];
    
    SCHTourFullScreenImageViewController *fullScreenController = [[SCHTourFullScreenImageViewController alloc] initWithNibName:nil bundle:nil];
    fullScreenController.imageTitle = title;
    fullScreenController.imageName = [NSString stringWithFormat:@"tour_full_image_%d_%d.jpg", self.currentIndex, multiIndex];
    
    NSLog(@"Loading %@", fullScreenController.imageName);
    
    [self presentModalViewController:fullScreenController animated:YES];
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
        
        self.mainScrollView.contentSize = CGSizeMake(visibleViewCount * 1024, 600);
        
        CGRect leftRect = self.leftView.frame;
        CGRect currentRect = self.currentView.frame;
        CGRect rightRect = self.rightView.frame;
        
        if (self.leftView && self.rightView) {
            leftRect.origin.x = 0;
            currentRect.origin.x = 1024;
            rightRect.origin.x = 2048;
            
            self.mainScrollView.contentOffset = CGPointMake(1024,0);
            
        } else if (!self.leftView && self.rightView) {
            currentRect.origin.x = 0;
            rightRect.origin.x = 1024;
            
            self.mainScrollView.contentOffset = CGPointMake(0,0);

        } else if (self.leftView && !self.rightView) {
            leftRect.origin.x = 0;
            currentRect.origin.x = 1024;
            
            self.mainScrollView.contentOffset = CGPointMake(1024,0);
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
    
    UIView *tourView = nil;
    
    switch (type) {
        case SCHTourStepsViewTypeSingleImage:
        {
            NSString *scrollImageName = [NSString stringWithFormat:@"tour_scrolled_image_%d", index];
            
            // image view
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:scrollImageName]];
            // button
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setBackgroundImage:[[UIImage imageNamed:@"tour-tab-button-bg"] stretchableImageWithLeftCapWidth:8 topCapHeight:0] forState:UIControlStateNormal];
            [button setFrame:CGRectMake(697, 539, 92, 32)];
            [button.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:13]];
            [button setTitle:@"Full Screen" forState:UIControlStateNormal];
            
            [button addTarget:self action:@selector(pickedFullScreenImage:) forControlEvents:UIControlEventTouchUpInside];
            // FIXME: styling
            
            // container view
            tourView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 600)];
            
            [tourView addSubview:imageView];
            [tourView addSubview:button];
            
            break;
        }
        case SCHTourStepsViewTypeDoubleImage:
        {
            NSString *scrollImageName = [NSString stringWithFormat:@"tour_scrolled_image_%d", index];
            
            // image view
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:scrollImageName]];
            // button
            UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [leftButton setBackgroundImage:[[UIImage imageNamed:@"tour-tab-button-bg"] stretchableImageWithLeftCapWidth:8 topCapHeight:0] forState:UIControlStateNormal];
            [leftButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:13]];
            leftButton.tag = LEFT_TAG;
            [leftButton addTarget:self action:@selector(pickedFullScreenImage:) forControlEvents:UIControlEventTouchUpInside];

            [leftButton setFrame:CGRectMake(402, 525, 92, 32)];
            [leftButton setTitle:@"Full Screen" forState:UIControlStateNormal];

            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [rightButton setBackgroundImage:[[UIImage imageNamed:@"tour-tab-button-bg"] stretchableImageWithLeftCapWidth:8 topCapHeight:0] forState:UIControlStateNormal];
            [rightButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:13]];
            rightButton.tag = RIGHT_TAG;
            [rightButton addTarget:self action:@selector(pickedFullScreenImage:) forControlEvents:UIControlEventTouchUpInside];

            [rightButton setFrame:CGRectMake(900, 525, 92, 32)];
            [rightButton setTitle:@"Full Screen" forState:UIControlStateNormal];
            // FIXME: styling
            // FIXME: add target
            
            // container view
            tourView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 600)];
            
            [tourView addSubview:imageView];
            [tourView addSubview:leftButton];
            [tourView addSubview:rightButton];
            
            break;
        }
        case SCHTourStepsViewTypeReadthrough:
        {
            NSString *scrollImageName = [NSString stringWithFormat:@"tour_scrolled_image_%d", index];
            
            // image view
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:scrollImageName]];
            // button
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setBackgroundImage:[[UIImage imageNamed:@"tour-tab-button-bg"] stretchableImageWithLeftCapWidth:8 topCapHeight:0] forState:UIControlStateNormal];
            [button.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:13]];

            [button setFrame:CGRectMake(653, 539, 131, 32)];
            [button setTitle:@"Play Read-Aloud" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(playCurrentVideo:) forControlEvents:UIControlEventTouchUpInside];

            // FIXME: styling
            // container view
            tourView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 600)];
            
            [tourView addSubview:imageView];
            [tourView addSubview:self.currentMoviePlayer.view];
            [tourView addSubview:button];
            break;
        }
        case SCHTourStepsViewTypeBeginTour:
        {
            NSString *scrollImageName = [NSString stringWithFormat:@"tour_scrolled_image_%d", index];
            
            // image view
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:scrollImageName]];
            // button
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            
            UIImage *stretchedBackImage = [[UIImage imageNamed:@"greytourbutton"] stretchableImageWithLeftCapWidth:7 topCapHeight:0];
            
            [button setBackgroundImage:stretchedBackImage forState:UIControlStateNormal];
            [button.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:13]];
            [button.titleLabel setTextColor:[UIColor whiteColor]];

            [button setFrame:CGRectMake(394, 552, 240, 37)];
            [button setTitle:@"Sign In" forState:UIControlStateNormal];
            // FIXME: styling
            [button addTarget:self action:@selector(signIn:) forControlEvents:UIControlEventTouchUpInside];
            
            // container view
            tourView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 600)];
            
            [tourView addSubview:imageView];
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

#pragma mark - UIPageControl

- (IBAction)pageControlValueChanged:(DDPageControl *)sender {
    
    NSLog(@"Setting page to %d", sender.currentPage);
    self.currentIndex = sender.currentPage;
    [self setupScrollViewForIndex:self.currentIndex];
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.currentMoviePlayer) {
        [self.currentMoviePlayer stop];
        [self.currentMoviePlayer.view removeFromSuperview];
        self.currentMoviePlayer = nil;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)sender {
//    self.currentIndex = sender.contentOffset.x / 1024;
    
    NSInteger indexDiff = sender.contentOffset.x  / 1024;
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
