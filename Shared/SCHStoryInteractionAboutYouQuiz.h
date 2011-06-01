//
//  SCHStoryInteractionAboutYouQuiz.h
//  Scholastic
//
//  Created by Neil Gall on 01/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHStoryInteraction.h"

@interface SCHStoryInteractionAboutYouQuizQuestion : SCHStoryInteractionQuestion {}

@property (nonatomic, retain) NSString *prompt;

// array of NSStrings
@property (nonatomic, retain) NSArray *answers;

@end


@interface SCHStoryInteractionAboutYouQuiz : SCHStoryInteraction {}

@property (nonatomic, retain) NSString *introduction;

// array of SCHStoryInteractionAboutYouQuizQuestion
@property (nonatomic, retain) NSArray *questions;

// array of NSString
@property (nonatomic, retain) NSArray *outcomeMessages;

@end
