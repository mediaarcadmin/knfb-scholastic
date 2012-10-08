//
//  SCHSyncDelay.m
//  Scholastic
//
//  Created by John S. Eddie on 27/09/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHSyncDelay.h"

// Constants
static NSTimeInterval const kSCHSyncDelayInterval = -300.0;

@interface SCHSyncDelay ()

@property (nonatomic, retain) NSDate *lastSyncDate;
@property (nonatomic, assign) BOOL delayActive;

@end

@implementation SCHSyncDelay

@synthesize lastSyncDate;
@synthesize delayActive;

#pragma Memory Management

- (void)dealloc
{
    [lastSyncDate release], lastSyncDate = nil;

    [super dealloc];
}

#pragma Public methods

- (void)clearLastSyncDate
{
    self.lastSyncDate = nil;
}

- (void)activateDelay
{
    self.delayActive = YES;
}

- (void)clearSyncDelay
{
    [self clearLastSyncDate];
    self.delayActive = NO;
}

- (void)syncStarted
{
    self.lastSyncDate = [NSDate date];
    self.delayActive = NO;
}

- (BOOL)shouldSync
{
    // reset the date if it's set in the future
    if (self.lastSyncDate != nil &&
        [self.lastSyncDate compare:[NSDate date]] == NSOrderedDescending) {
        self.lastSyncDate = nil;
    }

    return (self.lastSyncDate == nil ||
            [self.lastSyncDate timeIntervalSinceNow] < kSCHSyncDelayInterval);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"lastSyncDate: %@ delayActive: %@",
            self.lastSyncDate, (self.delayActive == YES ? @"YES" : @"NO")];
}

@end
