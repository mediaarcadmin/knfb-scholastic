//
//  SCHStoryInteractionJigsawPaths.h
//  Scholastic
//
//  Created by Neil Gall on 11/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCHStoryInteractionJigsawPaths : NSObject {}

- (id)initWithData:(NSData *)data;

// the number of paths loaded from the source data
- (NSInteger)numberOfPaths;

// return a new CGPathRef for the loaded path at the requested index
- (CGPathRef)pathAtIndex:(NSInteger)pathIndex;

// return a new CGImageRef containing an alpha-mask from the loaded path at
// the requested index.
- (CGImageRef)newMaskFromPathAtIndex:(NSInteger)pathIndex forPuzzleSize:(CGSize)size;

// bounds of a piece in the overall puzzle image
- (CGRect)boundsOfPieceAtIndex:(NSInteger)pathIndex forPuzzleSize:(CGSize)size;

@end
