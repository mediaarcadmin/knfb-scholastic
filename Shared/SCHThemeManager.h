//
//  SCHThemeManager.h
//  Scholastic
//
//  Created by John S. Eddie on 15/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

// Constants
extern NSString * const kSCHThemeManagerThemeChangeNotification;

extern NSString * const kSCHThemeManagerDefault;

extern NSString * const kSCHThemeManagerImage;

extern NSString * const kSCHThemeManagerButtonImage;
extern NSString * const kSCHThemeManagerDoneButtonImage;
extern NSString * const kSCHThemeManagerNavigationBarImage;
extern NSString * const kSCHThemeManagerBackgroundImage;
extern NSString * const kSCHThemeManagerShelfImage;
extern NSString * const kSCHThemeManagerHomeIcon;
extern NSString * const kSCHThemeManagerBooksIcon;
extern NSString * const kSCHThemeManagerThemeIcon;
extern NSString * const kSCHThemeManagerColorForListBackground;

@class SCHAppProfile;

@interface SCHThemeManager : NSObject 
{
}

@property (nonatomic, copy) NSString *theme;
@property (nonatomic, retain) SCHAppProfile *appProfile;

+ (SCHThemeManager *)sharedThemeManager;

- (NSArray *)themeNames:(BOOL)excludeSelectedTheme;
- (UIImage *)imageForTheme:(NSString *)themeName key:(NSString *)key 
               orientation:(UIInterfaceOrientation)orientation;
- (UIImage *)imageForTheme:(NSString *)themeName key:(NSString *)key 
               orientation:(UIInterfaceOrientation)orientation
              iPadSpecific:(BOOL)iPadSpecific;
- (UIImage *)imageFor:(NSString *)imageTitle 
          orientation:(UIInterfaceOrientation)orientation;
- (UIImage *)imageFor:(NSString *)imageTitle 
          orientation:(UIInterfaceOrientation)orientation 
         iPadSpecific:(BOOL)iPadSpecific;
- (UIImage *)imageForButton:(UIInterfaceOrientation)orientation;
- (UIImage *)imageForDoneButton:(UIInterfaceOrientation)orientation;
- (UIImage *)imageForNavigationBar:(UIInterfaceOrientation)orientation;
- (UIImage *)imageForBackground:(UIInterfaceOrientation)orientation;
- (UIImage *)imageForShelf:(UIInterfaceOrientation)orientation;
- (UIImage *)imageForHomeIcon:(UIInterfaceOrientation)orientation;
- (UIImage *)imageForBooksIcon:(UIInterfaceOrientation)orientation;
- (UIImage *)imageForThemeIcon:(UIInterfaceOrientation)orientation;
- (UIColor *)colorForListBackground;


@end
