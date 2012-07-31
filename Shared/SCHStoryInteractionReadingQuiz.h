//
//  SCHStoryInteractionReadingQuiz.h
//  Scholastic
//
//  Created by Gordon Christie on 24/07/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHStoryInteraction.h"

@interface SCHStoryInteractionReadingQuizQuestion : SCHStoryInteractionQuestion {}

@property (nonatomic, retain) NSString *prompt;

// array of NSStrings
@property (nonatomic, retain) NSArray *answers;

// index into answers
@property (nonatomic, assign) NSInteger correctAnswer;

- (NSString *)audioPathForQuestion;
- (NSString *)audioPathForAnswerAtIndex:(NSInteger)answerIndex;

@end


@interface SCHStoryInteractionReadingQuiz : SCHStoryInteraction {}

@property (nonatomic, retain) NSArray *questions;

- (NSString *)audioPathForNotCompletedBook;
- (NSString *)audioPathForIntroduction;
- (NSString *)audioPathForAllCorrect;
- (NSString *)audioPathForMoreThanFiftyPercent;
- (NSString *)audioPathForLessThanFiftyPercent;

@end
