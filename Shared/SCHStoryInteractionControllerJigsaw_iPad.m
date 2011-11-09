//
//  SCHStoryInteractionControllerJigsaw_iPad.m
//  Scholastic
//
//  Created by Neil Gall on 15/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionControllerJigsaw_iPad.h"
#import "SCHStoryInteractionJigsawPieceView_iPad.h"
#import "SCHStoryInteractionJigsawPreviewView.h"
#import "NSArray+Shuffling.h"

enum {
    kPieceMargin = 5,
};

@implementation SCHStoryInteractionControllerJigsaw_iPad

- (CGSize)iPadContentsSizeForViewAtIndex:(NSInteger)viewIndex forOrientation:(UIInterfaceOrientation)orientation
{
    switch (viewIndex) {
        case 0:
            return CGSizeMake(UIInterfaceOrientationIsLandscape(orientation) ? 798 : 690, 342);
        default:
            return UIInterfaceOrientationIsLandscape(orientation) ? CGSizeMake(900, 680) : CGSizeMake(690, 900);
    }
}

- (CGRect)puzzlePreviewFrame
{
    return CGRectInset(self.contentsView.bounds, 30, 10);
}

- (UIView<SCHStoryInteractionJigsawPieceView> *)newPieceViewForImage:(CGImageRef)image
{
    SCHStoryInteractionJigsawPieceView_iPad *pieceView = [[SCHStoryInteractionJigsawPieceView_iPad alloc] initWithFrame:CGRectZero];
    pieceView.image = image;
    return pieceView;
}

- (NSArray *)homePositionsAroundPuzzleForOrientation:(UIInterfaceOrientation)orientation
{
    const CGRect bounds = self.contentsView.bounds;
    const CGRect puzzle = self.puzzleBackground.frame;
    const BOOL landscape = UIInterfaceOrientationIsLandscape(orientation);
    
    NSMutableArray *positions = [NSMutableArray arrayWithCapacity:6];
    void (^add)(CGFloat,CGFloat) = ^(CGFloat x, CGFloat y) {
        [positions addObject:[NSValue valueWithCGPoint:CGPointMake(floorf(x), floorf(y))]];
    };
    
    NSInteger piecesOnSides = (landscape ? self.numberOfPieces/3 : 0);
    for (NSInteger i = 0; i < piecesOnSides; ++i) {
        const CGFloat y = CGRectGetHeight(bounds)/(piecesOnSides+1)*(i+1);
        add(CGRectGetMinX(bounds)+CGRectGetMinX(puzzle)/2, y);
        add(CGRectGetMaxX(bounds)-CGRectGetMinX(puzzle)/2, y);
    }

    if (self.numberOfPieces == 20 && !landscape) {
        for (NSInteger i = 0; i < 5; ++i) {
            const CGFloat x = CGRectGetMinX(bounds)+CGRectGetWidth(bounds)/6*(i+1);
            const CGFloat y1 = CGRectGetMinY(puzzle)/3;
            const CGFloat y2 = CGRectGetMinY(puzzle)*2/3;
            add(x, CGRectGetMinY(bounds)+y1);
            add(x, CGRectGetMinY(bounds)+y2);
            add(x, CGRectGetMaxY(bounds)-y1);
            add(x, CGRectGetMaxY(bounds)-y2);
        }
    } else {
        NSInteger piecesOnTopAndBottom = self.numberOfPieces/2-piecesOnSides;
        for (NSInteger i = 0; i < piecesOnTopAndBottom; ++i) {
            const CGFloat x = CGRectGetMinX(bounds)+CGRectGetWidth(bounds)/(piecesOnTopAndBottom+1)*(i+1);
            add(x, CGRectGetMinY(bounds)+CGRectGetMinY(puzzle)/2);
            add(x, CGRectGetMaxY(bounds)-CGRectGetMinY(puzzle)/2);
        }
    }
    
    NSAssert(self.numberOfPieces == [positions count], @"wrong number of positions");
    return [positions shuffled];
}

