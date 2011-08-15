//
//  SCHStoryInteractionControllerJigsaw_iPhone.m
//  Scholastic
//
//  Created by Neil Gall on 15/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionControllerJigsaw_iPhone.h"
#import "SCHStoryInteractionJigsawPieceView_iPhone.h"
#import "SCHStoryInteractionJigsawPreviewView.h"
#import "SCHDragFromScrollViewGestureRecognizer.h"
#import "NSArray+Shuffling.h"

enum {
    kPieceMargin = 5,
    kPieceHeightInScroller = 80
};

@interface SCHStoryInteractionControllerJigsaw_iPhone ()

@property (nonatomic, retain) SCHStoryInteractionJigsawPieceView_iPhone *dragSourcePiece;
@property (nonatomic, retain) SCHStoryInteractionJigsawPieceView_iPhone *draggingPiece;
@property (nonatomic, assign) CGPoint dragOffset;

- (void)beginDragFromView:(SCHStoryInteractionJigsawPieceView_iPhone *)sourceView point:(CGPoint)point;
- (void)endDrag;

@end

@implementation SCHStoryInteractionControllerJigsaw_iPhone

@synthesize puzzlePieceScroller;
@synthesize dragSourcePiece;
@synthesize draggingPiece;
@synthesize dragOffset;

- (void)dealloc
{
    [puzzlePieceScroller release], puzzlePieceScroller = nil;
    [draggingPiece release], draggingPiece = nil;
    [super dealloc];
}

- (CGRect)puzzlePreviewFrame
{
    return self.puzzleBackground.frame;
}

- (UIView<SCHStoryInteractionJigsawPieceView> *)newPieceViewForImage:(CGImageRef)image
{
    SCHStoryInteractionJigsawPieceView_iPhone *pieceView = [[SCHStoryInteractionJigsawPieceView_iPhone alloc] initWithFrame:CGRectZero];
    pieceView.image = image;
    return pieceView;
}

- (NSArray *)homePositionsInScroller
{
    NSMutableArray *positions = [NSMutableArray arrayWithCapacity:self.numberOfPieces];
    CGFloat x = CGRectGetMidX(self.puzzlePieceScroller.bounds);
    CGFloat y = kPieceHeightInScroller/2;
    for (NSInteger i = 0; i < self.numberOfPieces; ++i) {
        [positions addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
        y += kPieceHeightInScroller;
    }
    return [positions shuffled];
}

- (void)setupPuzzlePiecesForInteractionFromPreview:(SCHStoryInteractionJigsawPreviewView *)preview
{
    NSArray *homePositions = [self homePositionsInScroller];
    NSInteger pieceIndex = 0;
    CGFloat maxPieceWidth = 0, maxPieceHeight = 0;
    for (SCHStoryInteractionJigsawPieceView_iPhone *piece in self.jigsawPieceViews) {
        CGPoint center = piece.center;
        piece.center = CGPointMake(center.x+CGRectGetMinX(self.puzzleBackground.frame), center.y+CGRectGetMinY(self.puzzleBackground.frame));
        piece.solutionPosition = piece.center;
        piece.homePosition = [[homePositions objectAtIndex:pieceIndex] CGPointValue];
        piece.transform = CGAffineTransformIdentity;
        [self.contentsView addSubview:piece];
        pieceIndex++;
        maxPieceWidth = MAX(maxPieceWidth, CGRectGetWidth(piece.bounds));
        maxPieceHeight = MAX(maxPieceHeight, CGRectGetHeight(piece.bounds));
        
        SCHDragFromScrollViewGestureRecognizer *drag = [[SCHDragFromScrollViewGestureRecognizer alloc] initWithTarget:self action:@selector(handleDragFromScroller:)];
        drag.dragContainerView = self.contentsView;
        [piece addGestureRecognizer:drag];
        [drag release];
    }
    
    [self enqueueAudioWithPath:@"sfx_breakpuzzle.mp3" fromBundle:YES];
    
    // move the pieces into the scroller
    CGFloat scale = (CGRectGetWidth(self.puzzlePieceScroller.bounds) - kPieceMargin) / maxPieceWidth;
    CGAffineTransform pieceTransform = CGAffineTransformMakeScale(scale, scale);
    CGPoint scrollerOrigin = self.puzzlePieceScroller.frame.origin;
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationCurveEaseInOut
                     animations:^{
                         for (SCHStoryInteractionJigsawPieceView_iPhone *piece in self.jigsawPieceViews) {
                             piece.center = CGPointMake(piece.homePosition.x+scrollerOrigin.x, piece.homePosition.y+scrollerOrigin.y);
                             piece.transform = pieceTransform;
                         }
                     }
                     completion:^(BOOL finished) {
                         for (SCHStoryInteractionJigsawPieceView_iPhone *piece in self.jigsawPieceViews) {
                             [piece removeFromSuperview];
                             [self.puzzlePieceScroller addSubview:piece];
                             piece.center = piece.homePosition;
                         }
                         self.puzzlePieceScroller.contentSize = CGSizeMake(CGRectGetWidth(self.puzzlePieceScroller.bounds),
                                                                           kPieceHeightInScroller*self.numberOfPieces);
                     }];
}

