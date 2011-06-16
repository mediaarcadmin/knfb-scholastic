//
//  SCHStoryInteractionAboutYouQuiz.m
//  Scholastic
//
//  Created by Neil Gall on 01/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionAboutYouQuiz.h"

@implementation SCHStoryInteractionAboutYouQuizQuestion

@synthesize prompt;
@synthesize answers;

- (void)dealloc
{
    [prompt release];
    [answers release];
    [super dealloc];
}

@end

@implementation SCHStoryInteractionAboutYouQuiz

@synthesize introduction;
@synthesize questions;
@synthesize outcomeMessages;
@synthesize tiebreakOrder;

- (void)dealloc
{
    [introduction release];
    [questions release];
    [outcomeMessages release];
    [tiebreakOrder release];
    [super dealloc];
}

- (NSString *)title
{
    return @"About You Quiz";
}

- (BOOL)isOlderStoryInteraction
{
    return YES;
}

@end
