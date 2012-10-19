//
//  SCHStoryInteractionControllerReadingChallenge.m
//  Scholastic
//
//  Created by Gordon Christie on 24/07/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHStoryInteractionControllerReadingChallenge.h"
#import "SCHStoryInteractionReadingChallenge.h"
#import "SCHStoryInteractionProgressView.h"
#import "SCHStretchableImageButton.h"
#import "SCHStoryInteractionControllerDelegate.h"

@interface SCHStoryInteractionControllerReadingChallenge ()

@property (nonatomic, assign) NSInteger currentQuestionIndex;
@property (nonatomic, assign) NSInteger score;
@property (nonatomic, assign) NSInteger simultaneousTapCount;

@property (nonatomic, retain) NSMutableArray *answersGiven;
@property (nonatomic, assign) BOOL completedReadthrough;
@property (nonatomic, assign) NSInteger bestScore;

@property (nonatomic, retain) NSMutableArray *answerViews;

- (void)setupQuestionView;
- (void)setupScoreView;

- (void)nextQuestion;
- (void)setupQuestion;

- (void)playQuestionAudioAndHighlightAnswers;

@end

@implementation SCHStoryInteractionControllerReadingChallenge

@synthesize introTitleLabel;
@synthesize introSubtitleLabel;
@synthesize introActionButton;
@synthesize tryAgainButton;
@synthesize ipadQuestionLabel;
@synthesize answerScrollView;
@synthesize answerScrollViewContainer;
@synthesize progressView;
@synthesize answerButtons;
@synthesize answerBackgroundView;
@synthesize scoreLabel;
@synthesize scoreSublabel;
@synthesize resultsHeaderLabel;
@synthesize currentQuestionIndex;
@synthesize score;
@synthesize simultaneousTapCount;
@synthesize completedReadthrough;
@synthesize bestScore;
@synthesize answersGiven;
@synthesize answerViews;
@synthesize bestScoreLabel;

- (void)dealloc
{
    [bestScoreLabel release];
    [answerViews release];
    [answersGiven release];
    [progressView release];
    [answerButtons release];
    [scoreLabel release];
    [scoreSublabel release];
    [introTitleLabel release];
    [introSubtitleLabel release];
    [introActionButton release];
    [answerScrollView release];
    [answerScrollViewContainer release];
    [resultsHeaderLabel release];
    [answerBackgroundView release];
    [ipadQuestionLabel release];
    [tryAgainButton release];
    [super dealloc];
}

- (id)initWithStoryInteraction:(SCHStoryInteraction *)storyInteraction
{
    self = [super initWithStoryInteraction:storyInteraction];
    
    if (self) {
        self.completedReadthrough = NO;
        self.bestScore = -1;
        self.answersGiven = [NSMutableArray array];
        self.answerViews = [NSMutableArray array];
    }
    
    return self;
}

- (void)closeButtonTapped:(id)sender
{
    [super closeButtonTapped:sender];    
}

- (SCHStoryInteractionReadingChallengeQuestion *)currentQuestion
{
    NSParameterAssert(self.currentQuestionIndex < [[(SCHStoryInteractionReadingChallenge *)self.storyInteraction questions] count]);
    
    return [[(SCHStoryInteractionReadingChallenge *)self.storyInteraction questions] objectAtIndex:currentQuestionIndex];
}

- (void)setupViewAtIndex:(NSInteger)screenIndex
{    
    switch (screenIndex) {
        case 0: 
            [self setupStartView];
            break;
        case 1:
            [self setupQuestionView];
            break;
        case 2:
            [self setupScoreView];
            break;
    }
}

- (IBAction)startViewButtonTapped:(UIButton *)sender
{
    if (self.completedReadthrough) {
        [self presentNextView];
    } else {
        [self closeButtonTapped:nil];
    }
}

