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

- (void)nextQuestion;
- (void)setupQuestion;
- (void)playCurrentQuestionAudio;

@end

@implementation SCHStoryInteractionControllerMultipleChoiceWithAnswerPictures

@synthesize answerButtons;
@synthesize currentQuestionIndex;

- (void)dealloc
{
    [answerButtons release], answerButtons = nil;
    
    [super dealloc];
}

- (SCHStoryInteractionMultipleChoicePictureQuestion *)currentQuestion
{
    return [[(SCHStoryInteractionMultipleChoiceWithAnswerPictures *)self.storyInteraction questions] objectAtIndex:currentQuestionIndex];
}

- (BOOL)shouldPlayQuestionAudioForViewAtIndex:(NSInteger)screenIndex
{
    // override default behaviour
    return NO;
}

- (IBAction)playAudioButtonTapped:(id)sender
{
    [self cancelQueuedAudioExecutingSynchronizedBlocksImmediately];
    [self playCurrentQuestionAudio];
}

- (void)setupViewAtIndex:(NSInteger)screenIndex
{
    // get the current question
    if (self.delegate && [self.delegate respondsToSelector:@selector(currentQuestionForStoryInteraction)]) {
        self.currentQuestionIndex += [self.delegate currentQuestionForStoryInteraction];    
    }
    [self setupQuestion];
}

- (void)nextQuestion
{
    [self removeFromHostViewWithSuccess:YES];
}

- (void)setupQuestion
{
    [self setTitle:[self currentQuestion].prompt];
    
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
                NSUInteger chosenAnswer = imageButton.tag - 1;

                [self cancelQueuedAudioExecutingSynchronizedBlocksImmediately];
                if (chosenAnswer == [self currentQuestion].correctAnswer) {
                    [self setUserInteractionsEnabled:NO];
                    [self enqueueAudioWithPath:[self.storyInteraction audioPathForThatsRight] fromBundle:NO];
                    [self enqueueAudioWithPath:[[self currentQuestion] audioPathForCorrectAnswer]
                                    fromBundle:NO
                                    startDelay:0.5
                        synchronizedStartBlock:nil
                          synchronizedEndBlock:^{
                              [self setUserInteractionsEnabled:YES];
                              [self nextQuestion];
                          }];
                } else {
                    [self enqueueAudioWithPath:[[self currentQuestion] audioPathForIncorrectAnswer] fromBundle:NO 
                                    startDelay:0.0
                        synchronizedStartBlock:^{
                            [self setUserInteractionsEnabled:NO];
                        }
                          synchronizedEndBlock:^{
                              [self setUserInteractionsEnabled:YES];
                          }];
                }
            };
        }
    }
    
    [self playCurrentQuestionAudio];
}

- (void)playCurrentQuestionAudio
{
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
          synchronizedEndBlock:nil];
}


@end
