//
//  SCHSettingsSyncComponent.h
//  Scholastic
//
//  Created by John S. Eddie on 04/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SCHSyncComponent.h"

// Constants
extern NSString * const SCHSettingsSyncComponentDidCompleteNotification;
extern NSString * const SCHSettingsSyncComponentDidFailNotification;

@interface SCHSettingsSyncComponent : SCHSyncComponent

- (void)clearCoreDataUsingContext:(NSManagedObjectContext *)aManagedObjectContext;

@end
