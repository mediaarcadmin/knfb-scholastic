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
#import "SCHStretchableImageButton.h"
    
typedef enum {
	SCHStoryInteractionOpeningScreen,
    SCHStoryInteractionMainScreen,
    SCHStoryInteractionOutcomeScreen
} SCHStoryInteractionScreen;

@interface SCHStoryInteractionControllerAboutYouQuiz ()

@property (nonatomic, assign) NSInteger currentQuestionIndex;
@property (nonatomic, retain) NSMutableArray *outcomeCounts;
@property (nonatomic, assign) NSInteger simultaneousTapCount;

- (void)setupOpeningView;
- (void)setupMainView;
- (void)setupOutcomeView;

- (void)nextQuestion;
- (void)setupQuestion;
- (SCHStoryInteractionAboutYouQuizQuestion *)currentQuestion;
- (NSString *)calculatedResult;

@end


@implementation SCHStoryInteractionControllerAboutYouQuiz

@synthesize introductionLabel;

@synthesize progressView;
@synthesize questionLabel;
@synthesize answerButtons;
@synthesize buttonContainerView;
@synthesize currentQuestionIndex;
@synthesize simultaneousTapCount;

@synthesize outcomeCounts;
@synthesize outcomeTitleLabel;
@synthesize outcomeTextLabel;

- (void)dealloc
{
    [introductionLabel release], introductionLabel = nil;
    
    [progressView release], progressView = nil;
    [questionLabel release], questionLabel = nil;    
    [answerButtons release], answerButtons = nil;
    [outcomeCounts release], outcomeCounts = nil;    
    
    [outcomeTitleLabel release], outcomeTitleLabel = nil;
    [outcomeTextLabel release], outcomeTextLabel = nil;
    
    [buttonContainerView release];
    [super dealloc];
}

- (void)setupViewAtIndex:(NSInteger)screenIndex
{
    switch (screenIndex) {
        case SCHStoryInteractionOpeningScreen:
            [self setupOpeningView];
            break;
        case SCHStoryInteractionMainScreen:
            [self setupMainView];
            break;
        case SCHStoryInteractionOutcomeScreen:
            [self setupOutcomeView];
            break;            
    }
}

- (void)setupOpeningView
{
    self.introductionLabel.text = [(SCHStoryInteractionAboutYouQuiz *)self.storyInteraction introduction];    
}

- (void)setupMainView
{
    self.answerButtons = [self.answerButtons sortedArrayUsingDescriptors:
                          [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"tag" ascending:YES]]];
    self.currentQuestionIndex = 0;
    self.progressView.numberOfSteps = [[(SCHStoryInteractionAboutYouQuiz *)self.storyInteraction questions] count];
        
    for (SCHStretchableImageButton *button in self.answerButtons) {
        button.customTopCap = 10;
    }
    
    NSInteger outcomes = [[(SCHStoryInteractionAboutYouQuiz *)self.storyInteraction outcomeMessages] count];
    self.outcomeCounts = [NSMutableArray arrayWithCapacity:outcomes];
    for (NSInteger i = 0; i < outcomes; i++) {
        [self.outcomeCounts addObject:[NSNumber numberWithInt:0]];
    }

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.titleView.font = [UIFont fontWithName:@"Helvetica Bold" size:15];
        self.titleView.textAlignment = UITextAlignmentLeft;
    }
    
    // this code covers the state when the answer button is both selected and highlighted
    // prevents a flash between selection and moving on to the next question
    for (UIButton *item in self.answerButtons) {
        [item setBackgroundImage:[UIImage imageNamed:@"answer-button-green.png"] forState:(UIControlStateHighlighted|UIControlStateSelected)];
    }
    
    [self setupQuestion];   
    
    [self willRotateToInterfaceOrientation:self.interfaceOrientation duration:0.0];
}

- (void)setupOutcomeView
{
    NSArray *splitResult = [[self calculatedResult] componentsSeparatedByString:@". "];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self setupTitle];        
    }
    self.outcomeTextLabel.text = ([splitResult count] > 0 ? [NSString stringWithFormat:@"%@.", [splitResult objectAtIndex:0]] : @"");
    self.outcomeTitleLabel.text = ([splitResult count] > 1 ? [splitResult objectAtIndex:1] : @"");
}

- (void)setupQuestion
{
    BOOL iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    
    self.progressView.currentStep = self.currentQuestionIndex;
    
    if (iPad == YES) {
        self.questionLabel.text = [[self currentQuestion] prompt];
    } else {
        [self setTitle:[[self currentQuestion] prompt]];
    }
    
    NSInteger i = 0;
    
    for (NSString *answer in [self currentQuestion].answers) {
        SCHStretchableImageButton *button = [self.answerButtons objectAtIndex:i];

        [button setTitle:answer forState:UIControlStateNormal];
        [button setHidden:NO];
        ++i;
    }
    
    
    for (; i < [self.answerButtons count]; ++i) {
        [[self.answerButtons objectAtIndex:i] setHidden:YES];
    }
    
    self.simultaneousTapCount = 0;
    self.controllerState = SCHStoryInteractionControllerStateInteractionInProgress;
}

- (void)nextQuestion
{
    self.currentQuestionIndex++;
    if (self.currentQuestionIndex == self.progressView.numberOfSteps) {
        [self enqueueAudioWithPath:[self.storyInteraction storyInteractionRevealSoundFilename] fromBundle:YES];
        self.controllerState = SCHStoryInteractionControllerStateInteractionFinishedSuccessfully;
        [self presentNextView];
    } else {
        [self setupQuestion];
    }
}

