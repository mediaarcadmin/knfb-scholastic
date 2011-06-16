//
//  SCHStoryInteractionControllerMultipleChoiceText.m
//  Scholastic
//
//  Created by Neil Gall on 02/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionControllerMultipleChoiceText.h"

#import "SCHStoryInteractionMultipleChoiceText.h"

#import "SCHStoryInteractionControllerDelegate.h"

@interface SCHStoryInteractionControllerMultipleChoiceText ()

@property (nonatomic, assign) NSInteger currentQuestionIndex;

- (void)nextQuestion;
- (void)setupQuestion;

@end

@implementation SCHStoryInteractionControllerMultipleChoiceText

@synthesize answerButtons;
@synthesize currentQuestionIndex;

- (void)dealloc
{
    [answerButtons release], answerButtons = nil;

    [super dealloc];
}

- (SCHStoryInteractionMultipleChoiceTextQuestion *)currentQuestion
{
    return [[(SCHStoryInteractionMultipleChoiceText *)self.storyInteraction questions] objectAtIndex:currentQuestionIndex];
}

- (void)setupViewAtIndex:(NSInteger)screenIndex
{
    [self playAudioAtPath:[(SCHStoryInteractionMultipleChoiceText *)self.storyInteraction introductionAudioPath]
               completion:^{}];

    // get the current question
    if (self.delegate && [self.delegate respondsToSelector:@selector(currentQuestionForStoryInteraction)]) {
        self.currentQuestionIndex += [self.delegate currentQuestionForStoryInteraction];    
    }
    [self setupQuestion];
}

- (void)nextQuestion
{
//    self.currentQuestionIndex++;
//    if (self.currentQuestionIndex == [[(SCHStoryInteractionMultipleChoiceText *)self.storyInteraction questions] count]) {
//        [self removeFromHostView];
//    } else {
//        [self setupQuestion];
//    }
    [self removeFromHostViewWithSuccess:YES];
}

- (void)setupQuestion
{
    BOOL iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);

    [self setTitle:[self currentQuestion].prompt];

    for (UIButton *button in self.answerButtons) {
        NSUInteger answerIndex = button.tag - 1;
        if (answerIndex < [[self currentQuestion].answers count]) {
            NSString *answer = [[self currentQuestion].answers objectAtIndex:answerIndex];
            UIImage *highlight = nil;
            if (answerIndex == [self currentQuestion].correctAnswer) {
                highlight = [[UIImage imageNamed:@"answer-button-green"] stretchableImageWithLeftCapWidth:5 topCapHeight:0];
            } else {
                highlight = [[UIImage imageNamed:@"answer-button-red"] stretchableImageWithLeftCapWidth:5 topCapHeight:0];    
            }
            [button setTitle:answer forState:UIControlStateNormal];
            [button setTitleColor:(iPad ? [UIColor whiteColor] : [UIColor colorWithRed:0.113 green:0.392 blue:0.690 alpha:1.0]) forState:UIControlStateNormal];
            [button setHidden:NO];
            [button setSelected:NO];
            [button setBackgroundImage:[(iPad == YES ? [UIImage imageNamed:@"answer-button-blue"] : [UIImage imageNamed:@"answer-button-yellow"]) stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateNormal];        
            [button setBackgroundImage:highlight forState:UIControlStateSelected];
            if (iPad == YES) {
                [button setImage:[UIImage imageNamed:@"answer-blank"] forState:UIControlStateNormal];
                if (answerIndex == [self currentQuestion].correctAnswer) {
                    [button setImage:[UIImage imageNamed:@"answer-tick"] forState:UIControlStateSelected];
                } else {
                    [button setImage:[UIImage imageNamed:@"answer-cross"] forState:UIControlStateSelected];
                }
            }
        }
    }
}

- (IBAction)answerButtonTapped:(UIButton *)sender
{
    NSUInteger chosenAnswer = sender.tag - 1;
    
    if (chosenAnswer < [[self currentQuestion].answers count]) {
        [sender setSelected:YES];
        if (chosenAnswer == [self currentQuestion].correctAnswer) {
            [self playAudioAtPath:[[self currentQuestion] audioPathForAnswerAtIndex:chosenAnswer] completion:^{
                [self playAudioAtPath:[(SCHStoryInteractionMultipleChoiceText *)self.storyInteraction audioPathForThatsRight] completion:^{
                    [self playAudioAtPath:[[self currentQuestion] audioPathForCorrectAnswer] completion:^{
                        [self nextQuestion];
                    }];
                }];
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
