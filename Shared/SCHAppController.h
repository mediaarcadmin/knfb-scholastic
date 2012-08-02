//
//  SCHAppController.h
//  Scholastic
//
//  Created by Matt Farrugia on 19/07/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SCHAppController <NSObject>

@required

// Presentation Methods

- (void)presentProfiles;
- (void)presentProfilesSetup;
- (void)presentSamplesWithWelcome:(BOOL)welcome;
- (void)presentLogin;

// Failure Methods

- (void)failedSamplesWithError:(NSError *)error;
- (void)failedLoginWithError:(NSError *)error;
- (void)failedSyncWithError:(NSError *)error;

@end
