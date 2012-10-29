//
//  SCHDownloadDictionaryChoiceViewController.m
//  Scholastic
//
//  Created by Matt Farrugia on 29/10/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHDownloadDictionaryChoiceViewController.h"

@interface SCHDownloadDictionaryChoiceViewController ()

@end

@implementation SCHDownloadDictionaryChoiceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.downloadLaterButton setHidden:NO];
    [self.backButton setHidden:YES];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.view.layer setCornerRadius:10];
        [self.view setClipsToBounds:YES];
    }
}

- (IBAction)downloadDictionary:(id)sender
{
    [self startDictionaryDownload];
}

- (IBAction)close:(id)sender
{
    if (self.completionBlock) {
        self.completionBlock();
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return (UIInterfaceOrientationIsLandscape(interfaceOrientation));
    } else {
        return (UIInterfaceOrientationIsPortrait(interfaceOrientation));
    }
}

@end
