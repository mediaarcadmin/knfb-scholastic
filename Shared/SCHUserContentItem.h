//
//  SCHUserContentItem.h
//  Scholastic
//
//  Created by John S. Eddie on 31/01/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "SCHSyncEntity.h"

@class SCHContentProfileItem;
@class SCHOrderItem;

static NSString * const kSCHUserContentItem = @"SCHUserContentItem";

static NSString * const kSCHUserContentItemFetchWithContentIdentifier = @"fetchUserContentItemWithContentIdentifier";
static NSString * const kSCHUserContentItemCONTENT_IDENTIFIER = @"CONTENT_IDENTIFIER";
static NSString * const kSCHUserContentItemDRM_QUALIFIER = @"DRM_QUALIFIER";

@interface SCHUserContentItem :  SCHSyncEntity  
{
}

@property (nonatomic, retain) NSString * Format;
@property (nonatomic, retain) NSString * Version;
@property (nonatomic, retain) NSString * ContentIdentifier;
@property (nonatomic, retain) NSNumber * ContentIdentifierType;
@property (nonatomic, retain) NSNumber * DefaultAssignment;
@property (nonatomic, retain) NSNumber * DRMQualifier;
@property (nonatomic, retain) NSSet* OrderList;
@property (nonatomic, retain) NSSet* ProfileList;

@property (nonatomic, readonly) NSSet *AssignedProfileList;

@end

@interface SCHUserContentItem (CoreDataGeneratedAccessors)

- (void)addOrderListObject:(SCHOrderItem *)value;
- (void)removeOrderListObject:(SCHOrderItem *)value;
- (void)addOrderList:(NSSet *)value;
- (void)removeOrderList:(NSSet *)value;

- (void)addProfileListObject:(SCHContentProfileItem *)value;
- (void)removeProfileListObject:(SCHContentProfileItem *)value;
- (void)addProfileList:(NSSet *)value;
- (void)removeProfileList:(NSSet *)value;

@end

