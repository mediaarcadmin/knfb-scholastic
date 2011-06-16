//
//  SCHStoryInteractionControllerDelegate.h
//  Scholastic
//
//  Created by Neil Gall on 02/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SCHStoryInteractionController;

@protocol SCHStoryInteractionControllerDelegate <NSObject>

@optional
- (void)storyInteractionController:(SCHStoryInteractionController *)storyInteractionController didDismissWithSuccess:(BOOL)success;

@end
