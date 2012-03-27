//
//  SCHThemeManager.m
//  Scholastic
//
//  Created by John S. Eddie on 15/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHThemeManager.h"

#import "SCHAppProfile.h"
#import "UIColor+Extensions.h"

static SCHThemeManager *sharedThemeManager = nil;

// Constants
NSString * const kSCHThemeManagerThemeChangeNotification = @"SCHThemeManagerThemeChangeNotification";

NSString * const kSCHThemeManagerDefault = @"Default";

NSString * const kSCHThemeManagerImage = @"Image";

NSString * const kSCHThemeManagerButtonImage = @"ButtonImage";
NSString * const kSCHThemeManagerDoneButtonImage = @"DoneButtonImage";
NSString * const kSCHThemeManagerNavigationBarImage = @"NavigationBarImage";
NSString * const kSCHThemeManagerBackgroundImage = @"BackgroundImage";
NSString * const kSCHThemeManagerShelfImage = @"ShelfImage";
NSString * const kSCHThemeManagerHomeIcon = @"HomeIcon";
NSString * const kSCHThemeManagerThemeIcon = @"ThemeIcon";
NSString * const kSCHThemeManagerRatingsIcon = @"RatingsIcon";
NSString * const kSCHThemeManagerRatingsSelectedIcon = @"RatingsSelectedIcon";
NSString * const kSCHThemeManagerColorForListBackground = @"ListBackgroundColor";
NSString * const kSCHThemeManagerColorForPopoverBackground = @"PopoverBackgroundColor";
NSString * const kSCHThemeManagerGridTextColorIsDark = @"GridTextColorIsDark";

static NSString * const kSCHThemeManagerDirectory = @"Themes";
static NSString * const kSCHThemeManagerLandscapePostFix = @"-Landscape";
static NSString * const kSCHThemeManageriPadPostFix = @"-iPad";
static NSString * const kSCHThemeManagerRetinaSuffix = @"@2x";

static NSString * const kSCHThemeManagerID = @"id";
static NSString * const kSCHThemeManagerName = @"Name";

@interface SCHThemeManager ()

@property (nonatomic, retain) NSArray *allThemes;
@property (nonatomic, retain) NSDictionary *selectedTheme;

- (NSString *)filePath:(NSString *)filePath orientation:(UIInterfaceOrientation)orientation;
- (NSString *)filePath:(NSString *)filePath orientation:(UIInterfaceOrientation)orientation iPadQualifier:(SCHThemeManagerPadQualifier)iPadQualifier;

@end

@implementation SCHThemeManager

@synthesize theme;
@synthesize allThemes;
@synthesize selectedTheme;
@synthesize appProfile;

#pragma mark - Singleton Instance methods

+ (SCHThemeManager *)sharedThemeManager
{
    if (sharedThemeManager == nil) {
        sharedThemeManager = [[super allocWithZone:NULL] init];		
    }
	
    return(sharedThemeManager);
}

#pragma mark - Object lifecycle

- (id)init
{
	self = [super init];
	if (self != nil) {
        allThemes = [[NSArray arrayWithContentsOfFile:
                          [[NSBundle mainBundle] pathForResource:@"Themes" 
                                                          ofType:@"plist" 
                                                     inDirectory:kSCHThemeManagerDirectory]] retain];

        if ([allThemes count] > 0) {
            for (NSDictionary *dict in allThemes) {
                if ([[dict objectForKey:kSCHThemeManagerDefault] boolValue] == YES) {
                    selectedTheme = [dict retain];
                    break;
                }
            }            
        } else {
            [NSException raise:@"NoThemesException" 
                        format:@"Themes.plist has no configured Themes!"];
        }
        
	}
	return(self);
}

- (void)dealloc 
{
    [theme release], theme = nil;
    [allThemes release], allThemes = nil;
    [selectedTheme release], selectedTheme = nil;
    
    [super dealloc];
}

#pragma mark - Accessor methods

- (void)setAppProfile:(SCHAppProfile *)newAppProfile
{
    if (appProfile != newAppProfile) {
        [newAppProfile retain];
        [appProfile release];
        appProfile = newAppProfile;
        
        if (appProfile != nil && [appProfile.SelectedTheme integerValue] > 0) {
            for (NSDictionary *dict in allThemes) {
                NSInteger profileSelectedTheme = [appProfile.SelectedTheme integerValue];
                if ([[dict objectForKey:kSCHThemeManagerID] integerValue] == profileSelectedTheme) {
                    selectedTheme = [dict retain];
                    break;
                }
            }            
        } else {
            for (NSDictionary *dict in allThemes) {
                if ([[dict objectForKey:kSCHThemeManagerDefault] boolValue] == YES) {
                    selectedTheme = [dict retain];
                    break;
                }
            }            
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kSCHThemeManagerThemeChangeNotification 
                                                            object:self 
                                                          userInfo:nil];				                    
    }
}

