//
//  SCHStoryInteractionControllerWhoSaidIt_iPhone.h
//  Scholastic
//
//  Created by Neil Gall on 13/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHStoryInteractionController.h"

@interface SCHStoryInteractionControllerWhoSaidIt_iPhone : SCHStoryInteractionController {}

@property (nonatomic, retain) IBOutlet UILabel *statementLabel;
@property (nonatomic, retain) IBOutletCollection(UIButton) NSArray *answerButtons;

@property (nonatomic, retain) IBOutlet UILabel *scoreLabel;
@property (nonatomic, retain) IBOutlet UIButton *tryAgainButton;

- (IBAction)answerButtonTapped:(id)sender;
- (IBAction)playAgainButtonTapped:(id)sender;

@end
