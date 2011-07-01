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

@end
