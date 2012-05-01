//
//  SCHStoryInteractionControllerJigsaw_iPhone.m
//  Scholastic
//
//  Created by Neil Gall on 15/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionControllerJigsaw_iPhone.h"
#import "SCHStoryInteractionJigsawPiece.h"
#import "SCHStoryInteractionJigsawPieceView_iPhone.h"
#import "SCHStoryInteractionJigsawPreviewView.h"
#import "SCHDragFromScrollViewGestureRecognizer.h"
#import "NSArray+ViewSorting.h"

enum {
    kPieceMargin = 5,
    kPieceHeightInScroller = 80
};

@interface SCHStoryInteractionControllerJigsaw_iPhone ()

@property (nonatomic, retain) SCHStoryInteractionJigsawPieceView_iPhone *dragSourcePiece;
@property (nonatomic, retain) SCHStoryInteractionJigsawPieceView_iPhone *draggingPieceView;
@property (nonatomic, assign) CGPoint dragOffset;
@property (nonatomic, assign) CGSize maxPieceSize;

- (void)beginDragFromView:(SCHStoryInteractionJigsawPieceView_iPhone *)sourceView point:(CGPoint)point;
- (void)endDrag;

@end

@implementation SCHStoryInteractionControllerJigsaw_iPhone

@synthesize choosePuzzleButtons;
@synthesize puzzlePieceScroller;
@synthesize puzzlePieceScrollerOverlay;
@synthesize dragSourcePiece;
@synthesize draggingPieceView;
@synthesize dragOffset;
@synthesize maxPieceSize;

- (void)dealloc
{
    [choosePuzzleButtons release], choosePuzzleButtons = nil;
    [puzzlePieceScroller release], puzzlePieceScroller = nil;
    [puzzlePieceScrollerOverlay release], puzzlePieceScrollerOverlay = nil;
    [dragSourcePiece release], dragSourcePiece = nil;
    [draggingPieceView release], draggingPieceView = nil;
    [super dealloc];
}

- (void)setupChoosePuzzleView
{
    [super setupChoosePuzzleView];
    self.choosePuzzleButtons = [self.choosePuzzleButtons viewsSortedHorizontally];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    CGRect puzzleFrame;
    CGRect scrollerFrame;
    CGAffineTransform scrollerOverlayTransform;
    enum SCHStoryInteractionJigsawOrientation jigsawOrientation;
    
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        CGRect containerRect = CGRectMake(0, 0, 310, 410);
        [[self.choosePuzzleButtons objectAtIndex:0] setCenter:CGPointMake(CGRectGetMidX(containerRect), CGRectGetHeight(containerRect)/4)];
        [[self.choosePuzzleButtons objectAtIndex:1] setCenter:CGPointMake(CGRectGetWidth(containerRect)/4, CGRectGetHeight(containerRect)*3/4)];
        [[self.choosePuzzleButtons objectAtIndex:2] setCenter:CGPointMake(CGRectGetWidth(containerRect)*3/4, CGRectGetHeight(containerRect)*3/4)];
        
        puzzleFrame = CGRectMake(10, 96, 300, 225);
        scrollerFrame = CGRectMake(15, 341, 290, 80);
        scrollerOverlayTransform = CGAffineTransformMakeRotation(M_PI_2);
        jigsawOrientation = kSCHStoryInteractionJigsawOrientationPortrait;
        
    } else {
        CGRect containerRect = CGRectMake(0, 0, 470, 250);
        for (NSInteger index = 0; index < 3; ++index) {
            [[self.choosePuzzleButtons objectAtIndex:index] setCenter:CGPointMake(CGRectGetWidth(containerRect)/6*(index*2+1), CGRectGetMidY(containerRect))];
        }
        
        puzzleFrame = CGRectMake(98, 20, 360, 270);
        scrollerFrame = CGRectMake(10, 55, 80, 235);
        scrollerOverlayTransform = CGAffineTransformIdentity;
        jigsawOrientation = kSCHStoryInteractionJigsawOrientationLandscape;
    }
    
    self.puzzlePreviewView.frame = puzzleFrame;
    self.puzzleBackground.frame = puzzleFrame;
    self.puzzlePieceScroller.frame = scrollerFrame;
    self.puzzlePieceScrollerOverlay.center = CGPointMake(CGRectGetMidX(scrollerFrame), CGRectGetMidY(scrollerFrame));
    self.puzzlePieceScrollerOverlay.bounds = CGRectMake(0, 0, 80, MAX(CGRectGetWidth(scrollerFrame), CGRectGetHeight(scrollerFrame)));
    self.puzzlePieceScrollerOverlay.transform = scrollerOverlayTransform;
    
    [self coalescePiecesInScrollerForOrientation:jigsawOrientation];

    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (SCHStoryInteractionJigsawPreviewView *)makePuzzlePreviewView
{
    SCHStoryInteractionJigsawPreviewView *preview = [[SCHStoryInteractionJigsawPreviewView alloc] initWithFrame:self.puzzleBackground.frame];
    preview.autoresizingMask = 0;
    preview.backgroundColor = [UIColor clearColor];
    preview.edgeColor = [UIColor whiteColor];
    return [preview autorelease];
}

