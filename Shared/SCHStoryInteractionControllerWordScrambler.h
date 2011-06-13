//
//  SCHStoryInteractionControllerWordScrambler.h
//  Scholastic
//
//  Created by Neil Gall on 10/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHStoryInteractionController.h"
#import "SCHStoryInteractionDraggableLetterView.h"

@interface SCHStoryInteractionControllerWordScrambler : SCHStoryInteractionController <SCHStoryInteractionDraggableViewDelegate> {}

@property (nonatomic, retain) IBOutlet UILabel *clueLabel;
@property (nonatomic, retain) IBOutlet UIView *lettersContainerView;

- (IBAction)hintButtonTapped:(id)sender;

@end
