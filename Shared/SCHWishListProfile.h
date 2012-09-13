//
//  SCHWishListProfile.h
//  Scholastic
//
//  Created by John Eddie on 02/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SCHSyncEntity.h"

@class SCHProfileItem;

extern NSString * const kSCHWishListProfile;

@interface SCHWishListProfile : SCHSyncEntity

@property (nonatomic, retain) NSNumber * ProfileID;
@property (nonatomic, retain) NSString * ProfileName;
@property (nonatomic, retain) NSSet *ItemList;

@property (nonatomic, readonly) NSDate * Timestamp;

- (SCHProfileItem *)profileItem;
- (void)setProfileNameFromProfileItem;

+ (BOOL)isValidProfileID:(NSNumber *)profileID;

@end

@interface SCHWishListProfile (CoreDataGeneratedAccessors)

- (void)addItemListObject:(NSManagedObject *)value;
- (void)removeItemListObject:(NSManagedObject *)value;
- (void)addItemList:(NSSet *)values;
- (void)removeItemList:(NSSet *)values;

@end
