//
//  SCHReadingStoryInteractionButton.m
//  Scholastic
//
//  Created by Matt Farrugia on 22/09/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHReadingStoryInteractionButton.h"

@interface SCHReadingStoryInteractionButton()

@property (nonatomic, assign) SCHReadingStoryInteractionButtonFillLevel fillLevel;

@end

@implementation SCHReadingStoryInteractionButton

@synthesize fillLevel;

- (void)setFillLevel:(SCHReadingStoryInteractionButtonFillLevel)level forYounger:(BOOL)younger animated:(BOOL)animated
{
    NSString *imagePrefix;
    
    if (younger) {
        imagePrefix = @"young";
    } else {
        imagePrefix = @"old";
    }
    
    NSUInteger newFillLevel;
    
    switch (level) {
        case kSCHReadingStoryInteractionButtonFillLevelOneThird:
            newFillLevel = 1;
            break;
        case kSCHReadingStoryInteractionButtonFillLevelTwoThirds:
            newFillLevel = 2;
            break;
        case kSCHReadingStoryInteractionButtonFillLevelFull:
            newFillLevel = 3;
            break;
        default:
            newFillLevel = 0;
            break;
    }
        
    [self setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@-lightning-bolt-%d", imagePrefix, newFillLevel]] forState:UIControlStateNormal];
    
    fillLevel = newFillLevel;
}

@end
