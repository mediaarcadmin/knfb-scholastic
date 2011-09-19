//
//  SCHAnnotationSyncComponent.h
//  Scholastic
//
//  Created by John S. Eddie on 04/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SCHSyncComponent.h"

// Constants
extern NSString * const SCHAnnotationSyncComponentDidCompleteNotification;
extern NSString * const SCHAnnotationSyncComponentDidFailNotification;
extern NSString * const SCHAnnotationSyncComponentCompletedProfileIDs;

@interface SCHAnnotationSyncComponent : SCHSyncComponent 
{
}

- (void)addProfile:(NSNumber *)profileID withBooks:(NSArray *)books;
- (BOOL)haveProfiles;

@end
