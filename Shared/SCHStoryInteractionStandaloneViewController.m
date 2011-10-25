//
//  SCHStoryInteractionViewController.m
//  Scholastic
//
//  Created by Neil Gall on 31/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionStandaloneViewController.h"
#import "SCHStoryInteractionController.h"

@interface SCHStoryInteractionStandaloneViewController ()
@property (nonatomic, retain) UIImageView *readingViewSnapshotView;
@end

@implementation SCHStoryInteractionStandaloneViewController

@synthesize storyInteractionController;
@synthesize readingViewSnapshotView;

- (void)releaseViewObjects
{
    [readingViewSnapshotView release], readingViewSnapshotView = nil;    
}

- (void)dealloc
{
    [storyInteractionController release], storyInteractionController = nil;
    [self releaseViewObjects];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    UIImageView *snapshotView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    snapshotView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.readingViewSnapshotView = snapshotView;
    [self.view addSubview:self.readingViewSnapshotView];
    [snapshotView release];
}

- (void)viewDidUnload
{
    [self releaseViewObjects];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.view.frame = self.view.superview.bounds;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
#if STORY_INTERACTIONS_SUPPORT_AUTO_ROTATION
    return YES;
#else
    if ([self.storyInteractionController shouldPresentInPortraitOrientation]) {
        return UIInterfaceOrientationIsPortrait(interfaceOrientation);
    } else {
        return UIInterfaceOrientationIsLandscape(interfaceOrientation);
    }
#endif
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
#if STORY_INTERACTIONS_SUPPORT_AUTO_ROTATION
    [self.storyInteractionController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
#endif
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
#if STORY_INTERACTIONS_SUPPORT_AUTO_ROTATION
    [self.storyInteractionController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
#endif
}

- (void)setReadingViewSnapshot:(UIImage *)image
{
    // ensure view is setup
    [self view];
    self.readingViewSnapshotView.image = image;
}

@end
