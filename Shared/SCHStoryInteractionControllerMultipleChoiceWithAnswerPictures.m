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

@interface SCHStoryInteractionControllerMultipleChoiceWithAnswerPictures ()

@property (nonatomic, assign) NSInteger currentQuestionIndex;

- (void)nextQuestion;
- (void)setupQuestion;

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

- (void)setupViewAtIndex:(NSInteger)screenIndex
{
    [self playAudioAtPath:[(SCHStoryInteractionMultipleChoiceWithAnswerPictures *)self.storyInteraction introductionAudioPath]
               completion:^{}];

    self.currentQuestionIndex = 0;
    [self setupQuestion];
}

- (void)nextQuestion
{
    self.currentQuestionIndex++;
    if (self.currentQuestionIndex == [[(SCHStoryInteractionMultipleChoiceWithAnswerPictures *)self.storyInteraction questions] count]) {
        [self removeFromHostView];
    } else {
        [self setupQuestion];
    }
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
            button.normalColor = [UIColor colorWithRed:0.071 green:0.396 blue:0.698 alpha:1.000];
            button.selectedColor = ([self currentQuestion].correctAnswer != answerIndex ? [UIColor colorWithRed:0.973 green:0.004 blue:0.094 alpha:1.000] : [UIColor colorWithRed:0.157 green:0.753 blue:0.341 alpha:1.000]);            
            button.actionBlock = ^(SCHImageButton *imageButton) {
                NSUInteger chosenAnswer = imageButton.tag - 1;
                
                if (chosenAnswer == [self currentQuestion].correctAnswer) {
                    [self playAudioAtPath:[[self currentQuestion] audioPathForCorrectAnswer] completion:^{
                        [self nextQuestion];
                    }];
                } else {
                    [self playAudioAtPath:[[self currentQuestion] audioPathForIncorrectAnswer] completion:nil];
                }
            };
        }
    }
}

- (NSString *)audioPath
{
    return([[self currentQuestion] audioPathForQuestion]);
}

@end
