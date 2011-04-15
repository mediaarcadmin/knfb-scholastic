//
//  SCHThemeManager.m
//  Scholastic
//
//  Created by John S. Eddie on 15/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHThemeManager.h"

static SCHThemeManager *sharedThemeManager = nil;

@interface SCHThemeManager ()

@property (nonatomic, retain) NSArray *themes;

@end

@implementation SCHThemeManager

@synthesize themes;

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
        self.themes =  [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Themes/Themes" ofType:@"plist"]];
	}
	return(self);
}

- (void)dealloc {
    self.themes = nil;
    
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

@end
