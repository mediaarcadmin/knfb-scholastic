//
//  SCHStoryInteractionControllerImage.m
//  Scholastic
//
//  Created by John S. Eddie on 08/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionControllerImage.h"

#import <QuartzCore/QuartzCore.h>

#import "SCHStoryInteractionImage.h"
#import "SCHXPSProvider.h"

@interface SCHStoryInteractionControllerImage ()

- (void)layoutScrollViewContents;

@end

@implementation SCHStoryInteractionControllerImage

@synthesize scrollView;
@synthesize imageView;

- (void)dealloc
{
    [scrollView release], scrollView = nil;
    [imageView release], imageView = nil;
    
    [super dealloc];
}

- (void)setupViewAtIndex:(NSInteger)screenIndex
{
    NSString *imagePath = [(SCHStoryInteractionImage *)self.storyInteraction imagePath];
    NSData *imageData = [self.xpsProvider dataForComponentAtPath:imagePath];
    self.imageView.image = [UIImage imageWithData:imageData];

    [self.scrollView addSubview:self.imageView];
    self.scrollView.delegate = self;
    
//    [self layoutScrollViewContents];
    // Always mark the SI as complete as soon as it is opened once
    self.controllerState = SCHStoryInteractionControllerStateInteractionFinishedSuccessfully;
}

- (SCHFrameStyle)frameStyle
{
    return(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? SCHStoryInteractionFullScreen : SCHStoryInteractionNoTitle);
}

- (void)layoutScrollViewContents
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        CGSize imageSize = self.imageView.image.size;
        if (imageSize.width > 0.0 && imageSize.height > 0.0) {
            
            self.imageView.frame = CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
            
//            CGFloat widthScale = CGRectGetWidth(self.scrollView.superview.bounds) / imageSize.width;
//            CGFloat heightScale = CGRectGetHeight(self.scrollView.bounds) / imageSize.height;
//
//            CGRect rect = self.imageView.frame;
//            
//            if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
//                rect.size = CGSizeMake(floorf(imageSize.width * widthScale), floorf(imageSize.height * widthScale));
//            } else {
//                rect.size = CGSizeMake(floorf(imageSize.width * heightScale), floorf(imageSize.height * heightScale));
//            }
//            self.imageView.frame = rect;
            
            self.scrollView.contentSize = self.imageView.frame.size;
//            self.scrollView.minimumZoomScale = 1;
//            self.scrollView.maximumZoomScale = 1.5;
            
        }
    } else {
        [self resizeCurrentViewToSize:self.imageView.image.size animationDuration:0 withAdditionalAdjustments:nil];
        self.scrollView.hidden = YES;
    } 
    
    NSLog(@"scrollview.frame.size: %@", NSStringFromCGSize(self.scrollView.frame.size));
    NSLog(@"content size: %@", NSStringFromCGSize(self.scrollView.contentSize));
    

}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    self.scrollView.layer.borderColor = [UIColor orangeColor].CGColor;
    self.scrollView.layer.borderWidth = 1;
    
    self.imageView.layer.borderColor = [UIColor greenColor].CGColor;
    self.imageView.layer.borderWidth = 1;
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        [self layoutScrollViewContents];

        // fix the frame sizes for rotation
        CGRect viewFrame = self.scrollView.superview.frame;
        if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
            viewFrame.size.width = 320;
            viewFrame.size.height = 480;
        } else {
            viewFrame.size.width = 480;
            viewFrame.size.height = 320;
        }
        self.scrollView.superview.frame = viewFrame;
        self.scrollView.frame = viewFrame;

    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (BOOL) currentFrameStyleOverlaysContents
{
    return YES;
}

#pragma mark - UIScrollView delegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return(self.imageView);
}

//- (void)scrollViewDidZoom:(UIScrollView *)aScrollView {
//    
//    CGFloat offsetX = (self.scrollView.bounds.size.width > self.scrollView.contentSize.width)? 
//    (self.scrollView.bounds.size.width - self.scrollView.contentSize.width) * 0.5 : 0.0;
//    
//    CGFloat offsetY = (self.scrollView.bounds.size.height > self.scrollView.contentSize.height)? 
//    (self.scrollView.bounds.size.height - self.scrollView.contentSize.height) * 0.5 : 0.0;
//    
//    self.imageView.center = CGPointMake(self.scrollView.contentSize.width * 0.5 + offsetX, 
//                                   self.scrollView.contentSize.height * 0.5 + offsetY);
//    
//    NSLog(@"scrollview zoomscale: %f", self.scrollView.zoomScale);
//}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
    NSLog(@"content offset: %@", NSStringFromCGPoint(aScrollView.contentOffset));
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView 
                       withView:(UIView *)view 
                        atScale:(float)scale
{
        // nop - method included to implement zooming
}

#pragma mark - Override for SCHStoryInteractionControllerStateReactions

- (void)storyInteractionDisableUserInteraction
{
    // empty - there is no interaction we need to prevent here
}

- (void)storyInteractionEnableUserInteraction
{
    // empty - there is no interaction we need to prevent here
}



@end
