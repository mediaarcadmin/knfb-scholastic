//
//  SCHReadingNotesListController.m
//  Scholastic
//
//  Created by Gordon Christie on 03/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHReadingNotesListController.h"
#import "SCHCustomToolbar.h"
#import "SCHBookAnnotations.h"
#import "SCHProfileItem.h"
#import "SCHNote.h"

static NSInteger const CELL_TITLE_LABEL_TAG = 997;
static NSInteger const CELL_PAGE_LABEL_TAG = 998;
static NSInteger const CELL_ACTIVITY_INDICATOR_TAG = 999;

#pragma mark - Class Extension

@interface SCHReadingNotesListController ()

@property (nonatomic, retain) UINib *noteCellNib;
@property (nonatomic, retain) NSArray *notes;

@property (nonatomic) BOOL editMode;

- (void)releaseViewObjects;
- (void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation;
- (void)setToolbarModeEditing:(BOOL)editing;
- (void)toggleToolbarEditMode;

@end

#pragma mark - SCHReadingNotesListController

@implementation SCHReadingNotesListController

@synthesize delegate;
@synthesize noteCellNib;
@synthesize notesTableView;
@synthesize notesCell;
@synthesize topShadow;
@synthesize topBar;
@synthesize isbn;
@synthesize notes;
@synthesize profile;
@synthesize editMode;

#pragma mark - Dealloc and View Teardown

-(void)dealloc {
    [self releaseViewObjects];
    
    delegate = nil;
    
    [isbn release], isbn = nil;
    [noteCellNib release], noteCellNib = nil;
    [notesCell release], notesCell = nil;
    [profile release], profile = nil;
    [notes release], notes = nil;
    
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
        self.editMode = NO;
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

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self setupAssetsForOrientation:toInterfaceOrientation];
    
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

- (IBAction)editNotesButtonAction:(UIBarButtonItem *)sender
{
    [self toggleToolbarEditMode];
}

- (void) toggleToolbarEditMode
{
    [self setToolbarModeEditing:!self.editMode];
}

- (void) setToolbarModeEditing: (BOOL) editing
{
    UIBarButtonItem *newBBI = nil;
    int width = 14;
    
    if (!editing) {
        newBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editNotesButtonAction:)];

        if (self.editMode) {
            [self.notesTableView setEditing:NO animated:NO];
            [self.notesTableView beginUpdates];
            self.editMode = NO;
            [self.notesTableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationTop];
            [self.notesTableView endUpdates];
        }
        
        width = 14;
    } else {
        newBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editNotesButtonAction:)];
        if (!self.editMode) {
            [self.notesTableView setEditing:YES animated:NO];
            [self.notesTableView beginUpdates];
            self.editMode = YES;
            [self.notesTableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
            [self.notesTableView endUpdates];
        }
        width = 7;
    }
    
    if (newBBI) {
        NSMutableArray *currentItems = [NSMutableArray arrayWithArray:self.topBar.items];
        [currentItems replaceObjectAtIndex:0 withObject:newBBI];
        [newBBI release];
        
        // adjust the width of the fixed space to keep the title centred
        UIBarButtonItem *fixedSpace = (UIBarButtonItem *) [currentItems objectAtIndex:1];
        fixedSpace.width = width;
        
        self.topBar.items = [NSArray arrayWithArray:currentItems];
    }
 
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.editMode) {
        return 1;
    } else {
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // if we're editing, omit the first section
    if (self.editMode) {
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
            if (self.notes) {
                return [self.notes count];
            } else {
                return 0;
            }
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
    if (self.editMode) {
        section++;
    }
    
    switch (section) {
        case 0:
        {   
            NSString *cellIdentifier = @"SCHReadingNotesAddNoteCell";
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
            }
            
            cell.textLabel.font = [UIFont boldSystemFontOfSize:17.0f];
            cell.textLabel.text = NSLocalizedString(@"Add a Note", @"Add a Note");
            cell.imageView.image = [UIImage imageNamed:@"ABAddCircle"];
            
            break;
        }
        case 1:
        {
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
            
            SCHNote *note = [self.notes objectAtIndex:[indexPath row]];
            titleLabel.text = note.Value;
            
            SCHBookPoint *notePoint = [self.delegate bookPointForNote:note];
            
            if (notePoint) {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;  
                NSString *displayPage = [self.delegate displayPageNumberForBookPoint:notePoint];
                subTitleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Page %@", @"Display page for Notes List Controller"), displayPage];
                subTitleLabel.alpha = 1;
                activityView.alpha = 0;
            } else {
                subTitleLabel.alpha = 0;
                activityView.alpha = 1;
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
            if (self.delegate && [delegate respondsToSelector:@selector(readingNotesViewCreatingNewNote:)]) {
                [delegate readingNotesViewCreatingNewNote:self];
            }
            break;
        }
        case 1:
        {
            if (self.delegate && [delegate respondsToSelector:@selector(readingNotesView:didSelectNote:)]) {
                [delegate readingNotesView:self didSelectNote:[self.notes objectAtIndex:[indexPath row]]];
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    BOOL shouldCancelEditing = NO;

    // FIXME: The code below crashes so its just returning for now
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"Deleting %d, row %d!", indexPath.section, indexPath.row);
        
        
        if (self.delegate && [delegate respondsToSelector:@selector(readingNotesView:didDeleteNote:)]) {
            [delegate readingNotesView:self didDeleteNote:[self.notes objectAtIndex:[indexPath row]]];
        }
        
        [self.notesTableView beginUpdates];

        SCHBookAnnotations *annotations = [self.profile annotationsForBook:self.isbn];
        self.notes = [annotations notes];
        
        [self.notesTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        // cover the case where you swipe and remove the last row
        if ([self.notes count] == 0) {
            shouldCancelEditing = YES;
        }
        
        [self.notesTableView endUpdates];
        
        if (shouldCancelEditing) {
            [self setToolbarModeEditing:NO];
        }
            
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![tableView isEditing] && [indexPath section] == 0) {
        return NO;
    } else {
        return YES;
    }
}

@end
