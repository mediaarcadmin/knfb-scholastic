//
//  SCHStoryInteractionControllerWhoSaidIt.h
//  Scholastic
//
//  Created by Neil Gall on 03/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHStoryInteractionController.h"

@class SCHStoryInteractionDraggableView;
@class SCHStoryInteractionDraggableTargetView;

@interface SCHStoryInteractionControllerWhoSaidIt : SCHStoryInteractionController {}

@property (nonatomic, retain) IBOutlet UILabel *statementLabel1;
@property (nonatomic, retain) IBOutlet UILabel *statementLabel2;
@property (nonatomic, retain) IBOutlet UILabel *statementLabel3;
@property (nonatomic, retain) IBOutlet UILabel *statementLabel4;
@property (nonatomic, retain) IBOutlet UILabel *statementLabel5;
@property (nonatomic, retain) IBOutlet SCHStoryInteractionDraggableTargetView *target1;
@property (nonatomic, retain) IBOutlet SCHStoryInteractionDraggableTargetView *target2;
@property (nonatomic, retain) IBOutlet SCHStoryInteractionDraggableTargetView *target3;
@property (nonatomic, retain) IBOutlet SCHStoryInteractionDraggableTargetView *target4;
@property (nonatomic, retain) IBOutlet SCHStoryInteractionDraggableTargetView *target5;
@property (nonatomic, retain) IBOutlet SCHStoryInteractionDraggableView *source1;
@property (nonatomic, retain) IBOutlet SCHStoryInteractionDraggableView *source2;
@property (nonatomic, retain) IBOutlet SCHStoryInteractionDraggableView *source3;
@property (nonatomic, retain) IBOutlet SCHStoryInteractionDraggableView *source4;
@property (nonatomic, retain) IBOutlet SCHStoryInteractionDraggableView *source5;
@property (nonatomic, retain) IBOutlet SCHStoryInteractionDraggableView *source6;
@property (nonatomic, retain) IBOutlet UIButton *checkAnswersButton;

- (IBAction)checkAnswers:(id)sender;


@end
