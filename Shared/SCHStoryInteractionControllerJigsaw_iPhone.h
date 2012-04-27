//
//  SCHStoryInteractionControllerJigsaw_iPhone.h
//  Scholastic
//
//  Created by Neil Gall on 15/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionControllerJigsaw_Common.h"

@class SCHStretchableImageButton;

@interface SCHStoryInteractionControllerJigsaw_iPhone : SCHStoryInteractionControllerJigsaw_Common {}

@property (nonatomic, retain) IBOutletCollection(UIView) NSArray *choosePuzzleButtons;
@property (nonatomic, retain) IBOutlet UIScrollView *puzzlePieceScroller;
@property (nonatomic, retain) IBOutlet UIImageView *puzzlePieceScrollerOverlay;

@end
