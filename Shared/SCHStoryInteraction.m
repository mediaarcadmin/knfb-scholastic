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

- (BOOL)isOlderStoryInteraction
{
    return NO;
}

- (NSString *)title
{
    // override in subclasses
    return nil;
}

- (NSString *)interactionViewTitle
{
    return [self title];
}

+ (NSString *)resourcesPath
{
    return @"/Documents/1/Other/KNFB/Interactions";
}

@end
