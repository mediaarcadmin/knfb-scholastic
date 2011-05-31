//
//  SCHStoryInteractionPopQuiz.m
//  StoryInteractions
//
//  Created by Neil Gall on 30/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionPopQuiz.h"

#pragma mark - SCHStoryInteractionPopQuizQuestion

@implementation SCHStoryInteractionPopQuizQuestion

@synthesize answers;
@synthesize correctAnswer;
@synthesize prompt;

- (void)dealloc
{
    [answers release];
    [prompt release];
    [super dealloc];
}

@end

#pragma mark - SCHStoryInteractionPopQuiz

@implementation SCHStoryInteractionPopQuiz

@synthesize questions;
@synthesize scoreResponseLow;
@synthesize scoreResponseMedium;
@synthesize scoreResponseHigh;

- (void)dealloc
{
    [questions release];
    [scoreResponseLow release];
    [scoreResponseMedium release];
    [scoreResponseHigh release];
    [super dealloc];
}

@end
