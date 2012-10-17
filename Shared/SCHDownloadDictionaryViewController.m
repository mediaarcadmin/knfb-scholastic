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
@synthesize actionButton;
@synthesize containerView;
@synthesize shadowView;
@synthesize backButton;
@synthesize appController;

- (void)dealloc
{
    [self releaseViewObjects];
    [completion release], completion = nil;
    appController = nil;
    
    [super dealloc];
}

- (void)releaseViewObjects
{
    [actionButton release], actionButton = nil;
    [containerView release], containerView = nil;
    [shadowView release], shadowView = nil;
    [backButton release], backButton = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *stretchedButtonImage = [[UIImage imageNamed:@"lg_bttn_gray_UNselected_3part"] stretchableImageWithLeftCapWidth:7 topCapHeight:0];
    [self.actionButton setBackgroundImage:stretchedButtonImage forState:UIControlStateNormal];
    
    UIImage *backButtonImage = [[UIImage imageNamed:@"bookshelf_arrow_bttn_UNselected_3part"] stretchableImageWithLeftCapWidth:11 topCapHeight:0];
    [self.backButton setBackgroundImage:backButtonImage forState:UIControlStateNormal];
    
    self.shadowView.layer.shadowOpacity = 0.5f;
    self.shadowView.layer.shadowOffset = CGSizeMake(0, 0);
    self.shadowView.layer.shadowRadius = 4.0f;
    self.shadowView.layer.backgroundColor = [UIColor clearColor].CGColor;
    self.containerView.layer.masksToBounds = YES;
    self.containerView.layer.cornerRadius = 10.0f;
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
                              initWithTitle:NSLocalizedString(@"Not Enough Storage Space", @"")
                              message:NSLocalizedString(@"You do not have enough storage space on your device to complete this function. Please clear some space and try again.", @"")];
        [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:afterDownload];
        [alert show];
        [alert release];   
        return;
    }
    
    BOOL reachable = [[Reachability reachabilityForLocalWiFi] isReachable];
    
    if (reachable == NO) {
        LambdaAlert *alert = [[LambdaAlert alloc]
                              initWithTitle:NSLocalizedString(@"No Wi-Fi Connection", @"")
                              message:NSLocalizedString(@"Downloading the dictionary requires a Wi-Fi connection. Please connect to Wi-Fi and then try again.", @"")];
        [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:afterDownload];
        [alert show];
        [alert release];
        return;
    } else {
        [[SCHDictionaryDownloadManager sharedDownloadManager] beginDictionaryDownload];
        afterDownload();
    }
    
    [self.appController presentSettings];
}

- (void)removeDictionary:(id)sender
{
    [[SCHDictionaryDownloadManager sharedDownloadManager] deleteDictionary];
    [self.appController presentSettings];
}

- (IBAction)close:(id)sender
{
    [self.appController presentSettings];
}

@end
