//
//  SCHAppState.m
//  Scholastic
//
//  Created by John S. Eddie on 09/05/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import "SCHAppState.h"

// Constants
NSString * const kSCHAppState = @"SCHAppState";

NSString * const kSCHAppStatefetchAppState = @"fetchAppState";

@implementation SCHAppState

@dynamic ShouldSync;
@dynamic ShouldAuthenticate;
@dynamic DataStoreType;
@dynamic ShouldSyncNotes;

@end
