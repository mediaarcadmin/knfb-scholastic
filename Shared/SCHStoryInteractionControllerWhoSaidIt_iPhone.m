//
//  SCHStoryInteractionControllerWhoSaidIt_iPhone.m
//  Scholastic
//
//  Created by Neil Gall on 13/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionControllerWhoSaidIt_iPhone.h"
#import "SCHStoryInteractionWhoSaidIt.h"
#import "NSArray+Shuffling.h"

@interface SCHStoryInteractionControllerWhoSaidIt_iPhone ()

@property (nonatomic, assign) NSInteger currentStatement;
@property (nonatomic, assign) NSInteger score;

- (void)setupQuestionView;
- (void)setupScoreView;

- (void)nextQuestion;
- (void)setupQuestion;

@end

@implementation SCHStoryInteractionControllerWhoSaidIt_iPhone

@synthesize statementLabel;
@synthesize answerButtons;
@synthesize scoreLabel;
@synthesize tryAgainButton;
@synthesize currentStatement;
@synthesize score;

- (void)dealloc
{
    [statementLabel release];
    [answerButtons release];
    [scoreLabel release];
    [tryAgainButton release];
    [super dealloc];
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

- (void)setupQuestionView
{
    // mix up the answers
    SCHStoryInteractionWhoSaidIt *whoSaidIt = (SCHStoryInteractionWhoSaidIt *)self.storyInteraction;
    NSInteger numAnswers = MIN([self.answerButtons count], [whoSaidIt.statements count]);
    NSArray *shuffledStatements = [whoSaidIt.statements shuffled];

    for (NSInteger i = 0; i < numAnswers; ++i) {
        SCHStoryInteractionWhoSaidItStatement *statement = [shuffledStatements objectAtIndex:i];
        UIButton *button = [self.answerButtons objectAtIndex:i];
        [button setTitle:statement.source forState:UIControlStateNormal];
        [button setHidden:NO];
        [button setTag:[whoSaidIt.statements indexOfObject:statement]];
    }
    for (NSInteger i = numAnswers; i < [self.answerButtons count]; ++i) {
        [[self.answerButtons objectAtIndex:i] setHidden:YES];
    }
    
    self.currentStatement = 0;
    self.score = 0;
    [self setupQuestion];
}

- (void)setupScoreView
{
    SCHStoryInteractionWhoSaidIt *whoSaidIt = (SCHStoryInteractionWhoSaidIt *)self.storyInteraction;
    NSInteger maxScore = [whoSaidIt.statements count]-1;
    self.scoreLabel.text = [NSString stringWithFormat:@"You got %d out of %d right!", self.score, maxScore];
}

- (void)setupQuestion
{
    SCHStoryInteractionWhoSaidIt *whoSaidIt = (SCHStoryInteractionWhoSaidIt *)self.storyInteraction;
    SCHStoryInteractionWhoSaidItStatement *statement = [whoSaidIt.statements objectAtIndex:self.currentStatement];
    self.statementLabel.text = statement.text;
    CGRect maxRect = CGRectInset(self.statementLabel.superview.bounds, 5, 5);
    CGSize textSize = [statement.text sizeWithFont:self.statementLabel.font
                                 constrainedToSize:maxRect.size
                                     lineBreakMode:self.statementLabel.lineBreakMode];
    self.statementLabel.frame = CGRectMake(CGRectGetMinX(maxRect) + (CGRectGetWidth(maxRect) - textSize.width)/2,
                                           CGRectGetMinY(maxRect) + (CGRectGetHeight(maxRect) - textSize.height)/2,
                                           textSize.width, textSize.height);

    for (UIButton *button in self.answerButtons) {
        [button setBackgroundImage:[UIImage imageNamed:@"answer-button-yellow"] forState:UIControlStateNormal];
    }
}

- (void)nextQuestion
{
    [self setUserInteractionsEnabled:YES];
    SCHStoryInteractionWhoSaidIt *whoSaidIt = (SCHStoryInteractionWhoSaidIt *)self.storyInteraction;
    do {
        self.currentStatement++;
    } while (self.currentStatement == whoSaidIt.distracterIndex);
    
    if (self.currentStatement < [whoSaidIt.statements count]) {
        [self setupQuestion];
    } else {
        [self presentNextView];
    }
}

#pragma mark - actions

- (void)answerButtonTapped:(id)sender
{
    [self setUserInteractionsEnabled:NO];

    UIButton *button = (UIButton *)sender;
    if (button.tag == self.currentStatement) {
        [button setBackgroundImage:[UIImage imageNamed:@"answer-button-green"] forState:UIControlStateNormal];
        [self playBundleAudioWithFilename:[self.storyInteraction storyInteractionCorrectAnswerSoundFilename] completion:nil];
        self.score++;
    } else {
        [button setBackgroundImage:[UIImage imageNamed:@"answer-button-red"] forState:UIControlStateNormal];
        [self playBundleAudioWithFilename:[self.storyInteraction storyInteractionWrongAnswerSoundFilename] completion:nil];
    }
         
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self nextQuestion];
    });
}

- (void)playAgainButtonTapped:(id)sender
{
    [self presentNextView];
}

@end
