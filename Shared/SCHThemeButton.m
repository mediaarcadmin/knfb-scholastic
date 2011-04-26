//
//  SCHThemeButton.m
//  Scholastic
//
//  Created by John S. Eddie on 18/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHThemeButton.h"

#import "SCHThemeManager.h"

@interface SCHThemeButton ()

- (void)updateTheme;

@property (nonatomic, copy) NSString *buttonKey;
@property (nonatomic, copy) NSString *iconKey;

@property (nonatomic, assign) NSInteger leftCapWidth;
@property (nonatomic, assign) NSInteger topCapHeight;

@end

@implementation SCHThemeButton

@synthesize buttonKey;
@synthesize iconKey;
@synthesize leftCapWidth;
@synthesize topCapHeight;

#pragma mark - Object lifecycle

- (void)dealloc 
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [buttonKey release], buttonKey = nil;
    [iconKey release], iconKey = nil;
    [super dealloc];
}

#pragma mark - methods

- (void)setThemeButton:(NSString *)newButtonKey leftCapWidth:(NSInteger)newLeftCapWidth 
          topCapHeight:(NSInteger)newTopCapHeight
{
    self.buttonKey = newButtonKey;
    self.leftCapWidth = newLeftCapWidth;
    self.topCapHeight = newTopCapHeight;
    
    if (self.buttonKey == nil) {
        if (self.iconKey == nil) {    
            [[NSNotificationCenter defaultCenter] removeObserver:self];        
        }
        [self setBackgroundImage:nil forState:UIControlStateNormal];    
    } else {
        [self updateTheme];
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(updateTheme) 
                                                     name:kSCHThemeManagerThemeChangeNotification 
                                                   object:nil]; 
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(updateTheme) 
                                                     name:UIApplicationDidChangeStatusBarOrientationNotification 
                                                   object:nil]; 
    }
}

- (void)setThemeIcon:(NSString *)newIconKey
{
    self.iconKey = newIconKey;
    
    if (self.iconKey == nil) {
        if (self.buttonKey == nil) {
            [[NSNotificationCenter defaultCenter] removeObserver:self];        
        }
        [self setImage:nil forState:UIControlStateNormal];
    } else {
        [self updateTheme];
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(updateTheme) 
                                                     name:kSCHThemeManagerThemeChangeNotification 
                                                   object:nil];                
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(updateTheme) 
                                                     name:UIApplicationDidChangeStatusBarOrientationNotification 
                                                   object:nil];         
    }
}

#pragma mark - Private methods

- (void)updateTheme
{
    if (self.buttonKey != nil) {
        UIImage *image = [[[SCHThemeManager sharedThemeManager] imageFor:self.buttonKey 
                                                             orientation:[[UIApplication sharedApplication] statusBarOrientation]] 
                          stretchableImageWithLeftCapWidth:self.leftCapWidth topCapHeight:self.topCapHeight];
        // heights change when going between portrait and landscape so we change them
        CGRect rect = self.frame;
        rect.size.height = image.size.height;
        self.frame = rect;
        [self setBackgroundImage:image forState:UIControlStateNormal];    
    }
    if (self.iconKey != nil) {
        UIImage *image = [[SCHThemeManager sharedThemeManager] imageFor:self.iconKey 
                                                             orientation:[[UIApplication sharedApplication] statusBarOrientation]];
        // heights change when going between portrait and landscape so we change them
        CGRect rect = self.frame;
        rect.size.height = image.size.height;
        rect.size.width = image.size.width;        
        self.frame = rect;        
        [self setBackgroundImage:image forState:UIControlStateNormal];    
    }    
}

@end
