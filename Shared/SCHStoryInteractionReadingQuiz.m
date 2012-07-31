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

- (NSString *)audioPathForQuestion
{
    NSString *filename = [NSString stringWithFormat:@"rq_q%d.mp3", self.questionIndex+1];
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:filename];
}

- (NSString *)audioPathForAnswerAtIndex:(NSInteger)answerIndex
{
    NSString *filename = [NSString stringWithFormat:@"rq_q%da%d.mp3", self.questionIndex+1, answerIndex+1];
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:filename];
}

@end

@implementation SCHStoryInteractionReadingQuiz

@synthesize questions;

- (NSString *)audioPathForNotCompletedBook
{
    NSString *filename = [NSString stringWithFormat:@"rq_notcomplete.mp3"];
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:filename];
}

- (NSString *)audioPathForIntroduction
{
    NSString *filename = [NSString stringWithFormat:@"rq_intro.mp3"];
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:filename];
}

- (NSString *)audioPathForAllCorrect
{
    NSString *filename = [NSString stringWithFormat:@"rq_allcorrect.mp3"];
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:filename];
}

- (NSString *)audioPathForMoreThanFiftyPercent
{
    NSString *filename = [NSString stringWithFormat:@"rq_morethanfiftypercent.mp3"];
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:filename];
}

- (NSString *)audioPathForLessThanFiftyPercent
{
    NSString *filename = [NSString stringWithFormat:@"rq_lessthanfiftypercent.mp3"];
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
