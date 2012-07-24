//
//  SCHStoryInteractionReadingQuiz.m
//  Scholastic
//
//  Created by Gordon Christie on 24/07/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHStoryInteractionReadingQuiz.h"

@implementation SCHStoryInteractionReadingQuizQuestion

@synthesize answers;
@synthesize correctAnswer;
@synthesize prompt;

- (void)dealloc
{
    [prompt release], prompt = nil;
    [answers release];
    [super dealloc];
}

@end

@implementation SCHStoryInteractionReadingQuiz

@synthesize questions;

- (void)dealloc
{
    [questions release];
    [super dealloc];
}

- (NSString *)title
{
    return @"Reading Quiz";
}


@end
