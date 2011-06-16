//
//  SCHStoryInteractionControllerPopQuiz.m
//  Scholastic
//
//  Created by Neil Gall on 02/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionControllerPopQuiz.h"
#import "SCHStoryInteractionPopQuiz.h"
#import "SCHStoryInteractionProgressView.h"

@interface SCHStoryInteractionControllerPopQuiz ()

@property (nonatomic, assign) NSInteger currentQuestionIndex;
@property (nonatomic, assign) NSInteger score;

- (void)setupQuestionView;
- (void)setupScoreView;

- (void)nextQuestion;
- (void)setupQuestion;

@end

@implementation SCHStoryInteractionControllerPopQuiz

@synthesize progressView;
@synthesize questionLabel;
@synthesize answerButtons;
@synthesize scoreLabel;
@synthesize scoreSublabel;
@synthesize currentQuestionIndex;
@synthesize score;

- (void)dealloc
{
    [progressView release];
    [questionLabel release];
    [answerButtons release];
    [scoreLabel release];
    [scoreSublabel release];
    [super dealloc];
}

- (SCHStoryInteractionPopQuizQuestion *)currentQuestion
{
    return [[(SCHStoryInteractionPopQuiz *)self.storyInteraction questions] objectAtIndex:currentQuestionIndex];
}

- (void)setupViewAtIndex:(NSInteger)screenIndex
{    
    switch (screenIndex) {
        case 0:
            [self setupQuestionView];
            break;
        case 1:
            [self setupScoreView];
            break;
    }
}

- (BOOL)shouldPlayQuestionAudioForViewAtIndex:(NSInteger)screenIndex
{
    return screenIndex == 0;
}

- (void)setupQuestionView
{
    self.currentQuestionIndex = 0;
    self.score = 0;
    self.progressView.numberOfSteps = [[(SCHStoryInteractionPopQuiz *)self.storyInteraction questions] count];
    [self setupQuestion];

    [self playBundleAudioWithFilename:[self.storyInteraction storyInteractionOpeningSoundFilename] completion:nil];
}

- (void)setupScoreView
{
    SCHStoryInteractionPopQuiz *popQuiz = (SCHStoryInteractionPopQuiz *)self.storyInteraction;
    NSInteger maxScore = self.progressView.numberOfSteps;
    self.scoreLabel.text = [NSString stringWithFormat:@"You got %d out of %d right!", self.score, maxScore];
    if (score <= maxScore/3) {
        self.scoreSublabel.text = popQuiz.scoreResponseLow;
    } else if (score <= maxScore*2/3) {
        self.scoreSublabel.text = popQuiz.scoreResponseMedium;
    } else {
        self.scoreSublabel.text = popQuiz.scoreResponseHigh;
    }
}

- (void)nextQuestion
{
    self.currentQuestionIndex++;
    if (self.currentQuestionIndex == self.progressView.numberOfSteps) {
        [self presentNextView];
    } else {
        [self setupQuestion];
    }
}

- (void)setupQuestion
{
    self.progressView.currentStep = self.currentQuestionIndex;
    self.questionLabel.text = [self currentQuestion].prompt;
    NSInteger i = 0;
    for (NSString *answer in [self currentQuestion].answers) {
        UIImage *highlight = nil;
        if (i == [self currentQuestion].correctAnswer) {
            highlight = [UIImage imageNamed:@"answer-button-green"];
        }
        UIButton *button = [self.answerButtons objectAtIndex:i];
        [button setTitle:answer forState:UIControlStateNormal];
        [button setHidden:NO];
        [button setBackgroundImage:highlight forState:UIControlStateSelected];
        ++i;
    }
    for (; i < [self.answerButtons count]; ++i) {
        [[self.answerButtons objectAtIndex:i] setHidden:YES];
    }
}

- (IBAction)answerButtonTapped:(id)sender
{
    NSInteger chosenAnswer = [self.answerButtons indexOfObject:sender];
    if (chosenAnswer == NSNotFound) {
        return;
    }
    

    if (chosenAnswer == [self currentQuestion].correctAnswer) {
        [sender setSelected:YES];
        [self playBundleAudioWithFilename:[self.storyInteraction storyInteractionCorrectAnswerSoundFilename]
                               completion:nil];
        self.score++;
    
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [sender setSelected:NO];
            [self nextQuestion];
        });
    } else {
        [self playBundleAudioWithFilename:[self.storyInteraction storyInteractionWrongAnswerSoundFilename]
                               completion:^{
                                   [self nextQuestion];
                               }];
    }
}

- (void)playAgainButtonTapped:(id)sender
{
    [self presentNextView];
}

@end
