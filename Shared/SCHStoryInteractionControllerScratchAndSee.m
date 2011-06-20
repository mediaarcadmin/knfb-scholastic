//
//  SCHStoryInteractionControllerScratchAndSee.m
//  Scholastic
//
//  Created by Gordon Christie on 08/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionControllerScratchAndSee.h"
#import "SCHStoryInteractionScratchAndSee.h"
#import "SCHBookStoryInteractions.h"
#import "SCHStoryInteractionControllerDelegate.h"

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

- (void)setProgressViewForScratchCount: (NSInteger) scratchCount;

@end


@implementation SCHStoryInteractionControllerScratchAndSee

@synthesize scratchView;
@synthesize answerButton1;
@synthesize answerButton2;
@synthesize answerButton3;
@synthesize progressImageView;
@synthesize progressCoverImageView;
@synthesize progressView;
@synthesize aLabel;
@synthesize bLabel;
@synthesize cLabel;
@synthesize currentQuestionIndex;
@synthesize askingQuestions;

@synthesize answerButtons;

- (void)dealloc {
    [answerButton1 release], answerButton1 = nil;
    [answerButton2 release], answerButton2 = nil;
    [answerButton3 release], answerButton3 = nil;
    [scratchView release], scratchView = nil;
    [answerButtons release], answerButtons = nil;
    [progressImageView release], progressImageView = nil;
    [progressCoverImageView release], progressCoverImageView = nil;
    [progressView release], progressView = nil;
    [aLabel release], aLabel = nil;
    [bLabel release], bLabel = nil;
    [cLabel release], cLabel = nil;
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

    // get the current question
    if (self.delegate && [self.delegate respondsToSelector:@selector(currentQuestionForStoryInteraction)]) {
        self.currentQuestionIndex += [self.delegate currentQuestionForStoryInteraction];    
    }
    
    [self setupQuestion];
}

- (BOOL)shouldPlayQuestionAudioForViewAtIndex:(NSInteger)screenIndex
{
    BOOL completed = [self.storyInteraction.bookStoryInteractions storyInteractionsFinishedOnPage:self.storyInteraction.documentPageNumber];
    return !completed && self.currentQuestionIndex == 0;
}

