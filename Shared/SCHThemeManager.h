//
//  SCHThemeManager.h
//  Scholastic
//
//  Created by John S. Eddie on 15/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const kSCHThemeManagerThemeChangeNotification = @"SCHThemeManagerThemeChangeNotification";

static NSString * const kSCHThemeManagerDefault = @"Default";

static NSString * const kSCHThemeManagerImage = @"Image";

static NSString * const kSCHThemeManagerButtonImage = @"ButtonImage";
static NSString * const kSCHThemeManagerDoneButtonImage = @"DoneButtonImage";
static NSString * const kSCHThemeManagerNavigationBarImage = @"NavigationBarImage";
static NSString * const kSCHThemeManagerTableViewCellImage = @"TableViewCellImage";
static NSString * const kSCHThemeManagerBackgroundImage = @"BackgroundImage";
static NSString * const kSCHThemeManagerShelfImage = @"ShelfImage";
static NSString * const kSCHThemeManagerHomeIcon = @"HomeIcon";
static NSString * const kSCHThemeManagerBooksIcon = @"BooksIcon";
static NSString * const kSCHThemeManagerThemeIcon = @"ThemeIcon";

@interface SCHThemeManager : NSObject {
    
}

@property (nonatomic, retain) NSString *theme;

+ (SCHThemeManager *)sharedThemeManager;

- (NSArray *)themeNames:(BOOL)excludeSelectedTheme;
- (UIImage *)imageForTheme:(NSString *)themeName key:(NSString *)key;

- (UIImage *)imageFor:(NSString *)imageTitle;
- (UIImage *)imageForButton;
- (UIImage *)imageForDoneButton;
- (UIImage *)imageForNavigationBar;
- (UIImage *)imageForTableViewCell;
- (UIImage *)imageForBackground;
- (UIImage *)imageForShelf;
- (UIImage *)imageForHomeIcon;
- (UIImage *)imageForBooksIcon;
- (UIImage *)imageForThemeIcon;


@end