- (UIView<SCHStoryInteractionJigsawPieceView> *)newPieceView
{
    SCHStoryInteractionJigsawPieceView_iPhone *pieceView = [[SCHStoryInteractionJigsawPieceView_iPhone alloc] initWithFrame:CGRectZero];
    return pieceView;
}

- (NSArray *)homePositionsInScrollerForOrientation:(enum SCHStoryInteractionJigsawOrientation)orientation
{
    NSMutableArray *positions = [NSMutableArray arrayWithCapacity:self.numberOfPieces];
    CGFloat midX = CGRectGetMidX(self.puzzlePieceScroller.bounds);
    CGFloat midY = CGRectGetMidY(self.puzzlePieceScroller.bounds);
    CGFloat offset = kPieceHeightInScroller/2;

    for (NSInteger pieceIndex = 0; pieceIndex < self.numberOfPieces; ++pieceIndex) {
        CGPoint point;
        if (orientation == kSCHStoryInteractionJigsawOrientationLandscape) {
            point = CGPointMake(midX, offset);
        } else {
            point = CGPointMake(offset, midY);
        }
        [positions addObject:[NSValue valueWithCGPoint:point]];
        offset += kPieceHeightInScroller;
    }
    return positions;
}

- (void)setupPieceViewsForOrientation:(enum SCHStoryInteractionJigsawOrientation)orientation puzzleRect:(CGRect)puzzleRect
{
    CGFloat maxPieceWidth = 0, maxPieceHeight = 0;
    for (NSInteger pieceIndex = 0; pieceIndex < self.numberOfPieces; ++pieceIndex) {
        SCHStoryInteractionJigsawPiece *piece = [self.jigsawPieces objectAtIndex:pieceIndex];
        SCHStoryInteractionJigsawPieceView_iPhone *pieceView = [self.jigsawPieceViews objectAtIndex:pieceIndex];
        pieceView.bounds = [piece boundsForOrientation:orientation];
        pieceView.image = [piece imageForOrientation:orientation];
        pieceView.solutionPosition = [self.puzzleBackground convertPoint:[piece solutionPositionForOrientation:orientation] toView:self.contentsView];
        
        maxPieceWidth = MAX(maxPieceWidth, CGRectGetWidth(pieceView.bounds));
        maxPieceHeight = MAX(maxPieceHeight, CGRectGetHeight(pieceView.bounds));
        
        enum SCHDragFromScrollViewGestureRecognizerDirection dragDirection =
            (orientation == kSCHStoryInteractionJigsawOrientationLandscape ? kSCHDragFromScrollViewHorizontally : kSCHDragFromScrollViewVertically);
        [pieceView addDragFromScrollerGestureRecognizerWithTarget:self
                                                           action:@selector(handleDragFromScroller:)
                                                        container:self.contentsView
                                                        direction:dragDirection];
    }

    self.maxPieceSize = CGSizeMake(maxPieceWidth, maxPieceHeight);
}

