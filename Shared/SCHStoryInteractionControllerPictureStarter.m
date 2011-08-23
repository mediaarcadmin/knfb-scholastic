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
#import "SCHPictureStarterStickerChooser.h"
#import "SCHPictureStarterStickers.h"
#import "UIColor+Scholastic.h"
#import "NSArray+ViewSorting.h"

@interface SCHStoryInteractionControllerPictureStarter ()

@property (nonatomic, retain) SCHPictureStarterStickers *stickers;
@property (nonatomic, assign) NSInteger lastSelectedColour;
@property (nonatomic, assign) NSInteger lastSelectedSize;

- (void)setupDrawingScreen;

@end

@implementation SCHStoryInteractionControllerPictureStarter

@synthesize canvas;
@synthesize colorChooser;
@synthesize sizeChooser;
@synthesize stickerChoosers;
@synthesize doneButton;
@synthesize clearButton;
@synthesize saveButton;
@synthesize stickers;
@synthesize lastSelectedColour;
@synthesize lastSelectedSize;

- (void)dealloc
{
    [canvas release], canvas = nil;
    [colorChooser release], colorChooser = nil;
    [sizeChooser release], sizeChooser = nil;
    [stickerChoosers release], stickerChoosers = nil;
    [doneButton release], doneButton = nil;
    [clearButton release], clearButton = nil;
    [saveButton release], saveButton = nil;
    [stickers release], stickers = nil;
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
    
    self.stickerChoosers = [self.stickerChoosers viewsSortedHorizontally];
    self.stickers = [[[SCHPictureStarterStickers alloc] init] autorelease];
    self.stickers.numberOfChoosers = [self.stickerChoosers count];
    NSInteger index = 0;
    for (SCHPictureStarterStickerChooser *chooser in self.stickerChoosers) {
        [chooser setChooserIndex:index++];
        [chooser setStickerDataSource:self.stickers];
        [chooser setStickerDelegate:self];
    }
    
    self.lastSelectedColour = NSNotFound;
    self.lastSelectedSize = NSNotFound;
}

#pragma mark - Sticker chooser delegate

- (void)stickerChooser:(NSInteger)chooserIndex choseImageAtIndex:(NSInteger)imageIndex
{
    for (SCHPictureStarterStickerChooser *chooser in self.stickerChoosers) {
        if (chooser.chooserIndex != chooserIndex) {
            [chooser clearSelection];
        }
    }
    [self.colorChooser clearSelection];
    [self.sizeChooser clearSelection];
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
    if (self.colorChooser.selectedColor != nil) {
        [self.stickerChoosers makeObjectsPerformSelector:@selector(clearSelection)];
        self.lastSelectedColour = self.colorChooser.selectedColorIndex;
        self.sizeChooser.selectedSize = self.lastSelectedSize;
    }
}

- (void)sizeSelected:(id)sender
{
    if (self.sizeChooser.selectedSize != NSNotFound) {
        [self.stickerChoosers makeObjectsPerformSelector:@selector(clearSelection)];
        self.lastSelectedSize = self.sizeChooser.selectedSize;
        self.colorChooser.selectedColorIndex = self.lastSelectedColour;
    }
}

- (void)eraserSelected:(id)sender
{
}

- (void)stampSelected:(id)sender
{
}

@end
