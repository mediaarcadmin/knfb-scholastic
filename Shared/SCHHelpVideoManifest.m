//
//  SCHHelpVideoManifest.m
//  Scholastic
//
//  Created by Gordon Christie on 18/10/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import "SCHHelpVideoManifest.h"

#pragma mark Help Videos Manifest Class

@implementation SCHHelpVideoManifest

@synthesize manifestURLs;

- (id)init
{
    self = [super init];
    
    if (self) {
        self.manifestURLs = [[NSMutableDictionary alloc] init];
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

@end