- (void)repositionPiecesToSolutionPosition:(BOOL)moveToSolutionPosition withOrientation:(enum SCHStoryInteractionJigsawOrientation)orientation
{    
    CGAffineTransform scrollerTransform = [self pieceTransformForScrollerInOrientation:orientation withMaxPieceSize:self.maxPieceSize];

    NSArray *homePositions = [self homePositionsInScrollerForOrientation:orientation];
    NSInteger homePositionIndex = 0;
    
    for (NSInteger pieceIndex = 0; pieceIndex < self.numberOfPieces; ++pieceIndex) {
        SCHStoryInteractionJigsawPiece *piece = [self.jigsawPieces objectAtIndex:pieceIndex];
        SCHStoryInteractionJigsawPieceView_iPhone *pieceView = [self.jigsawPieceViews objectAtIndex:pieceIndex];
        
        if (moveToSolutionPosition || [piece isInCorrectPosition]) {
            pieceView.transform = CGAffineTransformIdentity;
            pieceView.center = pieceView.solutionPosition;
            [self.contentsView addSubview:pieceView];
        } else {
            pieceView.transform = scrollerTransform;
            pieceView.homePosition = [[homePositions objectAtIndex:homePositionIndex++] CGPointValue];
            [pieceView moveToHomePosition];
            [self.puzzlePieceScroller addSubview:pieceView];
        }
    }

    [self.contentsView bringSubviewToFront:self.puzzlePieceScrollerOverlay];
}

- (void)animatePiecesToHomePositionsForOrientation:(enum SCHStoryInteractionJigsawOrientation)orientation
{
    const BOOL landscape = (orientation == kSCHStoryInteractionJigsawOrientationLandscape);

    [self enqueueAudioWithPath:@"sfx_breakpuzzle.mp3" fromBundle:YES];
    
    // move the pieces into the scroller
    CGAffineTransform pieceTransform = [self pieceTransformForScrollerInOrientation:orientation withMaxPieceSize:self.maxPieceSize];
    CGPoint scrollerOrigin = self.puzzlePieceScroller.frame.origin;
    [self.puzzlePieceScroller setContentOffset:CGPointZero animated:NO];
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationCurveEaseInOut
                     animations:^{
                         for (SCHStoryInteractionJigsawPieceView_iPhone *piece in self.jigsawPieceViews) {
                             piece.center = CGPointMake(piece.homePosition.x+scrollerOrigin.x, piece.homePosition.y+scrollerOrigin.y);
                             piece.transform = pieceTransform;
                             if ((landscape && CGRectGetMaxY(piece.bounds) > CGRectGetHeight(self.puzzlePieceScroller.bounds))
                                 || (!landscape && CGRectGetMaxX(piece.bounds) > CGRectGetWidth(self.puzzlePieceScroller.bounds))) {
                                 piece.alpha = 0;
                             }
                         }
                     }
                     completion:^(BOOL finished) {
                         for (SCHStoryInteractionJigsawPieceView_iPhone *piece in self.jigsawPieceViews) {
                             [piece removeFromSuperview];
                             [self.puzzlePieceScroller addSubview:piece];
                             piece.center = piece.homePosition;
                             piece.alpha = 1;
                         }
                         if (landscape) {
                             self.puzzlePieceScroller.contentSize = CGSizeMake(CGRectGetWidth(self.puzzlePieceScroller.bounds),
                                                                               kPieceHeightInScroller*self.numberOfPieces);
                         } else {
                             self.puzzlePieceScroller.contentSize = CGSizeMake(kPieceHeightInScroller*self.numberOfPieces,
                                                                               CGRectGetHeight(self.puzzlePieceScroller.bounds));
                         }
                     }];
}

