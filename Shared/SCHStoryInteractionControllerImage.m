//
//  SCHStoryInteractionControllerImage.m
//  Scholastic
//
//  Created by John S. Eddie on 08/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionControllerImage.h"

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

    if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) == YES) {
        [self.scrollView addSubview:self.imageView];
        self.scrollView.delegate = self;
        
        CGSize imageSize = self.imageView.image.size;
        if (imageSize.width > 0.0 && imageSize.height > 0.0) {
            CGRect rect = self.imageView.bounds;
            rect.size = imageSize;
            self.imageView.bounds = rect;        
            self.imageView.frame = rect;
            self.scrollView.contentSize = imageSize;
            
            CGFloat widthScale = CGRectGetWidth(self.scrollView.bounds) / imageSize.width;
            CGFloat heightScale = CGRectGetHeight(self.scrollView.bounds) / imageSize.height;
            self.scrollView.maximumZoomScale = MAX(widthScale, heightScale) * 1.5;    // restrict the zoom so we don't completely pixelize the image 
            self.scrollView.minimumZoomScale = MIN(widthScale, heightScale);
            
            self.scrollView.zoomScale = widthScale;
        }
    } else {
        self.scrollView.hidden = YES;
    } 
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

@end
