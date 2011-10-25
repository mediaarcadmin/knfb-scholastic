//
//  SCHStoryInteractionViewController.h
//  Scholastic
//
//  Created by Neil Gall on 31/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

#define STORY_INTERACTIONS_SUPPORT_AUTO_ROTATION 1

@class SCHStoryInteractionController;

@interface SCHStoryInteractionStandaloneViewController : UIViewController

@property (nonatomic, retain) SCHStoryInteractionController *storyInteractionController;

- (void)setReadingViewSnapshot:(UIImage *)image;

@end
