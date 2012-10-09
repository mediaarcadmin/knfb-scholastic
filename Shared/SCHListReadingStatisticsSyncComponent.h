//
//  SCHListReadingStatisticsSyncComponent.h
//  Scholastic
//
//  Created by John S. Eddie on 28/09/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHSyncComponent.h"

// Constants
extern NSString * const SCHListReadingStatisticsSyncComponentDidCompleteNotification;
extern NSString * const SCHListReadingStatisticsSyncComponentDidFailNotification;

@interface SCHListReadingStatisticsSyncComponent : SCHSyncComponent

- (void)syncCompleted:(NSNumber *)profileID
             userInfo:(NSDictionary *)userInfo;
- (void)addProfile:(NSNumber *)profileID withBooks:(NSArray *)books;
- (void)removeProfile:(NSNumber *)profileID withBooks:(NSArray *)books;
- (BOOL)haveProfiles;
- (BOOL)nextProfile;

@end
