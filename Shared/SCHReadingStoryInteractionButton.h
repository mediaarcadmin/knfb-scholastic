//
//  SCHReadingStoryInteractionButton.h
//  Scholastic
//
//  Created by Matt Farrugia on 22/09/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum SCHReadingStoryInteractionButtonFillLevel {
    kSCHReadingStoryInteractionButtonFillLevelEmpty = 0,
    kSCHReadingStoryInteractionButtonFillLevelOneThird,
    kSCHReadingStoryInteractionButtonFillLevelTwoThirds,
    kSCHReadingStoryInteractionButtonFillLevelFull
} SCHReadingStoryInteractionButtonFillLevel; 

@interface SCHReadingStoryInteractionButton : UIButton {
    
}

@property (nonatomic, readonly) SCHReadingStoryInteractionButtonFillLevel fillLevel;

- (void)setFillLevel:(SCHReadingStoryInteractionButtonFillLevel)level forYounger:(BOOL)younger animated:(BOOL)animated;

@end
