//
//  SCHStoryInteractionWordMatch.m
//  StoryInteractions
//
//  Created by Neil Gall on 31/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionWordMatch.h"

#import "KNFBXPSConstants.h"

#pragma mark - SCHStoryInteractionWordMatchQuestionItem

@implementation SCHStoryInteractionWordMatchQuestionItem

@synthesize text;
@synthesize uniqueObjectName;

- (void)dealloc
{
    [text release];
    [uniqueObjectName release];
    [super dealloc];
}

- (NSString *)imagePath
{
    NSString *filename = [NSString stringWithFormat:@"%@_%@.png", self.storyInteraction.ID, self.uniqueObjectName];
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:filename];        
}

- (NSString *)audioPath
{
    NSString *filename = [NSString stringWithFormat:@"%@_%@.mp3", self.storyInteraction.ID, self.uniqueObjectName];
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:filename];        
}

@end

#pragma mark - SCHStoryInteractionWordMatchQuestion

@implementation SCHStoryInteractionWordMatchQuestion

@synthesize items;

- (void)dealloc
{
    [items release];
    [super dealloc];
}

@end

#pragma mark - SCHStoryInteractionWordMatch

@implementation SCHStoryInteractionWordMatch

@synthesize introduction;
@synthesize questions;

- (void)dealloc
{
    [introduction release];
    [questions release];
    [super dealloc];
}

- (NSString *)title
{
    return @"Word Match";
}

- (NSString *)interactionViewTitle
{
    return [self introduction];
}

- (NSInteger)questionCount
{
    return [[self questions] count];
}

- (NSString *)audioPathForQuestion
{
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:@"gen_matchthewords.mp3"];
}

@end
