//
//  BITModalSheetController.h
//
//  Copyright (c) 2011 BitWink. All rights reserved.
//  Made available under a BitWink Ltd source code license. See bitwink.com for full details.
//  Must not be distributed to 3rd parties without prior permission from BitWink Ltd.
//

#import <UIKit/UIKit.h>

@interface BITModalSheetController : NSObject {}

- (id)initWithContentViewController:(UIViewController *)viewController;

- (void)presentSheetInViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(dispatch_block_t)completion;
- (void)dismissSheetAnimated:(BOOL)animated completion:(void (^)(void))completion;
- (BOOL)isModalSheetVisible;

- (void)setContentSize:(CGSize)newSize animated:(BOOL)animated completion:(dispatch_block_t)completion;
- (void)setContentOffset:(CGPoint)newOffset animated:(BOOL)animated completion:(dispatch_block_t)completion;

#pragma mark - Customizations

@property (nonatomic, assign) CGSize contentSize;    // default is 540x620 on iPad, 300x300 on iPhone
@property (nonatomic, assign) CGPoint contentOffset; // default is CGPointZero
@property (nonatomic, assign) CGFloat shadowRadius;         // default 8.0f;
@property (nonatomic, assign) BOOL shouldDimBackground;     // default is YES;
@property (nonatomic, assign) BOOL shouldDismissOutsideContentBounds; // default is NO;
@property (nonatomic, assign) CGFloat offsetForLandscapeKeyboard; // default is -1 (which aligns the view top). iPad only

/*
 Controls how the popover is positioned on rotation. Default is:
    UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleRightMargin | 
    UIViewAutoresizingFlexibleTopMargin | 
    UIViewAutoresizingFlexibleBottomMargin.
 */

@property (nonatomic, assign) UIViewAutoresizing autoresizingMask;

/*
 Determines if the presenting viewController rotation animation waits for the modal popover
 to finish presenting/dismissing. Default is YES to match normal modal viewController behavior. 
 Can be disabled if users don't want the implementation of shouldRotateToInterfaceOrientation: 
 in the presenting viewController to be temporarily overriden. Only supported in iOS 5 and above.
 */

@property (nonatomic, assign) BOOL delayPresentingViewControllerRotationAnimation; // __IPHONE_5_0 AND ABOVE;

@end