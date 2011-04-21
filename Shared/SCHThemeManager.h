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

@interface SCHThemeManager : NSObject 
{
    
}

@property (nonatomic, retain) NSString *theme;

+ (SCHThemeManager *)sharedThemeManager;

- (NSArray *)themeNames:(BOOL)excludeSelectedTheme;
- (UIImage *)imageForTheme:(NSString *)themeName key:(NSString *)key orientation:(UIInterfaceOrientation)orientation;

- (UIImage *)imageFor:(NSString *)imageTitle orientation:(UIInterfaceOrientation)orientation;
- (UIImage *)imageForButton:(UIInterfaceOrientation)orientation;
- (UIImage *)imageForDoneButton:(UIInterfaceOrientation)orientation;
- (UIImage *)imageForNavigationBar:(UIInterfaceOrientation)orientation;
- (UIImage *)imageForTableViewCell:(UIInterfaceOrientation)orientation;
- (UIImage *)imageForBackground:(UIInterfaceOrientation)orientation;
- (UIImage *)imageForShelf:(UIInterfaceOrientation)orientation;
- (UIImage *)imageForHomeIcon:(UIInterfaceOrientation)orientation;
- (UIImage *)imageForBooksIcon:(UIInterfaceOrientation)orientation;
- (UIImage *)imageForThemeIcon:(UIInterfaceOrientation)orientation;


@end
