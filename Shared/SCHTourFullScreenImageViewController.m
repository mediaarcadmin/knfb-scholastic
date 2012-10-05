//
//  SCHTourFullScreenImageViewController.m
//  Scholastic
//
//  Created by Gordon Christie on 19/09/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHTourFullScreenImageViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface SCHTourFullScreenImageViewController ()

@end

@implementation SCHTourFullScreenImageViewController

@synthesize navBarImageView;
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
    [navBarImageView release], navBarImageView = nil;
    [_bottomView release];
    [super dealloc];
}

- (void)viewDidUnload
{
    [self releaseViewObjects];
    [self setNavBarImageView:nil];
    [self setBottomView:nil];
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
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.titleLabel.font = [UIFont boldSystemFontOfSize:11];
    }
    
    [self.closeButton setBackgroundImage:[[UIImage imageNamed:@"tour-tab-button-bg"] stretchableImageWithLeftCapWidth:8 topCapHeight:0] forState:UIControlStateNormal];

    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bottomView.bounds
                                                   byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight
                                                         cornerRadii:CGSizeMake(6, 6)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bottomView.bounds;
    maskLayer.path = maskPath.CGPath;
    [self.bottomView.layer setMask:maskLayer];
    [maskLayer release];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (IBAction)closeView:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

@end
