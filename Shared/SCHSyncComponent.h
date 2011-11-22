//
//  SCHSyncComponent.h
//  Scholastic
//
//  Created by John S. Eddie on 04/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "SCHComponent.h"
#import "NSNumber+ObjectTypes.h"

// Constants
extern NSString * const SCHSyncComponentDidFailAuthenticationNotification;

@interface SCHSyncComponent : SCHComponent
{
}

@property (assign, nonatomic) BOOL isSynchronizing;
@property (retain, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (readonly, nonatomic) NSUInteger failureCount;

- (BOOL)synchronize;
- (void)clearFailures;

@end
