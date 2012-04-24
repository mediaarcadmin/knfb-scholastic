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
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.scrollView addSubview:self.imageView];
        self.scrollView.delegate = self;
        
        CGSize imageSize = self.imageView.image.size;
        if (imageSize.width > 0.0 && imageSize.height > 0.0) {
            CGRect rect = self.imageView.bounds;
            rect.size = imageSize;
            self.imageView.bounds = rect;        
            self.imageView.frame = rect;
            self.scrollView.contentSize = imageSize;
            self.scrollView.layer.cornerRadius = 10.0;  
            self.scrollView.layer.borderWidth = 0.0;
            self.scrollView.layer.masksToBounds = YES;
            
            CGFloat widthScale = CGRectGetWidth(self.scrollView.bounds) / imageSize.width;
            CGFloat heightScale = CGRectGetHeight(self.scrollView.bounds) / imageSize.height;
            self.scrollView.maximumZoomScale = MAX(widthScale, heightScale) * 1.5;    // restrict the zoom so we don't completely pixelize the image 
            self.scrollView.minimumZoomScale = MIN(widthScale, heightScale);
            
            self.scrollView.zoomScale = widthScale;
        }
    } else {
        [self resizeCurrentViewToSize:self.imageView.image.size animationDuration:0 withAdditionalAdjustments:nil];
        self.scrollView.hidden = YES;
    } 
    
    // Always mark the SI as complete as soon as it is opened once
    self.controllerState = SCHStoryInteractionControllerStateInteractionFinishedSuccessfully;
    
    self.imageView.layer.borderColor = [UIColor purpleColor].CGColor;
    self.imageView.layer.borderWidth = 1;
    
    self.scrollView.layer.borderColor = [UIColor orangeColor].CGColor;
    self.scrollView.layer.borderWidth = 1;

}

- (SCHFrameStyle)frameStyle
{
    return(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? SCHStoryInteractionFullScreen : SCHStoryInteractionNoTitle);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

#pragma mark - UIScrollView delegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return(self.imageView);
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
