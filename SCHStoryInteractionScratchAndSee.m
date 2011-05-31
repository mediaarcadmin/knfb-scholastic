//
//  SCHStoryInteractionScratchAndSee.m
//  StoryInteractions
//
//  Created by Neil Gall on 31/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionScratchAndSee.h"

#pragma mark - SCHStoryInteractionScratchAndSeeQuestion

@implementation SCHStoryInteractionScratchAndSeeQuestion

@synthesize answers;
@synthesize correctAnswer;

- (void)dealloc
{
    [answers release];
    [super dealloc];
}

- (UIImage *)image
{
    return nil;
}

@end


#pragma mark - SCHStoryInteractionScratchAndSee

@implementation SCHStoryInteractionScratchAndSee

@synthesize introduction;
@synthesize questions;

- (void)dealloc
{
    [introduction release];
    [questions release];
    [super dealloc];
}

@end
