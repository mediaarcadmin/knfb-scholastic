//
//  SCHListProfileContentAnnotations.h
//  Scholastic
//
//  Created by John S. Eddie on 31/01/2011.
//  Copyright 2011 Zicron Software Limited. All rights reserved.
//

#import <CoreData/CoreData.h>

@class SCHAnnotationsItem;

@interface SCHListProfileContentAnnotations :  NSManagedObject  
{
}

@property (nonatomic, retain) NSSet* AnnotationsItem;
@property (nonatomic, retain) NSManagedObject * ItemsCount;

@end


@interface SCHListProfileContentAnnotations (CoreDataGeneratedAccessors)
- (void)addAnnotationsItemObject:(SCHAnnotationsItem *)value;
- (void)removeAnnotationsItemObject:(SCHAnnotationsItem *)value;
- (void)addAnnotationsItem:(NSSet *)value;
- (void)removeAnnotationsItem:(NSSet *)value;

@end

