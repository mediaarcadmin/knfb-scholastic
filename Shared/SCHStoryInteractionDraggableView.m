//
//  SCHStoryInteractionDraggableView.m
//  Scholastic
//
//  Created by Neil Gall on 03/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "SCHStoryInteractionDraggableView.h"
#import "SCHStoryInteractionDraggableTargetView.h"
#import "SCHGeometry.h"

#define kMaximumTapTime 0.2
#define kMinimumDragDistanceSq 25

@interface SCHStoryInteractionDraggableView ()

enum DragState {
    kDragStateIdle,
    kDragStateDragging,
    kDragStateCancelled
};

@property (nonatomic, assign) CGPoint touchOffset;
@property (nonatomic, assign) CGPoint dragOrigin;
@property (nonatomic, assign) NSTimeInterval touchStartTime;
@property (nonatomic, assign) BOOL tapSupported;
@property (nonatomic, assign) BOOL shouldStartDragSupported;
@property (nonatomic, assign) enum DragState dragState;
@property (nonatomic, assign) CGAffineTransform preDragTransform;
@property (nonatomic, assign) BOOL isSnapped;

- (void)beginDrag;
- (void)endDragWithTouch:(UITouch *)touch cancelled:(BOOL)cancelled;
- (CGPoint)centerOfRect:(CGRect)rect inContainerRect:(CGRect)container withNewCenter:(CGPoint)center;

@end

@implementation SCHStoryInteractionDraggableView

@synthesize matchTag;
@synthesize delegate;
@synthesize homePosition;
@synthesize touchOffset;
@synthesize dragOrigin;
@synthesize touchStartTime;
@synthesize tapSupported;
@synthesize shouldStartDragSupported;
@synthesize dragState;
@synthesize lockedInPlace;
@synthesize dragTransform;
@synthesize snappedTransform;
@synthesize preDragTransform;
@synthesize isSnapped;

- (void)setup
{
    self.lockedInPlace = NO;
    self.dragTransform = CGAffineTransformMakeScale(1.1f, 1.1f);
    self.snappedTransform = CGAffineTransformIdentity;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    [self setup];
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self setup];
    return self;
}

- (void)setDelegate:(NSObject<SCHStoryInteractionDraggableViewDelegate> *)aDelegate
{
    delegate = aDelegate;
    tapSupported = [aDelegate respondsToSelector:@selector(draggableViewWasTapped:)];
    shouldStartDragSupported = [aDelegate respondsToSelector:@selector(draggableViewShouldStartDrag:)];
}

- (void)moveToHomePosition
{
    [self moveToHomePositionWithCompletionHandler:nil];
}

- (void)moveToHomePositionWithCompletionHandler:(dispatch_block_t)completion
{
    if (CGPointEqualToPoint(self.center, self.homePosition)) {
        if (completion) {
            completion();
        }
    } else {
        [UIView animateWithDuration:0.25f 
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             self.center = self.homePosition;
                         }
                         completion:^(BOOL finished) {
                             if (completion) {
                                 completion();
                             }
                         }];
    }
}

#pragma mark - touch support

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.dragState = kDragStateIdle;
    if (self.shouldStartDragSupported && self.delegate && ![self.delegate draggableViewShouldStartDrag:self]) {
        self.dragState = kDragStateCancelled;
        return;
    }
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.superview];
    self.touchOffset = CGPointMake(self.center.x - point.x, self.center.y - self.center.y);
    
    if (self.tapSupported) {
        self.touchStartTime = touch.timestamp;
        [self performSelector:@selector(beginDrag) withObject:nil afterDelay:kMaximumTapTime];
    } else {
        [self beginDrag];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.dragState == kDragStateCancelled) {
        return;
    }

    CGPoint point = [[touches anyObject] locationInView:self.superview];
    CGPoint newCenter = [self centerOfRect:self.frame
                           inContainerRect:self.superview.bounds
                             withNewCenter:CGPointMake(point.x+self.touchOffset.x, point.y+self.touchOffset.y)];

    if (self.dragState == kDragStateIdle) {
        if (SCHCGPointDistanceSq(self.homePosition, newCenter) < kMinimumDragDistanceSq) {
            return;
        }
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(beginDrag) object:nil];
        [self beginDrag];
    }

    self.center = newCenter;
    
    CGPoint snapPoint;
    if (self.delegate && [self.delegate draggableView:self shouldSnapFromPosition:self.center toPosition:&snapPoint]) {
        self.center = snapPoint;
        self.isSnapped = YES;
    } else {
        self.isSnapped = NO;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self endDragWithTouch:[touches anyObject] cancelled:NO];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self endDragWithTouch:[touches anyObject] cancelled:YES];
}

#pragma mark - dragging

- (void)beginDrag
{
    self.dragState = kDragStateDragging;
    self.dragOrigin = self.center;
    self.preDragTransform = self.transform;
    [self.superview bringSubviewToFront:self];
    [UIView animateWithDuration:0.25f 
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.transform = self.dragTransform;
                         self.alpha = 0.8;
                     }
                     completion:nil];
    
    if (delegate) {
        [self.delegate draggableViewDidStartDrag:self];
    }
}

- (void)endDragWithTouch:(UITouch *)touch cancelled:(BOOL)cancelled
{
    if (self.dragState == kDragStateDragging) {
        [UIView animateWithDuration:0.25f 
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             self.transform = self.isSnapped ? self.snappedTransform : self.preDragTransform;
                             self.alpha = 1;
                             if (cancelled) {
                                 self.center = self.dragOrigin;
                             }
                         }
                         completion:nil];
        if (delegate) {
            [delegate draggableView:self didMoveToPosition:(cancelled ? self.dragOrigin : self.center)];
        }
    } else if (self.dragState != kDragStateCancelled && self.tapSupported) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(beginDrag) object:nil];
        if (delegate && touch.timestamp - self.touchStartTime < kMaximumTapTime) {
            [self.delegate draggableViewWasTapped:self];
        }
    }

    self.dragState = kDragStateIdle;
}

- (CGPoint)centerOfRect:(CGRect)rect inContainerRect:(CGRect)container withNewCenter:(CGPoint)center
{
    CGFloat x = MAX(center.x, CGRectGetWidth(rect)/2);
    x = MIN(x, CGRectGetWidth(container)-CGRectGetWidth(rect)/2);
    
    CGFloat y = MAX(center.y, CGRectGetHeight(rect)/2);
    y = MIN(y, CGRectGetHeight(container)-CGRectGetHeight(rect)/2);
    
    return CGPointMake(x, y);
}

@end
