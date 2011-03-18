//
//  SCHProfileItem.m
//  Scholastic
//
//  Created by John S. Eddie on 18/03/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import "SCHProfileItem.h"
#import "SCHAppBookOrder.h"


@implementation SCHProfileItem
@dynamic StoryInteractionEnabled;
@dynamic ID;
@dynamic LastPasswordModified;
@dynamic Password;
@dynamic Birthday;
@dynamic FirstName;
@dynamic ProfilePasswordRequired;
@dynamic ScreenName;
@dynamic Type;
@dynamic LastScreenNameModified;
@dynamic AutoAssignContentToProfiles;
@dynamic UserKey;
@dynamic BookshelfStyle;
@dynamic LastName;
@dynamic AppBookOrder;

- (void)addAppBookOrderObject:(SCHAppBookOrder *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"AppBookOrder" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"AppBookOrder"] addObject:value];
    [self didChangeValueForKey:@"AppBookOrder" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeAppBookOrderObject:(SCHAppBookOrder *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"AppBookOrder" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"AppBookOrder"] removeObject:value];
    [self didChangeValueForKey:@"AppBookOrder" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addAppBookOrder:(NSSet *)value {    
    [self willChangeValueForKey:@"AppBookOrder" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"AppBookOrder"] unionSet:value];
    [self didChangeValueForKey:@"AppBookOrder" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeAppBookOrder:(NSSet *)value {
    [self willChangeValueForKey:@"AppBookOrder" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"AppBookOrder"] minusSet:value];
    [self didChangeValueForKey:@"AppBookOrder" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


@end
