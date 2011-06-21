//
//  SCHStoryInteractionControllerHotSpot.m
//  Scholastic
//
//  Created by Neil Gall on 21/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionControllerHotSpot.h"
#import "SCHStoryInteractionHotSpot.h"
#import "SCHStoryInteractionControllerDelegate.h"

@interface SCHStoryInteractionControllerHotSpot ()

@property (nonatomic, retain) UIView *answerMarkerView;

- (void)incorrectTapAtPoint:(CGPoint)point;
- (void)correctTapAtPoint:(CGPoint)point;

@end

@implementation SCHStoryInteractionControllerHotSpot

@synthesize scrollView;
@synthesize pageImageView;
@synthesize answerMarkerView;

- (void)dealloc
{
    [scrollView release];
    [pageImageView release];
    [answerMarkerView release];
    [super dealloc];
}

- (SCHFrameStyle)frameStyle
{
    return SCHStoryInteractionTitleOverlaysContents;
}

- (CGRect)overlaidTitleFrame
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return CGRectMake(172, 40, 680, 152);
    } else {
        return CGRectMake(0, 0, 480, 64);
    }
}

- (SCHStoryInteractionHotSpotQuestion *)currentQuestion
{
    NSInteger currentQuestionIndex = [self.delegate currentQuestionForStoryInteraction];
    return [[(SCHStoryInteractionHotSpot *)self.storyInteraction questions] objectAtIndex:currentQuestionIndex];
}

- (NSString *)audioPathForQuestion
{
    return [[self currentQuestion] audioPathForQuestion];
}

- (void)setupViewAtIndex:(NSInteger)screenIndex
{
    [self setTitle:[[self currentQuestion] prompt]];
    self.pageImageView.image = [self.delegate currentPageSnapshot];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
    [self.pageImageView addGestureRecognizer:tap];
    [tap release];
}

#pragma mark - scroll view delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.pageImageView;
}

#pragma mark - tapping

- (void)imageTapped:(UITapGestureRecognizer *)tap
{
    [self.answerMarkerView removeFromSuperview];
    self.answerMarkerView = nil;
    
    CGPoint pointInView = [tap locationInView:self.pageImageView];
    CGAffineTransform viewToPageTransform = [self.delegate viewToPageTransformForLayoutPage];
    CGPoint pointInPage = CGPointApplyAffineTransform(pointInView, viewToPageTransform);

    NSLog(@"pointInView:%@ pointInPage:%@ hotSpot:%@",
          NSStringFromCGPoint(pointInView),
          NSStringFromCGPoint(pointInPage),
          NSStringFromCGRect([self currentQuestion].hotSpotRect));
    
    if (CGRectContainsPoint([self currentQuestion].hotSpotRect, pointInPage)) {
        [self correctTapAtPoint:pointInView];
    } else {
        [self incorrectTapAtPoint:pointInView];
    }
}

- (void)incorrectTapAtPoint:(CGPoint)point
{    
    CGFloat scale = 1.0f / self.scrollView.zoomScale;
    UIView *cross = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"storyinteraction-findinpage-wrong"]];
    cross.center = point;
    cross.transform = CGAffineTransformMakeScale(scale, scale);
    
    [self.pageImageView addSubview:cross];
    [self cancelQueuedAudio];
    [self enqueueAudioWithPath:[self.storyInteraction audioPathForTryAgain]
                    fromBundle:NO
                    startDelay:0
        synchronizedStartBlock:nil
          synchronizedEndBlock:^{
              [UIView animateWithDuration:0.25
                                    delay:0
                                  options:UIViewAnimationOptionAllowUserInteraction
                               animations:^{ cross.alpha = 0; }
                               completion:^(BOOL finished) { [cross removeFromSuperview]; }];
          }];
    
    self.answerMarkerView = cross;
    [cross release];
}

- (CGPoint)starsImageCenterForPoint:(CGPoint)point
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return CGPointMake(point.x-24, point.y-51);
    } else {
        return CGPointMake(point.x-26, point.y-51);
    }
}

- (void)correctTapAtPoint:(CGPoint)point
{
    CGFloat scale = 1.0f / self.scrollView.zoomScale;
    UIView *stars = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"storyInteraction-findinpage-correct"]];
    stars.center = [self starsImageCenterForPoint:point];
    stars.transform = CGAffineTransformMakeScale(scale, scale);
    
    [self.pageImageView addSubview:stars];
    [self cancelQueuedAudio];
    [self enqueueAudioWithPath:[self.storyInteraction audioPathForThatsRight] fromBundle:NO];
    [self enqueueAudioWithPath:[[self currentQuestion] audioPathForCorrectAnswer]
                    fromBundle:NO
                    startDelay:0.5
        synchronizedStartBlock:nil
          synchronizedEndBlock:^{
              [self removeFromHostViewWithSuccess:YES];
          }];
    
    self.answerMarkerView = stars;
    [stars release];
}

@end
