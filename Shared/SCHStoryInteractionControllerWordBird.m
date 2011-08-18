//
//  SCHStoryInteractionControllerWordBird.m
//  Scholastic
//
//  Created by Neil Gall on 11/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionControllerWordBird.h"
#import "SCHStoryInteractionControllerDelegate.h"
#import "SCHStoryInteractionWordBirdLetterView.h"
#import "SCHStoryInteractionWordBirdAnswerLetterView.h"
#import "SCHStoryInteractionWordBird.h"
#import "UIColor+Scholastic.h"
#import "SCHAnimatedLayer.h"
#import "SCHAnimationDelegate.h"

enum {
    kAnswerLetterWidth = 40,
    kAnswerLetterHeight = 40,
    kAnswerLetterGap = 5,
    kTileLetterWidth = 25,
    kTileLetterHeight = 25,
    kTileLetterGap = 5,
    kNumberOfBalloons = 2
    
};

@interface SCHStoryInteractionControllerWordBird ()

@property (nonatomic, retain) NSArray *answerLetters;
@property (nonatomic, assign) NSInteger correctLetterCount;
@property (nonatomic, assign) NSInteger remainingBalloonCount;
@property (nonatomic, retain) SCHAnimatedLayer *shockedPenguinLayer;
@property (nonatomic, retain) SCHAnimatedLayer *happyPenguinLayer;
@property (nonatomic, retain) SCHAnimatedLayer *balloonsLayer;
@property (nonatomic, retain) SCHAnimatedLayer *animationContainerLayer;
@property (nonatomic, retain) NSArray *loseAnimationLayers;

- (void)setupAnswerView;
- (void)setupLettersView;
- (void)setupAnimationView;
- (BOOL)checkForLetter:(unichar)letter;
- (void)revealLetterInAnswer:(unichar)letter;
- (void)didComplete;
- (void)movePenguinHigher;
- (void)popBalloon;

@end

@implementation SCHStoryInteractionControllerWordBird

@synthesize answerContainer;
@synthesize lettersContainer;
@synthesize animationContainer;
@synthesize answerLetters;
@synthesize correctLetterCount;
@synthesize remainingBalloonCount;
@synthesize shockedPenguinLayer;
@synthesize happyPenguinLayer;
@synthesize balloonsLayer;
@synthesize animationContainerLayer;
@synthesize loseAnimationLayers;

- (void)dealloc
{
    [answerContainer release], answerContainer = nil;
    [lettersContainer release], lettersContainer = nil;
    [animationContainer release], animationContainer = nil;
    [answerLetters release], answerLetters = nil;
    [shockedPenguinLayer release], shockedPenguinLayer = nil;
    [happyPenguinLayer release], happyPenguinLayer = nil;
    [balloonsLayer release], balloonsLayer = nil;
    [animationContainerLayer release], animationContainerLayer = nil;
    [loseAnimationLayers release], loseAnimationLayers = nil;
    [super dealloc];
}

- (void)storyInteractionDisableUserInteraction
{
    [self setUserInteractionsEnabled:NO];
}

- (void)storyInteractionEnableUserInteraction
{
    [self setUserInteractionsEnabled:YES];
}

- (BOOL)shouldPlayQuestionAudioForViewAtIndex:(NSInteger)screenIndex
{
    return screenIndex == 0;
}

- (void)setupViewAtIndex:(NSInteger)screenIndex
{
    switch (screenIndex) {
        case 1: {
            [self setupAnswerView];
            [self setupLettersView];
            [self setupAnimationView];
            self.correctLetterCount = 0;
            break;
        }
    }
}

- (NSString *)currentWord
{
    NSInteger currentQuestion = [self.delegate currentQuestionForStoryInteraction];
    SCHStoryInteractionWordBird *wordBird = (SCHStoryInteractionWordBird *)self.storyInteraction;
    SCHStoryInteractionWordBirdQuestion *question = [wordBird.questions objectAtIndex:currentQuestion];
    return question.word;
}

