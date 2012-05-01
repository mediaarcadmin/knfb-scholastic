//
//  SCHStoryInteractionControllerJigsaw_iPad.m
//  Scholastic
//
//  Created by Neil Gall on 15/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionControllerJigsaw_iPad.h"
#import "SCHStoryInteractionJigsawPiece.h"
#import "SCHStoryInteractionJigsawPieceView_iPad.h"
#import "SCHStoryInteractionJigsawPreviewView.h"
#import "NSArray+Shuffling.h"

enum {
    kPieceMargin = 5,
};

@interface SCHStoryInteractionControllerJigsaw_iPad ()

@property (nonatomic, assign) BOOL isPlayingStartDrag;

@end

@implementation SCHStoryInteractionControllerJigsaw_iPad {
    CGAffineTransform puzzleTransform;
}

@synthesize isPlayingStartDrag;

- (CGSize)iPadContentsSizeForViewAtIndex:(NSInteger)viewIndex forOrientation:(UIInterfaceOrientation)orientation
{
    switch (viewIndex) {
        case 0:
            return CGSizeMake(UIInterfaceOrientationIsLandscape(orientation) ? 798 : 690, 342);
        default:
            return UIInterfaceOrientationIsLandscape(orientation) ? CGSizeMake(900, 660) : CGSizeMake(690, 900);
    }
}

- (SCHStoryInteractionJigsawPreviewView *)makePuzzlePreviewView
{
    CGRect frame = CGRectInset(self.contentsView.bounds, 30, 10);
    SCHStoryInteractionJigsawPreviewView *preview = [[SCHStoryInteractionJigsawPreviewView alloc] initWithFrame:frame];
    preview.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
                                | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin
                                | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
    preview.backgroundColor = [UIColor clearColor];
    preview.edgeColor = [UIColor whiteColor];
    return [preview autorelease];
}

- (UIView<SCHStoryInteractionJigsawPieceView> *)newPieceView
{
    SCHStoryInteractionJigsawPieceView_iPad *pieceView = [[SCHStoryInteractionJigsawPieceView_iPad alloc] initWithFrame:CGRectZero];
    pieceView.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin
                                  | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
    return pieceView;
}

- (NSArray *)homePositionsAroundPuzzleForOrientation:(enum SCHStoryInteractionJigsawOrientation)orientation
{
    const CGRect bounds = self.contentsView.bounds;
    const CGRect puzzle = self.puzzleBackground.frame;
    const BOOL landscape = (orientation == kSCHStoryInteractionJigsawOrientationLandscape);
    
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
    return positions;
}

- (void)setupPieceViewsForOrientation:(enum SCHStoryInteractionJigsawOrientation)orientation puzzleRect:(CGRect)puzzleRect
{
    NSArray *homePositions = [self homePositionsAroundPuzzleForOrientation:orientation];

    puzzleTransform = CGAffineTransformMakeScale(CGRectGetWidth(puzzleRect)/CGRectGetWidth(self.puzzleBackground.bounds),
                                                 CGRectGetHeight(puzzleRect)/CGRectGetHeight(self.puzzleBackground.bounds));

    for (NSInteger pieceIndex = 0; pieceIndex < self.numberOfPieces; ++pieceIndex) {
        SCHStoryInteractionJigsawPiece *piece = [self.jigsawPieces objectAtIndex:pieceIndex];
        SCHStoryInteractionJigsawPieceView_iPad *pieceView = [self.jigsawPieceViews objectAtIndex:pieceIndex];
        pieceView.image = [piece imageForOrientation:orientation];
        pieceView.homePosition = [[homePositions objectAtIndex:pieceIndex] CGPointValue];
        pieceView.solutionPosition = [self.puzzleBackground convertPoint:[piece solutionPositionForOrientation:orientation] toView:self.contentsView];
        pieceView.bounds = [piece boundsForOrientation:orientation];
        pieceView.center = pieceView.homePosition;
        pieceView.transform = puzzleTransform;
        pieceView.dragTransform = CGAffineTransformIdentity;
        pieceView.snappedTransform = CGAffineTransformIdentity;
        pieceView.delegate = self;
    }
}

