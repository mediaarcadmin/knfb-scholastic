//
//  SCHStoryInteraction.m
//  StoryInteractions
//
//  Created by Neil Gall on 30/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteraction.h"
#import "SCHStoryInteractionParser.h"

@implementation SCHStoryInteraction

@synthesize documentPageNumber;
@synthesize position;

+ (NSArray *)storyInteractionsFromXpsProvider:(SCHXPSProvider *)xpsProvider
{
    SCHStoryInteractionParser *parser = [[SCHStoryInteraction alloc] init];
    NSArray *storyInteractions = [parser parseStoryInteractionsFromXPSProvider:xpsProvider];
    [parser release];
    return storyInteractions;
}

@end
