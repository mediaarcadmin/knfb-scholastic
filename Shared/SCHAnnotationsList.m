// 
//  SCHAnnotationsList.m
//  Scholastic
//
//  Created by John S. Eddie on 02/02/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import "SCHAnnotationsList.h"

#import "SCHAnnotationsContentItem.h"
#import "SCHListProfileContentAnnotations.h"

@implementation SCHAnnotationsList 

@dynamic ProfileID;
@dynamic AnnotationContentItem;
@dynamic ListProfileContentAnnotations;

#pragma -
#pragma Core Data Generated Accessors

- (void)addAnnotationContentItemObject:(SCHAnnotationsContentItem *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"AnnotationContentItem" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"AnnotationContentItem"] addObject:value];
    [self didChangeValueForKey:@"AnnotationContentItem" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeAnnotationContentItemObject:(SCHAnnotationsContentItem *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"AnnotationContentItem" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"AnnotationContentItem"] removeObject:value];
    [self didChangeValueForKey:@"AnnotationContentItem" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addAnnotationContentItem:(NSSet *)value {    
    [self willChangeValueForKey:@"AnnotationContentItem" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"AnnotationContentItem"] unionSet:value];
    [self didChangeValueForKey:@"AnnotationContentItem" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeAnnotationContentItem:(NSSet *)value {
    [self willChangeValueForKey:@"AnnotationContentItem" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"AnnotationContentItem"] minusSet:value];
    [self didChangeValueForKey:@"AnnotationContentItem" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}

@end
