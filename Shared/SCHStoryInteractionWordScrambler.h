//
//  SCHStoryInteractionWordScrambler.h
//  StoryInteractions
//
//  Created by Neil Gall on 30/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHStoryInteraction.h"

@interface SCHStoryInteractionWordScrambler : SCHStoryInteraction {}

@property (nonatomic, retain) NSString *clue;
@property (nonatomic, retain) NSString *answer;

// array of NSNumbers
@property (nonatomic, retain) NSArray *hintIndices;

@end
