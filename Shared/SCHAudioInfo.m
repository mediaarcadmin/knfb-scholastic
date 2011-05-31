//
//  SCHAudioInfo.m
//  Scholastic
//
//  Created by John S. Eddie on 30/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHAudioInfo.h"

@implementation SCHAudioInfo

@synthesize pageIndex;
@synthesize timeIndex;
@synthesize timeOffset;
@synthesize audioReferenceIndex;

- (id)initWithPageIndex:(NSUInteger)setPageIndex 
              timeIndex:(NSUInteger)setTimeIndex
             timeOffset:(NSUInteger)setTimeOffset 
    audioReferenceIndex:(NSUInteger)setAudioReferenceIndex
{
    self = [super init];
    if (self) {
        pageIndex = setPageIndex;
        timeIndex = setTimeIndex;
        timeOffset = setTimeOffset;
        audioReferenceIndex = setAudioReferenceIndex;
    }
    return(self);
}

- (NSString *)description
{
    return([NSString stringWithFormat:@"p:%lu ti:%lu to:%lu a:%lu", self.pageIndex, 
            self.timeIndex, self.timeOffset, self.audioReferenceIndex]);
}

@end
