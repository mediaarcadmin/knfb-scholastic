//
//  SCHStoryInteractionWhoSaidIt.h
//  StoryInteractions
//
//  Created by Neil Gall on 30/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHStoryInteraction.h"

@interface SCHStoryInteractionWhoSaidItStatement : NSObject {}

@property (nonatomic, readonly) NSString *source;
@property (nonatomic, readonly) NSString *text;

@end

@interface SCHStoryInteractionWhoSaidIt : SCHStoryInteraction {}

// one of the items in statements
@property (nonatomic, readonly) SCHStoryInteractionWhoSaidItStatement *distracter;

// array of SCHStoryInteractionWhoSaidItStatement
@property (nonatomic, readonly) NSArray *statements;

@end
