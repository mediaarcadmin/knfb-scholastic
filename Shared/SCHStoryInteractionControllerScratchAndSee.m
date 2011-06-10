//
//  SCHStoryInteractionControllerScratchAndSee.m
//  Scholastic
//
//  Created by Gordon Christie on 08/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionControllerScratchAndSee.h"
#import "SCHStoryInteractionScratchAndSee.h"

static const NSInteger kSCHScratchPointCount = 200;

@interface SCHStoryInteractionControllerScratchAndSee ()

@property (nonatomic, retain) NSArray *answerButtons;
@property (nonatomic, assign) NSInteger currentQuestionIndex;
@property (nonatomic, assign) BOOL askingQuestions;

- (SCHStoryInteractionScratchAndSeeQuestion *)currentQuestion;
- (void)nextQuestion;
- (void)setupQuestion;
- (void)correctAnswer:(NSInteger) selection;
- (void)wrongAnswer:(NSInteger) selection;
- (void)setButtonsEnabled: (BOOL) enabled;

- (void)setProgressViewForScratchCount: (NSInteger) scratchCount;

@end


@implementation SCHStoryInteractionControllerScratchAndSee

@synthesize scratchView;
@synthesize pictureView;
@synthesize answerButton1;
@synthesize answerButton2;
@synthesize answerButton3;
@synthesize progressImageView;
@synthesize progressCoverImageView;
@synthesize progressView;
@synthesize currentQuestionIndex;
@synthesize askingQuestions;

@synthesize answerButtons;

- (void)dealloc {
    [answerButton1 release], answerButton1 = nil;
    [answerButton2 release], answerButton2 = nil;
    [answerButton3 release], answerButton3 = nil;
    [pictureView release], pictureView = nil;
    [scratchView release], scratchView = nil;
    [answerButtons release], answerButtons = nil;
    [progressImageView release], progressImageView = nil;
    [progressCoverImageView release], progressCoverImageView = nil;
    [progressView release], progressView = nil;
    [super dealloc];
}

- (void)setupViewAtIndex:(NSInteger)screenIndex
{
    self.answerButtons = [NSArray arrayWithObjects:self.answerButton1, self.answerButton2, self.answerButton3, nil];
    self.askingQuestions = NO;
    self.scratchView.delegate = self;
    
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
    
    self.progressCoverImageView.image = [[UIImage imageNamed:@"progressbar-cover"] stretchableImageWithLeftCapWidth:16 topCapHeight:0];
    
    self.progressImageView.image = [UIImage imageNamed:@"progressbar-fill"];
    
    self.progressView.hidden = NO;

    [self setupQuestion];
    
    [self playBundleAudioWithFilename:[(SCHStoryInteractionScratchAndSee *)self.storyInteraction storyInteractionOpeningSoundFilename]
               completion:^{
                   [self playAudioAtPath:[(SCHStoryInteractionScratchAndSee *)self.storyInteraction introductionAudioPath]
                              completion:^{}];
               }];
    
    
}

- (void)setupQuestion
{
    if (!self.askingQuestions) {
        UIImage *image = [self imageAtPath:[[self currentQuestion] imagePath]];
        self.scratchView.answerImage = image;
        [self setProgressViewForScratchCount:0];
        self.progressView.hidden = NO;
    } else {
        self.progressView.hidden = YES;
    }
    
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
        [button setSelected:NO];
        if (self.askingQuestions) {
            [button setHidden:NO];
        } else {
            [button setHidden:YES];
        }
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
        self.askingQuestions = NO;
        [self setupQuestion];
    }
}

- (SCHStoryInteractionScratchAndSeeQuestion *)currentQuestion
{
    return [[(SCHStoryInteractionScratchAndSee *)self.storyInteraction questions] objectAtIndex:currentQuestionIndex];
}



- (IBAction)questionButtonTapped:(UIButton *)sender
{
    NSInteger selection = [self.answerButtons indexOfObject:sender];
    
    if (selection == [[self currentQuestion] correctAnswer]) {
        [self correctAnswer:selection];
    } else {
        [self wrongAnswer:selection];
    }
}

