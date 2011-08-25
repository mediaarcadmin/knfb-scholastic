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
#import "SCHGeometry.h"

enum {
    kZoomOutButtonTag = 42,
    kPreviousCardButtonTag = 97,
    kNextCardButtonTag = 98,
    kCardImageViewTag = 99
};

@interface SCHStoryInteractionControllerCardCollection ()

@property (nonatomic, retain) UIImageView *selectedCardView;
@property (nonatomic, retain) CALayer *cardLayer;
@property (nonatomic, retain) NSArray *scrollSublayers;

- (void)zoomToCardLayerFromView:(UIView *)view;
- (void)showCardButtons;
- (void)hideCardButtonsIncludingZoomout:(BOOL)hideZoomOutButton animated:(BOOL)animated;
- (void)setPurpleBorderOnLayer:(CALayer *)layer;
- (CALayer *)cardLayerWithFront:(UIImage *)front back:(UIImage *)back size:(CGSize)size;
- (void)showCardsInScrollViewAtIndex:(NSInteger)index;
- (void)hideScrollView;
- (void)syncCardLayerWithScrollView;

@end

@implementation SCHStoryInteractionControllerCardCollection

@synthesize cardViews;
@synthesize perspectiveView;
@synthesize cardButtons;
@synthesize cardScrollView;
@synthesize scrollContentView;
@synthesize zoomScrollView;
@synthesize zoomContentView;
@synthesize selectedCardView;
@synthesize cardLayer;
@synthesize scrollSublayers;

- (void)dealloc
{
    [cardViews release], cardViews = nil;
    [perspectiveView release], perspectiveView = nil;
    [cardButtons release], cardButtons = nil;
    [cardScrollView release], cardScrollView = nil;
    [scrollContentView release], scrollContentView = nil;
    [zoomScrollView release], zoomScrollView = nil;
    [zoomContentView release], zoomContentView = nil;
    [cardLayer release], cardLayer = nil;
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

    self.titleView.adjustsFontSizeToFitWidth = YES;
    self.titleView.numberOfLines = 1;
    
    [self hideCardButtonsIncludingZoomout:YES animated:NO];
    self.zoomScrollView.hidden = YES;
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
    
    [self.cardScrollView setHidden:YES];
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

- (void)showCardButtons
{
    const BOOL isFirstCard = ([self.scrollSublayers objectAtIndex:0] == self.cardLayer);
    const BOOL isLastCard = ([self.scrollSublayers lastObject] == self.cardLayer);
    
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         for (UIButton *button in self.cardButtons) {
                             if ((button.tag == kPreviousCardButtonTag && isFirstCard)
                                 || (button.tag == kNextCardButtonTag && isLastCard)) {
                                 continue;
                             }
                             button.userInteractionEnabled = YES;
                             button.alpha = 1;
                         }
                     }
                     completion:nil];
}

