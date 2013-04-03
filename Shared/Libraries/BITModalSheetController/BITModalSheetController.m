//
//  BITModalSheetController.m
//
//  Copyright (c) 2011 BitWink. All rights reserved.
//  Made available under a BitWink Ltd source code license. See bitwink.com for full details.
//  Must not be distributed to 3rd parties without prior permission from BitWink Ltd.
//

#import <QuartzCore/QuartzCore.h>
#import "BITModalSheetController.h"
#import <objc/runtime.h>
#import <objc/message.h>

enum {
    kBITModalSheetViewControllerCapabilityBasic                                      = 0 << 0,
    kBITModalSheetViewControllerCapabilitySupportsAttemptRotation                    = 1 << 1,   
    kBITModalSheetViewControllerCapabilitySupportsAutomaticallyCallAppearanceMethods = 2 << 2,  
};
typedef NSUInteger BITModalSheetViewControllerCapability;

static const NSTimeInterval kBITModalSheetRotationAnimationDurationPad = 0.4f;
static const NSTimeInterval kBITModalSheetRotationAnimationDurationPhone = 0.3f;
static const NSTimeInterval kBITModalSheetAppearanceAnimationDurationPad = 0.4f;
static const NSTimeInterval kBITModalSheetAppearanceAnimationDurationPhone = 0.3f;
static const NSTimeInterval kBITModalSheetDisappearanceAnimationDurationPad = 0.4f;
static const NSTimeInterval kBITModalSheetDisappearanceAnimationDurationPhone = 0.3f;
static const NSTimeInterval kBITModalSheetContentLayoutAnimationDurationPad = 0.4f;
static const NSTimeInterval kBITModalSheetContentLayoutAnimationDurationPhone = 0.3f;

@interface BITModalSheetContainerView : UIView
@end

@interface BITModalSheetContainerViewController : UIViewController <UIGestureRecognizerDelegate> {}

@property (nonatomic, assign) BITModalSheetController *popoverController;
@property (nonatomic, assign) UIWindow *window;
@property (nonatomic, assign) CGSize customSheetContentSize;
@property (nonatomic, assign) CGPoint customSheetContentOffset;
@property (nonatomic, retain) UIViewController *contentViewController;
@property (nonatomic, retain) UIView *shadeView;
@property (nonatomic, retain) UIView *wrapperView;
@property (nonatomic, retain) UIView *shadowView;
@property (nonatomic, retain) BITModalSheetContainerView *containerView;
@property (nonatomic, assign) CGFloat shadowRadius;
@property (nonatomic, assign) BOOL shouldDismissOutsideContentBounds;
@property (nonatomic, assign) BOOL shouldDimBackground;
@property (nonatomic, assign) UIViewAutoresizing autoresizingMask;
@property (nonatomic, assign) BOOL delayPresentingViewControllerRotationAnimation;
@property (nonatomic, assign) UIDeviceOrientation deviceOrientation;
@property (nonatomic, assign) UIInterfaceOrientation initialOrientation;
@property (nonatomic, copy) dispatch_block_t pendingRotation;
@property (nonatomic, assign, getter=isRotating) BOOL rotating;
@property (nonatomic, assign, getter=isAnimatingIn) BOOL animatingIn;
@property (nonatomic, assign, getter=isAnimatingOut) BOOL animatingOut;
@property (nonatomic, assign, getter=isKeyboardDocked) BOOL keyboardDocked;
@property (nonatomic, assign) BOOL shouldTopAlignContents;
@property (nonatomic, assign) CGFloat offsetForLandscapeKeyboard;

- (BOOL)shouldWaitForAnimationToComplete;
- (void)syncPresentingViewControllerRotation;
- (void)unsyncPresentingViewControllerRotation;
- (void)rotateFromOrientation:(UIDeviceOrientation)fromOrientation toOrientation:(UIDeviceOrientation)toOrientation;
- (UIInterfaceOrientation)interfaceOrientationFromDeviceOrientation:(UIDeviceOrientation)orientation;
- (UIDeviceOrientation)deviceOrientationFromInterfaceOrientation:(UIInterfaceOrientation)orientation;
- (void)performPendingRotation;
- (void)animateInWithDuration:(NSTimeInterval)duration completion:(void (^)(BOOL finished))completion;
- (void)animateOutWithDuration:(NSTimeInterval)duration completion:(void (^)(BOOL finished))completion;
- (void)setCustomSheetContentSize:(CGSize)newSize animated:(BOOL)animated completion:(dispatch_block_t)completion;
- (void)setCustomSheetContentOffset:(CGPoint)newOffset animated:(BOOL)animated completion:(dispatch_block_t)completion;
- (void)setKeyboardOffset;
- (void)registerForKeyboardNotifications;
- (void)deregisterForKeyboardNotifications;

