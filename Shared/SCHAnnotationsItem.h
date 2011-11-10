//
//  SCHAnnotationsItem.h
//  Scholastic
//
//  Created by John S. Eddie on 02/02/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import <CoreData/CoreData.h>

@class SCHAnnotationsContentItem;
@class SCHProfileItem;

// Constants
extern NSString * const kSCHAnnotationsItem;

extern NSString * const kSCHAnnotationsItemfetchAnnotationItemForProfile;
extern NSString * const kSCHAnnotationsItemPROFILE_ID;

@interface SCHAnnotationsItem :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * ProfileID;
@property (nonatomic, retain) NSSet* AnnotationsContentItem;

- (SCHProfileItem *)profileItem;

@end

@interface SCHAnnotationsItem (CoreDataGeneratedAccessors)

- (void)addAnnotationsContentItemObject:(SCHAnnotationsContentItem *)value;
- (void)removeAnnotationsContentItemObject:(SCHAnnotationsContentItem *)value;
- (void)addAnnotationsContentItem:(NSSet *)value;
- (void)removeAnnotationsContentItem:(NSSet *)value;

@end
