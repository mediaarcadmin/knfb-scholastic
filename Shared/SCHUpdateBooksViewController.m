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
    [booksTable release], booksTable = nil;
    [updateBooksButton release], updateBooksButton = nil;
    [estimatedDownloadTimeLabel release], estimatedDownloadTimeLabel = nil;
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
    
    self.booksTable.layer.cornerRadius = 12;
    self.booksTable.layer.borderWidth = 2;
    self.booksTable.layer.borderColor = [[UIColor SCHGrayColor] CGColor];
    self.booksTable.separatorColor = [UIColor SCHGrayColor];
    self.booksTable.backgroundColor = [UIColor colorWithRed:0.969 green:0.969 blue:0.969 alpha:1.];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self releaseViewObjects];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
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
    }
    
    return tvc.cell;
}

#pragma mark - UITableViewDelegate

#pragma mark - NSFetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController
{
    if (fetchedResultsController == nil) {
        NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
        [fetch setEntity:[NSEntityDescription entityForName:@"SCHAppBook" inManagedObjectContext:self.managedObjectContext]];
        [fetch setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"ContentMetadataItem.Title" ascending:YES]]];
        [fetch setResultType:NSManagedObjectIDResultType];
        
        // FIXME: show all books for now
        //[fetch setPredicate:[NSPredicate predicateWithFormat:@"OnDiskVersion != ContentMetadataItem.Version"]];
        
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

#pragma mark - Actions 

- (void)updateBooks:(id)sender
{
    [[self.cellControllers allValues] makeObjectsPerformSelector:@selector(startUpdateIfEnabled)];
}

@end