- (void)tappedAudioButton:(id)sender withViewAtIndex:(NSInteger)screenIndex
{
    // this can only be executed when this is a younger story interaction
    // disabled by shouldShowAudioButtonForViewAtIndex:
    
    [self cancelQueuedAudioExecutingSynchronizedBlocksBefore:^{
        switch (screenIndex) {
            case 0:
                if (self.completedReadthrough) {
                    [self enqueueAudioWithPath:[(SCHStoryInteractionReadingChallenge *)self.storyInteraction audioPathForIntroduction]
                                    fromBundle:YES];
                } else {
                    [self enqueueAudioWithPath:[(SCHStoryInteractionReadingChallenge *)self.storyInteraction audioPathForNotCompletedBook]
                                    fromBundle:YES];
                }
                break;
            case 1:
                [self playQuestionAudioAndHighlightAnswers];
                break;
            case 2:
                [self playSummaryAudio];
                break;
            default:
                NSLog(@"Warning: unknown view index.");
                [self enqueueAudioWithPath:[(SCHStoryInteractionReadingChallenge *)self.storyInteraction audioPathForNotCompletedBook]
                                fromBundle:YES];
                break;
        }
    }];
    
}


- (void)setupStartView
{
    NSNumber *bestQuizScore = [self.delegate bestQuizScore];
    self.bestScore = (bestQuizScore == nil ? -1 : [bestQuizScore integerValue]);

    self.completedReadthrough = [self.delegate bookHasBeenReadThroughCompletely];
    
    if (self.completedReadthrough) {
        if (!self.storyInteraction.olderStoryInteraction) {
            [self enqueueAudioWithPath:[(SCHStoryInteractionReadingChallenge *)self.storyInteraction audioPathForIntroduction]
                        fromBundle:YES];
        }
        
        self.bestScoreLabel.text = [NSString stringWithFormat:@"Best Score: %d/%d", bestScore, [[(SCHStoryInteractionReadingChallenge *)self.storyInteraction questions] count]];
        [self.introActionButton setTitle:@"Start" forState:UIControlStateNormal];
        if (self.bestScore >= 0) {
            self.bestScoreLabel.hidden = NO;
        } else {
            self.bestScoreLabel.hidden = YES;
        }
    } else {
        if (!self.storyInteraction.olderStoryInteraction) {
            [self enqueueAudioWithPath:[(SCHStoryInteractionReadingChallenge *)self.storyInteraction audioPathForNotCompletedBook]
                        fromBundle:YES];
        }
        self.introTitleLabel.text = @"Finish reading this book before trying this reading challenge.";
        [self.introActionButton setTitle:@"OK" forState:UIControlStateNormal];
        self.introSubtitleLabel.hidden = YES;
        self.bestScoreLabel.hidden = YES;
    }
    
    if (!self.storyInteraction.olderStoryInteraction) {
        [self.introActionButton setBackgroundImage:[UIImage imageNamed:@"answer-button-blue"] forState:UIControlStateNormal];
        [self.introActionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.introActionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    } else {
        [self.introActionButton setTitleColor:[UIColor SCHDarkBlue1Color] forState:UIControlStateNormal];
    }
}

- (BOOL)shouldPlayQuestionAudioForViewAtIndex:(NSInteger)screenIndex
{
    // special audio handling
    return NO;
}

- (BOOL)shouldShowAudioButtonForViewAtIndex:(NSInteger)screenIndex
{
    if (self.storyInteraction.olderStoryInteraction) {
        return NO;
    } else {
        return YES;
    }
}

- (void)setupQuestionView
{
    if (!self.storyInteraction.olderStoryInteraction) {
        self.progressView.youngerMode = YES;
    }
    
    [self.answersGiven removeAllObjects];
    self.currentQuestionIndex = 0;
    self.score = 0;
    self.progressView.numberOfSteps = [[(SCHStoryInteractionReadingChallenge *)self.storyInteraction questions] count];
    [self setupQuestion];
    
    self.controllerState = SCHStoryInteractionControllerStateInteractionInProgress;
}

- (void)setupScoreView
{
    UIColor *backgroundColor = [UIColor whiteColor];
    
    if (self.storyInteraction.olderStoryInteraction) {
        backgroundColor = [UIColor colorWithRed:0.851 green:0.945 blue:0.996 alpha:1];
    } else {
        backgroundColor = [UIColor colorWithRed:0.992 green:1.000 blue:0.816 alpha:1];
    }
    
    if (!self.storyInteraction.olderStoryInteraction) {
        [self.tryAgainButton setBackgroundImage:[UIImage imageNamed:@"answer-button-blue"] forState:UIControlStateNormal];
        [self.tryAgainButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.tryAgainButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    } else {
        [self.tryAgainButton setTitleColor:[UIColor SCHDarkBlue1Color] forState:UIControlStateNormal];
    }
    
    self.answerBackgroundView.backgroundColor = backgroundColor;

    [self enqueueAudioWithPath:[self.storyInteraction storyInteractionRevealSoundFilename] fromBundle:YES];
    
    
    NSInteger maxScore = self.progressView.numberOfSteps;
    self.scoreLabel.text = [NSString stringWithFormat:@"You got %d out of %d right!", self.score, maxScore];
    if (score <= (int) ceil((float)maxScore/2.0f)) {
        // 50% or less
        self.scoreSublabel.text = NSLocalizedString(@"Try reading the book again to find more answers.", @"Try reading the book again to find more answers.");
    } else if (score < ceil((float)maxScore)) {
        // less than 100%
        self.scoreSublabel.text = NSLocalizedString(@"Great job! Read the book again for an even higher score.", @"Great job! Read the book again for an even higher score.");
    } else {
        // 100%
        self.scoreSublabel.text = NSLocalizedString(@"Great reading!", @"Great reading!");
    }
    
    if (score > self.bestScore) {
        self.bestScore = score;
        [self.delegate addQuizScore:score total:[[(SCHStoryInteractionReadingChallenge *)self.storyInteraction questions] count]];
    }

    [self playSummaryAudio];
    [self setupScoreAnswers];

}

- (void)playSummaryAudio
{
    if (!self.storyInteraction.olderStoryInteraction) {
        NSInteger maxScore = self.progressView.numberOfSteps;
        if (score <= (int) ceil((float)maxScore/2.0f)) {
            // 50% or less
            if (!self.storyInteraction.olderStoryInteraction) {
                [self enqueueAudioWithPath:[(SCHStoryInteractionReadingChallenge *)self.storyInteraction audioPathForLessThanFiftyPercent]
                                fromBundle:YES];
            }
        } else if (score < ceil((float)maxScore)) {
            // less than 100%
            if (!self.storyInteraction.olderStoryInteraction) {
                [self enqueueAudioWithPath:[(SCHStoryInteractionReadingChallenge *)self.storyInteraction audioPathForMoreThanFiftyPercent]
                                fromBundle:YES];
            }
        } else {
            // 100%
            if (!self.storyInteraction.olderStoryInteraction) {
                [self enqueueAudioWithPath:[(SCHStoryInteractionReadingChallenge *)self.storyInteraction audioPathForAllCorrect]
                                fromBundle:YES];
            }
        }
    }
}

- (void)setupScoreAnswers
{
    [self.answerScrollView scrollRectToVisible:CGRectMake(0, 0, self.answerScrollView.frame.size.width, self.answerScrollView.frame.size.height) animated:NO];
    
    for (UIView *existingView in [self.answerScrollViewContainer subviews]) {
        if (existingView.tag == 999) {
            [existingView removeFromSuperview];
        }
    }
    
    CGFloat currentY = self.resultsHeaderLabel.frame.origin.y + self.resultsHeaderLabel.frame.size.height;
    
    for (int i = 0; i < self.answersGiven.count; i++)
    {
        NSInteger answerGiven = [[self.answersGiven objectAtIndex:i] intValue];
        SCHStoryInteractionReadingChallengeQuestion *question = [[(SCHStoryInteractionReadingChallenge *)self.storyInteraction questions] objectAtIndex:i];
        BOOL correctAnswer = (answerGiven == question.correctAnswer);
        
        SCHStoryInteractionReadingChallengeResultView *resultView = [[SCHStoryInteractionReadingChallengeResultView alloc] init];
        
        resultView.tag = 999;
        resultView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        [resultView setQuestion:[NSString stringWithFormat:@"%d. %@", i + 1, question.prompt]];
        
        NSString *answer = [[question answers] objectAtIndex:answerGiven];
        
        if (correctAnswer) {
            [resultView setCorrectAnswer:answer];
        } else {
            [resultView setWrongAnswer:answer];
        }
        
        
        CGFloat answerHeight = [resultView heightForCurrentTextWithWidth:self.answerScrollViewContainer.frame.size.width];
        resultView.frame = CGRectMake(0, currentY, self.answerScrollViewContainer.frame.size.width, answerHeight);
        
        currentY += answerHeight;
        [self.answerScrollViewContainer addSubview:resultView];
    }
    
    
    CGRect containerFrame = self.answerScrollViewContainer.frame;
    
    CGFloat containerFrameHeight = currentY + 15;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        containerFrameHeight = MAX(containerFrameHeight, 210);
     } else {
         if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
             containerFrameHeight = MAX(containerFrameHeight, 260);
         } else {
             containerFrameHeight = MAX(containerFrameHeight, 102);
         }
     }
    
    containerFrame.size.height = containerFrameHeight;
    containerFrame.size.width = self.answerScrollView.frame.size.width;
    self.answerScrollViewContainer.frame = containerFrame;

    containerFrame.origin.y = 0;
    self.answerBackgroundView.frame = containerFrame;
    
    // provide a rounded bottom edge for the answer background view
    UIBezierPath* rounded = [UIBezierPath bezierPathWithRoundedRect:self.answerBackgroundView.bounds
                                                  byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight
                                                        cornerRadii:CGSizeMake(10.0, 10.0)];
    
    CAShapeLayer* shape = [[CAShapeLayer alloc] init];
    [shape setPath:rounded.CGPath];
    
    self.answerBackgroundView.layer.mask = shape;
    
    self.answerScrollView.contentSize = CGSizeMake(self.answerScrollView.frame.size.width,
                                                   self.answerScrollViewContainer.frame.size.height + self.answerScrollViewContainer.frame.origin.y);
    
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.answerScrollView flashScrollIndicators];
    });
}

