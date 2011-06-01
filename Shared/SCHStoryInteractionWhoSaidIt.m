//
//  SCHStoryInteractionWhoSaidIt.m
//  StoryInteractions
//
//  Created by Neil Gall on 30/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionWhoSaidIt.h"

@implementation SCHStoryInteractionWhoSaidItStatement

@synthesize source;
@synthesize text;

- (void)dealloc
{
    [source release];
    [text release];
    [super dealloc];
}

@end

@implementation SCHStoryInteractionWhoSaidIt

@synthesize statements;
@synthesize distracterIndex;

- (void)dealloc
{
    [statements release];
    [super dealloc];
}

- (NSString *)title
{
    return @"Who Said It";
}

@end
