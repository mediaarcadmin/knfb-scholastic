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
        self.imageView.frame = self.scrollView.bounds;
        [self.scrollView addSubview:self.imageView];
        self.scrollView.delegate = self;
        self.scrollView.contentSize = self.scrollView.bounds.size;
        self.scrollView.layer.cornerRadius = 10.0;  
        self.scrollView.layer.borderWidth = 0.0;
        self.scrollView.layer.masksToBounds = YES;
        self.scrollView.maximumZoomScale = 1.5;    // restrict the zoom so we don't completely pixelize the image 
        self.scrollView.minimumZoomScale = 1.0;
        self.scrollView.zoomScale = 1.0;
    } else {
        [self resizeCurrentViewToSize:self.imageView.image.size animationDuration:0 withAdditionalAdjustments:nil];
    } 
    
    // Always mark the SI as complete as soon as it is opened once
    self.controllerState = SCHStoryInteractionControllerStateInteractionFinishedSuccessfully;
}

- (SCHFrameStyle)frameStyle
{
    return(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? SCHStoryInteractionFullScreen : SCHStoryInteractionNoTitle);
}

#pragma mark - UIScrollView delegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)aScrollView
{
    CGFloat scale = aScrollView.zoomScale;
    if (scale < 1.0) {
        CGSize scaledSize = CGSizeMake(aScrollView.contentSize.width*scale, aScrollView.contentSize.height*scale);
        CGFloat x = (aScrollView.contentSize.width-scaledSize.width)/2;
        CGFloat y = (aScrollView.contentSize.height-scaledSize.height)/2;
        aScrollView.contentOffset = CGPointMake(-x/scale, -y/scale);
    }
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