- (void)setTheme:(NSString *)themeName
{    
    if (themeName != nil) {
        for (NSDictionary *dict in self.allThemes) {
            if ([[dict objectForKey:kSCHThemeManagerName] isEqualToString:themeName] == YES) {
                self.selectedTheme = dict;
                appProfile.SelectedTheme = [self.selectedTheme objectForKey:kSCHThemeManagerID];
                [[NSNotificationCenter defaultCenter] postNotificationName:kSCHThemeManagerThemeChangeNotification 
                                                                    object:self 
                                                                  userInfo:nil];				            
                break;
            }
        }
    }
}

- (NSString *)theme
{
    return([self.selectedTheme objectForKey:kSCHThemeManagerName]);
}

#pragma mark - methods

- (NSArray *)themeNames:(BOOL)excludeSelectedTheme
{
    NSMutableArray *ret = [NSMutableArray array];
    
    for (NSDictionary *dict in self.allThemes) {
        if (excludeSelectedTheme == NO || dict != self.selectedTheme) {
            NSString *themeName = [dict objectForKey:kSCHThemeManagerName];
            if (themeName != nil) {
                [ret addObject:themeName];
            }
        }
    }
    
    return(ret);
}

#pragma mark - Image Accessors

- (UIImage *)imageForTheme:(NSString *)themeName key:(NSString *)key orientation:(UIInterfaceOrientation)orientation
{
    return [self imageForTheme:themeName key:key orientation:orientation iPadQualifier:kSCHThemeManagerPadQualifierNone];
}

- (UIImage *)imageForTheme:(NSString *)themeName key:(NSString *)key 
               orientation:(UIInterfaceOrientation)orientation
              iPadQualifier:(SCHThemeManagerPadQualifier)iPadQualifier
{
    UIImage *ret = nil;
    
    if (themeName != nil) {
        for (NSDictionary *dict in self.allThemes) {
            if ([[dict objectForKey:kSCHThemeManagerName] isEqualToString:themeName] == YES) {
                ret = [UIImage imageNamed:[kSCHThemeManagerDirectory 
                                           stringByAppendingPathComponent:[self filePath:[dict objectForKey:key] 
                                                                             orientation:orientation iPadQualifier:iPadQualifier]]];
                break;
            }
        }
    }
    
    return(ret);
}

- (UIImage *)imageFor:(NSString *)imageTitle orientation:(UIInterfaceOrientation)orientation
{
    return([UIImage imageNamed:[kSCHThemeManagerDirectory 
                                stringByAppendingPathComponent:[self filePath:[self.selectedTheme objectForKey:imageTitle] orientation:orientation]]]);
}

- (UIImage *)imageFor:(NSString *)imageTitle orientation:(UIInterfaceOrientation)orientation iPadQualifier:(SCHThemeManagerPadQualifier)iPadQualifier
{
    return([UIImage imageNamed:[kSCHThemeManagerDirectory 
                                stringByAppendingPathComponent:[self filePath:[self.selectedTheme objectForKey:imageTitle] orientation:orientation iPadQualifier:iPadQualifier]]]);
}

- (UIImage *)imageForButton:(UIInterfaceOrientation)orientation
{
    return([UIImage imageNamed:[kSCHThemeManagerDirectory 
                                stringByAppendingPathComponent:[self filePath:[self.selectedTheme objectForKey:kSCHThemeManagerButtonImage] 
                                                                  orientation:orientation]]]);
}

- (UIImage *)imageForDoneButton:(UIInterfaceOrientation)orientation
{
    return([UIImage imageNamed:[kSCHThemeManagerDirectory 
                                stringByAppendingPathComponent:[self filePath:[self.selectedTheme objectForKey:kSCHThemeManagerDoneButtonImage] 
                                                                  orientation:orientation]]]);
}

- (UIImage *)imageForNavigationBar:(UIInterfaceOrientation)orientation
{
    return([UIImage imageNamed:[kSCHThemeManagerDirectory 
                                stringByAppendingPathComponent:[self filePath:[self.selectedTheme objectForKey:kSCHThemeManagerNavigationBarImage] 
                                                                  orientation:orientation iPadQualifier:kSCHThemeManagerPadQualifierSuffix]]]);
    
}