- (SCHStoryInteractionAboutYouQuizQuestion *)currentQuestion
{
    NSAssert(currentQuestionIndex < [[(SCHStoryInteractionAboutYouQuiz *)self.storyInteraction questions] count], @"index must be within array bounds");
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

#pragma mark - Actions

- (IBAction)startButtonTapped:(id)sender
{
    [self cancelQueuedAudioExecutingSynchronizedBlocksBefore:^{
        [self enqueueAudioWithPath:[self.storyInteraction storyInteractionCorrectAnswerSoundFilename] fromBundle:YES];
        [self presentNextView];
    }];
}

- (IBAction)questionButtonTouched:(UIButton *)sender
{
    self.controllerState = SCHStoryInteractionControllerStateInteractionReadingAnswerWithPause;        
}

- (IBAction)questionButtonTapCancelled:(id)sender
{
    self.controllerState = SCHStoryInteractionControllerStateInteractionInProgress;
}

- (IBAction)questionButtonTapped:(UIButton *)sender
{
    NSLog(@"Question button tapped: %d", [self.answerButtons indexOfObject:sender]);
    self.simultaneousTapCount++;
    if (self.simultaneousTapCount == 1) {
        [sender setSelected:YES];
        [self performSelector:@selector(answerChosen:) withObject:sender afterDelay:kMinimumDistinguishedAnswerDelay];
    }
}

- (void)answerChosen:(UIButton *)sender
{
    NSInteger tapCount = self.simultaneousTapCount;
    self.simultaneousTapCount = 0;
    if (tapCount > 1) {
        [sender setSelected:NO];
        return;
    }

    [self cancelQueuedAudioExecutingSynchronizedBlocksBefore:^{
        [self enqueueAudioWithPath:[self.storyInteraction storyInteractionCorrectAnswerSoundFilename] fromBundle:YES];
        
        [sender setSelected:YES];
        
        [self performSelector:@selector(unhighlightAndMoveOn:) withObject:sender afterDelay:1.0];
    }];
}

- (void)unhighlightAndMoveOn:(UIButton *) sender
{
    NSNumber *selection = [NSNumber numberWithInt:[self.answerButtons indexOfObject:sender]];
    NSNumber *currentCount = [self.outcomeCounts objectAtIndex:[selection intValue]];
    
    currentCount = [NSNumber numberWithInt:[currentCount intValue] + 1];
    [self.outcomeCounts replaceObjectAtIndex:[selection intValue] withObject:currentCount];
    
    self.controllerState = SCHStoryInteractionControllerStateInteractionInProgress;
    
    [sender setSelected:NO];
    [self nextQuestion];
}

- (IBAction)doneButtonTapped:(id)sender
{
    [self cancelQueuedAudioExecutingSynchronizedBlocksBefore:^{
        [self enqueueAudioWithPath:[self.storyInteraction storyInteractionCorrectAnswerSoundFilename] fromBundle:YES];
        [self performSelector:@selector(removeFromHostView) withObject:nil afterDelay:0.5];
    }];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];

    // if we have questions to show...
    if (self.currentQuestionIndex < self.progressView.numberOfSteps) {
    
        // button spacing and height
        NSInteger activeButtonCount = [[[self currentQuestion] answers] count];
        CGFloat areaHeight = CGRectGetHeight(self.buttonContainerView.frame);
        
        CGFloat buttonHeight = floorf(areaHeight * 0.9 / activeButtonCount);
        CGFloat buttonSpacing = floorf((areaHeight - (activeButtonCount * buttonHeight)) / activeButtonCount);
        CGFloat topBottomInset = floorf(buttonHeight * 0.2);
        
        buttonSpacing = floorf(((buttonSpacing * activeButtonCount) - buttonSpacing) / activeButtonCount);
        
        for (int i = 0; i < activeButtonCount; i++) {
            UIButton *currentButton = (UIButton *)[self.answerButtons objectAtIndex:i];
            CGRect buttonFrame = currentButton.frame;
            buttonFrame.origin.y = topBottomInset + (i * buttonHeight) + (i * buttonSpacing);
            buttonFrame.size.height = buttonHeight;
            currentButton.frame = buttonFrame;
        }
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    // font resizing and insets
    UIEdgeInsets imageInsets = UIEdgeInsetsMake(0, CGRectGetWidth([[self.answerButtons objectAtIndex:0] bounds])-40, 0, 0);
    for (UIButton *button in self.answerButtons) {
        [button setImageEdgeInsets:imageInsets];
    }
    
    [self adjustButtonsFont];
}

- (void)adjustButtonsFont
{
    NSString *fontName = [[[[self.answerButtons objectAtIndex:0] titleLabel] font] fontName];
    CGFloat fontSize = 16;
    BOOL tooBig;
    do {
        tooBig = NO;
        for (UIButton *button in self.answerButtons) {
            
            UIEdgeInsets buttonInsets = UIEdgeInsetsMake(10, 10, 10, 10);
            
            CGSize maximumSize = UIEdgeInsetsInsetRect(button.bounds, buttonInsets).size;
            NSString *text = [button titleForState:UIControlStateNormal];
            CGSize constraintSize = CGSizeMake(maximumSize.width, CGFLOAT_MAX);
            CGSize size = [text sizeWithFont:[UIFont fontWithName:fontName size:fontSize]
                           constrainedToSize:constraintSize
                               lineBreakMode:button.titleLabel.lineBreakMode];
            if (size.height > maximumSize.height) {
                tooBig = YES;
                fontSize -= 2;
                break;
            }
        }
    } while (tooBig && fontSize > 10);
    
    UIFont *font = [UIFont fontWithName:fontName size:fontSize];
    for (UIButton *button in self.answerButtons) {
        button.titleLabel.font = font;
    }
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
