//
//  SCHStoryInteractionWordSearch.m
//  StoryInteractions
//
//  Created by Neil Gall on 31/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionWordSearch.h"

@implementation SCHStoryInteractionWordSearch

@synthesize introduction;
@synthesize words;

- (void)dealloc
{
    [introduction release];
    [words release];
    [super dealloc];
}

- (NSInteger)matrixRows
{
    return 0;
}

- (NSInteger)matrixColumns
{
    return 0;
}

- (NSString *)matrixLetterAtRow:(NSInteger)row column:(NSInteger)column
{
    return nil;
}

@end
