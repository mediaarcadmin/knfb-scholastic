//
//  SCHStoryInteractionViewController.m
//  Scholastic
//
//  Created by Neil Gall on 31/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionStandaloneViewController.h"
#import "SCHStoryInteractionController.h"

struct BackgroundViewState {
    CGPoint center;
    CGRect bounds;
    CGAffineTransform transform;
};

@interface SCHStoryInteractionStandaloneViewController ()
@property (nonatomic, retain) UIView *backgroundView;
@property (nonatomic, assign) struct BackgroundViewState backgroundViewState;     
@end

@implementation SCHStoryInteractionStandaloneViewController

@synthesize storyInteractionController;
@synthesize backgroundView;
@synthesize backgroundViewState;

- (void)releaseViewObjects
{
    // can't release backgroundView here as it doesn't really belong to this controller
}

- (void)dealloc
{
    NSAssert(backgroundView == nil, @"unmatched attach/detachBackgroundView");
    
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
    [super viewDidLoad];
    
    self.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
                                  | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin
                                  | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
    
    [self.backgroundView removeFromSuperview];
    self.backgroundView.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    self.backgroundView.bounds = self.view.bounds;
    self.backgroundView.transform = CGAffineTransformIdentity;
    [self.view insertSubview:self.backgroundView atIndex:0];
}

- (void)viewDidUnload
{
    [self releaseViewObjects];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.storyInteractionController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.storyInteractionController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

#pragma mark - Background view

- (void)attachBackgroundView:(UIView *)view
{
    backgroundViewState.center = view.center;
    backgroundViewState.bounds = view.bounds;
    backgroundViewState.transform = view.transform;
    self.backgroundView = view;
}

- (UIView *)detachBackgroundView
{
    UIView *view = [self.backgroundView retain];
    self.backgroundView = nil;
    view.center = backgroundViewState.center;
    view.bounds = backgroundViewState.bounds;
    view.transform = backgroundViewState.transform;
    return [view autorelease];
}

@end
