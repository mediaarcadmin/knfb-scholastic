//
//  SCHBookShelfSortPopoverTableView.m
//  Scholastic
//
//  Created by Gordon Christie on 03/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBookShelfSortPopoverTableView.h"


@interface SCHBookShelfSortPopoverTableView ()

@property (nonatomic, retain) NSArray *sortTypeArray;

@end 

@implementation SCHBookShelfSortPopoverTableView

@synthesize delegate;
@synthesize itemsTableView;
@synthesize sortType;
@synthesize sortTypeArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        sortTypeArray = [[NSArray arrayWithObjects:@"Manual", @"Title", @"Author", @"Newest", @"Last Read", nil] retain];
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
    
    [self.itemsTableView setSeparatorColor:[UIColor colorWithRed:0.710 green:0.737 blue:0.816 alpha:1.0]];
    self.itemsTableView.scrollEnabled = NO;
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.textLabel.textColor = [UIColor blackColor];
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SCHBookSortType newSortType = -1;
    
    switch ([indexPath row]) {
        case 0:
            newSortType = kSCHBookSortTypeUser;
            break;
        case 1:
            newSortType = kSCHBookSortTypeTitle;
            break;
        case 2:
            newSortType = kSCHBookSortTypeAuthor;
            break;
        case 3:
           newSortType = kSCHBookSortTypeNewest;
            break;
        case 4:
            newSortType = kSCHBookSortTypeLastRead;
            break;
        default:
            break;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(sortPopoverPickedSortType:)]) {
        [self.delegate sortPopoverPickedSortType:newSortType];
    }
}

- (CGSize)contentSizeForViewInPopover
{
    CGFloat height = ([sortTypeArray count] * 44);
    return CGSizeMake(320, height);
}



@end
