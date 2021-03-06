//
//  SCHStoryInteractionStartingLetter.m
//  StoryInteractions
//
//  Created by Neil Gall on 31/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionStartingLetter.h"

#import "KNFBXPSConstants.h"

#pragma mark - SCHStoryInteractionStartingLetterQuestion

@implementation SCHStoryInteractionStartingLetterQuestion

@synthesize isCorrect;
@synthesize uniqueObjectName;

- (void)dealloc
{
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

#pragma mark - SCHStoryInteractionStartingLetter

@implementation SCHStoryInteractionStartingLetter

@synthesize prompt;
@synthesize startingLetter;
@synthesize questions;

- (void)dealloc
{
    [prompt release];
    [startingLetter release];
    [questions release];
    [super dealloc];
}

- (NSString *)title
{
    return @"Starting Letter";
}

- (NSString *)audioPathForQuestion
{
    NSString *filename = [NSString stringWithFormat:@"%@_intro.mp3", self.ID];
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:filename];
}

- (NSString *)audioPathForStartsWith
{
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:@"gen_startswith.mp3"];
}

- (NSString *)audioPathForLetter
{
    NSString *filename = [NSString stringWithFormat:@"gen_%@.mp3", self.startingLetter];
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:filename];

}

- (NSString *)audioPathForDoesntStartWith
{
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:@"gen_doesntstartwith.mp3"];
}


@end
