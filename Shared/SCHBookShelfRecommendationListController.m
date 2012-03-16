//
//  SCHBookShelfRecommendationListController.m
//  Scholastic
//
//  Created by Gordon Christie on 15/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHBookShelfRecommendationListController.h"
#import "SCHRecommendationListView.h"

@interface SCHBookShelfRecommendationListController ()

- (void)releaseViewObjects;

@end

@implementation SCHBookShelfRecommendationListController

@synthesize delegate;
@synthesize appProfile;
@synthesize mainTableView;
@synthesize closeBlock;

#pragma mark - Memory Management

- (void)dealloc
{
    // release any non-view objects
    delegate = nil;
    [appProfile release], appProfile = nil;
    [closeBlock release], closeBlock = nil;
    
    // release view objects
    [self releaseViewObjects];
    [super dealloc];
}

- (void)releaseViewObjects
{
    // release any view objects here
    [mainTableView release], mainTableView = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(close:)] autorelease];
        self.title = @"Kids' Top Rated eBooks";
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    // release view objects
    [self releaseViewObjects];
    [super viewDidUnload];
}

#pragma mark - View Actions

- (IBAction)close:(id)sender
{
    if (closeBlock) {
        closeBlock();
    }
}

- (IBAction)switchToWishList:(id)sender
{
    if (self.delegate) {
        [self.delegate switchToWishListFromRecommendationListController:self];
    }
}

#pragma mark - View Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSLog(@"Number of rows.");
    NSArray *recommendations = [self.appProfile recommendations];
    
    if (recommendations && recommendations.count > 0) {
        return recommendations.count;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RecommendationListController";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];

        SCHRecommendationListView *recommendationView = [[SCHRecommendationListView alloc] initWithFrame:cell.frame];
        recommendationView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        recommendationView.tag = 999;
        
        [cell addSubview:recommendationView];
        [recommendationView release];
    }
    
    NSArray *recommendations = [self.appProfile recommendations];
    
    if (recommendations && recommendations.count > 0) {
        SCHRecommendationListView *recommendationView = (SCHRecommendationListView *)[cell viewWithTag:999];
        
        if (recommendationView) {
            [recommendationView updateWithRecommendationItem:[recommendations objectAtIndex:indexPath.row]];
        }
    }
    
    return cell;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 132;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end
