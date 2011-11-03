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
#import "NSArray+ViewSorting.h"

static const NSInteger kFirstScratchPointTarget = 60;
static const NSInteger kSecondScratchPointTarget = 100;

enum ScratchState {
    kScratchStateFirstScratch,
    kScratchStateFirstQuestionAttempt,
    kScratchStateSecondScratch,
    kScratchStateSecondQuestionAttempt,
    kScratchStateKeepTrying
};

@interface SCHStoryInteractionControllerScratchAndSee ()

@property (nonatomic, assign) NSInteger currentQuestionIndex;
@property (nonatomic, assign) NSInteger simultaneousTapCount;
@property (nonatomic, assign) enum ScratchState scratchState;

- (SCHStoryInteractionScratchAndSeeQuestion *)currentQuestion;
- (NSInteger)scratchPointTarget;

- (void)nextQuestion;
- (void)setupQuestionAnimated:(BOOL)animated;
- (void)correctAnswer:(NSInteger) selection;
- (void)wrongAnswer:(NSInteger) selection;

- (void)setProgressViewForScratchCount: (NSInteger) scratchCount;
- (void)askQuestion;

@end


@implementation SCHStoryInteractionControllerScratchAndSee

@synthesize scratchView;
@synthesize buttonContainerView;
@synthesize answerButtons;
@synthesize progressImageView;
@synthesize progressCoverImageView;
@synthesize progressView;
@synthesize aLabel;
@synthesize bLabel;
@synthesize cLabel;
@synthesize currentQuestionIndex;
@synthesize simultaneousTapCount;
@synthesize scratchState;

- (void)dealloc
{
    [buttonContainerView release], buttonContainerView = nil;
    [answerButtons release], answerButtons = nil;
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
    self.answerButtons = [self.answerButtons viewsInRowMajorOrder];
    self.scratchView.delegate = self;
    
    for (UIButton *button in answerButtons) {
        button.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
        button.titleLabel.textAlignment = UITextAlignmentCenter;
    }
    
    NSInteger i = 0;
    for (NSString *answer in [self currentQuestion].answers) {
        UIButton *button = [self.answerButtons objectAtIndex:i];
        [button setTitle:answer forState:UIControlStateNormal];
        [button setAlpha:0];
        ++i;
    }
    
    self.progressCoverImageView.image = [[UIImage imageNamed:@"progressbar-cover"] stretchableImageWithLeftCapWidth:16 topCapHeight:0];
    self.progressImageView.image = [UIImage imageNamed:@"progressbar-fill"];
    self.progressView.alpha = 1;

    // get the current question
    if (self.delegate && [self.delegate respondsToSelector:@selector(currentQuestionForStoryInteraction)]) {
        self.currentQuestionIndex += [self.delegate currentQuestionForStoryInteraction];    
    }
    
    self.scratchState = kScratchStateFirstScratch;
    [self setupQuestionAnimated:NO];
}

