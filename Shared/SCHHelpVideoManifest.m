//
//  SCHHelpVideoManifest.m
//  Scholastic
//
//  Created by Gordon Christie on 18/10/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import "SCHHelpVideoManifest.h"

#pragma mark Help Videos Manifest Class

@interface SCHHelpVideoManifest ()

- (NSString *)currentDeviceForAgeString: (NSString *)ageSearch;

@end

@implementation SCHHelpVideoManifest

@synthesize manifestURLs;

- (id)init
{
    self = [super init];
    
    if (self) {
        self.manifestURLs = [[[NSMutableDictionary alloc] init] autorelease];
    }
    
    return self;
}

- (void)dealloc
{
    [manifestURLs release], manifestURLs = nil;
    [super dealloc];
}


- (NSDictionary*)itemsForCurrentDevice
{
    BOOL iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    
    NSString *searchFor = @"iPhone";
    
    if (iPad) {
        searchFor = @"iPad";
    }
    
    NSMutableDictionary *returnedItems = [[[NSMutableDictionary alloc] init] autorelease];
    
    for (NSString *item in [manifestURLs allKeys]) {
        NSRange range = [item rangeOfString:searchFor options:NSCaseInsensitiveSearch];
        if (range.location != NSNotFound) {
            [returnedItems setValue:[manifestURLs objectForKey:item] forKey:item];
        }
    }
        
    return [NSDictionary dictionaryWithDictionary:returnedItems];
}

- (NSString *)olderURLForCurrentDevice
{
    return [self currentDeviceForAgeString:@"Old"];
}

- (NSString *)youngerURLForCurrentDevice
{
    return [self currentDeviceForAgeString:@"Young"];
}

- (NSString *)currentDeviceForAgeString: (NSString *)ageSearch
{
    BOOL iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    
    NSString *deviceSearch = @"iPhone";
    
    if (iPad) {
        deviceSearch = @"iPad";
    }
    
    for (NSString *key in [manifestURLs allKeys]) {
        if ([key rangeOfString:ageSearch options:NSCaseInsensitiveSearch].location != NSNotFound) {
            if ([key rangeOfString:deviceSearch options:NSCaseInsensitiveSearch].location != NSNotFound) {
                return [self.manifestURLs objectForKey:key];
            }
        }
    }
    
    return nil;
}

@end
