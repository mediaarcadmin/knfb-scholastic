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
@property (nonatomic, assign) NSInteger balloonPopCount;
@property (nonatomic, retain) SCHAnimatedLayer *penguinLayer;
@property (nonatomic, retain) SCHAnimatedLayer *balloonsLayer;
@property (nonatomic, retain) SCHAnimatedLayer *animationContainerLayer;

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
@synthesize balloonPopCount;
@synthesize penguinLayer;
@synthesize balloonsLayer;
@synthesize animationContainerLayer;

- (void)dealloc
{
    [answerContainer release], answerContainer = nil;
    [lettersContainer release], lettersContainer = nil;
    [animationContainer release], animationContainer = nil;
    [answerLetters release], answerLetters = nil;
    [penguinLayer release], penguinLayer = nil;
    [balloonsLayer release], balloonsLayer = nil;
    [animationContainerLayer release], animationContainerLayer = nil;
    [super dealloc];
}

- (void)storyInteractionDisableUserInteraction
{
    [self.lettersContainer setUserInteractionEnabled:NO];
}

- (void)storyInteractionEnableUserInteraction
{
    [self.lettersContainer setUserInteractionEnabled:YES];
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
}

- (void)setupAnimationView
{
    CGRect bounds = CGRectMake(0, 0, 220, 360);
    self.animationContainerLayer = [SCHAnimatedLayer layer];
    self.animationContainerLayer.bounds = bounds;
    self.animationContainerLayer.position = CGPointMake(CGRectGetMidX(bounds), CGRectGetMaxY(self.animationContainer.bounds)-CGRectGetMidY(bounds));
    [self.animationContainer.layer addSublayer:self.animationContainerLayer];
    
    self.balloonsLayer = [SCHAnimatedLayer layer];
    self.balloonsLayer.position = CGPointMake(103, 36);
    self.balloonsLayer.bounds = CGRectMake(0, 0, 200, 230);
    NSString *filename = [NSString stringWithFormat:@"storyinteraction-wordbird-BalloonPop_%02d.png", 11-kNumberOfBalloons];
    self.balloonsLayer.contents = (id)[[UIImage imageNamed:filename] CGImage];
    self.balloonsLayer.frameSize = CGSizeMake(200, 230);
    self.balloonsLayer.frameIndex = 0;
    [self.animationContainerLayer addSublayer:self.balloonsLayer];
    [self.balloonsLayer setNeedsDisplay];

    self.penguinLayer = [SCHAnimatedLayer layer];
    self.penguinLayer.position = CGPointMake(78, 194);
    self.penguinLayer.bounds = CGRectMake(0, 0, 150, 160);
    self.penguinLayer.contents = (id)[[UIImage imageNamed:@"storyinteraction-wordbird-Shocked_Pen.png"] CGImage];
    self.penguinLayer.frameSize = CGSizeMake(150, 160);
    self.penguinLayer.frameIndex = 0;
    [self.animationContainerLayer addSublayer:self.penguinLayer];
    [self.penguinLayer setNeedsDisplay];
        
    self.balloonPopCount = 0;
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
              if (self.correctLetterCount == [[self currentWord] length]) {
                  [self didComplete];
              } else {
                  self.controllerState = SCHStoryInteractionControllerStateInteractionInProgress;
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
    
    CGFloat ystep = (CGRectGetHeight(self.animationContainer.bounds)-CGRectGetHeight(self.animationContainerLayer.bounds))/([[self currentWord] length]-1);
    CGPoint targetPosition = CGPointMake(self.animationContainerLayer.position.x, 
                                         CGRectGetMaxY(self.animationContainer.bounds)-CGRectGetMidY(self.animationContainerLayer.bounds)-ystep*self.correctLetterCount);
    
    CABasicAnimation *move = [CABasicAnimation animationWithKeyPath:@"position"];
    move.fromValue = [NSValue valueWithCGPoint:self.animationContainerLayer.position];
    move.toValue = [NSValue valueWithCGPoint:targetPosition];
    move.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    move.duration = 0.5;
    [self.animationContainerLayer addAnimation:move forKey:@"move"];
    self.animationContainerLayer.position = targetPosition;
    
    [CATransaction commit];
}

- (void)popBalloon
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    if (++self.balloonPopCount == kNumberOfBalloons) {
        // pop last balloon
        self.animationContainerLayer.frameIndex = [self.animationContainerLayer numberOfFrames]-1;
        [self.animationContainerLayer animateAllFramesWithDuration:4.78 delegate:nil];
        [self enqueueAudioWithPath:@"sfx_penguinfall.mp3" fromBundle:YES];
    } else {
        SCHAnimationDelegate *delegate = [SCHAnimationDelegate animationDelegateWithStopBlock:^(CAAnimation *animation, BOOL finished) {
            if (self.balloonPopCount == kNumberOfBalloons-1) {
                // the last balloon's animation is in a single image
                [self.balloonsLayer removeFromSuperlayer];
                [self.penguinLayer removeFromSuperlayer];
                self.animationContainerLayer.contents = (id)[[UIImage imageNamed:@"storyinteraction-wordbird-Pen_Lose.png"] CGImage];
                self.animationContainerLayer.frameSize = CGSizeMake(220, 360);
                self.animationContainerLayer.frameIndex = 0;
                [self.animationContainerLayer setNeedsDisplay];
            } else {
                NSString *filename = [NSString stringWithFormat:@"storyinteraction-wordbird-BalloonPop_%02d.png", self.balloonPopCount+1];
                self.balloonsLayer.contents = (id)[[UIImage imageNamed:filename] CGImage];
                [self.penguinLayer animateAllFramesWithDuration:1.5 delegate:nil];
            }
        }];
        
        [self.balloonsLayer animateAllFramesWithDuration:1.5 delegate:delegate];
        [self enqueueAudioWithPath:@"sfx_penguinpop.mp3" fromBundle:YES];
    }
    
    [CATransaction commit];
}

@end