@end

@interface BITModalSheetController()

@property (nonatomic, assign, getter = isModalSheetVisible) BOOL modalSheetVisible;
@property (nonatomic, retain) BITModalSheetContainerViewController *containerViewController;
@property (nonatomic, retain) UIViewController *contentViewController;
@property (nonatomic, assign) UIViewController *hostViewController;
@property (nonatomic, retain) UIView *shadeView;

+ (BITModalSheetViewControllerCapability)capabilityForViewController:(UIViewController *)viewController;

@end

@implementation BITModalSheetController

@synthesize modalSheetVisible;
@synthesize contentSize;
@synthesize contentOffset;
@synthesize containerViewController;
@synthesize contentViewController;
@synthesize hostViewController;
@synthesize shadeView;
@synthesize shadowRadius;
@synthesize shouldDimBackground;
@synthesize shouldDismissOutsideContentBounds;
@synthesize offsetForLandscapeKeyboard;
@synthesize autoresizingMask;
@synthesize delayPresentingViewControllerRotationAnimation;

- (void)dealloc
{
    if ([self isModalSheetVisible]) {
        [containerViewController.view removeFromSuperview];
    }
    
    [containerViewController release], containerViewController = nil;
    [contentViewController release], contentViewController = nil;
    [shadeView release], shadeView = nil;

    hostViewController = nil;
    
    [super dealloc];
}

- (id)initWithContentViewController:(UIViewController *)viewController
{
    if ((self = [super init])) {
        contentViewController = [viewController retain];
        shadowRadius = 8.0f;
        autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            contentSize = CGSizeMake(540, 620);
        } else {
            contentSize = CGSizeMake(300, 300);
        }
        
        contentOffset = CGPointZero;
        shouldDimBackground = YES;
        offsetForLandscapeKeyboard = -1;
        delayPresentingViewControllerRotationAnimation = YES;
        shouldDismissOutsideContentBounds = NO;
        modalSheetVisible = NO;
    }
    
    return self;
}

- (void)presentSheetInViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(dispatch_block_t)completion
{
    NSAssert(![self isModalSheetVisible ], @"presentModalSheetInViewController:animated: called while already being presented");
    
    NSAssert(viewController != nil, @"presentModalSheetInViewController:animated: called with nil viewController");
    
    [self retain]; // retain self whilst popover is on-screen
    
    UIWindow *window = viewController.view.window;
    
    NSAssert(viewController != nil, @"presentModalSheetInViewController:animated: called with viewController view that has no window");

    self.modalSheetVisible = YES;
    
    self.hostViewController = viewController;
    
    BITModalSheetContainerViewController *rootVC = [[BITModalSheetContainerViewController alloc] init];
    rootVC.initialOrientation = self.hostViewController.interfaceOrientation;
    rootVC.popoverController = self;
    rootVC.window = window;
    rootVC.contentViewController = self.contentViewController;
    rootVC.customSheetContentSize = self.contentSize;
    rootVC.customSheetContentOffset = self.contentOffset;
    rootVC.shadowRadius = self.shadowRadius;
    rootVC.shouldDismissOutsideContentBounds = self.shouldDismissOutsideContentBounds;
    rootVC.offsetForLandscapeKeyboard = self.offsetForLandscapeKeyboard;
    rootVC.autoresizingMask = self.autoresizingMask;
    rootVC.delayPresentingViewControllerRotationAnimation = self.delayPresentingViewControllerRotationAnimation;
    rootVC.shouldDimBackground = self.shouldDimBackground;
    self.containerViewController = rootVC;
    [rootVC release];
    
    
    
    [window addSubview:rootVC.view];


    NSTimeInterval duration = 0;
    
    if (animated) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            duration = kBITModalSheetAppearanceAnimationDurationPad;
        } else {
            duration = kBITModalSheetAppearanceAnimationDurationPhone;
        }
    }
    
    [rootVC animateInWithDuration:duration 
                       completion:^(BOOL finished){
                           if (completion) {
                               completion();
                           }
    }];
           
}