- (void)setupAnswerView
{
    UIColor *answerColor = [UIColor SCHBlue2Color];
    
    self.answerContainer.layer.borderColor = [answerColor CGColor];
    self.answerContainer.layer.borderWidth = 2;
    self.answerContainer.layer.cornerRadius = 15;
    self.answerContainer.layer.masksToBounds = YES;

    NSInteger letterCount = [[self currentWord] length];
    NSMutableArray *letters = [NSMutableArray arrayWithCapacity:letterCount];

    CGFloat letterWidth = floorf(MIN(kAnswerLetterWidth, (CGRectGetWidth(self.answerContainer.bounds)-kAnswerLetterGap*2)/letterCount-kAnswerLetterGap));
    CGFloat width = letterWidth*letterCount + kAnswerLetterGap*(letterCount-1);
    CGFloat left = (CGRectGetWidth(self.answerContainer.bounds)-width)/2;
    CGFloat top = (CGRectGetHeight(self.answerContainer.bounds)-kAnswerLetterHeight)/2;
    
    for (NSInteger letterIndex = 0; letterIndex < letterCount; ++letterIndex) {
        CGRect frame = CGRectIntegral(CGRectMake(left+(letterWidth+kAnswerLetterGap)*letterIndex, top, letterWidth, kAnswerLetterHeight));
        SCHStoryInteractionWordBirdAnswerLetterView *letterView = [[SCHStoryInteractionWordBirdAnswerLetterView alloc] initWithFrame:frame];
        letterView.textColor = answerColor;
        letterView.letter = ' ';
        [letters addObject:letterView];
        [self.answerContainer addSubview:letterView];
        [letterView release];
    }
    
    NSLog(@"setup Word Bird '%@'", [self currentWord]);
}

