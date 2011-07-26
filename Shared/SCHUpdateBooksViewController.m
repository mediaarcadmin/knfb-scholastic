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
#import "SCHBookUpdates.h"
#import "UIColor+Scholastic.h"

@interface SCHUpdateBooksViewController ()
@property (nonatomic, retain) NSMutableDictionary *cellControllers;
@end

@implementation SCHUpdateBooksViewController

@synthesize booksTable;
@synthesize updateBooksButton;
@synthesize estimatedDownloadTimeLabel;
@synthesize bookUpdates;
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
    [bookUpdates release], bookUpdates = nil;
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.bookUpdates managedObjectIDsForAvailableBookUpdates] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *const CellIdentifier = @"UpdateBooksCell";

    id<NSFetchedResultsSectionInfo> updates = [self.bookUpdates managedObjectIDsForAvailableBookUpdates];
    NSManagedObjectID *bookObjectID = [[updates objects] objectAtIndex:indexPath.row];
    SCHUpdateBooksTableViewCellController *tvc = [self.cellControllers objectForKey:bookObjectID];
    if (!tvc) {
        tvc = [[[SCHUpdateBooksTableViewCellController alloc] initWithBookObjectID:bookObjectID
                                                            inManagedObjectContext:self.bookUpdates.managedObjectContext] autorelease];
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

#pragma mark - Actions 

- (void)updateBooks:(id)sender
{
    [[self.cellControllers allValues] makeObjectsPerformSelector:@selector(startUpdateIfEnabled)];
}

#pragma mark - Notifications

- (void)bookUpdatedSuccessfully:(NSNotification *)note
{
    [self.bookUpdates refresh];
    
    // automatically dismiss this view once all books are updated
    if (![self.bookUpdates areBookUpdatesAvailable]) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.booksTable reloadData];
    }
}

@end
