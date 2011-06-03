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

@property (nonatomic, retain) NSArray *answerButtons;
@property (nonatomic, assign) NSInteger currentQuestionIndex;

- (void)nextQuestion;
- (void)setupQuestion;

@end

@implementation SCHStoryInteractionControllerPopQuiz

@synthesize progressView;
@synthesize questionLabel;
@synthesize answerButton1;
@synthesize answerButton2;
@synthesize answerButton3;
@synthesize answerButton4;
@synthesize answerButtons;
@synthesize currentQuestionIndex;

- (void)dealloc
{
    [progressView release];
    [questionLabel release];
    [answerButton1 release];
    [answerButton2 release];
    [answerButton3 release];
    [answerButton4 release];
    [answerButtons release];
    [super dealloc];
}

- (SCHStoryInteractionPopQuizQuestion *)currentQuestion
{
    return [[(SCHStoryInteractionPopQuiz *)self.storyInteraction questions] objectAtIndex:currentQuestionIndex];
}

- (void)setupView
{
    self.answerButtons = [NSArray arrayWithObjects:self.answerButton1, self.answerButton2, self.answerButton3, self.answerButton4, nil];
    self.currentQuestionIndex = 0;
    self.progressView.numberOfSteps = [[(SCHStoryInteractionPopQuiz *)self.storyInteraction questions] count];
    [self setupQuestion];
}

- (void)nextQuestion
{
    self.currentQuestionIndex++;
    if (self.currentQuestionIndex == self.progressView.numberOfSteps) {
        [self removeFromHostView];
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
        UIButton *button = [self.answerButtons objectAtIndex:i];
        [button setTitle:answer forState:UIControlStateNormal];
        [button setHidden:NO];
        ++i;
    }
    for (; i < [self.answerButtons count]; ++i) {
        [[self.answerButtons objectAtIndex:i] setHidden:YES];
    }
}

- (IBAction)closeButtonTapped:(id)sender
{
    [self removeFromHostView];
}

- (IBAction)answerButtonTapped:(id)sender
{
    NSInteger chosenAnswer = [self.answerButtons indexOfObject:sender];
    if (chosenAnswer == NSNotFound) {
        return;
    }
    
    if (chosenAnswer == [self currentQuestion].correctAnswer) {
        [sender setBackgroundImage:[UIImage imageNamed:@"popquiz-answer-button-green"] forState:UIControlStateNormal];
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [sender setBackgroundImage:[UIImage imageNamed:@"popquiz-answer-button-yellow"] forState:UIControlStateNormal];
            [self nextQuestion];
        });
    } else {
        [sender setBackgroundImage:[UIImage imageNamed:@"popquiz-answer-button-red"] forState:UIControlStateNormal];
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [sender setBackgroundImage:[UIImage imageNamed:@"popquiz-answer-button-yellow"] forState:UIControlStateNormal];
        });
    }
}

@end