- (UIImage *)imageForBackground:(UIInterfaceOrientation)orientation
{
    return([UIImage imageNamed:[kSCHThemeManagerDirectory 
                                stringByAppendingPathComponent:[self filePath:[self.selectedTheme objectForKey:kSCHThemeManagerBackgroundImage] 
                                                                  orientation:orientation iPadQualifier:kSCHThemeManagerPadQualifierRetina]]]);
}

- (UIImage *)imageForShelf:(UIInterfaceOrientation)orientation
{
    return([UIImage imageNamed:[kSCHThemeManagerDirectory 
                                stringByAppendingPathComponent:[self filePath:[self.selectedTheme objectForKey:kSCHThemeManagerShelfImage]
                                                                  orientation:orientation
                                                                 iPadQualifier:kSCHThemeManagerPadQualifierSuffix]]]);
}

- (UIImage *)imageForHomeIcon:(UIInterfaceOrientation)orientation
{
    return([UIImage imageNamed:[kSCHThemeManagerDirectory 
                                stringByAppendingPathComponent:[self filePath:[self.selectedTheme objectForKey:kSCHThemeManagerHomeIcon]
                                                                  orientation:orientation]]]);
}

- (UIImage *)imageForThemeIcon:(UIInterfaceOrientation)orientation
{
    return([UIImage imageNamed:[kSCHThemeManagerDirectory 
                                stringByAppendingPathComponent:[self filePath:[self.selectedTheme objectForKey:kSCHThemeManagerThemeIcon]
                                                                  orientation:orientation]]]);
}

- (UIColor *)colorForListBackground
{
    return ([UIColor BITcolorWithHexString:[self.selectedTheme objectForKey:kSCHThemeManagerColorForListBackground]]);
}

- (UIColor *)colorForPopoverBackground
{
    return ([UIColor BITcolorWithHexString:[self.selectedTheme objectForKey:kSCHThemeManagerColorForPopoverBackground]]);
}

- (BOOL)gridTextColorIsDark
{
    return [[self.selectedTheme objectForKey:kSCHThemeManagerGridTextColorIsDark] boolValue];
}

- (void)resetToDefault
{
    for (NSDictionary *dict in self.allThemes) {
        if ([[dict objectForKey:kSCHThemeManagerDefault] boolValue] == YES) {
            [self setTheme:[dict valueForKey:kSCHThemeManagerName]];
            break;
        }
    }
}

#pragma mark - Private methods

- (NSString *)filePath:(NSString *)filePath orientation:(UIInterfaceOrientation)orientation
{
    return [self filePath:filePath orientation:orientation iPadQualifier:kSCHThemeManagerPadQualifierNone];
}

- (NSString *)filePath:(NSString *)filePath orientation:(UIInterfaceOrientation)orientation iPadQualifier:(SCHThemeManagerPadQualifier)iPadQualifier
{
    NSString *fullPath = nil;
    NSString *trimmedPath = [filePath stringByDeletingPathExtension];
    NSString *extension = [filePath pathExtension];
    
    if (![extension length]) {
        extension = @"png";
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone || (iPadQualifier == kSCHThemeManagerPadQualifierNone)) {
        if (UIInterfaceOrientationIsLandscape(orientation) == YES) {
            fullPath = [NSString stringWithFormat:@"%@%@.%@", trimmedPath, kSCHThemeManagerLandscapePostFix, extension];
        } else {
            fullPath = [NSString stringWithFormat:@"%@.%@", trimmedPath, extension];
        }
    } else if (iPadQualifier == kSCHThemeManagerPadQualifierSuffix) {
        
        if (UIInterfaceOrientationIsLandscape(orientation) == YES) {
            fullPath = [NSString stringWithFormat:@"%@%@%@.%@", trimmedPath, kSCHThemeManagerLandscapePostFix, kSCHThemeManageriPadPostFix, extension];
        } else {
            fullPath = [NSString stringWithFormat:@"%@%@.%@", trimmedPath, kSCHThemeManageriPadPostFix, extension];
        }
    } else if (iPadQualifier == kSCHThemeManagerPadQualifierRetina) {
        
        if (UIInterfaceOrientationIsLandscape(orientation) == YES) {
            fullPath = [NSString stringWithFormat:@"%@%@%@.%@", trimmedPath, kSCHThemeManagerLandscapePostFix, kSCHThemeManagerRetinaSuffix, extension];
        } else {
            fullPath = [NSString stringWithFormat:@"%@%@.%@", trimmedPath, kSCHThemeManagerRetinaSuffix, extension];
        }
    }
    
    return fullPath;
}

@end
