//
//  SCHTourStartViewController.m
//  Scholastic
//
//  Created by Gordon Christie on 17/09/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHTourStartViewController.h"
#import "SCHTourStepsViewController.h"
#import "SCHBookIdentifier.h"
#import "NSNumber+ObjectTypes.h"

#define OLDER_READING_TAG 100
#define YOUNGER_READING_TAG 200

@interface SCHTourStartViewController ()

@end

@implementation SCHTourStartViewController

@synthesize appController;

- (void)dealloc
{
    [self releaseViewObjects];
    
    appController = nil;
    [super dealloc];
}

- (void)releaseViewObjects
{
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.navigationController setNavigationBarHidden:YES];
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
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationIsLandscape(interfaceOrientation);
    } else {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
}

#pragma mark - Actions

- (IBAction)backToSignInScreen:(id)sender {
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)startReading:(UIButton *)sender {
    
    SCHBookIdentifier *identifier = nil;
    
    switch ([sender tag]) {
        case YOUNGER_READING_TAG:
        {
            NSLog(@"Start reading younger book");
            identifier = [[[SCHBookIdentifier alloc] initWithISBN:@"9780545323024" DRMQualifier:[NSNumber numberWithDRMQualifier:kSCHDRMQualifiersNone]] autorelease];
            break;
        }
        case OLDER_READING_TAG:
        {
            NSLog(@"Start reading older book");
            identifier = [[[SCHBookIdentifier alloc] initWithISBN:@"9780545283502" DRMQualifier:[NSNumber numberWithDRMQualifier:kSCHDRMQualifiersNone]] autorelease];
            break;
        }
            default:
        {
            NSLog(@"Warning: unknown reading button action.");
            break;
        }
    }
    
    if (identifier) {
        [self.appController presentTourBookWithIdentifier:identifier];
    }
}

- (IBAction)takeTheTour:(id)sender {
    NSLog(@"Take the tour!");
    SCHTourStepsViewController *stepsController = [[SCHTourStepsViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:stepsController animated:YES];
    [stepsController release];
}


@end
