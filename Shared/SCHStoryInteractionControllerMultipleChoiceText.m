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

#define debug_layout 0

@interface SCHStoryInteractionControllerMultipleChoiceText ()

@property (nonatomic, assign) NSInteger currentQuestionIndex;
@property (nonatomic, assign) NSInteger simultaneousTapCount;

- (void)setupQuestion;
- (void)playQuestionAudioAndHighlightAnswersWithIntroduction:(BOOL)withIntroduction;
- (void)adjustButtonsFont;

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
    NSParameterAssert(self.currentQuestionIndex < [[(SCHStoryInteractionMultipleChoiceText *)self.storyInteraction questions] count]);
    
    return [[(SCHStoryInteractionMultipleChoiceText *)self.storyInteraction questions] objectAtIndex:currentQuestionIndex];
}

- (NSString *)currentQuestionAnswerOptionAtIndex:(NSInteger)index
{
    NSParameterAssert(index < [[self currentQuestion].answers count]);
    
#if debug_layout
    // use various lengths of strings to force the text layout code to do some work
    switch (index) {
        case 0: return @"Space is big. Really big. You just won't believe how vastly, hugely, mind-bogglingly big it is. I mean, you may think it's a long way down the street to the chemist, but that's just peanuts to space.";
        case 1: return @"The Babel Fish is small, yellow, leech-like and probably the oddest thing in the universe.";
        case 2: return @"Forty two";
        default: return @"Don't panic";
    }
#else
    return [[self currentQuestion].answers objectAtIndex:index];    
#endif
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
            NSString *answer = [self currentQuestionAnswerOptionAtIndex:answerIndex];
            UIImage *highlight = nil;
            if (answerIndex == [self currentQuestion].correctAnswer) {
                highlight = [[UIImage imageNamed:@"answer-button-green"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
            } else {
                highlight = [[UIImage imageNamed:@"answer-button-red"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];    
            }
            [button.titleLabel setNumberOfLines:0];
            [button.titleLabel setTextAlignment:UITextAlignmentCenter];
            [button setTitle:answer forState:UIControlStateNormal];
            [button setTitleColor:(iPad ? [UIColor whiteColor] : [UIColor SCHBlue2Color]) forState:UIControlStateNormal];
            [button setHidden:NO];
            [button setSelected:NO];
            [button setBackgroundImage:[(iPad == YES ? [UIImage imageNamed:@"answer-button-blue"] : [UIImage imageNamed:@"answer-button-yellow"]) stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateNormal];        
            [button setBackgroundImage:highlight forState:UIControlStateSelected];
            [button setImage:[UIImage imageNamed:@"answer-blank"] forState:UIControlStateNormal];
            if (answerIndex == [self currentQuestion].correctAnswer) {
                [button setImage:[UIImage imageNamed:@"answer-tick"] forState:UIControlStateSelected];
            } else {
                [button setImage:[UIImage imageNamed:@"answer-cross"] forState:UIControlStateSelected];
            }
        }
    }
    
    [self adjustButtonsFont];
    
    // play intro audio on first question only
    self.controllerState = SCHStoryInteractionControllerStateAskingOpeningQuestion; 
    [self playQuestionAudioAndHighlightAnswersWithIntroduction:(self.currentQuestionIndex == 0)];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    UIEdgeInsets imageInsets = UIEdgeInsetsMake(0, CGRectGetWidth([[self.answerButtons objectAtIndex:0] bounds])-40, 0, 0);
    for (UIButton *button in self.answerButtons) {
        [button setImageEdgeInsets:imageInsets];
    }
    [self adjustButtonsFont];
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)adjustButtonsFont
{
    NSString *fontName = [[[[self.answerButtons objectAtIndex:0] titleLabel] font] fontName];
    CGFloat fontSize = 16;
    BOOL tooBig;
    do {
        tooBig = NO;
        for (UIButton *button in self.answerButtons) {
            CGSize maximumSize = UIEdgeInsetsInsetRect(button.bounds, button.titleEdgeInsets).size;
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

- (void)playQuestionAudioAndHighlightAnswersWithIntroduction:(BOOL)withIntroduction
{
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

- (IBAction)answerButtonTouched:(UIButton *)sender
{
    self.controllerState = SCHStoryInteractionControllerStateInteractionReadingAnswerWithPause;    
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

    [self cancelQueuedAudioExecutingSynchronizedBlocksBefore:^{
        NSUInteger chosenAnswer = sender.tag - 1;
        if (chosenAnswer >= [[self currentQuestion].answers count]) {
            return;
        }
        
        [sender setSelected:YES];
        self.controllerState = SCHStoryInteractionControllerStateInteractionReadingAnswerWithPause;
        
        if (chosenAnswer == [self currentQuestion].correctAnswer) {
            self.controllerState = SCHStoryInteractionControllerStateInteractionFinishedSuccessfully;
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
    }];
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
