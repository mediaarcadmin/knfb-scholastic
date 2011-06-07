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


@interface SCHStoryInteractionControllerAboutYouQuiz : SCHStoryInteractionController {}



@property (nonatomic, retain) IBOutlet SCHStoryInteractionProgressView *progressView;

@property (nonatomic, retain) IBOutlet UILabel *questionLabel;

@property (nonatomic, retain) IBOutlet UIButton *answerButton1;
@property (nonatomic, retain) IBOutlet UIButton *answerButton2;
@property (nonatomic, retain) IBOutlet UIButton *answerButton3;
@property (nonatomic, retain) IBOutlet UIButton *answerButton4;
@property (nonatomic, retain) IBOutlet UIButton *answerButton5;

- (IBAction)questionButtonTapped:(id)sender;

@end
