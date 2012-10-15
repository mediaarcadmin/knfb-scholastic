//
//  SCHUpdateBooksViewController.m
//  Scholastic
//
//  Created by Neil Gall on 25/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHUpdateBooksViewController.h"
#import "SCHUpdateBooksTableViewCellController.h"
#import "SCHUpdateBooksTableViewCell.h"
#import "SCHAppBook.h"
#import "SCHBookIdentifier.h"
#import "SCHBookUpdates.h"
#import "UIColor+Scholastic.h"

@interface SCHUpdateBooksViewController ()

@property (nonatomic, retain) NSMutableDictionary *cellControllers;
@property (nonatomic, retain) NSArray *availableBookUpdates;

@end

@implementation SCHUpdateBooksViewController

@synthesize booksTable;
@synthesize updateBooksButton;
@synthesize bookUpdates;
@synthesize noteUpdateNoticeLabel;
@synthesize cellControllers;
@synthesize availableBookUpdates;
@synthesize appController;
@synthesize containerView;
@synthesize shadowView;
@synthesize backButton;

- (void)releaseViewObjects
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [containerView release], containerView = nil;
    [shadowView release], shadowView = nil;
    [noteUpdateNoticeLabel release], noteUpdateNoticeLabel = nil;
    [booksTable release], booksTable = nil;
    [backButton release], backButton = nil;
    [updateBooksButton release], updateBooksButton = nil;
}

- (void)dealloc
{
    appController = nil;
    [bookUpdates release], bookUpdates = nil;
    [cellControllers release], cellControllers = nil;
    [self releaseViewObjects];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.booksTable.layer.cornerRadius = 10;
    self.booksTable.layer.borderWidth = 2;
    self.booksTable.layer.borderColor = [[UIColor SCHGrayColor] CGColor];
    self.booksTable.backgroundColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(bookUpdatedSuccessfully:)
                                                 name:kSCHBookUpdatedSuccessfullyNotification
                                               object:nil];
    
#if IPHONE_HIGHLIGHTS_DISABLED
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
//            self.noteUpdateNoticeLabel.text = NSLocalizedString(@"Your notes for these books will be lost.", @"");
        }
#endif
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
    
        UIImage *backButtonImage = [[UIImage imageNamed:@"bookshelf_arrow_bttn_UNselected_3part"] stretchableImageWithLeftCapWidth:11 topCapHeight:0];
        [self.backButton setBackgroundImage:backButtonImage forState:UIControlStateNormal];
        [self.backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
        
        self.shadowView.layer.shadowOpacity = 0.5f;
        self.shadowView.layer.shadowOffset = CGSizeMake(0, 0);
        self.shadowView.layer.shadowRadius = 4.0f;
        self.shadowView.layer.backgroundColor = [UIColor clearColor].CGColor;
        self.containerView.layer.masksToBounds = YES;
        self.containerView.layer.cornerRadius = 10.0f;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self releaseViewObjects];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.cellControllers = [NSMutableDictionary dictionary];
    self.availableBookUpdates = [self.bookUpdates availableBookUpdates];
    
    UIImage *stretchedButtonImage = [[UIImage imageNamed:@"lg_bttn_gray_UNselected_3part"] stretchableImageWithLeftCapWidth:7 topCapHeight:0];
    [self.updateBooksButton setBackgroundImage:stretchedButtonImage forState:UIControlStateNormal];

    for (SCHAppBook *book in self.availableBookUpdates) {
        SCHBookIdentifier *bookIdentifier = [book bookIdentifier];
        SCHUpdateBooksTableViewCellController *tvc = [[SCHUpdateBooksTableViewCellController alloc] initWithBookIdentifier:bookIdentifier
                                                                                                    inManagedObjectContext:self.bookUpdates.managedObjectContext];
        [self.cellControllers setObject:tvc forKey:bookIdentifier];
        [tvc release];
    }
    
    [self.booksTable reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.availableBookUpdates count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *const CellIdentifier = @"UpdateBooksCell";

    SCHAppBook *book = [self.availableBookUpdates objectAtIndex:indexPath.row];
    SCHBookIdentifier *bookIdentifier = [book bookIdentifier];
    SCHUpdateBooksTableViewCellController *tvc = [self.cellControllers objectForKey:bookIdentifier];
    
    tvc.cell = (SCHUpdateBooksTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!tvc.cell) {
        [[NSBundle mainBundle] loadNibNamed:@"SCHUpdateBooksTableViewCell" owner:tvc options:nil];
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
    [[self.cellControllers allValues] makeObjectsPerformSelector:@selector(startUpdate)];
}

#pragma mark - Notifications

- (void)bookUpdatedSuccessfully:(NSNotification *)note
{
    [self.bookUpdates refresh];
    
    // automatically dismiss this view once all books are updated
    if (![self.bookUpdates areBookUpdatesAvailable]) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        self.availableBookUpdates = [self.bookUpdates availableBookUpdates];
        [self.booksTable reloadData];
    }
}

- (void)back:(id)sender
{
    [self.appController presentSettings];
}

//- (void)checkButtonState
//{
//    NSInteger enabledCount = 0;
//    for (SCHUpdateBooksTableViewCellController *c in [self.cellControllers allValues]) {
//        enabledCount++;
//    }
//    self.updateBooksButton.enabled = (enabledCount > 0);
//}

@end
