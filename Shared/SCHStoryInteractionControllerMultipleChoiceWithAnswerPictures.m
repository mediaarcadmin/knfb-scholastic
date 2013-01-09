//
//  SCHStoryInteractionControllerMultipleChoiceWithAnswerPictures.m
//  Scholastic
//
//  Created by John S. Eddie on 09/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionControllerMultipleChoiceWithAnswerPictures.h"

#import "SCHStoryInteractionMultipleChoiceWithAnswerPictures.h"
#import "SCHImageButton.h"
#import "KNFBXPSProvider.h"
#import "SCHStoryInteractionControllerDelegate.h"

@interface SCHStoryInteractionControllerMultipleChoiceWithAnswerPictures ()

@property (nonatomic, assign) NSInteger currentQuestionIndex;
@property (nonatomic, assign) NSInteger simultaneousTapCount;

- (void)setupQuestion;
- (void)playCurrentQuestionAudio;
- (void)setupButtonsForOrientation:(UIInterfaceOrientation)orientation;
- (void)repositionButton:(UIImageView *)button x:(CGFloat)x y:(CGFloat)y;

@end

@implementation SCHStoryInteractionControllerMultipleChoiceWithAnswerPictures

@synthesize answerButtons;
@synthesize currentQuestionIndex;
@synthesize simultaneousTapCount;

- (void)dealloc
{
    [answerButtons release], answerButtons = nil;
    
    [super dealloc];
}

- (SCHStoryInteractionMultipleChoicePictureQuestion *)currentQuestion
{
    NSParameterAssert(currentQuestionIndex < [[(SCHStoryInteractionMultipleChoiceWithAnswerPictures *)self.storyInteraction questions] count]);
    
    return [[(SCHStoryInteractionMultipleChoiceWithAnswerPictures *)self.storyInteraction questions] objectAtIndex:currentQuestionIndex];
}

- (BOOL)shouldPlayQuestionAudioForViewAtIndex:(NSInteger)screenIndex
{
    // override default behaviour
    return NO;
}

- (void)tappedAudioButton:(id)sender withViewAtIndex:(NSInteger)screenIndex
{
    [self cancelQueuedAudioExecutingSynchronizedBlocksBefore:^{
        [self playCurrentQuestionAudio];
    }];
}

- (void)setupViewAtIndex:(NSInteger)screenIndex
{
    // get the current question
    if (self.delegate && [self.delegate respondsToSelector:@selector(currentQuestionForStoryInteraction)]) {
        self.currentQuestionIndex += [self.delegate currentQuestionForStoryInteraction];    
    }
    [self setupQuestion];
}

- (void)setupQuestion
{
    [self setTitle:[self currentQuestion].prompt];
    
    [self setupButtonsForOrientation:self.interfaceOrientation];
    
    self.simultaneousTapCount = 0;
    self.controllerState = SCHStoryInteractionControllerStateAskingOpeningQuestion;
    
    for (SCHImageButton *button in self.answerButtons) {
        NSUInteger answerIndex = button.tag - 1; 
        if (answerIndex < [[(SCHStoryInteractionMultipleChoiceWithAnswerPictures *)self.storyInteraction questions] count]) {            
            NSString *imagePath = [[self currentQuestion] imagePathForAnswerAtIndex:answerIndex];
            NSData *imageData = [self.xpsProvider dataForComponentAtPath:imagePath];
            button.image = [UIImage imageWithData:imageData];
            button.selected = NO;
            button.normalColor = [UIColor SCHBlue2Color];
            button.selectedColor = ([self currentQuestion].correctAnswer != answerIndex ?  [UIColor SCHScholasticRedColor] : [UIColor SCHGreen1Color]);                        
            button.actionBlock = ^(SCHImageButton *imageButton) {
                self.simultaneousTapCount++;
                if (self.simultaneousTapCount == 1) {
                    [self performSelector:@selector(answerChosen:) withObject:imageButton afterDelay:kMinimumDistinguishedAnswerDelay];
                }
            };
        }
    }
    
    [self playCurrentQuestionAudio];
}

