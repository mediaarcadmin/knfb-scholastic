//
//  SCHStoryInteractionControllerWhoSaidIt.h
//  Scholastic
//
//  Created by Neil Gall on 03/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHStoryInteractionController.h"
#import "SCHStoryInteractionDraggableView.h"

@class SCHStoryInteractionDraggableTargetView;

@interface SCHStoryInteractionControllerWhoSaidIt_iPad : SCHStoryInteractionController <SCHStoryInteractionDraggableViewDelegate> {}

@property (nonatomic, retain) IBOutletCollection(UILabel) NSArray *statementLabels;
@property (nonatomic, retain) IBOutletCollection(SCHStoryInteractionDraggableView) NSArray *sources;
@property (nonatomic, retain) IBOutletCollection(SCHStoryInteractionDraggableTargetView) NSArray *targets;
@property (nonatomic, retain) IBOutlet UIButton *checkAnswersButton;

- (IBAction)checkAnswers:(id)sender;


@end
