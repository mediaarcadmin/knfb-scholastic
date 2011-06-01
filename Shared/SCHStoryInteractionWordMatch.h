//
//  SCHStoryInteractionWordMatch.h
//  StoryInteractions
//
//  Created by Neil Gall on 31/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHStoryInteraction.h"

@class SCHStoryInteractionWordMatch;

@interface SCHStoryInteractionWordMatchQuestionItem : NSObject {}

@property (nonatomic, assign) SCHStoryInteraction *storyInteraction;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSString *uniqueObjectName;

// XPSProvider-relative path for item image
- (NSString *)imagePath;

// XPSProvider-relative path for item audio
- (NSString *)audioPath;

@end


@interface SCHStoryInteractionWordMatchQuestion : SCHStoryInteractionQuestion {}

// array of SCHStoryInteractionWordMatchQuestionItem
@property (nonatomic, retain) NSArray *items;

@end


@interface SCHStoryInteractionWordMatch : SCHStoryInteraction {}

@property (nonatomic, retain) NSString *introduction;

// array of SCHStoryInteractionWordMatchQuestion
@property (nonatomic, retain) NSArray *questions;

@end