- (void)rotateToOrientation:(UIInterfaceOrientation)orientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        double delayInSeconds = 0.15;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self setupScoreAnswers];
        });
        
    }
}

- (void)playQuestionAudioAndHighlightAnswers
{
    if (!self.storyInteraction.olderStoryInteraction) {
    
        [self cancelQueuedAudioExecutingSynchronizedBlocksBefore:^{
            
            self.controllerState = SCHStoryInteractionControllerStateInteractionReadingAnswerWithPause;
        
            [self enqueueAudioWithPath:[[self currentQuestion] audioPathForQuestion]
                            fromBundle:NO];
            
            NSInteger index = 0;
            for (UIButton *button in self.answerButtons) {
                [self enqueueAudioWithPath:[[self currentQuestion] audioPathForAnswerAtIndex:index]
                                fromBundle:NO
                                startDelay:0.5
                    synchronizedStartBlock:^{
                        [button setHighlighted:YES];
                    }
                      synchronizedEndBlock:^{
                          [button setHighlighted:NO];
                          if (index + 1 == [self.answerButtons count]) {
                              self.controllerState = SCHStoryInteractionControllerStateInteractionInProgress;
                          }
                      }];
                index++;
            }
        }];
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
    self.simultaneousTapCount = 0;
    self.progressView.currentStep = self.currentQuestionIndex;
//    self.questionLabel.text = [self currentQuestion].prompt;

    if (self.ipadQuestionLabel) {
        self.ipadQuestionLabel.text = [self currentQuestion].prompt;
    } else {
        [self setTitle:[self currentQuestion].prompt];
    }
    NSInteger i = 0;
    for (NSString *answer in [self currentQuestion].answers) {
        SCHStretchableImageButton *button = [self.answerButtons objectAtIndex:i];
        
        if (!self.storyInteraction.olderStoryInteraction) {
            [button setBackgroundImage:[UIImage imageNamed:@"answer-button-blue"] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        } else {
            [button setTitleColor:[UIColor SCHDarkBlue1Color] forState:UIControlStateNormal];
        }
        
        BOOL iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
        
        CGSize buttonSize = button.frame.size;
        UIFont *buttonFont = [UIFont fontWithName:@"Arial-BoldMT" size:iPad?15:15];
        
        float actualFontSize = 15;
        float leftRightPadding = 10;
        [answer sizeWithFont:buttonFont 
                 minFontSize:8 
              actualFontSize:&actualFontSize 
                    forWidth:buttonSize.width - leftRightPadding
               lineBreakMode:UILineBreakModeWordWrap];
        
        [button.titleLabel setFont:[UIFont fontWithName:@"Arial-BoldMT" size:actualFontSize]];
        [button.titleLabel setNumberOfLines:2];
        [button.titleLabel setLineBreakMode:UILineBreakModeWordWrap];
        [button.titleLabel setTextAlignment:UITextAlignmentCenter];
        [button setTitle:answer forState:UIControlStateNormal];
        [button setHidden:NO];
        [button setCustomTopCap:10];
        
        
        ++i;
    }
    for (; i < [self.answerButtons count]; ++i) {
        [[self.answerButtons objectAtIndex:i] setHidden:YES];
    }
    
    if (!self.storyInteraction.olderStoryInteraction) {
        [self playQuestionAudioAndHighlightAnswers];
    }
}

- (IBAction)answerButtonTouched:(id)sender
{
    self.controllerState = SCHStoryInteractionControllerStateInteractionReadingAnswerWithPause;
}

- (IBAction)answerButtonTapCancelled:(id)sender
{
    self.controllerState = SCHStoryInteractionControllerStateInteractionInProgress;
}

- (IBAction)answerButtonTapped:(id)sender
{
    self.simultaneousTapCount++;
    if (self.simultaneousTapCount == 1) {
        [self performSelector:@selector(answerChosen:) withObject:sender afterDelay:kMinimumDistinguishedAnswerDelay];
    }
}

- (void)answerChosen:(id)sender
{
    NSInteger tapCount = self.simultaneousTapCount;
    self.simultaneousTapCount = 0;
    if (tapCount > 1) {
        return;
    }
 
    [self cancelQueuedAudioExecutingSynchronizedBlocksBefore:^{
        NSInteger chosenAnswer = [self.answerButtons indexOfObject:sender];
        if (chosenAnswer == NSNotFound) {
            return;
        }
        
        [self enqueueAudioWithPath:[self.storyInteraction storyInteractionCorrectAnswerSoundFilename] fromBundle:YES];
        
        [self.answersGiven addObject:[NSNumber numberWithInt:chosenAnswer]];

        if (chosenAnswer == [self currentQuestion].correctAnswer) {
            self.score++;
            
        }
        
        [self performSelector:@selector(unhighlightAndMoveOn:) withObject:sender afterDelay:1.0];
    }];
}

- (void)unhighlightAndMoveOn:(UIButton *) sender
{
    self.controllerState = SCHStoryInteractionControllerStateInteractionInProgress;
    [self nextQuestion];
}

- (void)playAgainButtonTapped:(id)sender
{
    [self enqueueAudioWithPath:[self.storyInteraction storyInteractionOpeningSoundFilename] fromBundle:YES];
    [self presentNextView];
}

#pragma mark - Override for SCHStoryInteractionControllerStateReactions

- (void)storyInteractionDisableUserInteraction
{
    // disable user interaction
    for (UIButton *button in self.answerButtons) {
        [button setUserInteractionEnabled:NO];
    }
}

- (void)storyInteractionEnableUserInteraction
{
    // enable user interaction
    for (UIButton *button in self.answerButtons) {
        [button setUserInteractionEnabled:YES];
    }
}



@end
