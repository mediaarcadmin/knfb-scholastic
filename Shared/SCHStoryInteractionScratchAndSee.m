//
//  SCHStoryInteractionScratchAndSee.m
//  StoryInteractions
//
//  Created by Neil Gall on 31/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionScratchAndSee.h"

#import "KNFBXPSConstants.h"

#pragma mark - SCHStoryInteractionScratchAndSeeQuestion

@implementation SCHStoryInteractionScratchAndSeeQuestion

@synthesize questionIndex;
@synthesize answers;
@synthesize correctAnswer;

- (void)dealloc
{
    [answers release];
    [super dealloc];
}

- (NSString *)title
{
    return @"Scratch And See";
}

- (NSString *)imagePath
{
    NSString *filename = [NSString stringWithFormat:@"%@_q%d.png", self.storyInteraction.ID, self.questionIndex+1];
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:filename];
}

- (NSString *)audioPathForAnswerAtIndex:(NSInteger)index
{
    NSString *filename = [NSString stringWithFormat:@"%@_q%da%d.mp3", self.storyInteraction.ID, self.questionIndex+1, index+1];
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:filename];
}

- (NSString *)correctAnswerAudioPath
{
    NSString *filename = [NSString stringWithFormat:@"%@_ca%d.mp3", self.storyInteraction.ID, self.questionIndex+1];
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:filename];
}

@end


#pragma mark - SCHStoryInteractionScratchAndSee

@implementation SCHStoryInteractionScratchAndSee

@synthesize introduction;
@synthesize questions;

- (void)dealloc
{
    [introduction release];
    [questions release];
    [super dealloc];
}

@end
