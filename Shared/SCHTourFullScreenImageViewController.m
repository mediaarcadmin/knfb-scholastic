//
//  SCHTourFullScreenImageViewController.m
//  Scholastic
//
//  Created by Gordon Christie on 19/09/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHTourFullScreenImageViewController.h"

@interface SCHTourFullScreenImageViewController ()

@end

@implementation SCHTourFullScreenImageViewController
@synthesize mainImageView;
@synthesize closeButton;
@synthesize titleLabel;

@synthesize imageName;
@synthesize imageTitle;

- (void)releaseViewObjects
{
    [closeButton release], closeButton = nil;
    [mainImageView release], mainImageView = nil;
    [titleLabel release], titleLabel = nil;
}

- (void)dealloc {
    [self releaseViewObjects];
    [imageName release], imageName = nil;
    [imageTitle release], imageTitle = nil;
    [super dealloc];
}

- (void)viewDidUnload
{
    [self releaseViewObjects];
    [super viewDidUnload];
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
    
    self.mainImageView.image = [UIImage imageNamed:self.imageName];
    self.titleLabel.text = self.imageTitle;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (IBAction)closeView:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

@end
