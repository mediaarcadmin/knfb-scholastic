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
extern double const SCHSyncComponentThreadLowPriority;

@interface SCHSyncComponent : SCHComponent
{
}

@property (assign, nonatomic) BOOL isSynchronizing;
@property (retain, atomic) NSManagedObjectContext *managedObjectContext;

@property (readonly, nonatomic) NSUInteger failureCount;

@property (nonatomic, assign) BOOL saveOnly;

- (BOOL)synchronize;
- (void)clearFailures;
- (void)resetSync;
- (void)resetWebService;
- (void)clearCoreData;

- (void)completeWithSuccessMethod:(NSString *)method 
                           result:(NSDictionary *)result 
                         userInfo:(NSDictionary *)userInfo
                 notificationName:(NSString *)notificationName
             notificationUserInfo:(NSDictionary *)notificationUserInfo;
- (void)completeWithFailureMethod:(NSString *)method 
                            error:(NSError *)error 
                      requestInfo:(NSDictionary *)requestInfo 
                           result:(NSDictionary *)result
                 notificationName:(NSString *)notificationName
             notificationUserInfo:(NSDictionary *)notificationUserInfo;

@end
