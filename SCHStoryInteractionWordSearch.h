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

@property (nonatomic, readonly) NSString *introduction;

// array of NSString
@property (nonatomic, readonly) NSArray *words;

- (NSInteger)matrixRows;
- (NSInteger)matrixColumns;
- (NSString *)matrixLetterAtRow:(NSInteger)row column:(NSInteger)column;

@end
