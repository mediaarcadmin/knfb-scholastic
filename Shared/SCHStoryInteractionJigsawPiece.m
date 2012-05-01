//
//  SCHStoryInteractionJigsawPiece.m
//  Scholastic
//
//  Created by Neil Gall on 30/04/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHStoryInteractionJigsawPiece.h"

@implementation SCHStoryInteractionJigsawPiece {
    CGImageRef images[2];
    CGRect bounds[2];
    CGPoint solutionPositions[2];
}

@synthesize inCorrectPosition;

- (void)dealloc
{
    CGImageRelease(images[0]);
    CGImageRelease(images[1]);
    [super dealloc];
}

- (void)setImage:(CGImageRef)image forOrientation:(enum SCHStoryInteractionJigsawOrientation)orientation
{
    NSAssert(orientation == kSCHStoryInteractionJigsawOrientationPortrait || orientation == kSCHStoryInteractionJigsawOrientationLandscape, @"bad orientation");
    CGImageRelease(images[orientation]);
    images[orientation] = CGImageRetain(image);
}

- (void)setBounds:(CGRect)aBounds forOrientation:(enum SCHStoryInteractionJigsawOrientation)orientation
{
    NSAssert(orientation == kSCHStoryInteractionJigsawOrientationPortrait || orientation == kSCHStoryInteractionJigsawOrientationLandscape, @"bad orientation");
    bounds[orientation] = aBounds;
}

- (void)setSolutionPosition:(CGPoint)position forOrientation:(enum SCHStoryInteractionJigsawOrientation)orientation
{
    NSAssert(orientation == kSCHStoryInteractionJigsawOrientationPortrait || orientation == kSCHStoryInteractionJigsawOrientationLandscape, @"bad orientation");
    solutionPositions[orientation] = position;
}

- (CGImageRef)imageForOrientation:(enum SCHStoryInteractionJigsawOrientation)orientation
{
    NSAssert(orientation == kSCHStoryInteractionJigsawOrientationPortrait || orientation == kSCHStoryInteractionJigsawOrientationLandscape, @"bad orientation");
    return images[orientation];
}

- (CGRect)boundsForOrientation:(enum SCHStoryInteractionJigsawOrientation)orientation
{
    NSAssert(orientation == kSCHStoryInteractionJigsawOrientationPortrait || orientation == kSCHStoryInteractionJigsawOrientationLandscape, @"bad orientation");
    return bounds[orientation];
}

- (CGPoint)solutionPositionForOrientation:(enum SCHStoryInteractionJigsawOrientation)orientation
{
    NSAssert(orientation == kSCHStoryInteractionJigsawOrientationPortrait || orientation == kSCHStoryInteractionJigsawOrientationLandscape, @"bad orientation");
    return solutionPositions[orientation];
}

@end
