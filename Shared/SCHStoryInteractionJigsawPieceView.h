//
//  SCHStoryInteractionJigsawPieceView.h
//  Scholastic
//
//  Created by Neil Gall on 15/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SCHStoryInteractionJigsawPieceView <NSObject>

@property (nonatomic, assign) CGImageRef image;
@property (nonatomic, assign) CGPoint solutionPosition;
@property (nonatomic, assign) CGRect puzzleFrame;

- (CGPoint)correctPosition;
- (BOOL)isInCorrectPosition;
- (BOOL)isLockedInCorrectPosition;

@end
