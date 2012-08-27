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
    return @"gen_introductionnotready.mp3";
}

- (NSString *)audioPathForIntroduction
{
    return @"gen_introductionready.mp3";
}

- (NSString *)audioPathForAllCorrect
{
    return @"gen_scoreresponsehigh.mp3";
}

- (NSString *)audioPathForMoreThanFiftyPercent
{
    return @"gen_scoreresponsemedium.mp3";
}

- (NSString *)audioPathForLessThanFiftyPercent
{
    return @"gen_scoreresponselow.mp3";
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
