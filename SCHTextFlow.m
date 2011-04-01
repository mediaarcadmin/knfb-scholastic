//
//  SCHTextFlow.m
//  Scholastic
//
//  Created by Matt Farrugia on 01/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHTextFlow.h"
#import "SCHBookManager.h"
#import "SCHAppBook.h"
#import "BITXPSProvider.h"
#import "KNFBTextFlowPositionedWord.h"

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
    KNFBTextFlowPositionedWord *word = [[[KNFBTextFlowPositionedWord alloc] init] autorelease];
    word.string = @"matt";
    
    return [NSArray arrayWithObject:word];
}

- (NSArray *)wordStringsForRange:(id)range
{
    return [NSArray arrayWithObjects:@"Foo", @"Bar", nil];
}

- (id)rangeWithStartPage:(NSUInteger)startPage 
              startBlock:(NSUInteger)startBlock
               startWord:(NSUInteger)startWord
                 endPage:(NSUInteger)endPage
                endBlock:(NSUInteger)endBlock
                 endWord:(NSUInteger)endWord
{
    return [[[NSObject alloc] init] autorelease];
}

- (NSSet *)persistedTextFlowPageRanges
{
    SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.isbn];
    return [book TextFlowPageRanges];
}

- (NSData *)textFlowDataWithPath:(NSString *)path
{
    
    NSData *data = nil;
    BITXPSProvider *xpsProvider = [[SCHBookManager sharedBookManager] checkOutXPSProviderForBookIdentifier:self.isbn];
    
    data = [xpsProvider dataForComponentAtPath:[BlioXPSEncryptedTextFlowDir stringByAppendingPathComponent:path]];
    
    [[SCHBookManager sharedBookManager] checkInXPSProviderForBookIdentifier:self.isbn];

    return data;
}

- (NSData *)textFlowRootFileData
{
    BITXPSProvider *xpsProvider = [[SCHBookManager sharedBookManager] checkOutXPSProviderForBookIdentifier:self.isbn];
    NSData *data = [xpsProvider dataForComponentAtPath:BlioXPSTextFlowSectionsFile];
    [[SCHBookManager sharedBookManager] checkInXPSProviderForBookIdentifier:self.isbn];

    return data;
}

@end
