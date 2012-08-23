//
//  SCHStoryInteractionReadingChallenge.m
//  Scholastic
//
//  Created by Gordon Christie on 24/07/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHStoryInteractionReadingChallenge.h"

@implementation SCHStoryInteractionReadingChallengeQuestion

@synthesize answers;
@synthesize correctAnswer;
@synthesize prompt;

- (void)dealloc
{
    [prompt release], prompt = nil;
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

@end

@implementation SCHStoryInteractionReadingChallenge

@synthesize questions;

- (NSString *)audioPathForNotCompletedBook
{
    NSString *filename = [NSString stringWithFormat:@"gen_introductionnotready.mp3"];
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:filename];
}

- (NSString *)audioPathForIntroduction
{
    NSString *filename = [NSString stringWithFormat:@"gen_introductionready.mp3"];
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:filename];
}

- (NSString *)audioPathForAllCorrect
{
    NSString *filename = [NSString stringWithFormat:@"gen_scoreresponsehigh.mp3"];
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:filename];
}

- (NSString *)audioPathForMoreThanFiftyPercent
{
    NSString *filename = [NSString stringWithFormat:@"gen_scoreresponsemedium.mp3"];
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:filename];
}

- (NSString *)audioPathForLessThanFiftyPercent
{
    NSString *filename = [NSString stringWithFormat:@"gen_scoreresponselow.mp3"];
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:filename];
}

- (void)dealloc
{
    [questions release];
    [super dealloc];
}

- (NSString *)title
{
    return @"Reading Challenge";
}


@end
