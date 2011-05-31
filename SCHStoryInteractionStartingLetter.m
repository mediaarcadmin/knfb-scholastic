//
//  SCHStoryInteractionStartingLetter.m
//  StoryInteractions
//
//  Created by Neil Gall on 31/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionStartingLetter.h"

#pragma mark - SCHStoryInteractionStartingLetterAnswer

@implementation SCHStoryInteractionStartingLetterAnswer

@synthesize isCorrect;

- (void)dealloc
{
    [super dealloc];
}

- (UIImage *)image
{
    return nil;
}

@end

#pragma mark - SCHStoryInteractionStartingLetter

@implementation SCHStoryInteractionStartingLetter

@synthesize prompt;
@synthesize startingLetter;
@synthesize answers;

- (void)dealloc
{
    [prompt release];
    [startingLetter release];
    [answers release];
    [super dealloc];
}

@end
