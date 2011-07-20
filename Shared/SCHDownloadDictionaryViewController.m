//
//  SCHDownloadDictionaryViewController.m
//  Scholastic
//
//  Created by Neil Gall on 20/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHDownloadDictionaryViewController.h"


@implementation SCHDownloadDictionaryViewController

@synthesize downlaodDictionaryButton;

- (void)dealloc
{
    [downlaodDictionaryButton release], downlaodDictionaryButton = nil;
    [super dealloc];
}

- (void)viewDidLoad
{
    UIImage *buttonBGImage = [[UIImage imageNamed:@"button-login-red"] stretchableImageWithLeftCapWidth:10 topCapHeight:0];
    [self.downlaodDictionaryButton setBackgroundImage:buttonBGImage forState:UIControlStateNormal];
    
    [super viewDidLoad];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)downloadDictionary:(id)sender
{
    
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
