//
//  SCHBookShelfTopTenPopoverTableView.m
//  Scholastic
//
//  Created by Gordon Christie on 03/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBookShelfTopTenPopoverTableView.h"

@implementation SCHBookShelfTopTenPopoverTableView

@synthesize topTenTableView;
@synthesize books;

- (void)dealloc 
{
    [topTenTableView release], topTenTableView = nil;
    [books release], books = nil;
    
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.topTenTableView setSeparatorColor:[UIColor SCHGrayColor]];
    self.topTenTableView.allowsSelection = NO;
    self.topTenTableView.scrollEnabled = NO;    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITableView delegate and data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.books == nil || [self.books count] == 0) {
        return(1);
    } else {
        return([self.books count]);
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"topTenTableCell"];
    
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"topTenTableCell"] autorelease]; 
        cell.textLabel.textColor = [UIColor SCHDarkBlue1Color];        
        cell.textLabel.font = [cell.textLabel.font fontWithSize:16];
    }
    
    if (self.books == nil) {
        cell.textLabel.text = NSLocalizedString(@"Fetching the Top 10 Picks ...", @"");
    } else if ([self.books count] == 0) {
        cell.textLabel.text = NSLocalizedString(@"Top 10 Picks currently not available", @"");
    } else {
        cell.textLabel.text = [[books objectAtIndex:indexPath.row] valueForKey:@"Title"];
    }
            
    return(cell);
}

- (CGSize)contentSizeForViewInPopover
{
    CGFloat height = (10 * 44);
    return CGSizeMake(320, height);
}

#pragma mark - Accessors

- (void)setBooks:(NSArray *)newBooks
{
    if (books != newBooks) {
        [books release];
        books = [newBooks retain];

        [self.topTenTableView reloadData];
    }
}

@end
