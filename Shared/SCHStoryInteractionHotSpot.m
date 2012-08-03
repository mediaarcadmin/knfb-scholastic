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
@synthesize answered;

- (id)init
{
    self = [super init];
    
    if (self) {
        answered = NO;
    }
    
    return self;
}

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

- (enum SCHStoryInteractionQuestionPageAssociation)pageAssociationForPageSize:(CGSize)pageSize
{
    CGRect leftPageRect = (CGRect){ CGPointZero, pageSize };
    CGRect rightPageRect = CGRectMake(pageSize.width, 0, pageSize.width, pageSize.height);
    
    CGRect leftPageIntersection = CGRectIntersection(leftPageRect, hotSpotRect);
    CGRect rightPageIntersection = CGRectIntersection(rightPageRect, hotSpotRect);
    CGFloat leftPageIntersectionArea = CGRectGetWidth(leftPageIntersection)*CGRectGetHeight(leftPageIntersection);
    CGFloat rightPageIntersectionArea = CGRectGetWidth(rightPageIntersection)*CGRectGetHeight(rightPageIntersection);
    
    if (leftPageIntersectionArea > rightPageIntersectionArea) {
        return SCHStoryInteractionQuestionOnLeftPage;
    } else {
        return SCHStoryInteractionQuestionOnRightPage;
    }
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

- (NSInteger)questionCount
{
    return [self.questions count];
}

- (NSArray *)questionsWithPageAssociation:(enum SCHStoryInteractionQuestionPageAssociation)pageAssociation
                                 pageSize:(CGSize)pageSize
{
    NSMutableArray *result = [NSMutableArray array];
    for (SCHStoryInteractionHotSpotQuestion *question in self.questions) {
        if (pageAssociation == SCHStoryInteractionQuestionOnBothPages || pageAssociation == [question pageAssociationForPageSize:pageSize]) {
            [result addObject:question];
        }
    }
    return [NSArray arrayWithArray:result];
}

- (enum SCHStoryInteractionQuestionPageAssociation)pageAssociationForQuestionAtIndex:(NSInteger)questionIndex
                                                                        withPageSize:(CGSize)pageSize
{
    NSParameterAssert(questionIndex < [self.questions count]);
    
    SCHStoryInteractionHotSpotQuestion *question = [self.questions objectAtIndex:questionIndex];
    return [question pageAssociationForPageSize:pageSize];
}


@end
