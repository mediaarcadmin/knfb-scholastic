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

@property (nonatomic, retain) NSString *imageKey;

@end

@implementation SCHThemeImageView

@synthesize imageKey;

- (void)dealloc 
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

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

- (void)updateTheme
{
    self.image = [[SCHThemeManager sharedThemeManager] imageFor:self.imageKey 
                                                    orientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

@end
