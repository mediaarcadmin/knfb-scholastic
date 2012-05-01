//
//  SCHSyncComponentProtected.h
//  Scholastic
//
//  Created by John S. Eddie on 04/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHSyncComponent.h"
#import "SCHComponentProtected.h"

@interface SCHSyncComponent ()

- (void)save;

@property (assign, nonatomic) UIBackgroundTaskIdentifier backgroundTaskIdentifier;

- (void)beginBackgroundTask;
- (void)endBackgroundTask;

@end