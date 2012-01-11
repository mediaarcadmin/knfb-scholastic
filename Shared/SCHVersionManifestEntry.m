//
//  SCHVersionManifestEntry.m
//  Scholastic
//
//  Created by John Eddie on 23/12/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import "SCHVersionManifestEntry.h"

@implementation SCHVersionManifestEntry

@synthesize fromVersion;
@synthesize toVersion;
@synthesize forced;

#pragma mark - Object Lifecycle

- (void)dealloc
{
    [fromVersion release], fromVersion = nil;
    [toVersion release], toVersion = nil;
    [forced release], forced = nil;
    
    [super dealloc];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ to %@, %@", fromVersion, toVersion, forced];
}

@end