- (void)dismissSheetAnimated:(BOOL)animated completion:(void (^)(void))completion
{        
    NSTimeInterval duration = 0;
    
    if (animated) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            duration = kBITModalSheetDisappearanceAnimationDurationPad;
        } else {
            duration = kBITModalSheetDisappearanceAnimationDurationPhone;
        }
    }
     
    [self.containerViewController.view endEditing:YES];
    [self.containerViewController animateOutWithDuration:duration
                                  completion:^(BOOL finished) {
                                      self.hostViewController = nil;
                                      self.modalSheetVisible = NO;
                                      
                                      [self.containerViewController.view removeFromSuperview];
                                      self.containerViewController = nil;
                                      
                                      if (completion) {
                                          completion();
                                      }
                                      
                                      [self release];
                                  }];
}

- (void)setContentSize:(CGSize)newSize animated:(BOOL)animated completion:(dispatch_block_t)completion
{
    contentSize = newSize;
    [self.containerViewController setCustomSheetContentSize:newSize animated:animated completion:completion];
}

- (void)setContentOffset:(CGPoint)newOffset animated:(BOOL)animated completion:(dispatch_block_t)completion
{
    contentOffset = newOffset;
    [self.containerViewController setCustomSheetContentOffset:newOffset animated:animated completion:completion];
}

+ (BITModalSheetViewControllerCapability)capabilityForViewController:(UIViewController *)viewController
{
    BITModalSheetViewControllerCapability capability = kBITModalSheetViewControllerCapabilityBasic;
    
    if ([[UIViewController class] respondsToSelector:@selector(attemptRotationToDeviceOrientation)]) {
        capability |= kBITModalSheetViewControllerCapabilitySupportsAttemptRotation;
    }
    
    if ([viewController respondsToSelector:@selector(automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers)]) {
        // Note this is a proxy check for whether the appearance method need to be manually passed on
        // to the contents view controller - in 5.0 they don't so this does an effective check for that
        capability |= kBITModalSheetViewControllerCapabilitySupportsAutomaticallyCallAppearanceMethods;
    }
    
    return capability;

}

@end

#pragma mark -

@implementation BITModalSheetContainerViewController

@synthesize popoverController;
@synthesize window;
@synthesize customSheetContentSize;
@synthesize customSheetContentOffset;
@synthesize contentViewController;
@synthesize shadeView;
@synthesize wrapperView;
@synthesize shadowView;
@synthesize containerView;
@synthesize shadowRadius;
@synthesize shouldDismissOutsideContentBounds;
@synthesize shouldDimBackground;
@synthesize autoresizingMask;
@synthesize delayPresentingViewControllerRotationAnimation;
@synthesize deviceOrientation;
@synthesize initialOrientation;
@synthesize pendingRotation;
@synthesize rotating;
@synthesize animatingIn;
@synthesize animatingOut;
@synthesize shouldTopAlignContents;
@synthesize offsetForLandscapeKeyboard;
@synthesize keyboardDocked;

- (void)dealloc
{
    popoverController = nil;
    [contentViewController release], contentViewController = nil;
    [shadeView release], shadeView = nil;
    [wrapperView release], wrapperView = nil;
    [shadowView release], shadowView = nil;
    [containerView release], containerView = nil;
    [pendingRotation release], pendingRotation = nil;
    [super dealloc];
}

