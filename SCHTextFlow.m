//
//  SCHTextFlow.m
//  Scholastic
//
//  Created by Matt Farrugia on 01/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHTextFlow.h"

@interface SCHTextFlow()

@property (nonatomic, retain) NSString *isbn;

@end

@implementation SCHTextFlow

@synthesize isbn;

- (id)initWithISBN:(NSString *)newIsbn
{
    if((self = [super initWithBookID:nil])) {
        isbn = [newIsbn retain];
    }
    
    return self;
}

- (void)dealloc
{
    [isbn release], isbn = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Overriden methods

- (NSArray *)wordsForRange:(id)range 
{
    return nil;
}

- (NSArray *)wordStringsForRange:(id)range
{
    return nil;
}

- (id)rangeWithStartPage:(NSUInteger)startPage 
              startBlock:(NSUInteger)startBlock
               startWord:(NSUInteger)startWord
                 endPage:(NSUInteger)endPage
                endBlock:(NSUInteger)endBlock
                 endWord:(NSUInteger)endWord
{
    return nil;
}

- (NSSet *)persistedTextFlowPageRanges
{
    return nil;
}

- (NSData *)textFlowDataWithPath:(NSString *)path
{
    return nil;
}

- (NSData *)textFlowRootFileData
{
    return nil;
}

@end
