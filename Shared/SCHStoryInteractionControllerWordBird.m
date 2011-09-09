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
    kNumberOfBalloons = 10
    
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
@property (nonatomic, assign) NSInteger simultaneousTapCount;

- (void)setupAnswerView;
- (void)setupLettersView;
- (void)setupAnimationView;
- (BOOL)checkForLetter:(unichar)letter;
- (void)revealLetterInAnswer:(unichar)letter;
- (void)didComplete;
- (void)movePenguinHigher;
- (void)popBalloon;
- (void)showPlayAgainButton;
- (void)playAgainTapped:(id)sender;

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
@synthesize simultaneousTapCount;

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
    if (screenIndex == 1) {
        [self setupAnswerView];
        [self setupLettersView];
        [self setupAnimationView];
        self.correctLetterCount = 0;
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
    
    self.simultaneousTapCount = 0;
}

- (void)setupAnimationView
{
    CGRect bounds = CGRectMake(0, 0, 260, 400);
    self.animationContainerLayer = [SCHAnimatedLayer layer];
    self.animationContainerLayer.bounds = bounds;
    
    CGFloat scale = 1.0f;
    CGFloat neededHeight = CGRectGetHeight(bounds)*1.5;
    if (CGRectGetWidth(bounds) > CGRectGetWidth(self.animationContainer.bounds)
        || neededHeight > CGRectGetHeight(self.animationContainer.bounds)) {
        // scale the animation layer down to fit
        scale = MIN(CGRectGetWidth(self.animationContainer.bounds) / CGRectGetWidth(bounds),
                    CGRectGetHeight(self.animationContainer.bounds) / neededHeight);
    }
    self.animationContainerLayer.affineTransform = CGAffineTransformMakeScale(scale, scale);
    self.animationContainerLayer.position = CGPointMake(CGRectGetMidX(self.animationContainer.bounds),
                                                        CGRectGetMaxY(self.animationContainer.bounds)-CGRectGetMidY(bounds)*scale);
    [self.animationContainer.layer addSublayer:self.animationContainerLayer];
    [self.animationContainer.layer setMasksToBounds:YES];
    
    self.balloonsLayer = [SCHAnimatedLayer layer];
    self.balloonsLayer.position = CGPointMake(122, 96);
    self.balloonsLayer.bounds = CGRectMake(0, 0, 200, 230);
    self.balloonsLayer.contents = (id)[[UIImage imageNamed:@"storyinteraction-wordbird-BalloonPop.png"] CGImage];
    self.balloonsLayer.frameSize = CGSizeMake(200, 230);
    self.balloonsLayer.numberOfFrames = 28;
    self.balloonsLayer.frameIndex = 0;
    [self.animationContainerLayer addSublayer:self.balloonsLayer];
    [self.balloonsLayer setNeedsDisplay];

    self.shockedPenguinLayer = [SCHAnimatedLayer layer];
    self.shockedPenguinLayer.position = CGPointMake(97, 254);
    self.shockedPenguinLayer.bounds = CGRectMake(0, 0, 150, 160);
    self.shockedPenguinLayer.contents = (id)[[UIImage imageNamed:@"storyinteraction-wordbird-Shocked_Pen.png"] CGImage];
    self.shockedPenguinLayer.frameSize = CGSizeMake(150, 160);
    self.shockedPenguinLayer.numberOfFrames = 24;
    self.shockedPenguinLayer.frameIndex = 0;
    [self.animationContainerLayer addSublayer:self.shockedPenguinLayer];
    [self.shockedPenguinLayer setNeedsDisplay];
        
    self.happyPenguinLayer = [SCHAnimatedLayer layer];
    self.happyPenguinLayer.position = CGPointMake(80, 241);
    self.happyPenguinLayer.bounds = self.shockedPenguinLayer.bounds;
    self.happyPenguinLayer.contents = (id)[[UIImage imageNamed:@"storyinteraction-wordbird-Pen_Happy_Filmstrip.png"] CGImage];
    self.happyPenguinLayer.frameSize = CGSizeMake(150, 160);
    self.happyPenguinLayer.numberOfFrames = 12;
    self.happyPenguinLayer.frameIndex = 0;
    self.happyPenguinLayer.hidden = YES;
    [self.animationContainerLayer addSublayer:self.happyPenguinLayer];
    [self.happyPenguinLayer setNeedsDisplay];
    
    NSMutableArray *loseLayers = [NSMutableArray arrayWithCapacity:3];
    for (NSInteger i = 0; i < 3; ++i) {
        SCHAnimatedLayer *loseLayer = [SCHAnimatedLayer layer];
        loseLayer.position = CGPointMake(130, 240);
        loseLayer.bounds = CGRectMake(0, 0, 220, 360);
        NSString *filename = [NSString stringWithFormat:@"storyinteraction-wordbird-Pen_Lose_%d.png", i];
        loseLayer.contents = (id)[[UIImage imageNamed:filename] CGImage];
        loseLayer.frameSize = CGSizeMake(220, 360);
        loseLayer.frameIndex = 0;
        switch (i) {
            case 0:
                loseLayer.numberOfFrames = 10;
                break;
            case 1:
                loseLayer.numberOfFrames = 9;
                break;
            case 2:
                loseLayer.numberOfFrames = 7;
                break;
        }
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
    [self cancelQueuedAudioExecutingSynchronizedBlocksImmediately];
    [self presentNextView];
}

- (void)letterTapped:(SCHStoryInteractionWordBirdLetterView *)sender
{
    self.simultaneousTapCount++;
    if (self.simultaneousTapCount == 1) {
        [self performSelector:@selector(singleLetterTapped:) withObject:sender afterDelay:kMinimumDistinguishedAnswerDelay];
    }
}    

- (void)singleLetterTapped:(SCHStoryInteractionWordBirdLetterView *)sender
{
    NSInteger tapCount = self.simultaneousTapCount;
    self.simultaneousTapCount = 0;
    if (tapCount > 1) {
        return;
    }

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
                           : [self.storyInteraction storyInteractionWrongAnswerSoundFilename]);
    [self enqueueAudioWithPath:audioPath
                    fromBundle:YES
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
        
        CGFloat heightInset = self.animationContainer.frame.origin.y;
        
        CGRect bounds = CGRectApplyAffineTransform(self.animationContainerLayer.bounds, self.animationContainerLayer.affineTransform);
        CGFloat ystep = (CGRectGetHeight(self.animationContainer.bounds) + heightInset - CGRectGetHeight(bounds))/([[self currentWord] length]-1);
        CGPoint targetPosition = CGPointMake(self.animationContainerLayer.position.x, 
                                             CGRectGetMaxY(self.animationContainer.bounds)-CGRectGetMidY(bounds)-ystep*self.correctLetterCount);
        
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
                                                      frameOrder:nil
                                                     autoreverse:NO
                                                     repeatCount:1
                                                        delegate:[self continueInteraction]];
            [CATransaction commit];
        }];
        
        [self.animationContainerLayer addAnimation:move forKey:@"move"];
        self.animationContainerLayer.position = targetPosition;
    } else {
        self.happyPenguinLayer.hidden = NO;
        self.shockedPenguinLayer.hidden = YES;
        self.happyPenguinLayer.frameIndex = 0;
        [self.happyPenguinLayer setNeedsDisplay];
        [self.happyPenguinLayer animateAllFramesWithDuration:1.5
                                                  frameOrder:nil
                                                 autoreverse:NO
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
        
        [self enqueueAudioWithPath:@"sfx_penguinwin.mp3" fromBundle:YES];
        [self didComplete];
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
    
    if (self.remainingBalloonCount == 1) {
        // pop last balloon - there are three stages to the animation due to the number of frames required
        // not fitting in the maximum texture size
        // Actually they have been reduced in size so could be combined but the 3 stages lets a frameOrder to be specified for 2 out of 3 stages
        SCHAnimationDelegate *step2delegate = [SCHAnimationDelegate animationDelegateWithStopBlock:^(CAAnimation *animation, BOOL finished) {
            [self showPlayAgainButton];
        }];
        SCHAnimationDelegate *step1delegate = [SCHAnimationDelegate animationDelegateWithStopBlock:^(CAAnimation *animation, BOOL finished) {
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            releaseLayer([self.loseAnimationLayers objectAtIndex:1]);
            SCHAnimatedLayer *finalLayer = [self.loseAnimationLayers objectAtIndex:2];
            [finalLayer setHidden:NO];
            
            NSArray *frameOrder = [NSArray arrayWithObjects:[NSNumber numberWithInt:0],
                                   [NSNumber numberWithInt:0],
                                   [NSNumber numberWithInt:1],
                                   [NSNumber numberWithInt:1],
                                   [NSNumber numberWithInt:1],
                                   [NSNumber numberWithInt:1],
                                   [NSNumber numberWithInt:0],
                                   [NSNumber numberWithInt:2],
                                   [NSNumber numberWithInt:2],
                                   [NSNumber numberWithInt:3],
                                   [NSNumber numberWithInt:3],
                                   [NSNumber numberWithInt:3],
                                   [NSNumber numberWithInt:3],
                                   [NSNumber numberWithInt:3],
                                   [NSNumber numberWithInt:3],
                                   [NSNumber numberWithInt:3],
                                   [NSNumber numberWithInt:3],
                                   [NSNumber numberWithInt:3],
                                   [NSNumber numberWithInt:3],
                                   [NSNumber numberWithInt:3],
                                   [NSNumber numberWithInt:3],
                                   [NSNumber numberWithInt:3],
                                   [NSNumber numberWithInt:3],
                                   [NSNumber numberWithInt:3],
                                   [NSNumber numberWithInt:3],
                                   [NSNumber numberWithInt:3],
                                   [NSNumber numberWithInt:3],
                                   [NSNumber numberWithInt:4],
                                   [NSNumber numberWithInt:4],
                                   [NSNumber numberWithInt:4],
                                   [NSNumber numberWithInt:5],
                                   [NSNumber numberWithInt:5],
                                   [NSNumber numberWithInt:5],
                                   [NSNumber numberWithInt:5],
                                   [NSNumber numberWithInt:6],
                                   [NSNumber numberWithInt:6],
                                   [NSNumber numberWithInt:6],
                                   [NSNumber numberWithInt:6],
                                   [NSNumber numberWithInt:6],
                                   nil];
            
            [finalLayer animateAllFramesWithDuration:1.56
                                          frameOrder:frameOrder
                                         autoreverse:NO
                                         repeatCount:1 
                                            delegate:step2delegate];
            [finalLayer setFrameIndex:finalLayer.numberOfFrames-1];
            [CATransaction commit];
        }];
        SCHAnimationDelegate *step0delegate = [SCHAnimationDelegate animationDelegateWithStopBlock:^(CAAnimation *animation, BOOL finished) {
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            releaseLayer([self.loseAnimationLayers objectAtIndex:0]);
            
            NSArray *frameOrder = [NSArray arrayWithObjects:[NSNumber numberWithInt:0],
                                   [NSNumber numberWithInt:1],
                                   [NSNumber numberWithInt:2],
                                   [NSNumber numberWithInt:3],
                                   [NSNumber numberWithInt:4],
                                   [NSNumber numberWithInt:5],
                                   [NSNumber numberWithInt:6],
                                   [NSNumber numberWithInt:6],
                                   [NSNumber numberWithInt:6],
                                   [NSNumber numberWithInt:7],
                                   [NSNumber numberWithInt:7],
                                   [NSNumber numberWithInt:7],
                                   [NSNumber numberWithInt:7],
                                   [NSNumber numberWithInt:7],
                                   [NSNumber numberWithInt:7],
                                   [NSNumber numberWithInt:7],
                                   [NSNumber numberWithInt:7],
                                   [NSNumber numberWithInt:7],
                                   [NSNumber numberWithInt:7],
                                   [NSNumber numberWithInt:8],
                                   [NSNumber numberWithInt:8],
                                   [NSNumber numberWithInt:8],
                                   [NSNumber numberWithInt:8],
                                   [NSNumber numberWithInt:7],
                                   [NSNumber numberWithInt:7],
                                   [NSNumber numberWithInt:7],
                                   [NSNumber numberWithInt:7],
                                   [NSNumber numberWithInt:7],
                                   [NSNumber numberWithInt:7],
                                   [NSNumber numberWithInt:7],
                                   [NSNumber numberWithInt:7],
                                   [NSNumber numberWithInt:7],
                                   [NSNumber numberWithInt:7],
                                   [NSNumber numberWithInt:7],
                                   [NSNumber numberWithInt:7],
                                   [NSNumber numberWithInt:7],
                                   [NSNumber numberWithInt:7],
                                   [NSNumber numberWithInt:7],
                                   [NSNumber numberWithInt:7],
                                   [NSNumber numberWithInt:7],
                                   nil];
            
            [[self.loseAnimationLayers objectAtIndex:1] setHidden:NO];
            [[self.loseAnimationLayers objectAtIndex:1] animateAllFramesWithDuration:1.59
                                                                          frameOrder:frameOrder
                                                                         autoreverse:NO
                                                                         repeatCount:1
                                                                            delegate:step1delegate];
            [CATransaction commit];
        }];

        releaseLayer(self.balloonsLayer);
        releaseLayer(self.shockedPenguinLayer);
        releaseLayer(self.happyPenguinLayer);
        [[self.loseAnimationLayers objectAtIndex:0] setHidden:NO];
        [[self.loseAnimationLayers objectAtIndex:0] animateAllFramesWithDuration:1.59
                                                                      frameOrder:nil
                                                                     autoreverse:NO
                                                                     repeatCount:1
                                                                        delegate:step0delegate];
        [self enqueueAudioWithPath:@"sfx_penguinfall.mp3" fromBundle:YES];
    } else {
        
        switch (self.remainingBalloonCount) {
            case 10:
                self.balloonsLayer.frameIndex = 3;                
                break;
            case 9:
                self.balloonsLayer.frameIndex = 6;
                break;
            case 8:
                self.balloonsLayer.frameIndex = 9;
                break;
            case 7:
                self.balloonsLayer.frameIndex = 12;
                break;
            case 6:
                self.balloonsLayer.frameIndex = 15;
                break;
            case 5:
                self.balloonsLayer.frameIndex = 18;
                break;
            case 4:
                self.balloonsLayer.frameIndex = 21;
                break;
            case 3:
                self.balloonsLayer.frameIndex = 24;
                break;
            case 2:
                self.balloonsLayer.frameIndex = 27;
                break;
        }
        
        // This is the repeating pattern of the 4 frames of each balloon pop that best match the sound effect
        NSMutableArray *frameOrder = [NSArray arrayWithObjects:[NSNumber numberWithInt:self.balloonsLayer.frameIndex - 3],
                      [NSNumber numberWithInt:self.balloonsLayer.frameIndex - 2],
                      [NSNumber numberWithInt:self.balloonsLayer.frameIndex - 2],
                      [NSNumber numberWithInt:self.balloonsLayer.frameIndex - 2],
                      [NSNumber numberWithInt:self.balloonsLayer.frameIndex - 3],
                      [NSNumber numberWithInt:self.balloonsLayer.frameIndex - 3],
                      [NSNumber numberWithInt:self.balloonsLayer.frameIndex - 2],
                      [NSNumber numberWithInt:self.balloonsLayer.frameIndex - 2],
                      [NSNumber numberWithInt:self.balloonsLayer.frameIndex - 2],
                      [NSNumber numberWithInt:self.balloonsLayer.frameIndex - 1],
                      [NSNumber numberWithInt:self.balloonsLayer.frameIndex],
                      nil];
        
        SCHAnimationDelegate *balloonAnimationDelegate = [SCHAnimationDelegate animationDelegateWithStopBlock:^(CAAnimation *animation, BOOL finished) {
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            self.happyPenguinLayer.hidden = YES;
            self.shockedPenguinLayer.hidden = NO;
            [self.shockedPenguinLayer animateAllFramesWithDuration:1.5
                                                        frameOrder:nil
                                                       autoreverse:NO
                                                       repeatCount:1
                                                          delegate:[self continueInteraction]];
            [CATransaction commit];
        }];
            
        [self.balloonsLayer animateAllFramesWithDuration:1.5
                                              frameOrder:frameOrder
                                             autoreverse:NO
                                             repeatCount:1
                                                delegate:balloonAnimationDelegate];
        [self enqueueAudioWithPath:@"sfx_penguinpop.mp3" fromBundle:YES];
    }
    
    [CATransaction commit];
    
    self.remainingBalloonCount--;
}

- (void)showPlayAgainButton
{
    UIButton *playAgain = [UIButton buttonWithType:UIButtonTypeCustom];
    playAgain.frame = self.contentsView.bounds;
    [playAgain addTarget:self action:@selector(playAgainTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentsView addSubview:playAgain];
    self.controllerState = SCHStoryInteractionControllerStateInteractionInProgress;
}

- (void)playAgainTapped:(UIButton *)sender
{
    [sender removeFromSuperview];
    for (SCHStoryInteractionWordBirdAnswerLetterView *answer in [self.answerContainer subviews]) {
        answer.letter = ' ';
    }
    for (SCHStoryInteractionWordBirdLetterView *letter in [self.lettersContainer subviews]) {
        [letter removeHighlight];
        [letter setUserInteractionEnabled:YES];
    }
    
    self.correctLetterCount = 0;
    self.remainingBalloonCount = kNumberOfBalloons;

    [self.animationContainerLayer removeFromSuperlayer];
    [self setupAnimationView];
}

@end
