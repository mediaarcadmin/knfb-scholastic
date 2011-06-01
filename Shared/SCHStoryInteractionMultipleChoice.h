//
//  SCHStoryInteractionMultipleChoice.h
//  StoryInteractions
//
//  Created by Neil Gall on 31/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHStoryInteraction.h"

#pragma mark - abstract base

@interface SCHStoryInteractionMultipleChoice : SCHStoryInteraction {}

@property (nonatomic, retain) NSString *introduction;

// array of SCHStoryInteractionMultipleChoiceTextQuestion or SCHStoryInteractionMultipleChoicePictureQuestion
@property (nonatomic, retain) NSArray *questions;

@end


#pragma mark - text

@interface SCHStoryInteractionMultipleChoiceTextQuestion : SCHStoryInteractionQuestion {}

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

@interface SCHStoryInteractionMultipleChoiceText : SCHStoryInteractionMultipleChoice {}
@end

#pragma mark - picture

@interface SCHStoryInteractionMultipleChoicePictureQuestion : SCHStoryInteractionMultipleChoiceTextQuestion {}

// XPSProvider-relative path for a picture answer
- (NSString *)imagePathForAnswerAtIndex:(NSInteger)answerIndex;

@end

@interface SCHStoryInteractionMultipleChoiceWithAnswerPictures : SCHStoryInteractionMultipleChoice {}
@end
