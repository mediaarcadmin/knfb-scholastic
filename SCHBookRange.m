//
//  SCHBookRange.m
//  Scholastic
//
//  Created by Matt Farrugia on 01/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBookRange.h"

@implementation SCHBookRange

@synthesize startPage;
@synthesize startBlock;
@synthesize startWord;
@synthesize endPage;
@synthesize endBlock;
@synthesize endWord;

- (id)initWithStartPage:(NSUInteger)aStartPage 
             startBlock:(NSUInteger)aStartBlock
              startWord:(NSUInteger)aStartWord
                endPage:(NSUInteger)aEndPage
               endBlock:(NSUInteger)aEndBlock
                endWord:(NSUInteger)aEndWord
{
    if ((self = [super init])) {
        startPage = aStartPage;
        startBlock = aStartBlock;
        startWord = aStartWord;
        endPage = aEndPage;
        endBlock = aEndBlock;
        endWord = aEndWord;
    }
    
    return self;
}

@end
