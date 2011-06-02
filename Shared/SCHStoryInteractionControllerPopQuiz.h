//
//  SCHStoryInteractionControllerPopQuiz.h
//  Scholastic
//
//  Created by Neil Gall on 02/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHStoryInteractionController.h"

@class SCHStoryInteractionProgressView;

@interface SCHStoryInteractionControllerPopQuiz : SCHStoryInteractionController {}

@property (nonatomic, retain) IBOutlet SCHStoryInteractionProgressView *progressView;
@property (nonatomic, retain) IBOutlet UILabel *questionLabel;
@property (nonatomic, retain) IBOutlet UIButton *answerButton1;
@property (nonatomic, retain) IBOutlet UIButton *answerButton2;
@property (nonatomic, retain) IBOutlet UIButton *answerButton3;
@property (nonatomic, retain) IBOutlet UIButton *answerButton4;

- (IBAction)closeButtonTapped:(id)sender;
- (IBAction)answerButtonTapped:(id)sender;

@end
