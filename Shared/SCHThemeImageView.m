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

- (void)updateTheme;

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

#pragma - methods

- (void)setTheme:(NSString *)newImageKey
{
    self.imageKey = newImageKey;
    
    if (self.imageKey == nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];        
        self.image = nil;
    } else {
        [self updateTheme];
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(updateTheme) 
                                                     name:kSCHThemeManagerThemeChangeNotification 
                                                   object:nil];                
    }
}

#pragma - Private methods

- (void)updateTheme
{
    self.image = [[SCHThemeManager sharedThemeManager] imageFor:self.imageKey 
                                                    orientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

@end
