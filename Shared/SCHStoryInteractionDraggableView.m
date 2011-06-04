//
//  SCHStoryInteractionDraggableView.m
//  Scholastic
//
//  Created by Neil Gall on 03/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionDraggableView.h"
#import "SCHStoryInteractionDraggableTargetView.h"

#define kTitleViewTag 572
#define kSnapDistanceSq 900
#define kTargetOffsetX 12
#define kTargetOffsetY 6

@interface SCHStoryInteractionDraggableView ()

@property (nonatomic, assign) SCHStoryInteractionDraggableTargetView *attachedTarget;
@property (nonatomic, assign) CGPoint touchOffset;
@property (nonatomic, assign) CGPoint originalCenter;
@property (nonatomic, copy) NSArray *targets;

- (void)beginDrag;
- (void)endDrag:(BOOL)cancelled;

@end

@implementation SCHStoryInteractionDraggableView

@synthesize targets;
@synthesize touchOffset;
@synthesize originalCenter;
@synthesize attachedTarget;

- (void)dealloc
{
    [targets release];
    [super dealloc];
}

- (NSString *)title
{
    UILabel *label = (UILabel *)[self viewWithTag:kTitleViewTag];
    return label.text;
}

- (void)setTitle:(NSString *)title
{
    [[self viewWithTag:kTitleViewTag] removeFromSuperview];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.tag = kTitleViewTag;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    label.textAlignment = UITextAlignmentCenter;
    label.text = title;
    [self addSubview:label];
    [label release];
}

- (void)setDragTargets:(NSArray *)dragTargets
{
    self.originalCenter = self.center;
    self.targets = dragTargets;
    [self setUserInteractionEnabled:YES];
}

- (void)layoutSubviews
{
    [self viewWithTag:kTitleViewTag].frame = CGRectMake(0, 12, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)-12);
    [super layoutSubviews];
}

- (void)flashCorrectness
{
    if (!attachedTarget) {
        return;
    }
    UIImage *image = [UIImage imageNamed:(self.tag == self.attachedTarget.tag ? @"storyinteraction-draggable-green" : @"storyinteraction-draggable-red")];
    self.highlightedImage = image;
    [self setHighlighted:YES];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self setHighlighted:NO];
    });
}

#pragma mark - touch support

static CGFloat distanceSq(CGPoint p1, CGPoint p2)
{
    CGFloat dx = p1.x-p2.x;
    CGFloat dy = p1.y-p2.y;
    return dx*dx + dy*dy;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [[touches anyObject] locationInView:self.superview];
    self.touchOffset = CGPointMake(self.center.x - point.x, self.center.y - self.center.y);
    [self beginDrag];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [[touches anyObject] locationInView:self.superview];
    self.center = CGPointMake(point.x + self.touchOffset.x, point.y + self.touchOffset.y);
    
    self.attachedTarget.occupied = NO;
    self.attachedTarget = nil;
    for (SCHStoryInteractionDraggableTargetView *target in self.targets) {
        if (target.occupied) {
            continue;
        }
        CGPoint targetCenter = CGPointMake(target.center.x - kTargetOffsetX, target.center.y);
        CGPoint selfCenter = CGPointMake(self.center.x, self.center.y + kTargetOffsetY);
        if (distanceSq(targetCenter, selfCenter) < kSnapDistanceSq) {
            self.center = CGPointMake(target.center.x - kTargetOffsetX, target.center.y - kTargetOffsetY);
            self.attachedTarget = target;
            self.attachedTarget.occupied = YES;
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // if we don't drop on a target, return to original position
    [self endDrag:(attachedTarget == nil)];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self endDrag:YES];
}

#pragma mark - dragging

- (void)beginDrag
{
    [self.superview bringSubviewToFront:self];
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.transform = CGAffineTransformMakeScale(1.1, 1.1);
                         self.alpha = 0.8;
                     }];
}

- (void)endDrag:(BOOL)cancelled
{
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.transform = CGAffineTransformIdentity;
                         self.alpha = 1;
                         if (cancelled) {
                             self.center = self.originalCenter;
                         }
                     }];
}

@end
