//
//  SCHSyncDelayTests.m
//  Scholastic
//
//  Created by John S. Eddie on 27/09/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHSyncDelayTests.h"

#import "SCHSyncDelay.h"

@interface SCHSyncDelayTests ()

@property (nonatomic, retain) SCHSyncDelay *syncDelay;

@end

@implementation SCHSyncDelayTests

#pragma mark - Lifecycle methods

- (void)setUp
{
    self.syncDelay = [[[SCHSyncDelay alloc] init] autorelease];
}

- (void)tearDown
{
    self.syncDelay = nil;
}

#pragma mark - General Tests

- (void)testDefaultSyncDelay
{
    STAssertTrue([self.syncDelay shouldSync],  @"Default sync delay should sync");
    STAssertFalse(self.syncDelay.delayActive, @"Default sync delay should not be delayed");
}

- (void)testSyncStarted
{
    [self.syncDelay syncStarted];
    
    STAssertFalse([self.syncDelay shouldSync],  @"sync delay should not sync after sync started");
    STAssertFalse(self.syncDelay.delayActive, @"sync delay should not be delayed after sync started");
}

- (void)testClearAfterSyncStarted
{
    [self.syncDelay syncStarted];
    [self.syncDelay clearSyncDelay];
    
    STAssertTrue([self.syncDelay shouldSync],  @"sync delay should sync after clear");
    STAssertFalse(self.syncDelay.delayActive, @"sync delay should not be delayed after clear");
}

- (void)testClearLastSyncDateAfterSyncStarted
{
    [self.syncDelay syncStarted];
    [self.syncDelay clearLastSyncDate];

    STAssertTrue([self.syncDelay shouldSync],  @"sync delay should sync after clear last sync date");
}

- (void)testActivateDelay
{
    [self.syncDelay activateDelay];
    STAssertTrue(self.syncDelay.delayActive,  @"delay should be active");

    [self.syncDelay clearSyncDelay];
    STAssertFalse(self.syncDelay.delayActive,  @"delay should be inactive");
}

@end
