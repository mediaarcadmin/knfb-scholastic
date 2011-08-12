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

@property (nonatomic, retain) UIImageView *backgroundView;
@property (nonatomic, copy) NSString *imageKey;
@property (nonatomic, assign) BOOL iPadQualifier;

@end 

@implementation SCHCustomNavigationBar

@synthesize backgroundImage;
@synthesize backgroundView;
@synthesize imageKey;
@synthesize iPadQualifier;

#pragma mark - Object lifecycle

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [backgroundImage release], backgroundImage = nil;
    [backgroundView release], backgroundView = nil;
    [imageKey release], imageKey = nil;
    [super dealloc];
}

#pragma mark - Drawing routines

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self sendSubviewToBack:self.backgroundView];
}

- (void)drawRect:(CGRect)rect
{
    // Do nothing so that the default bar isn't shown during rotation
}

#pragma mark - Accessor methods

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
        backgroundView = [[UIImageView alloc] initWithFrame:self.bounds];        
        backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;        
        [self addSubview:backgroundView];
    }
    
    return(backgroundView);
}

- (void)setTheme:(NSString *)newImageKey
   iPadQualifier:(SCHThemeManagerPadQualifier)setiPadQualifier
{
    self.imageKey = newImageKey;
    self.iPadQualifier = setiPadQualifier;
    if (self.imageKey == nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self setBackgroundImage:nil];
    } else {
        [self updateTheme:[[UIApplication sharedApplication] statusBarOrientation]];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(themeManagerThemeChangeNotification)
                                                     name:kSCHThemeManagerThemeChangeNotification
                                                   object:nil];
    }
}

- (void)setTheme:(NSString *)newImageKey
{
    [self setTheme:newImageKey iPadQualifier:kSCHThemeManagerPadQualifierNone];
}

- (void)updateTheme:(UIInterfaceOrientation)interfaceOrientation
{
    [self setBackgroundImage:[[SCHThemeManager sharedThemeManager] imageFor:self.imageKey
                                                                orientation:interfaceOrientation 
                                                              iPadQualifier:self.iPadQualifier]];
}

#pragma mark - Notification methods
     
- (void)themeManagerThemeChangeNotification
{
    [self updateTheme:[[UIApplication sharedApplication] statusBarOrientation]];
}

@end
