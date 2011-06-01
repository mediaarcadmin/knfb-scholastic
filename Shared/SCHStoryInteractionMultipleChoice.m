//
//  SCHStoryInteractionMultipleChoice.m
//  StoryInteractions
//
//  Created by Neil Gall on 31/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionMultipleChoice.h"

#pragma mark - base

@implementation SCHStoryInteractionMultipleChoice

@synthesize introduction;
@synthesize questions;

- (void)dealloc
{
    [introduction release];
    [questions release];
    [super dealloc];
}

@end


#pragma mark - text

@implementation SCHStoryInteractionMultipleChoiceTextQuestion

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
    return [[SCHStoryInteraction resourcesPath] stringByAppendingPathComponent:filename];
}

- (NSString *)audioPathForAnswerAtIndex:(NSInteger)answerIndex
{
    NSString *filename = [NSString stringWithFormat:@"%@_q%da%d.mp3", self.storyInteraction.ID, self.questionIndex+1, answerIndex+1];
    return [[SCHStoryInteraction resourcesPath] stringByAppendingPathComponent:filename];
}

- (NSString *)audioPathForIncorrectAnswer
{
    return [[SCHStoryInteraction resourcesPath] stringByAppendingPathComponent:@"gen_tryagain.mp3"];
}

- (NSString *)audioPathForCorrectAnswer
{
    NSString *filename = [NSString stringWithFormat:@"%@_ca%d.mp3", self.storyInteraction.ID, self.questionIndex+1];
    return [[SCHStoryInteraction resourcesPath] stringByAppendingPathComponent:filename];
}

@end

@implementation SCHStoryInteractionMultipleChoiceText
@end


#pragma mark - picture

@implementation SCHStoryInteractionMultipleChoicePictureQuestion

- (NSString *)imagePathForAnswerAtIndex:(NSInteger)answerIndex
{
    NSString *filename = [NSString stringWithFormat:@"%@_q%da%d.png", self.storyInteraction.ID, self.questionIndex+1, answerIndex+1];
    return [[SCHStoryInteraction resourcesPath] stringByAppendingPathComponent:filename];
}

@end

@implementation SCHStoryInteractionMultipleChoiceWithAnswerPictures
@end