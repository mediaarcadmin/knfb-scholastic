//
//  SCHThemeButton.h
//  Scholastic
//
//  Created by John S. Eddie on 18/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHThemeManager.h"

@interface SCHThemeButton : UIButton 
{    
}

- (void)setThemeButton:(NSString *)newButtonKey leftCapWidth:(NSInteger)newLeftCapWidth 
          topCapHeight:(NSInteger)newTopCapHeight iPadQualifier:(SCHThemeManagerPadQualifier)iPadQualifier;
- (void)setThemeButton:(NSString *)newButtonKey leftCapWidth:(NSInteger)newLeftCapWidth 
          topCapHeight:(NSInteger)newTopCapHeight;
- (void)setThemeIcon:(NSString *)newIconKey iPadQualifier:(SCHThemeManagerPadQualifier)iPadQualifier;
- (void)setThemeIcon:(NSString *)newIconKey;
- (void)updateTheme:(UIInterfaceOrientation)orientation;

@end
