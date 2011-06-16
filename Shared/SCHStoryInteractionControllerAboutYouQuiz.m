//
//  SCHStoryInteractionControllerAboutYouQuiz.m
//  Scholastic
//
//  Created by Gordon Christie on 07/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionControllerAboutYouQuiz.h"
#import "SCHStoryInteractionProgressView.h"
#import "SCHStoryInteractionAboutYouQuiz.h"

@interface SCHStoryInteractionControllerAboutYouQuiz ()

@property (nonatomic, retain) NSArray *answerButtons;
@property (nonatomic, assign) NSInteger currentQuestionIndex;

@property (nonatomic, retain) NSMutableArray *outcomeCounts;

@property (nonatomic, assign) BOOL showTitleView;
@property (nonatomic, assign) BOOL showResultView;

- (void)nextQuestion;
- (void)setupQuestion;
- (SCHStoryInteractionAboutYouQuizQuestion *)currentQuestion;
- (NSString *)calculatedResult;

@end


@implementation SCHStoryInteractionControllerAboutYouQuiz

@synthesize progressView;
@synthesize questionLabel;
@synthesize answerButton1;
@synthesize answerButton2;
@synthesize answerButton3;
@synthesize answerButton4;
@synthesize answerButton5;
@synthesize answerButtons;
@synthesize currentQuestionIndex;
@synthesize outcomeCounts;
@synthesize showTitleView;
@synthesize showResultView;

- (void)dealloc
{
    [progressView release], progressView = nil;
    [questionLabel release], questionLabel = nil;
    [answerButton1 release], answerButton1 = nil;
    [answerButton2 release], answerButton2 = nil;
    [answerButton3 release], answerButton3 = nil;
    [answerButton4 release], answerButton4 = nil;
    [answerButton5 release], answerButton5 = nil;
    
    [answerButtons release], answerButtons = nil;
    [outcomeCounts release], outcomeCounts = nil;
    
    [super dealloc];
}


- (void)setupViewAtIndex:(NSInteger)screenIndex
{
    [self playBundleAudioWithFilename:[self.storyInteraction storyInteractionOpeningSoundFilename] completion:nil];

    self.showTitleView = YES;
    self.showResultView = NO;
    self.answerButtons = [NSArray arrayWithObjects:self.answerButton1, self.answerButton2, self.answerButton3, self.answerButton4, self.answerButton5, nil];
    self.currentQuestionIndex = 0;
    self.progressView.numberOfSteps = [[(SCHStoryInteractionAboutYouQuiz *)self.storyInteraction questions] count];
    
    NSInteger outcomes = [[(SCHStoryInteractionAboutYouQuiz *)self.storyInteraction outcomeMessages] count];
    
    self.outcomeCounts = [[NSMutableArray alloc] initWithCapacity:outcomes];
    
    for (NSInteger i = 0; i < outcomes; i++) {
        [self.outcomeCounts addObject:[NSNumber numberWithInt:0]];
    }
    
    for (UIButton *button in answerButtons) {
        button.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
        button.titleLabel.textAlignment = UITextAlignmentCenter;
    }
    
    [self setupQuestion];
}

- (void)setupQuestion
{
    if (self.showTitleView) {
        [self.progressView setHidden:YES];
        self.questionLabel.text = [(SCHStoryInteractionAboutYouQuiz *)self.storyInteraction introduction];
        
        [self.answerButton2 setTitle:NSLocalizedString(@"Go", @"Go") forState:UIControlStateNormal];
        
        for (NSInteger i = 0; i < [[self answerButtons] count]; i++) {
            if (i != 1) {
                [[self.answerButtons objectAtIndex:i] setHidden:YES];
            }
        }
    } else if (self.showResultView) {
        [self.progressView setHidden:YES];
        self.questionLabel.text = [self calculatedResult];
        
        for (NSInteger i = 0; i < [[self answerButtons] count]; i++) {
            [[self.answerButtons objectAtIndex:i] setHidden:YES];
        }
    } else {
        [self.progressView setHidden:NO];
        self.progressView.currentStep = self.currentQuestionIndex;
        self.questionLabel.text = [[self currentQuestion] prompt];
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
}

- (void)nextQuestion
{
    self.currentQuestionIndex++;
    if (self.currentQuestionIndex == self.progressView.numberOfSteps) {
        self.showResultView = YES;
    }

    [self setupQuestion];
}


- (SCHStoryInteractionAboutYouQuizQuestion *)currentQuestion
{
    return [[(SCHStoryInteractionAboutYouQuiz *)self.storyInteraction questions] objectAtIndex:currentQuestionIndex];
}

- (NSString *)calculatedResult
{
    NSArray *outcomeMessages = [(SCHStoryInteractionAboutYouQuiz *)self.storyInteraction outcomeMessages];
    NSString *resultMessage = nil;
    
    NSInteger highestValue = -1;
    NSMutableArray *highestQuestions = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 0; i < [self.outcomeCounts count]; i++) {
        if ([[self.outcomeCounts objectAtIndex:i] intValue] > highestValue) {
            highestValue = [[self.outcomeCounts objectAtIndex:i] intValue];
            [highestQuestions removeAllObjects];
            [highestQuestions addObject:[NSNumber numberWithInt:i]];
        } else if ([[self.outcomeCounts objectAtIndex:i] intValue] == highestValue) {
            [highestQuestions addObject:[NSNumber numberWithInt:i]];
        }
    }
    
    NSArray *tiebreakOrder = [(SCHStoryInteractionAboutYouQuiz *) self.storyInteraction tiebreakOrder];
    
    if (tiebreakOrder && [tiebreakOrder count] > 0) {
        for (NSNumber *item in tiebreakOrder) {
            if (item) {
                NSInteger itemvalue = [item intValue];
                
                for (NSInteger i = 0; i < [highestQuestions count]; i++) {
                    NSInteger questionNumber = [[highestQuestions objectAtIndex:i] intValue];
                    
                    NSLog(@"Comparing %d to %d", questionNumber, itemvalue);
                    if (questionNumber == itemvalue) {
                        resultMessage = [outcomeMessages objectAtIndex:[[highestQuestions objectAtIndex:i] intValue]];
                        break;
                    }
                }
                
                if (resultMessage) {
                    break;
                }
            }
        }
    }
    
    [highestQuestions release];
    return resultMessage;
}


- (IBAction)questionButtonTapped:(id)sender
{
    if (self.showTitleView) {
        self.showTitleView = NO;
        [self setupQuestion];
    } else {
        NSNumber *selection = [NSNumber numberWithInt:[self.answerButtons indexOfObject:sender]];

        NSNumber *currentCount = [self.outcomeCounts objectAtIndex:[selection intValue]];
        
        currentCount = [NSNumber numberWithInt:[currentCount intValue] + 1];
        [self.outcomeCounts replaceObjectAtIndex:[selection intValue] withObject:currentCount];
        
        [self nextQuestion];
    }
    
}


@end
