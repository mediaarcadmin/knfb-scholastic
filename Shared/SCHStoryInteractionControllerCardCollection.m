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
#import "SCHAnimationDelegate.h"

enum {
    kCardImageViewTag = 99
};

@interface SCHStoryInteractionControllerCardCollection ()

@property (nonatomic, retain) UIImageView *selectedCardView;
@property (nonatomic, retain) CATransformLayer *zoomCardLayer;
@property (nonatomic, assign) BOOL showingFront;

- (void)showZoomedCardButtons;
- (void)hideZoomedCardButtons;

@end

@implementation SCHStoryInteractionControllerCardCollection

@synthesize cardViews;
@synthesize perspectiveView;
@synthesize buttonsContainer;
@synthesize selectedCardView;
@synthesize zoomCardLayer;
@synthesize showingFront;

- (void)dealloc
{
    [cardViews release], cardViews = nil;
    [perspectiveView release], perspectiveView = nil;
    [buttonsContainer release], buttonsContainer = nil;
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

    [self.buttonsContainer.superview bringSubviewToFront:self.buttonsContainer];
    self.buttonsContainer.alpha = 0;
    self.buttonsContainer.userInteractionEnabled = NO;
    
    // enable depth in the perspective view so the flip animations look 3D
    CATransform3D sublayerTransform = CATransform3DIdentity;
    sublayerTransform.m34 = 1.0 / -2000;
    self.perspectiveView.layer.sublayerTransform = sublayerTransform;
    
    for (NSInteger i = 0, n = MIN([self.cardViews count], [cardCollection numberOfCards]); i < n; ++i) {
        UIView *cardView = [self.cardViews objectAtIndex:i];
        cardView.tag = i;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cardTapped:)];
        [cardView addGestureRecognizer:tap];
        [tap release];
        
        UIImageView *imageView = (UIImageView *)[cardView viewWithTag:kCardImageViewTag];
        imageView.image = [self imageAtPath:[cardCollection imagePathForCardFrontAtIndex:i]];
        [self setPurpleBorderOnLayer:imageView.layer];
    }
}

- (void)storyInteractionDisableUserInteraction
{
    for (UIView *v in self.cardViews) {
        [v setUserInteractionEnabled:NO];
    }
}

- (void)storyInteractionEnableUserInteraction
{
    for (UIView *v in self.cardViews) {
        [v setUserInteractionEnabled:YES];
    }
}

- (void)cardTapped:(UITapGestureRecognizer *)tap
{
    if (self.zoomCardLayer != nil) {
        return;
    }
    
    SCHStoryInteractionCardCollection *cardCollection = (SCHStoryInteractionCardCollection *)self.storyInteraction;
    UIImage *backImage = [self imageAtPath:[cardCollection imagePathForCardBackAtIndex:tap.view.tag]];

    self.selectedCardView = (UIImageView *)[tap.view viewWithTag:kCardImageViewTag];
    self.showingFront = YES;

    CGFloat height = CGRectGetHeight(self.contentsView.bounds) - 30;
    CGFloat width = height * CGRectGetWidth(self.selectedCardView.bounds) / CGRectGetHeight(self.selectedCardView.bounds);
    
    self.zoomCardLayer = [CATransformLayer layer];
    self.zoomCardLayer.bounds = CGRectIntegral(CGRectMake(0, 0, width, height));
    self.zoomCardLayer.position = CGPointMake(floorf(CGRectGetMidX(self.contentsView.bounds)),
                                              floorf(CGRectGetMidY(self.contentsView.bounds)));

    CALayer *front = [CALayer layer];
    front.contents = (id)[self.selectedCardView.image CGImage];
    front.bounds = self.zoomCardLayer.bounds;
    front.position = CGPointMake(floorf(width/2), floorf(height/2));
    front.transform = CATransform3DIdentity;
    front.doubleSided = NO;
    [self setPurpleBorderOnLayer:front];
    
    CALayer *back = [CALayer layer];
    back.contents = (id)[backImage CGImage];
    back.bounds = front.bounds;
    back.position = front.position;
    back.transform = CATransform3DMakeRotation(M_PI, 0, 1, 0);
    back.doubleSided = NO;
    [self setPurpleBorderOnLayer:back];

    [self.zoomCardLayer addSublayer:back];
    [self.zoomCardLayer addSublayer:front];
    
    // replace the UIView layer with the zooming layer in a single transaction
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [self.perspectiveView.layer addSublayer:self.zoomCardLayer];
    tap.view.layer.opacity = 0;
    [CATransaction commit];

    CATransform3D scale = CATransform3DMakeScale(CGRectGetWidth(self.selectedCardView.bounds)/width,
                                                 CGRectGetHeight(self.selectedCardView.bounds)/height,
                                                 1);    
    CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform"];
    rotate.fromValue = [NSValue valueWithCATransform3D:scale];
    rotate.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    
    CABasicAnimation *position = [CABasicAnimation animationWithKeyPath:@"position"];
    position.fromValue = [NSValue valueWithCGPoint:[self.selectedCardView convertPoint:self.selectedCardView.center toView:self.contentsView]];
    position.toValue = [NSValue valueWithCGPoint:self.zoomCardLayer.position];

    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = [NSArray arrayWithObjects:rotate, position, nil];
    group.duration = 0.5;
    group.delegate = [SCHAnimationDelegate animationDelegateWithStopBlock:^(CAAnimation *animation, BOOL finished) {
        [self showZoomedCardButtons];
    }];
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         for (UIView *view in self.cardViews) {
                             view.alpha = 0;
                         }
                     }];

    [self.zoomCardLayer addAnimation:group forKey:@"zoomIn"];
}

