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

@property (nonatomic, copy) NSString *buttonKey;
@property (nonatomic, copy) NSString *iconKey;
@property (nonatomic, assign) BOOL iPadQualifier;

@property (nonatomic, assign) NSInteger leftCapWidth;
@property (nonatomic, assign) NSInteger topCapHeight;

@end

@implementation SCHThemeButton

@synthesize buttonKey;
@synthesize iconKey;
@synthesize iPadQualifier;
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

- (void)setThemeButton:(NSString *)newButtonKey 
          leftCapWidth:(NSInteger)newLeftCapWidth 
          topCapHeight:(NSInteger)newTopCapHeight 
         iPadQualifier:(SCHThemeManagerPadQualifier)setiPadQualifier
{
    self.buttonKey = newButtonKey;
    self.iPadQualifier = setiPadQualifier;
    self.leftCapWidth = newLeftCapWidth;
    self.topCapHeight = newTopCapHeight;
    
    if (self.buttonKey == nil) {
        if (self.iconKey == nil) {    
            [[NSNotificationCenter defaultCenter] removeObserver:self];        
        }
        [self setBackgroundImage:nil forState:UIControlStateNormal];    
    } else {
        [self updateTheme:[[UIApplication sharedApplication] statusBarOrientation]];
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(themeManagerThemeChangeNotification) 
                                                     name:kSCHThemeManagerThemeChangeNotification 
                                                   object:nil]; 
    }
}

- (void)setThemeButton:(NSString *)newButtonKey 
          leftCapWidth:(NSInteger)newLeftCapWidth 
          topCapHeight:(NSInteger)newTopCapHeight
{
    [self setThemeButton:newButtonKey 
            leftCapWidth:newLeftCapWidth 
            topCapHeight:newTopCapHeight 
           iPadQualifier:kSCHThemeManagerPadQualifierNone];
}

- (void)setThemeIcon:(NSString *)newIconKey 
       iPadQualifier:(SCHThemeManagerPadQualifier)setiPadQualifier
{
    self.iconKey = newIconKey;
    self.iPadQualifier = setiPadQualifier;
    
    if (self.iconKey == nil) {
        if (self.buttonKey == nil) {
            [[NSNotificationCenter defaultCenter] removeObserver:self];        
        }
        [self setImage:nil forState:UIControlStateNormal];
    } else {
        [self updateTheme:[[UIApplication sharedApplication] statusBarOrientation]];
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(themeManagerThemeChangeNotification) 
                                                     name:kSCHThemeManagerThemeChangeNotification 
                                                   object:nil];                      
    }
}

- (void)setThemeIcon:(NSString *)newIconKey
{
    [self setThemeIcon:newIconKey iPadQualifier:kSCHThemeManagerPadQualifierNone];
}

- (void)updateTheme:(UIInterfaceOrientation)orientation
{
    // override button sizes for iPad
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        orientation = UIInterfaceOrientationPortrait;
    }
    
    if (self.buttonKey != nil) {
        UIImage *image = [[[SCHThemeManager sharedThemeManager] imageFor:self.buttonKey 
                                                             orientation:orientation 
                                                           iPadQualifier:self.iPadQualifier] 
                          stretchableImageWithLeftCapWidth:self.leftCapWidth 
                          topCapHeight:self.topCapHeight];
        // heights change when going between portrait and landscape so we change them
        CGRect rect = self.frame;
        rect.size.height = image.size.height;
        self.frame = rect;
        [self setBackgroundImage:image forState:UIControlStateNormal];    
    }
    if (self.iconKey != nil) {
        UIImage *image = [[SCHThemeManager sharedThemeManager] imageFor:self.iconKey 
                                                            orientation:orientation
                                                          iPadQualifier:self.iPadQualifier];
        // heights change when going between portrait and landscape so we change them
        CGRect rect = self.frame;
        rect.size.height = image.size.height;
        rect.size.width = image.size.width;        
        self.frame = rect;        
        [self setBackgroundImage:image forState:UIControlStateNormal];    
    }    
}

#pragma mark - Notification methods

- (void)themeManagerThemeChangeNotification
{
    [self updateTheme:[[UIApplication sharedApplication] statusBarOrientation]];
}
    
@end
