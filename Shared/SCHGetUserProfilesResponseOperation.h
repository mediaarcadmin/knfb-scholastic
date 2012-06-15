//
//  SCHGetUserProfilesResponseOperation.h
//  Scholastic
//
//  Created by John Eddie on 14/06/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHSyncComponentOperation.h"

@class SCHProfileItem;

@interface SCHGetUserProfilesResponseOperation : SCHSyncComponentOperation

- (SCHProfileItem *)addProfile:(NSDictionary *)webProfile
          managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;

@end