- (void)loadView
{
    self.wantsFullScreenLayout = NO;
    
    CGRect rootFrame = self.window.bounds;
    CGFloat offset;
    
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        offset = CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]);
    } else {
        offset = CGRectGetWidth([[UIApplication sharedApplication] statusBarFrame]);
    }
    
    rootFrame.origin.y += offset;
    rootFrame.size.height -= offset; 
    
    UIView *rootView = [[UIView alloc] initWithFrame:rootFrame];
    rootView.backgroundColor = [UIColor clearColor];
    rootView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    if (self.shouldDismissOutsideContentBounds) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        tap.delegate = self;
        [rootView addGestureRecognizer:tap];
        [tap release];
    }
    
    self.view = rootView;
    [rootView release];
    
    UIView *aShadeView = [[UIView alloc] initWithFrame:CGRectInset(self.view.bounds, -20, -20)];
    aShadeView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    aShadeView.userInteractionEnabled = NO;
    self.shadeView = aShadeView;
    [self.view addSubview:self.shadeView];
    [aShadeView release];
    
    CGRect frame = CGRectZero;
    frame.size = self.customSheetContentSize;
    frame.origin = CGPointMake(ceilf((CGRectGetWidth(rootView.frame)  - self.customSheetContentSize.width)/2.0f),            
                              (ceilf(CGRectGetHeight(rootView.frame) - self.customSheetContentSize.height)/2.0f));
    frame.origin.x += self.customSheetContentOffset.x;
    frame.origin.y += self.customSheetContentOffset.y;
    
    BITModalSheetContainerView *aContainerView = [[BITModalSheetContainerView alloc] initWithFrame:frame];
    aContainerView.backgroundColor = [UIColor clearColor];
    aContainerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin; // delaying setting this to the user setting until after the initial rotation in viewWillAppear
    //aContainerView.layer.delegate = self;
    
    self.containerView = aContainerView;
    [self.view addSubview:self.containerView];
    [aContainerView release];
    
    UIView *aShadowView = [[UIView alloc] initWithFrame:self.containerView.bounds];
    aShadowView.backgroundColor = [UIColor clearColor];
    aShadowView.layer.shadowRadius = self.shadowRadius;
    aShadowView.layer.shadowOpacity = 0.5f;
    aShadowView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    aShadowView.layer.shouldRasterize = YES;
    aShadowView.layer.shadowOffset = CGSizeZero;
    aShadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.shadowView = aShadowView;
    [self.containerView addSubview:self.shadowView];
    [aShadowView release];
    
    UIView *aWrapperView = [[UIView alloc] initWithFrame:self.shadowView.bounds];
    aWrapperView.backgroundColor = [UIColor clearColor];
    aWrapperView.layer.masksToBounds = YES;
    aWrapperView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    self.wrapperView = aWrapperView;
    [self.shadowView addSubview:self.wrapperView];
    [aWrapperView release];
    
    UIView* contentView = self.contentViewController.view;
    [contentView setFrame:self.wrapperView.bounds];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.wrapperView addSubview:contentView];
}

