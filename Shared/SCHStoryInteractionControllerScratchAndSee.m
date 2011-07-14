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

static const NSInteger kFirstScratchPointTarget = 180;
static const NSInteger kSecondScratchPointTarget = 270;

enum ScratchState {
    kScratchStateFirstScratch,
    kScratchStateFirstQuestionAttempt,
    kScratchStateSecondScratch,
    kScratchStateSecondQuestionAttempt,
    kScratchStateKeepTrying
};

@interface SCHStoryInteractionControllerScratchAndSee ()

@property (nonatomic, retain) NSArray *answerButtons;
@property (nonatomic, assign) NSInteger currentQuestionIndex;
@property (nonatomic, assign) NSInteger simultaneousTapCount;
@property (nonatomic, assign) enum ScratchState scratchState;

- (SCHStoryInteractionScratchAndSeeQuestion *)currentQuestion;
- (NSInteger)scratchPointTarget;

- (void)nextQuestion;
- (void)setupQuestion;
- (void)correctAnswer:(NSInteger) selection;
- (void)wrongAnswer:(NSInteger) selection;

- (void)setProgressViewForScratchCount: (NSInteger) scratchCount;
- (void)askQuestion;

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
@synthesize simultaneousTapCount;
@synthesize scratchState;

@synthesize answerButtons;

- (void)dealloc
{
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
    
    self.scratchState = kScratchStateFirstScratch;
    [self setupQuestion];
}

- (BOOL)shouldPlayQuestionAudioForViewAtIndex:(NSInteger)screenIndex
{
    BOOL completed = [self.storyInteraction.bookStoryInteractions storyInteractionsFinishedOnPage:self.storyInteraction.documentPageNumber];
    return !completed && self.currentQuestionIndex == 0;
}

- (void)playAudioButtonTapped:(id)sender
{
    switch (self.scratchState) {
        case kScratchStateFirstQuestionAttempt:
        case kScratchStateSecondQuestionAttempt:
            [self cancelQueuedAudioExecutingSynchronizedBlocksImmediately];
            [self askQuestion];
            break;
        default:
            [super playAudioButtonTapped:sender];
            break;
    }
}

- (void)setupQuestion
{
    const BOOL iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    const BOOL scratching = (self.scratchState == kScratchStateFirstScratch || self.scratchState == kScratchStateSecondScratch);
    
    if (scratching) {
        [self setTitle:NSLocalizedString(@"Scratch away the question mark to see the picture.", @"")];
        if (self.scratchState == kScratchStateFirstScratch) {
            UIImage *image = [self imageAtPath:[[self currentQuestion] imagePath]];
            self.scratchView.answerImage = image;
            [self setProgressViewForScratchCount:0];
        } else {
            [self setProgressViewForScratchCount:kFirstScratchPointTarget];
        }
        self.scratchView.interactionEnabled = YES;
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
            highlight = [[UIImage imageNamed:@"answer-button-green"] stretchableImageWithLeftCapWidth:10 topCapHeight:0];
        } else {
            highlight = [[UIImage imageNamed:@"answer-button-red"] stretchableImageWithLeftCapWidth:10 topCapHeight:0];
        }
        
        [button setTitle:answer forState:UIControlStateNormal];
        [button setTitleColor:(iPad ? [UIColor whiteColor] : [UIColor SCHBlue2Color]) forState:UIControlStateNormal];
        [button setBackgroundImage:[(iPad == YES ? [UIImage imageNamed:@"answer-button-blue"] : [UIImage imageNamed:@"answer-button-yellow"]) stretchableImageWithLeftCapWidth:10 topCapHeight:0] forState:UIControlStateNormal];        
        [button setBackgroundImage:[(iPad == YES ? [UIImage imageNamed:@"answer-button-blue"] : [UIImage imageNamed:@"answer-button-yellow"]) stretchableImageWithLeftCapWidth:10 topCapHeight:0] forState:UIControlStateSelected];        
        [button setSelected:NO];
        [button setHidden:scratching];
        [button setBackgroundImage:highlight forState:UIControlStateSelected];
        ++i;
    }
    for (; i < [self.answerButtons count]; ++i) {
        [[self.answerButtons objectAtIndex:i] setHidden:YES];
    }

    self.simultaneousTapCount = 0;
}

