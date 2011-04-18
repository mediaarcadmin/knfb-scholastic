//
//  SCHThemeManager.m
//  Scholastic
//
//  Created by John S. Eddie on 15/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHThemeManager.h"

static SCHThemeManager *sharedThemeManager = nil;

static NSString * const kSCHThemeManagerButtonImage = @"ButtonImage";
static NSString * const kSCHThemeManagerDoneButtonImage = @"DoneButtonImage";
static NSString * const kSCHThemeManagerNavigationBarImage = @"NavigationBarImage";
static NSString * const kSCHThemeManagerTableViewCellImage = @"TableViewCellImage";
static NSString * const kSCHThemeManagerBackgroundImage = @"BackgroundImage";
static NSString * const kSCHThemeManagerShelfImage = @"ShelfImage";
static NSString * const kSCHThemeManagerHomeIcon = @"HomeIcon";
static NSString * const kSCHThemeManagerBooksIcon = @"BooksIcon";
static NSString * const SCHThemeManagerkThemeIcon = @"ThemeIcon";

@interface SCHThemeManager ()

@property (nonatomic, retain) NSArray *themes;
@property (nonatomic, retain) NSDictionary *currentTheme;

@end

@implementation SCHThemeManager

@synthesize themes;
@synthesize currentTheme;

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
        self.themes = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Themes/Themes" ofType:@"plist"]];
        self.currentTheme = [self.themes objectAtIndex:1];
	}
	return(self);
}

- (void)dealloc 
{
    self.themes = nil;
    self.currentTheme = nil;
    
    [super dealloc];
}

#pragma mark -
#pragma mark methods

- (NSArray *)themeNames
{
    NSMutableArray *ret = [NSMutableArray array];
    
    for (NSDictionary *dict in self.themes) {
        [ret addObject:[dict objectForKey:@"Name"]];
    }
    
    return(ret);
}

- (UIImage *)imageForButton
{
    return([UIImage imageNamed:[self.currentTheme objectForKey:kSCHThemeManagerButtonImage]]);
}

- (UIImage *)imageForDoneButton
{
    return([UIImage imageNamed:[self.currentTheme objectForKey:kSCHThemeManagerDoneButtonImage]]);
}

- (UIImage *)imageForNavigationBar
{
    return([UIImage imageNamed:[self.currentTheme objectForKey:kSCHThemeManagerNavigationBarImage]]);
}

- (UIImage *)imageForTableViewCell
{
    return([UIImage imageNamed:[self.currentTheme objectForKey:kSCHThemeManagerTableViewCellImage]]);
}

- (UIImage *)imageForBackground
{
    return([UIImage imageNamed:[self.currentTheme objectForKey:kSCHThemeManagerBackgroundImage]]);
}

- (UIImage *)imageForShelf
{
    return([UIImage imageNamed:[self.currentTheme objectForKey:kSCHThemeManagerShelfImage]]);
}

- (UIImage *)imageForHomeIcon
{
    return([UIImage imageNamed:[self.currentTheme objectForKey:kSCHThemeManagerHomeIcon]]);
}

- (UIImage *)imageForBooksIcon
{
    return([UIImage imageNamed:[self.currentTheme objectForKey:kSCHThemeManagerBooksIcon]]);
}

- (UIImage *)imageForThemeIcon
{
    return([UIImage imageNamed:[self.currentTheme objectForKey:SCHThemeManagerkThemeIcon]]);
}

@end
