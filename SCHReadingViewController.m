//
//  SCHReadingViewController.m
//  Scholastic
//
//  Created by Matt Farrugia on 23/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHReadingViewController.h"
#import "SCHLayoutView.h"

@interface SCHReadingViewController()

@property (nonatomic, retain) id book;

@end

@implementation SCHReadingViewController

@synthesize book;

- (void)dealloc
{
    [book release], book = nil;
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil book:(id)aBook
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        book = [aBook retain];
    }
    return self;
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
    
    SCHLayoutView *aBookView = [[SCHLayoutView alloc] initWithFrame:self.view.bounds book:self.book];
    [self.view addSubview:aBookView];
    [aBookView release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