- (void)rotateToOrientation:(UIInterfaceOrientation)orientation
{
    static const CGFloat kButtonGap = 7;
    static const CGFloat kMinimumFontSize = 12;
    static const CGFloat kLabelInset = 40;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (self.scratchState == kScratchStateFirstScratch || self.scratchState == kScratchStateSecondScratch) {
            CGPoint center = CGPointMake(CGRectGetMidX(self.contentsView.bounds), CGRectGetMidY(self.contentsView.bounds));
            CGFloat gap = UIInterfaceOrientationIsLandscape(orientation) ? 10 : 20;
            CGFloat height = CGRectGetHeight(self.scratchView.bounds)+gap+CGRectGetHeight(self.progressView.bounds);
            CGFloat scratchOffset = height/2-CGRectGetMidY(self.scratchView.bounds);
            CGFloat progressOffset = (height-CGRectGetMidY(self.progressView.bounds))-height/2;
            self.scratchView.center = CGPointMake(center.x, center.y-scratchOffset);
            self.progressView.center = CGPointMake(center.x, center.y+progressOffset);
        } else {
            self.scratchView.center = CGPointMake(CGRectGetMidX(self.contentsView.bounds), CGRectGetMinY(self.buttonContainerView.frame)/2);
            CGFloat fontSize = 15;
            NSString *fontName = @"Arial-BoldMT";
            if (UIInterfaceOrientationIsLandscape(orientation)) {
                // lay out buttons horizontally
                CGFloat width = (CGRectGetWidth(self.buttonContainerView.bounds)-kButtonGap)/[self.answerButtons count] - kButtonGap;
                CGFloat x = kButtonGap+width/2;
                CGFloat y = CGRectGetMidY(self.buttonContainerView.bounds);
                for (UIButton *button in self.answerButtons) {
                    button.center = CGPointMake(x, y);
                    button.bounds = CGRectMake(0, 0, width, CGRectGetHeight(button.bounds));
                    button.imageEdgeInsets = UIEdgeInsetsMake(0, width-30, 0, 0);
                    NSString *title = [button titleForState:UIControlStateNormal];
                    [title sizeWithFont:[UIFont fontWithName:fontName size:fontSize]
                            minFontSize:kMinimumFontSize
                         actualFontSize:&fontSize
                               forWidth:width-kLabelInset
                          lineBreakMode:UILineBreakModeWordWrap];
                    x += kButtonGap+width;
                }
            } else {
                // lay out buttons vertically
                CGFloat width = CGRectGetWidth(self.buttonContainerView.bounds)-kButtonGap*2;
                CGFloat height = CGRectGetHeight([[self.answerButtons objectAtIndex:0] bounds]);
                CGFloat x = CGRectGetMidX(self.buttonContainerView.bounds);
                CGFloat spacing = CGRectGetHeight(self.buttonContainerView.bounds)/[self.answerButtons count];
                CGFloat y = spacing/2;
                for (UIButton *button in self.answerButtons) {
                    button.center = CGPointMake(x, y);
                    button.bounds = CGRectMake(0, 0, width, height);
                    button.imageEdgeInsets = UIEdgeInsetsMake(0, width-30, 0, 0);
                    NSString *title = [button titleForState:UIControlStateNormal];
                    [title sizeWithFont:[UIFont fontWithName:fontName size:fontSize]
                            minFontSize:kMinimumFontSize
                         actualFontSize:&fontSize
                               forWidth:width-kLabelInset
                          lineBreakMode:UILineBreakModeWordWrap];
                    y += spacing;
                }
            }
            
            UIFont *font = [UIFont fontWithName:fontName size:fontSize];
            for (UIButton *button in self.answerButtons) {
                [button.titleLabel setFont:font];
                
            }
        }
    }
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
            [self cancelQueuedAudioExecutingSynchronizedBlocksBefore:^{
                [self askQuestion];
            }];
            break;
        default:
            [super playAudioButtonTapped:sender];
            break;
    }
}

- (void)setupQuestionAnimated:(BOOL)animated
{
    const BOOL iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    const BOOL scratching = (self.scratchState == kScratchStateFirstScratch || self.scratchState == kScratchStateSecondScratch);
    
    CGFloat contentsHeight = scratching ? 282 : 380;
    dispatch_block_t adjustments = ^{
        if (scratching) {
            if (self.scratchState == kScratchStateFirstScratch) {
                UIImage *image = [self imageAtPath:[[self currentQuestion] imagePath]];
                self.scratchView.answerImage = image;
                [self setProgressViewForScratchCount:0];
                [self setTitle:NSLocalizedString(@"Scratch away the question mark to see the picture.", @"")];
            } else {
                [self setProgressViewForScratchCount:kFirstScratchPointTarget];
                [self setTitle:NSLocalizedString(@"Keep Scratching!", @"")];
            }
            self.scratchView.interactionEnabled = YES;
            self.progressView.alpha = 1;
            aLabel.alpha = 0;
            bLabel.alpha = 0;
            cLabel.alpha = 0;
        } else {
            [self setTitle:NSLocalizedString(@"What do you see?", @"")];
            self.progressView.alpha = 0;
            aLabel.alpha = 1;
            bLabel.alpha = 1;
            cLabel.alpha = 1;
        }
    
        NSInteger i = 0;
        for (NSString *answer in [self currentQuestion].answers) {
            UIImage *highlight;
            UIButton *button = [self.answerButtons objectAtIndex:i];
            
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
            [button setAlpha:scratching ? 0 : 1];
            [button setBackgroundImage:highlight forState:UIControlStateSelected];

            [button setImage:[UIImage imageNamed:@"answer-blank"] forState:UIControlStateNormal];
            if (i == [self currentQuestion].correctAnswer) {
                [button setImage:[UIImage imageNamed:@"answer-tick"] forState:UIControlStateSelected];
            } else {
                [button setImage:[UIImage imageNamed:@"answer-cross"] forState:UIControlStateSelected];
            }
            
            ++i;
        }
        for (; i < [self.answerButtons count]; ++i) {
            [[self.answerButtons objectAtIndex:i] setAlpha:0];
        }

        [self rotateToOrientation:self.interfaceOrientation];
    };

    if (iPad) {
        [self resizeCurrentViewToSize:CGSizeMake(self.contentsView.bounds.size.width, contentsHeight)
                    animationDuration:(animated ? 0.5 : 0)
             withAdditionalAdjustments:adjustments];
    } else {
        adjustments();
    }
    
    self.simultaneousTapCount = 0;
}

