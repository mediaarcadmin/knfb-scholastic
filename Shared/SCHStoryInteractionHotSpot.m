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
@synthesize path;

- (void)dealloc
{
    [prompt release];
    if (path) {
        CGPathRelease(path);
    }
    [super dealloc];
}

- (void)setPath:(CGPathRef)newPath
{
    if (newPath != path) {
        if (path) {
            CGPathRelease(path);
        }
        path = CGPathRetain(newPath);
    }
}

- (BOOL)hasPageAssociation:(enum SCHStoryInteractionQuestionPageAssociation)pageAssociation
{
    CGRect pageRect;
    switch (pageAssociation) {
        case SCHStoryInteractionQuestionOnBothPages:
            pageRect = CGRectMake(0, 0, originalBookSize.width, originalBookSize.height);
            break;
        case SCHStoryInteractionQuestionOnLeftPage:
            pageRect = CGRectMake(0, 0, originalBookSize.width/2, originalBookSize.height);
            break;
        case SCHStoryInteractionQuestionOnRightPage:
            pageRect = CGRectMake(originalBookSize.width/2, 0, originalBookSize.width/2, originalBookSize.height);
            break;
    }
    return CGRectIntersectsRect(pageRect, hotSpotRect);
}

- (NSString *)audioPathForQuestion
{
    NSString *filename = [NSString stringWithFormat:@"%@_q%d.mp3", self.storyInteraction.ID, self.questionIndex+1];
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:filename];
}

- (NSString *)audioPathForCorrectAnswer
{
    NSString *filename = [NSString stringWithFormat:@"%@_ca%d.mp3", self.storyInteraction.ID, self.questionIndex+1];
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:filename];
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

- (NSString *)title
{
    return @"Touch The Page";
}

- (BOOL)requiresInteractionWithPage
{
    return YES;
}

- (NSInteger)numberOfQuestionsWithPageAssociation:(enum SCHStoryInteractionQuestionPageAssociation)pageAssociation
{
    return [[self questionsWithPageAssociation:pageAssociation] count];
}

- (NSArray *)questionsWithPageAssociation:(enum SCHStoryInteractionQuestionPageAssociation)pageAssociation
{
    NSMutableArray *result = [NSMutableArray array];
    for (SCHStoryInteractionHotSpotQuestion *question in self.questions) {
        if ([question hasPageAssociation:pageAssociation]) {
            [result addObject:question];
        }
    }
    return [NSArray arrayWithArray:result];
}


@end