- (void)contentsViewTapped:(UITapGestureRecognizer *)tap
{
    [self zoomOut:nil];
}

- (void)zoomOut:(id)sender
{
    if (self.zoomCardLayer == nil) {
        return;
    }

    CATransform3D scale = CATransform3DMakeScale(CGRectGetWidth(self.selectedCardView.bounds)/CGRectGetWidth(self.zoomCardLayer.bounds),
                                                 CGRectGetHeight(self.selectedCardView.bounds)/CGRectGetHeight(self.zoomCardLayer.bounds),
                                                 1);
    CATransform3D flip = CATransform3DMakeRotation(M_PI, 0, 1, 0);
    
    CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform"];
    rotate.fromValue = [NSValue valueWithCATransform3D:showingFront ? CATransform3DIdentity : flip];
    rotate.toValue = [NSValue valueWithCATransform3D:scale];
    
    CABasicAnimation *position = [CABasicAnimation animationWithKeyPath:@"position"];
    position.fromValue = [NSValue valueWithCGPoint:self.zoomCardLayer.position];
    position.toValue = [NSValue valueWithCGPoint:[self.selectedCardView convertPoint:self.selectedCardView.center toView:self.contentsView]];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = [NSArray arrayWithObjects:rotate, position, nil];
    group.duration = 0.5;
    group.delegate = [SCHAnimationDelegate animationDelegateWithStopBlock:^(CAAnimation *animation, BOOL finished) {
        // replace the zooming layer with the original one in a single transaction
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        [self.zoomCardLayer removeFromSuperlayer];
        self.zoomCardLayer = nil;
        self.selectedCardView.superview.layer.opacity = 1.0;
        self.selectedCardView = nil;
        [CATransaction commit];
    }];
    
    self.zoomCardLayer.transform = CATransform3DConcat(scale, flip);
    self.zoomCardLayer.position = [self.selectedCardView convertPoint:self.selectedCardView.center toView:self.contentsView];
    [self.zoomCardLayer addAnimation:group forKey:@"zoomOut"];

    [self hideZoomedCardButtons];

    NSMutableArray *unselectedCards = [self.cardViews mutableCopy];
    [unselectedCards removeObject:self.selectedCardView.superview];
    
    [UIView animateWithDuration:0.2
                          delay:0.3
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         for (UIView *view in unselectedCards) {
                             view.alpha = 1.0;
                         }
                     }
                     completion:nil];
    
    [unselectedCards release];
}

- (void)flip:(UIButton *)sender
{
    if ([self.zoomCardLayer animationForKey:@"flip"] != nil) {
        return;
    }
    
    self.showingFront = !self.showingFront;
    
    CATransform3D toTransform = self.showingFront ? CATransform3DIdentity : CATransform3DMakeRotation(M_PI, 0, 1, 0);

    CABasicAnimation *flip = [CABasicAnimation animationWithKeyPath:@"transform"];
    flip.fromValue = [NSValue valueWithCATransform3D:self.zoomCardLayer.transform];
    flip.toValue = [NSValue valueWithCATransform3D:toTransform];
    flip.duration = 0.5;
    
    self.zoomCardLayer.transform = toTransform;
    [self.zoomCardLayer addAnimation:flip forKey:@"flip"];
}

- (void)showZoomedCardButtons
{
    self.buttonsContainer.userInteractionEnabled = YES;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.buttonsContainer.alpha = 1;
    }];
}

- (void)hideZoomedCardButtons
{
    self.buttonsContainer.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.25 animations:^{
        self.buttonsContainer.alpha = 0;
    }];
}


@end