- (void)correctAnswer:(NSInteger) selection{
    NSLog(@"Correct answer.");
    [self setButtonsEnabled:NO];
    
    for (int i = 0; i < [self.answerButtons count]; i++) {
        if (i == selection) {
            [(UIButton *) [self.answerButtons objectAtIndex:i] setSelected:YES];
        } else {
            [(UIButton *) [self.answerButtons objectAtIndex:i] setSelected:NO];
        }
    }
        
    self.scratchView.showFullImage = YES;
    
    [self playBundleAudioWithFilename:[[self currentQuestion] storyInteractionCorrectAnswerSoundFilename]
                           completion:^{
                               [self playAudioAtPath:[[self currentQuestion] audioPathForAnswerAtIndex:selection]
                                                      completion:^{
                                                          [self playAudioAtPath:[[self currentQuestion] audioPathForThatsRight]
                                                                     completion:^{
                                                                         [self playAudioAtPath:[[self currentQuestion] correctAnswerAudioPath]
                                                                                    completion:^{
                                                                                        [self setButtonsEnabled:YES];
                                                                                        [self nextQuestion];
                                                                                    }];
                                                                     }];
                                                      }];
                           }];
    
}

- (void)wrongAnswer:(NSInteger) selection {
    NSLog(@"Wrong answer.");
    [self setButtonsEnabled:NO];

    [(UIButton *) [self.answerButtons objectAtIndex:selection] setSelected:YES];

    [self playBundleAudioWithFilename:[[self currentQuestion] storyInteractionWrongAnswerSoundFilename]
                           completion:^{
                               [self playAudioAtPath:[[self currentQuestion] audioPathForAnswerAtIndex:selection]
                                          completion:^{
                                              [self playAudioAtPath:[[self currentQuestion] audioPathForIncorrectAnswer]
                                                         completion:^{
                                                             [(UIButton *) [self.answerButtons objectAtIndex:selection] setSelected:NO];
                                                             [self setButtonsEnabled:YES];
                                                         }];
                                          }];
                           }];
}

- (void)setButtonsEnabled: (BOOL) enabled
{
    for (int i = 0; i < [self.answerButtons count]; i++) {
        if (enabled) {
            [(UIButton *) [self.answerButtons objectAtIndex:i] addTarget:self action:@selector(questionButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [(UIButton *) [self.answerButtons objectAtIndex:i] removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
        }
    }
}

- (void)setProgressViewForScratchCount: (NSInteger) scratchCount
{
    float percentage = 1 - (((float)scratchCount / (float)kSCHScratchPointCount));
    
    NSLog(@"Percentage: %f scratchCount: %d", percentage, scratchCount);
    
    CGRect frame = self.progressImageView.frame;
    frame.size.width = (self.progressView.frame.size.width * percentage);
    self.progressImageView.frame = frame;
}


- (void)scratchView:(SCHStoryInteractionScratchView *)aScratchView uncoveredPoints:(NSInteger)points
{
    if (points > kSCHScratchPointCount && !self.askingQuestions) {
        self.askingQuestions = YES;
        self.progressView.hidden = YES;
        aScratchView.interactionEnabled = NO;

        [self playBundleAudioWithFilename:[(SCHStoryInteractionScratchAndSee *)self.storyInteraction scratchingCompleteSoundEffectFilename] 
                               completion:^{
                                   [self playAudioAtPath:[(SCHStoryInteractionScratchAndSee *)self.storyInteraction whatDoYouSeeAudioPath] 
                                              completion:^{
                                                  [self playAudioAtPath:[[self currentQuestion] audioPathForAnswerAtIndex:0] completion: ^{
                                                      [self playAudioAtPath:[[self currentQuestion] audioPathForAnswerAtIndex:1] completion: ^{
                                                          [self playAudioAtPath:[[self currentQuestion] audioPathForAnswerAtIndex:2] completion: ^{
                                                          }];
                                                      }];
                                                  }];
                                              }];
                               }];
        
        [self setupQuestion];
    } else {
        self.askingQuestions = NO;
        aScratchView.interactionEnabled = YES;
        
        [self setProgressViewForScratchCount:points];
        
        if (points % 15 == 0) {
            if (![self playingAudio]) {
                [self playBundleAudioWithFilename:[(SCHStoryInteractionScratchAndSee *)self.storyInteraction scratchSoundEffectFilename] 
                                       completion:^{}];
            }
        }
    }
}


@end
