//
//  SCHThemeManager.m
//  Scholastic
//
//  Created by John S. Eddie on 15/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHThemeManager.h"

static SCHThemeManager *sharedThemeManager = nil;

static NSString * const kSCHThemeManagerDirectory = @"Themes";

static NSString * const kSCHThemeManagerID = @"id";
static NSString * const kSCHThemeManagerName = @"Name";

static NSString * const kSCHThemeManagerSelectedTheme = @"ThemeManagerSelectedTheme";

@interface SCHThemeManager ()

@property (nonatomic, retain) NSArray *allThemes;
@property (nonatomic, retain) NSDictionary *selectedTheme;

@end

@implementation SCHThemeManager

@dynamic theme;
@synthesize allThemes;
@synthesize selectedTheme;

#pragma mark -
#pragma mark Singleton Instance methods

+ (SCHThemeManager *)sharedThemeManager
{
    if (sharedThemeManager == nil) {
        sharedThemeManager = [[super allocWithZone:NULL] init];		
    }
	
    return(sharedThemeManager);
}

#pragma mark -
#pragma mark methods

- (id)init
{
	self = [super init];
	if (self != nil) {
        self.allThemes = [NSArray arrayWithContentsOfFile:
                          [[NSBundle mainBundle] pathForResource:@"Themes" 
                                                          ofType:@"plist" 
                                                     inDirectory:kSCHThemeManagerDirectory]];

        if ([self.allThemes count] > 0) {
            NSInteger userSelectedTheme = [[NSUserDefaults standardUserDefaults] integerForKey:kSCHThemeManagerSelectedTheme];
            if (userSelectedTheme > 0) {
                for (NSDictionary *dict in self.allThemes) {
                    if ([[dict objectForKey:kSCHThemeManagerID] integerValue] == userSelectedTheme) {
                        self.selectedTheme = dict;
                        break;
                    }
                }            
            }

            // if we couldnt find a theme use the default
            if (self.selectedTheme == nil) {
                for (NSDictionary *dict in self.allThemes) {
                    if ([[dict objectForKey:kSCHThemeManagerDefault] boolValue] == YES) {
                        self.selectedTheme = dict;
                        break;
                    }
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
    self.allThemes = nil;
    self.selectedTheme = nil;
    
    [super dealloc];
}

- (void)setTheme:(NSString *)themeName
{    
    for (NSDictionary *dict in self.allThemes) {
        if ([[dict objectForKey:kSCHThemeManagerName] isEqualToString:themeName] == YES) {
            self.selectedTheme = dict;
            [[NSUserDefaults standardUserDefaults] setInteger:
             [[self.selectedTheme objectForKey:kSCHThemeManagerID] integerValue] forKey:kSCHThemeManagerSelectedTheme];
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

- (UIImage *)imageForTheme:(NSString *)themeName key:(NSString *)key
{
    UIImage *ret = nil;
    
    for (NSDictionary *dict in self.allThemes) {
        if ([[dict objectForKey:kSCHThemeManagerName] isEqualToString:themeName] == YES) {
            ret = [UIImage imageNamed:[kSCHThemeManagerDirectory stringByAppendingPathComponent:[dict objectForKey:key]]];
            break;
        }
    }
    
    return(ret);
}

#pragma mark -
#pragma mark Image Accessors

- (UIImage *)imageFor:(NSString *)imageTitle
{
    return([UIImage imageNamed:[kSCHThemeManagerDirectory stringByAppendingPathComponent:[self.selectedTheme objectForKey:imageTitle]]]);
}

- (UIImage *)imageForButton
{
    return([UIImage imageNamed:[kSCHThemeManagerDirectory stringByAppendingPathComponent:[self.selectedTheme objectForKey:kSCHThemeManagerButtonImage]]]);
}

- (UIImage *)imageForDoneButton
{
    return([UIImage imageNamed:[kSCHThemeManagerDirectory stringByAppendingPathComponent:[self.selectedTheme objectForKey:kSCHThemeManagerDoneButtonImage]]]);
}

- (UIImage *)imageForNavigationBar
{
    return([UIImage imageNamed:[kSCHThemeManagerDirectory stringByAppendingPathComponent:[self.selectedTheme objectForKey:kSCHThemeManagerNavigationBarImage]]]);
    
}

- (UIImage *)imageForTableViewCell
{
    return([UIImage imageNamed:[kSCHThemeManagerDirectory stringByAppendingPathComponent:[self.selectedTheme objectForKey:kSCHThemeManagerTableViewCellImage]]]);
}

- (UIImage *)imageForBackground
{
    return([UIImage imageNamed:[kSCHThemeManagerDirectory stringByAppendingPathComponent:[self.selectedTheme objectForKey:kSCHThemeManagerBackgroundImage]]]);
}

- (UIImage *)imageForShelf
{
    return([UIImage imageNamed:[kSCHThemeManagerDirectory stringByAppendingPathComponent:[self.selectedTheme objectForKey:kSCHThemeManagerShelfImage]]]);
}

- (UIImage *)imageForHomeIcon
{
    return([UIImage imageNamed:[kSCHThemeManagerDirectory stringByAppendingPathComponent:[self.selectedTheme objectForKey:kSCHThemeManagerHomeIcon]]]);
}

- (UIImage *)imageForBooksIcon
{
    return([UIImage imageNamed:[kSCHThemeManagerDirectory stringByAppendingPathComponent:[self.selectedTheme objectForKey:kSCHThemeManagerBooksIcon]]]);
}

- (UIImage *)imageForThemeIcon
{
    return([UIImage imageNamed:[kSCHThemeManagerDirectory stringByAppendingPathComponent:[self.selectedTheme objectForKey:kSCHThemeManagerThemeIcon]]]);
}

@end
