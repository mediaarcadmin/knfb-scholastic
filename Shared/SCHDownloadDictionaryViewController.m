//
//  SCHDownloadDictionaryViewController.m
//  Scholastic
//
//  Created by Neil Gall on 20/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHDownloadDictionaryViewController.h"
#import "SCHDictionaryDownloadManager.h"
#import "SCHAppDictionaryState.h"
#import "SCHAppStateManager.h"
#import "Reachability.h"
#import "LambdaAlert.h"
#import "NSFileManager+Extensions.h"
#import "SCHVersionDownloadManager.h"
#import "NSString+FileSize.h"
#import "SCHUserDefaults.h"

@interface SCHDownloadDictionaryViewController()

- (void)releaseViewObjects;
- (void)showAppVersionOutdatedAlert;

@end

@implementation SCHDownloadDictionaryViewController

@synthesize completionBlock;
@synthesize actionButton;
@synthesize containerView;
@synthesize shadowView;
@synthesize backButton;
@synthesize appController;
@synthesize downloadLaterButton;
@synthesize textLabel;
@synthesize removeDictionaryTextLabel;

- (void)dealloc
{
    [self releaseViewObjects];
    [completionBlock release], completionBlock = nil;
    appController = nil;
    
    [super dealloc];
}

- (void)releaseViewObjects
{
    [actionButton release], actionButton = nil;
    [containerView release], containerView = nil;
    [shadowView release], shadowView = nil;
    [backButton release], backButton = nil;
    [downloadLaterButton release], downloadLaterButton = nil;
    [textLabel release], textLabel = nil;
    [removeDictionaryTextLabel release], removeDictionaryTextLabel =nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *stretchedButtonImage = [[UIImage imageNamed:@"lg_bttn_gray_UNselected_3part"] stretchableImageWithLeftCapWidth:7 topCapHeight:0];
    [self.actionButton setBackgroundImage:stretchedButtonImage forState:UIControlStateNormal];
    [self.downloadLaterButton setBackgroundImage:stretchedButtonImage forState:UIControlStateNormal];
    
    UIImage *backButtonImage = [[UIImage imageNamed:@"bookshelf_arrow_bttn_UNselected_3part"] stretchableImageWithLeftCapWidth:11 topCapHeight:0];
    [self.backButton setBackgroundImage:backButtonImage forState:UIControlStateNormal];
    
    self.shadowView.layer.shadowOpacity = 0.5f;
    self.shadowView.layer.shadowOffset = CGSizeMake(0, 0);
    self.shadowView.layer.shadowRadius = 4.0f;
    self.shadowView.layer.backgroundColor = [UIColor clearColor].CGColor;
    self.containerView.layer.masksToBounds = YES;
    self.containerView.layer.cornerRadius = 10.0f;

    __block NSString *freeSpaceString = nil;
    [[SCHDictionaryDownloadManager sharedDownloadManager] withAppDictionaryStatePerform:^(SCHAppDictionaryState *state) {
        freeSpaceString = [state freeSpaceRequiredToCompleteDownloadAsString];
    }];
    if (freeSpaceString != nil) {
        self.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Storia features a rich dictionary built especially for kids. "
                                                                           @"It includes definitions tailored to different ages and stages with complete audio readthroughs of all definitions for young kids.\n\n"
                                                                           @"This download requires about %@. "
                                                                           @"The dictionary will download in the background while you continue to read.", nil), freeSpaceString];
    } else {
        self.textLabel.text = NSLocalizedString(@"Storia features a rich dictionary built especially for kids. "
                                                @"It includes definitions tailored to different ages and stages with complete audio readthroughs of all definitions for young kids.\n\n"
                                                @"The dictionary will download in the background while you continue to read.", nil);
    }

    NSString *onDiskSpaceString = [NSString stringWithSizeInGBFromBytes:[[NSUserDefaults standardUserDefaults] integerForKey:kSCHDictionaryTotalUncompressedFileSize]];
    self.removeDictionaryTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"The Storia Dictionary uses about %@ of storage space. "
                                                                                       @"If you remove the dictionary, readers will no longer be able to look up words or get word pronunciations.\n\n"
                                                                                       @"If you choose to remove the dictionary, you can download it again at any time.", nil), onDiskSpaceString];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillUnload
{
    [self releaseViewObjects];
}

