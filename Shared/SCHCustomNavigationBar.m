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

@synthesize backgroundImage;
@synthesize backgroundView;

- (void)dealloc
{
    [backgroundView release], backgroundView = nil;
    [super dealloc];
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    [self sendSubviewToBack:self.backgroundView];
}

- (void)setBackgroundImage:(UIImage*)image
{
    
    CGRect imageFrame = self.bounds;
    imageFrame.size.height = image.size.height;
    imageFrame.origin.y = -1;
    [self.backgroundView setImage:image];
    [self.backgroundView setFrame:imageFrame];
    
    [self setNeedsLayout];
}

- (UIImage *)backgroundImage
{
    return(backgroundView.image);
}

- (UIImageView *)backgroundView
{
    if (!backgroundView) {
        backgroundView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.clipsToBounds = NO;
        [self addSubview:backgroundView];
    }
    
    return backgroundView;
}

@end