- (void)repositionPiecesToSolutionPosition:(BOOL)moveToSolutionPosition withOrientation:(enum SCHStoryInteractionJigsawOrientation)orientation
{
    CGAffineTransform pieceTransform = [self pieceTransformForHomePosition];
    
    for (NSInteger pieceIndex = 0; pieceIndex < self.numberOfPieces; ++pieceIndex) {
        SCHStoryInteractionJigsawPiece *piece = [self.jigsawPieces objectAtIndex:pieceIndex];
        SCHStoryInteractionJigsawPieceView_iPad *pieceView = [self.jigsawPieceViews objectAtIndex:pieceIndex];
        
        if (moveToSolutionPosition || [piece isInCorrectPosition]) {
            pieceView.transform = puzzleTransform;
            pieceView.center = pieceView.solutionPosition;
        } else {
            pieceView.transform = pieceTransform;
            [pieceView moveToHomePosition];
        }
        [self.contentsView addSubview:pieceView];
    }
}

- (void)animatePiecesToHomePositionsForOrientation:(enum SCHStoryInteractionJigsawOrientation)orientation
{
    [self enqueueAudioWithPath:@"sfx_breakpuzzle.mp3" fromBundle:YES];
    
    CGAffineTransform pieceTransform = [self pieceTransformForHomePosition];
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

- (CGAffineTransform)pieceTransformForHomePosition
{
    // scale the pieces down to fit in the margins around the puzzle background
    CGFloat scale = 0.33;
    switch (self.numberOfPieces) {
        case 6: scale = 0.28; break;
        case 12: scale = 0.33; break;
        case 20: scale = 0.33; break;
        default: scale = 0.33; break;
    }
    return CGAffineTransformMakeScale(scale, scale);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

#pragma mark - draggable delegate

- (void)draggableViewDidStartDrag:(SCHStoryInteractionDraggableView *)draggableView
{
    if (self.isPlayingStartDrag == NO) {
        self.isPlayingStartDrag = YES;
        [self enqueueAudioWithPath:@"sfx_pickup.mp3" 
                        fromBundle:YES
                        startDelay:0
            synchronizedStartBlock:nil
              synchronizedEndBlock:^{
                  self.isPlayingStartDrag = NO;
              }];
    }
}

- (BOOL)draggableView:(SCHStoryInteractionDraggableView *)draggableView shouldSnapFromPosition:(CGPoint)position toPosition:(CGPoint *)snapPosition
{
    SCHStoryInteractionJigsawPieceView_iPad *pieceView = (SCHStoryInteractionJigsawPieceView_iPad *)draggableView;
    if ([pieceView shouldSnapToSolutionPositionFromPosition:position]) {
        *snapPosition = pieceView.solutionPosition;
        return YES;
    }
    return NO;
}

- (void)draggableView:(SCHStoryInteractionDraggableView *)draggableView didMoveToPosition:(CGPoint)position
{
    SCHStoryInteractionJigsawPieceView_iPad *pieceView = (SCHStoryInteractionJigsawPieceView_iPad *)draggableView;
    
    // ensure we only play one drop sound at a time
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(playDropSoundForPiece:) withObject:pieceView afterDelay:0.2];
    
    if ([pieceView shouldSnapToSolutionPositionFromPosition:position]) {
        pieceView.center = pieceView.solutionPosition;
        [pieceView setUserInteractionEnabled:NO];
        [[self pieceForPieceView:pieceView] setInCorrectPosition:YES];
    } else {
        [pieceView moveToHomePosition];
    }
}

- (void)playDropSoundForPiece:(SCHStoryInteractionJigsawPieceView_iPad *)pieceView
{
    SCHStoryInteractionJigsawPiece *piece = [self pieceForPieceView:pieceView];
    
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
