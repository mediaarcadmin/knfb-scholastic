//
//  SCHStoryInteractionControllerPictureStarter.m
//  Scholastic
//
//  Created by Neil Gall on 22/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

#import "SCHStoryInteractionControllerPictureStarter.h"
#import "SCHStoryInteractionPictureStarter.h"
#import "SCHPictureStarterDrawingInstruction.h"
#import "SCHPictureStarterCanvas.h"
#import "SCHPictureStarterColorChooser.h"
#import "SCHPictureStarterSizeChooser.h"
#import "SCHPictureStarterStickerChooser.h"
#import "SCHPictureStarterStickers.h"
#import "SCHStretchableImageButton.h"
#import "UIColor+Scholastic.h"
#import "NSArray+ViewSorting.h"
#import "SCHStoryInteractionControllerDelegate.h"

enum SCHToolType {
    SCHToolTypeNone,
    SCHToolTypePaint,
    SCHToolTypeSticker
};

@interface SCHStoryInteractionControllerPictureStarter ()

@property (nonatomic, assign) BOOL inDrawingScreen;
@property (nonatomic, retain) SCHPictureStarterStickers *stickers;
@property (nonatomic, assign) NSInteger lastSelectedColour;
@property (nonatomic, assign) NSInteger lastSelectedSize;
@property (nonatomic, assign) NSInteger selectedStickerIndex;
@property (nonatomic, assign) NSInteger selectedStickerChooser;
@property (nonatomic, assign) enum SCHToolType toolType;
@property (nonatomic, assign) CGPoint lastDragPoint;
@property (nonatomic, retain) UIActionSheet *clearActionSheet;
@property (nonatomic, retain) UIActionSheet *doneActionSheet;
@property (nonatomic, assign) BOOL drawingChanged;

- (void)savePictureToPhotoLibrary:(void(^)(BOOL success))completionBlock;
- (void)loadCachedPictureFromDisk;
- (void)saveCachedPictureToDisk;
- (void)clearCachedPictureFromDisk;
- (BOOL)shouldAutoSaveWhenDone;
- (void)close;

@end

@implementation SCHStoryInteractionControllerPictureStarter

@synthesize inDrawingScreen;
@synthesize drawingCanvas;
@synthesize colorChooser;
@synthesize sizeChooser;
@synthesize stickerChoosersContainer;
@synthesize stickerChoosers;
@synthesize doneButton;
@synthesize clearButton;
@synthesize saveButton;
@synthesize savingLabel;
@synthesize savingBackground;
@synthesize colorShadowOverlayView;
@synthesize stickers;
@synthesize lastSelectedColour;
@synthesize lastSelectedSize;
@synthesize selectedStickerIndex;
@synthesize selectedStickerChooser;
@synthesize toolType;
@synthesize lastDragPoint;
@synthesize clearActionSheet;
@synthesize doneActionSheet;
@synthesize drawingChanged;

