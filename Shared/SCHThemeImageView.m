//
//  SCHThemeImageView.m
//  Scholastic
//
//  Created by John S. Eddie on 18/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHThemeImageView.h"

#import "SCHThemeManager.h"

@interface SCHThemeImageView ()

@property (nonatomic, copy) NSString *imageKey;

@end

@implementation SCHThemeImageView

@synthesize imageKey;

#pragma mark - Object lifecycle

- (void)dealloc 
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [imageKey release], imageKey = nil;
    [super dealloc];
}

#pragma mark - methods

- (void)setTheme:(NSString *)newImageKey
{
    self.imageKey = newImageKey;
    
    if (self.imageKey == nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];        
        self.image = nil;
    } else {
        [self updateTheme:[[UIApplication sharedApplication] statusBarOrientation]];
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(themeManagerThemeChangeNotification) 
                                                     name:kSCHThemeManagerThemeChangeNotification 
                                                   object:nil];                
    }
}

- (void)updateTheme:(UIInterfaceOrientation)orientation
{
    self.image = [[SCHThemeManager sharedThemeManager] imageFor:self.imageKey 
                                                    orientation:orientation];
}

#pragma mark - Notification methods

- (void)themeManagerThemeChangeNotification
{
    [self updateTheme:[[UIApplication sharedApplication] statusBarOrientation]];
}

@end
