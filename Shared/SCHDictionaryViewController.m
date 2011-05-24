//
//  SCHDictionaryViewController.m
//  Scholastic
//
//  Created by Gordon Christie on 24/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHDictionaryViewController.h"
#import "SCHDictionaryManager.h"

@interface SCHDictionaryViewController ()

- (void)releaseViewObjects;

@end

@implementation SCHDictionaryViewController

@synthesize categoryMode;
@synthesize word;
@synthesize webView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)releaseViewObjects
{
    [webView release], webView = nil;
}

- (void)dealloc
{
    [self releaseViewObjects];
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
    
    SCHDictionaryManager *dictionaryManager = [SCHDictionaryManager sharedDictionaryManager];
    
    NSString *htmlString = [dictionaryManager HTMLForWord:self.word category:self.categoryMode];
    
    [self.webView loadHTMLString:htmlString baseURL:nil];
}

- (void)viewDidUnload
{
    [self releaseViewObjects];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
