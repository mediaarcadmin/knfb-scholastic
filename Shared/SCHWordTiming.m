//
//  SCHWordTiming.m
//  Scholastic
//
//  Created by John S. Eddie on 26/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHWordTiming.h"

@implementation SCHWordTiming

@synthesize startTime;
@synthesize endTime;

- (id)initWithStartTime:(NSUInteger)setStartTime endTime:(NSUInteger)setEndTime
{
    self = [super init];
    if (self) {
        startTime = MIN(setStartTime, setEndTime);
        endTime = MAX(setStartTime, setEndTime);
    }
    return(self);
}

- (NSComparisonResult)compareTime:(NSUInteger)time
{
    NSComparisonResult ret;
    
    if (time >= self.startTime && time <= self.endTime) {
        ret = NSOrderedSame;
    } else if (time < self.startTime) {
        ret = NSOrderedDescending;
    } else if (time > self.endTime) {
        ret = NSOrderedAscending;        
    }
    
    return(ret);
}

- (NSString *)description
{
    return([NSString stringWithFormat:@"%lu - %lu", self.startTime, self.endTime]);
}

@end
