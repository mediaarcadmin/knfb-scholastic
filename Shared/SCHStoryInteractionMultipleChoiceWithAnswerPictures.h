//
//  SCHStoryInteractionMultipleChoiceWithAnswerPictures.h
//  Scholastic
//
//  Created by Neil Gall on 07/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHStoryInteractionMultipleChoiceText.h"

@interface SCHStoryInteractionMultipleChoicePictureQuestion : SCHStoryInteractionMultipleChoiceTextQuestion {}

// XPSProvider-relative path for a picture answer
- (NSString *)imagePathForAnswerAtIndex:(NSInteger)answerIndex;

@end

@interface SCHStoryInteractionMultipleChoiceWithAnswerPictures : SCHStoryInteractionMultipleChoice {}
@end
