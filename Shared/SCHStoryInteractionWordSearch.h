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

@end
