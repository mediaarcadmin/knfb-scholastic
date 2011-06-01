//
//  SCHStoryInteraction.m
//  StoryInteractions
//
//  Created by Neil Gall on 30/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteraction.h"
#import "SCHStoryInteractionParser.h"

@implementation SCHStoryInteractionQuestion

@synthesize storyInteraction;
@synthesize questionIndex;

- (NSString *)audioPathForThatsRight
{
    return [[SCHStoryInteraction resourcesPath] stringByAppendingPathComponent:@"gen_thatsright.mp3"];
}

@end

@implementation SCHStoryInteraction

@synthesize ID;
@synthesize documentPageNumber;
@synthesize position;

+ (NSString *)resourcesPath
{
    return @"/Documents/1/Other/KNFB/Interactions/Interactions.xml";
}

+ (NSArray *)storyInteractionsFromXpsProvider:(SCHXPSProvider *)xpsProvider
{
    SCHStoryInteractionParser *parser = [[SCHStoryInteraction alloc] init];
    NSArray *storyInteractions = [parser parseStoryInteractionsFromXPSProvider:xpsProvider];
    [parser release];
    return storyInteractions;
}

@end