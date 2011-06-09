//
//  SCHStoryInteractionTitleTwister.m
//  StoryInteractions
//
//  Created by Neil Gall on 30/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionTitleTwister.h"


@implementation SCHStoryInteractionTitleTwister

@synthesize bookTitle;
@synthesize words;

- (void)dealloc
{
    [bookTitle release];
    [words release];
    [super dealloc];
}

- (NSString *)title
{
    return @"Word Twister";
}

- (BOOL)isOlderStoryInteraction
{
    return YES;
}

@end