- (void)hideCardButtonsIncludingZoomout:(BOOL)hideZoomOutButton animated:(BOOL)animated
{
    dispatch_block_t block = ^{
        for (UIButton *button in self.cardButtons) {
            if (button.tag != kZoomOutButtonTag || hideZoomOutButton) {
                button.userInteractionEnabled = NO;
                button.alpha = 0;
            }
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
    if (self.cardLayer != nil) {
        return;
    }

    // hide other card views
    [UIView animateWithDuration:0.2
                     animations:^{
                         for (UIView *view in self.cardViews) {
                             if (view != tap.view) {
                                 view.alpha = 0;
                             }
                         }
                     }
                     completion:^(BOOL finished) {
                         [self zoomToCardLayerFromView:tap.view];
                     }];
}

- (void)zoomToCardLayerFromView:(UIView *)cardView
{
   SCHStoryInteractionCardCollection *cardCollection = (SCHStoryInteractionCardCollection *)self.storyInteraction;
    UIImage *backImage = [self imageAtPath:[cardCollection imagePathForCardBackAtIndex:cardView.tag]];

    self.selectedCardView = (UIImageView *)[cardView viewWithTag:kCardImageViewTag];

    CGFloat verticalSpace = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 30 : 40;
    CGFloat height = CGRectGetHeight(self.contentsView.bounds) - verticalSpace;
    CGFloat width = height * CGRectGetWidth(self.selectedCardView.bounds) / CGRectGetHeight(self.selectedCardView.bounds);
    
    self.cardLayer = [self cardLayerWithFront:self.selectedCardView.image back:backImage size:CGSizeMake(width, height)];
    self.cardLayer.position = [self.selectedCardView convertPoint:self.selectedCardView.center toView:self.contentsView];
    
    // replace the UIView layer with the zooming layer in a single transaction
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [self.perspectiveView.layer addSublayer:self.cardLayer];
    cardView.layer.opacity = 0;
    
    // zoom card from current position
    self.cardLayer.transform = CATransform3DMakeScale(CGRectGetWidth(self.selectedCardView.bounds)/width,
                                                      CGRectGetHeight(self.selectedCardView.bounds)/height,
                                                      1);
    
    CABasicAnimation *scaleAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
    scaleAnim.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    scaleAnim.fillMode = kCAFillModeForwards;
    
    CABasicAnimation *positionAnim = [CABasicAnimation animationWithKeyPath:@"position"];
    positionAnim.toValue = [NSValue valueWithCGPoint:CGPointMake(floorf(CGRectGetMidX(self.perspectiveView.bounds)),
                                                                 floorf(CGRectGetMidY(self.perspectiveView.bounds)))];
    positionAnim.fillMode = kCAFillModeForwards;

    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = [NSArray arrayWithObjects:scaleAnim, positionAnim, nil];
    group.duration = 0.5;
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    group.removedOnCompletion = NO;
    group.fillMode = kCAFillModeForwards;
    group.delegate = [SCHAnimationDelegate animationDelegateWithStopBlock:^(CAAnimation *animation, BOOL finished) {
        [self.cardLayer removeAllAnimations];
        [self showCardsInScrollViewAtIndex:cardView.tag];
        [self showCardButtons];
    }];
    
    [self.cardLayer addAnimation:group forKey:@"zoomIn"];
    [CATransaction commit];
}

- (void)zoomOut:(id)sender
{
    if (self.cardLayer == nil) {
        return;
    }
    
    if (self.zoomScrollView != nil && ![self.zoomScrollView isHidden]) {
        [self.zoomScrollView setZoomScale:1.0f animated:YES];
        return;
    }
    
    if (self.cardScrollView) {
        [self hideScrollView];
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.cardLayer.position = CGPointMake(floorf(CGRectGetMidX(self.perspectiveView.bounds)),
                                                  floorf(CGRectGetMidY(self.perspectiveView.bounds)));
        [self.perspectiveView.layer addSublayer:self.cardLayer];
        [CATransaction commit];
    }

    CATransform3D scale = CATransform3DMakeScale(CGRectGetWidth(self.selectedCardView.bounds)/CGRectGetWidth(self.cardLayer.bounds),
                                                 CGRectGetHeight(self.selectedCardView.bounds)/CGRectGetHeight(self.cardLayer.bounds),
                                                 1);
    CATransform3D flip = CATransform3DMakeRotation(M_PI, 0, 1, 0);
    BOOL showingFront = CATransform3DIsIdentity(self.cardLayer.transform);
    
    CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform"];
    rotate.fromValue = [NSValue valueWithCATransform3D:showingFront ? CATransform3DIdentity : flip];
    rotate.toValue = [NSValue valueWithCATransform3D:scale];
    
    CABasicAnimation *position = [CABasicAnimation animationWithKeyPath:@"position"];
    position.fromValue = [NSValue valueWithCGPoint:self.cardLayer.position];
    position.toValue = [NSValue valueWithCGPoint:[self.selectedCardView convertPoint:self.selectedCardView.center toView:self.contentsView]];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = [NSArray arrayWithObjects:rotate, position, nil];
    group.duration = 0.5;
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    group.delegate = [SCHAnimationDelegate animationDelegateWithStopBlock:^(CAAnimation *animation, BOOL finished) {
        // replace the zooming layer with the original one in a single transaction
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        [self.cardLayer removeFromSuperlayer];
        self.cardLayer = nil;
        self.selectedCardView.superview.layer.opacity = 1.0;
        self.selectedCardView = nil;
        [CATransaction commit];
        
        [UIView animateWithDuration:0.2
                         animations:^{
                             for (UIView *view in self.cardViews) {
                                 if (view != self.selectedCardView.superview) {
                                     view.alpha = 1.0;
                                 }
                             }
                         }];
    }];
    
    self.cardLayer.transform = CATransform3DConcat(scale, flip);
    self.cardLayer.position = [self.selectedCardView convertPoint:self.selectedCardView.center toView:self.contentsView];
    [self.cardLayer addAnimation:group forKey:@"zoomOut"];

    [self hideCardButtonsIncludingZoomout:YES animated:YES];
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
    CATransformLayer *layer = [CATransformLayer layer];
    layer.bounds = CGRectIntegral((CGRect){CGPointZero, size});
    
    CALayer *front = [CALayer layer];
    front.contents = (id)[frontImage CGImage];
    front.bounds = layer.bounds;
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
    
    [layer addSublayer:back];
    [layer addSublayer:front];

    return layer;
}

- (void)flip:(UIButton *)sender
{
    if ([self.cardLayer animationForKey:@"flip"] != nil) {
        return;
    }
    
    BOOL showingFront = CATransform3DIsIdentity(self.cardLayer.transform);
    CATransform3D toTransform = showingFront ? CATransform3DMakeRotation(M_PI, 0, 1, 0) : CATransform3DIdentity;

    CABasicAnimation *flip = [CABasicAnimation animationWithKeyPath:@"transform"];
    flip.fromValue = [NSValue valueWithCATransform3D:self.cardLayer.transform];
    flip.toValue = [NSValue valueWithCATransform3D:toTransform];
    flip.duration = 0.5;
    flip.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    self.cardLayer.transform = toTransform;
    [self.cardLayer addAnimation:flip forKey:@"flip"];
}

#pragma mark - Card scroll view

- (void)previousCard:(id)sender
{
    CGPoint contentOffset = self.cardScrollView.contentOffset;
    CGFloat width = CGRectGetWidth(self.cardScrollView.bounds);
    NSInteger cardIndex = contentOffset.x / width;
    if (cardIndex > 0) {
        contentOffset.x = (cardIndex-1) * width;
        [self.cardScrollView setContentOffset:contentOffset animated:YES];
    }
}

- (void)nextCard:(id)sender
{
    CGPoint contentOffset = self.cardScrollView.contentOffset;
    CGFloat width = CGRectGetWidth(self.cardScrollView.bounds);
    NSInteger cardIndex = contentOffset.x / width;
    if (cardIndex < [self.scrollSublayers count]-1) {
        contentOffset.x = (cardIndex+1) * width;
        [self.cardScrollView setContentOffset:contentOffset animated:YES];
    }
}

- (void)showCardsInScrollViewAtIndex:(NSInteger)index
{
    if (!self.cardScrollView) {
        return;
    }
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];

    SCHStoryInteractionCardCollection *cardCollection = (SCHStoryInteractionCardCollection *)self.storyInteraction;
    const NSInteger numCards = [cardCollection numberOfCards];
    const CGSize cardSize = self.cardLayer.bounds.size;
    const CGFloat width = CGRectGetWidth(self.contentsView.bounds);

    CGPoint position = CGPointMake(floorf(CGRectGetMidX(self.perspectiveView.bounds)),
                                   floorf(CGRectGetMidY(self.perspectiveView.bounds)));
    NSMutableArray *sublayers = [NSMutableArray arrayWithCapacity:numCards];
    
    for (NSInteger cardIndex = 0; cardIndex < numCards; ++cardIndex) {
        UIImage *frontImage = [self imageAtPath:[cardCollection imagePathForCardFrontAtIndex:cardIndex]];
        UIImage *backImage = [self imageAtPath:[cardCollection imagePathForCardBackAtIndex:cardIndex]];
        if (!frontImage || !backImage) {
            continue;
        }
        CALayer *layer = [self cardLayerWithFront:frontImage back:backImage size:cardSize];
        layer.position = position;
        [self.scrollContentView.layer addSublayer:layer];
        [sublayers addObject:layer];
        position.x += width;
    }
    
    self.scrollSublayers = [NSArray arrayWithArray:sublayers];
    self.cardScrollView.contentSize = CGSizeMake(width*[sublayers count], cardSize.height);
    self.scrollContentView.frame = (CGRect){CGPointZero, self.cardScrollView.contentSize};

    // replace zoom layer with scroller
    [self.cardLayer removeFromSuperlayer];
    self.cardLayer = [self.scrollSublayers objectAtIndex:index];

    [self.cardScrollView setHidden:NO];
    [self.cardScrollView setContentOffset:CGPointMake(width*index, 0) animated:NO];
    [CATransaction commit];
    
    // adjust the view order
    [self.contentsView bringSubviewToFront:self.perspectiveView];
    for (UIButton *button in self.cardButtons) {
        [self.contentsView bringSubviewToFront:button];
    }
}

- (void)hideScrollView
{
    [self.contentsView sendSubviewToBack:self.perspectiveView];
    [self.cardScrollView setHidden:YES];
    [self.scrollSublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    self.scrollSublayers = nil;
}

- (void)syncCardLayerWithScrollView
{
    CGFloat width = CGRectGetWidth(self.cardScrollView.bounds);
    NSInteger cardIndex = (self.cardScrollView.contentOffset.x + width/2) / width;
    cardIndex = MAX(0, MIN([self.scrollSublayers count]-1, cardIndex));
    self.cardLayer = [self.scrollSublayers objectAtIndex:cardIndex];
    self.selectedCardView = (UIImageView *)[[self.cardViews objectAtIndex:cardIndex] viewWithTag:kCardImageViewTag];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == self.cardScrollView) {
        [self hideCardButtonsIncludingZoomout:YES animated:YES];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView == self.cardScrollView && !decelerate) {
        [self syncCardLayerWithScrollView];
        [self showCardButtons];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.cardScrollView) {
        [self syncCardLayerWithScrollView];
        [self showCardButtons];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (scrollView == self.cardScrollView) {
        [self syncCardLayerWithScrollView];
        [self showCardButtons];
    }
}

#pragma mark - Zoom view

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if (scrollView == self.zoomScrollView) {
        return self.zoomContentView;
    }
    return nil;
}

- (void)zoomIn:(id)sender
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    // duplicate the visible layer in the zoom view
    BOOL showingFront = CATransform3DIsIdentity(self.cardLayer.transform);
    CALayer *visibleLayer = [self.cardLayer.sublayers objectAtIndex:showingFront ? 1 : 0];
    self.zoomContentView.layer.contents = visibleLayer.contents;
    self.zoomContentView.layer.bounds = self.cardLayer.bounds;
    [CATransaction commit];

    self.zoomScrollView.contentSize = self.zoomContentView.bounds.size;
    self.zoomScrollView.minimumZoomScale = CGRectGetWidth(self.cardLayer.bounds) / CGRectGetWidth(self.zoomScrollView.bounds);
    
    [self.perspectiveView setHidden:YES];
    [self.zoomScrollView setHidden:NO];
    [self.zoomScrollView setZoomScale:1.0f animated:NO];
    [self.zoomScrollView setZoomScale:2.0f animated:YES];
    [self hideCardButtonsIncludingZoomout:NO animated:YES];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    if (scrollView == self.zoomScrollView) {
        if (scale <= 1.0f) {
            [self.zoomScrollView setHidden:YES];
            [self.perspectiveView setHidden:NO];
            [self showCardButtons];
        }
        else if (scale < 1.5f) {
            [self.zoomScrollView setZoomScale:1.0f animated:YES];
        }
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    if (scrollView == self.zoomScrollView) {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        if (scrollView.zoomScale <= 1.0f) {
            // center the card
            CGAffineTransform scale = CGAffineTransformMakeScale(scrollView.zoomScale, scrollView.zoomScale);
            CGRect effectiveRect = CGRectApplyAffineTransform(self.zoomContentView.frame, scale);
            CGRect frame = SCHCGRectForSizeCenteredInCGRect(effectiveRect.size, scrollView.bounds);
            self.zoomContentView.layer.position = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
        } else {
            self.zoomContentView.layer.position = CGPointMake(CGRectGetMidX(self.zoomContentView.layer.bounds)*scrollView.zoomScale,
                                                              CGRectGetMidY(self.zoomContentView.layer.bounds)*scrollView.zoomScale);
        }
        [CATransaction commit];
    }
}

@end