- (UIInterfaceOrientation)interfaceOrientation
{
    UIInterfaceOrientation ret = [super interfaceOrientation];
    return ret;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    self.deviceOrientation = [[UIDevice currentDevice] orientation];
    
    if ([self.contentViewController shouldAutorotateToInterfaceOrientation:self.initialOrientation]) {
        UIDeviceOrientation toDeviceOrientation = [self deviceOrientationFromInterfaceOrientation:self.initialOrientation];
        [self rotateFromOrientation:self.deviceOrientation toOrientation:toDeviceOrientation];
    }
    
    self.containerView.autoresizingMask = self.autoresizingMask;

    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(receivedRotate:) name: UIDeviceOrientationDidChangeNotification object:nil];
    
    if (!([BITModalSheetController capabilityForViewController:self] & kBITModalSheetViewControllerCapabilitySupportsAutomaticallyCallAppearanceMethods)) {
        [self.contentViewController viewWillAppear:animated];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!([BITModalSheetController capabilityForViewController:self] & kBITModalSheetViewControllerCapabilitySupportsAutomaticallyCallAppearanceMethods)) {
        [self.contentViewController viewDidAppear:animated];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    
    if (!([BITModalSheetController capabilityForViewController:self] & kBITModalSheetViewControllerCapabilitySupportsAutomaticallyCallAppearanceMethods)) {
        [self.contentViewController viewWillDisappear:animated];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (!([BITModalSheetController capabilityForViewController:self] & kBITModalSheetViewControllerCapabilitySupportsAutomaticallyCallAppearanceMethods)) {
        [self.contentViewController viewDidDisappear:animated];
    }
}
  
#pragma mark - Rotation

- (void)receivedRotate:(NSNotification *)notification
{
    UIDeviceOrientation toDeviceOrientation = [[UIDevice currentDevice] orientation];
    
    if (UIDeviceOrientationIsValidInterfaceOrientation(toDeviceOrientation)) {
        UIInterfaceOrientation toInterfaceOrientation = [self interfaceOrientationFromDeviceOrientation:toDeviceOrientation];
        
        if ([self.contentViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
            [self rotateFromOrientation:self.deviceOrientation toOrientation:toDeviceOrientation];
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    // Only autorotate to the initial orientation
    if (self.initialOrientation == 0) {
        self.initialOrientation = toInterfaceOrientation;
        return YES;
    } else {
        return (toInterfaceOrientation == self.initialOrientation);
    }
}

- (void)rotateFromOrientation:(UIDeviceOrientation)fromDeviceOrientation toOrientation:(UIDeviceOrientation)toDeviceOrientation 
{

    CGFloat rotation = 0;
    NSTimeInterval duration = 0;
    NSTimeInterval animationDuration = 0;
    CGRect viewBounds;
    CGPoint viewCenterOffset;
    
    CGRect screenBounds = self.window.screen.bounds;
    CGFloat statusBarHeight;
    
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    } else {
        statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.width;
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        animationDuration = kBITModalSheetRotationAnimationDurationPad;
    } else {
        animationDuration = kBITModalSheetRotationAnimationDurationPhone;
    }
    
    if (toDeviceOrientation == UIDeviceOrientationLandscapeLeft) {
        rotation = 0.5 * M_PI;
        viewBounds = CGRectMake(0, 0, screenBounds.size.height, screenBounds.size.width - statusBarHeight);
        viewCenterOffset = CGPointMake(-statusBarHeight/2.0f, 0);
        
        switch (fromDeviceOrientation) {
            case UIDeviceOrientationPortrait:
            case UIDeviceOrientationPortraitUpsideDown:
                duration = animationDuration;
                break;
            case UIDeviceOrientationLandscapeLeft:
                duration = 0;
                break;
            case UIDeviceOrientationLandscapeRight:
                duration = 2 * animationDuration;
                break;
            default:
                break;
        }
    } else if (toDeviceOrientation == UIDeviceOrientationLandscapeRight) {
        rotation = -0.5 * M_PI;
        viewBounds = CGRectMake(0, 0, screenBounds.size.height, screenBounds.size.width - statusBarHeight);
        viewCenterOffset = CGPointMake(statusBarHeight/2.0f, 0);

        switch (fromDeviceOrientation) {
            case UIDeviceOrientationPortrait:
            case UIDeviceOrientationPortraitUpsideDown:
                duration = animationDuration;
                break;
            case UIDeviceOrientationLandscapeLeft:
                duration = 2 * animationDuration;
                break;
            case UIDeviceOrientationLandscapeRight:
                duration = 0;
                break;
            default:
                break;
        }
    } else if (toDeviceOrientation == UIDeviceOrientationPortrait) {
        rotation = 0.0;
        viewBounds = CGRectMake(0, 0, screenBounds.size.width, screenBounds.size.height - statusBarHeight);
        viewCenterOffset = CGPointMake(0, statusBarHeight/2.0f);

        switch (fromDeviceOrientation) {
            case UIDeviceOrientationPortrait:
                duration = 0;
                break;
            case UIDeviceOrientationPortraitUpsideDown:
                duration = 2 * animationDuration;
                break;
            case UIDeviceOrientationLandscapeLeft:
            case UIDeviceOrientationLandscapeRight:
                duration = animationDuration;
                break;
            default:
                break;
        }
    } else if (toDeviceOrientation == UIDeviceOrientationPortraitUpsideDown) {
        rotation = M_PI;
        viewBounds = CGRectMake(0, 0, screenBounds.size.width, screenBounds.size.height - statusBarHeight);
        viewCenterOffset = CGPointMake(0, -statusBarHeight/2.0f);

        switch (fromDeviceOrientation) {
            case UIDeviceOrientationPortrait:
                duration = 2 * animationDuration;
                break;
            case UIDeviceOrientationPortraitUpsideDown:
                duration = 0;
                break;
            case UIDeviceOrientationLandscapeLeft:
            case UIDeviceOrientationLandscapeRight:
                duration = animationDuration;
                break;
            default:
                break;
        }
    }

    __block BITModalSheetContainerViewController *weakSelf = self;
    
    if (UIDeviceOrientationIsLandscape(toDeviceOrientation) && [self isKeyboardDocked]) {
        self.shouldTopAlignContents = YES;
    } else {
        self.shouldTopAlignContents = NO;
    }
    
    dispatch_block_t rotationAnimation = ^{

        weakSelf.deviceOrientation = toDeviceOrientation;
        
        dispatch_block_t animations = ^{
            weakSelf.view.transform = CGAffineTransformMakeRotation(rotation);
            weakSelf.view.bounds = viewBounds;
            
            CGPoint unoffsetCenter = CGPointMake(CGRectGetWidth(screenBounds)/2.0f, 
                                                 CGRectGetHeight(screenBounds)/2.0f);
            
            weakSelf.view.center = CGPointMake(unoffsetCenter.x + viewCenterOffset.x, 
                                               unoffsetCenter.y + viewCenterOffset.y);
            
            
            [weakSelf.view layoutSubviews];
            
            [weakSelf setKeyboardOffset];
        };
        
        if (duration > 0) {
            self.rotating = YES;
            [UIView animateWithDuration:duration
                                  delay:0 
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:animations
                             completion:^(BOOL finished){
                                 self.rotating = NO;
                                 [weakSelf performPendingRotation];
                             }];
        } else {
            animations();
            [weakSelf performPendingRotation];
        }
    };
    
    if ([self shouldWaitForAnimationToComplete]) {
        self.pendingRotation = rotationAnimation;
    } else {
        rotationAnimation();
    }
}

- (void)setDelayPresentingViewControllerRotationAnimation:(BOOL)shouldDelay
{
    // Only supported where attemptRotationToDeviceOrientation is implemented (iOS 5+)
    if ([BITModalSheetController capabilityForViewController:self] & kBITModalSheetViewControllerCapabilitySupportsAttemptRotation) {
        delayPresentingViewControllerRotationAnimation = shouldDelay;
    } else {
        delayPresentingViewControllerRotationAnimation = NO;
    }
}

- (BOOL)shouldWaitForAnimationToComplete
{
    if ([self isRotating]) {
        return YES;
    } else if ([self isAnimatingOut]) {
        return YES;
    } else if ([self isAnimatingIn]) {
        if (self.delayPresentingViewControllerRotationAnimation) {
            return YES;
        } else {
            UIViewController *hostViewController = self.popoverController.hostViewController;
        
            if ([hostViewController presentedViewController] != nil) {
                return YES; // is animating in on top of a modally presented view
            }
        }
    }

    return NO;
}

- (void)performPendingRotation
{
    if (self.pendingRotation) {

        dispatch_block_t handler = Block_copy(self.pendingRotation);
        self.pendingRotation = nil;
        dispatch_async(dispatch_get_main_queue(), handler);
        Block_release(handler);
    }
}

- (UIInterfaceOrientation)interfaceOrientationFromDeviceOrientation:(UIDeviceOrientation)orientation
{
    // Matches taken from enum definition of UIInterfaceOrientation
    switch (orientation) {
        case UIDeviceOrientationPortrait:
            return UIInterfaceOrientationPortrait;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            return UIInterfaceOrientationPortraitUpsideDown;
            break;
        case UIDeviceOrientationLandscapeRight:
            return UIInterfaceOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationLandscapeLeft:
            return UIInterfaceOrientationLandscapeRight;
            break;
        default:
            return (UIInterfaceOrientation)UIDeviceOrientationUnknown;
            break;
    }
}

- (UIDeviceOrientation)deviceOrientationFromInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    // Matches taken from enum definition of UIInterfaceOrientation
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            return UIDeviceOrientationPortrait;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            return UIDeviceOrientationPortraitUpsideDown;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            return UIDeviceOrientationLandscapeRight;
            break;
        case UIInterfaceOrientationLandscapeRight:
            return UIDeviceOrientationLandscapeLeft;
            break;
        default:
            return UIDeviceOrientationUnknown;
            break;
    }
}

#pragma  mark - Animated Customisations

- (void)setKeyboardOffset
{
    CGAffineTransform keyboardOffset = CGAffineTransformIdentity;
    
    if (self.shouldTopAlignContents) {
        if (self.offsetForLandscapeKeyboard == -1) {
            keyboardOffset = CGAffineTransformMakeTranslation(0, -(self.containerView.frame.origin.y));
        } else {
            keyboardOffset = CGAffineTransformMakeTranslation(0, -self.offsetForLandscapeKeyboard);
        }
    }
    
    self.shadowView.transform = keyboardOffset;
}

- (void)setCustomSheetContentSize:(CGSize)newSize animated:(BOOL)animated completion:(dispatch_block_t)completion
{
    customSheetContentSize = newSize;
    
    CGRect bounds = CGRectZero;    
    bounds.size = customSheetContentSize;
       
    if (animated) {
        [UIView animateWithDuration:kBITModalSheetContentLayoutAnimationDurationPad 
                              delay:0 
                            options:UIViewAnimationOptionCurveEaseInOut 
                         animations:^{
                             self.containerView.bounds = bounds;
                         }
                         completion:^(BOOL finished){
                             if (completion) {
                                 completion();
                             }
                         }];
    } else {
        self.containerView.bounds = bounds;
        if (completion) {
            completion();
        }
    }

}

- (void)setCustomSheetContentOffset:(CGPoint)newOffset animated:(BOOL)animated completion:(dispatch_block_t)completion
{
    customSheetContentOffset = newOffset;
    
    CGPoint center = CGPointZero;
    
    center = CGPointMake(CGRectGetWidth(self.view.bounds)/2.0f,            
                         CGRectGetHeight(self.view.bounds)/2.0f);
    
    center.x += customSheetContentOffset.x;
    center.y += customSheetContentOffset.y;
    
    if (animated) {
        [UIView animateWithDuration:kBITModalSheetContentLayoutAnimationDurationPad 
                              delay:0 
                            options:UIViewAnimationOptionCurveEaseInOut 
                         animations:^{
                             self.containerView.center = center;
                             [self setKeyboardOffset];
                         }
                         completion:^(BOOL finished){
                             if (completion) {
                                 completion();
                             }
                         }];
    } else {
        self.containerView.center = center;
        [self setKeyboardOffset];
        if (completion) {
            completion();
        }
    }
}

#pragma mark In/Out Animations

- (void)animateInWithDuration:(NSTimeInterval)duration completion:(void (^)(BOOL finished))completion
{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    if (self.delayPresentingViewControllerRotationAnimation) {
        [self syncPresentingViewControllerRotation];
    }
    
    [self registerForKeyboardNotifications];
    
    self.animatingIn = YES;
    
    if (self.shouldDimBackground) {
        self.shadeView.backgroundColor = [UIColor colorWithRed:0.03f green:0.05f blue:0.07f alpha:0.5f];
    } else {
        self.shadeView.backgroundColor = [UIColor clearColor];
    }
    
    self.shadeView.alpha = 0;
    self.containerView.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(self.view.bounds) - CGRectGetMinY(self.containerView.frame));
    
    [UIView animateWithDuration:duration 
                     animations:^{
                         self.shadeView.alpha = 1;
                         self.containerView.transform = CGAffineTransformIdentity; 

                     }
                     completion:^(BOOL finished){
                         self.animatingIn = NO;
                         
                         if (![self shouldWaitForAnimationToComplete]) {
                             [self performPendingRotation];
                         }
                         
                         if (self.delayPresentingViewControllerRotationAnimation) {
                             [self unsyncPresentingViewControllerRotation];
                         }
                         [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                         
                         if (completion) {
                             completion(finished);
                         }
                     }];
}

- (void)animateOutWithDuration:(NSTimeInterval)duration completion:(void (^)(BOOL finished))completion
{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    if (self.delayPresentingViewControllerRotationAnimation) {
        [self syncPresentingViewControllerRotation];
    }
    
    self.animatingOut = YES;
    
    [UIView animateWithDuration:duration 
                     animations:^{
                         self.shadeView.alpha = 0;
                         self.containerView.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(self.view.bounds) - CGRectGetMinY(self.containerView.frame));
                     }
                     completion:^(BOOL finished){
                         self.animatingOut = NO;

                         if (self.delayPresentingViewControllerRotationAnimation) {
                             [self unsyncPresentingViewControllerRotation];
                         }

                         [self deregisterForKeyboardNotifications];

                         [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                         
                         if (completion) {
                             completion(finished);
                         }
                         
                     }];
}

- (void)syncPresentingViewControllerRotation
{
    UIViewController *hostVC = self.popoverController.hostViewController;
    
    if (hostVC) {
        SEL hostSEL      = @selector(shouldAutorotateToInterfaceOrientation:);
        SEL overrideSEL  = @selector(BITModalSheetControllerShouldNotAutorotateToInterfaceOrientation:);
        SEL callSuperSEL = @selector(BITModalSheetControllerShouldCallSuperAutorotateToInterfaceOrientation:);
        
        Method hostMethod     = class_getInstanceMethod([hostVC class], hostSEL);
        Method overrideMethod = class_getInstanceMethod([self class], overrideSEL);
        Method mySuperMethod  = class_getInstanceMethod([self class], callSuperSEL);
        
        if (class_addMethod([hostVC class], hostSEL, method_getImplementation(mySuperMethod), method_getTypeEncoding(mySuperMethod))) {
            Method hostSuperMethod = class_getInstanceMethod([hostVC class], hostSEL);
            
            method_exchangeImplementations(hostSuperMethod, overrideMethod);
        } else {
            method_exchangeImplementations(hostMethod, overrideMethod);
        }
    }
}

- (void)unsyncPresentingViewControllerRotation
{
    UIViewController *hostVC = self.popoverController.hostViewController;
    
    if (hostVC) {
        SEL hostSEL     = @selector(shouldAutorotateToInterfaceOrientation:);
        SEL overrideSEL = @selector(BITModalSheetControllerShouldNotAutorotateToInterfaceOrientation:);
        
        Method hostMethod     = class_getInstanceMethod([hostVC class], hostSEL);
        Method overrideMethod = class_getInstanceMethod([self class], overrideSEL);
        
        method_exchangeImplementations(hostMethod, overrideMethod);
    }
    
    if ([BITModalSheetController capabilityForViewController:self] & kBITModalSheetViewControllerCapabilitySupportsAttemptRotation) {
        [UIViewController attemptRotationToDeviceOrientation];
    }
}

- (BOOL)BITModalSheetControllerShouldNotAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NO;
}

