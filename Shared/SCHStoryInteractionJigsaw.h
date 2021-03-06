//
//  SCHStoryInteractionJigsaw.h
//  Scholastic
//
//  Created by Neil Gall on 08/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteraction.h"

@interface SCHStoryInteractionJigsaw : SCHStoryInteraction {}

- (NSString *)imagePathForEasyPuzzle;
- (NSString *)imagePathForMediumPuzzle;
- (NSString *)imagePathForHardPuzzle;

- (NSString *)audioPathForChooseYourPuzzle;
- (NSString *)audioPathForClickPuzzleToStart;
- (NSString *)audioPathForYouWon;

@end
