//
//  SCHStoryInteractionControllerMultipleChoiceText.h
//  Scholastic
//
//  Created by Neil Gall on 02/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHStoryInteractionController.h"

@interface SCHStoryInteractionControllerMultipleChoiceText : SCHStoryInteractionController {}

@property (nonatomic, retain) IBOutlet UILabel *promptLabel;
@property (nonatomic, retain) IBOutlet UIButton *answerButton1;
@property (nonatomic, retain) IBOutlet UIButton *answerButton2;
@property (nonatomic, retain) IBOutlet UIButton *answerButton3;
@property (nonatomic, retain) IBOutlet UIButton *closeButton;
@property (nonatomic, retain) IBOutlet UIButton *playAudioButton;

- (IBAction)answerButtonTapped:(id)sender;
- (IBAction)closeButtonTapped:(id)sender;
- (IBAction)playAudioButtonTapped:(id)sender;

@end
