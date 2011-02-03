//
//  SCHListProfileContentAnnotations.h
//  Scholastic
//
//  Created by John S. Eddie on 02/02/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import <CoreData/CoreData.h>

@class SCHAnnotationsList;
@class SCHItemsCount;

@interface SCHListProfileContentAnnotations :  NSManagedObject  
{
}

@property (nonatomic, retain) NSSet* AnnotationsList;
@property (nonatomic, retain) SCHItemsCount * ItemsCount;

@end


@interface SCHListProfileContentAnnotations (CoreDataGeneratedAccessors)
- (void)addAnnotationsListObject:(SCHAnnotationsList *)value;
- (void)removeAnnotationsListObject:(SCHAnnotationsList *)value;
- (void)addAnnotationsList:(NSSet *)value;
- (void)removeAnnotationsList:(NSSet *)value;

@end