- (void)setupPuzzlePiecesForInteractionFromPreview:(SCHStoryInteractionJigsawPreviewView *)preview;
{
    CGRect puzzleBounds = [preview puzzleBounds];
    CGAffineTransform puzzleTransform = CGAffineTransformMakeScale(CGRectGetWidth(puzzleBounds)/CGRectGetWidth(self.puzzleBackground.bounds),
                                                                   CGRectGetHeight(puzzleBounds)/CGRectGetHeight(self.puzzleBackground.bounds));

    NSArray *homePositions = [self homePositionsAroundPuzzleForOrientation:self.interfaceOrientation];
    NSInteger pieceIndex = 0;
    for (SCHStoryInteractionJigsawPieceView_iPad *piece in self.jigsawPieceViews) {
        CGPoint center = piece.center;
        NSLog(@"piece position = %@", NSStringFromCGPoint(center));
        piece.solutionPosition = center;
        piece.center = CGPointMake(center.x+CGRectGetMinX(self.puzzleBackground.frame), center.y+CGRectGetMinY(self.puzzleBackground.frame));
        piece.puzzleFrame = self.puzzleBackground.frame;
        piece.homePosition = [[homePositions objectAtIndex:pieceIndex] CGPointValue];
        piece.transform = puzzleTransform;
        piece.dragTransform = CGAffineTransformIdentity;
        piece.snappedTransform = CGAffineTransformIdentity;
        piece.delegate = self;
        [self.contentsView addSubview:piece];
        pieceIndex++;
    }
    
    [self enqueueAudioWithPath:@"sfx_breakpuzzle.mp3" fromBundle:YES];
    
    // scale the pieces down to fit in the margins around the puzzle background
    CGFloat scale;
    switch (self.numberOfPieces) {
        case 6: scale = 0.28; break;
        case 12: scale = 0.33; break;
        case 20: scale = 0.33; break;
    }
    CGAffineTransform pieceTransform = CGAffineTransformMakeScale(scale, scale);
    [self.puzzleBackground setTransform:puzzleTransform];
    
    // spread the pieces around the puzzle background
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationCurveEaseInOut
                     animations:^{
                         self.puzzleBackground.transform = CGAffineTransformIdentity;
                         for (SCHStoryInteractionJigsawPieceView_iPad *piece in self.jigsawPieceViews) {
                             [piece moveToHomePosition];
                             [piece setTransform:pieceTransform];
                         }
                     }
                     completion:nil];
}

- (void)rotateToOrientation:(UIInterfaceOrientation)orientation
{
    if (![self puzzleIsInteractive]) {
        return;
    }
    
    NSArray *homePositions = [self homePositionsAroundPuzzleForOrientation:orientation];
 
    NSInteger pieceIndex = 0;
    for (SCHStoryInteractionJigsawPieceView_iPad *piece in self.jigsawPieceViews) {
        piece.puzzleFrame = self.puzzleBackground.frame;
        piece.homePosition = [[homePositions objectAtIndex:pieceIndex] CGPointValue];
        if ([piece isLockedInCorrectPosition]) {
            piece.center = [piece correctPosition];
        } else {
            piece.center = piece.homePosition;
        }
        pieceIndex++;
    }
}

#pragma mark - draggable delegate

- (void)draggableViewDidStartDrag:(SCHStoryInteractionDraggableView *)draggableView
{
    [self enqueueAudioWithPath:@"sfx_pickup.mp3" fromBundle:YES];
}

- (BOOL)draggableView:(SCHStoryInteractionDraggableView *)draggableView shouldSnapFromPosition:(CGPoint)position toPosition:(CGPoint *)snapPosition
{
    SCHStoryInteractionJigsawPieceView_iPad *piece = (SCHStoryInteractionJigsawPieceView_iPad *)draggableView;
    if ([piece isInCorrectPosition]) {
        *snapPosition = [piece correctPosition];
        return YES;
    }
    return NO;
}

- (void)draggableView:(SCHStoryInteractionDraggableView *)draggableView didMoveToPosition:(CGPoint)position
{
    SCHStoryInteractionJigsawPieceView_iPad *piece = (SCHStoryInteractionJigsawPieceView_iPad *)draggableView;
    
    // ensure we only play one drop sound at a time
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(playDropSoundForPiece:) withObject:piece afterDelay:0.2];
    
    if ([piece isInCorrectPosition]) {
        [piece setUserInteractionEnabled:NO];
    } else {
        [piece moveToHomePosition];
    }
}

- (void)playDropSoundForPiece:(SCHStoryInteractionJigsawPieceView_iPad *)piece
{
    if ([piece isInCorrectPosition]) {
        [self enqueueAudioWithPath:@"sfx_dropOK.mp3"
                        fromBundle:YES
                        startDelay:0
            synchronizedStartBlock:nil
              synchronizedEndBlock:^{
                  [self checkForCompletion];
              }];
    } else {
        [self enqueueAudioWithPath:@"sfx_dropNo.mp3"
                        fromBundle:YES
                        startDelay:0
            synchronizedStartBlock:nil
              synchronizedEndBlock:nil];
    }
}



@end
