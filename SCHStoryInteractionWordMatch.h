//
//  SCHStoryInteractionWordMatch.h
//  StoryInteractions
//
//  Created by Neil Gall on 31/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHStoryInteraction.h"

@interface SCHStoryInteractionWordMatchQuestion : NSObject {}

@property (nonatomic, readonly) NSString *text;
@property (nonatomic, readonly) UIImage *image;

@end


@interface SCHStoryInteractionWordMatch : SCHStoryInteraction {}

@property (nonatomic, readonly) NSString *introduction;

// array of SCHStoryInteractionWordMatchQuestion
@property (nonatomic, readonly) NSArray *questions;

@end