- (CGAffineTransform)pieceTransformForScrollerInOrientation:(enum SCHStoryInteractionJigsawOrientation)orientation withMaxPieceSize:(CGSize)size
{
    CGFloat scale;
    if (orientation == kSCHStoryInteractionJigsawOrientationLandscape) {
        scale = (CGRectGetWidth(self.puzzlePieceScroller.bounds) - kPieceMargin) / size.width;
    } else {
        scale = (CGRectGetHeight(self.puzzlePieceScroller.bounds) - kPieceMargin) / size.height;
    }
    return CGAffineTransformMakeScale(scale, scale);
}

#pragma mark - drag from scroller

- (void)handleDragFromScroller:(SCHDragFromScrollViewGestureRecognizer *)drag
{
    switch ([drag state]) {
        case UIGestureRecognizerStateBegan: {
            [self beginDragFromView:(SCHStoryInteractionJigsawPieceView_iPhone *)[drag view] point:[drag locationInView:drag.dragContainerView]];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint point = [drag locationInView:drag.dragContainerView];
            CGPoint center = CGPointMake(point.x + self.dragOffset.x, point.y + self.dragOffset.y);
            if ([self.draggingPieceView shouldSnapToSolutionPositionFromPosition:center]) {
                self.draggingPieceView.center = self.draggingPieceView.solutionPosition;
            } else {
                self.draggingPieceView.center = center;
            }
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed: {
            [self endDrag];
            break;
        }
        default:
            break;
    }
}

- (void)beginDragFromView:(SCHStoryInteractionJigsawPieceView_iPhone *)sourceView point:(CGPoint)point
{
    if (self.dragSourcePiece != nil) {
        [self endDrag];
    }
    
    self.dragSourcePiece = sourceView;
    
    self.draggingPieceView = [[[SCHStoryInteractionJigsawPieceView_iPhone alloc] initWithFrame:sourceView.bounds] autorelease];
    self.draggingPieceView.center = CGPointMake(sourceView.center.x-self.puzzlePieceScroller.contentOffset.x+self.puzzlePieceScroller.frame.origin.x,
                                        sourceView.center.y-self.puzzlePieceScroller.contentOffset.y+self.puzzlePieceScroller.frame.origin.y);
    self.draggingPieceView.transform = sourceView.transform;
    self.draggingPieceView.image = sourceView.image;
    self.draggingPieceView.solutionPosition = sourceView.solutionPosition;
    self.draggingPieceView.homePosition = self.draggingPieceView.center;
    self.dragOffset = CGPointMake(self.draggingPieceView.center.x - point.x, self.draggingPieceView.center.y - point.y);
    [self.contentsView addSubview:self.draggingPieceView];
    [sourceView setAlpha:0];
    
    UIView *draggingPiece = self.draggingPieceView;
    [UIView animateWithDuration:0.25 animations:^{
        [draggingPiece setAlpha:0.8];
        [draggingPiece setTransform:CGAffineTransformIdentity];
    }];
    
    [self.puzzlePieceScroller setUserInteractionEnabled:NO];
    
    [self cancelQueuedAudioExecutingSynchronizedBlocksBefore:^{
        [self enqueueAudioWithPath:@"sfx_pickup.mp3" fromBundle:YES];
    }];
}

- (void)endDrag
{
    if ([self.draggingPieceView shouldSnapToSolutionPositionFromPosition:self.draggingPieceView.center]) {
        [self enqueueAudioWithPath:@"sfx_dropOK.mp3" fromBundle:YES];
        [[self pieceForPieceView:self.dragSourcePiece] setInCorrectPosition:YES];
        // move the original piece from the scroller to its correct position
        [self.draggingPieceView removeFromSuperview];
        self.draggingPieceView = nil;
        [self.dragSourcePiece removeFromSuperview];
        [self.contentsView addSubview:self.dragSourcePiece];
        self.dragSourcePiece.transform = CGAffineTransformIdentity;
        self.dragSourcePiece.center = self.dragSourcePiece.solutionPosition;
        self.dragSourcePiece.alpha = 1;
        self.dragSourcePiece.userInteractionEnabled = NO;
        self.dragSourcePiece = nil;
        [self coalescePiecesInScrollerForOrientation:[self currentJigsawOrientation]];
        [self checkForCompletion];
    } else {
        [self enqueueAudioWithPath:@"sfx_dropNo.mp3" fromBundle:YES];

        // animate the dragging piece back to its home
        UIView *draggingPiece = self.draggingPieceView;
        UIView *sourcePiece = self.dragSourcePiece;
        [UIView animateWithDuration:0.25
                              delay:0
                            options:UIViewAnimationCurveEaseInOut
                         animations:^{
                             draggingPiece.transform = self.dragSourcePiece.transform;
                             draggingPiece.center = self.draggingPieceView.homePosition;
                         }
                         completion:^(BOOL finished) {
                             [draggingPiece removeFromSuperview];
                             [sourcePiece setAlpha:1];
                         }];
        self.draggingPieceView = nil;
        self.dragSourcePiece = nil;
    }
    
    [self.puzzlePieceScroller setUserInteractionEnabled:YES];
}

- (void)coalescePiecesInScrollerForOrientation:(enum SCHStoryInteractionJigsawOrientation)orientation
{
    NSArray *homePositions = [self homePositionsInScrollerForOrientation:orientation];
    
    NSInteger homePositionIndex = 0;
    for (NSInteger pieceIndex = 0, pieceCount = [self.jigsawPieces count]; pieceIndex < pieceCount; ++pieceIndex) {
        SCHStoryInteractionJigsawPiece *piece = [self.jigsawPieces objectAtIndex:pieceIndex];
        SCHStoryInteractionJigsawPieceView_iPhone *pieceView = [self.jigsawPieceViews objectAtIndex:pieceIndex];
        if ([piece isInCorrectPosition]) {
            pieceView.homePosition = pieceView.solutionPosition;
        } else {
            pieceView.homePosition = [[homePositions objectAtIndex:homePositionIndex++] CGPointValue];
        }
    }
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         [self.jigsawPieceViews makeObjectsPerformSelector:@selector(moveToHomePosition)];
                         if (orientation == kSCHStoryInteractionJigsawOrientationLandscape) {
                             CGFloat height = kPieceHeightInScroller*homePositionIndex;
                             if (height > CGRectGetHeight(self.puzzlePieceScroller.bounds)) {
                                 CGFloat maxOffset = height - CGRectGetHeight(self.puzzlePieceScroller.bounds);
                                 if (self.puzzlePieceScroller.contentOffset.y > maxOffset) {
                                     [self.puzzlePieceScroller setContentOffset:CGPointMake(0, maxOffset) animated:NO];
                                 }
                                 self.puzzlePieceScroller.contentSize = CGSizeMake(CGRectGetWidth(self.puzzlePieceScroller.bounds), height);
                             }
                         } else {
                             CGFloat width = kPieceHeightInScroller*homePositionIndex;
                             if (width > CGRectGetWidth(self.puzzlePieceScroller.bounds)) {
                                 CGFloat maxOffset = width - CGRectGetWidth(self.puzzlePieceScroller.bounds);
                                 if (self.puzzlePieceScroller.contentOffset.x > maxOffset) {
                                     [self.puzzlePieceScroller setContentOffset:CGPointMake(maxOffset, 0) animated:NO];
                                 }
                                 self.puzzlePieceScroller.contentSize = CGSizeMake(width, CGRectGetHeight(self.puzzlePieceScroller.bounds));
                             }
                         }
                     }];
}

@end
