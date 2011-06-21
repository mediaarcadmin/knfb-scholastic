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

- (void)incorrectTapAtPoint:(CGPoint)point;
- (void)correctTapAtPoint:(CGPoint)point;

@end

@implementation SCHStoryInteractionControllerHotSpot

@synthesize scrollView;
@synthesize pageImageView;

- (void)dealloc
{
    [scrollView release];
    [pageImageView release];
    [super dealloc];
}

- (SCHFrameStyle)frameStyle
{
    return SCHStoryInteractionTitleOverlaysContents;
}

- (CGRect)overlaidTitleFrame
{
    return CGRectMake(172, 40, 680, 152);
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
    CGPoint p = [tap locationInView:self.pageImageView];
    
    [self incorrectTapAtPoint:p];
}

- (void)incorrectTapAtPoint:(CGPoint)point
{
    UIView *cross = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"storyinteraction-findinpage-wrong"]];
    cross.center = point;
    cross.transform = CGAffineTransformMakeScale(1.0/self.scrollView.zoomScale, 1.0/self.scrollView.zoomScale);
    
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
    [cross release];
}

- (void)correctTapAtPoint:(CGPoint)point
{
    
}

@end
