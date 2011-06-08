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

// XPS-relative path for the question audio
- (NSString *)audioPathForQuestion;

// XPS-relative path for incorrect answer audio
- (NSString *)audioPathForIncorrectAnswer;

// XPS-relative path for correct answer audio
- (NSString *)audioPathForCorrectAnswer;

// XPS-relative path for 'you found them all' all
- (NSString *)audioPathForYouFoundThemAll;

@end
