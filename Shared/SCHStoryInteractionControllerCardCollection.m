//
//  SCHStoryInteractionControllerCardCollection.m
//  Scholastic
//
//  Created by Neil Gall on 03/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionControllerCardCollection.h"
#import "SCHStoryInteractionCardCollection.h"
#import "UIColor+Scholastic.h"

enum {
    kCardImageViewTag = 99
};

@interface SCHStoryInteractionControllerCardCollection ()
@property (nonatomic, retain) UIImageView *selectedCardView;
@property (nonatomic, retain) CATransformLayer *zoomCardLayer;
@end

@implementation SCHStoryInteractionControllerCardCollection

@synthesize cardViews;
@synthesize selectedCardView;
@synthesize zoomCardLayer;

- (void)dealloc
{
    [cardViews release], cardViews = nil;
    [zoomCardLayer release], zoomCardLayer = nil;
    [selectedCardView release], selectedCardView = nil;
    [super dealloc];
}

- (void)setPurpleBorderOnLayer:(CALayer *)layer
{
    layer.borderWidth = 2;
    layer.borderColor = [[UIColor SCHPurple1Color] CGColor];
    layer.cornerRadius = 4;
    layer.masksToBounds = YES;
}

- (void)setupViewAtIndex:(NSInteger)screenIndex
{
    SCHStoryInteractionCardCollection *cardCollection = (SCHStoryInteractionCardCollection *)self.storyInteraction;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentsViewTapped:)];
    [self.contentsView addGestureRecognizer:tap];
    [self.contentsView setUserInteractionEnabled:YES];
    [tap release];
    
    for (NSInteger i = 0, n = MIN([self.cardViews count], [cardCollection numberOfCards]); i < n; ++i) {
        UIView *cardView = [self.cardViews objectAtIndex:i];
        cardView.tag = i;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cardTapped:)];
        [cardView addGestureRecognizer:tap];
        [tap release];
        
        UIImageView *imageView = (UIImageView *)[cardView viewWithTag:kCardImageViewTag];
        imageView.image = [self imageAtPath:[cardCollection imagePathForCardBackAtIndex:i]];
        [self setPurpleBorderOnLayer:imageView.layer];
    }
}

- (void)cardTapped:(UITapGestureRecognizer *)tap
{
    if (self.zoomCardLayer != nil) {
        return;
    }
    
    SCHStoryInteractionCardCollection *cardCollection = (SCHStoryInteractionCardCollection *)self.storyInteraction;
    UIImage *frontImage = [self imageAtPath:[cardCollection imagePathForCardFrontAtIndex:tap.view.tag]];

    self.selectedCardView = (UIImageView *)[tap.view viewWithTag:kCardImageViewTag];

    CGFloat height = CGRectGetHeight(self.contentsView.bounds) - 40;
    CGFloat width = height * CGRectGetWidth(self.selectedCardView.bounds) / CGRectGetHeight(self.selectedCardView.bounds);
    
    self.zoomCardLayer = [CATransformLayer layer];
    self.zoomCardLayer.bounds = CGRectMake(0, 0, width, height);
    self.zoomCardLayer.position = CGPointMake(CGRectGetMidX(self.contentsView.bounds), CGRectGetMidY(self.contentsView.bounds));
    self.zoomCardLayer.zPosition = CGFLOAT_MAX;
    [self.contentsView.layer addSublayer:self.zoomCardLayer];

    CALayer *front = [CALayer layer];
    front.contents = (id)[frontImage CGImage];
    front.bounds = self.zoomCardLayer.bounds;
    front.position = CGPointMake(floorf(width/2), floorf(height/2));
    front.transform = CATransform3DIdentity;
    front.doubleSided = NO;
    [self setPurpleBorderOnLayer:front];
    
    CALayer *back = [CALayer layer];
    back.contents = (id)[self.selectedCardView.image CGImage];
    back.bounds = front.bounds;
    back.position = front.position;
    back.transform = CATransform3DMakeRotation(M_PI, 0, 1, 0);
    back.doubleSided = NO;
    [self setPurpleBorderOnLayer:back];

    [self.zoomCardLayer addSublayer:back];
    [self.zoomCardLayer addSublayer:front];

    CATransform3D scale = CATransform3DMakeScale(CGRectGetWidth(self.selectedCardView.bounds)/width,
                                                 CGRectGetHeight(self.selectedCardView.bounds)/height,
                                                 1);
    CATransform3D flip = CATransform3DMakeRotation(M_PI, 0, 1, 0);
    
    CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform"];
    rotate.fromValue = [NSValue valueWithCATransform3D:CATransform3DConcat(scale, flip)];
    rotate.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    
    CABasicAnimation *position = [CABasicAnimation animationWithKeyPath:@"position"];
    position.fromValue = [NSValue valueWithCGPoint:[self.selectedCardView convertPoint:self.selectedCardView.center toView:self.contentsView]];
    position.toValue = [NSValue valueWithCGPoint:self.zoomCardLayer.position];

    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = [NSArray arrayWithObjects:rotate, position, nil];
    group.duration = 0.5;
    
    [self.zoomCardLayer addAnimation:group forKey:@"zoomIn"];

    tap.view.hidden = YES;
    [UIView animateWithDuration:0.2
                     animations:^{
                         for (UIView *view in self.cardViews) {
                             view.alpha = 0.1;
                         }
                     }];
}

- (void)contentsViewTapped:(UITapGestureRecognizer *)tap
{
    if (self.zoomCardLayer == nil) {
        return;
    }

    CATransform3D scale = CATransform3DMakeScale(CGRectGetWidth(self.selectedCardView.bounds)/CGRectGetWidth(self.zoomCardLayer.bounds),
                                                 CGRectGetHeight(self.selectedCardView.bounds)/CGRectGetHeight(self.zoomCardLayer.bounds),
                                                 1);
    CATransform3D flip = CATransform3DMakeRotation(M_PI, 0, 1, 0);
    
    CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform"];
    rotate.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    rotate.toValue = [NSValue valueWithCATransform3D:CATransform3DConcat(scale, flip)];
    
    CABasicAnimation *position = [CABasicAnimation animationWithKeyPath:@"position"];
    position.fromValue = [NSValue valueWithCGPoint:self.zoomCardLayer.position];
    position.toValue = [NSValue valueWithCGPoint:[self.selectedCardView convertPoint:self.selectedCardView.center toView:self.contentsView]];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = [NSArray arrayWithObjects:rotate, position, nil];
    group.duration = 0.5;
    group.delegate = self;
    
    [self.zoomCardLayer addAnimation:group forKey:@"zoomOut"];
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         for (UIView *view in self.cardViews) {
                             view.alpha = 1.0;
                         }
                     }];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    self.selectedCardView.superview.hidden = NO;
    [self.zoomCardLayer removeFromSuperlayer];
    self.zoomCardLayer = nil;
    self.selectedCardView = nil;
}

@end
