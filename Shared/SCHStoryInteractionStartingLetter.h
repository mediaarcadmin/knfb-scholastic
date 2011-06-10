//
//  SCHStoryInteractionStartingLetter.h
//  StoryInteractions
//
//  Created by Neil Gall on 31/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHStoryInteraction.h"

@interface SCHStoryInteractionStartingLetterQuestion : SCHStoryInteractionQuestion {}

@property (nonatomic, assign) BOOL isCorrect;

@property (nonatomic, retain) NSString *uniqueObjectName;

// XPSProvider-relative path for question image
- (NSString *)imagePath;

// XPSProvider-relative path for question audio
- (NSString *)audioPath;

@end


@interface SCHStoryInteractionStartingLetter : SCHStoryInteraction {}

@property (nonatomic, retain) NSString *prompt;
@property (nonatomic, retain) NSString *startingLetter;

// array of SCHStoryInteractionStartingLetterQuestion
@property (nonatomic, retain) NSArray *questions;

// XPSProvider-relative path for prompt audio
- (NSString *)audioPath;

@end
