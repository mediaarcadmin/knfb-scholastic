//
//  SCHStoryInteractionControllerTitleTwister.h
//  Scholastic
//
//  Created by Neil Gall on 09/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHStoryInteractionController.h"
#import "SCHStoryInteractionDraggableView.h"

@class SCHStoryInteractionDraggableTargetView;

@interface SCHStoryInteractionControllerTitleTwister : SCHStoryInteractionController <UITableViewDataSource, SCHStoryInteractionDraggableViewDelegate> {}

@property (nonatomic, retain) IBOutlet UILabel *openingScreenTitleLabel;
@property (nonatomic, retain) IBOutlet SCHStoryInteractionDraggableTargetView *answerBuildTarget;
@property (nonatomic, retain) IBOutletCollection(UILabel) NSArray *answerHeadingCounts;
@property (nonatomic, retain) IBOutletCollection(UITableView) NSArray *answerTables;

- (IBAction)goButtonTapped:(id)sender;
- (IBAction)doneButtonTapped:(id)sender;
- (IBAction)clearButtonTapped:(id)sender;

@end
