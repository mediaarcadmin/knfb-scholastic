//
//  SCHBookShelfSortPopoverTableView.m
//  Scholastic
//
//  Created by Gordon Christie on 03/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBookShelfSortPopoverTableView.h"


@implementation SCHBookShelfSortPopoverTableView

@synthesize delegate;
@synthesize itemsTableView;
@synthesize sortType;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [itemsTableView release];
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

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // FIXME: temporarily disabling table view for top ten view. needs its own controller.
    if ([self.title compare:@"Top Ten Books"] == NSOrderedSame) {
        return 0;
    }
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sortTableCell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"sortTableCell"];        
    }
    
    NSArray *sortTypeArray = [NSArray arrayWithObjects:@"Manual", @"My Favorites", @"Title", @"Author", @"Newest", @"Last Read", nil];
    
    cell.textLabel.text = [sortTypeArray objectAtIndex:[indexPath row]];
    
    if ([indexPath row] == self.sortType) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
//    //    if (([indexPath row] == 1) || [indexPath row] == 4 || [indexPath row] == 5) {
//    if (([indexPath row] == 1)) {
//        cell.textLabel.textColor = [UIColor darkGrayColor];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    } else {
        cell.textLabel.textColor = [UIColor blackColor];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
//    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SCHBookSortType newSortType = -1;
    
    BOOL enabled = YES;
    
    switch ([indexPath row]) {
        case 0:
            newSortType = kSCHBookSortTypeUser;
            break;
        case 1:
            newSortType = kSCHBookSortTypeFavorites;
//            enabled = NO;
            break;
        case 2:
            newSortType = kSCHBookSortTypeTitle;
            break;
        case 3:
            newSortType = kSCHBookSortTypeAuthor;
            break;
        case 4:
           newSortType = kSCHBookSortTypeNewest;
 //           enabled = NO;
            break;
        case 5:
            newSortType = kSCHBookSortTypeLastRead;
//            enabled = NO;
            break;
        default:
            break;
    }
    
    if (enabled && self.delegate && [self.delegate respondsToSelector:@selector(sortPopoverPickedSortType:)]) {
        [self.delegate sortPopoverPickedSortType:newSortType];
    }
}

- (CGSize) contentSizeForViewInPopover
{
    CGFloat height = (10 * 44) + 44 + 10;
    return CGSizeMake(320, height);
}



@end
