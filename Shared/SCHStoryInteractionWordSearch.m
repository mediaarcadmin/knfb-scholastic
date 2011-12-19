//
//  SCHStoryInteractionWordSearch.m
//  StoryInteractions
//
//  Created by Neil Gall on 31/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionWordSearch.h"

#import "KNFBXPSConstants.h"

@implementation SCHStoryInteractionWordSearch

@synthesize introduction;
@synthesize words;
@synthesize matrix;
@synthesize matrixColumns;

- (void)dealloc
{
    [matrix release], matrix = nil;
    [introduction release], introduction = nil;
    [words release], words = nil;
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

- (NSInteger)wordIndexForLetters:(NSString *)letters
{
    for (NSInteger i = 0, n = [words count]; i < n; ++i) {
        if ([[words objectAtIndex:i] caseInsensitiveCompare:letters] == NSOrderedSame) {
            return i;
        }
    }
    return NSNotFound;
}

- (NSString *)audioPathForQuestion
{
    NSString *filename = [NSString stringWithFormat:@"%@_intro.mp3", self.ID];
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:filename];
}

- (NSString *)audioPathForCorrectAnswer
{
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:@"gen_thatsright.mp3"];
}

- (NSString *)audioPathForYouFound
{
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:@"gen_youfound.mp3"];
}

- (NSString *)audioPathForWordAtIndex:(NSInteger)index
{
    NSString *filename = [NSString stringWithFormat:@"%@_%@.mp3", self.ID, [[self.words objectAtIndex:index] lowercaseString]];
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:filename];
}

- (NSString *)audioPathForIncorrectAnswer
{
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:@"gen_tryagain.mp3"];
}

- (NSString *)dragYourFingerAudioPath
{
    return @"Interaction1_Relaxed.mp3";
}

@end
