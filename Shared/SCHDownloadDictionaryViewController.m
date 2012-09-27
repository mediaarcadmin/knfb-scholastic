//
//  SCHDownloadDictionaryViewController.m
//  Scholastic
//
//  Created by Neil Gall on 20/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHDownloadDictionaryViewController.h"
#import "SCHDictionaryDownloadManager.h"
#import "SCHAppStateManager.h"
#import "Reachability.h"
#import "LambdaAlert.h"
#import "NSFileManager+Extensions.h"

@interface SCHDownloadDictionaryViewController()

@property (nonatomic, copy) dispatch_block_t completion;

- (void)releaseViewObjects;

@end

@implementation SCHDownloadDictionaryViewController

@synthesize completion;
@synthesize downloadButton;

- (void)dealloc
{
    [self releaseViewObjects];
    [completion release], completion = nil;
    [super dealloc];
}

- (void)releaseViewObjects
{
    [downloadButton release], downloadButton = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *stretchedButtonImage = [[UIImage imageNamed:@"lg_bttn_gray_UNselected_3part"] stretchableImageWithLeftCapWidth:7 topCapHeight:0];
    [self.downloadButton setBackgroundImage:stretchedButtonImage forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillUnload
{
    [self releaseViewObjects];
}

- (void)downloadDictionary:(id)sender
{
    dispatch_block_t afterDownload = ^{
        if (completion) {
            completion();
        }
    };

    // we need to have 1GB free for initial dictionary download
    // less for subsequent updates
    BOOL fileSpaceAvailable = [[NSFileManager defaultManager] BITfileSystemHasBytesAvailable:1073741824];

    if (fileSpaceAvailable == NO) {
        LambdaAlert *alert = [[LambdaAlert alloc]
                              initWithTitle:NSLocalizedString(@"Not Enough Free Space", @"")
                              message:NSLocalizedString(@"You do not have enough memory on your device to download the Storia dictionary. Please clear some space and then go to the Parent Tools menu to download the Dictionary.", @"")];
        [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:afterDownload];
        [alert show];
        [alert release];   
        return;
    }
    
    [[SCHDictionaryDownloadManager sharedDownloadManager] beginDictionaryDownload];
    
    
    BOOL reachable = [[Reachability reachabilityForLocalWiFi] isReachable];
    
    if (reachable == NO) {
        LambdaAlert *alert = [[LambdaAlert alloc]
                              initWithTitle:NSLocalizedString(@"No Wi-Fi Connection", @"")
                              message:NSLocalizedString(@"Downloading the dictionary requires a Wi-Fi connection. Please connect to Wi-Fi and then try again.", @"")];
        [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:afterDownload];
        [alert show];
        [alert release];   
    } else {
        afterDownload();
    }
}

@end