- (BOOL)BITModalSheetControllerShouldCallSuperAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    struct objc_super s = { self, [self superclass] }; 
    id ret = objc_msgSendSuper(&s, @selector(shouldAutorotateToInterfaceOrientation:),toInterfaceOrientation);   
    
    return (BOOL)ret;
}

#pragma mark - Touch Handling

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    CGPoint position = [touch locationInView:self.wrapperView];
    
    if (!CGRectContainsPoint(self.wrapperView.frame, position)) {
        [self.popoverController dismissSheetAnimated:YES completion:nil];
    }
    
    return NO;
}

#pragma mark - Animations

- (id<CAAction>)actionForCoverFromBottomAnimateIn
{
    NSTimeInterval duration = 0;
    
    if (YES) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            duration = kBITModalSheetAppearanceAnimationDurationPad;
        } else {
            duration = kBITModalSheetAppearanceAnimationDurationPhone;
        }
    }
    
    CABasicAnimation *fromBottom = [CABasicAnimation animationWithKeyPath:@"transform"]; 
    fromBottom.duration = duration;
    fromBottom.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    fromBottom.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0, CGRectGetHeight(self.view.bounds) - CGRectGetMinY(self.containerView.frame), 0)];
    fromBottom.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    fromBottom.fillMode = kCAFillModeBackwards;
    fromBottom.removedOnCompletion = YES;
    
    return fromBottom;
}
        