- (void)dealloc
{
    [colorShadowOverlayView release], colorShadowOverlayView = nil;
    [drawingCanvas release], drawingCanvas = nil;
    [colorChooser release], colorChooser = nil;
    [sizeChooser release], sizeChooser = nil;
    [stickerChoosersContainer release], stickerChoosersContainer = nil;
    [stickerChoosers release], stickerChoosers = nil;
    [doneButton release], doneButton = nil;
    [clearButton release], clearButton = nil;
    [saveButton release], saveButton = nil;
    [savingLabel release], savingLabel = nil;
    [savingBackground release], savingBackground = nil;
    [stickers release], stickers = nil;
    [clearActionSheet release], clearActionSheet = nil;
    [doneActionSheet release], doneActionSheet = nil;
    [colorShadowOverlayView release];
    [savingBackground release];
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

- (BOOL)shouldAutoSaveWhenDone
{
    return YES;
}

- (BOOL)shouldShowCloseButtonForViewAtIndex:(NSInteger)screenIndex
{
    return screenIndex == 0;
}

- (BOOL)shouldAnimateTransitionBetweenViews
{
    return NO;
}

- (void)setUserInteractionState:(BOOL)state
{
    self.drawingCanvas.userInteractionEnabled = state;
    self.colorChooser.userInteractionEnabled = state;
    self.sizeChooser.userInteractionEnabled = state;
    self.doneButton.userInteractionEnabled = state;
    self.clearButton.userInteractionEnabled = state;
    self.savingLabel.userInteractionEnabled = state;
    for (UIView *view in self.stickerChoosers) {
        view.userInteractionEnabled = state;
    }
}

- (void)storyInteractionDisableUserInteraction
{
    [self setUserInteractionState:NO];
}

- (void)storyInteractionEnableUserInteraction
{
    [self setUserInteractionState:YES];
}

- (void)setupViewAtIndex:(NSInteger)screenIndex
{
    if (!self.stickers) {
        // set this up early to avoid delays when the drawing screen first appears
        self.stickers = [[[SCHPictureStarterStickers alloc] initForChooserCount:[self.stickerChoosers count]] autorelease];
    }
    
    switch (screenIndex) {
        case 0 :
            self.inDrawingScreen = NO;
            [self setupOpeningScreen];
            [self enqueueAudioWithPath:[(SCHStoryInteractionPictureStarter *)self.storyInteraction audioPathForIntroduction] fromBundle:NO];
            break;
        case 1:
            self.inDrawingScreen = YES;
            [self setupDrawingScreen];
            break;
    }
}

#pragma mark - rotation

- (CGSize)iPadContentsSizeForViewAtIndex:(NSInteger)viewIndex forOrientation:(UIInterfaceOrientation)orientation
{
    if (inDrawingScreen) {
        if (UIInterfaceOrientationIsLandscape(orientation)) {
            return CGSizeMake(950, 700);
        } else {
            return CGSizeMake(692, 885);
        }
    } else {
        return [super iPadContentsSizeForViewAtIndex:viewIndex forOrientation:orientation];
    }
}

- (void)rotateToOrientation:(UIInterfaceOrientation)orientation
{
    if (inDrawingScreen) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            if (UIInterfaceOrientationIsLandscape(orientation)) {
                self.drawingCanvas.superview.frame = CGRectMake(10, 10, 692, 615);
//                self.savingLabel.frame = CGRectMake(250, 330, 310, 60);
                self.doneButton.frame = CGRectMake(53, 653, 210, 37);
                self.clearButton.frame = CGRectMake(271, 653, 210, 37);
                self.saveButton.frame = CGRectMake(489, 653, 210, 37);
                self.colorChooser.frame = CGRectMake(730, 10, 210, 222);
                self.sizeChooser.center = CGPointMake(835, 275);
                self.sizeChooser.bounds = CGRectMake(0, 0, 210, 50);
                self.sizeChooser.transform = CGAffineTransformIdentity;
                self.stickerChoosersContainer.frame = CGRectMake(730, 318, 210, 372);
            } else {
                self.drawingCanvas.superview.frame = CGRectMake(10, 20, 672, 615);
//                self.savingLabel.frame = CGRectMake(192, 298, 310, 60);
                self.stickerChoosersContainer.frame = CGRectMake(472, 643, 210, 222);
                self.colorChooser.frame = CGRectMake(180, 643, 210, 222);
                self.sizeChooser.center = CGPointMake(430, 754);
                self.sizeChooser.bounds = CGRectMake(0, 0, 222, 50);
                self.sizeChooser.transform = CGAffineTransformMakeRotation(M_PI_2);
                self.doneButton.frame = CGRectMake(10, 735, 155, 37);
                self.clearButton.frame = CGRectMake(10, 783, 155, 37);
                self.saveButton.frame = CGRectMake(10, 828, 155, 37);
            }
        } else {
            if (UIInterfaceOrientationIsLandscape(orientation)) {
                self.drawingCanvas.superview.frame = CGRectMake(10, 10, 339, 245);
                self.doneButton.frame = CGRectMake(21, 263, 100, 37);
                self.clearButton.frame = CGRectMake(129, 263, 100, 37);
                self.saveButton.frame = CGRectMake(237, 263, 100, 37);
                self.colorChooser.superview.frame = CGRectMake(357, 10, 103, 110);
                self.colorShadowOverlayView.frame = CGRectMake(357, 10, 103, 110);
                self.stickerChoosersContainer.frame = CGRectMake(357, 127, 103, 173);
            } else {
                self.drawingCanvas.superview.frame = CGRectMake(10, 10, 295, 269);
//                self.savingLabel.frame = CGRectMake(25, 115, 260, 60);
                self.colorChooser.superview.frame = CGRectMake(197, 287, 103, 173);
                self.colorShadowOverlayView.frame = CGRectMake(197, 287, 103, 173);
                self.stickerChoosersContainer.frame = CGRectMake(87, 287, 103, 173);
                self.doneButton.frame = CGRectMake(10, 333, 68, 37);
                self.clearButton.frame = CGRectMake(10, 378, 68, 37);
                self.saveButton.frame = CGRectMake(10, 423, 68, 37);
            }
            
            UIScrollView *scrollView = (UIScrollView *)self.colorChooser.superview;
            scrollView.contentSize = self.colorChooser.bounds.size;
            [self applyRoundRectStyle:scrollView];
        }
    }
}

