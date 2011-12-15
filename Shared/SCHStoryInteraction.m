//
//  SCHStoryInteraction.m
//  StoryInteractions
//
//  Created by Neil Gall on 30/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteraction.h"
#import "SCHStoryInteractionParser.h"

@implementation SCHStoryInteractionQuestion

@synthesize storyInteraction;
@synthesize questionIndex;

@end

@implementation SCHStoryInteraction

@synthesize ID;
@synthesize documentPageNumber;
@synthesize position;
@synthesize bookStoryInteractions;
@synthesize olderStoryInteraction;

- (void)dealloc
{
    [ID release], ID = nil;
    
    [super dealloc];
}
- (BOOL)isValid
{
    return(YES);
}

- (NSString *)title
{
    // override in subclasses
    return nil;
}

- (NSString *)interactionViewTitle
{
    return [self title];
}

- (BOOL)requiresInteractionWithPage
{
    return NO;
}

- (enum SCHStoryInteractionQuestionPageAssociation)pageAssociationForQuestionAtIndex:(NSInteger)questionIndex
                                                                        withPageSize:(CGSize)pageSize
{
    return SCHStoryInteractionQuestionOnBothPages;
}

- (NSInteger)questionCount
{
    return 1;
}

- (NSString *)storyInteractionButtonAppearingSoundFilename
{
    if ([self isOlderStoryInteraction]) {
        return @"sfx_siappears_o.mp3";
    } else {
        return @"sfx_siappears_y2B.mp3";
    }
}

- (NSString *)storyInteractionOpeningSoundFilename
{
    if ([self isOlderStoryInteraction]) {
        return @"sfx_siopen_o.mp3";
    } else {
        return @"sfx_siopen_y.mp3";
    }
}

- (NSString *)audioPathForQuestion
{
    return nil;
}

- (NSString *)audioPathForThatsRight
{
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:@"gen_thatsright.mp3"];
}

- (NSString *)audioPathForTryAgain
{
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:@"gen_tryagain.mp3"];
}

- (NSString *)storyInteractionCorrectAnswerSoundFilename
{
    if ([self isOlderStoryInteraction]) {
        return @"sfx_ca_o.mp3";
    } else {
        return @"sfx_ca_y.mp3";
    }
}

- (NSString *)storyInteractionWrongAnswerSoundFilename
{
    if ([self isOlderStoryInteraction]) {
        return @"sfx_wa_o.mp3";
    } else {
        return @"sfx_wa_y.mp3";
    }
}

- (NSString *)storyInteractionRevealSoundFilename
{
    return @"sfx_youReveal.mp3";
}

- (BOOL)hasQuestionsOnLeftPageForPageSize:(CGSize)pageSize
{
    NSInteger questionCount = [self questionCount];
    for (NSInteger questionIndex = 0; questionIndex < questionCount; ++questionIndex) {
        if ([self pageAssociationForQuestionAtIndex:questionIndex withPageSize:pageSize] == SCHStoryInteractionQuestionOnLeftPage) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)hasQuestionsOnRightPageForPageSize:(CGSize)pageSize
{
    NSInteger questionCount = [self questionCount];
    for (NSInteger questionIndex = 0; questionIndex < questionCount; ++questionIndex) {
        if ([self pageAssociationForQuestionAtIndex:questionIndex withPageSize:pageSize] == SCHStoryInteractionQuestionOnRightPage) {
            return YES;
        }
    }
    return NO;
}

- (NSInteger)numberOfQuestionsWithPageAssociation:(enum SCHStoryInteractionQuestionPageAssociation)pageAssociation withPageSize:(CGSize)pageSize
{
    NSInteger count = 0;
    NSInteger questionCount = [self questionCount];
    for (NSInteger questionIndex = 0; questionIndex < questionCount; ++questionIndex) {
        if ([self pageAssociationForQuestionAtIndex:questionIndex withPageSize:pageSize] == pageAssociation) {
            count++;
        }
    }
    return count;
}

@end
