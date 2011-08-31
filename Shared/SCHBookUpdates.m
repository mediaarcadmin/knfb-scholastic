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

#define DEBUG_FORCE_ENABLE_UPDATES 0

@interface SCHBookUpdates ()
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, assign) BOOL refreshNeeded;
@end

@implementation SCHBookUpdates

@synthesize managedObjectContext;
@synthesize fetchedResultsController;
@synthesize refreshNeeded;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [managedObjectContext release], managedObjectContext = nil;
    [fetchedResultsController release], fetchedResultsController = nil;
    [super dealloc];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (fetchedResultsController == nil && self.managedObjectContext != nil) {
        NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
        [fetch setEntity:[NSEntityDescription entityForName:@"SCHAppBook" inManagedObjectContext:self.managedObjectContext]];
        [fetch setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"ContentMetadataItem.Title" ascending:YES]]];
        
        NSPredicate *statePred = [NSPredicate predicateWithFormat:@"State >= 0"];
        if ([[SCHAppStateManager sharedAppStateManager] canSync] == NO) {
            // show all books
            [fetch setPredicate:statePred];
        } else {
#if DEBUG_FORCE_ENABLE_UPDATES
            [fetch setPredicate:statePred];
#else
            NSPredicate *versionPred = [NSPredicate predicateWithFormat:@"OnDiskVersion != ContentMetadataItem.Version"];
            [fetch setPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:statePred, versionPred, nil]]];
#endif
        }
        
        NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetch
                                                                              managedObjectContext:self.managedObjectContext
                                                                                sectionNameKeyPath:nil
                                                                                         cacheName:@"booksForUpdate"];
        
        self.fetchedResultsController = frc;
        
        [fetch release];
        [frc release];
        
        [self refresh];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(bookStateDidUpdate:)
                                                     name:@"SCHBookStateUpdate"
                                                   object:nil];
    }
    return fetchedResultsController;
}

- (BOOL)areBookUpdatesAvailable
{
    return [[self availableBookUpdates] count] > 0;
}

- (NSArray *)availableBookUpdates
{
    if (self.refreshNeeded) {
        [self refresh];
    }
    
    NSArray *sections = [self.fetchedResultsController sections];
    if ([sections count] == 0) {
        return nil;
    }
    return [NSArray arrayWithArray:[[sections objectAtIndex:0] objects]];
}

- (void)refresh
{
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"unable to refresh SCHBookUpdates: %@", error);
    }
    self.refreshNeeded = NO;
}

#pragma mark - book state updates

- (void)bookStateDidUpdate:(NSNotification *)note
{
    self.refreshNeeded = YES;
}

@end
