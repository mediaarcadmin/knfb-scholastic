//
//  SCHStoryInteractionControllerJigsaw.h
//  Scholastic
//
//  Created by Neil Gall on 12/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionController.h"

@class SCHStoryInteractionJigsawPreviewView;
@class SCHStoryInteractionJigsawPaths;
@protocol SCHStoryInteractionJigsawPieceView;

@interface SCHStoryInteractionControllerJigsaw_Common : SCHStoryInteractionController {}

@property (nonatomic, retain) IBOutlet SCHStoryInteractionJigsawPreviewView *puzzleBackground;
@property (nonatomic, retain) SCHStoryInteractionJigsawPreviewView *puzzlePreviewView;
@property (nonatomic, assign) NSInteger numberOfPieces;
@property (nonatomic, retain) NSArray *jigsawPieceViews;

- (void)setupChoosePuzzleView;

- (IBAction)choosePuzzle:(id)sender;

- (UIView<SCHStoryInteractionJigsawPieceView> *)newPieceViewForImage:(CGImageRef)image;
- (CGRect)puzzlePreviewFrame;
- (void)setupPuzzlePiecesForInteractionFromPreview:(SCHStoryInteractionJigsawPreviewView *)preview;
- (void)checkForCompletion;

- (BOOL)puzzleIsInteractive;

@end
