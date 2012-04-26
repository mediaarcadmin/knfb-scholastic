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
#define debug_show_answer_path_and_hotspot_rect 0

@interface SCHStoryInteractionControllerHotSpot ()

@property (nonatomic, retain) UIView *answerMarkerView;
@property (nonatomic, copy) dispatch_block_t zoomCompletionHandler;
@property (nonatomic, retain) NSArray *questions;

- (CGAffineTransform)viewToPageTransform;
- (SCHStoryInteractionHotSpotQuestion *)currentQuestion;
- (void)incorrectTapAtPoint:(CGPoint)point;
- (void)correctTapAtPoint:(CGPoint)point;

@end

@implementation SCHStoryInteractionControllerHotSpot

@synthesize scrollView;
@synthesize pageImageView;
@synthesize answerMarkerView;
@synthesize zoomCompletionHandler;
@synthesize questions;

- (void)dealloc
{
    self.scrollView.delegate = nil;
    [scrollView release];
    [pageImageView release];
    [answerMarkerView release];
    [zoomCompletionHandler release];
    [super dealloc];
}

- (BOOL)shouldShowSnapshotOfReadingViewInBackground
{
    return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    // lock in initial orientation
    return orientation == self.interfaceOrientation;

}

- (CGAffineTransform)viewToPageTransform
{
    return [self.delegate viewToPageTransform];
}

- (SCHFrameStyle)frameStyleForViewAtIndex:(NSInteger)viewIndex
{
    CGRect frameInPageCoords = CGRectApplyAffineTransform([self overlaidTitleFrame], [self viewToPageTransform]);
    if (self.pageAssociation == SCHStoryInteractionQuestionOnRightPage) {
        frameInPageCoords.origin.x += [self.delegate sizeOfPageAtIndex:self.storyInteraction.documentPageNumber].width;
    }
    
    CGRect hotspotRect = [self currentQuestion].hotSpotRect;
    if (CGRectIntersectsRect(hotspotRect, frameInPageCoords)) {
        return SCHStoryInteractionTitleOverlaysContentsAtBottom;
    } else {
        return SCHStoryInteractionTitleOverlaysContentsAtTop;
    }
}

- (CGRect)overlaidTitleFrame
{
    const BOOL landscape = UIInterfaceOrientationIsLandscape(self.interfaceOrientation);
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return CGRectMake(landscape ? 172 : 44, 40, 680, 152);
    } else {
        return CGRectMake(0, 0, landscape ? 480 : 320, 64);
    }
}

- (SCHStoryInteractionHotSpotQuestion *)currentQuestion
{
    if (questions == nil) {
        CGSize pageSize = [self.delegate sizeOfPageAtIndex:self.storyInteraction.documentPageNumber];
        self.questions = [(SCHStoryInteractionHotSpot *)self.storyInteraction questionsWithPageAssociation:self.pageAssociation
                                                                                                  pageSize:pageSize];
    }
    NSInteger currentQuestionIndex = [self.delegate currentQuestionForStoryInteraction];
    NSAssert(currentQuestionIndex < [questions count], @"index must be within array bounds");    
    return [questions objectAtIndex:currentQuestionIndex];
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
    [tap setDelegate:self];
    [self.pageImageView addGestureRecognizer:tap];
    [self.pageImageView setUserInteractionEnabled:YES];
    [tap release];
    
#if debug_show_answer_path_and_hotspot_rect
    CALayer *pathLayer = [CALayer layer];
    pathLayer.delegate = self;
    pathLayer.frame = [self.pageImageView bounds];
    [self.pageImageView.layer addSublayer:pathLayer];
    [pathLayer setNeedsDisplay];
#endif
}

- (void)zoomOutAndCloseWithSuccess:(BOOL)success
{
    if (success) {
        self.controllerState = SCHStoryInteractionControllerStateInteractionFinishedSuccessfully;
    }
    if (self.scrollView.zoomScale != 1.0f) {
        self.zoomCompletionHandler = ^{
            [self removeFromHostView];
        };
        [self.scrollView setZoomScale:1.0f animated:YES];
    } else {
        [self removeFromHostView];
    }
}