#pragma mark - subclass overrides

- (void)setupOpeningScreen
{}

- (UIImage *)drawingBackgroundImage
{
    return nil;
}

- (NSString *)pictureStarterSavedImageName
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
    [self applyRoundRectStyle:self.drawingCanvas.superview];
    [self applyRoundRectStyle:self.sizeChooser];
    [self applyRoundRectStyle:self.savingBackground];
    self.savingBackground.alpha = 0;
    
    [self.drawingCanvas setBackgroundImage:[self drawingBackgroundImage]];
    self.drawingCanvas.delegate = self;
    
    self.stickerChoosersContainer.layer.cornerRadius = 14;
    self.stickerChoosers = [self.stickerChoosers viewsSortedHorizontally];
    NSInteger index = 0;
    for (SCHPictureStarterStickerChooser *chooser in self.stickerChoosers) {
        [chooser setChooserIndex:index++];
        [chooser setStickerDataSource:self.stickers];
        [chooser setStickerDelegate:self];
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UIImageView *stickerChooserOverlay = (UIImageView *)[self.stickerChoosersContainer viewWithTag:123];
        UIImage *stretchable = [stickerChooserOverlay.image stretchableImageWithLeftCapWidth:0 topCapHeight:133];
        stickerChooserOverlay.image = stretchable;
    }
    
    self.selectedStickerChooser = NSNotFound;
    self.selectedStickerIndex = NSNotFound;
    self.toolType = SCHToolTypePaint;

    self.lastSelectedColour = 1;
    self.colorChooser.selectedColorIndex = self.lastSelectedColour;

    // TODO uses indices rather than actual values for size
    self.lastSelectedSize = 8;
    self.sizeChooser.selectedSize = self.lastSelectedSize;
    
    // color chooser is in a scroller on iPhone
    if ([self.colorChooser.superview isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)self.colorChooser.superview;
        scrollView.contentSize = self.colorChooser.bounds.size;
        [self applyRoundRectStyle:scrollView];
    } else {
        [self applyRoundRectStyle:self.colorChooser];
    }
    
    [self loadCachedPictureFromDisk];
    
    self.drawingChanged = NO;
}

- (void)close
{
    // do not go to finished state, as this will cause progress to advance on any SI on the current reading page
    self.controllerState = SCHStoryInteractionControllerStateInteractionInProgress;
    [self removeFromHostView];
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
    [self storyInteractionDisableUserInteraction];
    
    [self savePictureToPhotoLibrary:^(BOOL success) {
        [self storyInteractionEnableUserInteraction];
        if (success) {
            self.drawingChanged = NO;
        }
    }];
}

- (void)clearButtonPressed:(id)sender
{
    [self enqueueAudioWithPath:[(SCHStoryInteractionPictureStarter *)self.storyInteraction audioPathForClearThisPicture]
                    fromBundle:NO];

    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Do you want to clear this picture and start again?", @"Picture starter clear prompt")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                         destructiveButtonTitle:NSLocalizedString(@"Clear", @"Clear")
                                              otherButtonTitles:nil];
    sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [sheet showFromRect:self.clearButton.frame inView:self.contentsView animated:YES];
    } else {
        [sheet showInView:self.contentsView];
    }
    self.clearActionSheet = sheet;
    [sheet release];
}

