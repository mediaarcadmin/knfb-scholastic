//
//  SCHStoryInteractionScratchAndSee.h
//  StoryInteractions
//
//  Created by Neil Gall on 31/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHStoryInteractionMultipleChoice.h"

@interface SCHStoryInteractionScratchAndSeeQuestion : SCHStoryInteractionMultipleChoiceQuestion {}

// XPSProvider-relative path for image file
- (NSString *)imagePath;

// XPSProvider-relative path for answer audio file
- (NSString *)audioPathForAnswerAtIndex:(NSInteger)index;

// XPSProvider-relative path for correct answer audio
- (NSString *)correctAnswerAudioPath;

@end


@interface SCHStoryInteractionScratchAndSee : SCHStoryInteractionMultipleChoice {}
@end
