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
@synthesize matrix;
@synthesize matrixColumns;

- (void)dealloc
{
    [introduction release];
    [words release];
    [super dealloc];
}

- (NSString *)title
{
    return @"Word Search";
}

- (NSInteger)matrixRows
{
    return [self.matrix length] / matrixColumns;
}

- (unichar)matrixLetterAtRow:(NSInteger)row column:(NSInteger)column
{
    NSInteger index = row * matrixColumns + column;
    return [self.matrix characterAtIndex:index];
}

@end
