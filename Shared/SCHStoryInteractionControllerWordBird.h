//
//  SCHStoryInteractionControllerWordBird.h
//  Scholastic
//
//  Created by Neil Gall on 11/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionController.h"

@interface SCHStoryInteractionControllerWordBird : SCHStoryInteractionController {}

@property (nonatomic, retain) IBOutlet UIView *answerContainer;
@property (nonatomic, retain) IBOutlet UIView *lettersContainer;
@property (nonatomic, retain) IBOutlet UIView *animationContainer;
@property (nonatomic, retain) IBOutlet UILabel *introLabel;
@property (nonatomic, retain) IBOutlet UIButton *playButton;

- (IBAction)playTapped:(id)sender;
 
@end
