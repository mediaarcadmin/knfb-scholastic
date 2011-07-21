//
//  SCHBaseSetupViewController.m
//  Scholastic
//
//  Created by Neil Gall on 20/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBaseSetupViewController.h"


@implementation SCHBaseSetupViewController

- (void)dealloc
{
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)setButtonBackground:(UIButton *)button
{
    UIImage *buttonBGImage = [[UIImage imageNamed:@"button-login-red"] stretchableImageWithLeftCapWidth:10 topCapHeight:0];
    [button setBackgroundImage:buttonBGImage forState:UIControlStateNormal];
}

- (void)back:(id)sender
{
    [self.navigationController.parentViewController dismissModalViewControllerAnimated:YES];
}

@end
