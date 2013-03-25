//
//  SCHAppDictionaryManifestEntry.m
//  Scholastic
//
//  Created by Neil Gall on 26/10/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import "SCHAppDictionaryManifestEntry.h"
#import "SCHAppDictionaryState.h"

// Constants
NSString * const kSCHAppDictionaryManifestEntry = @"SCHAppDictionaryManifestEntry";

@implementation SCHAppDictionaryManifestEntry

@dynamic category;
@dynamic size;
@dynamic state;
@dynamic toVersion;
@dynamic url;
@dynamic appDictionaryState;

@end
