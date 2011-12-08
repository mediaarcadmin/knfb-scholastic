//
//  SCHProfileItem.m
//  Scholastic
//
//  Created by John S. Eddie on 18/03/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import "SCHProfileItem.h"
#import "SCHAppContentProfileItem.h"
#import "SCHAppProfile.h"

#import <CommonCrypto/CommonDigest.h>

#import "SCHContentProfileItem.h"
#import "SCHContentMetadataItem.h"
#import "SCHUserContentItem.h"
#import "SCHBookManager.h"
#import "USAdditions.h"
#import "SCHLibreAccessConstants.h"
#import "SCHAppBook.h"
#import "SCHPrivateAnnotations.h"
#import "SCHBookAnnotations.h"
#import "SCHAnnotationsContentItem.h"
#import "SCHOrderItem.h"
#import "SCHLastPage.h"
#import "SCHBookIdentifier.h"
#import "SCHBookStatistics.h"
#import "SCHReadingStatsDetailItem.h"
#import "SCHReadingStatsContentItem.h"
#import "SCHReadingStatsEntryItem.h"
#import "SCHBookshelfSyncComponent.h"
#import "SCHAnnotationsItem.h"

// Constants
NSString * const kSCHProfileItem = @"SCHProfileItem";

NSString * const kSCHProfileItemFetchAnnotationsForProfileBook = @"fetchAnnotationsForProfileBook";
NSString * const kSCHProfileItemPROFILE_ID = @"PROFILE_ID";
NSString * const kSCHProfileItemCONTENT_IDENTIFIER = @"CONTENT_IDENTIFIER";
NSString * const kSCHProfileItemDRM_QUALIFIER = @"DRM_QUALIFIER";

@interface SCHProfileItem ()

- (void)deleteAnnotations;
- (void)deleteStatistics;
- (SCHReadingStatsContentItem *)makeReadingStatsContentItemForBook:(SCHBookIdentifier *)bookIdentifier;
- (NSString *)MD5:(NSString *)string;
- (NSString *)SHA1:(NSString *)string;

@end

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
@dynamic AppProfile;
@dynamic AppContentProfileItem;

@synthesize age;

- (NSSet *)ContentProfileItem
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSError *error = nil; 
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:kSCHContentProfileItem 
                                        inManagedObjectContext:self.managedObjectContext]];	
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"ProfileID == %@", self.ID]];
    
    NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest 
                                                               error:&error];
    [fetchRequest release], fetchRequest = nil;
    if (result == nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }

    return (result == nil ? [NSSet set] : [NSSet setWithArray:result]);
}

- (SCHAppContentProfileItem *)appContentProfileItemForBookIdentifier:(SCHBookIdentifier *)bookIdentifier
{
    SCHAppContentProfileItem *ret = nil;
    
    for (SCHAppContentProfileItem *appContentProfileItem in self.AppContentProfileItem) {
        if ([appContentProfileItem.bookIdentifier isEqual:bookIdentifier] == YES) {
            ret = appContentProfileItem;
            break;
        }
    }
    
    return ret;
}

- (void)prepareForDeletion
{
    [super prepareForDeletion];
    
    [self deleteStatistics];    
    [self deleteAnnotations];
}

- (void)deleteAnnotations
{
    if (self.ID != nil) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init]; 
        NSError *error = nil;
        [fetchRequest setEntity:[NSEntityDescription entityForName:kSCHAnnotationsItem 
                                            inManagedObjectContext:self.managedObjectContext]];	                                                                            
        [fetchRequest setPredicate:
         [NSPredicate predicateWithFormat:@"ProfileID == %@", self.ID]];    
        
        NSArray *profiles = [self.managedObjectContext executeFetchRequest:fetchRequest 
                                                                  error:&error];
        [fetchRequest release], fetchRequest = nil;
        if (profiles == nil) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }

        if ([profiles count] > 0) {
            [self.managedObjectContext deleteObject:[profiles objectAtIndex:0]];
        }
    }    
}

