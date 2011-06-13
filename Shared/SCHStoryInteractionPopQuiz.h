//
//  SCHStoryInteractionPopQuiz.h
//  StoryInteractions
//
//  Created by Neil Gall on 30/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHStoryInteraction.h"

@interface SCHStoryInteractionPopQuizQuestion : SCHStoryInteractionQuestion {}

@property (nonatomic, retain) NSString *prompt;

// array of NSStrings
@property (nonatomic, retain) NSArray *answers;

// index into answers
@property (nonatomic, assign) NSInteger correctAnswer;

@end


@interface SCHStoryInteractionPopQuiz : SCHStoryInteraction {}

@property (nonatomic, retain) NSString *introduction;
@property (nonatomic, retain) NSArray *questions;

// Response for a low score
@property (nonatomic, retain) NSString *scoreResponseLow;

// Response for a medium score
@property (nonatomic, retain) NSString *scoreResponseMedium;

// Response for a high score
@property (nonatomic, retain) NSString *scoreResponseHigh;

@end