#pragma mark - drag from scroller

- (void)handleDragFromScroller:(SCHDragFromScrollViewGestureRecognizer *)drag
{
    switch ([drag state]) {
        case UIGestureRecognizerStateBegan: {
            [self beginDragFromView:(SCHStoryInteractionJigsawPieceView_iPhone *)[drag view] point:[drag locationInView:self.contentsView]];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint point = [drag locationInView:drag.dragContainerView];
            self.draggingPiece.center = CGPointMake(point.x + self.dragOffset.x, point.y + self.dragOffset.y);
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            [self endDrag];
            break;
        }
        default:
            break;
    }
}

- (void)beginDragFromView:(SCHStoryInteractionJigsawPieceView_iPhone *)sourceView point:(CGPoint)point
{
    self.dragSourcePiece = sourceView;
    self.draggingPiece = [[[SCHStoryInteractionJigsawPieceView_iPhone alloc] initWithFrame:sourceView.bounds] autorelease];
    self.draggingPiece.center = CGPointMake(sourceView.center.x-self.puzzlePieceScroller.contentOffset.x+self.puzzlePieceScroller.frame.origin.x,
                                        sourceView.center.y-self.puzzlePieceScroller.contentOffset.y+self.puzzlePieceScroller.frame.origin.y);
    self.draggingPiece.transform = sourceView.transform;
    self.draggingPiece.image = sourceView.image;
    self.draggingPiece.solutionPosition = sourceView.solutionPosition;
    self.draggingPiece.homePosition = self.draggingPiece.center;
    self.dragOffset = CGPointMake(self.draggingPiece.center.x - point.x, self.draggingPiece.center.y - point.y);
    [self.contentsView addSubview:self.draggingPiece];
    [sourceView setAlpha:0];
    
    [UIView animateWithDuration:0.25 animations:^{
        [self.draggingPiece setAlpha:0.8];
        [self.draggingPiece setTransform:CGAffineTransformIdentity];
    }];
    
    [self enqueueAudioWithPath:@"sfx_pickup.mp3" fromBundle:YES];
}

- (void)endDrag
{
    if ([self.draggingPiece isInCorrectPosition]) {
        [self enqueueAudioWithPath:@"sfx_dropOK.mp3" fromBundle:YES];
        // move the original piece from the scroller to its correct position
        [self.draggingPiece removeFromSuperview];
        self.draggingPiece = nil;
        [self.dragSourcePiece removeFromSuperview];
        [self.contentsView addSubview:self.dragSourcePiece];
        self.dragSourcePiece.transform = CGAffineTransformIdentity;
        self.dragSourcePiece.center = self.dragSourcePiece.solutionPosition;
        self.dragSourcePiece.alpha = 1;
        self.dragSourcePiece = nil;
        [self checkForCompletion];
    } else {
        [self enqueueAudioWithPath:@"sfx_dropNo.mp3" fromBundle:YES];
        // animate the dragging piece back to its home
        [UIView animateWithDuration:0.25
                              delay:0
                            options:UIViewAnimationCurveEaseInOut
                         animations:^{
                             self.draggingPiece.transform = self.dragSourcePiece.transform;
                             self.draggingPiece.center = self.draggingPiece.homePosition;
                         }
                         completion:^(BOOL finished) {
                             [self.draggingPiece removeFromSuperview];
                             self.draggingPiece = nil;
                             self.dragSourcePiece.alpha = 1;
                             self.dragSourcePiece = nil;
                         }];
    }
    
}

@end
