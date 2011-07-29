//
//  SCHRemoveDictionaryViewController.m
//  Scholastic
//
//  Created by Neil Gall on 22/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHRemoveDictionaryViewController.h"
#import "SCHDictionaryDownloadManager.h"

@interface SCHRemoveDictionaryViewController ()
- (void)layoutLabelsForOrientation:(UIInterfaceOrientation)orientation;
@end

@implementation SCHRemoveDictionaryViewController

@synthesize removeDictionaryButton;
@synthesize labels;

- (void)releaseViewObjects
{
    [removeDictionaryButton release], removeDictionaryButton = nil;
    [labels release], labels = nil;
    [super releaseViewObjects];
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
    
    self.labels = [self.labels sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [(UIView *)obj1 tag] - [(UIView *)obj2 tag];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self layoutLabelsForOrientation:self.interfaceOrientation];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self releaseViewObjects];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [UIView animateWithDuration:duration animations:^{
        [self layoutLabelsForOrientation:toInterfaceOrientation];
    }];
}

- (void)removeDictionary:(id)sender
{
    [[SCHDictionaryDownloadManager sharedDownloadManager] deleteDictionary];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)layoutLabelsForOrientation:(UIInterfaceOrientation)orientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        CGFloat width = UIInterfaceOrientationIsLandscape(orientation) ? 440 : 280;
        CGFloat gap = UIInterfaceOrientationIsLandscape(orientation) ? 8 : 18;
        CGFloat yOffset = UIInterfaceOrientationIsLandscape(orientation) ? 16 : 30;
        CGFloat buttonOffset = UIInterfaceOrientationIsLandscape(orientation) ? 16 : 16;
        
        CGFloat y = yOffset;
        for (UILabel *label in self.labels) {
            CGSize size = [label.text sizeWithFont:label.font
                                 constrainedToSize:CGSizeMake(width, CGRectGetHeight(label.bounds))
                                     lineBreakMode:label.lineBreakMode];
            label.center = CGPointMake(label.center.x, floorf(y+size.height/2));
            y += size.height + gap;
        }
        
        y += buttonOffset;
        
        self.removeDictionaryButton.center = CGPointMake(self.removeDictionaryButton.center.x, floorf(y+CGRectGetHeight(self.removeDictionaryButton.bounds)/2));
    }
}

@end
