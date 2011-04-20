//
//  SCHCustomNavigationBar.m
//  Scholastic
//
//  Created by Gordon Christie on 08/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHThemeNavigationBar.h"

#import "SCHThemeManager.h"

@interface SCHThemeNavigationBar ()

- (void)updateTheme;

@property (nonatomic, retain) UIImageView *backgroundView;
@property (nonatomic, retain) NSString *imageKey;

@end 

@implementation SCHThemeNavigationBar

@synthesize backgroundImage;
@synthesize backgroundView;
@synthesize imageKey;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [backgroundView release], backgroundView = nil;
    [super dealloc];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self sendSubviewToBack:backgroundView];
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

- (void)setTheme:(NSString *)newImageKey
{
    self.imageKey = newImageKey;
    
    if (self.imageKey == nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];        
        [self setBackgroundImage:nil];    
    } else {
        [self updateTheme];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTheme) name:kSCHThemeManagerThemeChangeNotification object:nil];                
    }
}

- (void)updateTheme
{
    [self setBackgroundImage:[[SCHThemeManager sharedThemeManager] imageFor:self.imageKey]];    
}

@end
