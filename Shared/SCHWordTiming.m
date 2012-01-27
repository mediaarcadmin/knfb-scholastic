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
@synthesize word;
@synthesize pageIndex;
@synthesize blockIndex;
@synthesize wordIndex;

- (id)initWithStartTime:(NSUInteger)setStartTime 
                endTime:(NSUInteger)setEndTime 
{
    return([self initWithStartTime:setStartTime 
                           endTime:setEndTime 
                              word:nil
                         pageIndex:NSUIntegerMax
                           blockIndex:NSUIntegerMax
                            wordIndex:NSUIntegerMax]);
}

- (id)initWithStartTime:(NSUInteger)setStartTime 
                endTime:(NSUInteger)setEndTime 
                   word:(NSString *)setWord
              pageIndex:(NSUInteger)setPageIndex
                blockIndex:(NSUInteger)setBlockIndex
                 wordIndex:(NSUInteger)setWordIndex
{
    self = [super init];
    if (self) {
        startTime = MIN(setStartTime, setEndTime);
        endTime = MAX(setStartTime, setEndTime);
        word = [setWord copy];
        pageIndex = setPageIndex;
        blockIndex = setBlockIndex;
        wordIndex = setWordIndex;
    }
    return(self);
}

- (void)dealloc 
{
    [word release], word = nil;
    
    [super dealloc];
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
    if (self.pageIndex == NSUIntegerMax) {
        return([NSString stringWithFormat:@"%lu - %lu", self.startTime, self.endTime]);
    } else {
        return([NSString stringWithFormat:@"%lu - %lu %@ (page:%lu block:%lu word:%lu)", self.startTime, self.endTime, self.word, self.pageIndex, self.blockIndex, self.wordIndex]);
    }
}

@end
