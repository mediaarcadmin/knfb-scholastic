//
//  SCHAnnotationsItem.h
//  Scholastic
//
//  Created by John S. Eddie on 02/02/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import <CoreData/CoreData.h>

@class SCHAnnotationsContentItem;

static NSString * const kSCHAnnotationsItem = @"SCHAnnotationsItem";

static NSString * const kSCHAnnotationsItemfetchAnnotationItemForProfile = @"fetchAnnotationItemForProfile";
static NSString * const kSCHAnnotationsItemPROFILE_ID = @"PROFILE_ID";

@interface SCHAnnotationsItem :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * ProfileID;
@property (nonatomic, retain) NSSet* AnnotationsContentItem;

@end

@interface SCHAnnotationsItem (CoreDataGeneratedAccessors)

- (void)addAnnotationsContentItemObject:(SCHAnnotationsContentItem *)value;
- (void)removeAnnotationsContentItemObject:(SCHAnnotationsContentItem *)value;
- (void)addAnnotationsContentItem:(NSSet *)value;
- (void)removeAnnotationsContentItem:(NSSet *)value;

@end