- (void)setupQuestion
{
    BOOL iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    

    if (!self.askingQuestions) {
//        [self setTitle:[self currentQuestion].prompt];
        [self setTitle:NSLocalizedString(@"Scratch away the question mark to see the picture.", @"")];
        UIImage *image = [self imageAtPath:[[self currentQuestion] imagePath]];
        self.scratchView.answerImage = image;
        [self setProgressViewForScratchCount:0];
        self.progressView.hidden = NO;
        aLabel.hidden = YES;
        bLabel.hidden = YES;
        cLabel.hidden = YES;
    } else {
        [self setTitle:NSLocalizedString(@"What do you see?", @"")];
        self.progressView.hidden = YES;
        aLabel.hidden = NO;
        bLabel.hidden = NO;
        cLabel.hidden = NO;
    }
    
    NSLog(@"Image: %@", [self.currentQuestion imagePath]);
    
    NSInteger i = 0;
    for (NSString *answer in [self currentQuestion].answers) {
        UIImage *highlight;
        UIButton *button = [self.answerButtons objectAtIndex:i];

        if (iPad == YES) {
            [button setImage:[UIImage imageNamed:@"answer-blank"] forState:UIControlStateNormal];
            if (i == [self currentQuestion].correctAnswer) {
                [button setImage:[UIImage imageNamed:@"answer-tick"] forState:UIControlStateSelected];
            } else {
                [button setImage:[UIImage imageNamed:@"answer-cross"] forState:UIControlStateSelected];
            }
        }
        
        if (i == [self currentQuestion].correctAnswer) {
            highlight = [[UIImage imageNamed:@"answer-button-green"] stretchableImageWithLeftCapWidth:5 topCapHeight:0];
        } else {
            highlight = [[UIImage imageNamed:@"answer-button-red"] stretchableImageWithLeftCapWidth:5 topCapHeight:0];
        }
        
        [button setTitle:answer forState:UIControlStateNormal];
        [button setTitleColor:(iPad ? [UIColor whiteColor] : [UIColor colorWithRed:0.113 green:0.392 blue:0.690 alpha:1.0]) forState:UIControlStateNormal];
        [button setBackgroundImage:[(iPad == YES ? [UIImage imageNamed:@"answer-button-blue"] : [UIImage imageNamed:@"answer-button-yellow"]) stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateNormal];        
        [button setBackgroundImage:[(iPad == YES ? [UIImage imageNamed:@"answer-button-blue"] : [UIImage imageNamed:@"answer-button-yellow"]) stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateSelected];        
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
    [self removeFromHostViewWithSuccess:YES];
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
    [self setUserInteractionsEnabled:NO];
    
    for (int i = 0; i < [self.answerButtons count]; i++) {
        if (i == selection) {
            [(UIButton *) [self.answerButtons objectAtIndex:i] setSelected:YES];
        } else {
            [(UIButton *) [self.answerButtons objectAtIndex:i] setSelected:NO];
        }
    }
        
    [self.scratchView setShowFullImage:YES];
    
    [self playBundleAudioWithFilename:[self.storyInteraction storyInteractionCorrectAnswerSoundFilename]
                           completion:^{
                               [self playAudioAtPath:[[self currentQuestion] audioPathForAnswerAtIndex:selection]
                                          completion:^{
                                              [self playAudioAtPath:[self.storyInteraction audioPathForThatsRight]
                                                         completion:^{
                                                             [self playAudioAtPath:[[self currentQuestion] correctAnswerAudioPath]
                                                                        completion:^{
                                                                            [self setUserInteractionsEnabled:YES];
                                                                            [self nextQuestion];
                                                                        }];
                                                         }];
                                          }];
                           }];
    
}

- (void)wrongAnswer:(NSInteger) selection {
    NSLog(@"Wrong answer.");
    [self setUserInteractionsEnabled:NO];

    [(UIButton *) [self.answerButtons objectAtIndex:selection] setSelected:YES];
    
    [self playBundleAudioWithFilename:[self.storyInteraction storyInteractionWrongAnswerSoundFilename]
                           completion:^{
                               [self playAudioAtPath:[[self currentQuestion] audioPathForAnswerAtIndex:selection]
                                          completion:^{
                                              [self playAudioAtPath:[[self currentQuestion] audioPathForIncorrectAnswer]
                                                         completion:^{
                                                             [(UIButton *) [self.answerButtons objectAtIndex:selection] setSelected:NO];
                                                             [self setUserInteractionsEnabled:YES];
                                                         }];
                                          }];
                           }];
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

        [self setupQuestion];
        [self enqueueAudioWithPath:[(SCHStoryInteractionScratchAndSee *)self.storyInteraction scratchingCompleteSoundEffectFilename] 
                        fromBundle:YES
                        startDelay:0
            synchronizedStartBlock:^{
                [self setUserInteractionsEnabled:NO];
            }
              synchronizedEndBlock:nil];
        [self enqueueAudioWithPath:[(SCHStoryInteractionScratchAndSee *)self.storyInteraction whatDoYouSeeAudioPath]
                        fromBundle:NO
                        startDelay:0
            synchronizedStartBlock:nil
              synchronizedEndBlock:nil];
        
        for (NSInteger i = 0; i < 3; ++i) {
            UIButton *button = [self.answerButtons objectAtIndex:i];
            [self enqueueAudioWithPath:[[self currentQuestion] audioPathForAnswerAtIndex:i]
                            fromBundle:NO
                            startDelay:0.5
                synchronizedStartBlock:^{
                    [button setHighlighted:YES];
                }
                  synchronizedEndBlock:^{
                      [button setHighlighted:NO];
                      
                      if (i == 2) {
                          [self setUserInteractionsEnabled:YES];
                      }
                      
                  }];
        }
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
