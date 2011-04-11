//
//  SCHAuthenticationManagerProtected.h
//  Scholastic
//
//  Created by John S. Eddie on 11/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

static NSString * const kSCHAuthenticationManagerUsername = @"AuthenticationManager.Username";
static NSString * const kSCHAuthenticationManagerServiceName = @"Scholastic";

static NSTimeInterval const kSCHAuthenticationManagerSecondsInAMinute = 60.0;

@interface SCHAuthenticationManager ()

- (void)authenticateOnMainThread;

@end