- (void)playCurrentQuestionAudio
{
    self.controllerState = SCHStoryInteractionControllerStateAskingOpeningQuestion;
    
    // play intro audio on first question only
    NSTimeInterval startDelay = 0;
    if ([self.delegate currentQuestionForStoryInteraction] == 0 && ![self.delegate storyInteractionFinished]) {
        [self enqueueAudioWithPath:[self.storyInteraction audioPathForQuestion] fromBundle:NO];
        startDelay = 0.5;
    }
    [self enqueueAudioWithPath:[[self currentQuestion] audioPathForQuestion]
                    fromBundle:NO
                    startDelay:startDelay
        synchronizedStartBlock:nil
          synchronizedEndBlock:^{
              self.controllerState = SCHStoryInteractionControllerStateInteractionInProgress;
          }];
}

- (void)answerChosen:(SCHImageButton *)imageButton
{
    // ignore multiple simultaneous taps
    NSInteger tapCount = self.simultaneousTapCount;
    self.simultaneousTapCount = 0;
    if (tapCount > 1) {
        return;
    }
    
    imageButton.selected = YES;
    NSUInteger chosenAnswer = imageButton.tag - 1;
    
    [self cancelQueuedAudioExecutingSynchronizedBlocksBefore:^{
        if (chosenAnswer == [self currentQuestion].correctAnswer) {
            self.controllerState = SCHStoryInteractionControllerStateInteractionFinishedSuccessfully;
            [self enqueueAudioWithPath:[self.storyInteraction storyInteractionCorrectAnswerSoundFilename] fromBundle:YES];
            [self enqueueAudioWithPath:[self.storyInteraction audioPathForThatsRight] fromBundle:NO];
            [self enqueueAudioWithPath:[[self currentQuestion] audioPathForCorrectAnswer]
                            fromBundle:NO
                            startDelay:0.5
                synchronizedStartBlock:nil
                  synchronizedEndBlock:^{
                      [self removeFromHostView];
                  }];
        } else {
            self.controllerState = SCHStoryInteractionControllerStateInteractionReadingAnswerWithPause;
            
            [self enqueueAudioWithPath:[self.storyInteraction storyInteractionWrongAnswerSoundFilename]
                            fromBundle:YES];
            [self enqueueAudioWithPath:[[self currentQuestion] audioPathForIncorrectAnswer] fromBundle:NO 
                            startDelay:0.0
                synchronizedStartBlock:nil
                  synchronizedEndBlock:^{
                      self.controllerState = SCHStoryInteractionControllerStateInteractionInProgress;
                  }];
        }
    }];
}

- (void)rotateToOrientation:(UIInterfaceOrientation)orientation
{
    [super rotateToOrientation:orientation];
    [self setupButtonsForOrientation:orientation];
}

- (void)setupButtonsForOrientation:(UIInterfaceOrientation)orientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (UIInterfaceOrientationIsLandscape(orientation)) {
            [self repositionButton:[self.answerButtons objectAtIndex:0] x:17 y:45];
            [self repositionButton:[self.answerButtons objectAtIndex:1] x:170 y:45];
            [self repositionButton:[self.answerButtons objectAtIndex:2] x:323 y:45];
        } else {
            [self repositionButton:[self.answerButtons objectAtIndex:0] x:17 y:38];
            [self repositionButton:[self.answerButtons objectAtIndex:1] x:163 y:38];
            [self repositionButton:[self.answerButtons objectAtIndex:2] x:85 y:214];
        }
    }
}

- (void)repositionButton:(UIImageView *)button x:(CGFloat)x y:(CGFloat)y
{
    if (button != nil) {
        CGSize buttonSize = button.frame.size;
        button.frame = CGRectMake(x, y, buttonSize.width, buttonSize.height);
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
