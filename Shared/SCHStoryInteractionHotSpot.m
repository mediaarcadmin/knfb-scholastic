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
              withPageSize:(CGSize)pageSize
{
    CGRect pageRect;
    switch (pageAssociation) {
        case SCHStoryInteractionQuestionOnBothPages:
            pageRect = CGRectMake(0, 0, pageSize.width*2, pageSize.height);
            break;
        case SCHStoryInteractionQuestionOnLeftPage:
            pageRect = (CGRect){ CGPointZero, pageSize };
            break;
        case SCHStoryInteractionQuestionOnRightPage:
            pageRect = CGRectMake(pageSize.width, 0, pageSize.width, pageSize.height);
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
                                     withPageSize:(CGSize)pageSize
{
    return [[self questionsWithPageAssociation:pageAssociation pageSize:pageSize] count];
}

- (NSArray *)questionsWithPageAssociation:(enum SCHStoryInteractionQuestionPageAssociation)pageAssociation
                                 pageSize:(CGSize)pageSize
{
    NSMutableArray *result = [NSMutableArray array];
    for (SCHStoryInteractionHotSpotQuestion *question in self.questions) {
        if ([question hasPageAssociation:pageAssociation withPageSize:pageSize]) {
            [result addObject:question];
        }
    }
    return [NSArray arrayWithArray:result];
}


@end
