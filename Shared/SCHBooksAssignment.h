//
//  SCHBooksAssignment.h
//  Scholastic
//
//  Created by John S. Eddie on 02/08/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SCHContentItem.h"

#import "SCHISBNItem.h"

@class SCHContentProfileItem;

// Constants
extern NSString * const kSCHBooksAssignment;

@interface SCHBooksAssignment : SCHContentItem <SCHISBNItem>

@property (nonatomic, retain) NSNumber * averageRating;
@property (nonatomic, retain) NSNumber * defaultAssignment;
@property (nonatomic, retain) NSString * format;
@property (nonatomic, retain) NSNumber * freeBook;
@property (nonatomic, retain) NSDate * lastOrderDate;
// The assumption is that we will never use LastVersion instead we use Versoin
// LD added LastVersion, swapped what used to be in Version into LastVersion,
// and made Version correct from that point forward
@property (nonatomic, retain) NSNumber * lastVersion;
@property (nonatomic, retain) NSNumber * quantity;
@property (nonatomic, retain) NSNumber * quantityInit;
@property (nonatomic, retain) NSNumber * version;
@property (nonatomic, retain) NSSet *profileList;

@property (nonatomic, readonly) NSSet *ContentMetadataItem;
//@property (nonatomic, readonly) NSSet *AssignedProfileList;

@end

@interface SCHBooksAssignment (CoreDataGeneratedAccessors)

- (void)addProfileListObject:(SCHContentProfileItem *)value;
- (void)removeProfileListObject:(SCHContentProfileItem *)value;
- (void)addProfileList:(NSSet *)values;
- (void)removeProfileList:(NSSet *)values;

@end
