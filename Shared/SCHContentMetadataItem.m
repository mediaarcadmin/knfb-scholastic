//
//  SCHContentMetadataItem.m
//  Scholastic
//
//  Created by John S. Eddie on 15/03/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import "SCHContentMetadataItem.h"
#import "SCHAppBook.h"
#import "SCHAppBookOrder.h"
#import "SCHeReaderCategories.h"


@implementation SCHContentMetadataItem
@dynamic Author;
@dynamic Description;
@dynamic Version;
@dynamic Enhanced;
@dynamic ContentURL;
@dynamic CoverURL;
@dynamic Title;
@dynamic FileSize;
@dynamic PageNumber;
@dynamic FileName;
@dynamic AppBook;
@dynamic eReaderCategories;
@dynamic AppBookOrder;


- (void)addEReaderCategoriesObject:(SCHeReaderCategories *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"eReaderCategories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"eReaderCategories"] addObject:value];
    [self didChangeValueForKey:@"eReaderCategories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeEReaderCategoriesObject:(SCHeReaderCategories *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"eReaderCategories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"eReaderCategories"] removeObject:value];
    [self didChangeValueForKey:@"eReaderCategories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addEReaderCategories:(NSSet *)value {    
    [self willChangeValueForKey:@"eReaderCategories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"eReaderCategories"] unionSet:value];
    [self didChangeValueForKey:@"eReaderCategories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeEReaderCategories:(NSSet *)value {
    [self willChangeValueForKey:@"eReaderCategories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"eReaderCategories"] minusSet:value];
    [self didChangeValueForKey:@"eReaderCategories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


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
