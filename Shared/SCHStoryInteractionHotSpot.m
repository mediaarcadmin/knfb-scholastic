//
//  SCHStoryInteractionHotSpot.m
//  StoryInteractions
//
//  Created by Neil Gall on 31/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionHotSpot.h"

#import "SCHHotSpotCoordinates.h"

#pragma mark - SCHStoryInteractionHotSpotQuestion

@implementation SCHStoryInteractionHotSpotQuestion

@synthesize prompt;
@synthesize hotSpots;
@synthesize originalBookSize;
@synthesize answered;

- (id)init
{
    self = [super init];
    
    if (self) {
        hotSpots = [[NSMutableArray alloc] init];
        answered = NO;
    }
    
    return self;
}

- (void)dealloc
{
    [prompt release];
    [hotSpots release], hotSpots = nil;
    [super dealloc];
}

- (enum SCHStoryInteractionQuestionPageAssociation)pageAssociationForPageSize:(CGSize)pageSize
{
    CGRect leftPageRect = (CGRect){ CGPointZero, pageSize };
    CGRect rightPageRect = CGRectMake(pageSize.width, 0, pageSize.width, pageSize.height);

    // Assume all hotspots appear on the same page: use first one
    CGRect hotSpotRect = CGRectZero;
    if ([self.hotSpots count] > 0) {
        hotSpotRect = [[self.hotSpots objectAtIndex:0] rect];
    }
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

@synthesize introduction;
@synthesize questions;

- (NSString *)audioPathForIntroduction
{
    NSString *filename = [NSString stringWithFormat:@"%@_intro.mp3", self.ID];
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:filename];
}

- (void)dealloc
{
    [introduction release], introduction = nil;
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
