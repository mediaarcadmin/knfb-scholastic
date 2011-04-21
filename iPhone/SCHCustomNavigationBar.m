//
//  SCHCustomNavigationBar.m
//  Scholastic
//
//  Created by Gordon Christie on 08/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHCustomNavigationBar.h"
#import "SCHThemeManager.h"

@interface SCHCustomNavigationBar ()

- (void)updateTheme;

@property (nonatomic, retain) UIImageView *backgroundView;
@property (nonatomic, retain) NSString *imageKey;

@end 

@implementation SCHCustomNavigationBar

@synthesize backgroundImage;
@synthesize backgroundView;
@synthesize imageKey;

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
    [self.backgroundView setImage:image];    
    [self setNeedsLayout];
}

- (UIImage *)backgroundImage
{
    return(backgroundView.image);
}

- (UIImageView *)backgroundView
{
    if (!backgroundView) {
        CGRect backgroundFrame = self.bounds;
        backgroundFrame.origin.y = -1;

        backgroundView = [[UIImageView alloc] initWithFrame:backgroundFrame];        
        backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        backgroundView.contentMode = UIViewContentModeTopLeft;
        
        self.clipsToBounds = NO;
        [self addSubview:backgroundView];
    }
    
    return backgroundView;
}

- (void) setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
}

- (void)setTheme:(NSString *)newImageKey
{
    self.imageKey = newImageKey;
    if (self.imageKey == nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self setBackgroundImage:nil];
    } else {
        [self updateTheme];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateTheme)
                                                     name:kSCHThemeManagerThemeChangeNotification
                                                   object:nil];
    }
}

- (void)updateTheme
{
    [self setBackgroundImage:[[SCHThemeManager sharedThemeManager] imageFor:self.imageKey
                                                                orientation:[[UIApplication sharedApplication] statusBarOrientation]]];
}

@end
