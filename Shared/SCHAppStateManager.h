//
//  SCHAppStateManager.h
//  Scholastic
//
//  Created by John S. Eddie on 08/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSNumber+ObjectTypes.h"
#import "SCHAppState.h"

@class NSManagedObjectContext;

@interface SCHAppStateManager : NSObject 
{    
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

+ (SCHAppStateManager *)sharedAppStateManager;

- (BOOL)canSync;
- (void)setCanSync:(BOOL)sync;

- (BOOL)canSyncNotes;
- (void)setCanSyncNotes:(BOOL)sync;

- (BOOL)canAuthenticate;
- (void)setCanAuthenticate:(BOOL)auth;

- (void)setServerDateDelta:(NSTimeInterval)seconds;
- (NSTimeInterval)serverDateDelta;

- (BOOL)isStandardStore;
- (BOOL)isSampleStore;
- (void)setDataStoreType:(SCHDataStoreTypes)type;

- (NSString *)lastKnownAuthToken;
- (void)setLastKnownAuthToken:(NSString *)token;

- (NSDate *)lastRemoteManifestUpdateDate;
- (void)setLastRemoteManifestUpdateDate:(NSDate *)date;

@end
