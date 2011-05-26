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

- (id)initWithStartTime:(NSUInteger)setStartTime endTime:(NSUInteger)setEndTime;
- (NSComparisonResult)compareTime:(NSUInteger)time;

@end
