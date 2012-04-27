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
#import "NSArray+ViewSorting.h"

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
- (void)coalescePiecesInScroller;

@end

@implementation SCHStoryInteractionControllerJigsaw_iPhone

@synthesize choosePuzzleButtons;
@synthesize puzzlePieceScroller;
@synthesize puzzlePieceScrollerOverlay;
@synthesize dragSourcePiece;
@synthesize draggingPiece;
@synthesize dragOffset;

- (void)dealloc
{
    [choosePuzzleButtons release], choosePuzzleButtons = nil;
    [puzzlePieceScroller release], puzzlePieceScroller = nil;
    [puzzlePieceScrollerOverlay release], puzzlePieceScrollerOverlay = nil;
    [draggingPiece release], draggingPiece = nil;
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    // lock in initial orientation
    return orientation == self.interfaceOrientation;
}

- (void)setupChoosePuzzleView
{
    [super setupChoosePuzzleView];
    self.choosePuzzleButtons = [self.choosePuzzleButtons viewsSortedHorizontally];
}

- (void)layoutViewsForPhoneOrientation:(UIInterfaceOrientation)orientation
{
    CGRect puzzleFrame;
    CGRect scrollerFrame;
    CGAffineTransform scrollerOverlayTransform;
    
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        CGRect containerRect = CGRectMake(0, 0, 310, 410);
        [[self.choosePuzzleButtons objectAtIndex:0] setCenter:CGPointMake(CGRectGetMidX(containerRect), CGRectGetHeight(containerRect)/4)];
        [[self.choosePuzzleButtons objectAtIndex:1] setCenter:CGPointMake(CGRectGetWidth(containerRect)/4, CGRectGetHeight(containerRect)*3/4)];
        [[self.choosePuzzleButtons objectAtIndex:2] setCenter:CGPointMake(CGRectGetWidth(containerRect)*3/4, CGRectGetHeight(containerRect)*3/4)];
        
        puzzleFrame = CGRectMake(10, 96, 300, 225);
        scrollerFrame = CGRectMake(15, 341, 290, 80);
        scrollerOverlayTransform = CGAffineTransformMakeRotation(M_PI_2);
        
    } else {
        CGRect containerRect = CGRectMake(0, 0, 470, 250);
        for (NSInteger index = 0; index < 3; ++index) {
            [[self.choosePuzzleButtons objectAtIndex:index] setCenter:CGPointMake(CGRectGetWidth(containerRect)/6*(index*2+1), CGRectGetMidY(containerRect))];
        }
        
        puzzleFrame = CGRectMake(98, 20, 360, 270);
        scrollerFrame = CGRectMake(10, 55, 80, 235);
        scrollerOverlayTransform = CGAffineTransformIdentity;
    }
    
    self.puzzlePreviewView.frame = puzzleFrame;
    self.puzzleBackground.frame = puzzleFrame;
    self.puzzlePieceScroller.frame = scrollerFrame;
    self.puzzlePieceScrollerOverlay.center = CGPointMake(CGRectGetMidX(scrollerFrame), CGRectGetMidY(scrollerFrame));
    self.puzzlePieceScrollerOverlay.bounds = CGRectMake(0, 0, 80, MAX(CGRectGetWidth(scrollerFrame), CGRectGetHeight(scrollerFrame)));
    self.puzzlePieceScrollerOverlay.transform = scrollerOverlayTransform;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self layoutViewsForPhoneOrientation:toInterfaceOrientation];
    }
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
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

- (NSArray *)homePositionsInScrollerForOrientation:(UIInterfaceOrientation)orientation
{
    NSMutableArray *positions = [NSMutableArray arrayWithCapacity:self.numberOfPieces];
    CGFloat x, y, dx, dy;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        x = CGRectGetMidX(self.puzzlePieceScroller.bounds);
        y = kPieceHeightInScroller/2;
        dx = 0;
        dy = kPieceHeightInScroller;
    } else {
        x = kPieceHeightInScroller/2;
        y = CGRectGetMidY(self.puzzlePieceScroller.bounds);
        dx = kPieceHeightInScroller;
        dy = 0;
    }
    for (NSInteger i = 0; i < self.numberOfPieces; ++i) {
        [positions addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
        x += dx;
        y += dy;
    }
    return positions;
}

