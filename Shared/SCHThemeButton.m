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

@property (nonatomic, retain) NSString *buttonKey;
@property (nonatomic, retain) NSString *iconKey;

@property(nonatomic, assign) NSInteger leftCapWidth;
@property(nonatomic, assign) NSInteger topCapHeight;

@end

@implementation SCHThemeButton

@synthesize buttonKey;
@synthesize iconKey;
@synthesize leftCapWidth;
@synthesize topCapHeight;

- (void)dealloc 
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

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
    }
}

- (void)updateTheme
{
    if (self.buttonKey != nil) {
        [self setBackgroundImage:[[[SCHThemeManager sharedThemeManager] imageFor:self.buttonKey 
                                                                     orientation:[[UIApplication sharedApplication] statusBarOrientation]] 
                                  stretchableImageWithLeftCapWidth:self.leftCapWidth topCapHeight:self.topCapHeight] forState:UIControlStateNormal];    
    }
    if (self.iconKey != nil) {
        [self setImage:[[SCHThemeManager sharedThemeManager] imageFor:self.iconKey 
                                                          orientation:[[UIApplication sharedApplication] statusBarOrientation]] forState:UIControlStateNormal];
    }    
}

@end
