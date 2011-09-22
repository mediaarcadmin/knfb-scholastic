//
//  SCHStoryInteractionControllerPictureStarter.h
//  Scholastic
//
//  Created by Neil Gall on 22/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionController.h"
#import "SCHPictureStarterStickerChooserDelegate.h"
#import "SCHPictureStarterCanvasDelegate.h"

@class SCHPictureStarterCanvas;
@class SCHPictureStarterColorChooser;
@class SCHPictureStarterSizeChooser;
@class SCHPictureStarterStickerChooser;
@class SCHStretchableImageButton;

@interface SCHStoryInteractionControllerPictureStarter : SCHStoryInteractionController <SCHPictureStarterStickerChooserDelegate, SCHPictureStarterCanvasDelegate, UIActionSheetDelegate>

@property (nonatomic, retain) IBOutlet SCHPictureStarterCanvas *drawingCanvas;
@property (nonatomic, retain) IBOutlet SCHPictureStarterColorChooser *colorChooser;
@property (nonatomic, retain) IBOutlet SCHPictureStarterSizeChooser *sizeChooser;
@property (nonatomic, retain) IBOutletCollection(SCHPictureStarterStickerChooser) NSArray *stickerChoosers;
@property (nonatomic, retain) IBOutlet SCHStretchableImageButton *doneButton;
@property (nonatomic, retain) IBOutlet SCHStretchableImageButton *clearButton;
@property (nonatomic, retain) IBOutlet SCHStretchableImageButton *saveButton;
@property (nonatomic, retain) IBOutlet UILabel *savingLabel;

- (IBAction)colorSelected:(id)sender;
- (IBAction)sizeSelected:(id)sender;
- (IBAction)doneButtonPressed:(id)sender;
- (IBAction)clearButtonPressed:(id)sender;
- (IBAction)saveButtonPressed:(id)sender;

// override in subclasses
- (void)setupOpeningScreen;
- (void)setupDrawingScreen;
- (UIImage *)drawingBackgroundImage;

@end
