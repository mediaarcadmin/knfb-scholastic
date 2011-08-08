//
//  SCHStoryInteractionWordBird.h
//  Scholastic
//
//  Created by Neil Gall on 08/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteraction.h"

@interface SCHStoryInteractionWordBirdQuestion : SCHStoryInteractionQuestion {}

@property (nonatomic, retain) NSString *word;
@property (nonatomic, retain) NSString *suffix;

@end

@interface SCHStoryInteractionWordBird : SCHStoryInteraction {}

@property (nonatomic, retain) NSArray *questions;

@end
