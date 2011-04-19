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
    [super layoutSubviews];
    [self sendSubviewToBack:self.backgroundView];
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
        
        self.clipsToBounds = NO;
        self.backgroundColor = [UIColor clearColor];   
        
        [self insertSubview:self.backgroundView atIndex:0];
        
        CGRect rect = self.frame;
        NSLog(@"Rect: %@", NSStringFromCGRect(rect));
        rect.size.height = self.backgroundView.image.size.height;
        rect.origin.y = -1;
        self.backgroundView.frame = rect;
        NSLog(@"Rect: %@", NSStringFromCGRect(rect));
        NSLog(@"Super rect: %@", NSStringFromCGRect(self.superview.frame));
        
        [self.backgroundView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        
        [self setNeedsDisplay];            
    }
}

- (UIImage *)backgroundImage
{
    return(backgroundView.image);
}


@end