- (void)startDictionaryDownload
{
    dispatch_block_t afterDownload = ^{
        if (self.completionBlock) {
            self.completionBlock();
        }
    };
    
    // we need to have free space for dictionary download
    __block NSInteger *freeSpaceInBytesRequiredToCompleteDownload = 0;
    [[SCHDictionaryDownloadManager sharedDownloadManager] withAppDictionaryStatePerform:^(SCHAppDictionaryState *state) {
        freeSpaceInBytesRequiredToCompleteDownload = [state freeSpaceInBytesRequiredToCompleteDownload];
    }];

    BOOL fileSpaceAvailable = [[NSFileManager defaultManager] BITfileSystemHasBytesAvailable:freeSpaceInBytesRequiredToCompleteDownload];

    if (fileSpaceAvailable == NO) {
        __block NSString *freeSpaceString = nil;
        [[SCHDictionaryDownloadManager sharedDownloadManager] withAppDictionaryStatePerform:^(SCHAppDictionaryState *state) {
            freeSpaceString = [state freeSpaceRequiredToCompleteDownloadAsString];
        }];
        NSString *messageString = nil;
        if (freeSpaceString != nil) {
            messageString = [NSString stringWithFormat:NSLocalizedString(@"You do not have enough storage space on your device to complete this function. "
                                                                         @"Please clear %@ of space and try again.", @""), freeSpaceString];
        } else {
            messageString = NSLocalizedString(@"You do not have enough storage space on your device to complete this function."
                                              @"Please clear some space and try again.", @"");
        }
        LambdaAlert *alert = [[LambdaAlert alloc]
                              initWithTitle:NSLocalizedString(@"Not Enough Storage Space", @"")
                              message:messageString];
        [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:afterDownload];
        [alert show];
        [alert release];
        return;
    }
    
    BOOL reachable = [[Reachability reachabilityForLocalWiFi] isReachable];
    
    if (reachable == NO) {
        LambdaAlert *alert = [[LambdaAlert alloc]
                              initWithTitle:NSLocalizedString(@"No WiFi Connection", @"")
                              message:NSLocalizedString(@"The dictionary will only download over a WiFi connection. When you are connected to WiFi, the download will begin.", @"")];
        [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:afterDownload];
        [alert show];
        [alert release];
        return;
    } else {
        [[SCHDictionaryDownloadManager sharedDownloadManager] beginDictionaryDownload];
        afterDownload();
    }

}

- (void)startDictionaryDeletion
{
    [[SCHDictionaryDownloadManager sharedDownloadManager] deleteDictionary];
    if (self.completionBlock) {
        self.completionBlock();
    }
}

- (IBAction)downloadDictionary:(id)sender
{
    if ([[SCHVersionDownloadManager sharedVersionManager] isAppVersionOutdated] == YES) {
        [self showAppVersionOutdatedAlert];
    } else {
        [self startDictionaryDownload];
        [self.appController presentSettingsWithExpandedNavigation];
    }
}

- (IBAction)removeDictionary:(id)sender
{
    if ([[SCHDictionaryDownloadManager sharedDownloadManager] dictionaryProcessingState] != SCHDictionaryProcessingStateNeedsParse) {
        [self startDictionaryDeletion];
        [self.appController presentSettingsWithExpandedNavigation];
    }
    else {
        LambdaAlert *alert = [[LambdaAlert alloc]
                              initWithTitle:NSLocalizedString(@"Removal Failed", @"")
                              message:NSLocalizedString(@"The dictionary can't be removed at this time.  Try again shortly.", @"")];
        [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:nil];
        [alert show];
        [alert release];
    }
}

- (IBAction)close:(id)sender
{
    [self.appController presentSettings];
}

- (void)showAppVersionOutdatedAlert
{
    LambdaAlert *alert = [[LambdaAlert alloc]
                          initWithTitle:NSLocalizedString(@"Update Required", @"")
                          message:NSLocalizedString(@"This function requires that you update Storia. Please visit the App Store to update your app.", @"")];
    [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:nil];
    [alert show];
    [alert release];
}

@end
