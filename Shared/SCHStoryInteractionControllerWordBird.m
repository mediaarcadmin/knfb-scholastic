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

enum {
    kAnswerLetterWidth = 40,
    kAnswerLetterHeight = 40,
    kAnswerLetterGap = 5,
    kTileLetterWidth = 25,
    kTileLetterHeight = 25,
    kTileLetterGap = 5,
};

@interface SCHStoryInteractionControllerWordBird ()

@property (nonatomic, retain) NSArray *answerLetters;
@property (nonatomic, assign) NSInteger correctLetterCount;;

- (void)setupAnswerView;
- (void)setupLettersView;
- (BOOL)checkForLetter:(unichar)letter;
- (void)revealLetterInAnswer:(unichar)letter;
- (void)didComplete;

@end

@implementation SCHStoryInteractionControllerWordBird

@synthesize answerContainer;
@synthesize lettersContainer;
@synthesize animationContainer;
@synthesize answerLetters;
@synthesize correctLetterCount;

- (void)dealloc
{
    [answerContainer release], answerContainer = nil;
    [lettersContainer release], lettersContainer = nil;
    [animationContainer release], animationContainer = nil;
    [answerLetters release], answerLetters = nil;
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

@end
