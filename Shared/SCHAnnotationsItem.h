//
//  SCHAnnotationsItem.h
//  Scholastic
//
//  Created by John S. Eddie on 31/01/2011.
//  Copyright 2011 Zicron Software Limited. All rights reserved.
//

#import <CoreData/CoreData.h>

@class SCHAnnotationsContentItem;
@class SCHListProfileContentAnnotations;

@interface SCHAnnotationsItem :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * ProfileID;
@property (nonatomic, retain) SCHListProfileContentAnnotations * ListProfileContentAnnotations;
@property (nonatomic, retain) NSSet* AnnotationsContentItem;

@end


@interface SCHAnnotationsItem (CoreDataGeneratedAccessors)
- (void)addAnnotationsContentItemObject:(SCHAnnotationsContentItem *)value;
- (void)removeAnnotationsContentItemObject:(SCHAnnotationsContentItem *)value;
- (void)addAnnotationsContentItem:(NSSet *)value;
- (void)removeAnnotationsContentItem:(NSSet *)value;

@end

