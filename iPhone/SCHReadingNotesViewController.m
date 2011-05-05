//
//  SCHReadingNotesViewController.m
//  Scholastic
//
//  Created by Gordon Christie on 03/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHReadingNotesViewController.h"
#import "SCHCustomToolbar.h"


static NSInteger const CELL_TITLE_LABEL_TAG = 997;
static NSInteger const CELL_PAGE_LABEL_TAG = 998;
static NSInteger const CELL_ACTIVITY_INDICATOR_TAG = 999;

#pragma mark - Class Extension

@interface SCHReadingNotesViewController ()

@property (nonatomic, retain) UINib *noteCellNib;

-(void)releaseViewObjects;
-(void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation;

@end

#pragma mark - SCHReadingNotesViewController

@implementation SCHReadingNotesViewController

@synthesize noteCellNib;
@synthesize notesTableView;
@synthesize notesCell;
@synthesize topBar;

#pragma mark Object Synthesis

@synthesize isbn;

#pragma mark - Dealloc and View Teardown

-(void)dealloc {
    [self releaseViewObjects];
    
    [isbn release], isbn = nil;
    [noteCellNib release], noteCellNib = nil;
    [notesCell release], notesCell = nil;
    
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
    
    [self.topBar setTintColor:[UIColor colorWithRed:0.490 green:0.773 blue:0.945 alpha:1.0]];
    [self setupAssetsForOrientation:self.interfaceOrientation];
    
    // because we're iOS 4 and above, use UINib to cache access to the NIB
    self.noteCellNib = [UINib nibWithNibName:@"SCHReadingNotesTableCell" bundle:nil];
}


#pragma mark - Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self setupAssetsForOrientation:toInterfaceOrientation];
    
}

-(void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation
{    
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        [self.topBar setBackgroundImage:[UIImage imageNamed:@"reading-view-portrait-top-bar.png"]];
    } else {
        [self.topBar setBackgroundImage:[UIImage imageNamed:@"reading-view-landscape-top-bar.png"]];
    }    
}


#pragma mark - Actions

- (IBAction)cancelButtonAction:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 5;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"SCHReadingNotesTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
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
    
    titleLabel.text = [NSString stringWithFormat:@"Note %d", [indexPath row] + 1];
    
    // FIXME: for demo purposes, even lines will be loading, odd will not
    if (activityView) {
        if ([indexPath row] % 2 == 0) {
            [activityView startAnimating];
            cell.accessoryType = UITableViewCellAccessoryNone;
            subTitleLabel.text = @"";
        } else {
            [activityView stopAnimating];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            subTitleLabel.text = [NSString stringWithFormat:@"Page %d", [indexPath row] + 1];
        }
    }
    
    return cell;
}

@end
