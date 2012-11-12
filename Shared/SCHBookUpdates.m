//
//  SCHBookUpdates.m
//  Scholastic
//
//  Created by Neil Gall on 26/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBookUpdates.h"
#import "SCHAppBook.h"
#import "SCHBookIdentifier.h"
#import "SCHBookManager.h"
#import "SCHAppStateManager.h"
#import "SCHContentMetadataItem.h"
#import "SCHBooksAssignment.h"
#import "SCHAuthenticationManager.h"
#import "SCHProcessingManager.h"

#define DEBUG_FORCE_ENABLE_UPDATES 0

static const NSTimeInterval kSCHBookUpdatesDelayRefreshNoBooks = 60.0; // secs

@interface SCHBookUpdates ()

@property (nonatomic, assign) BOOL refreshNeeded;
@property (nonatomic, retain) NSMutableArray *results;
@property (nonatomic, retain) NSDate *lastRefresh;

- (BOOL)shouldRefreshIfNoBooks;

@end

@implementation SCHBookUpdates

@synthesize managedObjectContext;
@synthesize results;
@synthesize refreshNeeded;
@synthesize lastRefresh;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [results release], results = nil;
    [lastRefresh release], lastRefresh = nil;

    [super dealloc];
}

- (id)init
{
    self = [super init];
    
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(bookStateDidUpdate:)
                                                     name:@"SCHBookStateUpdate"
                                                   object:nil];
  
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(authenticationManagerDidDeregisterNotification:)
                                                     name:SCHAuthenticationManagerDidDeregisterNotification
                                                   object:nil];

        self.results = [NSMutableArray array];
    }
    
    return self;
}

- (BOOL)areBookUpdatesAvailable
{
    return [[self availableBookUpdates] count] > 0;
}

- (NSArray *)availableBookUpdates
{
#if UPDATE_BOOKS_DISABLED
    return [NSArray array];
#else
    if (self.refreshNeeded || [self shouldRefreshIfNoBooks] == YES) {
        [self refresh];
    }
    
    if ([self.results count] == 0) {
        return nil;
    }
    return [NSArray arrayWithArray:results];
#endif
}

- (BOOL)shouldRefreshIfNoBooks
{
    BOOL ret = NO;

    if ([self.results count] == 0) {
        if (self.lastRefresh == nil ||
            [self.lastRefresh timeIntervalSinceNow] > kSCHBookUpdatesDelayRefreshNoBooks) {
            ret = YES;
        }
    }

    return ret;
}

- (void)refresh
{
    NSError *error = nil;
    
    [self.results removeAllObjects];
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:[NSEntityDescription entityForName:@"SCHAppBook" inManagedObjectContext:self.managedObjectContext]];
    [fetch setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"ContentMetadataItem.Title" ascending:YES]]];
    
    NSPredicate *statePred = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"State == %@", [NSNumber numberWithInt:SCHBookProcessingStateReadyToRead]]];
    [fetch setPredicate:statePred];
    NSArray *allAppBooks = [self.managedObjectContext executeFetchRequest:fetch error:&error];
    [fetch release], fetch = nil;
    if (allAppBooks == nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }

    [allAppBooks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
#if FAKE_BOOK_UPDATES_REQUIRED == 0
        SCHContentMetadataItem *contentMetadataItem = [(SCHAppBook*) obj ContentMetadataItem];
        
        NSString *onDiskVersion = [(SCHAppBook*) obj OnDiskVersion];
        BOOL validOnDiskVersion = (onDiskVersion != nil);
                
        if (validOnDiskVersion && ([contentMetadataItem.booksAssignment.version integerValue] > [onDiskVersion integerValue])) {
            [self.results addObject:obj];
        }
#else
        [self.results addObject:obj];
#endif

    }];

    self.lastRefresh = [NSDate date];
    self.refreshNeeded = NO;
}

#pragma mark - book state updates

- (void)bookStateDidUpdate:(NSNotification *)note
{
    self.refreshNeeded = YES;
}

- (void)authenticationManagerDidDeregisterNotification:(NSNotification *)note
{
    self.refreshNeeded = YES;    
}

@end
