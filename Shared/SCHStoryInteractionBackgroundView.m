//
//  SCHStoryInteractionBackgroundView.m
//  Scholastic
//
//  Created by Neil Gall on 03/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionBackgroundView.h"

@implementation SCHStoryInteractionBackgroundView

static UIImage *stretch(UIImage *image)
{
    // assumes one of the appropriate background images
    return [image stretchableImageWithLeftCapWidth:10 topCapHeight:74];
}

- (id)initWithImage:(UIImage *)image
{
    return [super initWithImage:stretch(image)];
}

- (id)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage
{
    return [super initWithImage:stretch(image) highlightedImage:stretch(highlightedImage)];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self setImage:self.image];
        [self setHighlightedImage:self.highlightedImage];
    }
    return self;
}

- (void)setImage:(UIImage *)image
{
    [super setImage:stretch(image)];
}

- (void)setHighlightedImage:(UIImage *)highlightedImage
{
    [super setHighlightedImage:stretch(highlightedImage)];
}

@end
