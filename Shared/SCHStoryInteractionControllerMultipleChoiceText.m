//
//  SCHStoryInteractionControllerMultipleChoiceText.m
//  Scholastic
//
//  Created by Neil Gall on 02/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "SCHStoryInteractionControllerMultipleChoiceText.h"
#import "SCHStoryInteractionMultipleChoiceText.h"
#import "SCHStoryInteractionControllerDelegate.h"
#import "NSArray+ViewSorting.h"

@interface SCHStoryInteractionControllerMultipleChoiceText ()

@property (nonatomic, assign) NSInteger currentQuestionIndex;
@property (nonatomic, assign) NSInteger simultaneousTapCount;

- (void)setupQuestion;
- (void)playQuestionAudioAndHighlightAnswersWithIntroduction:(BOOL)withIntroduction;

@end

@implementation SCHStoryInteractionControllerMultipleChoiceText

@synthesize answerButtons;
@synthesize currentQuestionIndex;
@synthesize simultaneousTapCount;

- (void)dealloc
{
    [answerButtons release], answerButtons = nil;
    [super dealloc];
}

- (SCHStoryInteractionMultipleChoiceTextQuestion *)currentQuestion
{
    return [[(SCHStoryInteractionMultipleChoiceText *)self.storyInteraction questions] objectAtIndex:currentQuestionIndex];
}

- (BOOL)shouldPlayQuestionAudioForViewAtIndex:(NSInteger)screenIndex
{
    // override default behaviour
    return NO;
}

- (void)setupViewAtIndex:(NSInteger)screenIndex
{
    self.answerButtons = [self.answerButtons viewsSortedVertically];
    
    // get the current question
    if (self.delegate && [self.delegate respondsToSelector:@selector(currentQuestionForStoryInteraction)]) {
        self.currentQuestionIndex += [self.delegate currentQuestionForStoryInteraction];    
    }
    [self setupQuestion];
}

- (void)setupQuestion
{
    BOOL iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);

    self.simultaneousTapCount = 0;
    [self setTitle:[self currentQuestion].prompt];

    for (UIButton *button in self.answerButtons) {
        NSUInteger answerIndex = button.tag - 1;
        if (answerIndex < [[self currentQuestion].answers count]) {
            NSString *answer = [[self currentQuestion].answers objectAtIndex:answerIndex];
            UIImage *highlight = nil;
            if (answerIndex == [self currentQuestion].correctAnswer) {
                highlight = [[UIImage imageNamed:@"answer-button-green"] stretchableImageWithLeftCapWidth:10 topCapHeight:0];
            } else {
                highlight = [[UIImage imageNamed:@"answer-button-red"] stretchableImageWithLeftCapWidth:10 topCapHeight:0];    
            }
            [button setTitle:answer forState:UIControlStateNormal];
            [button setTitleColor:(iPad ? [UIColor whiteColor] : [UIColor SCHBlue2Color]) forState:UIControlStateNormal];
            [button setHidden:NO];
            [button setSelected:NO];
            [button setBackgroundImage:[(iPad == YES ? [UIImage imageNamed:@"answer-button-blue"] : [UIImage imageNamed:@"answer-button-yellow"]) stretchableImageWithLeftCapWidth:10 topCapHeight:0] forState:UIControlStateNormal];        
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
    
    // play intro audio on first question only
    self.controllerState = SCHStoryInteractionControllerStateAskingOpeningQuestion; 
    [self playQuestionAudioAndHighlightAnswersWithIntroduction:(self.currentQuestionIndex == 0)];
}

- (void)playQuestionAudioAndHighlightAnswersWithIntroduction:(BOOL)withIntroduction
{
//    [self cancelQueuedAudioExecutingSynchronizedBlocksImmediately];

    if (withIntroduction) {
        [self enqueueAudioWithPath:[self.storyInteraction audioPathForQuestion] 
                        fromBundle:NO];
    }

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
}

- (void)playAudioButtonTapped:(id)sender
{
    if (![self playingAudio] && self.controllerState != SCHStoryInteractionControllerStateInteractionFinishedSuccessfully) { 
        self.controllerState = SCHStoryInteractionControllerStateAskingOpeningQuestion;
        [self playQuestionAudioAndHighlightAnswersWithIntroduction:NO];
    }
}

- (IBAction)answerButtonTapped:(UIButton *)sender
{
    self.simultaneousTapCount++;
    if (self.simultaneousTapCount == 1) {
        [self performSelector:@selector(answerChosen:) withObject:sender afterDelay:kMinimumDistinguishedAnswerDelay];
    }
}

- (void)answerChosen:(UIButton *)sender
{
    // ignore simultaneous taps on multiple buttons
    NSInteger answersTapped = self.simultaneousTapCount;
    self.simultaneousTapCount = 0;
    if (answersTapped > 1) {
        return;
    }
    
    NSUInteger chosenAnswer = sender.tag - 1;
    if (chosenAnswer >= [[self currentQuestion].answers count]) {
        return;
    }
    
    [sender setSelected:YES];
    if (chosenAnswer == [self currentQuestion].correctAnswer) {
        self.controllerState = SCHStoryInteractionControllerStateInteractionFinishedSuccessfully;
        [self cancelQueuedAudio];
        [self enqueueAudioWithPath:[self.storyInteraction storyInteractionCorrectAnswerSoundFilename] fromBundle:YES];
        [self enqueueAudioWithPath:[[self currentQuestion] audioPathForAnswerAtIndex:chosenAnswer] fromBundle:NO];
        [self enqueueAudioWithPath:[(SCHStoryInteractionMultipleChoiceText *)self.storyInteraction audioPathForThatsRight] fromBundle:NO];
        [self enqueueAudioWithPath:[[self currentQuestion] audioPathForCorrectAnswer]
                        fromBundle:NO
                        startDelay:0
            synchronizedStartBlock:nil
              synchronizedEndBlock:^{
                  [self removeFromHostView];
              }];
    } else {
        self.controllerState = SCHStoryInteractionControllerStateInteractionReadingAnswerWithPause;
        [self cancelQueuedAudio];
        [self enqueueAudioWithPath:[self.storyInteraction storyInteractionWrongAnswerSoundFilename]
                        fromBundle:YES];
        [self enqueueAudioWithPath:[[self currentQuestion] audioPathForAnswerAtIndex:chosenAnswer]
                        fromBundle:NO];
        [self enqueueAudioWithPath:[[self currentQuestion] audioPathForIncorrectAnswer]
                        fromBundle:NO
                        startDelay:0
            synchronizedStartBlock:nil
              synchronizedEndBlock:^{
                  [sender setSelected:NO];
                  self.controllerState = SCHStoryInteractionControllerStateInteractionInProgress;
              }];
    }
}

- (NSString *)audioPathForQuestion
{
    return([[self currentQuestion] audioPathForQuestion]);
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