- (void)askQuestion
{
    self.controllerState = SCHStoryInteractionControllerStateAskingOpeningQuestion;
    [self enqueueAudioWithPath:[(SCHStoryInteractionScratchAndSee *)self.storyInteraction whatDoYouSeeAudioPath] fromBundle:NO];
    
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
                      self.controllerState = SCHStoryInteractionControllerStateInteractionInProgress;
                  }
              }];
    }
}

- (NSInteger)scratchPointTarget
{
    switch (self.scratchState) {
        case kScratchStateFirstScratch:
            return kFirstScratchPointTarget;
        case kScratchStateSecondScratch:
            return kSecondScratchPointTarget;
        default: return 0;
    }
}

- (void)nextQuestion
{
    [self removeFromHostView];
}

- (SCHStoryInteractionScratchAndSeeQuestion *)currentQuestion
{
    return [[(SCHStoryInteractionScratchAndSee *)self.storyInteraction questions] objectAtIndex:currentQuestionIndex];
}

- (IBAction)questionButtonTapped:(UIButton *)sender
{
    self.simultaneousTapCount++;
    if (self.simultaneousTapCount == 1) {
        [self performSelector:@selector(answerChosen:) withObject:sender afterDelay:kMinimumDistinguishedAnswerDelay];
    }
}

- (void)answerChosen:(UIButton *)sender
{
    NSInteger tapCount = self.simultaneousTapCount;
    self.simultaneousTapCount = 0;
    if (tapCount > 1) {
        return;
    }

    NSInteger selection = [self.answerButtons indexOfObject:sender];
    
    if (selection == [[self currentQuestion] correctAnswer]) {
        [self correctAnswer:selection];
    } else {
        [self wrongAnswer:selection];
    }
}

- (void)correctAnswer:(NSInteger) selection
{
    self.controllerState = SCHStoryInteractionControllerStateInteractionReadingAnswerWithPause;
    
    for (int i = 0; i < [self.answerButtons count]; i++) {
        if (i == selection) {
            [(UIButton *) [self.answerButtons objectAtIndex:i] setSelected:YES];
        } else {
            [(UIButton *) [self.answerButtons objectAtIndex:i] setSelected:NO];
        }
    }
        
    [self.scratchView setShowFullImage:YES];
    
    [self cancelQueuedAudioExecutingSynchronizedBlocksImmediately];
    [self enqueueAudioWithPath:[self.storyInteraction storyInteractionCorrectAnswerSoundFilename] 
                    fromBundle:YES 
                    startDelay:0 
        synchronizedStartBlock:^{
            self.controllerState = SCHStoryInteractionControllerStateInteractionFinishedSuccessfully;
        }
          synchronizedEndBlock:nil];
    
    [self enqueueAudioWithPath:[[self currentQuestion] audioPathForAnswerAtIndex:selection] fromBundle:NO];
    [self enqueueAudioWithPath:[[self currentQuestion] correctAnswerAudioPath]
                    fromBundle:NO
                    startDelay:0
        synchronizedStartBlock:nil
          synchronizedEndBlock:^{
              [self nextQuestion];
          }];
}

