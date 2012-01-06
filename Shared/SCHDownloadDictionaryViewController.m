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

@interface SCHDownloadDictionaryViewController ()
- (void)layoutLabelsForOrientation:(UIInterfaceOrientation)orientation;
@end

@implementation SCHDownloadDictionaryViewController

@synthesize labels;
@synthesize downloadSizeLabel;
@synthesize downloadDictionaryButton;
@synthesize closeButton;
@synthesize completion;

- (void)releaseViewObjects
{
    [downloadDictionaryButton release], downloadDictionaryButton = nil;
    [labels release], labels = nil;
    [closeButton release], closeButton = nil;
    [downloadSizeLabel release], downloadSizeLabel = nil;
}

- (void)dealloc
{
    [self releaseViewObjects];
    [completion release], completion = nil;
    [super dealloc];
}

- (void)viewDidUnload
{
    [self releaseViewObjects];
    [super viewDidUnload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setButtonBackground:self.downloadDictionaryButton];
    [self setButtonBackground:self.closeButton];
    
    self.closeButton.accessibilityLabel = @"Close Button";
    
    if ([[SCHAppStateManager sharedAppStateManager] isSampleStore]) {
        self.downloadSizeLabel.text = NSLocalizedString(@"This download is about 400MB.", @"");
    }

    self.labels = [self.labels sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [(UIView *)obj1 tag] - [(UIView *)obj2 tag];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self layoutLabelsForOrientation:self.interfaceOrientation];
}

- (void)close
{
    if ([[SCHAppStateManager sharedAppStateManager] isSampleStore] == NO) {
        [[SCHDictionaryDownloadManager sharedDownloadManager] threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateUserDeclined];
        [SCHDictionaryDownloadManager sharedDownloadManager].userRequestState = SCHDictionaryUserDeclined;
        

       // [self.profileSetupDelegate showCurrentProfileAnimated:YES];
    } //else {
        //[self.profileSetupDelegate pushSamplesAnimated:self.shouldAnimateSamplesPush];
    //}
    
    if (completion) {
        completion();
    }
}

- (void)downloadDictionary:(id)sender
{
    [[SCHDictionaryDownloadManager sharedDownloadManager] beginDictionaryDownload];
    
    dispatch_block_t afterDownload = ^{
        if (completion) {
            completion();
        }
        //if ([[SCHAppStateManager sharedAppStateManager] isSampleStore] == NO) {
          //  [self.profileSetupDelegate showCurrentProfileAnimated:YES];
        //} else {
          //  [self.profileSetupDelegate pushSamplesAnimated:YES];
        //}
    };
    
    BOOL reachable = [[Reachability reachabilityForLocalWiFi] isReachable];
    
    if (reachable == NO) {
        LambdaAlert *alert = [[LambdaAlert alloc]
                              initWithTitle:NSLocalizedString(@"No WiFi Connection", @"")
                              message:NSLocalizedString(@"The dictionary will only download over a WiFi connection. When you are connected to WiFi, the download will begin.", @"")];
        [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:afterDownload];
        [alert show];
        [alert release];   
    } else {
        afterDownload();
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [UIView animateWithDuration:duration animations:^{
        [self layoutLabelsForOrientation:toInterfaceOrientation];
    }];
}

- (void)layoutLabelsForOrientation:(UIInterfaceOrientation)orientation
{
   if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
       CGFloat width = UIInterfaceOrientationIsLandscape(orientation) ? 460 : 280;
       CGFloat gap = UIInterfaceOrientationIsLandscape(orientation) ? 6 : 18;
       CGFloat yOffset = UIInterfaceOrientationIsLandscape(orientation) ? 12 : 24;
       CGFloat downloadButtonXOrigin = UIInterfaceOrientationIsLandscape(orientation) ? 30 : 20;
       CGFloat closeButtonYOffset = UIInterfaceOrientationIsLandscape(orientation) ? 0 : 54;
       CGFloat closeButtonXOrigin = UIInterfaceOrientationIsLandscape(orientation) ? 240 : 20;
       CGFloat buttonWidth = UIInterfaceOrientationIsLandscape(orientation) ? 200 : 280;

       CGFloat y = yOffset;
       for (UILabel *label in self.labels) {
           CGSize size = [label.text sizeWithFont:label.font
                                constrainedToSize:CGSizeMake(width, CGRectGetHeight(label.bounds))
                                    lineBreakMode:label.lineBreakMode];
           label.center = CGPointMake(label.center.x, floorf(y+size.height/2));
           y += size.height + gap;
       }
              
       CGRect dictionaryButtonFrame = self.downloadDictionaryButton.frame;

       dictionaryButtonFrame.origin.x = downloadButtonXOrigin;
       dictionaryButtonFrame.origin.y = y;
       dictionaryButtonFrame.size.width = buttonWidth;
       
       CGRect closeButtonFrame = self.closeButton.frame;
       closeButtonFrame.origin.x = closeButtonXOrigin;
       closeButtonFrame.origin.y = y + closeButtonYOffset;
       closeButtonFrame.size.width = buttonWidth;

       
       self.downloadDictionaryButton.frame = dictionaryButtonFrame;
       self.closeButton.frame = closeButtonFrame;
   }
}

@end
