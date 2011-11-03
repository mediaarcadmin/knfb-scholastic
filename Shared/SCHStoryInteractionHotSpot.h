//
//  SCHStoryInteractionHotSpot.h
//  StoryInteractions
//
//  Created by Neil Gall on 31/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHStoryInteraction.h"

@interface SCHStoryInteractionHotSpotQuestion : SCHStoryInteractionQuestion {}

@property (nonatomic, retain) NSString *prompt;
@property (nonatomic, assign) CGRect hotSpotRect;
@property (nonatomic, assign) CGSize originalBookSize;
@property (nonatomic, assign) CGPathRef path;

// XPSProvider-relative path for question audio
- (NSString *)audioPathForQuestion;

// XPSProvider-relative path for correct answer audio
- (NSString *)audioPathForCorrectAnswer;

@end


@interface SCHStoryInteractionHotSpot : SCHStoryInteraction {}

// array of SCHStoryInteractionHotSpotQuestion
@property (nonatomic, retain) NSArray *questions;

- (NSArray *)questionsWithPageAssociation:(enum SCHStoryInteractionQuestionPageAssociation)pageAssociation;

@end
