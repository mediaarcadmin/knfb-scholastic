//
//  SCHStoryInteractionWordMatch.m
//  StoryInteractions
//
//  Created by Neil Gall on 31/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionWordMatch.h"

#pragma mark - SCHStoryInteractionWordMatchQuestion

@implementation SCHStoryInteractionWordMatchQuestion

@synthesize text;

- (void)dealloc
{
    [text release];
    [super dealloc];
}

- (UIImage *)image
{
    return nil;
}

@end

#pragma mark - SCHStoryInteractionWordMatch

@implementation SCHStoryInteractionWordMatch

@synthesize introduction;
@synthesize questions;

- (void)dealloc
{
    [introduction release];
    [questions release];
    [super dealloc];
}

@end