- (void)deleteStatistics
{
    if (self.ID != nil) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init]; 
        NSError *error = nil;
        [fetchRequest setEntity:[NSEntityDescription entityForName:kSCHReadingStatsDetailItem 
                                            inManagedObjectContext:self.managedObjectContext]];	                                                                            
        [fetchRequest setPredicate:
         [NSPredicate predicateWithFormat:@"ProfileID == %@", self.ID]];    
        
        NSArray *profiles = [self.managedObjectContext executeFetchRequest:fetchRequest 
                                                                  error:&error];
        [fetchRequest release], fetchRequest = nil;
        if (profiles == nil) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
        
        if ([profiles count] > 0) {
            [self.managedObjectContext deleteObject:[profiles objectAtIndex:0]];
        }
    }
}

#pragma mark - methods

// all book identifiers for the profile
- (NSMutableArray *)bookIdentifiersAssignedToProfile
{
    NSSet *contentProfileItem = [self ContentProfileItem];
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:[contentProfileItem count]];
                           
    for(SCHContentProfileItem *item in contentProfileItem) {
        [ret addObject:item.UserContentItem.bookIdentifier];
    }
    
    return ret;
}

// all book identifiers available for use, i.e. we have the metadata information
- (NSMutableArray *)allBookIdentifiers
{
    NSNumber *sortTypeObj = [[self AppProfile] SortType];
    
    if (!sortTypeObj) {
        sortTypeObj = [NSNumber numberWithInt:kSCHBookSortTypeUser];
        [[self AppProfile] setSortType:sortTypeObj];
    }
    
    SCHBookSortType sortType = [sortTypeObj intValue];
    
    if (sortType == kSCHBookSortTypeUser) {
        
        NSMutableArray *books = [NSMutableArray array];
        
        for (SCHContentProfileItem *contentProfileItem in [self ContentProfileItem]) {
            for (SCHContentMetadataItem *contentMetadataItem in contentProfileItem.UserContentItem.ContentMetadataItem) {
                SCHBookIdentifier *identifier = [[SCHBookIdentifier alloc] initWithISBN:contentMetadataItem.ContentIdentifier
                                                                           DRMQualifier:contentMetadataItem.DRMQualifier];
                [books addObject:identifier];
                [identifier release];
            }
        }
        
        // order the books
        if ([self.AppContentProfileItem count] > 0) {
            NSArray *bookOrder = [self.AppContentProfileItem sortedArrayUsingDescriptors:
                                  [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:kSCHAppContentProfileItemOrder ascending:YES], 
                                   [NSSortDescriptor sortDescriptorWithKey:kSCHAppContentProfileItemISBN ascending:YES], 
                                   [NSSortDescriptor sortDescriptorWithKey:kSCHAppContentProfileItemDRMQualifier ascending:YES], nil]];
            for (int i = 0; i < [bookOrder count]; i++) {
                SCHAppContentProfileItem *appContentProfileItem = [bookOrder objectAtIndex:i];
                
                NSUInteger bookIndex = [books indexOfObjectPassingTest:^(id obj, NSUInteger idx, BOOL *stop) {
                    SCHBookIdentifier *identifier = (SCHBookIdentifier *)obj;
                    if ([appContentProfileItem.ISBN compare:identifier.isbn] == NSOrderedSame &&
                        [appContentProfileItem.DRMQualifier compare:identifier.DRMQualifier] == NSOrderedSame) {
                        *stop = YES;
                        return(YES);
                    } else {
                        return NO;
                    }
                }];
                
                if(bookIndex != NSNotFound) {
                    if ((i < [books count]) && (bookIndex < [books count])) {
                        [books exchangeObjectAtIndex:i withObjectAtIndex:bookIndex];
                    }
                }
            }
        }
        
        return(books);
    }

    NSMutableArray *books = [NSMutableArray array];
    NSMutableArray *bookObjects = [NSMutableArray array];
    
    for (SCHContentProfileItem *contentProfileItem in [self ContentProfileItem]) {
        for (SCHContentMetadataItem *contentMetadataItem in contentProfileItem.UserContentItem.ContentMetadataItem) {
            [bookObjects addObject:contentMetadataItem];
        }
    }

    switch (sortType) {
        case kSCHBookSortTypeTitle:
        {
            [bookObjects sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"Title" ascending:YES]]];
            break;
        }
        case kSCHBookSortTypeAuthor:
        {
            [bookObjects sortUsingSelector:@selector(compare:)];
            break;
        }
        case kSCHBookSortTypeNewest:
        {
            NSMutableArray *sortArray = [[NSMutableArray alloc] initWithCapacity:[books count]];
            NSEntityDescription *entityDescription = [NSEntityDescription 
                                                      entityForName:kSCHUserContentItem
                                                      inManagedObjectContext:self.managedObjectContext];

            for (SCHContentMetadataItem *book in bookObjects) {
                NSError *error = nil;
                NSFetchRequest *fetchRequest = [entityDescription.managedObjectModel
                                                fetchRequestFromTemplateWithName:kSCHUserContentItemFetchWithContentIdentifier
                                                substitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                       book.ContentIdentifier, kSCHUserContentItemCONTENT_IDENTIFIER,
                                                                       book.DRMQualifier, kSCHUserContentItemDRM_QUALIFIER,
                                                                       nil]];
                [fetchRequest setFetchLimit:1];
                
                NSArray *userContentItems = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];	
                if (userContentItems == nil) {
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                }
                
                NSDate *date = [NSDate distantPast];
                if (userContentItems != nil && [userContentItems count] > 0) {
                    NSSet *orderItems = [[userContentItems objectAtIndex:0] OrderList];
                    if ([orderItems count] > 0) {
                        // use the latest date
                        NSArray *sortedOrderItems = [[orderItems allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"OrderDate" ascending:NO]]];
                        SCHOrderItem *orderItem = [sortedOrderItems objectAtIndex:0];
                        date = [orderItem OrderDate];
                    }
                }
                SCHProfileItemSortObject *sortObj = [[SCHProfileItemSortObject alloc] init];
                sortObj.date = date;
                sortObj.item = book;
                
                [sortArray addObject:sortObj];
                [sortObj release];
            }
            
            [sortArray sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]]];
            
            [bookObjects removeAllObjects];
            
            for (SCHProfileItemSortObject *sortObj in sortArray) {
                [bookObjects addObject:sortObj.item];
            }
            
            [sortArray release];

            break;
        }
        case kSCHBookSortTypeLastRead:
        {
            NSLog(@"Sort by last read.");
            NSMutableArray *sortArray = [[NSMutableArray alloc] initWithCapacity:[books count]];

            for (SCHContentMetadataItem *item in bookObjects) {
                SCHPrivateAnnotations *privAnnotations = [(SCHAnnotationsContentItem *)[[item annotationsContentForProfile:self.ID] objectAtIndex:0] PrivateAnnotations];
                SCHAppContentProfileItem *appContentProfileItem = [self appContentProfileItemForBookIdentifier:item.bookIdentifier];
                SCHContentProfileItem *contentProfileItem = appContentProfileItem.ContentProfileItem;
                
                SCHProfileItemSortObject *sortObj = [[SCHProfileItemSortObject alloc] init];
                // If we havnt yet received the annotations from the sync then use the contentprofileitem
                // lastModified date, see SCHReadingView:lastPageLocation where we do the same for the last page
                if ([[contentProfileItem LastModified] compare:privAnnotations.LastPage.LastModified] == NSOrderedDescending) {
                    sortObj.date = [contentProfileItem LastModified];
                } else {
                    sortObj.date = privAnnotations.LastPage.LastModified;
                }
                sortObj.item = item;
                sortObj.isNewBook = [appContentProfileItem.IsNewBook boolValue];
                
                [sortArray addObject:sortObj];
                [sortObj release];

            }
            
            [sortArray sortUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"isNewBook" ascending:YES], 
                                             [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO], nil]];

            [bookObjects removeAllObjects];
            
            for (SCHProfileItemSortObject *sortObj in sortArray) {
                [bookObjects addObject:sortObj.item];
            }
            
            [sortArray release];

            
            break;
        }
        default:
            break;
    }
    
    // build the ISBN list
    for (SCHContentMetadataItem *item in bookObjects) {
        SCHBookIdentifier *identifier = [[SCHBookIdentifier alloc] initWithISBN:item.ContentIdentifier
                                                                   DRMQualifier:item.DRMQualifier];
        [books addObject:identifier];
        [identifier release];
    }
    
    return books;
    
}

