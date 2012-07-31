//
//  SCHStoryInteractionControllerReadingQuiz.h
//  Scholastic
//
//  Created by Gordon Christie on 24/07/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHStoryInteractionController.h"
#import "TTTAttributedLabel.h"
#import "SCHStretchableImageButton.h"
#import "SCHStoryInteractionReadingQuizResultView.h"

@class SCHStoryInteractionProgressView;

@interface SCHStoryInteractionControllerReadingQuiz : SCHStoryInteractionController

@property (retain, nonatomic) IBOutlet UILabel *introTitleLabel;
@property (retain, nonatomic) IBOutlet UILabel *introSubtitleLabel;
@property (retain, nonatomic) IBOutlet UILabel *bestScoreLabel;
@property (retain, nonatomic) IBOutlet SCHStretchableImageButton *introActionButton;

@property (retain, nonatomic) IBOutlet UILabel *ipadQuestionLabel;
@property (retain, nonatomic) IBOutlet UIScrollView *answerScrollView;
@property (retain, nonatomic) IBOutlet UIView *answerScrollViewContainer;

@property (nonatomic, retain) IBOutlet SCHStoryInteractionProgressView *progressView;
@property (nonatomic, retain) IBOutletCollection(UIButton) NSArray *answerButtons;
@property (retain, nonatomic) IBOutlet UIView *answerBackgroundView;

@property (nonatomic, retain) IBOutlet UILabel *scoreLabel;
@property (nonatomic, retain) IBOutlet UILabel *scoreSublabel;
@property (retain, nonatomic) IBOutlet UILabel *resultsHeaderLabel;

- (IBAction)startViewButtonTapped:(id)sender;

- (IBAction)answerButtonTapped:(id)sender;
- (IBAction)answerButtonTouched:(id)sender;
- (IBAction)answerButtonTapCancelled:(id)sender;

- (IBAction)playAgainButtonTapped:(id)sender;

@end
