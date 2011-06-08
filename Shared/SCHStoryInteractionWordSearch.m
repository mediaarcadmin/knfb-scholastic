//
//  SCHStoryInteractionWordSearch.m
//  StoryInteractions
//
//  Created by Neil Gall on 31/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionWordSearch.h"

@implementation SCHStoryInteractionWordSearch

@synthesize introduction;
@synthesize words;
@synthesize matrix;
@synthesize matrixColumns;

- (void)dealloc
{
    [introduction release];
    [words release];
    [super dealloc];
}

- (NSString *)title
{
    return @"Word Search";
}

- (NSString *)interactionViewTitle
{
    return self.introduction;
}

- (NSInteger)matrixRows
{
    return [self.matrix length] / matrixColumns;
}

- (unichar)matrixLetterAtRow:(NSInteger)row column:(NSInteger)column
{
    NSInteger index = row * matrixColumns + column;
    return [self.matrix characterAtIndex:index];
}

- (NSString *)audioPathForQuestion
{
    NSString *filename = [NSString stringWithFormat:@"%@_intro.mp3", self.ID];
    return [[SCHStoryInteraction resourcesPath] stringByAppendingPathComponent:filename];
}

- (NSString *)audioPathForCorrectAnswer
{
    return [[SCHStoryInteraction resourcesPath] stringByAppendingPathComponent:@"gen_thatsright.mp3"];
}

- (NSString *)audioPathForIncorrectAnswer
{
    return [[SCHStoryInteraction resourcesPath] stringByAppendingPathComponent:@"gen_tryagain.mp3"];
}

- (NSString *)audioPathForYouFoundThemAll
{
    return [[SCHStoryInteraction resourcesPath] stringByAppendingPathComponent:@"gen_gotthemall.mp3"];
}

@end
