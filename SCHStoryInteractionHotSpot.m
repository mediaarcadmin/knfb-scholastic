//
//  SCHStoryInteractionHotSpot.m
//  StoryInteractions
//
//  Created by Neil Gall on 31/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionHotSpot.h"

#pragma mark - SCHStoryInteractionHotSpotQuestion

@implementation SCHStoryInteractionHotSpotQuestion

@synthesize prompt;
@synthesize hotSpotRect;
@synthesize originalBookSize;
@synthesize data;

- (void)dealloc
{
    [prompt release];
    [data release];
    [super dealloc];
}

@end

#pragma mark - SCHStoryInteractionHotSpot

@implementation SCHStoryInteractionHotSpot

@synthesize questions;

- (void)dealloc
{
    [questions release];
    [super dealloc];
}

@end
