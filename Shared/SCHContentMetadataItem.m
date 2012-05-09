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

@interface SCHContentMetadataItem (CoreDataGeneratedPrimitiveAccessors)

- (NSString *)primitiveFormatTitleString;
- (void)setPrimitiveFormatTitleString:(NSString *)newFormatTitleString;
- (NSString *)primitiveFormatAuthorString;
- (void)setPrimitiveFormatAuthorString:(NSString *)newFormatAuthorString;

@end

@interface SCHContentMetadataItem ()

- (NSString *)formatSingleAuthor:(NSString *)author;

@end

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
@dynamic FormatAuthorString;
@dynamic formatTitleString;
@dynamic AverageRating;

- (NSSet *)AnnotationsContentItem
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSError *error = nil;
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:kSCHAnnotationsContentItem 
                                        inManagedObjectContext:self.managedObjectContext]];	
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"ContentIdentifier == %@ AND DRMQualifier == %@", 
                                self.ContentIdentifier, self.DRMQualifier]];
    
    NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest 
                                                               error:&error];
    [fetchRequest release], fetchRequest = nil;
    if (result == nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }

    return((result == nil ? [NSSet set] : [NSSet setWithArray:result]));
}

- (SCHUserContentItem *)UserContentItem
{
    SCHUserContentItem *ret = nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSError *error = nil;
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:kSCHUserContentItem
                                        inManagedObjectContext:self.managedObjectContext]];	
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"ContentIdentifier == %@ AND DRMQualifier == %@", 
                                self.ContentIdentifier, self.DRMQualifier]];

    
    NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest 
                                                               error:&error];
    [fetchRequest release], fetchRequest = nil;
    if (result == nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }

    // there should only ever be a single matching user content item
    if ([result count] > 0) {
        ret = [result objectAtIndex:0];
    }

    return(ret);
}

