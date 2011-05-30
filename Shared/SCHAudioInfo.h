//
//  SCHAudioInfo.h
//  Scholastic
//
//  Created by John S. Eddie on 30/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCHAudioInfo : NSObject 
{    
}

@property (nonatomic, assign, readonly) NSUInteger pageIndex;
@property (nonatomic, assign, readonly) NSUInteger timeIndex;
@property (nonatomic, assign, readonly) NSUInteger timeOffset;
@property (nonatomic, assign, readonly) NSUInteger audioReferenceIndex;

- (id)initWithPageIndex:(NSUInteger)setPageIndex 
              timeIndex:(NSUInteger)setTimeIndex
             timeOffset:(NSUInteger)setTimeOffset 
    audioReferenceIndex:(NSUInteger)setAudioReferenceIndex;
- (NSTimeInterval)setTimeOffsetAsSeconds;

@end
