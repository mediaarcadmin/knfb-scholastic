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

@implementation SCHBaseSetupViewController

@synthesize setupDelegate;
@synthesize topToolbar;
@synthesize containerView;
@synthesize backgroundView;
@synthesize barSpacer;

- (void)dealloc
{
    [super dealloc];
}

- (void)releaseViewObjects
{
    [topToolbar release], topToolbar = nil;
    [containerView release], containerView = nil;
    [backgroundView release], backgroundView = nil;
    [barSpacer release], barSpacer = nil;
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
        [self.backgroundView setImage:[UIImage imageNamed:@"plain-background-portrait.jpg"]];   
        [self.navigationController.view.layer setBorderColor:[UIColor SCHRed3Color].CGColor];
        [self.navigationController.view.layer setBorderWidth:2.0f];
    } else {
        CGRect barFrame = self.topToolbar.frame;
        if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
            [self.backgroundView setImage:[UIImage imageNamed:@"plain-background-landscape.jpg"]];
            [self.topToolbar setBackgroundImage:[UIImage imageNamed:@"admin-iphone-landscape-top-toolbar.png"]];
            barFrame.size.height = 32;
            self.barSpacer.width = 38;
        } else {
            [self.backgroundView setImage:[UIImage imageNamed:@"plain-background-portrait.jpg"]];   
            [self.topToolbar setBackgroundImage:[UIImage imageNamed:@"admin-iphone-portrait-top-toolbar.png"]];
            barFrame.size.height = 44;
            self.barSpacer.width = 0;
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

- (void)setEnablesBackButton:(BOOL)enablesBackButton
{
    UIBarButtonItem *item = (UIBarButtonItem *)[self.topToolbar.items objectAtIndex:0];
    
    if (item != nil) {
        item.enabled = enablesBackButton;
    }
}

- (void)closeSettings
{
    [self.setupDelegate dismissSettingsWithCompletionHandler:nil];
}

@end
