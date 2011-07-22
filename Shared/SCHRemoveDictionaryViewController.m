//
//  SCHRemoveDictionaryViewController.m
//  Scholastic
//
//  Created by Neil Gall on 22/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHRemoveDictionaryViewController.h"
#import "SCHDictionaryDownloadManager.h"

@implementation SCHRemoveDictionaryViewController

@synthesize removeDictionaryButton;

- (void)releaseViewObjects
{
    [removeDictionaryButton release], removeDictionaryButton = nil;
}

- (void)dealloc
{
    [self releaseViewObjects];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setButtonBackground:self.removeDictionaryButton];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self releaseViewObjects];
}

- (void)removeDictionary:(id)sender
{
    [[SCHDictionaryDownloadManager sharedDownloadManager] deleteDictionary];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
