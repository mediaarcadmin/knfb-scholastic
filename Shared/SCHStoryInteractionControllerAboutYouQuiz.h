//
//  SCHStoryInteractionControllerAboutYouQuiz.h
//  Scholastic
//
//  Created by Gordon Christie on 07/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SCHStoryInteractionController.h"

@class SCHStoryInteractionProgressView;

@interface SCHStoryInteractionControllerAboutYouQuiz : SCHStoryInteractionController 
{
}

@property (nonatomic, retain) IBOutlet UILabel *introductionLabel;

@property (nonatomic, retain) IBOutlet SCHStoryInteractionProgressView *progressView;
@property (nonatomic, retain) IBOutlet UILabel *questionLabel;
@property (nonatomic, retain) IBOutletCollection(UIButton) NSArray *answerButtons;

@property (retain, nonatomic) IBOutlet UIView *buttonContainerView;
@property (nonatomic, retain) IBOutlet UILabel *outcomeTitleLabel;

- (IBAction)startButtonTapped:(id)sender;
- (IBAction)questionButtonTouched:(UIButton *)sender;
- (IBAction)questionButtonTapped:(id)sender;
- (IBAction)questionButtonTapCancelled:(id)sender;

@end
