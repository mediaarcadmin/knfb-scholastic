//
//  SCHBaseSetupViewController.m
//  Scholastic
//
//  Created by Neil Gall on 20/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SCHBaseSetupViewController.h"
#import "SCHCustomToolbar.h"
#import "SCHSetupDelegate.h"

@interface SCHBaseSetupViewController ()
- (void)setupAssetsForOrientation:(UIInterfaceOrientation)toInterfaceOrientation;
@end

@implementation SCHBaseSetupViewController

@synthesize setupDelegate;
@synthesize topToolbar;
@synthesize containerView;
@synthesize backgroundView;

- (void)dealloc
{
    [super dealloc];
}

- (void)releaseViewObjects
{
    [topToolbar release], topToolbar = nil;
    [containerView release], containerView = nil;
    [backgroundView release], backgroundView = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupAssetsForOrientation:self.interfaceOrientation];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self setupAssetsForOrientation:toInterfaceOrientation];
}

- (void)setupAssetsForOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.topToolbar setBackgroundImage:[UIImage imageNamed:@"settings-ipad-top-toolbar.png"]];
        [self.backgroundView setImage:[UIImage imageNamed:@"plain-background-portrait.png"]];   
        [self.navigationController.view.layer setBorderColor:[UIColor SCHRed3Color].CGColor];
        [self.navigationController.view.layer setBorderWidth:2.0f];
    } else {
        CGRect barFrame = self.topToolbar.frame;
        if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
            [self.backgroundView setImage:[UIImage imageNamed:@"plain-background-landscape.png"]];
            [self.topToolbar setBackgroundImage:[UIImage imageNamed:@"admin-iphone-landscape-top-toolbar.png"]];
            barFrame.size.height = 32;
        } else {
            [self.backgroundView setImage:[UIImage imageNamed:@"plain-background-portrait.png"]];   
            [self.topToolbar setBackgroundImage:[UIImage imageNamed:@"admin-iphone-portrait-top-toolbar.png"]];
            barFrame.size.height = 44;
        }

        CGRect containerFrame = self.containerView.frame;
        CGFloat containerMaxY = CGRectGetMaxY(containerFrame);
        containerFrame.origin.y = CGRectGetMaxY(barFrame);
        containerFrame.size.height = containerMaxY - containerFrame.origin.y;
        self.topToolbar.frame = barFrame;
        self.containerView.frame = containerFrame; 
    }
}

- (void)setButtonBackground:(UIButton *)button
{
    if (button) {
        UIImage *buttonBGImage = [[UIImage imageNamed:@"button-login-red"] stretchableImageWithLeftCapWidth:11 topCapHeight:0];
        [button setBackgroundImage:buttonBGImage forState:UIControlStateNormal];
    }
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)closeSettings
{
    [self.setupDelegate dismissSettingsForm];
}

@end
