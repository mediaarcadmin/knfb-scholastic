//
//  SCHStoryInteractionControllerWordSearch.h
//  Scholastic
//
//  Created by Neil Gall on 07/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHStoryInteractionController.h"
#import "SCHStoryInteractionWordSearchContainerView.h"

@class SCHStoryInteractionStrikeOutLabelView;

@interface SCHStoryInteractionControllerWordSearch : SCHStoryInteractionController <SCHStoryInteractionWordSearchContainerViewDelegate> {}

@property (nonatomic, retain) IBOutlet UIView *wordsContainerView;
@property (nonatomic, retain) IBOutlet SCHStoryInteractionWordSearchContainerView *lettersContainerView;
@property (nonatomic, retain) IBOutlet SCHStoryInteractionStrikeOutLabelView *wordView1;
@property (nonatomic, retain) IBOutlet SCHStoryInteractionStrikeOutLabelView *wordView2;
@property (nonatomic, retain) IBOutlet SCHStoryInteractionStrikeOutLabelView *wordView3;
@property (nonatomic, retain) IBOutlet SCHStoryInteractionStrikeOutLabelView *wordView4;
@property (nonatomic, retain) IBOutlet SCHStoryInteractionStrikeOutLabelView *wordView5;
@property (nonatomic, retain) IBOutlet SCHStoryInteractionStrikeOutLabelView *wordView6;

@end
