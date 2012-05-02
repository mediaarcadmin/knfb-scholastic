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
- (BOOL)fileSystemHasBytesAvailable:(unsigned long long)sizeInBytes;

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
    }
    
    if (completion) {
        completion();
    }
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
    BOOL fileSpaceAvailable = [self fileSystemHasBytesAvailable:1073741824];

    if (fileSpaceAvailable == NO) {
        LambdaAlert *alert = [[LambdaAlert alloc]
                              initWithTitle:NSLocalizedString(@"Not Enough Free Space", @"")
                              message:NSLocalizedString(@"You do not have enough memory on your device to download the Scholastic Dictionary. Please clear some space and then go to Parent Tools from the eReader sign-in screen to download the Dictionary.", @"")];
        [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:afterDownload];
        [alert show];
        [alert release];   
        return;
    }
    
    [[SCHDictionaryDownloadManager sharedDownloadManager] beginDictionaryDownload];
    
    
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
       CGFloat gap = UIInterfaceOrientationIsLandscape(orientation) ? 10 : 18;
       CGFloat yOffset = UIInterfaceOrientationIsLandscape(orientation) ? 24 : 24;
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
           
           // round frame positions
           label.frame = CGRectIntegral(label.frame);
           
           NSLog(@"Frame: %@", NSStringFromCGRect(label.frame));
       }
              
       if (self.closeButton) {
       
           CGRect dictionaryButtonFrame = self.downloadDictionaryButton.frame;
           
           dictionaryButtonFrame.origin.x = downloadButtonXOrigin;
           dictionaryButtonFrame.origin.y = y;
           dictionaryButtonFrame.size.width = buttonWidth;
           
           CGRect closeButtonFrame = self.closeButton.frame;
           closeButtonFrame.origin.x = closeButtonXOrigin;
           closeButtonFrame.origin.y = y + closeButtonYOffset;
           closeButtonFrame.size.width = buttonWidth;

           self.closeButton.frame = closeButtonFrame;
           self.downloadDictionaryButton.frame = dictionaryButtonFrame;
       }
       
   }
}

- (BOOL)fileSystemHasBytesAvailable:(unsigned long long)sizeInBytes
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDirectory = ([paths count] > 0 ? [paths objectAtIndex:0] : nil);            
    
    NSFileManager *localFileManager = [[NSFileManager alloc] init];
    
    NSDictionary* fsAttr = [localFileManager attributesOfFileSystemForPath:docDirectory error:NULL];
    
    [localFileManager release];
    
    unsigned long long freeSize = [(NSNumber*)[fsAttr objectForKey:NSFileSystemFreeSize] unsignedLongLongValue];
    //NSLog(@"Freesize: %llu", freeSize);
    
    return (sizeInBytes <= freeSize);
}

@end
