//
//  SCHStoryInteractionControllerReadingQuiz.m
//  Scholastic
//
//  Created by Gordon Christie on 24/07/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHStoryInteractionControllerReadingQuiz.h"
#import "SCHStoryInteractionReadingQuiz.h"
#import "SCHStoryInteractionProgressView.h"
#import "SCHStretchableImageButton.h"

@interface SCHStoryInteractionControllerReadingQuiz ()

@property (nonatomic, assign) NSInteger currentQuestionIndex;
@property (nonatomic, assign) NSInteger score;
@property (nonatomic, assign) NSInteger simultaneousTapCount;

@property (nonatomic, assign) BOOL completedReadthrough;
@property (nonatomic, assign) NSInteger bestScore;

- (void)setupQuestionView;
- (void)setupScoreView;

- (void)nextQuestion;
- (void)setupQuestion;

@end

@implementation SCHStoryInteractionControllerReadingQuiz

@synthesize introTitleLabel;
@synthesize introSubtitleLabel;
@synthesize introActionButton;
@synthesize progressView;
@synthesize questionLabel;
@synthesize answerButtons;
@synthesize scoreLabel;
@synthesize scoreSublabel;
@synthesize currentQuestionIndex;
@synthesize score;
@synthesize simultaneousTapCount;
@synthesize completedReadthrough;
@synthesize bestScore;

- (void)dealloc
{
    [progressView release];
    [questionLabel release];
    [answerButtons release];
    [scoreLabel release];
    [scoreSublabel release];
    [introTitleLabel release];
    [introSubtitleLabel release];
    [introActionButton release];
    [super dealloc];
}

- (id)initWithStoryInteraction:(SCHStoryInteraction *)storyInteraction
{
    self = [super initWithStoryInteraction:storyInteraction];
    
    if (self) {
        self.completedReadthrough = NO;
        self.bestScore = -1;
    }
    
    return self;
}

- (void)closeButtonTapped:(id)sender
{
    [super closeButtonTapped:sender];    
}

- (SCHStoryInteractionReadingQuizQuestion *)currentQuestion
{
    NSParameterAssert(self.currentQuestionIndex < [[(SCHStoryInteractionReadingQuiz *)self.storyInteraction questions] count]);
    
    return [[(SCHStoryInteractionReadingQuiz *)self.storyInteraction questions] objectAtIndex:currentQuestionIndex];
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

- (void)setupStartView
{
    // FIXME: in here, grab the best score from the sync
    // FIXME: in here, grab the completion status from the sync
//    self.bestScore = syncscore;
    self.completedReadthrough = YES;
    
    if (self.completedReadthrough) {
        self.introTitleLabel.text = @"How carefully did you read this Book?\nTake this quiz and find out.";
        self.introSubtitleLabel.text = [NSString stringWithFormat:@"Best Score: %d/%d", bestScore, [[(SCHStoryInteractionReadingQuiz *)self.storyInteraction questions] count]];
        [self.introActionButton setTitle:@"Start" forState:UIControlStateNormal];
        if (self.bestScore >= 0) {
            self.introSubtitleLabel.hidden = NO;
        } else {
            self.introSubtitleLabel.hidden = YES;
        }
    } else {
        self.introTitleLabel.text = @"Finish reading this book before trying this reading quiz.";
        [self.introActionButton setTitle:@"OK" forState:UIControlStateNormal];
        self.introSubtitleLabel.hidden = YES;
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
    self.progressView.numberOfSteps = [[(SCHStoryInteractionReadingQuiz *)self.storyInteraction questions] count];
    [self setupQuestion];
    
    self.controllerState = SCHStoryInteractionControllerStateInteractionInProgress;
}

- (void)setupScoreView
{
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
    [self enqueueAudioWithPath:[self.storyInteraction storyInteractionRevealSoundFilename] fromBundle:YES];
    
    if (score > self.bestScore) {
        self.bestScore = score;
        // FIXME: In here, send the new score to sync
        
    }
    
}

- (void)nextQuestion
{
    self.controllerState = SCHStoryInteractionControllerStateInteractionInProgress;
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
    self.questionLabel.text = [self currentQuestion].prompt;
    NSInteger i = 0;
    for (NSString *answer in [self currentQuestion].answers) {
        UIImage *highlight = nil;
        if (i == [self currentQuestion].correctAnswer) {
            highlight = [UIImage imageNamed:@"answer-button-green"];
        } else {
            highlight = [UIImage imageNamed:@"answer-button-red"];
        }
        SCHStretchableImageButton *button = [self.answerButtons objectAtIndex:i];
        
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
        [button setBackgroundImage:highlight forState:UIControlStateSelected];
        ++i;
    }
    for (; i < [self.answerButtons count]; ++i) {
        [[self.answerButtons objectAtIndex:i] setHidden:YES];
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
    
    NSInteger chosenAnswer = [self.answerButtons indexOfObject:sender];
    if (chosenAnswer == NSNotFound) {
        return;
    }
    
    
    [sender setSelected:YES];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [sender setSelected:NO];
        [self nextQuestion];
    });
    
    if (chosenAnswer == [self currentQuestion].correctAnswer) {
        [self enqueueAudioWithPath:[self.storyInteraction storyInteractionCorrectAnswerSoundFilename] fromBundle:YES];
        self.score++;
        
    } else {
        [self enqueueAudioWithPath:[self.storyInteraction storyInteractionWrongAnswerSoundFilename] fromBundle:YES];
    }
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
