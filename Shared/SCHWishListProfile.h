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

extern NSString * const kSCHWishListProfile;

@interface SCHWishListProfile : SCHSyncEntity

@property (nonatomic, retain) NSNumber * profileID;
@property (nonatomic, retain) NSString * profileName;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSSet *itemList;
@end

@interface SCHWishListProfile (CoreDataGeneratedAccessors)

- (void)addItemListObject:(NSManagedObject *)value;
- (void)removeItemListObject:(NSManagedObject *)value;
- (void)addItemList:(NSSet *)values;
- (void)removeItemList:(NSSet *)values;

@end
