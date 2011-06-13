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
@property (nonatomic, retain) IBOutletCollection(UIButton) NSArray *answerButtons;

@property (nonatomic, retain) IBOutlet UILabel *scoreLabel;
@property (nonatomic, retain) IBOutlet UILabel *scoreSublabel;

- (IBAction)answerButtonTapped:(id)sender;
- (IBAction)playAgainButtonTapped:(id)sender;

@end