- (void)askQuestion
{
    self.controllerState = SCHStoryInteractionControllerStateAskingOpeningQuestion;

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

- (IBAction)questionButtonTouched:(UIButton *)sender
{
    self.controllerState = SCHStoryInteractionControllerStateInteractionReadingAnswerWithPause;    
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
    for (int i = 0; i < [self.answerButtons count]; i++) {
        if (i == selection) {
            [(UIButton *) [self.answerButtons objectAtIndex:i] setSelected:YES];
        } else {
            [(UIButton *) [self.answerButtons objectAtIndex:i] setSelected:NO];
        }
    }
        
    [self.scratchView setShowFullImage:YES];
    
    [self cancelQueuedAudioExecutingSynchronizedBlocksBefore:^{
        [self enqueueAudioWithPath:[self.storyInteraction storyInteractionCorrectAnswerSoundFilename] 
                        fromBundle:YES 
                        startDelay:0 
            synchronizedStartBlock:^{
                self.controllerState = SCHStoryInteractionControllerStateInteractionFinishedSuccessfully;
            }
              synchronizedEndBlock:nil];
        
        [self enqueueAudioWithPath:[[self currentQuestion] audioPathForAnswerAtIndex:selection] fromBundle:NO];
        [self enqueueAudioWithPath:[(SCHStoryInteractionScratchAndSee *)self.storyInteraction thatsRightAudioPath] fromBundle:NO];
        [self enqueueAudioWithPath:[[self currentQuestion] correctAnswerAudioPath]
                        fromBundle:NO
                        startDelay:0
            synchronizedStartBlock:nil
              synchronizedEndBlock:^{
                  [self nextQuestion];
              }];
    }];
}

- (void)wrongAnswer:(NSInteger) selection
{
    SCHStoryInteractionScratchAndSee *scratchAndSee = (SCHStoryInteractionScratchAndSee *)self.storyInteraction;
    
    UIButton *button = (UIButton *) [self.answerButtons objectAtIndex:selection];
    [button setSelected:YES];
    
    [self cancelQueuedAudioExecutingSynchronizedBlocksBefore:^{
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
                          [self setupQuestionAnimated:YES];
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
                          [self setupQuestionAnimated:YES];
                      }];
                break;
            }
            default:
                break;
        }
    }];
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

- (void)scratchViewWasScratched:(SCHStoryInteractionScratchView *)aScratchView
{
    if (![self playingAudio]) {
        [self enqueueAudioWithPath:[(SCHStoryInteractionScratchAndSee *)self.storyInteraction scratchSoundEffectFilename] fromBundle:YES startDelay:0 synchronizedStartBlock:nil synchronizedEndBlock:nil requiresEmptyQueue:YES];
    }
}

- (void)scratchView:(SCHStoryInteractionScratchView *)aScratchView uncoveredPoints:(NSInteger)points
{
    if ((self.scratchState == kScratchStateFirstScratch || self.scratchState == kScratchStateSecondScratch) && points > [self scratchPointTarget]) {
        if (self.scratchState == kScratchStateFirstScratch) {
            self.scratchState = kScratchStateFirstQuestionAttempt;
        } else if (self.scratchState == kScratchStateSecondScratch) {
            self.scratchState = kScratchStateSecondQuestionAttempt;
        }
        
        self.progressView.alpha = 0;
        [self setupQuestionAnimated:YES];

        aScratchView.interactionEnabled = NO;

        [self cancelQueuedAudioExecutingSynchronizedBlocksBefore:^{
            [self enqueueAudioWithPath:[(SCHStoryInteractionScratchAndSee *)self.storyInteraction scratchingCompleteSoundEffectFilename]
                            fromBundle:YES
                            startDelay:0
                synchronizedStartBlock:^{
                    self.controllerState = SCHStoryInteractionControllerStateInteractionReadingAnswerWithPause;
                }
                  synchronizedEndBlock:^{
                      [self askQuestion];
                  }];
        }];
    } else {
        [self setProgressViewForScratchCount:points];
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
