//
//  SCHStoryInteractionWhoSaidIt.h
//  StoryInteractions
//
//  Created by Neil Gall on 30/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHStoryInteraction.h"

@interface SCHStoryInteractionWhoSaidItStatement : SCHStoryInteractionQuestion {}

@property (nonatomic, retain) NSString *source;
@property (nonatomic, retain) NSString *text;

@end

@interface SCHStoryInteractionWhoSaidIt : SCHStoryInteraction {}

// index into 'statements'
@property (nonatomic, assign) NSInteger distracterIndex;

// array of SCHStoryInteractionWhoSaidItStatement
@property (nonatomic, retain) NSArray *statements;

@end
