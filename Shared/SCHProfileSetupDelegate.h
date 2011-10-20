//
//  SCHProfileSetupDelegate.h
//  Scholastic
//
//  Created by Matt Farrugia on 19/10/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHModalPresenterDelegate.h"

@protocol SCHProfileSetupDelegate <SCHModalPresenterDelegate>

- (void)showCurrentSamplesAnimated:(BOOL)animated;
- (void)showCurrentProfileAnimated:(BOOL)animated;

@end