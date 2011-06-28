//
//  SCHStoryInteractionWordScrambler.m
//  StoryInteractions
//
//  Created by Neil Gall on 30/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionWordScrambler.h"


@implementation SCHStoryInteractionWordScrambler

@synthesize clue;
@synthesize answer;
@synthesize hintIndices;

- (void)dealloc
{
    [clue release];
    [answer release];
    [hintIndices release];
    [super dealloc];
}

- (BOOL)isOlderStoryInteraction
{
    return YES;
}

- (NSString *)title
{
    return @"Scramble";
}

@end
