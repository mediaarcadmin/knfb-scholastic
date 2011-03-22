// 
//  SCHUserContentItem.m
//  Scholastic
//
//  Created by John S. Eddie on 31/01/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import "SCHUserContentItem.h"

#import "SCHContentProfileItem.h"
#import "SCHOrderItem.h"

@implementation SCHUserContentItem 

@dynamic Format;
@dynamic Version;
@dynamic ContentIdentifier;
@dynamic ContentIdentifierType;
@dynamic DefaultAssignment;
@dynamic DRMQualifier;
@dynamic OrderList;
@dynamic ProfileList;

- (NSSet *)AssignedProfileList
{
	return(self.ProfileList);
}

#pragma -
#pragma Core Data Generated Accessors

- (void)addOrderListObject:(SCHOrderItem *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"OrderList" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"OrderList"] addObject:value];
    [self didChangeValueForKey:@"OrderList" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeOrderListObject:(SCHOrderItem *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"OrderList" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"OrderList"] removeObject:value];
    [self didChangeValueForKey:@"OrderList" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addOrderList:(NSSet *)value {    
    [self willChangeValueForKey:@"OrderList" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"OrderList"] unionSet:value];
    [self didChangeValueForKey:@"OrderList" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeOrderList:(NSSet *)value {
    [self willChangeValueForKey:@"OrderList" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"OrderList"] minusSet:value];
    [self didChangeValueForKey:@"OrderList" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}

- (void)addProfileListObject:(SCHContentProfileItem *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"ProfileList" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"ProfileList"] addObject:value];
    [self didChangeValueForKey:@"ProfileList" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeProfileListObject:(SCHContentProfileItem *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"ProfileList" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"ProfileList"] removeObject:value];
    [self didChangeValueForKey:@"ProfileList" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addProfileList:(NSSet *)value {    
    [self willChangeValueForKey:@"ProfileList" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"ProfileList"] unionSet:value];
    [self didChangeValueForKey:@"ProfileList" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeProfileList:(NSSet *)value {
    [self willChangeValueForKey:@"ProfileList" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"ProfileList"] minusSet:value];
    [self didChangeValueForKey:@"ProfileList" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}

@end
