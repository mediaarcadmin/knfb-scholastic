//
//  SCHReadingStoryInteractionButton.m
//  Scholastic
//
//  Created by Matt Farrugia on 22/09/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHReadingStoryInteractionButton.h"


@implementation SCHReadingStoryInteractionButton


- (void)setFillLevel:(SCHReadingStoryInteractionButtonFillLevel)level forYounger:(BOOL)younger animated:(BOOL)animated withSound:(BOOL)withSound
{
    NSString *imagePrefix;
    
    if (younger) {
        imagePrefix = @"young";
    } else {
        imagePrefix = @"old";
    }
    
    NSUInteger fillLevel;
    
    switch (level) {
        case kSCHReadingStoryInteractionButtonFillLevelOneThird:
            fillLevel = 1;
            break;
        case kSCHReadingStoryInteractionButtonFillLevelTwoThirds:
            fillLevel = 2;
            break;
        case kSCHReadingStoryInteractionButtonFillLevelFull:
            fillLevel = 3;
            break;
        default:
            fillLevel = 0;
            break;
    }
    
    if (animated) {
        [CATransaction begin];
        [CATransaction setAnimationDuration:5];
    }
    
    [self setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@-lightning-bolt-%d", imagePrefix, fillLevel]] forState:UIControlStateNormal];
    
    if (animated) {
        [CATransaction commit];
    }
}

@end
