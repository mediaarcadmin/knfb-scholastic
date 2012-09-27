//
//  SCHSyncComponentProtected.h
//  Scholastic
//
//  Created by John S. Eddie on 04/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHSyncComponent.h"

@interface SCHSyncComponent ()

- (void)saveWithManagedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;

@property (nonatomic, retain) NSOperationQueue *backgroundProcessingQueue;
@property (assign, nonatomic) UIBackgroundTaskIdentifier backgroundTaskIdentifier;

- (void)beginBackgroundTask;
- (void)endBackgroundTask;

@end