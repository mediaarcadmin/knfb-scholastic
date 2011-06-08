//
//  SCHStoryInteractionControllerScratchAndSee.m
//  Scholastic
//
//  Created by Gordon Christie on 08/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionControllerScratchAndSee.h"
#import "SCHStoryInteractionScratchAndSee.h"

@interface SCHStoryInteractionControllerScratchAndSee ()

@property (nonatomic, retain) NSArray *answerButtons;
@property (nonatomic, assign) NSInteger currentQuestionIndex;

- (SCHStoryInteractionScratchAndSeeQuestion *)currentQuestion;
- (void)nextQuestion;
- (void)setupQuestion;

@end


@implementation SCHStoryInteractionControllerScratchAndSee

@synthesize scratchView;
@synthesize pictureView;
@synthesize answerButton1;
@synthesize answerButton2;
@synthesize answerButton3;
@synthesize currentQuestionIndex;

@synthesize answerButtons;

- (void)dealloc {
    [answerButton1 release], answerButton1 = nil;
    [answerButton2 release], answerButton2 = nil;
    [answerButton3 release], answerButton3 = nil;
    [pictureView release], pictureView = nil;
    [scratchView release], scratchView = nil;
    [answerButtons release], answerButtons = nil;
    [super dealloc];
}

- (void)setupView
{
    self.answerButtons = [NSArray arrayWithObjects:self.answerButton1, self.answerButton2, self.answerButton3, nil];
    
    for (UIButton *button in answerButtons) {
        button.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
        button.titleLabel.textAlignment = UITextAlignmentCenter;
    }
    
    NSInteger i = 0;
    for (NSString *answer in [self currentQuestion].answers) {
        UIButton *button = [self.answerButtons objectAtIndex:i];
        [button setTitle:answer forState:UIControlStateNormal];
        [button setHidden:YES];
        ++i;
    }

    [self setupQuestion];
}

- (void)setupQuestion
{
    UIImage *image = [self imageAtPath:[[self currentQuestion] imagePath]];
    self.pictureView.image = image;
    
    NSLog(@"Image: %@", [self.currentQuestion imagePath]);
    
    NSInteger i = 0;
    for (NSString *answer in [self currentQuestion].answers) {
        UIImage *highlight;
        if (i == [self currentQuestion].correctAnswer) {
            highlight = [UIImage imageNamed:@"answer-button-green"];
        } else {
            highlight = [UIImage imageNamed:@"answer-button-red"];
        }
        UIButton *button = [self.answerButtons objectAtIndex:i];
        [button setTitle:answer forState:UIControlStateNormal];
        [button setHidden:YES];
        [button setBackgroundImage:highlight forState:UIControlStateSelected];
        ++i;
    }
    for (; i < [self.answerButtons count]; ++i) {
        [[self.answerButtons objectAtIndex:i] setHidden:YES];
    }

}

- (void)nextQuestion
{
    self.currentQuestionIndex++;
    if (self.currentQuestionIndex == [[(SCHStoryInteractionScratchAndSee *)self.storyInteraction questions] count]) {
        [self removeFromHostView];
    } else {
        [self setupQuestion];
    }
}

- (SCHStoryInteractionScratchAndSeeQuestion *)currentQuestion
{
    return [[(SCHStoryInteractionScratchAndSee *)self.storyInteraction questions] objectAtIndex:currentQuestionIndex];
}



- (IBAction)questionButtonTapped:(id)sender
{
    NSLog(@"Selected button");
}




@end
