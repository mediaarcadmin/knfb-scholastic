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
@property (nonatomic, assign) BOOL answered;

- (void)nextQuestion;
- (void)setupQuestion;
- (void)playCurrentQuestionAudio;

@end

@implementation SCHStoryInteractionControllerMultipleChoiceWithAnswerPictures

@synthesize answerButtons;
@synthesize currentQuestionIndex;
@synthesize answered;

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
    if (!self.answered) {
        [self cancelQueuedAudio];
        [self playCurrentQuestionAudio];
    }
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
    self.answered = NO;
    [self setTitle:[self currentQuestion].prompt];
    
    for (SCHImageButton *button in self.answerButtons) {
        NSUInteger answerIndex = button.tag - 1; 
        if (answerIndex < [[(SCHStoryInteractionMultipleChoiceWithAnswerPictures *)self.storyInteraction questions] count]) {            
            NSString *imagePath = [[self currentQuestion] imagePathForAnswerAtIndex:answerIndex];
            NSData *imageData = [self.xpsProvider dataForComponentAtPath:imagePath];
            button.image = [UIImage imageWithData:imageData];
            button.selected = NO;
            button.normalColor = [UIColor colorWithRed:0.071 green:0.396 blue:0.698 alpha:1.000];
            button.selectedColor = ([self currentQuestion].correctAnswer != answerIndex ? [UIColor colorWithRed:0.973 green:0.004 blue:0.094 alpha:1.000] : [UIColor colorWithRed:0.157 green:0.753 blue:0.341 alpha:1.000]);            
            button.actionBlock = ^(SCHImageButton *imageButton) {
                self.answered = YES;
                NSUInteger chosenAnswer = imageButton.tag - 1;

                [self cancelQueuedAudio];
                if (chosenAnswer == [self currentQuestion].correctAnswer) {
                    [self enqueueAudioWithPath:[self.storyInteraction audioPathForThatsRight] fromBundle:NO];
                    [self enqueueAudioWithPath:[[self currentQuestion] audioPathForCorrectAnswer]
                                    fromBundle:NO
                                    startDelay:0.5
                        synchronizedStartBlock:nil
                          synchronizedEndBlock:^{
                              [self nextQuestion];
                          }];
                } else {
                    [self enqueueAudioWithPath:[[self currentQuestion] audioPathForIncorrectAnswer] fromBundle:NO];
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
