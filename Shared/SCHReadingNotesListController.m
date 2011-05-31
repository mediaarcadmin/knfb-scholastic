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
#import "SCHReadingView.h"

static NSInteger const CELL_TITLE_LABEL_TAG = 997;
static NSInteger const CELL_PAGE_LABEL_TAG = 998;
static NSInteger const CELL_ACTIVITY_INDICATOR_TAG = 999;

#pragma mark - Class Extension

@interface SCHReadingNotesListController ()

@property (nonatomic, retain) UINib *noteCellNib;
@property (nonatomic, retain) NSArray *notes;

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
@synthesize isbn;
@synthesize notes;
@synthesize profile;
@synthesize readingView;

#pragma mark - Dealloc and View Teardown

-(void)dealloc {
    [self releaseViewObjects];
    
    delegate = nil;
    
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
    UIBarButtonItem *newBBI = nil;
    int width = 14;
    
    [self.notesTableView beginUpdates];
    if ([self.notesTableView isEditing]) {
        newBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editNotesButtonAction:)];
        [self.notesTableView setEditing:NO animated:NO];
        [self.notesTableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationTop];
        width = 14;
    } else {
        newBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editNotesButtonAction:)];
        [self.notesTableView setEditing:YES animated:NO];
        [self.notesTableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
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
    [self.notesTableView endUpdates];

}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([tableView isEditing]) {
        return 1;
    } else {
        return 2;
    }
}

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
    if ([tableView isEditing]) {
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
            activityView.alpha = 0;
            UILabel *titleLabel = (UILabel *) [cell viewWithTag:CELL_TITLE_LABEL_TAG];
            UILabel *subTitleLabel = (UILabel *) [cell viewWithTag:CELL_PAGE_LABEL_TAG];
            
            SCHNote *note = [self.notes objectAtIndex:[indexPath row]];
            if (note && note.Value && [note.Value length] > 0) {
                titleLabel.text = note.Value;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                
                //NSUInteger layoutPage = note.noteLayoutPage;
                //NSUInteger pageWordIndex = note.notePageWordIndex;
                SCHBookPoint *notePoint = nil;
                //SCHBookPoint *notePoint = [self.readingView bookPointForLayoutPage:layoutPage pageWordIndex:pageWordIndex];
                int pageIndex = [self.readingView pageIndexForBookPoint:notePoint];
                
                // MATT DO THIS
//                subTitleLabel.text = [NSString stringWithFormat:@"Page %@", [self.readingView displayPageNumberForPageAtIndex:pageIndex]];
                
                subTitleLabel.text = [self.readingView pageLabelForPageAtIndex:pageIndex];
            } else {
                titleLabel.text = @"Empty note";
            }
            
            // FIXME: for demo purposes, even lines will be loading, odd will not
//            if (activityView) {
//                if ([indexPath row] % 2 == 0) {
//                    [activityView startAnimating];
//                    cell.accessoryType = UITableViewCellAccessoryNone;
//                    subTitleLabel.text = @"";
//                } else {
//                    [activityView stopAnimating];
//                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//                    subTitleLabel.text = [NSString stringWithFormat:@"Page %d", [indexPath row] + 1];
//                }
//            }
            
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
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"Deleting row %d!", indexPath.row);
        
        NSInteger section = [indexPath section];
        
        switch (section) {
            case 0:
            {
                NSLog(@"section 0.");
                break;
            }
            case 1:
            {
                if (self.delegate && [delegate respondsToSelector:@selector(readingNotesView:didDeleteNote:)]) {
                    [delegate readingNotesView:self didDeleteNote:[self.notes objectAtIndex:[indexPath row]]];
                }
                [self.notesTableView beginUpdates];
                [self.notesTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                SCHBookAnnotations *annotations = [self.profile annotationsForBook:self.isbn];
                self.notes = [annotations notes];
                
                if ([self.notes count] == 0) {
                    [self.notesTableView deleteSections:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    [self editNotesButtonAction:nil];
                }
                [self.notesTableView endUpdates];
                
                break;
            }
            default:
            {
                NSLog(@"Unknown row selection in SCHReadingNotesListController (%d)", section);
                break;
            }
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
