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

    STAssertTrue(appBookFeatures.features == kSCHAppBookFeaturesNone, @"features should be set to none");
    STAssertFalse(appBookFeatures.hasStoryInteractions, @"features set to none should not have story interactions");
    STAssertFalse(appBookFeatures.hasAudio, @"features set to none should not have audio");
    STAssertFalse(appBookFeatures.isSample, @"features set to none should not be a sample");

    appBookFeatures = [[[SCHAppBookFeatures alloc] initWithStoryInteractions:NO
                                                                       audio:NO
                                                                      sample:NO] autorelease];

    STAssertTrue(appBookFeatures.features == kSCHAppBookFeaturesNone, @"features should be set to none");
    STAssertFalse(appBookFeatures.hasStoryInteractions, @"features set to none should not have story interactions");
    STAssertFalse(appBookFeatures.hasAudio, @"features set to none should not have audio");
    STAssertFalse(appBookFeatures.isSample, @"features set to none should not be a sample");
}

- (void)testFeaturesWithStoryInteractions
{
    SCHAppBookFeatures *appBookFeatures = [[[SCHAppBookFeatures alloc] initWithStoryInteractions:YES
                                                                                           audio:NO
                                                                                          sample:NO] autorelease];

    STAssertTrue(appBookFeatures.features == kSCHAppBookFeaturesStoryInteractions, @"features should be set to story interactions");
    STAssertTrue(appBookFeatures.hasStoryInteractions, @"features set to story interactions should have story interactions");
    STAssertFalse(appBookFeatures.hasAudio, @"features set to story interactions should not have audio");
    STAssertFalse(appBookFeatures.isSample, @"features set to story interactions should not be a sample");
}

- (void)testFeaturesWithAudio
{
    SCHAppBookFeatures *appBookFeatures = [[[SCHAppBookFeatures alloc] initWithStoryInteractions:NO
                                                                                           audio:YES
                                                                                          sample:NO] autorelease];

    STAssertTrue(appBookFeatures.features == kSCHAppBookFeaturesAudio, @"features should be set to audio");
    STAssertFalse(appBookFeatures.hasStoryInteractions, @"features set to audio should not have story interactions");
    STAssertTrue(appBookFeatures.hasAudio, @"features set to audio should have audio");
    STAssertFalse(appBookFeatures.isSample, @"features set to audio should not be a sample");
}

- (void)testFeaturesWithSample
{
    SCHAppBookFeatures *appBookFeatures = [[[SCHAppBookFeatures alloc] initWithStoryInteractions:NO
                                                                                           audio:NO
                                                                                          sample:YES] autorelease];

    STAssertTrue(appBookFeatures.features == kSCHAppBookFeaturesSample, @"features should be set to sample");
    STAssertFalse(appBookFeatures.hasStoryInteractions, @"features set to sample should not have story interactions");
    STAssertFalse(appBookFeatures.hasAudio, @"features set to sample should not have audio");
    STAssertTrue(appBookFeatures.isSample, @"features set to sample should have sample");
}

- (void)testFeaturesWithMultipleFeatures
{
    SCHAppBookFeatures *appBookFeatures = [[[SCHAppBookFeatures alloc] initWithStoryInteractions:YES
                                                                                           audio:YES
                                                                                          sample:NO] autorelease];

    STAssertTrue(appBookFeatures.features == kSCHAppBookFeaturesStoryInteractionsAudio, @"features should be set to story interactions and audio");
    STAssertTrue(appBookFeatures.hasStoryInteractions, @"features should have story interactions");
    STAssertTrue(appBookFeatures.hasAudio, @"features should have audio");
    STAssertFalse(appBookFeatures.isSample, @"features should not have sample");

    appBookFeatures = [[[SCHAppBookFeatures alloc] initWithStoryInteractions:YES
                                                                       audio:NO
                                                                      sample:YES] autorelease];

    STAssertTrue(appBookFeatures.features == kSCHAppBookFeaturesStoryInteractionsSample, @"features should be set to story interactions and sample");
    STAssertTrue(appBookFeatures.hasStoryInteractions, @"features should have story interactions");
    STAssertFalse(appBookFeatures.hasAudio, @"features should not have audio");
    STAssertTrue(appBookFeatures.isSample, @"features should have a sample");

    appBookFeatures = [[[SCHAppBookFeatures alloc] initWithStoryInteractions:NO
                                                                       audio:YES
                                                                      sample:YES] autorelease];

    STAssertTrue(appBookFeatures.features == kSCHAppBookFeaturesAudioSample, @"features should be set to audio and sample");
    STAssertFalse(appBookFeatures.hasStoryInteractions, @"features should not have story interactions");
    STAssertTrue(appBookFeatures.hasAudio, @"features should have audio");
    STAssertTrue(appBookFeatures.isSample, @"features should have a sample");

    appBookFeatures = [[[SCHAppBookFeatures alloc] initWithStoryInteractions:YES
                                                                       audio:YES
                                                                      sample:YES] autorelease];

    STAssertTrue(appBookFeatures.features == kSCHAppBookFeaturesStoryInteractionsAudioSample, @"features should be set to story interactions and audio and sample");
    STAssertTrue(appBookFeatures.hasStoryInteractions, @"features should have story interactions");
    STAssertTrue(appBookFeatures.hasAudio, @"features should have audio");
    STAssertTrue(appBookFeatures.isSample, @"features should have a sample");
}

@end
