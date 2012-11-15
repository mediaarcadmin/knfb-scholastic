//
//  SCHAppBookFeaturesTests.m
//  Scholastic
//
//  Created by John S. Eddie on 14/11/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHAppBookFeaturesTests.h"

#import "SCHAppBookFeatures.h"

@implementation SCHAppBookFeaturesTests

#pragma mark - General Tests

- (void)testFeaturesWithNone
{
    SCHAppBookFeatures *appBookFeatures = [[[SCHAppBookFeatures alloc] init] autorelease];

    STAssertFalse(appBookFeatures.hasStoryInteractions, @"features set to none should not have story interactions");
    STAssertFalse(appBookFeatures.hasAudio, @"features set to none should not have audio");
    STAssertFalse(appBookFeatures.isSample, @"features set to none should not been a sample");
}


@end
