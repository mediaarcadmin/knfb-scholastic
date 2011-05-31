//
//  SCHStoryInteractionHotSpot.h
//  StoryInteractions
//
//  Created by Neil Gall on 31/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHStoryInteraction.h"

@interface SCHStoryInteractionHotSpotQuestion : NSObject {}

@property (nonatomic, retain) NSString *prompt;
@property (nonatomic, assign) CGRect hotSpotRect;
@property (nonatomic, assign) CGSize originalBookSize;
@property (nonatomic, retain) NSData *data;

@end


@interface SCHStoryInteractionHotSpot : SCHStoryInteraction {}

// array of SCHStoryInteractionHotSpotQuestion
@property (nonatomic, retain) NSArray *questions;

@end
