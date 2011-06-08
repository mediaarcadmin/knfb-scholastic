//
//  SCHStoryInteractionControllerMultipleChoiceText.m
//  Scholastic
//
//  Created by Neil Gall on 02/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionControllerMultipleChoiceText.h"

#import "SCHStoryInteractionMultipleChoiceText.h"

@interface SCHStoryInteractionControllerMultipleChoiceText ()

@property (nonatomic, retain) NSArray *answerButtons;
@property (nonatomic, assign) NSInteger currentQuestionIndex;

- (void)nextQuestion;
- (void)setupQuestion;

@end

@implementation SCHStoryInteractionControllerMultipleChoiceText

@synthesize promptLabel;
@synthesize answerButton1;
@synthesize answerButton2;
@synthesize answerButton3;
@synthesize answerButtons;
@synthesize currentQuestionIndex;

- (void)dealloc
{
    [promptLabel release], promptLabel = nil;
    [answerButton1 release], answerButton1 = nil;
    [answerButton2 release], answerButton2 = nil;
    [answerButton3 release], answerButton3 = nil;
    [answerButtons release], answerButtons = nil;

    [super dealloc];
}

- (SCHStoryInteractionMultipleChoiceTextQuestion *)currentQuestion
{
    return [[(SCHStoryInteractionMultipleChoiceText *)self.storyInteraction questions] objectAtIndex:currentQuestionIndex];
}

- (void)setupView
{
    self.answerButtons = [NSArray arrayWithObjects:self.answerButton1, self.answerButton2, self.answerButton3, nil];
    self.currentQuestionIndex = 0;
    [self setupQuestion];
}

- (void)nextQuestion
{
    self.currentQuestionIndex++;
    if (self.currentQuestionIndex == [[(SCHStoryInteractionMultipleChoiceText *)self.storyInteraction questions] count]) {
        [self removeFromHostView];
    } else {
        [self setupQuestion];
    }
}

- (void)setupQuestion
{
    self.promptLabel.text = [self currentQuestion].prompt;
    NSInteger i = 0;
    for (NSString *answer in [self currentQuestion].answers) {
        UIImage *highlight = nil;
        UIImage *selectedIcon = nil;
        if (i == [self currentQuestion].correctAnswer) {
            highlight = [[UIImage imageNamed:@"answer-button-green"] stretchableImageWithLeftCapWidth:5 topCapHeight:0];
            selectedIcon = [UIImage imageNamed:@"answer-tick"];
        } else {
            highlight = [[UIImage imageNamed:@"answer-button-red"] stretchableImageWithLeftCapWidth:5 topCapHeight:0];    
            selectedIcon = [UIImage imageNamed:@"answer-cross"];
        }
        UIButton *button = [self.answerButtons objectAtIndex:i];
        [button setTitle:answer forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"answer-blank"] forState:UIControlStateNormal];
        [button setHidden:NO];
        [button setSelected:NO];
        [button setBackgroundImage:[[UIImage imageNamed:@"answer-button-blue"] stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateNormal];        
        [button setBackgroundImage:highlight forState:UIControlStateSelected];
        [button setImage:selectedIcon forState:UIControlStateSelected];
        ++i;
    }
    for (; i < [self.answerButtons count]; ++i) {
        [[self.answerButtons objectAtIndex:i] setHidden:YES];
    }    
}

- (IBAction)answerButtonTapped:(id)sender
{
    NSInteger chosenAnswer = [self.answerButtons indexOfObject:sender];
    
    if (chosenAnswer != NSNotFound) {
        [sender setSelected:YES];
        if (chosenAnswer == [self currentQuestion].correctAnswer) {
            [self playAudioAtPath:[[self currentQuestion] audioPathForCorrectAnswer] completion:^{
                [self nextQuestion];
            }];
        } else {
            [self playAudioAtPath:[[self currentQuestion] audioPathForIncorrectAnswer] completion:nil];
        }
    }
}

- (NSString *)audioPath
{
    return([[self currentQuestion] audioPathForQuestion]);
}

@end