- (SCHBookAnnotations *)annotationsForBook:(SCHBookIdentifier *)bookIdentifier
{
    SCHBookAnnotations *ret = nil;
    NSError *error = nil;
    
    if (bookIdentifier != nil) {
        NSEntityDescription *entityDescription = [NSEntityDescription 
                                                  entityForName:kSCHPrivateAnnotations 
                                                  inManagedObjectContext:self.managedObjectContext];
        NSFetchRequest *fetchRequest = [entityDescription.managedObjectModel fetchRequestFromTemplateWithName:kSCHProfileItemFetchAnnotationsForProfileBook 
                                                                                        substitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                                                               self.ID, kSCHProfileItemPROFILE_ID, bookIdentifier.isbn, 
                                                                                                               kSCHProfileItemCONTENT_IDENTIFIER, bookIdentifier.DRMQualifier, 
                                                                                                               kSCHProfileItemDRM_QUALIFIER, nil]];
        
        NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (results == nil) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }

        if ([results count] > 0) {
            ret = [[[SCHBookAnnotations alloc] initWithPrivateAnnotations:[results objectAtIndex:0]] autorelease];
        }    
    }
    
    return(ret);
}

- (void)newStatistics:(SCHBookStatistics *)bookStatistics forBook:(SCHBookIdentifier *)bookIdentifier
{
    SCHReadingStatsDetailItem *readingStatsDetailItem = nil;
    SCHReadingStatsContentItem *readingStatsContentItem = nil;
    SCHReadingStatsEntryItem *readingStatsEntryItem = nil;
    NSError *error = nil;
    
    if (bookStatistics != nil && [bookStatistics hasStatistics] == YES && 
        bookIdentifier != nil) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        [fetchRequest setEntity:[NSEntityDescription entityForName:kSCHReadingStatsDetailItem 
                                            inManagedObjectContext:self.managedObjectContext]];	
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"ProfileID == %@", self.ID]];
        [fetchRequest setFetchLimit:1];
        
        NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest 
                                                                   error:&error];
        [fetchRequest release], fetchRequest = nil;
        if (result == nil) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
        
        if ([result count] > 0) {
            readingStatsDetailItem = [result objectAtIndex:0];
            for (SCHReadingStatsContentItem *contentItem in readingStatsDetailItem.ReadingStatsContentItem) {
                if ([[contentItem bookIdentifier] isEqual:bookIdentifier] == YES) {
                    readingStatsContentItem = contentItem;
                    break;
                }
            }            
        } else {
            readingStatsDetailItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHReadingStatsDetailItem 
                                                                   inManagedObjectContext:self.managedObjectContext];
            readingStatsDetailItem.ProfileID = self.ID;  
        } 
        
        if (readingStatsContentItem == nil) {
            readingStatsContentItem = [self makeReadingStatsContentItemForBook:bookIdentifier];   
            readingStatsContentItem.ReadingStatsDetailItem = readingStatsDetailItem;                
        }

        readingStatsEntryItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHReadingStatsEntryItem 
                                                              inManagedObjectContext:self.managedObjectContext];            
        readingStatsEntryItem.ReadingStatsContentItem = readingStatsContentItem;                            
        
        readingStatsEntryItem.ReadingDuration = [NSNumber numberWithUnsignedInteger:bookStatistics.readingDuration];
        readingStatsEntryItem.PagesRead = [NSNumber numberWithUnsignedInteger:bookStatistics.pagesRead];
        readingStatsEntryItem.StoryInteractions = [NSNumber numberWithUnsignedInteger:bookStatistics.storyInteractions];
        readingStatsEntryItem.DictionaryLookupsList = bookStatistics.dictionaryLookupsList;        
    }
}

