//
//  SCHAnnotationsList.h
//  Scholastic
//
//  Created by John S. Eddie on 02/02/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import <CoreData/CoreData.h>

@class SCHAnnotationsContentItem;
@class SCHListProfileContentAnnotations;

@interface SCHAnnotationsList :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * ProfileID;
@property (nonatomic, retain) NSSet* AnnotationContentItem;
@property (nonatomic, retain) SCHListProfileContentAnnotations * ListProfileContentAnnotations;

@end


@interface SCHAnnotationsList (CoreDataGeneratedAccessors)
- (void)addAnnotationContentItemObject:(SCHAnnotationsContentItem *)value;
- (void)removeAnnotationContentItemObject:(SCHAnnotationsContentItem *)value;
- (void)addAnnotationContentItem:(NSSet *)value;
- (void)removeAnnotationContentItem:(NSSet *)value;

@end

