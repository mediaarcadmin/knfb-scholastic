//
//  SCHDownloadDictionaryViewController.m
//  Scholastic
//
//  Created by Neil Gall on 20/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHDownloadDictionaryViewController.h"
#import "SCHDictionaryDownloadManager.h"

@interface SCHDownloadDictionaryViewController ()
- (void)layoutLabelsForOrientation:(UIInterfaceOrientation)orientation;
@end

@implementation SCHDownloadDictionaryViewController

@synthesize labels;
@synthesize downloadDictionaryButton;

- (void)dealloc
{
    [downloadDictionaryButton release], downloadDictionaryButton = nil;
    [labels release], labels = nil;
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setButtonBackground:self.downloadDictionaryButton];
    
    self.labels = [self.labels sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [(UIView *)obj1 tag] - [(UIView *)obj2 tag];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self layoutLabelsForOrientation:self.interfaceOrientation];
}

- (void)closeSettings
{
    [[SCHDictionaryDownloadManager sharedDownloadManager] threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateUserDeclined];
    [super closeSettings];
}

- (void)downloadDictionary:(id)sender
{
    [[SCHDictionaryDownloadManager sharedDownloadManager] beginDictionaryDownload];
    [super closeSettings];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self layoutLabelsForOrientation:toInterfaceOrientation];
}

- (void)layoutLabelsForOrientation:(UIInterfaceOrientation)orientation
{
   if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
       CGFloat width = UIInterfaceOrientationIsLandscape(orientation) ? 440 : 280;
       [UIView animateWithDuration:0.25 animations:^{
           CGFloat y = 20;
           for (UILabel *label in self.labels) {
               CGSize size = [label.text sizeWithFont:label.font
                                    constrainedToSize:CGSizeMake(width, CGRectGetHeight(label.bounds))
                                        lineBreakMode:label.lineBreakMode];
               label.center = CGPointMake(label.center.x, floorf(y+size.height/2));
               y += size.height + 15;
           }
           self.downloadDictionaryButton.center = CGPointMake(self.downloadDictionaryButton.center.x, floorf(y+CGRectGetHeight(self.downloadDictionaryButton.bounds)/2));
       }];
    }
}

@end
