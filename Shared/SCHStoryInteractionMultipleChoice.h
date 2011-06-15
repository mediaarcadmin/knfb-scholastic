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

// XPSProvider-relative path for question audio
- (NSString *)audioPathForQuestion;

// XPSProvider-relative path for answer audio
- (NSString *)audioPathForAnswerAtIndex:(NSInteger)answerIndex;

// XPSProvider-relative path for incorrect answer audio
- (NSString *)audioPathForIncorrectAnswer;

// XPSProvider-relative path for correct answer audio
- (NSString *)audioPathForCorrectAnswer;

@end


@interface SCHStoryInteractionMultipleChoice : SCHStoryInteraction {}

@property (nonatomic, retain) NSString *introduction;
@property (nonatomic, retain) NSArray *questions;

// XPSProvider-relative path for intro audio
- (NSString *)introductionAudioPath;

@end

