//
//  SCHStoryInteractionJigsawPiece.h
//  Scholastic
//
//  Created by Neil Gall on 30/04/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHStoryInteractionJigsawOrientation.h"

@interface SCHStoryInteractionJigsawPiece : NSObject

@property (nonatomic, assign, getter=isInCorrectPosition) BOOL inCorrectPosition;

- (CGImageRef)imageForOrientation:(enum SCHStoryInteractionJigsawOrientation)orientation;
- (CGRect)boundsForOrientation:(enum SCHStoryInteractionJigsawOrientation)orientation;
- (CGPoint)solutionPositionForOrientation:(enum SCHStoryInteractionJigsawOrientation)orientation;

- (void)setImage:(CGImageRef)image forOrientation:(enum SCHStoryInteractionJigsawOrientation)orientation;
- (void)setBounds:(CGRect)bounds forOrientation:(enum SCHStoryInteractionJigsawOrientation)orientation;
- (void)setSolutionPosition:(CGPoint)position forOrientation:(enum SCHStoryInteractionJigsawOrientation)orientation;

@end
