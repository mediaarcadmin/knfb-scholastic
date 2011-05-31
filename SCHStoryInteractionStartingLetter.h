//
//  SCHStoryInteractionStartingLetter.h
//  StoryInteractions
//
//  Created by Neil Gall on 31/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHStoryInteraction.h"

@interface SCHStoryInteractionStartingLetterAnswer : NSObject {}

@property (nonatomic, readonly) UIImage *image;
@property (nonatomic, readonly) BOOL isCorrect;

@end


@interface SCHStoryInteractionStartingLetter : SCHStoryInteraction {}

@property (nonatomic, readonly) NSString *prompt;
@property (nonatomic, readonly) NSString *startingLetter;

// array of SCHStoryInteractionStartingLetterAnswer
@property (nonatomic, readonly) NSArray *answers;

@end
