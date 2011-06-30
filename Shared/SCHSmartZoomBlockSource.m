//
//  SCHSmartZoomBlockSource.m
//  Scholastic
//
//  Created by Matt Farrugia on 13/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHSmartZoomBlockSource.h"
#import "SCHBookManager.h"
#import "SCHBookIdentifier.h"
#import "SCHTextFlow.h"
#import "SCHAppBook.h"
#import "SCHXPSProvider.h"

@interface SCHSmartZoomBlockSource()

@property (nonatomic, retain) SCHBookIdentifier *identifier;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end

@implementation SCHSmartZoomBlockSource

@synthesize identifier;
@synthesize managedObjectContext;

- (void)dealloc
{
    if (self.xpsProvider) {
        [[SCHBookManager sharedBookManager] checkInXPSProviderForBookIdentifier:self.identifier];
    }
    
    [identifier release], identifier = nil;
    [managedObjectContext release], managedObjectContext = nil;
    
    [super dealloc];
}

- (id)initWithBookIdentifier:(SCHBookIdentifier *)bookIdentifier managedObjectContext:(NSManagedObjectContext *)moc
{
    if ((self = [super init])) {
        identifier = [bookIdentifier retain];
        self.managedObjectContext = moc;
        
        self.xpsProvider = [[SCHBookManager sharedBookManager] checkOutXPSProviderForBookIdentifier:bookIdentifier inManagedObjectContext:moc];
    }
    return self;
}

#pragma mark - Overridden methods

- (NSSet *)persistedSmartZoomPageMarkers;
{
    SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.identifier inManagedObjectContext:self.managedObjectContext];
    return [book SmartZoomPageMarkers];
}

@end