- (SCHReadingStatsContentItem *)makeReadingStatsContentItemForBook:(SCHBookIdentifier *)bookIdentifier
{
    SCHReadingStatsContentItem *ret = nil;
    NSError *error = nil;
    NSEntityDescription *entityDescription = [NSEntityDescription 
                                              entityForName:kSCHUserContentItem
                                              inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *fetchRequest = [entityDescription.managedObjectModel
                                    fetchRequestFromTemplateWithName:kSCHUserContentItemFetchWithContentIdentifier
                                    substitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:
                                                           bookIdentifier.isbn, kSCHUserContentItemCONTENT_IDENTIFIER,
                                                           bookIdentifier.DRMQualifier, kSCHUserContentItemDRM_QUALIFIER,
                                                           nil]];
    [fetchRequest setFetchLimit:1];
    
    NSArray *userContentItems = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];	
    if (userContentItems == nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    if ([userContentItems count] > 0) {
        SCHUserContentItem *userContentItem = [userContentItems objectAtIndex:0];
        ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHReadingStatsContentItem 
                                            inManagedObjectContext:self.managedObjectContext];
        ret.ContentIdentifier = userContentItem.ContentIdentifier;
        ret.ContentIdentifierType = userContentItem.ContentIdentifierType;
        ret.DRMQualifier = userContentItem.DRMQualifier;
        ret.Format = userContentItem.Format;
    }
    
    return(ret);
}

