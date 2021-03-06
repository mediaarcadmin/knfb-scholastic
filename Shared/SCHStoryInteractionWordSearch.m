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
    [introduction release], words = nil;
    [words release], words = nil;
    [matrix release], matrix = nil;
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
    if (matrixColumns > 0) {
        return [self.matrix length] / matrixColumns;
    } else {
        return 0;
    }
}

- (unichar)matrixLetterAtRow:(NSInteger)row column:(NSInteger)column
{
    NSInteger index = row * matrixColumns + column;
    return [self.matrix characterAtIndex:index];
}

- (NSInteger)wordIndexForLetters:(NSString *)letters
{
    if (letters != nil) {
        for (NSInteger i = 0, n = [words count]; i < n; ++i) {
            NSString *word = [words objectAtIndex:i];
            if (word != nil &&
                [word caseInsensitiveCompare:letters] == NSOrderedSame) {
                return i;
            }
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
    NSParameterAssert(index < [self.words count]);
    
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
