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

@class SCHStoryInteractionProgressView;

@interface SCHStoryInteractionControllerReadingQuiz : SCHStoryInteractionController

@property (retain, nonatomic) IBOutlet TTTAttributedLabel *introTitleLabel;
@property (retain, nonatomic) IBOutlet UILabel *introSubtitleLabel;
@property (retain, nonatomic) IBOutlet SCHStretchableImageButton *introActionButton;


@property (nonatomic, retain) IBOutlet SCHStoryInteractionProgressView *progressView;
@property (nonatomic, retain) IBOutlet UILabel *questionLabel;
@property (nonatomic, retain) IBOutletCollection(UIButton) NSArray *answerButtons;

@property (nonatomic, retain) IBOutlet UILabel *scoreLabel;
@property (nonatomic, retain) IBOutlet UILabel *scoreSublabel;

- (IBAction)startViewButtonTapped:(id)sender;

- (IBAction)answerButtonTapped:(id)sender;
- (IBAction)answerButtonTouched:(id)sender;
- (IBAction)answerButtonTapCancelled:(id)sender;

- (IBAction)playAgainButtonTapped:(id)sender;

@end
