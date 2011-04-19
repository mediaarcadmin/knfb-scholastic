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
@property (nonatomic, retain) UIColor *originalBackgroundColor;

@end 

@implementation SCHCustomNavigationBar

@dynamic backgroundImage;
@synthesize backgroundView;
@synthesize originalBackgroundColor;

- (void) layoutSubviews
{
    if (self.backgroundView.image != nil) {
        CGRect rect = self.frame;
        rect.size.height = self.backgroundView.image.size.height;
        rect.origin.y = -1;
        self.backgroundView.frame = rect;
        
        NSLog(@"rect: %@", NSStringFromCGRect(rect));
        [super layoutSubviews];
        [self sendSubviewToBack:self.backgroundView];
        
    } else {
        [super layoutSubviews];
    }
}

- (void)setBackgroundImage:(UIImage*)image
{
    if (self.originalBackgroundColor == nil) {
        self.originalBackgroundColor = self.backgroundColor;
    }

    if (image == nil) {
        [backgroundView removeFromSuperview];
        [backgroundView release], backgroundView = nil;
        self.backgroundColor = self.backgroundColor;                
        [self setNeedsDisplay];            
    } else if (image != self.backgroundView.image) {
        backgroundView = [[UIImageView alloc] initWithFrame:self.frame];
        self.backgroundView.image = image;
        [self insertSubview:self.backgroundView atIndex:0];
        
        self.clipsToBounds = NO;
        self.backgroundColor = [UIColor clearColor];        
        [self setNeedsDisplay];            
    }
}

/*
- (void) willMoveToWindow:(UIWindow *)newWindow
{
    [self sendSubviewToBack:self.backgroundView];
    [super willMoveToWindow:newWindow];
}
*/

- (UIImage *)backgroundImage
{
    return(backgroundView.image);
}


@end
