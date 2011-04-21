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
static NSString * const kSCHThemeManagerLandscapePostFix = @"-Landscape";

static NSString * const kSCHThemeManagerID = @"id";
static NSString * const kSCHThemeManagerName = @"Name";

static NSString * const kSCHThemeManagerSelectedTheme = @"ThemeManagerSelectedTheme";

@interface SCHThemeManager ()

@property (nonatomic, retain) NSArray *allThemes;
@property (nonatomic, retain) NSDictionary *selectedTheme;

- (NSString *)filePath:(NSString *)filePath orientation:(UIInterfaceOrientation)orientation;

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

#pragma mark -
#pragma mark Image Accessors

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

- (UIImage *)imageForTableViewCell:(UIInterfaceOrientation)orientation
{
    return([UIImage imageNamed:[kSCHThemeManagerDirectory 
                                stringByAppendingPathComponent:[self filePath:[self.selectedTheme objectForKey:kSCHThemeManagerTableViewCellImage] 
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
                                                                  orientation:orientation]]]);
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

#pragma mark -
#pragma mark Private methods

- (NSString *)filePath:(NSString *)filePath orientation:(UIInterfaceOrientation)orientation
{
    if (UIInterfaceOrientationIsLandscape(orientation) == YES) {
        return([NSString stringWithFormat:@"%@%@", filePath, kSCHThemeManagerLandscapePostFix]);
    } else {
        return(filePath);
    }
}

@end
