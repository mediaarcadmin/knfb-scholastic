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

@property (nonatomic, retain) IBOutlet UILabel *outcomeTitleLabel;
@property (nonatomic, retain) IBOutlet UILabel *outcomeTextLabel;

- (IBAction)startButtonTapped:(id)sender;
- (IBAction)questionButtonTouched:(UIButton *)sender;
- (IBAction)questionButtonTapped:(id)sender;
- (IBAction)doneButtonTapped:(id)sender;

@end
