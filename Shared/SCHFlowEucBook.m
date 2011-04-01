//
//  SCHFlowEucBook.m
//  Scholastic
//
//  Created by Gordon Christie on 31/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHFlowEucBook.h"
#import "SCHBookManager.h"
#import "SCHTextFlow.h"
#import "SCHAppBook.h"

@interface SCHFlowEucBook ()

@property (nonatomic, assign) NSString *isbn;

@end


@implementation SCHFlowEucBook

@synthesize isbn;

- (id)initWithISBN:(NSString *)newIsbn
{
    if((self = [super init])) {
        self.isbn = newIsbn;
        self.textFlow = [[SCHBookManager sharedBookManager] checkOutTextFlowForBookIdentifier:newIsbn];
        self.fakeCover = self.textFlow.flowTreeKind == KNFBTextFlowFlowTreeKindFlow;
        
        SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:newIsbn];
        self.title = [book XPSTitle];
        self.author = [book XPSAuthor];
        
        self.cacheDirectoryPath = [book libEucalyptusCache];
    }
    
    return self;
}

- (void)dealloc
{
    [[SCHBookManager sharedBookManager] checkInTextFlowForBookIdentifier:self.isbn];
    self.isbn = nil;
    
    [super dealloc];
}


@end
