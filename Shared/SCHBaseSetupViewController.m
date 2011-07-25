//
//  SCHBaseSetupViewController.m
//  Scholastic
//
//  Created by Neil Gall on 20/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SCHBaseSetupViewController.h"

@implementation SCHBaseSetupViewController

- (void)dealloc
{
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.view.layer setBorderColor:[UIColor SCHRed3Color].CGColor];
    [self.navigationController.view.layer setBorderWidth:2.0f];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)setButtonBackground:(UIButton *)button
{
    if (button) {
        UIImage *buttonBGImage = [[UIImage imageNamed:@"button-login-red"] stretchableImageWithLeftCapWidth:10 topCapHeight:0];
        [button setBackgroundImage:buttonBGImage forState:UIControlStateNormal];
    }
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)closeSettings
{
    [self.navigationController.parentViewController dismissModalViewControllerAnimated:YES];
}

@end
