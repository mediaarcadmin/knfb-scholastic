//
//  SCHStoryInteractionControllerJigsaw.h
//  Scholastic
//
//  Created by Neil Gall on 12/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionController.h"
#import "SCHStoryInteractionDraggableView.h"

@class SCHStoryInteractionJigsawPreviewView;

@interface SCHStoryInteractionControllerJigsaw : SCHStoryInteractionController <SCHStoryInteractionDraggableViewDelegate> {}

@property (nonatomic, retain) IBOutletCollection(UIButton) NSArray *choosePuzzleButtons;
@property (nonatomic, retain) IBOutlet SCHStoryInteractionJigsawPreviewView *puzzleBackground;

- (IBAction)choosePuzzle:(id)sender;
- (IBAction)playAgain:(id)sender;

@end
