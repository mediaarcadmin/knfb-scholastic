//
//  SCHBookUpdates.m
//  Scholastic
//
//  Created by Neil Gall on 26/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBookUpdates.h"
#import "SCHAppBook.h"

@interface SCHBookUpdates ()
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@end

@implementation SCHBookUpdates

@synthesize managedObjectContext;
@synthesize fetchedResultsController;

- (void)dealloc
{
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
        [fetch setResultType:NSManagedObjectIDResultType];
        
        NSPredicate *statePred = [NSPredicate predicateWithFormat:@"State = %d", SCHBookProcessingStateReadyToRead];
#ifdef LOCALDEBUG
        // show all books in local files build
        [fetch setPredicate:statePred];
#else
        NSPredicate *versionPred = [NSPredicate predicateWithFormat:@"OnDiskVersion != ContentMetadataItem.Version"];
        [fetch setPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:statePred, versionPred, nil]]];
#endif
        
        NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetch
                                                                              managedObjectContext:self.managedObjectContext
                                                                                sectionNameKeyPath:nil
                                                                                         cacheName:@"booksForUpdate"];
        
        self.fetchedResultsController = frc;
        
        [fetch release];
        [frc release];
        
        [self refresh];
    }
    return fetchedResultsController;
}

- (BOOL)areBookUpdatesAvailable
{
    return [[self managedObjectIDsForAvailableBookUpdates] numberOfObjects] > 0;
}

- (id<NSFetchedResultsSectionInfo>)managedObjectIDsForAvailableBookUpdates
{
    NSArray *sections = [self.fetchedResultsController sections];
    if ([sections count] == 0) {
        return nil;
    }
    return [sections objectAtIndex:0];
}

- (void)refresh
{
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"unable to refresh SCHBookUpdates: %@", error);
    }
}

@end
