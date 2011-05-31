//
//  SCHStoryInteractionScratchAndSee.h
//  StoryInteractions
//
//  Created by Neil Gall on 31/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHStoryInteraction.h"

@interface SCHStoryInteractionScratchAndSeeQuestion : NSObject {}

@property (nonatomic, readonly) UIImage *image;

// array of NSStrings
@property (nonatomic, readonly) NSArray *answers;

// index into answers
@property (nonatomic, readonly) NSInteger correctAnswer;

@end


@interface SCHStoryInteractionScratchAndSee : SCHStoryInteraction {}

@property (nonatomic, readonly) NSString *introduction;

// array of SCHStoryInteractionScratchAndSeeQuestion
@property (nonatomic, readonly) NSArray *questions;

@end
