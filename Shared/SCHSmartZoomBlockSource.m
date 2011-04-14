//
//  SCHSmartZoomBlockSource.m
//  Scholastic
//
//  Created by Matt Farrugia on 13/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHSmartZoomBlockSource.h"
#import "SCHBookManager.h"
#import "SCHTextFlow.h"
#import "SCHAppBook.h"
#import "SCHXPSProvider.h"

@interface SCHSmartZoomBlockSource()

@property (nonatomic, retain) NSString *isbn;

@end

@implementation SCHSmartZoomBlockSource

@synthesize isbn;

- (void)dealloc
{
    if (self.xpsProvider) {
        [[SCHBookManager sharedBookManager] checkInXPSProviderForBookIdentifier:isbn];
    }
    
    [isbn release], isbn = nil;
    
    [super dealloc];
}

- (id)initWithISBN:(NSString *)anIsbn
{
    if ((self = [super init])) {
        isbn = [anIsbn retain];
        
        self.xpsProvider = [[SCHBookManager sharedBookManager] checkOutXPSProviderForBookIdentifier:anIsbn];
    }
    return self;
}

#pragma mark - Overridden methods

- (NSSet *)persistedSmartZoomPageMarkers;
{
    SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.isbn];
    return [book SmartZoomPageMarkers];
}

@end
