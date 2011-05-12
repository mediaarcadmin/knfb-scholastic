//
//  SCHThemeManager.m
//  Scholastic
//
//  Created by John S. Eddie on 15/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHThemeManager.h"

#import "SCHAppProfile.h"

static SCHThemeManager *sharedThemeManager = nil;

static NSString * const kSCHThemeManagerDirectory = @"Themes";
static NSString * const kSCHThemeManagerLandscapePostFix = @"-Landscape";
static NSString * const kSCHThemeManageriPadPostFix = @"-iPad";

static NSString * const kSCHThemeManagerID = @"id";
static NSString * const kSCHThemeManagerName = @"Name";

@interface SCHThemeManager ()

@property (nonatomic, retain) NSArray *allThemes;
@property (nonatomic, retain) NSDictionary *selectedTheme;

- (NSString *)filePath:(NSString *)filePath orientation:(UIInterfaceOrientation)orientation;
- (NSString *)filePath:(NSString *)filePath orientation:(UIInterfaceOrientation)orientation iPadSpecific: (BOOL) iPadSpecific;

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
            [ret addObject:[dict objectForKey:kSCHThemeManagerName]];
        }
    }
    
    return(ret);
}

#pragma mark - Image Accessors

- (UIImage *)imageForTheme:(NSString *)themeName key:(NSString *)key orientation:(UIInterfaceOrientation)orientation
{
    UIImage *ret = nil;
    
    for (NSDictionary *dict in self.allThemes) {
        if ([[dict objectForKey:kSCHThemeManagerName] isEqualToString:themeName] == YES) {
            ret = [UIImage imageNamed:[kSCHThemeManagerDirectory 
                                       stringByAppendingPathComponent:[self filePath:[dict objectForKey:key] 
                                                                         orientation:orientation]]];
            break;
        }
    }
    
    return(ret);
}

- (UIImage *)imageFor:(NSString *)imageTitle orientation:(UIInterfaceOrientation)orientation
{
    return([UIImage imageNamed:[kSCHThemeManagerDirectory 
                                stringByAppendingPathComponent:[self filePath:[self.selectedTheme objectForKey:imageTitle] orientation:orientation]]]);
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
                                                                  orientation:orientation]]]);
    
}

- (UIImage *)imageForBackground:(UIInterfaceOrientation)orientation
{
    return([UIImage imageNamed:[kSCHThemeManagerDirectory 
                                stringByAppendingPathComponent:[self filePath:[self.selectedTheme objectForKey:kSCHThemeManagerBackgroundImage] 
                                                                  orientation:orientation]]]);
}

- (UIImage *)imageForShelf:(UIInterfaceOrientation)orientation
{
    return([UIImage imageNamed:[kSCHThemeManagerDirectory 
                                stringByAppendingPathComponent:[self filePath:[self.selectedTheme objectForKey:kSCHThemeManagerShelfImage]
                                                                  orientation:orientation
                                                                 iPadSpecific:YES]]]);
}

- (UIImage *)imageForHomeIcon:(UIInterfaceOrientation)orientation
{
    return([UIImage imageNamed:[kSCHThemeManagerDirectory 
                                stringByAppendingPathComponent:[self filePath:[self.selectedTheme objectForKey:kSCHThemeManagerHomeIcon]
                                                                  orientation:orientation]]]);
}

- (UIImage *)imageForBooksIcon:(UIInterfaceOrientation)orientation
{
    return([UIImage imageNamed:[kSCHThemeManagerDirectory 
                                stringByAppendingPathComponent:[self filePath:[self.selectedTheme objectForKey:kSCHThemeManagerBooksIcon]
                                                                  orientation:orientation]]]);
}

- (UIImage *)imageForThemeIcon:(UIInterfaceOrientation)orientation
{
    return([UIImage imageNamed:[kSCHThemeManagerDirectory 
                                stringByAppendingPathComponent:[self filePath:[self.selectedTheme objectForKey:kSCHThemeManagerThemeIcon]
                                                                  orientation:orientation]]]);
}

#pragma mark - Private methods

- (NSString *)filePath:(NSString *)filePath orientation:(UIInterfaceOrientation)orientation
{
    return [self filePath:filePath orientation:orientation iPadSpecific:NO];
}

- (NSString *)filePath:(NSString *)filePath orientation:(UIInterfaceOrientation)orientation iPadSpecific: (BOOL) iPadSpecific
{
    NSString *fullPath = nil;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone || !iPadSpecific) {
        if (UIInterfaceOrientationIsLandscape(orientation) == YES) {
            fullPath = [NSString stringWithFormat:@"%@%@", filePath, kSCHThemeManagerLandscapePostFix];
        } else {
            fullPath = filePath;
        }
    } else {
        
        if (UIInterfaceOrientationIsLandscape(orientation) == YES) {
            fullPath = [NSString stringWithFormat:@"%@%@%@", filePath, kSCHThemeManagerLandscapePostFix, kSCHThemeManageriPadPostFix];
        } else {
            fullPath = [NSString stringWithFormat:@"%@%@", filePath, kSCHThemeManageriPadPostFix];
        }
    }
    
    return fullPath;
}

@end
