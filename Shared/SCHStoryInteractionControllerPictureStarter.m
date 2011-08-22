//
//  SCHStoryInteractionControllerPictureStarter.m
//  Scholastic
//
//  Created by Neil Gall on 22/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionControllerPictureStarter.h"
#import "SCHPictureStarterCanvas.h"
#import "SCHPictureStarterColorChooser.h"
#import "SCHPictureStarterSizeChooser.h"
#import "SCHPictureStarterStampChooser.h"
#import "UIColor+Scholastic.h"

@interface SCHStoryInteractionControllerPictureStarter ()
- (void)setupDrawingScreen;
@end

@implementation SCHStoryInteractionControllerPictureStarter

@synthesize canvas;
@synthesize colorChooser;
@synthesize sizeChooser;
@synthesize stampChoosers;
@synthesize stampChooserOverlay;
@synthesize doneButton;
@synthesize clearButton;
@synthesize saveButton;

- (void)dealloc
{
    [canvas release], canvas = nil;
    [colorChooser release], colorChooser = nil;
    [sizeChooser release], sizeChooser = nil;
    [stampChoosers release], stampChoosers = nil;
    [stampChooserOverlay release], stampChooserOverlay = nil;
    [doneButton release], doneButton = nil;
    [clearButton release], clearButton = nil;
    [saveButton release], saveButton = nil;
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

- (BOOL)shouldShowCloseButton
{
    return NO;
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
            [self setupOpeningScreen];
            break;
        case 1:
            [self setupDrawingScreen];
            break;
    }
}

#pragma mark - subclass overrides

- (void)setupOpeningScreen
{}

- (UIImage *)drawingBackgroundImage
{
    return nil;
}

#pragma mark - Drawing screen

- (void)applyRoundRectStyle:(UIView *)view
{
    view.layer.cornerRadius = 12;
    view.layer.borderWidth = 3;
    view.layer.borderColor = [[UIColor colorWithRed:0.855 green:0.855 blue:0.855 alpha:1.0f] CGColor];
    view.layer.masksToBounds = YES;
}

- (void)setupDrawingScreen
{
    self.contentsView.backgroundColor = [UIColor clearColor];
    [self applyRoundRectStyle:self.canvas];
    [self applyRoundRectStyle:self.colorChooser];
    [self applyRoundRectStyle:self.sizeChooser];

    self.canvas.backgroundImage = [self drawingBackgroundImage];
}

#pragma mark - Actions

- (void)saveButtonPressed:(id)sender
{
}

- (void)clearButtonPressed:(id)sender
{
}

- (void)doneButtonPressed:(id)sender
{
    self.controllerState = SCHStoryInteractionControllerStateInteractionFinishedSuccessfully;
    [self removeFromHostView];
}

- (void)colorSelected:(id)sender
{
}

- (void)sizeSelected:(id)sender
{
}

- (void)eraserSelected:(id)sender
{
}

- (void)stampSelected:(id)sender
{
}

@end