- (void)doneButtonPressed:(id)sender
{
    if (!self.drawingChanged) {
        [self close];
    } else {
        
        if ([self shouldAutoSaveWhenDone]) {
            [self savePictureToPhotoLibrary:^(BOOL success) {
                [self close];
            }];
        } else {
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Do you want to save this picture?", @"picture starter save prompt")
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                 destructiveButtonTitle:NSLocalizedString(@"Don't Save", @"Don't Save")
                                                      otherButtonTitles:NSLocalizedString(@"Save", @"Save"), nil];
            sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                [sheet showFromRect:self.doneButton.frame inView:self.contentsView animated:YES];
            } else {
                [sheet showInView:self.contentsView];
            }
            self.doneActionSheet = sheet;
            [sheet release];
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self cancelQueuedAudioExecutingSynchronizedBlocksBefore:^{
        if (actionSheet == self.clearActionSheet) {
            if (buttonIndex == actionSheet.destructiveButtonIndex) {
                [self clearCachedPictureFromDisk];
                [self.drawingCanvas clear];
                self.drawingChanged = NO;
                self.clearButton.enabled = NO;
            }
            self.clearActionSheet = nil;
        }
        if (actionSheet == self.doneActionSheet) {
            if (buttonIndex == actionSheet.destructiveButtonIndex) {
                [self close];
            }
            else if (buttonIndex != actionSheet.cancelButtonIndex) {
                [self savePictureToPhotoLibrary:^(BOOL success) {
                    if (success) {
                        [self close];
                    }
                }];
            }
            self.doneActionSheet = nil;
        }
    }];
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
    [self cancelQueuedAudioExecutingSynchronizedBlocksBefore:^{
        if (actionSheet == self.clearActionSheet) {
            self.clearActionSheet = nil;
        }
        if (actionSheet == self.doneActionSheet) {
            self.doneActionSheet = nil;
        }
    }];
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

- (void)canvas:(SCHPictureStarterCanvas *)canvas didCommitDrawingInstruction:(id<SCHPictureStarterDrawingInstruction>)drawingInstruction
{
    self.drawingChanged = YES;
    self.clearButton.enabled = YES;
}

#pragma mark - Load/Save/Delete work in progress from local storage

- (void)loadCachedPictureFromDisk
{
    if (!self.delegate) {
        return;
    }
    
    NSString *cacheDir = [self.delegate storyInteractionCacheDirectory];
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@.png", cacheDir, [self pictureStarterSavedImageName]];

    UIImage *previousImage = [UIImage imageWithContentsOfFile:fullPath];
    
    if (previousImage) {
        [self.drawingCanvas setDrawnImage:previousImage];
        self.clearButton.enabled = YES;
    }
}

- (void)saveCachedPictureToDisk
{
    if (!self.delegate) {
        return;
    }
    
    NSString *cacheDir = [self.delegate storyInteractionCacheDirectory];
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@.png", cacheDir, [self pictureStarterSavedImageName]];
    
    NSData *imageData = UIImagePNGRepresentation([UIImage imageWithCGImage:[self.drawingCanvas image]]);
    [imageData writeToFile:fullPath atomically:YES];
}

- (void)clearCachedPictureFromDisk
{
    NSString *cacheDir = [self.delegate storyInteractionCacheDirectory];
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@.png", cacheDir, [self pictureStarterSavedImageName]];
    
    NSFileManager *localFileManager = [[[NSFileManager alloc] init] autorelease];
    
    NSError *error = nil;
    
    [localFileManager removeItemAtPath:fullPath error:&error];
    
    if (error) {
        NSLog(@"Error deleting cached SI image: %@", [error localizedDescription]);
    }

}

#pragma mark - Save to photo library

- (void)savePictureToPhotoLibrary:(void (^)(BOOL))completionBlock
{
    self.savingLabel.frame = CGRectIntegral(self.savingLabel.frame);
    self.savingBackground.frame = CGRectIntegral(self.savingBackground.frame);

    self.savingLabel.text = NSLocalizedString(@"Saving...", @"");
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.savingBackground.alpha = 1;
                     }];
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeImageToSavedPhotosAlbum:[self.drawingCanvas image]
                              orientation:ALAssetOrientationUp
                          completionBlock:^(NSURL *assetURL, NSError *error) {
                              if (error) {
                                  self.savingBackground.alpha = 0;
                                  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                                                  message:[error localizedDescription]
                                                                                 delegate:nil
                                                                        cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                                        otherButtonTitles:nil];
                                  [alert show];
                                  [alert release];
                                  completionBlock(NO);
                              } else {
                                  self.savingLabel.text = NSLocalizedString(@"Your picture has been saved to your photos.", @"");
                                  [UIView animateWithDuration:0.25
                                                        delay:1.5
                                                      options:UIViewAnimationOptionAllowUserInteraction
                                                   animations:^{
                                                       self.savingBackground.alpha = 0;
                                                   }
                                                   completion:^(BOOL finished) {
                                                       completionBlock(YES);
                                                   }];
                                  
                                  [self saveCachedPictureToDisk];
                                  
                              }
                          }];
    [library release];
}

@end
