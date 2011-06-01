//
//  SCHStoryInteractionHotSpot.m
//  StoryInteractions
//
//  Created by Neil Gall on 31/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionHotSpot.h"

#pragma mark - SCHStoryInteractionHotSpotQuestion

@implementation SCHStoryInteractionHotSpotQuestion

@synthesize prompt;
@synthesize hotSpotRect;
@synthesize originalBookSize;
@synthesize data;

- (void)dealloc
{
    [prompt release];
    [data release];
    [super dealloc];
}

- (NSString *)audioPathForQuestion
{
    NSString *filename = [NSString stringWithFormat:@"%@_q%d.mp3", self.storyInteraction.ID, self.questionIndex+1];
    return [[SCHStoryInteraction resourcesPath] stringByAppendingPathComponent:filename];
}

- (NSString *)audioPathForCorrectAnswer
{
    NSString *filename = [NSString stringWithFormat:@"%@_ca%d.mp3", self.storyInteraction.ID, self.questionIndex+1];
    return [[SCHStoryInteraction resourcesPath] stringByAppendingPathComponent:filename];
}

@end

#pragma mark - SCHStoryInteractionHotSpot

@implementation SCHStoryInteractionHotSpot

@synthesize questions;

- (void)dealloc
{
    [questions release];
    [super dealloc];
}

@end