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
@synthesize blockID;
@synthesize wordID;

- (id)initWithStartTime:(NSUInteger)setStartTime 
                endTime:(NSUInteger)setEndTime 
{
    return([self initWithStartTime:setStartTime 
                           endTime:setEndTime 
                              word:nil
                         pageIndex:NSUIntegerMax
                           blockID:NSUIntegerMax
                            wordID:NSUIntegerMax]);
}

- (id)initWithStartTime:(NSUInteger)setStartTime 
                endTime:(NSUInteger)setEndTime 
                   word:(NSString *)setWord
              pageIndex:(NSUInteger)setPageIndex
                blockID:(NSUInteger)setBlockID
                 wordID:(NSUInteger)setWordID
{
    self = [super init];
    if (self) {
        startTime = MIN(setStartTime, setEndTime);
        endTime = MAX(setStartTime, setEndTime);
        word = [setWord copy];
        pageIndex = setPageIndex;
        blockID = setBlockID;
        wordID = setWordID;
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
        return([NSString stringWithFormat:@"%lu - %lu %@ (pageIndex:%lu blockID:%lu wordID:%lu)", 
                self.startTime, 
                self.endTime, 
                self.word, 
                self.pageIndex, 
                self.blockID, 
                self.wordID]);
    }
}

@end
