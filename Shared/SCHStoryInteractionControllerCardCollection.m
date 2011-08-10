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
#import "NSArray+ViewSorting.h"
#import "SCHAnimationDelegate.h"

enum {
    kCardImageViewTag = 99
};

@interface SCHStoryInteractionControllerCardCollection ()

@property (nonatomic, retain) UIImageView *selectedCardView;
@property (nonatomic, retain) CALayer *zoomCardLayer;
@property (nonatomic, retain) NSArray *scrollSublayers;

- (void)showZoomedCardButtons;
- (void)hideZoomedCardButtonsAnimated:(BOOL)animated;
- (void)setPurpleBorderOnLayer:(CALayer *)layer;
- (CALayer *)cardLayerWithFront:(UIImage *)front back:(UIImage *)back size:(CGSize)size;
- (void)showCardsInScrollViewAtIndex:(NSInteger)index;
- (void)hideScrollView;
- (void)updateZoomButtons;
- (void)updateZoomedLayer;

@end

@implementation SCHStoryInteractionControllerCardCollection

@synthesize cardViews;
@synthesize perspectiveView;
@synthesize zoomedCardButtons;
@synthesize zoomedCardScrollView;
@synthesize scrollContentView;
@synthesize selectedCardView;
@synthesize zoomCardLayer;
@synthesize scrollSublayers;

- (void)dealloc
{
    [cardViews release], cardViews = nil;
    [perspectiveView release], perspectiveView = nil;
    [zoomedCardButtons release], zoomedCardButtons = nil;
    [zoomedCardScrollView release], zoomedCardScrollView = nil;
    [scrollContentView release], scrollContentView = nil;
    [zoomCardLayer release], zoomCardLayer = nil;
    [selectedCardView release], selectedCardView = nil;
    [scrollSublayers release], scrollSublayers = nil;
    [super dealloc];
}


- (BOOL)shouldPresentInPortraitOrientation
{
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
}

- (void)setupViewAtIndex:(NSInteger)screenIndex
{
    SCHStoryInteractionCardCollection *cardCollection = (SCHStoryInteractionCardCollection *)self.storyInteraction;

    [self hideZoomedCardButtonsAnimated:NO];
    self.cardViews = [self.cardViews viewsInRowMajorOrder];
    
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
    
    [self.zoomedCardScrollView setHidden:YES];
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

- (void)showZoomedCardButtons
{
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         for (UIButton *button in self.zoomedCardButtons) {
                             button.userInteractionEnabled = YES;
                             button.alpha = 1;
                         }
                     }
                     completion:nil];
}

