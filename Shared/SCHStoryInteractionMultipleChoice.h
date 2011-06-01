//
//  SCHStoryInteractionMultipleChoice.h
//  StoryInteractions
//
//  Created by Neil Gall on 31/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHStoryInteraction.h"

@interface SCHStoryInteractionMultipleChoiceQuestion : SCHStoryInteractionQuestion {}

@property (nonatomic, retain) NSString *prompt;

// array of NSStrings
@property (nonatomic, retain) NSArray *answers;

// index into answers
@property (nonatomic, assign) NSInteger correctAnswer;

@end


@interface SCHStoryInteractionMultipleChoice : SCHStoryInteraction {}

@property (nonatomic, retain) NSString *introduction;

// array of SCHStoryInteractionMultipleChoiceQuestion
@property (nonatomic, retain) NSArray *questions;

@property (nonatomic, readonly) BOOL answersArePictures;

@end


@interface SCHStoryInteractionMultipleChoiceText : SCHStoryInteractionMultipleChoice {}
@end

@interface SCHStoryInteractionMultipleChoiceWithAnswerPictures : SCHStoryInteractionMultipleChoice {}
@end