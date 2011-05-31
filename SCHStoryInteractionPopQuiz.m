//
//  SCHStoryInteractionPopQuiz.m
//  StoryInteractions
//
//  Created by Neil Gall on 30/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionPopQuiz.h"

@implementation SCHStoryInteractionPopQuiz

@synthesize scoreResponseLow;
@synthesize scoreResponseMedium;
@synthesize scoreResponseHigh;

- (void)dealloc
{
    [scoreResponseLow release];
    [scoreResponseMedium release];
    [scoreResponseHigh release];
    [super dealloc];
}

@end