- (void)hideZoomedCardButtonsAnimated:(BOOL)animated
{
    dispatch_block_t block = ^{
        for (UIButton *button in self.zoomedCardButtons) {
            button.userInteractionEnabled = NO;
            button.alpha = 0;
        }
    };
    
    if (animated) {
        [UIView animateWithDuration:0.2
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:block
                         completion:nil];
    } else {
        block();
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

    CGFloat verticalSpace = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 30 : 40;
    CGFloat height = CGRectGetHeight(self.contentsView.bounds) - verticalSpace;
    CGFloat width = height * CGRectGetWidth(self.selectedCardView.bounds) / CGRectGetHeight(self.selectedCardView.bounds);
    
    self.zoomCardLayer = [self cardLayerWithFront:self.selectedCardView.image back:backImage size:CGSizeMake(width, height)];
    self.zoomCardLayer.position = CGPointMake(floorf(CGRectGetMidX(self.contentsView.bounds)),
                                              floorf(CGRectGetMidY(self.contentsView.bounds)));
    
    // replace the UIView layer with the zooming layer in a single transaction
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [self.perspectiveView.layer addSublayer:self.zoomCardLayer];
    tap.view.layer.opacity = 0;
    [CATransaction commit];

    // zoom card from current position
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
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    group.delegate = [SCHAnimationDelegate animationDelegateWithStopBlock:^(CAAnimation *animation, BOOL finished) {
        [self showZoomedCardButtons];
        [self showCardsInScrollViewAtIndex:tap.view.tag];
    }];
    
    [self.zoomCardLayer addAnimation:group forKey:@"zoomIn"];
    
    // hide other card views
    [UIView animateWithDuration:0.2
                     animations:^{
                         for (UIView *view in self.cardViews) {
                             view.alpha = 0;
                         }
                     }];
}

- (void)zoomOut:(id)sender
{
    if (self.zoomCardLayer == nil) {
        return;
    }
    
    if (self.zoomedCardScrollView) {
        [self hideScrollView];
        self.zoomCardLayer.position = CGPointMake(floorf(CGRectGetMidX(self.perspectiveView.bounds)),
                                                  floorf(CGRectGetMidY(self.perspectiveView.bounds)));
        [self.perspectiveView.layer addSublayer:self.zoomCardLayer];
    }

    CATransform3D scale = CATransform3DMakeScale(CGRectGetWidth(self.selectedCardView.bounds)/CGRectGetWidth(self.zoomCardLayer.bounds),
                                                 CGRectGetHeight(self.selectedCardView.bounds)/CGRectGetHeight(self.zoomCardLayer.bounds),
                                                 1);
    CATransform3D flip = CATransform3DMakeRotation(M_PI, 0, 1, 0);
    BOOL showingFront = CATransform3DIsIdentity(self.zoomCardLayer.transform);
    
    CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform"];
    rotate.fromValue = [NSValue valueWithCATransform3D:showingFront ? CATransform3DIdentity : flip];
    rotate.toValue = [NSValue valueWithCATransform3D:scale];
    
    CABasicAnimation *position = [CABasicAnimation animationWithKeyPath:@"position"];
    position.fromValue = [NSValue valueWithCGPoint:self.zoomCardLayer.position];
    position.toValue = [NSValue valueWithCGPoint:[self.selectedCardView convertPoint:self.selectedCardView.center toView:self.contentsView]];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = [NSArray arrayWithObjects:rotate, position, nil];
    group.duration = 0.5;
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
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

    [self hideZoomedCardButtonsAnimated:YES];

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

- (void)setPurpleBorderOnLayer:(CALayer *)layer
{
    layer.borderWidth = 2;
    layer.borderColor = [[UIColor SCHPurple1Color] CGColor];
    layer.cornerRadius = 4;
    layer.masksToBounds = YES;
}

- (CALayer *)cardLayerWithFront:(UIImage *)frontImage back:(UIImage *)backImage size:(CGSize)size
{
    CATransformLayer *cardLayer = [CATransformLayer layer];
    cardLayer.bounds = CGRectIntegral((CGRect){CGPointZero, size});
    
    CALayer *front = [CALayer layer];
    front.contents = (id)[frontImage CGImage];
    front.bounds = cardLayer.bounds;
    front.position = CGPointMake(floorf(size.width/2), floorf(size.height/2));
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
    
    [cardLayer addSublayer:back];
    [cardLayer addSublayer:front];

    return cardLayer;
}

- (void)flip:(UIButton *)sender
{
    if ([self.zoomCardLayer animationForKey:@"flip"] != nil) {
        return;
    }
    
    BOOL showingFront = CATransform3DIsIdentity(self.zoomCardLayer.transform);
    CATransform3D toTransform = showingFront ? CATransform3DMakeRotation(M_PI, 0, 1, 0) : CATransform3DIdentity;

    CABasicAnimation *flip = [CABasicAnimation animationWithKeyPath:@"transform"];
    flip.fromValue = [NSValue valueWithCATransform3D:self.zoomCardLayer.transform];
    flip.toValue = [NSValue valueWithCATransform3D:toTransform];
    flip.duration = 0.5;
    flip.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    self.zoomCardLayer.transform = toTransform;
    [self.zoomCardLayer addAnimation:flip forKey:@"flip"];
}

#pragma mark - Scroll view

- (void)previousCard:(id)sender
{
    CGPoint contentOffset = self.zoomedCardScrollView.contentOffset;
    CGFloat width = CGRectGetWidth(self.zoomedCardScrollView.bounds);
    NSInteger cardIndex = contentOffset.x / width;
    if (cardIndex > 0) {
        contentOffset.x = (cardIndex-1) * width;
        [self.zoomedCardScrollView setContentOffset:contentOffset animated:YES];
    }
}

- (void)nextCard:(id)sender
{
    CGPoint contentOffset = self.zoomedCardScrollView.contentOffset;
    CGFloat width = CGRectGetWidth(self.zoomedCardScrollView.bounds);
    NSInteger cardIndex = contentOffset.x / width;
    if (cardIndex < [self.scrollSublayers count]-1) {
        contentOffset.x = (cardIndex+1) * width;
        [self.zoomedCardScrollView setContentOffset:contentOffset animated:YES];
    }
}

- (void)showCardsInScrollViewAtIndex:(NSInteger)index
{
    if (!self.zoomedCardScrollView) {
        return;
    }
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];

    SCHStoryInteractionCardCollection *cardCollection = (SCHStoryInteractionCardCollection *)self.storyInteraction;
    const NSInteger numCards = [cardCollection numberOfCards];
    const CGSize cardSize = self.zoomCardLayer.bounds.size;
    NSInteger gap = CGRectGetWidth(self.contentsView.bounds) - cardSize.width;

    NSInteger x = cardSize.width/2 + CGRectGetMinX(self.zoomCardLayer.frame);
    NSInteger y = cardSize.height/2 + CGRectGetMinY(self.zoomCardLayer.frame);
    NSMutableArray *sublayers = [NSMutableArray arrayWithCapacity:numCards];
    
    for (NSInteger cardIndex = 0; cardIndex < numCards; ++cardIndex) {
        UIImage *frontImage = [self imageAtPath:[cardCollection imagePathForCardFrontAtIndex:cardIndex]];
        UIImage *backImage = [self imageAtPath:[cardCollection imagePathForCardBackAtIndex:cardIndex]];
        if (!frontImage || !backImage) {
            continue;
        }
        CALayer *cardLayer = [self cardLayerWithFront:frontImage back:backImage size:cardSize];
        cardLayer.position = CGPointMake(x, y);
        [self.scrollContentView.layer addSublayer:cardLayer];
        [sublayers addObject:cardLayer];
        x += cardSize.width + gap;
    }
    
    self.scrollSublayers = [NSArray arrayWithArray:sublayers];
    self.zoomedCardScrollView.contentSize = CGSizeMake((cardSize.width+gap)*[sublayers count], cardSize.height);
    self.scrollContentView.frame = (CGRect){CGPointZero, self.zoomedCardScrollView.contentSize};

    // replace zoom layer with scroller
    [self.zoomCardLayer removeFromSuperlayer];
    self.zoomCardLayer = [self.scrollSublayers objectAtIndex:index];

    [self.zoomedCardScrollView setHidden:NO];
    [self.zoomedCardScrollView setContentOffset:CGPointMake((cardSize.width+gap)*index, 0) animated:NO];
    [CATransaction commit];
    
    // adjust the view order
    [self.contentsView bringSubviewToFront:self.perspectiveView];
    for (UIButton *button in self.zoomedCardButtons) {
        [self.contentsView bringSubviewToFront:button];
    }
}

- (void)hideScrollView
{
    [self.contentsView sendSubviewToBack:self.perspectiveView];
    [self.zoomedCardScrollView setHidden:YES];
    [self.scrollSublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    self.scrollSublayers = nil;
}

- (void)updateZoomButtons
{
    if (self.zoomedCardScrollView.zoomScale > 1.0) {
        [self hideZoomedCardButtonsAnimated:YES];
    } else {
        [self showZoomedCardButtons];
    }
}

- (void)updateZoomedLayer
{
    CGFloat width = CGRectGetWidth(self.zoomedCardScrollView.bounds);
    NSInteger cardIndex = (self.zoomedCardScrollView.contentOffset.x + width/2) / width;
    cardIndex = MAX(0, MIN([self.scrollSublayers count]-1, cardIndex));
    self.zoomCardLayer = [self.scrollSublayers objectAtIndex:cardIndex];
    self.selectedCardView = (UIImageView *)[[self.cardViews objectAtIndex:cardIndex] viewWithTag:kCardImageViewTag];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self hideZoomedCardButtonsAnimated:YES];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self updateZoomButtons];
        [self updateZoomedLayer];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self updateZoomButtons];
    [self updateZoomedLayer];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self updateZoomButtons];
    [self updateZoomedLayer];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.scrollContentView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    [self updateZoomButtons];
}

@end
