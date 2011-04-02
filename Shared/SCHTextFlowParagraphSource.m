//
//  SCHTextFlowParagraphSource.m
//  Scholastic
//
//  Created by Matt Farrugia on 02/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHTextFlowParagraphSource.h"
#import "SCHBookManager.h"
#import "SCHTextFlow.h"

@interface SCHTextFlowParagraphSource()

@property (nonatomic, retain) NSString *isbn;

@end

@implementation SCHTextFlowParagraphSource

@synthesize isbn;

- (void)dealloc
{
    
    if (self.textFlow) {
//        if(self.xamlEucBook) {
//            [[BlioBookManager sharedBookManager] checkInEucBookForBookWithID:myBookID];
//        }
        [[SCHBookManager sharedBookManager] checkInTextFlowForBookIdentifier:isbn];
    }
    
    [isbn release], isbn = nil;
    
    [super dealloc];
}

- (id)initWithISBN:(NSString *)anIsbn
{
    if ((self = [super initWithBookID:nil])) {
        isbn = [anIsbn retain];
        
        self.textFlow = [[SCHBookManager sharedBookManager] checkOutTextFlowForBookIdentifier:anIsbn];
        
//        if(self.textFlow.flowTreeKind == KNFBTextFlowFlowTreeKindXaml) {
//            self.xamlEucBook = (BlioFlowEucBook *)[[BlioBookManager sharedBookManager] checkOutEucBookForBookWithID:blioBookID];
//        }

    }
    return self;
}

#pragma mark -
#pragma mark Overridden methods

- (void)bookmarkPoint:(id)bookmarkPoint toParagraphID:(id *)paragraphID wordOffset:(uint32_t *)wordOffset
{
    return;
}

- (id)bookmarkPointFromParagraphID:(id)paragraphID wordOffset:(uint32_t)wordOffset 
{
    return nil;
}

- (NSUInteger)pageNumberForBookmarkPoint:(id)bookmarkPoint
{
    return -1;
}

- (id)bookmarkPointForPageNumber:(NSUInteger)pageNumber
{
    return nil;
}

@end
