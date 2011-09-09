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
#import "SCHBookManager.h"
#import "SCHBookIdentifier.h"
#import "SCHProcessingManager.h"

// Constants
NSString * const kSCHContentMetadataItem = @"SCHContentMetadataItem";

static NSString * const kSCHContentMetadataItemAnnotationsItemProfileID = @"AnnotationsItem.ProfileID";

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

- (NSSet *)AnnotationsContentItem
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:kSCHAnnotationsContentItem 
                                        inManagedObjectContext:self.managedObjectContext]];	
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"ContentIdentifier == %@ AND DRMQualifier == %@", 
                                self.ContentIdentifier, self.DRMQualifier]];
    
    NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest 
                                                               error:nil];
    [fetchRequest release], fetchRequest = nil;
    
    return((result == nil ? [NSSet set] : [NSSet setWithArray:result]));
}

- (SCHUserContentItem *)UserContentItem
{
    SCHUserContentItem *ret = nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:kSCHUserContentItem
                                        inManagedObjectContext:self.managedObjectContext]];	
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"ContentIdentifier == %@ AND DRMQualifier == %@", 
                                self.ContentIdentifier, self.DRMQualifier]];

    
    NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest 
                                                               error:nil];
    [fetchRequest release], fetchRequest = nil;

    // there should only ever be a single matching user content item
    if ([result count] > 0) {
        ret = [result objectAtIndex:0];
    }

    return(ret);
}

- (NSArray *)annotationsContentForProfile:(NSNumber *)profileID
{
	NSMutableArray *annotations = [NSMutableArray array];
	
	for (SCHAnnotationsContentItem *annotationsContentItem in [self AnnotationsContentItem]) {
		if ([profileID isEqualToNumber:[annotationsContentItem valueForKeyPath:kSCHContentMetadataItemAnnotationsItemProfileID]] == YES) {
			[annotations addObject:annotationsContentItem];
		}
	}
	
	return(annotations);	
}

- (void)prepareForDeletion
{
    [super prepareForDeletion];
    [[SCHProcessingManager sharedProcessingManager] cancelAllOperationsForBookIndentifier:self.bookIdentifier];
    [[SCHBookManager sharedBookManager] removeBookIdentifierFromCache:self.bookIdentifier];    
    [self deleteAllFiles];
}

- (void)deleteAllFiles
{
    NSError *error = nil;
    
    if ([[NSFileManager defaultManager] removeItemAtPath:self.AppBook.bookDirectory 
                                                   error:&error] == NO) {
        NSLog(@"Failed to delete files for %@, error: %@", 
              self.ContentIdentifier, [error localizedDescription]);
    }
}

- (void)deleteXPSFile
{
    NSError *error = nil;
    
    if ([[NSFileManager defaultManager] removeItemAtPath:self.AppBook.xpsPath 
                                                   error:&error] == NO) {
        NSLog(@"Failed to delete XPS file for %@, error: %@", 
              self.ContentIdentifier, [error localizedDescription]);
    }
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