- (NSComparisonResult)titleCompare:(SCHContentMetadataItem *)contentMetadataItem
{
    NSComparisonResult ret;
    
    if (self.Title == nil || 
        [[self.Title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] < 1) {
        ret = NSOrderedDescending;
    } else if (contentMetadataItem.Title == nil || 
               [[contentMetadataItem.Title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] < 1) {
        ret = NSOrderedAscending;
    } else {
        ret = [self.FormatTitleString compare:contentMetadataItem.FormatTitleString];
    }
    
    return ret;
}

- (NSString *)FormatTitleString
{
    [self willAccessValueForKey:@"formatTitleString"];
    NSString *formatTitleString = [self primitiveFormatTitleString];
    [self didAccessValueForKey:@"formatTitleString"];
    if (formatTitleString == nil)
    {
        NSString *title = self.Title;
        NSRange range;

        if (title == nil ||
            [[title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] < 1) {
            return title;
        } 

        range = [title rangeOfString:@"The " options:NSCaseInsensitiveSearch|NSAnchoredSearch];
        if (range.location != NSNotFound) {
            formatTitleString = [title substringFromIndex:range.length];           
        } else {
            range = [title rangeOfString:@"An " options:NSCaseInsensitiveSearch|NSAnchoredSearch];        
            if (range.location != NSNotFound) {
                formatTitleString = [title substringFromIndex:range.length];           
            } else {
                range = [title rangeOfString:@"A " options:NSCaseInsensitiveSearch|NSAnchoredSearch];        
                if (range.location != NSNotFound) {
                    formatTitleString = [title substringFromIndex:range.length];           
                }
            }
        }
        if (formatTitleString == nil) {
            formatTitleString = title;
        }
        
        NSLog(@"%@", formatTitleString);
        [self setPrimitiveFormatTitleString:formatTitleString];
    }
    
    return formatTitleString;
}
        
- (NSComparisonResult)authorCompare:(SCHContentMetadataItem *)contentMetadataItem
{
    NSComparisonResult ret;
    
    if (self.Author == nil || 
        [[self.Author stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] < 1) {
        ret = NSOrderedDescending;
    } else if (contentMetadataItem.Author == nil || 
               [[contentMetadataItem.Author stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] < 1) {
        ret = NSOrderedAscending;
    } else {
        ret = [self.FormatAuthorString compare:contentMetadataItem.FormatAuthorString];
    }
    
    return ret;
}

- (NSString *)FormatAuthorString
{
    [self willAccessValueForKey:@"FormatAuthorString"];
    NSString *formatAuthorString = [self primitiveFormatAuthorString];
    [self didAccessValueForKey:@"FormatAuthorString"];
    if (formatAuthorString == nil)
    {
        NSString *author = self.Author;
        NSMutableString *builder = [NSMutableString stringWithCapacity:[author length]];
        
        if (author == nil ||
            [[author stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] < 1) {
            return author;
        } 
        
        NSMutableArray *authors = [NSMutableArray array];
        [[author componentsSeparatedByString:@"&"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([[obj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
                [authors addObject:obj];
            }
        }];
        for (int i = 0; i < [authors count]; i++) {
            [builder appendString:[self formatSingleAuthor:[authors objectAtIndex:i]]];
            if (i + 1 < [authors count]) {
                [builder appendString:@"; "];
            }             
        }

        formatAuthorString = [NSString stringWithString:builder];
        NSLog(@"%@", formatAuthorString);
        [self setPrimitiveFormatAuthorString:formatAuthorString];
    }

    return formatAuthorString;
}

- (NSString *)formatSingleAuthor:(NSString *)author
{
    NSMutableString *builder = [NSMutableString stringWithCapacity:[author length]];
    NSRange notFoundRange = NSMakeRange(NSNotFound, 0);
    
    if (author != nil && 
        [[author stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
        
        //2-9-2011, rferris. Noted that some Scholastic books were coming in as:
        //      "by True Kelley, illustrated by True Kelley"
        if ([[author lowercaseString] hasPrefix:@"by "] == YES) {
            author = [author substringFromIndex:3];
        }
        
        NSMutableArray *names = [NSMutableArray array];
        [[author componentsSeparatedByString:@" "] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([[obj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
                [names addObject:obj];
            }
        }];
        
        //2-9-2011 rferris #2
        NSRange firstComma = [author rangeOfString:@","];
        if (NSEqualRanges(firstComma, notFoundRange) == NO && 
            [names count] > 3) {
            author = [author substringToIndex:firstComma.location];
            names = [NSMutableArray array];
            [[author componentsSeparatedByString:@" "] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([[obj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
                    [names addObject:obj];
                }
            }];
        }
        
        // TODO If the author's name contains a comma and three or fewer words, we assume it's already last name first.
        // This doesn't handle cases in which the author's name has more than 3 parts (a middle name and a suffix, for example)
        // because we can't differentiate between that and two authors (eg: "John Doe, Jill Doe")
        firstComma = [author rangeOfString:@","];
        if (NSEqualRanges(firstComma, notFoundRange) == NO &&
            [names count] < 4) {
            return author;
        }
        
        if ([names count] >= 2 && [names count] < 4) {
            [builder appendString:[names lastObject]];
            [builder appendString:@", "];
            
            for (int i = 0; i < [names count] - 1; i++) {
                [builder appendString:[names objectAtIndex:i]];
                
                if (i + 1 < [names count] - 1) {
                    [builder appendString:@" "];
                }
            }
        }
        else {
            return author;
        }
    }
    
    return [NSString stringWithString:builder];    
}
             
- (NSArray *)annotationsContentForProfile:(NSNumber *)profileID
{
	NSMutableArray *annotations = [NSMutableArray array];
	
	for (SCHAnnotationsContentItem *annotationsContentItem in [self AnnotationsContentItem]) {
        NSNumber *annotationsItemProfileID = [annotationsContentItem valueForKeyPath:kSCHContentMetadataItemAnnotationsItemProfileID];
		if (annotationsItemProfileID != nil && [profileID isEqualToNumber:annotationsItemProfileID] == YES) {
			[annotations addObject:annotationsContentItem];
		}
	}
	
	return(annotations);	
}

- (void)prepareForDeletion
{
    [super prepareForDeletion];
    [[SCHProcessingManager sharedProcessingManager] cancelAllOperationsForBookIdentifier:self.bookIdentifier
                                                                       waitUntilFinished:NO];
    [[SCHBookManager sharedBookManager] removeBookIdentifierFromCache:self.bookIdentifier];    
    [self deleteAllFiles];
}

- (void)deleteAllFiles
{    
    NSString *bookDirectory = self.AppBook.bookDirectory;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{        
        [[SCHProcessingManager sharedProcessingManager] cancelAllOperationsForBookIdentifier:self.bookIdentifier 
                                                                           waitUntilFinished:YES];
        NSError *error = nil;
        NSFileManager *localManager = [[[NSFileManager alloc] init] autorelease];
        if ([localManager removeItemAtPath:bookDirectory 
                                     error:&error] == NO) {
            NSLog(@"Failed to delete files for %@, error: %@", 
                  self.ContentIdentifier, [error localizedDescription]);
        }
    });
    
    [self.AppBook clearCachedBookDirectory];
}

- (void)deleteBookPackageFile
{
    NSError *error = nil;
    NSFileManager *localManager = [[[NSFileManager alloc] init] autorelease];
    
    if ([localManager removeItemAtPath:self.AppBook.bookPackagePath 
                                                   error:&error] == NO) {
        NSLog(@"Failed to delete XPS file for %@, error: %@", 
              self.ContentIdentifier, [error localizedDescription]);
    }
}

- (void)deleteCoverFile
{
    NSError *error = nil;
    NSFileManager *localManager = [[[NSFileManager alloc] init] autorelease];
    
    if ([localManager removeItemAtPath:self.AppBook.coverImagePath 
                                 error:&error] == NO) {
        NSLog(@"Failed to delete cover file for %@, error: %@", 
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