- (void)wrongAnswer:(NSInteger) selection
{
    SCHStoryInteractionScratchAndSee *scratchAndSee = (SCHStoryInteractionScratchAndSee *)self.storyInteraction;
    
    UIButton *button = (UIButton *) [self.answerButtons objectAtIndex:selection];
    [button setSelected:YES];
    
    [self cancelQueuedAudioExecutingSynchronizedBlocksImmediately];
    [self enqueueAudioWithPath:[scratchAndSee storyInteractionWrongAnswerSoundFilename] 
                    fromBundle:YES 
                    startDelay:0 
        synchronizedStartBlock:^{
            self.controllerState = SCHStoryInteractionControllerStateInteractionReadingAnswerWithPause;
        }
          synchronizedEndBlock:nil
     ];
    [self enqueueAudioWithPath:[[self currentQuestion] audioPathForAnswerAtIndex:selection] fromBundle:NO];
    
    switch (self.scratchState) {
        case kScratchStateFirstQuestionAttempt: {
            [self enqueueAudioWithPath:[scratchAndSee thatsNotItAudioPath] fromBundle:NO];
            [self enqueueAudioWithPath:[scratchAndSee keepScratchingAudioPath]
                            fromBundle:NO
                            startDelay:0
                synchronizedStartBlock:nil
                  synchronizedEndBlock:^{
                      [button setSelected:NO];
                      self.scratchState = kScratchStateSecondScratch;
                      self.controllerState = SCHStoryInteractionControllerStateInteractionInProgress;
                      [self setupQuestion];
                  }];
            break;
        }
        case kScratchStateSecondQuestionAttempt:
        case kScratchStateKeepTrying: {
            [self enqueueAudioWithPath:[scratchAndSee audioPathForTryAgain]
                            fromBundle:NO
                            startDelay:0
                synchronizedStartBlock:nil
                  synchronizedEndBlock:^{
                      [button setSelected:NO];
                      self.scratchState = kScratchStateKeepTrying;
                      self.controllerState = SCHStoryInteractionControllerStateInteractionInProgress;
                      [self setupQuestion];
                  }];
            break;
        }
        default:
            break;
    }
}

- (void)setProgressViewForScratchCount: (NSInteger) scratchCount
{
    float progress = 0;
    switch (self.scratchState) {
        case kScratchStateFirstScratch:
            progress = (float)scratchCount / kFirstScratchPointTarget;
            break;
        case kScratchStateSecondScratch:
            progress = 0.5f + (float)(scratchCount - kFirstScratchPointTarget) / (2*(kSecondScratchPointTarget - kFirstScratchPointTarget));
            break;
        default:
            break;
    }
    
    CGRect frame = self.progressImageView.frame;
    frame.size.width = (self.progressView.frame.size.width * (1.0f - progress));
    self.progressImageView.frame = frame;
}


- (void)scratchView:(SCHStoryInteractionScratchView *)aScratchView uncoveredPoints:(NSInteger)points
{
    if ((self.scratchState == kScratchStateFirstScratch || self.scratchState == kScratchStateSecondScratch) && points > [self scratchPointTarget]) {
        if (self.scratchState == kScratchStateFirstScratch) {
            self.scratchState = kScratchStateFirstQuestionAttempt;
        } else if (self.scratchState == kScratchStateSecondScratch) {
            self.scratchState = kScratchStateSecondQuestionAttempt;
        }
        
        self.progressView.hidden = YES;
        [self setupQuestion];

        aScratchView.interactionEnabled = NO;

        [self cancelQueuedAudioExecutingSynchronizedBlocksImmediately];
        [self enqueueAudioWithPath:[(SCHStoryInteractionScratchAndSee *)self.storyInteraction scratchingCompleteSoundEffectFilename]
                        fromBundle:YES
                        startDelay:0
            synchronizedStartBlock:^{
                self.controllerState = SCHStoryInteractionControllerStateInteractionReadingAnswerWithPause;
            }
              synchronizedEndBlock:^{
                  [self askQuestion];
              }];
    } else {
        [self setProgressViewForScratchCount:points];
        
        if (points % 15 == 0) {
            if (![self playingAudio]) {
                [self enqueueAudioWithPath:[(SCHStoryInteractionScratchAndSee *)self.storyInteraction scratchSoundEffectFilename] fromBundle:YES];
            }
        }
    }
}

#pragma mark - Override for SCHStoryInteractionControllerStateReactions

- (void)storyInteractionDisableUserInteraction
{
    NSLog(@"Disabling interactions.");
    // disable user interaction
    for (UIButton *button in self.answerButtons) {
        [button setUserInteractionEnabled:NO];
    }
    self.scratchView.userInteractionEnabled = NO;
}

- (void)storyInteractionEnableUserInteraction
{
    NSLog(@"Enabling interactions.");
    // enable user interaction
    for (UIButton *button in self.answerButtons) {
        [button setUserInteractionEnabled:YES];
    }
    
    self.scratchView.userInteractionEnabled = YES;
}



@end
