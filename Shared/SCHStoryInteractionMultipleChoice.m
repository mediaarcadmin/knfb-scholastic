//
//  SCHStoryInteractionMultipleChoice.m
//  StoryInteractions
//
//  Created by Neil Gall on 31/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionMultipleChoice.h"

#import "KNFBXPSConstants.h"

@implementation SCHStoryInteractionMultipleChoiceQuestion

@synthesize storyInteraction;
@synthesize questionIndex;
@synthesize prompt;
@synthesize answers;
@synthesize correctAnswer;

- (void)dealloc
{
    [prompt release];
    [answers release];
    [super dealloc];
}

- (NSString *)audioPathForQuestion
{
    NSString *filename = [NSString stringWithFormat:@"%@_q%d.mp3", self.storyInteraction.ID, self.questionIndex+1];
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:filename];
}

- (NSString *)audioPathForAnswerAtIndex:(NSInteger)answerIndex
{
    NSString *filename = [NSString stringWithFormat:@"%@_q%da%d.mp3", self.storyInteraction.ID, self.questionIndex+1, answerIndex+1];
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:filename];
}

- (NSString *)audioPathForIncorrectAnswer
{
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:@"gen_tryagain.mp3"];
}

- (NSString *)audioPathForCorrectAnswer
{
    NSString *filename = [NSString stringWithFormat:@"%@_ca%d.mp3", self.storyInteraction.ID, self.questionIndex+1];
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:filename];
}

@end


@implementation SCHStoryInteractionMultipleChoice

@synthesize introduction;
@synthesize questions;

- (void)dealloc
{
    [introduction release];
    [questions release];
    [super dealloc];
}

- (NSString *)title
{
    return @"Multiple Choice";
}

@end

