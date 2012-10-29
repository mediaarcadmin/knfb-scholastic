//
//  SCHProfileSetupDelegate.h
//  Scholastic
//
//  Created by Matt Farrugia on 19/10/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHModalPresenterDelegate.h"

@class SCHBookIdentifier;

@protocol SCHProfileSetupDelegate <SCHModalPresenterDelegate>

- (void)popToAuthenticatedProfileAnimated:(BOOL)animated;
- (void)pushCurrentProfileAnimated:(BOOL)animated;
- (void)waitingForPassword;
- (void)waitingForBookshelves;
- (void)waitingForTourBookWithIdentifier:(SCHBookIdentifier *)identifier;

@end