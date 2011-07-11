//
//  SCHWordTiming.m
//  Scholastic
//
//  Created by John S. Eddie on 26/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHWordTiming.h"

static NSTimeInterval const kSCHWordTimingMilliSecondsInASecond = 1000.0;

@implementation SCHWordTiming

@synthesize startTime;
@synthesize endTime;
@synthesize page;

- (id)initWithStartTime:(NSUInteger)setStartTime 
                endTime:(NSUInteger)setEndTime 
{
    return([self initWithStartTime:setStartTime 
                           endTime:setEndTime 
                              page:NSUIntegerMax]);
}

- (id)initWithStartTime:(NSUInteger)setStartTime 
                endTime:(NSUInteger)setEndTime 
                   page:(NSUInteger)setPage
{
    self = [super init];
    if (self) {
        startTime = MIN(setStartTime, setEndTime);
        endTime = MAX(setStartTime, setEndTime);
        page = setPage;
    }
    return(self);
}

- (NSComparisonResult)compareTime:(NSUInteger)time
{
    NSComparisonResult ret = NSOrderedSame;
    
    if (time >= self.startTime && time <= self.endTime) {
        ret = NSOrderedSame;
    } else if (time < self.startTime) {
        ret = NSOrderedDescending;
    } else if (time > self.endTime) {
        ret = NSOrderedAscending;        
    }
    
    return(ret);
}

- (NSTimeInterval)startTimeAsSeconds
{
    NSTimeInterval ret = 0.0;
    
    if (self.startTime > 0) {
        ret = (self.startTime / kSCHWordTimingMilliSecondsInASecond);   
    }
    
    return(ret);
}

- (NSTimeInterval)endTimeAsSeconds
{
    NSTimeInterval ret = 0.0;
    
    if (self.startTime > 0) {
        ret = (self.endTime / kSCHWordTimingMilliSecondsInASecond);   
    }
    
    return(ret);
}

- (NSString *)description
{
    if (self.page == NSUIntegerMax) {
        return([NSString stringWithFormat:@"%lu - %lu", self.startTime, self.endTime]);
    } else {
        return([NSString stringWithFormat:@"%lu - %lu (%lu)", self.startTime, self.endTime, self.page]);
    }
}

@end
