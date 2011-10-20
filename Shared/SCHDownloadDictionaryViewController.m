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

@interface SCHDownloadDictionaryViewController ()
- (void)layoutLabelsForOrientation:(UIInterfaceOrientation)orientation;
@end

@implementation SCHDownloadDictionaryViewController

@synthesize labels;
@synthesize downloadSizeLabel;
@synthesize downloadDictionaryButton;
@synthesize closeButton;

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

- (void)setupAssetsForOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    [super setupAssetsForOrientation:(UIInterfaceOrientation)toInterfaceOrientation];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
            self.barSpacer.width = 68;
        } else {
            self.barSpacer.width = 0;
        }
    }
}

- (void)close
{
    if ([[SCHAppStateManager sharedAppStateManager] isSampleStore] == NO) {
        [[SCHDictionaryDownloadManager sharedDownloadManager] threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateUserDeclined];
        [SCHDictionaryDownloadManager sharedDownloadManager].userRequestState = SCHDictionaryUserDeclined;
        [self.profileSetupDelegate showCurrentProfile];
    } else {
        [self.profileSetupDelegate showCurrentSamples];
    }
}

- (void)downloadDictionary:(id)sender
{
    [[SCHDictionaryDownloadManager sharedDownloadManager] beginDictionaryDownload];
    
    if ([[SCHAppStateManager sharedAppStateManager] isSampleStore] == NO) {
        [self.profileSetupDelegate showCurrentProfile];
    } else {
        [self.profileSetupDelegate showCurrentSamples];
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
       CGFloat width = UIInterfaceOrientationIsLandscape(orientation) ? 440 : 280;
       CGFloat gap = UIInterfaceOrientationIsLandscape(orientation) ? 8 : 18;
       CGFloat yOffset = UIInterfaceOrientationIsLandscape(orientation) ? 16 : 30;
       CGFloat buttonOffset = UIInterfaceOrientationIsLandscape(orientation) ? 0 : 16;
       
       CGFloat y = yOffset;
       for (UILabel *label in self.labels) {
           CGSize size = [label.text sizeWithFont:label.font
                                constrainedToSize:CGSizeMake(width, CGRectGetHeight(label.bounds))
                                    lineBreakMode:label.lineBreakMode];
           label.center = CGPointMake(label.center.x, floorf(y+size.height/2));
           y += size.height + gap;
       }
       
       y += buttonOffset;
       
       self.downloadDictionaryButton.center = CGPointMake(self.downloadDictionaryButton.center.x, floorf(y+CGRectGetHeight(self.downloadDictionaryButton.bounds)/2));
   }
}

@end
