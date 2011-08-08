//
//  SCHStoryInteractionControllerConcentration.h
//  Scholastic
//
//  Created by Neil Gall on 08/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionController.h"

@interface SCHStoryInteractionControllerConcentration : SCHStoryInteractionController {}

@property (nonatomic, retain) IBOutletCollection(UIButton) NSArray *levelButtons;
@property (nonatomic, retain) IBOutlet UIView *flipContainer;
@property (nonatomic, retain) IBOutlet UILabel *flipCounterLabel;

- (IBAction)levelButtonTapped:(id)sender;
- (IBAction)startOverTapped:(id)sender;

@end
