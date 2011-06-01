//
//  SCHStoryInteractionTitleTwister.h
//  StoryInteractions
//
//  Created by Neil Gall on 30/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHStoryInteraction.h"

@interface SCHStoryInteractionTitleTwister : SCHStoryInteraction {}

@property (nonatomic, retain) NSString *bookTitle;

// array of NSStrings
@property (nonatomic, retain) NSArray *words;

@end
