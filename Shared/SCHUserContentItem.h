//
//  SCHUserContentItem.h
//  Scholastic
//
//  Created by John S. Eddie on 31/01/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "SCHSyncEntity.h"

#import "SCHISBNItem.h"

@class SCHContentProfileItem;
@class SCHOrderItem;
@class SCHBookIdentifier;

// Constants
extern NSString * const kSCHUserContentItem;

extern NSString * const kSCHUserContentItemFetchWithContentIdentifier;
extern NSString * const kSCHUserContentItemCONTENT_IDENTIFIER;
extern NSString * const kSCHUserContentItemDRM_QUALIFIER;

@interface SCHUserContentItem :  SCHSyncEntity <SCHISBNItem>
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
@property (nonatomic, retain) NSNumber * FreeBook;
// The assumption is that we will never use LastVersion instead we use Versoin
// LD added LastVersion, swapped what used to be in Version into LastVersion, 
// and made Version correct from that point forward
@property (nonatomic, retain) NSString * LastVersion;
@property (nonatomic, retain) NSNumber * AverageRating;

@property (nonatomic, readonly) NSSet *ContentMetadataItem;
@property (nonatomic, readonly) NSSet *AssignedProfileList;

- (SCHBookIdentifier *)bookIdentifier;

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

