//
//  SCHBookShelfSortTableView.m
//  Scholastic
//
//  Created by Gordon Christie on 03/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBookShelfSortTableView.h"


@interface SCHBookShelfSortTableView ()

@property (nonatomic, retain) NSArray *sortTypeArray;

@end 

@implementation SCHBookShelfSortTableView

@synthesize delegate;
@synthesize itemsTableView;
@synthesize sortType;
@synthesize sortTypeArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        sortTypeArray = [[NSArray arrayWithObjects:@"Title", @"Author", @"Newest", @"Last Read", nil] retain];
    }
    return self;
}

- (void)dealloc
{
    [itemsTableView release];
    [sortTypeArray release], sortTypeArray = nil;
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.itemsTableView.scrollEnabled = NO;
    self.title = @"Sort";

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)] autorelease];

        self.itemsTableView.backgroundColor = [UIColor clearColor];
        self.view.backgroundColor = [UIColor clearColor];
    }
}

- (void)viewDidUnload
{
    [self setItemsTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)cancel
{
    [self.delegate sortPopoverCancelled:self];
}

#pragma mark - UITableView delegate and data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return([sortTypeArray count]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sortTableCell"];
    
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"sortTableCell"] autorelease];        
    }
    
    cell.textLabel.text = [self.sortTypeArray objectAtIndex:[indexPath row]];
    
    if ([indexPath row] == self.sortType) {
        cell.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"popoverTick"]] autorelease];
    } else {
        cell.accessoryView = nil;
    }
        
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SCHBookSortType newSortType = -1;
    
    switch ([indexPath row]) {
        case 0:
            newSortType = kSCHBookSortTypeTitle;
            break;
        case 1:
            newSortType = kSCHBookSortTypeAuthor;
            break;
        case 2:
           newSortType = kSCHBookSortTypeNewest;
            break;
        case 3:
            newSortType = kSCHBookSortTypeLastRead;
            break;
        default:
            break;
    }
    
    [self.delegate sortPopover:self pickedSortType:newSortType];
}

#pragma mark - Popover Size

- (CGSize)contentSizeForViewInPopover
{
    CGFloat height = ([sortTypeArray count] * 44) + 20;
    return CGSizeMake(240, height);
}



@end
