//
//  SCHCustomNavigationBar.m
//  Scholastic
//
//  Created by Gordon Christie on 08/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHCustomNavigationBar.h"

@interface SCHCustomNavigationBar ()

@property (nonatomic, retain) UIImageView *backgroundView;

@end 

@implementation SCHCustomNavigationBar

@dynamic backgroundImage;
@synthesize backgroundView;

- (void)drawRect:(CGRect)rect
{
    if (self.backgroundView.image != nil) {
        CGRect rect = self.frame;
        rect.size.height = self.backgroundView.image.size.height;
        self.backgroundView.frame = rect;
    } else {
        [super drawRect:rect];
    }
}

- (void)setBackgroundImage:(UIImage*)image
{
    if (image == nil) {
        [backgroundView removeFromSuperview];
        [backgroundView release], backgroundView = nil;
        [self setNeedsDisplay];            
    } else if (image != self.backgroundView.image) {
        backgroundView = [[UIImageView alloc] initWithFrame:self.frame];
        self.backgroundView.image = image;
        [self.superview insertSubview:self.backgroundView belowSubview:self];
        [self setNeedsDisplay];            
    }
}

- (UIImage *)backgroundImage
{
    return(backgroundView.image);
}


@end
