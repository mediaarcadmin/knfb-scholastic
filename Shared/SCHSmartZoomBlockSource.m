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
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end

@implementation SCHSmartZoomBlockSource

@synthesize isbn;
@synthesize managedObjectContext;

- (void)dealloc
{
    if (self.xpsProvider) {
        [[SCHBookManager sharedBookManager] checkInXPSProviderForBookIdentifier:isbn];
    }
    
    [isbn release], isbn = nil;
    [managedObjectContext release], managedObjectContext = nil;
    
    [super dealloc];
}

- (id)initWithISBN:(NSString *)anIsbn managedObjectContext:(NSManagedObjectContext *)moc
{
    if ((self = [super init])) {
        isbn = [anIsbn retain];
        self.managedObjectContext = moc;
        
        self.xpsProvider = [[SCHBookManager sharedBookManager] checkOutXPSProviderForBookIdentifier:anIsbn inManagedObjectContext:moc];
    }
    return self;
}

#pragma mark - Overridden methods

- (NSSet *)persistedSmartZoomPageMarkers;
{
    SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.isbn inManagedObjectContext:self.managedObjectContext];
    return [book SmartZoomPageMarkers];
}

@end
