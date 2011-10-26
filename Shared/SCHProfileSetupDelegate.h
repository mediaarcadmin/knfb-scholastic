//
//  SCHProfileSetupDelegate.h
//  Scholastic
//
//  Created by Matt Farrugia on 19/10/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHModalPresenterDelegate.h"

@protocol SCHProfileSetupDelegate <SCHModalPresenterDelegate>

- (void)pushAuthenticatedProfileAnimated:(BOOL)animated;
- (void)popToAuthenticatedProfileAnimated:(BOOL)animated;

- (void)pushSamplesAnimated:(BOOL)animated;
- (void)showCurrentProfileAnimated:(BOOL)animated;

// Web Parent Tools methods
- (void)waitingForPassword;
- (void)waitingForWebParentToolsToComplete;
- (void)webParentToolsCompleted;

@end