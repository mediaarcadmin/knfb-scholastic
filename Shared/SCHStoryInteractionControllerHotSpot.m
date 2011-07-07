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
#import "SCHStarView.h"

#define kNumberOfStars 20

@interface SCHStoryInteractionControllerHotSpot ()

@property (nonatomic, retain) UIView *answerMarkerView;
@property (nonatomic, copy) dispatch_block_t zoomCompletionHandler;
@property (nonatomic, assign) CGAffineTransform viewToPageTransform;
@property (nonatomic, assign) BOOL isPortraitWithLandscapePresentation;

- (void)updateViewToPageTransform;
- (void)incorrectTapAtPoint:(CGPoint)point;
- (void)correctTapAtPoint:(CGPoint)point;

@end

@implementation SCHStoryInteractionControllerHotSpot

@synthesize scrollView;
@synthesize pageImageView;
@synthesize answerMarkerView;
@synthesize zoomCompletionHandler;
@synthesize viewToPageTransform;
@synthesize isPortraitWithLandscapePresentation;

- (void)dealloc
{
    self.scrollView.delegate = nil;
    [scrollView release];
    [pageImageView release];
    [answerMarkerView release];
    [zoomCompletionHandler release];
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
    
    // If presented in portrait, this SI initially shows the portrait book image. Once
    // rotated to landscape the landscape book image is captured and the SI locks in
    // landscaope mode thereafter.     
    self.isPortraitWithLandscapePresentation = NO;
    if ([self isLandscape]) {
        self.pageImageView.image = [self.delegate currentPageSnapshot];
    } else {
        self.contentsView.backgroundColor = [UIColor clearColor];
    }

    [self updateViewToPageTransform];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
    [self.pageImageView addGestureRecognizer:tap];
    [self.pageImageView setUserInteractionEnabled:YES];
    [tap release];
    
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        self.isPortraitWithLandscapePresentation = YES;
    }
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        self.isPortraitWithLandscapePresentation = NO;
        [self updateViewToPageTransform];
        if (self.pageImageView.image == nil) {
            self.pageImageView.image = [self.delegate currentPageSnapshot];
            self.contentsView.backgroundColor = [UIColor SCHBlackColor];
        }
    }
    [super didRotateToInterfaceOrientation:toInterfaceOrientation];
}

- (void)simulateRotationBackToPortraitAndCloseWithSuccess:(BOOL)success
{
    self.zoomCompletionHandler = ^{
        if (self.isPortraitWithLandscapePresentation) {
            [UIView animateWithDuration:0.3
                             animations:^{
                                 // rotate and scale the left-hand page to fill screen
                                 CGFloat scaleFactor = self.pageImageView.image.size.width / self.pageImageView.image.size.height;
                                 CGAffineTransform scale = CGAffineTransformMakeScale(scaleFactor, scaleFactor);
                                 CGAffineTransform translate = CGAffineTransformMakeTranslation(CGRectGetWidth(self.pageImageView.bounds)/4, 0);
                                 CGAffineTransform rotate = CGAffineTransformMakeRotation(M_PI/2);
                                 self.pageImageView.transform = CGAffineTransformConcat(CGAffineTransformConcat(scale, translate), rotate);
                             }
                             completion:^(BOOL finished) {
                                 // FIXME: change this class to use the state variable
                                 if (success) {
                                     [self didSuccessfullyCompleteInteraction];
                                 }
                                 [self removeFromHostView];
                             }];
        } else {
            // FIXME: change this class to use the state variable
            if (success) {
                [self didSuccessfullyCompleteInteraction];
            }
            [self removeFromHostView];
        }
    };
    
    if (self.scrollView.zoomScale != 1.0f) {
        [self.scrollView setZoomScale:1.0f animated:YES];
    } else {
        self.zoomCompletionHandler();
    }
}

- (void)closeButtonTapped:(id)sender
{
    [self simulateRotationBackToPortraitAndCloseWithSuccess:NO];
}

- (void)updateViewToPageTransform
{
    self.viewToPageTransform = [self.delegate viewToPageTransformForLayoutPage:self.storyInteraction.documentPageNumber];
}

#pragma mark - scroll view delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.pageImageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    if (self.zoomCompletionHandler != nil) {
        dispatch_block_t block = Block_copy(self.zoomCompletionHandler);
        self.zoomCompletionHandler = nil;
        block();
        Block_release(block);
    }
}

#pragma mark - tapping

- (CGPoint)viewToPage:(CGPoint)pointInView;
{
    CGAffineTransform currentViewToPage;
    if (self.isPortraitWithLandscapePresentation) {
        currentViewToPage = self.viewToPageTransform;
    } else {
        currentViewToPage = CGAffineTransformConcat([self affineTransformForCurrentOrientation], self.viewToPageTransform);
    }
    return CGPointApplyAffineTransform(pointInView, currentViewToPage);
}

- (void)imageTapped:(UITapGestureRecognizer *)tap
{
    [self.answerMarkerView removeFromSuperview];
    self.answerMarkerView = nil;

    CGPoint pointInView = [tap locationInView:self.pageImageView];
    CGPoint pointInPage = [self viewToPage:pointInView];

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
    [self enqueueAudioWithPath:[self.storyInteraction storyInteractionWrongAnswerSoundFilename]
                    fromBundle:YES];
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
    [self setUserInteractionsEnabled:NO];
    
    CGFloat scale = 1.0f / self.scrollView.zoomScale;
    UIColor *fillColors[3] = {
        [UIColor SCHGreen2Color],
        [UIColor SCHYellowColor],
        [UIColor SCHOrange1Color]
    };
    BOOL iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    
    NSMutableArray *stars = [NSMutableArray arrayWithCapacity:kNumberOfStars];
    for (NSInteger i = 0; i < kNumberOfStars; ++i) {
        CGFloat angle = M_PI*2 / kNumberOfStars * i;
        CGFloat radius = (arc4random() % (iPad ? 150 : 90));
        CGFloat size = (arc4random() % (iPad ? 25 : 20)) + 5;
        SCHStarView *star = [[SCHStarView alloc] initWithFrame:CGRectZero];
        star.targetPoint = CGPointMake(point.x + cos(angle)*radius, point.y + sin(angle)*radius);
        star.center = CGPointMake(point.x + cos(angle)*3, point.y + sin(angle)*3);
        star.bounds = CGRectMake(0, 0, size, size);
        star.fillColor = fillColors[arc4random()%3];
        star.borderColor = [UIColor SCHGreen1Color];        
        star.backgroundColor = [UIColor clearColor];
        star.transform = CGAffineTransformRotate(CGAffineTransformMakeScale(scale, scale), angle);
        [self.pageImageView addSubview:star];
        [stars addObject:star];
    }

    [UIView animateWithDuration:0.7
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         [stars makeObjectsPerformSelector:@selector(animateToTargetPoint)];
                     }
                     completion:^(BOOL finished) {
                         [stars makeObjectsPerformSelector:@selector(removeFromSuperview)];
                     }];
    
    [self cancelQueuedAudio];
    [self enqueueAudioWithPath:[self.storyInteraction storyInteractionCorrectAnswerSoundFilename]
                    fromBundle:YES];
    [self enqueueAudioWithPath:[[self currentQuestion] audioPathForCorrectAnswer]
                    fromBundle:NO
                    startDelay:0
        synchronizedStartBlock:nil
          synchronizedEndBlock:^{
              [self simulateRotationBackToPortraitAndCloseWithSuccess:YES];
          }];
    
    // disable more taps
    [self.pageImageView setUserInteractionEnabled:NO];
}

@end