- (void)setupPuzzlePiecesForInteractionFromPreview:(SCHStoryInteractionJigsawPreviewView *)preview
{
    const BOOL landscape = UIInterfaceOrientationIsLandscape(self.interfaceOrientation);
    
    NSArray *homePositions = [[self homePositionsInScrollerForOrientation:self.interfaceOrientation] shuffled];
    NSInteger pieceIndex = 0;
    CGFloat maxPieceWidth = 0, maxPieceHeight = 0;
    for (SCHStoryInteractionJigsawPieceView_iPhone *piece in self.jigsawPieceViews) {
        CGPoint center = piece.center;
        piece.solutionPosition = piece.center;
        piece.puzzleFrame = self.puzzleBackground.frame;
        piece.center = CGPointMake(center.x+CGRectGetMinX(self.puzzleBackground.frame), center.y+CGRectGetMinY(self.puzzleBackground.frame));
        piece.homePosition = [[homePositions objectAtIndex:pieceIndex] CGPointValue];
        piece.transform = CGAffineTransformIdentity;
        [self.contentsView addSubview:piece];
        pieceIndex++;
        maxPieceWidth = MAX(maxPieceWidth, CGRectGetWidth(piece.bounds));
        maxPieceHeight = MAX(maxPieceHeight, CGRectGetHeight(piece.bounds));
        
        SCHDragFromScrollViewGestureRecognizer *drag = [[SCHDragFromScrollViewGestureRecognizer alloc] initWithTarget:self action:@selector(handleDragFromScroller:)];
        drag.dragContainerView = self.contentsView;
        drag.direction = landscape ? kSCHDragFromScrollViewHorizontally : kSCHDragFromScrollViewVertically;
        [piece addGestureRecognizer:drag];
        [drag release];
    }
    
    [self enqueueAudioWithPath:@"sfx_breakpuzzle.mp3" fromBundle:YES];
    
    // move the pieces into the scroller
    CGFloat scale;
    if (landscape) {
        scale = (CGRectGetWidth(self.puzzlePieceScroller.bounds) - kPieceMargin) / maxPieceWidth;
    } else {
        scale = (CGRectGetHeight(self.puzzlePieceScroller.bounds) - kPieceMargin) / maxPieceHeight;
    }
    CGAffineTransform pieceTransform = CGAffineTransformMakeScale(scale, scale);
    CGPoint scrollerOrigin = self.puzzlePieceScroller.frame.origin;
    [self.puzzlePieceScroller setContentOffset:CGPointZero animated:NO];
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationCurveEaseInOut
                     animations:^{
                         for (SCHStoryInteractionJigsawPieceView_iPhone *piece in self.jigsawPieceViews) {
                             piece.center = CGPointMake(piece.homePosition.x+scrollerOrigin.x, piece.homePosition.y+scrollerOrigin.y);
                             piece.transform = pieceTransform;
                             if (piece.center.y > CGRectGetHeight(self.puzzlePieceScroller.bounds)) {
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
                             self.jigsawPieceViews = [self.jigsawPieceViews viewsSortedVertically];
                             self.puzzlePieceScroller.contentSize = CGSizeMake(CGRectGetWidth(self.puzzlePieceScroller.bounds),
                                                                               kPieceHeightInScroller*self.numberOfPieces);
                         } else {
                             self.jigsawPieceViews = [self.jigsawPieceViews viewsSortedHorizontally];
                             self.puzzlePieceScroller.contentSize = CGSizeMake(kPieceHeightInScroller*self.numberOfPieces,
                                                                               CGRectGetHeight(self.puzzlePieceScroller.bounds));
                         }
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
            if ([self.draggingPiece isInCorrectPosition]) {
                self.draggingPiece.center = [self.draggingPiece correctPosition];
            }
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
    self.draggingPiece.puzzleFrame = sourceView.puzzleFrame;
    self.draggingPiece.homePosition = self.draggingPiece.center;
    self.dragOffset = CGPointMake(self.draggingPiece.center.x - point.x, self.draggingPiece.center.y - point.y);
    [self.contentsView addSubview:self.draggingPiece];
    [sourceView setAlpha:0];
    
    [UIView animateWithDuration:0.25 animations:^{
        [self.draggingPiece setAlpha:0.8];
        [self.draggingPiece setTransform:CGAffineTransformIdentity];
    }];
    
    [self.puzzlePieceScroller setUserInteractionEnabled:NO];
    
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
        self.dragSourcePiece.center = [self.dragSourcePiece correctPosition];
        self.dragSourcePiece.alpha = 1;
        self.dragSourcePiece.userInteractionEnabled = NO;
        self.dragSourcePiece = nil;
        [self coalescePiecesInScroller];
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
    
    [self.puzzlePieceScroller setUserInteractionEnabled:YES];
}

- (void)coalescePiecesInScroller
{
    NSMutableArray *remainingPieces = [NSMutableArray array];
    NSArray *homePositions = [self homePositionsInScrollerForOrientation:self.interfaceOrientation];
    
    for (SCHStoryInteractionJigsawPieceView_iPhone *piece in self.jigsawPieceViews) {
        if (![piece isInCorrectPosition]) {
            NSInteger pieceIndex = [remainingPieces count];
            piece.homePosition = [[homePositions objectAtIndex:pieceIndex] CGPointValue];
            [remainingPieces addObject:piece];
        }
    }
    
    self.jigsawPieceViews = [NSArray arrayWithArray:remainingPieces];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         [self.jigsawPieceViews makeObjectsPerformSelector:@selector(moveToHomePosition)];
                         CGFloat height = kPieceHeightInScroller*[self.jigsawPieceViews count];
                         if (height > CGRectGetHeight(self.puzzlePieceScroller.bounds)) {
                             CGFloat maxOffset = height - CGRectGetHeight(self.puzzlePieceScroller.bounds);
                             if (self.puzzlePieceScroller.contentOffset.y > maxOffset) {
                                 [self.puzzlePieceScroller setContentOffset:CGPointMake(0, maxOffset) animated:NO];
                             }
                             if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
                                 self.puzzlePieceScroller.contentSize = CGSizeMake(CGRectGetWidth(self.puzzlePieceScroller.bounds), height);
                             } else {
                                 self.puzzlePieceScroller.contentSize = CGSizeMake(height, CGRectGetHeight(self.puzzlePieceScroller.bounds));
                             }
                         }
                     }];
}

@end