- (id<CAAction>)actionForAnimateIn
{
    NSTimeInterval duration = 0;
    
    if (YES) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            duration = kBITModalSheetAppearanceAnimationDurationPad;
        } else {
            duration = kBITModalSheetAppearanceAnimationDurationPhone;
        }
    }
    
    id<CAAction> action = [self actionForCoverFromBottomAnimateIn];
    [(CAAnimation *)action setValue:[NSNumber numberWithFloat:duration] forKey:@"duration"];

    return action;

}

- (id<CAAction>)actionForAnimateOut
{
    return (id<CAAction>)[NSNull null];
}

- (id<CAAction>)actionForLayer:(CALayer *)aLayer forKey:(NSString *)key
{
	id<CAAction> theAction=(id<CAAction>)[NSNull null];
	
	if ([key isEqualToString:kCAOnOrderIn]) {
        theAction = [self actionForAnimateIn];
    } else if ([key isEqualToString:kCAOnOrderOut]) {
        theAction = [self actionForAnimateOut];
    }
    
    return theAction;
}

#pragma mark - Keyboard

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)deregisterForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    self.keyboardDocked = YES;

    if (UIDeviceOrientationIsLandscape(self.deviceOrientation)) {
        self.shouldTopAlignContents = YES;
        NSDictionary *info = [notification userInfo];
        NSNumber *duration = [info valueForKey:UIKeyboardAnimationDurationUserInfoKey];
        NSNumber *curve = [info valueForKey:UIKeyboardAnimationCurveUserInfoKey];        
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:[duration doubleValue]];
        [UIView setAnimationCurve:[curve intValue]];
        [self setKeyboardOffset];
        [UIView commitAnimations];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    self.keyboardDocked = NO;

    if (UIDeviceOrientationIsLandscape(self.deviceOrientation)) {
        self.shouldTopAlignContents = NO;
        NSDictionary *info = [notification userInfo];
        NSNumber *duration = [info valueForKey:UIKeyboardAnimationDurationUserInfoKey];
        NSNumber *curve = [info valueForKey:UIKeyboardAnimationCurveUserInfoKey];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:[duration doubleValue]];
        [UIView setAnimationCurve:[curve intValue]];
        [self setKeyboardOffset];
        [UIView commitAnimations];
    }
}

@end

@implementation BITModalSheetContainerView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event 
{
    UIView *result = [super hitTest:point withEvent:event];
    
    if (!result) {
        for (UIView *subview in [self.subviews reverseObjectEnumerator]) {
            CGPoint pt = [self convertPoint:point toView:subview];
            result = [subview hitTest:pt withEvent:event];
            if (result) {
                break;
            }
        }
    }
    
    return result;
}

@end