- (void)setupLettersView
{
    CGFloat size = (CGRectGetWidth(self.lettersContainer.bounds)-kTileLetterGap)/9 - kTileLetterGap;
    CGFloat left = size/2; // top row offset by half a tile
    CGFloat top = (CGRectGetHeight(self.lettersContainer.bounds)-size*3-kTileLetterGap*2) / 2;
    unichar firstInRow = L'A';
    
    for (unichar letter = L'A'; letter <= L'Z'; ++letter) {
        if (letter == L'I' || letter == L'R') {
            left = 0;
            top += size+kTileLetterGap;
            firstInRow = letter;
        }
        SCHStoryInteractionWordBirdLetterView *letterView = [SCHStoryInteractionWordBirdLetterView letter];
        letterView.frame = CGRectMake(left+(size+kTileLetterGap)*(letter-firstInRow), top, size, size);
        letterView.letter = letter;
        [letterView addTarget:self action:@selector(letterTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.lettersContainer addSubview:letterView];
    }
}

- (void)setupAnimationView
{
    CGRect bounds = CGRectMake(0, 0, 260, 400);
    self.animationContainerLayer = [SCHAnimatedLayer layer];
    self.animationContainerLayer.bounds = bounds;
    self.animationContainerLayer.position = CGPointMake(CGRectGetMidX(self.animationContainer.bounds),
                                                        CGRectGetMaxY(self.animationContainer.bounds)-CGRectGetMidY(bounds));
    [self.animationContainer.layer addSublayer:self.animationContainerLayer];
    
    self.balloonsLayer = [SCHAnimatedLayer layer];
    self.balloonsLayer.position = CGPointMake(122, 76);
    self.balloonsLayer.bounds = CGRectMake(0, 0, 200, 230);
    NSString *filename = [NSString stringWithFormat:@"storyinteraction-wordbird-BalloonPop_%02d.png", 11-kNumberOfBalloons];
    self.balloonsLayer.contents = (id)[[UIImage imageNamed:filename] CGImage];
    self.balloonsLayer.frameSize = CGSizeMake(200, 230);
    self.balloonsLayer.numberOfFrames = 46;
    self.balloonsLayer.frameIndex = 0;
    [self.animationContainerLayer addSublayer:self.balloonsLayer];
    [self.balloonsLayer setNeedsDisplay];

    self.shockedPenguinLayer = [SCHAnimatedLayer layer];
    self.shockedPenguinLayer.position = CGPointMake(97, 234);
    self.shockedPenguinLayer.bounds = CGRectMake(0, 0, 150, 160);
    self.shockedPenguinLayer.contents = (id)[[UIImage imageNamed:@"storyinteraction-wordbird-Shocked_Pen.png"] CGImage];
    self.shockedPenguinLayer.frameSize = CGSizeMake(150, 160);
    self.shockedPenguinLayer.numberOfFrames = 99;
    self.shockedPenguinLayer.frameIndex = 0;
    [self.animationContainerLayer addSublayer:self.shockedPenguinLayer];
    [self.shockedPenguinLayer setNeedsDisplay];
        
    self.happyPenguinLayer = [SCHAnimatedLayer layer];
    self.happyPenguinLayer.position = CGPointMake(80, 221);
    self.happyPenguinLayer.bounds = self.shockedPenguinLayer.bounds;
    self.happyPenguinLayer.contents = (id)[[UIImage imageNamed:@"storyinteraction-wordbird-Pen_Happy_Filmstrip.png"] CGImage];
    self.happyPenguinLayer.frameSize = CGSizeMake(150, 160);
    self.happyPenguinLayer.numberOfFrames = 49;
    self.happyPenguinLayer.frameIndex = 0;
    self.happyPenguinLayer.hidden = YES;
    [self.animationContainerLayer addSublayer:self.happyPenguinLayer];
    [self.happyPenguinLayer setNeedsDisplay];
    
    NSMutableArray *loseLayers = [NSMutableArray arrayWithCapacity:3];
    for (NSInteger i = 0; i < 3; ++i) {
        SCHAnimatedLayer *loseLayer = [SCHAnimatedLayer layer];
        loseLayer.position = CGPointMake(130, 220);
        loseLayer.bounds = CGRectMake(0, 0, 220, 360);
        NSString *filename = [NSString stringWithFormat:@"storyinteraction-wordbird-Pen_Lose_%d.png", i];
        loseLayer.contents = (id)[[UIImage imageNamed:filename] CGImage];
        loseLayer.frameSize = CGSizeMake(220, 360);
        loseLayer.frameIndex = 0;
        loseLayer.numberOfFrames = (i == 2) ? 39 : 40;
        loseLayer.hidden = YES;
        [loseLayer setNeedsDisplay];
        [self.animationContainerLayer addSublayer:loseLayer];
        [loseLayers addObject:loseLayer];
    }
    self.loseAnimationLayers = [NSArray arrayWithArray:loseLayers];
    
    self.remainingBalloonCount = kNumberOfBalloons;
}

- (SCHAnimationDelegate *)continueInteraction
{
    return [SCHAnimationDelegate animationDelegateWithStopBlock:^(CAAnimation *animation, BOOL finished) {
        self.controllerState = SCHStoryInteractionControllerStateInteractionInProgress;
    }];
}

- (void)playTapped:(id)sender
{
    [self presentNextView];
}

- (void)letterTapped:(SCHStoryInteractionWordBirdLetterView *)sender
{
    unichar letter = sender.letter;    
    self.controllerState = SCHStoryInteractionControllerStateInteractionReadingAnswerWithPause;
    
    BOOL correct = [self checkForLetter:letter];
    
    [self enqueueAudioWithPath:[(SCHStoryInteractionWordBird *)self.storyInteraction audioPathForLetter:letter]
                    fromBundle:NO
                    startDelay:0
        synchronizedStartBlock:nil
          synchronizedEndBlock:^{
              if (correct) {
                  [sender setCorrectHighlight];
              } else {
                  [sender setIncorrectHighlight];
              }
          }];
    
    NSString *audioPath = (correct ? [self.storyInteraction storyInteractionCorrectAnswerSoundFilename]
                           : [self.storyInteraction storyInteractionCorrectAnswerSoundFilename]);
    [self enqueueAudioWithPath:audioPath
                    fromBundle:NO
                    startDelay:0
        synchronizedStartBlock:nil
          synchronizedEndBlock:^{
              [self revealLetterInAnswer:letter];
              if (correct) {
                  [self movePenguinHigher];
              } else {
                  [self popBalloon];
              }
          }];

    [sender setUserInteractionEnabled:NO];
}

- (BOOL)checkForLetter:(unichar)letter
{
    NSString *letterString = [NSString stringWithCharacters:&letter length:1];
    NSString *word = [self currentWord];
    return [word rangeOfString:letterString].location != NSNotFound;
}

- (void)revealLetterInAnswer:(unichar)letter
{
    NSString *word = [self currentWord];
    NSInteger letterCount = [word length];
    for (NSInteger letterIndex = 0; letterIndex < letterCount; ++letterIndex) {
        if ([word characterAtIndex:letterIndex] == letter) {
            SCHStoryInteractionWordBirdAnswerLetterView *answer = [self.answerContainer.subviews objectAtIndex:letterIndex];
            [answer setLetter:letter];
            self.correctLetterCount++;
        }
    }
}

- (void)didComplete
{
    // TODO animate penguin flying away
    [self enqueueAudioWithPath:[(SCHStoryInteractionWordBird *)self.storyInteraction audioPathForNiceFlying]
                    fromBundle:NO
                    startDelay:0
        synchronizedStartBlock:nil
          synchronizedEndBlock:^{
              self.controllerState = SCHStoryInteractionControllerStateInteractionFinishedSuccessfully;
              [self removeFromHostView];
          }];
}

#pragma mark - animations

- (void)movePenguinHigher
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    if (self.correctLetterCount < [[self currentWord] length]) {
        CGFloat ystep = (CGRectGetHeight(self.animationContainer.bounds)-CGRectGetHeight(self.animationContainerLayer.bounds))/([[self currentWord] length]-1);
        CGPoint targetPosition = CGPointMake(self.animationContainerLayer.position.x, 
                                             CGRectGetMaxY(self.animationContainer.bounds)-CGRectGetMidY(self.animationContainerLayer.bounds)-ystep*self.correctLetterCount);
        
        CABasicAnimation *move = [CABasicAnimation animationWithKeyPath:@"position"];
        move.fromValue = [NSValue valueWithCGPoint:self.animationContainerLayer.position];
        move.toValue = [NSValue valueWithCGPoint:targetPosition];
        move.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        move.duration = 0.5;
        move.fillMode = kCAFillModeForwards;
        move.delegate = [SCHAnimationDelegate animationDelegateWithStopBlock:^(CAAnimation *animation, BOOL finished) {
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            self.happyPenguinLayer.hidden = NO;
            self.shockedPenguinLayer.hidden = YES;
            [self.happyPenguinLayer animateAllFramesWithDuration:1.5
                                                     repeatCount:1
                                                        delegate:[self continueInteraction]];
            [CATransaction commit];
        }];
        
        [self.animationContainerLayer addAnimation:move forKey:@"move"];
        self.animationContainerLayer.position = targetPosition;
        [self enqueueAudioWithPath:[self.storyInteraction storyInteractionCorrectAnswerSoundFilename] fromBundle:YES];
    } else {
        self.happyPenguinLayer.hidden = NO;
        self.shockedPenguinLayer.hidden = YES;
        self.happyPenguinLayer.frameIndex = 0;
        [self.happyPenguinLayer setNeedsDisplay];
        [self.happyPenguinLayer animateAllFramesWithDuration:1.5
                                                 repeatCount:3
                                                    delegate:nil];
        
        CGPoint targetPosition = CGPointMake(self.animationContainerLayer.position.x, -300);
        CABasicAnimation *move = [CABasicAnimation animationWithKeyPath:@"position"];
        move.fromValue = [NSValue valueWithCGPoint:self.animationContainerLayer.position];
        move.toValue = [NSValue valueWithCGPoint:targetPosition];
        move.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        move.duration = 4.5;
        [self.animationContainerLayer addAnimation:move forKey:@"move"];
        self.animationContainerLayer.position = targetPosition;
        
        [self enqueueAudioWithPath:@"sfx_penguinwin.mp3"
                        fromBundle:YES
                        startDelay:0
            synchronizedStartBlock:nil
              synchronizedEndBlock:^{
                  self.controllerState = SCHStoryInteractionControllerStateInteractionFinishedSuccessfully;
                  [self removeFromHostView];
              }];
    }
    
    [CATransaction commit];
}

