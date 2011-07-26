//
//  SCHUpdateBooksViewController.m
//  Scholastic
//
//  Created by Neil Gall on 25/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHUpdateBooksViewController.h"
#import "SCHUpdateBooksTableViewCellController.h"
#import "SCHAppBook.h"
#import "UIColor+Scholastic.h"

@interface SCHUpdateBooksViewController ()

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSMutableDictionary *cellControllers;

@end

@implementation SCHUpdateBooksViewController

@synthesize booksTable;
@synthesize updateBooksButton;
@synthesize estimatedDownloadTimeLabel;
@synthesize managedObjectContext;
@synthesize fetchedResultsController;
@synthesize cellControllers;

- (void)releaseViewObjects
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [booksTable release], booksTable = nil;
    [updateBooksButton release], updateBooksButton = nil;
    [estimatedDownloadTimeLabel release], estimatedDownloadTimeLabel = nil;
    [super releaseViewObjects];
}

- (void)dealloc
{
    [managedObjectContext release], managedObjectContext = nil;
    [fetchedResultsController release], fetchedResultsController = nil;
    [cellControllers release], cellControllers = nil;
    [self releaseViewObjects];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setButtonBackground:self.updateBooksButton];

    self.cellControllers = [NSMutableDictionary dictionary];
    
    self.booksTable.layer.cornerRadius = 10;
    self.booksTable.layer.borderWidth = 1;
    self.booksTable.layer.borderColor = [[UIColor SCHGray2Color] CGColor];
    self.booksTable.separatorColor = [UIColor SCHGray2Color];
    self.booksTable.backgroundColor = [UIColor colorWithRed:0.969 green:0.969 blue:0.969 alpha:1.];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(bookUpdatedSuccessfully:)
                                                 name:kSCHBookUpdatedSuccessfullyNotification
                                               object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self releaseViewObjects];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.booksTable reloadData];
}

#pragma mark - UITableViewDataSource

- (id<NSFetchedResultsSectionInfo>)fetchedResultControllerSectionInfo
{
    NSArray *sections = [self.fetchedResultsController sections];
    if ([sections count] == 0) {
        return nil;
    }
    return [sections objectAtIndex:0];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self fetchedResultControllerSectionInfo] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *const CellIdentifier = @"UpdateBooksCell";

    NSManagedObjectID *bookObjectID = [[[self fetchedResultControllerSectionInfo] objects] objectAtIndex:indexPath.row];
    SCHUpdateBooksTableViewCellController *tvc = [self.cellControllers objectForKey:bookObjectID];
    if (!tvc) {
        tvc = [[[SCHUpdateBooksTableViewCellController alloc] initWithBookObjectID:bookObjectID inManagedObjectContext:self.managedObjectContext] autorelease];
        [self.cellControllers setObject:tvc forKey:bookObjectID];
    }
    
    tvc.cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!tvc.cell) {
        [[NSBundle mainBundle] loadNibNamed:@"SCHUpdateBooksTableViewCell" owner:tvc options:nil];
        tvc.cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return tvc.cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - NSFetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController
{
    if (fetchedResultsController == nil) {
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

        NSError *error = nil;
        if (![self.fetchedResultsController performFetch:&error]) {
            NSLog(@"failed to fetch books for update: %@", error);
        }
    }
    return fetchedResultsController;
}

- (BOOL)updatesAvailable
{
    return [[self fetchedResultControllerSectionInfo] numberOfObjects] > 0;
}

#pragma mark - Actions 

- (void)updateBooks:(id)sender
{
    [[self.cellControllers allValues] makeObjectsPerformSelector:@selector(startUpdateIfEnabled)];
}

#pragma mark - Notifications

- (void)bookUpdatedSuccessfully:(NSNotification *)note
{
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"failed to fetch books for update: %@", error);
    }
    // automatically dismiss this view once all books are updated
    if ([[self fetchedResultControllerSectionInfo] numberOfObjects] == 0) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.booksTable reloadData];
    }
}

@end
