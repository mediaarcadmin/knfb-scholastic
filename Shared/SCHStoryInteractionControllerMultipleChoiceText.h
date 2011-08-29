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


@property (nonatomic, retain) IBOutletCollection(UIButton) NSArray *answerButtons;

- (IBAction)answerButtonTouched:(UIButton *)sender;
- (IBAction)answerButtonTapped:(id)sender;

@end
