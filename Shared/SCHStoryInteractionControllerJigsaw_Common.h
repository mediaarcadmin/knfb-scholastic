//
//  SCHStoryInteractionControllerJigsaw.h
//  Scholastic
//
//  Created by Neil Gall on 12/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionController.h"
#import "SCHStoryInteractionJigsawOrientation.h"

@class SCHStoryInteractionJigsawPaths;
@class SCHStoryInteractionJigsawPiece;
@class SCHStoryInteractionJigsawPreviewView;
@protocol SCHStoryInteractionJigsawPieceView;

@interface SCHStoryInteractionControllerJigsaw_Common : SCHStoryInteractionController {}

@property (nonatomic, retain) IBOutlet SCHStoryInteractionJigsawPreviewView *puzzleBackground;
@property (nonatomic, retain) SCHStoryInteractionJigsawPreviewView *puzzlePreviewView;
@property (nonatomic, assign) NSInteger numberOfPieces;
@property (nonatomic, retain) NSArray *jigsawPieces;
@property (nonatomic, retain) NSArray *jigsawPieceViews;

- (enum SCHStoryInteractionJigsawOrientation)currentJigsawOrientation;

- (void)setupChoosePuzzleView;

- (IBAction)choosePuzzle:(id)sender;

- (SCHStoryInteractionJigsawPreviewView *)makePuzzlePreviewView;

- (void)setupPieceViewsForOrientation:(enum SCHStoryInteractionJigsawOrientation)orientation
                           puzzleRect:(CGRect)puzzleRect;

- (void)animatePiecesToHomePositionsForOrientation:(enum SCHStoryInteractionJigsawOrientation)orientation;

- (void)repositionPiecesToSolutionPosition:(BOOL)moveToSolutionPosition withOrientation:(enum SCHStoryInteractionJigsawOrientation)orientation;

- (UIView<SCHStoryInteractionJigsawPieceView> *)newPieceView;

- (SCHStoryInteractionJigsawPiece *)pieceForPieceView:(id<SCHStoryInteractionJigsawPieceView>)pieceView;

- (void)checkForCompletion;

- (BOOL)puzzleIsInteractive;

@end