- (void)closeButtonTapped:(id)sender
{
    [self zoomOutAndCloseWithSuccess:NO];
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
    CGPoint pointOnPage = CGPointApplyAffineTransform(pointInView, [self viewToPageTransform]);

    // if presented on right page only, translate the tapped point as if the left page was present
    if (self.pageAssociation == SCHStoryInteractionQuestionOnRightPage) {
        pointOnPage.x += [self.delegate sizeOfPageAtIndex:self.storyInteraction.documentPageNumber].width;
    }

    return pointOnPage;
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
    
    SCHStoryInteractionHotSpotQuestion *question = [self currentQuestion];
    BOOL correct;
    if (question.path != NULL) {
        correct = CGPathContainsPoint(question.path, NULL, pointInPage, NO);
    } else {
        correct = CGRectContainsPoint(question.hotSpotRect, pointInPage);
    }
    
    if (correct) {
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
    [self cancelQueuedAudioExecutingSynchronizedBlocksBefore:^{
        [self enqueueAudioWithPath:[self.storyInteraction storyInteractionWrongAnswerSoundFilename]
                        fromBundle:YES
                        startDelay:0
            synchronizedStartBlock:^{
                self.controllerState = SCHStoryInteractionControllerStateInteractionReadingAnswerWithPause;
            }
              synchronizedEndBlock:nil];
        [self enqueueAudioWithPath:[self.storyInteraction audioPathForTryAgain]
                        fromBundle:NO
                        startDelay:0
            synchronizedStartBlock:nil
              synchronizedEndBlock:^{
                  [UIView animateWithDuration:0.25
                                        delay:0
                                      options:UIViewAnimationOptionAllowUserInteraction
                                   animations:^{ cross.alpha = 0; }
                                   completion:^(BOOL finished) { 
                                       self.controllerState = SCHStoryInteractionControllerStateInteractionInProgress;
                                       [cross removeFromSuperview]; 
                                   }];
              }];
        
        self.answerMarkerView = cross;
        [cross release];
    }];
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
    self.controllerState = SCHStoryInteractionControllerStateInteractionFinishedSuccessfully;
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
        [star release], star = nil;
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
    
    [self cancelQueuedAudioExecutingSynchronizedBlocksBefore:^{
        [self enqueueAudioWithPath:[self.storyInteraction storyInteractionCorrectAnswerSoundFilename] fromBundle:YES];
        [self enqueueAudioWithPath:[[self currentQuestion] audioPathForCorrectAnswer]
                        fromBundle:NO
                        startDelay:0
            synchronizedStartBlock:nil
              synchronizedEndBlock:^{
                  [self zoomOutAndCloseWithSuccess:YES];
              }];
    }];
        
}


#if debug_show_answer_path_and_hotspot_rect
- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    CGAffineTransform pageToView = CGAffineTransformInvert([self viewToPageTransform]);
    NSLog(@"pageToView: %@", NSStringFromCGAffineTransform(pageToView));
    
    CGContextConcatCTM(ctx, pageToView);
    if (self.pageAssociation == SCHStoryInteractionQuestionOnRightPage) {
        CGSize pageSize = [self.delegate sizeOfPageAtIndex:self.storyInteraction.documentPageNumber];
        CGContextTranslateCTM(ctx, -pageSize.width, 0);
    }
    
    CGContextSetRGBStrokeColor(ctx, 0, 1, 0, 1);
    CGContextSetLineWidth(ctx, 2);
    CGContextAddPath(ctx, [[self currentQuestion] path]);
    CGContextStrokePath(ctx);
    
    CGContextSetRGBStrokeColor(ctx, 1, 0, 0, 1);
    CGContextAddRect(ctx, [[self currentQuestion] hotSpotRect]);
    CGContextStrokePath(ctx);
}
#endif

#pragma mark - Override for SCHStoryInteractionControllerStateReactions

- (void)storyInteractionDisableUserInteraction
{
    // disable user interaction
    [self.pageImageView setUserInteractionEnabled:NO];
}

- (void)storyInteractionEnableUserInteraction
{
    //enable user interaction
    [self.pageImageView setUserInteractionEnabled:YES];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return !CGRectContainsPoint(self.titleView.bounds, [touch locationInView:self.titleView]);
}

@end
