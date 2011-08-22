//
//  SCHStoryInteractionControllerPictureStarter.m
//  Scholastic
//
//  Created by Neil Gall on 19/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionControllerPictureStarter.h"
#import "SCHStoryInteractionPictureStarter.h"
#import "NSArray+ViewSorting.h"

@interface SCHStoryInteractionControllerPictureStarter ()

@property (nonatomic, assign) NSInteger chosenBackgroundIndex;

- (void)setupChooseBackgroundView;

@end

@implementation SCHStoryInteractionControllerPictureStarter

@synthesize backgroundChooserButtons;
@synthesize chosenBackgroundIndex;

- (void)dealloc
{
    [backgroundChooserButtons release], backgroundChooserButtons = nil;
    [super dealloc];
}

- (SCHFrameStyle)frameStyleForViewAtIndex:(NSInteger)viewIndex
{
    switch (viewIndex) {
        case 0:
            return SCHStoryInteractionTitle;
        default:
            return SCHStoryInteractionNoTitle;
    }
}

- (void)storyInteractionDisableUserInteraction
{
}

- (void)storyInteractionEnableUserInteraction
{
}

- (void)setupViewAtIndex:(NSInteger)screenIndex
{
    switch (screenIndex) {
        case 0 :
            [self setupChooseBackgroundView];
            break;
    }
}

- (void)setupChooseBackgroundView
{
    SCHStoryInteractionPictureStarter *pictureStarter = (SCHStoryInteractionPictureStarter *)self.storyInteraction;
    for (UIButton *button in self.backgroundChooserButtons) {
        NSString *path = [pictureStarter imagePathAtIndex:button.tag];
        [button setBackgroundImage:[self imageAtPath:path] forState:UIControlStateNormal];
    }
}

- (void)chooseBackground:(UIButton *)sender
{
    self.chosenBackgroundIndex = sender.tag;
    [self presentNextView];
}

@end