- (void)popBalloon
{
    void (^releaseLayer)(CALayer *) = ^(CALayer *layer) {
        [layer removeFromSuperlayer];
        layer.contents = nil;
    };
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    if (--self.remainingBalloonCount == 0) {
        // pop last balloon - there are three stages to the animation due to the number of frames required
        // not fitting in the maximum texture size
        SCHAnimationDelegate *step3 = [SCHAnimationDelegate animationDelegateWithStopBlock:^(CAAnimation *animation, BOOL finished) {
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            releaseLayer([self.loseAnimationLayers objectAtIndex:1]);
            SCHAnimatedLayer *finalLayer = [self.loseAnimationLayers objectAtIndex:2];
            [finalLayer setHidden:NO];
            [finalLayer animateAllFramesWithDuration:1.56
                                         repeatCount:1 
                                            delegate:[self continueInteraction]];
            [finalLayer setFrameIndex:finalLayer.numberOfFrames-1];
            [CATransaction commit];
        }];
        SCHAnimationDelegate *step2 = [SCHAnimationDelegate animationDelegateWithStopBlock:^(CAAnimation *animation, BOOL finished) {
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            releaseLayer([self.loseAnimationLayers objectAtIndex:0]);
            [[self.loseAnimationLayers objectAtIndex:1] setHidden:NO];
            [[self.loseAnimationLayers objectAtIndex:1] animateAllFramesWithDuration:1.59
                                                                         repeatCount:1
                                                                            delegate:step3];
            [CATransaction commit];
        }];
        [[self.loseAnimationLayers objectAtIndex:0] animateAllFramesWithDuration:1.59 
                                                                     repeatCount:1
                                                                        delegate:step2];
        [self enqueueAudioWithPath:@"sfx_penguinfall.mp3" fromBundle:YES];
    } else {
        SCHAnimationDelegate *balloonAnimationDelegate = [SCHAnimationDelegate animationDelegateWithStopBlock:^(CAAnimation *animation, BOOL finished) {
            SCHAnimationDelegate *penguinAnimationDelegate;
            if (self.remainingBalloonCount == 1) {
                penguinAnimationDelegate = [SCHAnimationDelegate animationDelegateWithStopBlock:^(CAAnimation *animation, BOOL finished) {
                    [CATransaction begin];
                    [CATransaction setDisableActions:YES];
                    releaseLayer(self.balloonsLayer);
                    releaseLayer(self.shockedPenguinLayer);
                    self.happyPenguinLayer.hidden = YES;
                    [[self.loseAnimationLayers objectAtIndex:0] setHidden:NO];
                    [CATransaction commit];
                    self.controllerState = SCHStoryInteractionControllerStateInteractionInProgress;
                }];
            } else {
                NSString *filename = [NSString stringWithFormat:@"storyinteraction-wordbird-BalloonPop_%02d.png", 11-self.remainingBalloonCount];
                self.balloonsLayer.contents = (id)[[UIImage imageNamed:filename] CGImage];
                self.balloonsLayer.frameIndex = 0;
                penguinAnimationDelegate = [self continueInteraction];
            }
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            [self.balloonsLayer setNeedsDisplay];
            self.happyPenguinLayer.hidden = YES;
            self.shockedPenguinLayer.hidden = NO;
            [self.shockedPenguinLayer animateAllFramesWithDuration:1.5
                                                       repeatCount:1
                                                          delegate:penguinAnimationDelegate];
            [CATransaction commit];
        }];
    
        self.balloonsLayer.frameIndex = self.balloonsLayer.numberOfFrames-1;
        [self.balloonsLayer animateAllFramesWithDuration:1.5
                                             repeatCount:1
                                                delegate:balloonAnimationDelegate];
        [self enqueueAudioWithPath:@"sfx_penguinpop.mp3" fromBundle:YES];
    }
    
    [CATransaction commit];
}

@end
