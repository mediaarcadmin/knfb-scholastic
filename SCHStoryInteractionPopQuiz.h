//
//  SCHStoryInteractionPopQuiz.h
//  StoryInteractions
//
//  Created by Neil Gall on 30/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHStoryInteraction.h"

@interface SCHStoryInteractionPopQuizQuestion : NSObject {}

@property (nonatomic, readonly) NSString *prompt;

// array of NSString
@property (nonatomic, readonly) NSArray *answers;

// index into answers
@property (nonatomic, readonly) NSInteger correctAnswer;

@end

@interface SCHStoryInteractionPopQuiz : SCHStoryInteraction {}

// Array of SCHStoryInteractionPopQuizQuestion items
@property (nonatomic, readonly) NSArray *questions;

// Response for a low score
@property (nonatomic, readonly) NSString *scoreResponseLow;

// Response for a medium score
@property (nonatomic, readonly) NSString *scoreResponseMedium;

// Response for a high score
@property (nonatomic, readonly) NSString *scoreResponseHigh;

@end
