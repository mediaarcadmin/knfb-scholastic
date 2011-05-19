//
//  SCHContentMetadataItem.m
//  Scholastic
//
//  Created by John S. Eddie on 18/03/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import "SCHContentMetadataItem.h"
#import "SCHAppBook.h"
#import "SCHeReaderCategories.h"
#import "SCHAnnotationsContentItem.h"
#import "SCHUserContentItem.h"

static NSString * const kSCHContentMetadataItemAnnotationsContentItem = @"AnnotationsContentItem";
static NSString * const kSCHContentMetadataItemAnnotationsListProfileID = @"AnnotationsList.ProfileID";
static NSString * const kSCHContentMetadataItemUserContentItem = @"UserContentItem";

@implementation SCHContentMetadataItem

@dynamic Author;
@dynamic Description;
@dynamic Version;
@dynamic ContentURL;
@dynamic CoverURL;
@dynamic Enhanced;
@dynamic Title;
@dynamic FileSize;
@dynamic PageNumber;
@dynamic FileName;
@dynamic AppBook;
@dynamic eReaderCategories;

@dynamic userContentItem;

- (NSArray *)annotationsContentForProfile:(NSNumber *)profileID
{
	NSMutableArray *annotations = [NSMutableArray array];
	
	for (SCHAnnotationsContentItem *annotationsContentItem in [self valueForKey:kSCHContentMetadataItemAnnotationsContentItem]) {
		if ([profileID isEqualToNumber:[annotationsContentItem valueForKeyPath:kSCHContentMetadataItemAnnotationsListProfileID]] == YES) {
			[annotations addObject:annotationsContentItem];
		}
	}
	
	return(annotations);	
}

- (SCHUserContentItem *)userContentItem
{
    SCHUserContentItem *ret = nil;
    
    // there should only ever be a single matching user content item
    NSArray *userContentItems = [self valueForKey:kSCHContentMetadataItemUserContentItem];
    if ([userContentItems count] > 0) {
        ret = [userContentItems objectAtIndex:0];
    }
    
    return(ret);
}

#pragma mark - Core Data Generated Accessors

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

@end
