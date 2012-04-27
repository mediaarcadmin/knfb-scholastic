//
//  SCHStoryInteractionWordBird.m
//  Scholastic
//
//  Created by Neil Gall on 08/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionWordBird.h"

@implementation SCHStoryInteractionWordBirdQuestion

@synthesize word;
@synthesize suffix;

- (void)dealloc
{
    [word release], word = nil;
    [suffix release], suffix = nil;
    [super dealloc];
}

- (NSString *)audioPathForWord
{
    NSString *filename = [NSString stringWithFormat:@"%@_%@.mp3", self.storyInteraction.ID, self.suffix];
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:filename];
}

- (NSString *)word
{
    return [word uppercaseString];
}

@end

@implementation SCHStoryInteractionWordBird

@synthesize questions;

- (void)dealloc
{
    [questions release], questions = nil;
    [super dealloc];
}

- (NSInteger)questionCount
{
    return [self.questions count];
}

- (BOOL)alwaysIncrementsQuestionIndex
{
    return YES;
}

- (NSString *)title
{
    return @"Word Bird";
}

- (NSString *)audioPathForQuestion
{
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:@"gen_penguinfly.mp3"];
}

- (NSString *)audioPathForLetter:(unichar)letter
{   
    if (letter < L'A' || L'Z' < letter) {
        return nil;
    }
    NSString *filename = [[NSString stringWithFormat:@"gen_%C.mp3", letter] lowercaseString];
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:filename];
}

- (NSString *)audioPathForNiceFlying
{
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:@"gen_niceflying.mp3"];
}

@end
