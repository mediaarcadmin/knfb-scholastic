//
//  SCHProfileSyncComponent.h
//  Scholastic
//
//  Created by John S. Eddie on 04/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SCHSyncComponent.h"
#import "NSNumber+ObjectTypes.h"

@class SCHProfileItem;

// Constants
extern NSString * const SCHProfileSyncComponentWillDeleteNotification;
extern NSString * const SCHProfileSyncComponentDeletedProfileIDs;
extern NSString * const SCHProfileSyncComponentDidCompleteNotification;
extern NSString * const SCHProfileSyncComponentDidFailNotification;

@interface SCHProfileSyncComponent : SCHSyncComponent

@property (atomic, retain) NSMutableArray *savedProfiles;

- (BOOL)requestUserProfiles;
- (void)syncProfilesFromMainThread:(NSArray *)profileList;
- (void)addProfileFromMainThread:(NSDictionary *)webProfile;

+ (void)removeWishListForProfile:(SCHProfileItem *)profileItem
            managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;

@end
