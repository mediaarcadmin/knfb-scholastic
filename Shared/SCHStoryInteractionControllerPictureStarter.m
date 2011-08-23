//
//  SCHStoryInteractionControllerPictureStarter.m
//  Scholastic
//
//  Created by Neil Gall on 22/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionControllerPictureStarter.h"
#import "SCHPictureStarterDrawingInstruction.h"
#import "SCHPictureStarterCanvas.h"
#import "SCHPictureStarterColorChooser.h"
#import "SCHPictureStarterSizeChooser.h"
#import "SCHPictureStarterStickerChooser.h"
#import "SCHPictureStarterStickers.h"
#import "UIColor+Scholastic.h"
#import "NSArray+ViewSorting.h"

enum SCHToolType {
    SCHToolTypeNone,
    SCHToolTypePaint,
    SCHToolTypeSticker
};

@interface SCHStoryInteractionControllerPictureStarter ()

@property (nonatomic, retain) SCHPictureStarterStickers *stickers;
@property (nonatomic, assign) NSInteger lastSelectedColour;
@property (nonatomic, assign) NSInteger lastSelectedSize;
@property (nonatomic, assign) NSInteger selectedStickerIndex;
@property (nonatomic, assign) NSInteger selectedStickerChooser;
@property (nonatomic, assign) enum SCHToolType toolType;
@property (nonatomic, assign) CGPoint lastDragPoint;

- (void)setupDrawingScreen;

@end

@implementation SCHStoryInteractionControllerPictureStarter

@synthesize drawingCanvas;
@synthesize colorChooser;
@synthesize sizeChooser;
@synthesize stickerChoosers;
@synthesize doneButton;
@synthesize clearButton;
@synthesize saveButton;
@synthesize stickers;
@synthesize lastSelectedColour;
@synthesize lastSelectedSize;
@synthesize selectedStickerIndex;
@synthesize selectedStickerChooser;
@synthesize toolType;
@synthesize lastDragPoint;

- (void)dealloc
{
    [drawingCanvas release], drawingCanvas = nil;
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
    [self applyRoundRectStyle:self.drawingCanvas];
    [self applyRoundRectStyle:self.colorChooser];
    [self applyRoundRectStyle:self.sizeChooser];

    [self.drawingCanvas setBackgroundImage:[self drawingBackgroundImage]];
    self.drawingCanvas.delegate = self;
    
    self.stickerChoosers = [self.stickerChoosers viewsSortedHorizontally];
    self.stickers = [[[SCHPictureStarterStickers alloc] init] autorelease];
    self.stickers.numberOfChoosers = [self.stickerChoosers count];
    NSInteger index = 0;
    for (SCHPictureStarterStickerChooser *chooser in self.stickerChoosers) {
        [chooser setChooserIndex:index++];
        [chooser setStickerDataSource:self.stickers];
        [chooser setStickerDelegate:self];
    }
    
    self.selectedStickerChooser = NSNotFound;
    self.selectedStickerIndex = NSNotFound;
    self.toolType = SCHToolTypePaint;

    self.lastSelectedColour = 1;
    self.colorChooser.selectedColorIndex = self.lastSelectedColour;

    // TODO uses indices rather than actual values for size
    self.lastSelectedSize = 8;
    self.sizeChooser.selectedSize = self.lastSelectedSize;
}

#pragma mark - Sticker chooser delegate

- (void)stickerChooser:(NSInteger)chooserIndex choseImageAtIndex:(NSInteger)imageIndex
{
    self.selectedStickerIndex = imageIndex;
    self.selectedStickerChooser = chooserIndex;
    self.toolType = SCHToolTypeSticker;
    
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
    [self.drawingCanvas clear];
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
        self.toolType = SCHToolTypePaint;
    }
}

- (void)sizeSelected:(id)sender
{
    if (self.sizeChooser.selectedSize != NSNotFound) {
        [self.stickerChoosers makeObjectsPerformSelector:@selector(clearSelection)];
        self.lastSelectedSize = self.sizeChooser.selectedSize;
        self.colorChooser.selectedColorIndex = self.lastSelectedColour;
        self.toolType = SCHToolTypePaint;
    }
}

#pragma mark - Canvas delegate

- (id<SCHPictureStarterDrawingInstruction>)drawingInstruction
{
    switch (self.toolType) {
        case SCHToolTypePaint: {
            if ([self.colorChooser selectionIsEraser]) {
                SCHPictureStarterEraseDrawingInstruction *erase = [[SCHPictureStarterEraseDrawingInstruction alloc] init];
                erase.size = [self.sizeChooser selectedSize];
                erase.color = [UIColor whiteColor];
                return [erase autorelease];
            } else {
                SCHPictureStarterLineDrawingInstruction *draw = [[SCHPictureStarterLineDrawingInstruction alloc] init];
                draw.color = [self.colorChooser selectedColor];
                draw.size = [self.sizeChooser selectedSize];
                return [draw autorelease];
            }
        }
        case SCHToolTypeSticker: {
            SCHPictureStarterStickerDrawingInstruction *sdi = [[SCHPictureStarterStickerDrawingInstruction alloc] init];
            sdi.sticker = [self.stickers imageAtIndex:self.selectedStickerIndex forChooserIndex:self.selectedStickerChooser];
            return [sdi autorelease];
        }
        default: {
            return nil;
        }
    }
}

@end
