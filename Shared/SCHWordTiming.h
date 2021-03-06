//
//  SCHWordTiming.h
//  Scholastic
//
//  Created by John S. Eddie on 26/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCHWordTiming : NSObject 
{
}

@property (nonatomic, assign, readonly) NSUInteger startTime;
@property (nonatomic, assign, readonly) NSUInteger endTime;
@property (nonatomic, copy, readonly) NSString *word;

@property (nonatomic, assign, readonly) NSUInteger pageIndex;
@property (nonatomic, assign, readonly) NSUInteger blockID;
@property (nonatomic, assign, readonly) NSUInteger wordID;

- (id)initWithStartTime:(NSUInteger)setStartTime 
                endTime:(NSUInteger)setEndTime;
- (id)initWithStartTime:(NSUInteger)setStartTime 
                endTime:(NSUInteger)setEndTime 
                   word:(NSString *)setWord
              pageIndex:(NSUInteger)setPageIndex
                blockID:(NSUInteger)setBlockID
                 wordID:(NSUInteger)setWordID;
- (NSComparisonResult)compareTime:(NSUInteger)time;
- (NSTimeInterval)startTimeAsSeconds;
- (NSTimeInterval)endTimeAsSeconds;

@end
