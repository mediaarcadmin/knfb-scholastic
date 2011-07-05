//
//  SCHReadingInteractionsListController.m
//  Scholastic
//
//  Created by Gordon Christie on 24/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHReadingInteractionsListController.h"

#import "SCHCustomToolbar.h"
#import "SCHBookAnnotations.h"
#import "SCHProfileItem.h"
#import "SCHNote.h"
#import "SCHReadingView.h"
#import "SCHBookStoryInteractions.h"
#import "SCHStoryInteraction.h"

static NSInteger const CELL_TITLE_LABEL_TAG = 997;
static NSInteger const CELL_PAGE_LABEL_TAG = 998;
static NSInteger const CELL_ACTIVITY_INDICATOR_TAG = 999;

#pragma mark - Class Extension

@interface SCHReadingInteractionsListController ()

@property (nonatomic, retain) UINib *noteCellNib;
@property (nonatomic, retain) NSArray *notes;

-(void)releaseViewObjects;
-(void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation;

@end

#pragma mark - SCHReadingInteractionsListController

@implementation SCHReadingInteractionsListController

@synthesize bookStoryInteractions;
@synthesize excludeInteractionWithPage;
@synthesize delegate;
@synthesize noteCellNib;
@synthesize notesTableView;
@synthesize notesCell;
@synthesize topShadow;
@synthesize topBar;
@synthesize isbn;
@synthesize notes;
@synthesize profile;
@synthesize readingView;

#pragma mark - Dealloc and View Teardown

-(void)dealloc {
    [self releaseViewObjects];
    
    delegate = nil;
    
    [bookStoryInteractions release], bookStoryInteractions = nil;
    [isbn release], isbn = nil;
    [noteCellNib release], noteCellNib = nil;
    [notesCell release], notesCell = nil;
    [profile release], profile = nil;
    [notes release], notes = nil;
    readingView = nil;
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)releaseViewObjects
{
    [notesTableView release], notesTableView = nil;
    [topBar release], topBar = nil;
    [topShadow release], topShadow = nil;
}

-(void)viewDidUnload {
    [super viewDidUnload];
    [self releaseViewObjects];
}

#pragma mark - Object Initialiser

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
    }
    
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.topBar setTintColor:[UIColor colorWithWhite:0.7f alpha:1.0f]];
    [self setupAssetsForOrientation:self.interfaceOrientation];
    
    // because we're using iOS 4 and above, use UINib to cache access to the NIB
    self.noteCellNib = [UINib nibWithNibName:@"SCHReadingPageListTableCell" bundle:nil];
    
    [self.topShadow setImage:[UIImage imageNamed:@"reading-view-top-shadow.png"]];
    
    SCHBookAnnotations *annotations = [self.profile annotationsForBook:self.isbn];
    self.notes = [annotations notes];
}


#pragma mark - Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self setupAssetsForOrientation:toInterfaceOrientation];
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.notesTableView reloadData];
}

-(void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation
{    
    if (UIInterfaceOrientationIsPortrait(orientation) || UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.topBar setBackgroundImage:[UIImage imageNamed:@"reading-view-portrait-top-bar.png"]];
        
        CGRect barFrame = self.topBar.frame;
        if (barFrame.size.height == 34) {
            barFrame.size.height = 44;
            self.topBar.frame = barFrame;
            
            CGRect tableFrame = self.notesTableView.frame;
            tableFrame.size.height -= 10;
            tableFrame.origin.y += 10;
            self.notesTableView.frame = tableFrame;
        }
    } else {
        [self.topBar setBackgroundImage:[UIImage imageNamed:@"reading-view-landscape-top-bar.png"]];
        
        CGRect barFrame = self.topBar.frame;
        if (barFrame.size.height == 44) {
            barFrame.size.height = 34;
            self.topBar.frame = barFrame;
            
            CGRect tableFrame = self.notesTableView.frame;
            tableFrame.size.height += 10;
            tableFrame.origin.y -= 10;
            self.notesTableView.frame = tableFrame;
        }
    }    
    
    CGRect topShadowFrame = self.topShadow.frame;
    topShadowFrame.origin.y = CGRectGetMinY(self.notesTableView.frame);
    self.topShadow.frame = topShadowFrame;
    
}


#pragma mark - Actions

- (IBAction)cancelButtonAction:(UIBarButtonItem *)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
        {
            return [[bookStoryInteractions allStoryInteractionsExcludingInteractionWithPage:self.excludeInteractionWithPage] count];
            break;
        }   
        default:
            return 0;
            break;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    NSString *cellIdentifier = @"SCHReadingPageListTableCell";
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        
        if (self.noteCellNib) {
            [self.noteCellNib instantiateWithOwner:self options:nil];
        }
        
        // when the nib loads, it places an instantiated version of the cell in self.notesCell
        cell = self.notesCell;
        
        // tidy up after ourselves
        self.notesCell = nil;
    }
    
    // use tags to grab the labels and the activity view
    UIActivityIndicatorView *activityView = (UIActivityIndicatorView *) [cell viewWithTag:CELL_ACTIVITY_INDICATOR_TAG];
    UILabel *titleLabel = (UILabel *) [cell viewWithTag:CELL_TITLE_LABEL_TAG];
    UILabel *subTitleLabel = (UILabel *) [cell viewWithTag:CELL_PAGE_LABEL_TAG];
    
    SCHStoryInteraction *storyInteraction = [[self.bookStoryInteractions allStoryInteractionsExcludingInteractionWithPage:self.excludeInteractionWithPage] objectAtIndex:indexPath.row];
    titleLabel.text = [storyInteraction title];
    
    SCHBookPoint *interactionPoint = [self.delegate bookPointForStoryInteractionDocumentPageNumber:storyInteraction.documentPageNumber];
    
    if (interactionPoint) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;  
        NSString *displayPage = [self.delegate displayPageNumberForBookPoint:interactionPoint];
        subTitleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Page %@", @"Display page for Story Interaction List Controller"), displayPage];
        subTitleLabel.alpha = 1;
        activityView.alpha = 0;
    } else {
        subTitleLabel.alpha = 0;
        activityView.alpha = 1;
    }    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self dismissModalViewControllerAnimated:YES];
    // table is set to disallow selection while editing
    switch ([indexPath section]) {
        case 0:
        {
            if (self.delegate && [delegate respondsToSelector:@selector(readingInteractionsView:didSelectInteraction:)]) {
                [delegate readingInteractionsView:self didSelectInteraction:[indexPath row]];
            }
            break;
        }
        default:
        {
            NSLog(@"Unknown row selection in SCHReadingInteractionsListController (%d)", [indexPath section]);
            break;
        }
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

@end
