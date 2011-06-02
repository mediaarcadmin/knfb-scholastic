//
//  SCHStoryInteractionControllerPopQuiz.m
//  Scholastic
//
//  Created by Neil Gall on 02/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionControllerPopQuiz.h"
#import "SCHStoryInteractionPopQuiz.h"

@interface SCHStoryInteractionControllerPopQuiz ()

@property (nonatomic, retain) NSArray *answerButtons;
@property (nonatomic, assign) NSInteger currentQuestionIndex;

- (void)setupQuestion;

@end

@implementation SCHStoryInteractionControllerPopQuiz

@synthesize progressContainer;
@synthesize questionLabel;
@synthesize answerButton1;
@synthesize answerButton2;
@synthesize answerButton3;
@synthesize answerButton4;
@synthesize answerButtons;
@synthesize currentQuestionIndex;

- (void)dealloc
{
    [progressContainer release];
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
    [self setupQuestion];
}

- (void)setupQuestion
{
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
    
}

@end
