//
//  SCHStoryInteractionMultipleChoice.m
//  StoryInteractions
//
//  Created by Neil Gall on 31/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionMultipleChoice.h"

#pragma mark - SCHStoryInteractionMultipleChoiceAnswer

@implementation SCHStoryInteractionMultipleChoiceQuestion

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


#pragma mark - SCHStoryInteractionMultipleChoice

@implementation SCHStoryInteractionMultipleChoice

@synthesize introduction;
@synthesize questions;

- (void)dealloc
{
    [introduction release];
    [questions release];
    [super dealloc];
}

- (BOOL)answersArePictures
{
    return NO;
}

@end


@implementation SCHStoryInteractionMultipleChoiceText

- (BOOL)answersArePictures
{
    return NO;
}

@end

@implementation SCHStoryInteractionMultipleChoiceWithAnswerPictures

- (BOOL)answersArePictures
{
    return YES;
}

@end