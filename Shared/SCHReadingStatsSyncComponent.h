//
//  SCHReadingStatsSyncComponent.h
//  Scholastic
//
//  Created by John S. Eddie on 04/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SCHSyncComponent.h"

// Constants
extern NSString * const SCHReadingStatsSyncComponentDidCompleteNotification;
extern NSString * const SCHReadingStatsSyncComponentDidFailNotification;

@interface SCHReadingStatsSyncComponent : SCHSyncComponent

- (void)clearCoreDataUsingContext:(NSManagedObjectContext *)aManagedObjectContext;
- (void)addProfile:(NSNumber *)profileID;
- (void)removeProfile:(NSNumber *)profileID;
- (BOOL)haveProfiles;
- (BOOL)nextProfile;
- (void)syncCompleted:(NSNumber *)profileID
               result:(NSDictionary *)result
             userInfo:(NSDictionary *)userInfo;

@end
