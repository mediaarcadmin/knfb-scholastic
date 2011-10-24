//
//  SCHStoryInteractionWordSearch.h
//  StoryInteractions
//
//  Created by Neil Gall on 31/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHStoryInteraction.h"

@interface SCHStoryInteractionWordSearch : SCHStoryInteraction {}

@property (nonatomic, retain) NSString *introduction;
@property (nonatomic, assign) NSInteger matrixColumns;
@property (nonatomic, retain) NSString *matrix;

// array of NSString
@property (nonatomic, retain) NSArray *words;

- (NSInteger)matrixRows;
- (unichar)matrixLetterAtRow:(NSInteger)row column:(NSInteger)column;

// get the index in 'words' for a string of selected letters, or NSNotFound if the
// selected letters are not one of the correct words
- (NSInteger)wordIndexForLetters:(NSString *)letters;

// XPS-relative path for the question audio
- (NSString *)audioPathForQuestion;

// XPS-relative path for incorrect answer audio
- (NSString *)audioPathForIncorrectAnswer;

// XPS-relative path for "you found"
- (NSString *)audioPathForYouFound;

// XPS-relative path for audio for each of the words
- (NSString *)audioPathForWordAtIndex:(NSInteger)index;

// XPS-relative path for correct answer audio
- (NSString *)audioPathForCorrectAnswer;

// XPSProvider-relative path for "To find a word, touch the first letter and drag your finger to the last letter"
- (NSString *)dragYourFingerAudioPath;

@end
