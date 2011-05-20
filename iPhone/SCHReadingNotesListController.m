//
//  SCHReadingNotesListController.m
//  Scholastic
//
//  Created by Gordon Christie on 03/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHReadingNotesListController.h"
#import "SCHCustomToolbar.h"


static NSInteger const CELL_TITLE_LABEL_TAG = 997;
static NSInteger const CELL_PAGE_LABEL_TAG = 998;
static NSInteger const CELL_ACTIVITY_INDICATOR_TAG = 999;

#pragma mark - Class Extension

@interface SCHReadingNotesListController ()

@property (nonatomic, retain) UINib *noteCellNib;

-(void)releaseViewObjects;
-(void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation;

@end

#pragma mark - SCHReadingNotesListController

@implementation SCHReadingNotesListController

@synthesize delegate;
@synthesize noteCellNib;
@synthesize notesTableView;
@synthesize notesCell;
@synthesize topShadow;
@synthesize topBar;

#pragma mark Object Synthesis

@synthesize isbn;

#pragma mark - Dealloc and View Teardown

-(void)dealloc {
    [self releaseViewObjects];
    
    delegate = nil;
    
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
    
    [self.topBar setTintColor:[UIColor colorWithRed:0.490 green:0.773 blue:0.945 alpha:1.0]];
    [self setupAssetsForOrientation:self.interfaceOrientation];
    
    // because we're using iOS 4 and above, use UINib to cache access to the NIB
    self.noteCellNib = [UINib nibWithNibName:@"SCHReadingNotesListTableCell" bundle:nil];
    
    [self.topShadow setImage:[[UIImage imageNamed:@"reading-view-iphone-top-shadow.png"] stretchableImageWithLeftCapWidth:15.0f topCapHeight:0]];

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

- (IBAction)editNotesButtonAction:(UIBarButtonItem *)sender
{
    UIBarButtonItem *newBBI = nil;
    int width = 14;
    
    if ([self.notesTableView isEditing]) {
        newBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editNotesButtonAction:)];
        [self.notesTableView setEditing:NO animated:YES];
        width = 14;
    } else {
        newBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editNotesButtonAction:)];
        [self.notesTableView setEditing:YES animated:YES];
        width = 7;
    }
    
    if (newBBI) {
        NSMutableArray *currentItems = [NSMutableArray arrayWithArray:self.topBar.items];
        [currentItems replaceObjectAtIndex:0 withObject:newBBI];
        
        // adjust the width of the fixed space to keep the title centred
        UIBarButtonItem *fixedSpace = (UIBarButtonItem *) [currentItems objectAtIndex:1];
        fixedSpace.width = width;
        
        self.topBar.items = [NSArray arrayWithArray:currentItems];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // if we're editing, omit the first section
    if ([tableView isEditing]) {
        section++;
    }
    
    switch (section) {
        case 0:
        {
            return 1;
            break;
        }   
        case 1:
        {
            return 5;
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
    
    NSInteger section = [indexPath section];
    
    // if we're editing, omit the first section
    if ([tableView isEditing]) {
        section++;
    }
    
    switch (section) {
        case 0:
        {   
            NSString *cellIdentifier = @"SCHReadingNotesAddNoteCell";
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            
            cell.textLabel.text = NSLocalizedString(@"Add a Note", @"Add a Note");
            cell.imageView.image = [UIImage imageNamed:@"ABAddCircle"];
            
            break;
        }
        case 1:
        {
            NSString *cellIdentifier = @"SCHReadingNotesTableCell";
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
            
            break;
        }   
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // table is set to disallow selection while editing
    switch ([indexPath section]) {
        case 0:
        {
            if (self.delegate && [delegate respondsToSelector:@selector(readingNotesView:didSelectNote:)]) {
                [delegate readingNotesViewCreatingNewNote:self];
            }
            break;
        }
        case 1:
        {
            if (self.delegate && [delegate respondsToSelector:@selector(readingNotesView:didSelectNote:)]) {
                [delegate readingNotesView:self didSelectNote:@"FIXME: dummy note"];
            }
            break;
        }
        default:
        {
            NSLog(@"Unknown row selection in SCHReadingNotesListController (%d)", [indexPath section]);
            break;
        }
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

@end