- (void)saveBookOrder:(NSArray *)books
{
    for (int idx = 0; idx < [books count]; idx++) {
        SCHBookIdentifier *bookIdentifier = [books objectAtIndex:idx];
        SCHAppContentProfileItem *appContentProfileItem = [self appContentProfileItemForBookIdentifier:bookIdentifier];
        
        if (appContentProfileItem != nil) {
            appContentProfileItem.Order = [NSNumber numberWithInt:idx];
        }
    }
}

#pragma mark - Accessor methods

- (NSString *)bookshelfName:(BOOL)shortName
{
    NSString *ret = nil;
        
    if ([[self.FirstName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
        ret = self.FirstName;
        //ret = [NSString stringWithFormat:@"%@%@", self.FirstName, 
        //       (shortName == NO ? @"" : NSLocalizedString(@"'s Books", @""))];
    } else {
        ret = (shortName == NO ? @"" : NSLocalizedString(@"Books", @""));
    }
    
    return(ret);
}

- (void)setRawPassword:(NSString *)value 
{
    self.Password = [self SHA1:value];
}

- (BOOL)hasPassword
{
	if (self.Password == nil || [[self.Password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] < 1) {
		return(NO);
	} else {
		return(YES);
	}
}

- (BOOL)validatePasswordWith:(NSString *)withPassword
{
	if ([self hasPassword] == NO || [self.Password compare:[self SHA1:withPassword]] != NSOrderedSame) {
		return(NO);
	} else {
		return(YES);
	}
}

- (NSUInteger)age
{
    NSUInteger ret = 0;
    
    if(self.Birthday != nil) {
        NSCalendar *gregorian = [[NSCalendar alloc]
                                 initWithCalendarIdentifier:NSGregorianCalendar];
        
        NSDateComponents *components = [gregorian components:NSYearCalendarUnit
                                                    fromDate:self.Birthday
                                                      toDate:[NSDate date] options:0];
        [gregorian release], gregorian = nil;
        ret = components.year;
    }
    
    return(ret);
}

- (BOOL)storyInteractionsDisabled
{
    BOOL ret = NO;
    
    if (self.StoryInteractionEnabled != nil) {
        ret = ![self.StoryInteractionEnabled boolValue];
    }
    
    return ret;
}

#pragma mark - Encryption methods

- (NSString *)MD5:(NSString *)string
{
	const char *data = [string UTF8String];
	unsigned char md[CC_MD5_DIGEST_LENGTH+1];
    
	bzero(md, CC_MD5_DIGEST_LENGTH+1);
	
	CC_MD5(data, strlen(data), md);
	
	return([[NSData dataWithBytes:md length:strlen((char *)md)] base64Encoding]);
}

- (NSString *)SHA1:(NSString *)string
{
	const char *data = [string UTF8String];
	unsigned char md[CC_SHA1_DIGEST_LENGTH+1];
    
	bzero(md, CC_SHA1_DIGEST_LENGTH+1);

	CC_SHA1(data, strlen(data), md);
	
	return([[NSData dataWithBytes:md length:strlen((char *)md)] base64Encoding]);
}

@end

@implementation SCHProfileItemSortObject

@synthesize item;
@synthesize date;
@synthesize isNewBook;

- (void)dealloc 
{
    [item release], item = nil;
    [date release], date = nil;
    
    [super dealloc];
}

@end
