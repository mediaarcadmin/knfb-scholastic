//
//  SCHDownloadDictionaryViewController.m
//  Scholastic
//
//  Created by Neil Gall on 20/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHDownloadDictionaryViewController.h"
#import "SCHDictionaryDownloadManager.h"

@implementation SCHDownloadDictionaryViewController

@synthesize downlaodDictionaryButton;

- (void)dealloc
{
    [downlaodDictionaryButton release], downlaodDictionaryButton = nil;
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setButtonBackground:self.downlaodDictionaryButton];
}

- (void)back:(id)sender
{
    [[SCHDictionaryDownloadManager sharedDownloadManager] threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateUserDeclined];
    [super back:sender];
}

- (void)downloadDictionary:(id)sender
{
    [[SCHDictionaryDownloadManager sharedDownloadManager] beginDictionaryDownload];
    [self.navigationController.parentViewController dismissModalViewControllerAnimated:YES];
}

@end
