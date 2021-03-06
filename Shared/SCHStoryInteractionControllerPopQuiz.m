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
#import "SCHStretchableImageButton.h"

static const CGFloat kSCHStoryInteractionControllerPopQuizMaximumButtonFontSize = 16.0;
static const CGFloat kSCHStoryInteractionControllerPopQuizMinimumButtonFontSize = 10.0;

@interface SCHStoryInteractionControllerPopQuiz ()

@property (nonatomic, assign) NSInteger currentQuestionIndex;
@property (nonatomic, assign) NSInteger score;
@property (nonatomic, assign) NSInteger simultaneousTapCount;
@property (nonatomic, assign) BOOL successfullyCompleted;

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
@synthesize simultaneousTapCount;
@synthesize successfullyCompleted;

- (void)dealloc
{
    [progressView release];
    [questionLabel release];
    [answerButtons release];
    [scoreLabel release];
    [scoreSublabel release];
    [super dealloc];
}

- (id)initWithStoryInteraction:(SCHStoryInteraction *)storyInteraction
{
    self = [super initWithStoryInteraction:storyInteraction];
    
    if (self) {
        self.successfullyCompleted = NO;
    }
    
    return self;
}

- (void)closeButtonTapped:(id)sender
{
    if (self.successfullyCompleted) {
        self.controllerState = SCHStoryInteractionControllerStateInteractionFinishedSuccessfully;
    }
    
    [super closeButtonTapped:sender];    
}

- (SCHStoryInteractionPopQuizQuestion *)currentQuestion
{
    NSParameterAssert(self.currentQuestionIndex < [[(SCHStoryInteractionPopQuiz *)self.storyInteraction questions] count]);
    
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

    self.controllerState = SCHStoryInteractionControllerStateInteractionInProgress;
}

- (void)setupScoreView
{
    SCHStoryInteractionPopQuiz *popQuiz = (SCHStoryInteractionPopQuiz *)self.storyInteraction;
    NSInteger maxScore = self.progressView.numberOfSteps;
    self.scoreLabel.text = [NSString stringWithFormat:@"You got %d out of %d right!", self.score, maxScore];
    if (score <= (int) ceil((float)maxScore/3.0f)) {
        self.scoreSublabel.text = popQuiz.scoreResponseLow;
    } else if (score <= ceil((float)maxScore*2.0f/3.0f)) {
        self.scoreSublabel.text = popQuiz.scoreResponseMedium;
    } else {
        self.scoreSublabel.text = popQuiz.scoreResponseHigh;
        self.successfullyCompleted = YES;
    }
    [self enqueueAudioWithPath:[self.storyInteraction storyInteractionRevealSoundFilename] fromBundle:YES];
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
    CGFloat buttonFontSize = kSCHStoryInteractionControllerPopQuizMaximumButtonFontSize;
    for (NSString *answer in [self currentQuestion].answers) {
        UIImage *highlight = nil;
        if (i == [self currentQuestion].correctAnswer) {
            highlight = [UIImage imageNamed:@"answer-button-green"];
        } else {
            highlight = [UIImage imageNamed:@"answer-button-red"];
        }
        SCHStretchableImageButton *button = [self.answerButtons objectAtIndex:i];
        
        CGRect insetContentRect = [button contentRectForBounds:button.bounds];
        insetContentRect = UIEdgeInsetsInsetRect(insetContentRect, button.contentEdgeInsets);
        
        // increase the height so we can detect the text flowing outside the display rect
        CGSize computeSize = CGSizeMake(insetContentRect.size.width, insetContentRect.size.height * 2.0);
        for (CGFloat fontSize = kSCHStoryInteractionControllerPopQuizMaximumButtonFontSize; fontSize >= kSCHStoryInteractionControllerPopQuizMinimumButtonFontSize; fontSize -= 0.5) {
            CGSize sizeForText = [answer sizeWithFont:[UIFont fontWithName:@"Arial-BoldMT" size:fontSize] constrainedToSize:computeSize];
            if (sizeForText.height <= insetContentRect.size.height || fontSize <= kSCHStoryInteractionControllerPopQuizMinimumButtonFontSize) {
                if (buttonFontSize > fontSize) {
                    buttonFontSize = fontSize;
                }
                break;
            }
        }
    
        [button.titleLabel setLineBreakMode:UILineBreakModeWordWrap];
        [button.titleLabel setTextAlignment:UITextAlignmentCenter];
        [button setTitle:answer forState:UIControlStateNormal];
        [button setHidden:NO];
        [button setCustomTopCap:10];
        [button setBackgroundImage:highlight forState:UIControlStateSelected];
        ++i;
    }
    for (SCHStretchableImageButton *button in self.answerButtons) {
        [button.titleLabel setFont:[UIFont fontWithName:@"Arial-BoldMT" size:buttonFontSize]];
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
