//
//  SCHStoryInteractionPopQuiz.m
//  StoryInteractions
//
//  Created by Neil Gall on 30/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionPopQuiz.h"

@implementation SCHStoryInteractionPopQuizQuestion

@synthesize prompt;
@synthesize answers;
@synthesize correctAnswer;

- (void)dealloc
{
    [prompt release];
    [answers release];
    [super dealloc];
}

@end

@implementation SCHStoryInteractionPopQuiz

@synthesize introduction;
@synthesize questions;
@synthesize scoreResponseLow;
@synthesize scoreResponseMedium;
@synthesize scoreResponseHigh;

- (void)dealloc
{
    [introduction release];
    [questions release];
    [scoreResponseLow release];
    [scoreResponseMedium release];
    [scoreResponseHigh release];
    [super dealloc];
}

- (BOOL)isOlderStoryInteraction
{
    return YES;
}

- (NSString *)title
{
    return @"Do You Know?";
}


@end
