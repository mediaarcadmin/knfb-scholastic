//
//  SCHProfileItem.m
//  Scholastic
//
//  Created by John S. Eddie on 18/03/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import "SCHProfileItem.h"
#import "SCHAppBookOrder.h"
#import "SCHAppProfile.h"

#import <CommonCrypto/CommonDigest.h>

#import "SCHContentProfileItem.h"
#import "SCHContentMetadataItem.h"
#import "SCHUserContentItem.h"
#import "SCHBookManager.h"
#import "USAdditions.h"
#import "SCHLibreAccessWebService.h"
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

static NSString * const kSCHProfileItemContentProfileItem = @"ContentProfileItem";
static NSString * const kSCHProfileItemUserContentItem = @"UserContentItem";
static NSString * const kSCHProfileItemContentMetadataItem = @"ContentMetadataItem";
static NSString * const kSCHProfileItemUserContentItemContentMetadataItem = @"UserContentItem.ContentMetadataItem";

@interface SCHProfileItem ()

- (SCHReadingStatsContentItem *)newReadingStatsContentItemForBook:(SCHBookIdentifier *)bookIdentifier;
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
@dynamic AppBookOrder;
@dynamic AppProfile;

@synthesize age;

#pragma mark - Object lifecycle

- (void)awakeFromInsert
{
	[super awakeFromInsert];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshAllContentMetadataItems) name:@"SCHBookshelfSyncComponentComplete" object:nil];			
}

- (void)awakeFromFetch
{
	[super awakeFromFetch];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshAllContentMetadataItems) name:@"SCHBookshelfSyncComponentComplete" object:nil];		
}

- (void)willTurnIntoFault
{
    [super willTurnIntoFault];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - methods

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
        
        for (SCHContentProfileItem *contentProfileItem in [self valueForKey:kSCHProfileItemContentProfileItem]) {
            for (SCHContentMetadataItem *contentMetadataItem in [contentProfileItem valueForKeyPath:kSCHProfileItemUserContentItemContentMetadataItem]) {
                SCHBookIdentifier *identifier = [[SCHBookIdentifier alloc] initWithISBN:contentMetadataItem.ContentIdentifier
                                                                           DRMQualifier:contentMetadataItem.DRMQualifier];
                [books addObject:identifier];
                [identifier release];
            }
        }
        
        // order the books
        if ([self.AppBookOrder count] > 0) {
            NSArray *bookOrder = [self.AppBookOrder sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHAppBookOrderOrder ascending:YES]]];
            for (int i = 0; i < [bookOrder count]; i++) {
                SCHAppBookOrder *bookOrderItem = [bookOrder objectAtIndex:i];
                
                NSUInteger bookIndex = [books indexOfObjectPassingTest:^(id obj, NSUInteger idx, BOOL *stop) {
                    SCHBookIdentifier *identifier = (SCHBookIdentifier *)obj;
                    if ([bookOrderItem.ISBN compare:identifier.isbn] == NSOrderedSame &&
                        [bookOrderItem.DRMQualifier compare:identifier.DRMQualifier] == NSOrderedSame) {
                        *stop = YES;
                        return(YES);
                    } else {
                        return NO;
                    }
                }];
                
                if(bookIndex != NSNotFound) {
                    [books exchangeObjectAtIndex:i withObjectAtIndex:bookIndex];
                }
            }
        }
        
        return(books);
    }

    NSMutableArray *books = [NSMutableArray array];
    NSMutableArray *bookObjects = [NSMutableArray array];
    
    for (SCHContentProfileItem *contentProfileItem in [self valueForKey:kSCHProfileItemContentProfileItem]) {
        for (SCHContentMetadataItem *contentMetadataItem in [contentProfileItem valueForKeyPath:kSCHProfileItemUserContentItemContentMetadataItem]) {
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
            [bookObjects sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"Author" ascending:YES]]];
            break;
        }
        case kSCHBookSortTypeNewest:
        {
            NSMutableArray *sortArray = [[NSMutableArray alloc] initWithCapacity:[books count]];
            NSEntityDescription *entityDescription = [NSEntityDescription 
                                                      entityForName:kSCHUserContentItem
                                                      inManagedObjectContext:self.managedObjectContext];

            for (SCHContentMetadataItem *book in bookObjects) {
                NSFetchRequest *fetchRequest = [entityDescription.managedObjectModel
                                                fetchRequestFromTemplateWithName:kSCHUserContentItemFetchWithContentIdentifier
                                                substitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                       book.ContentIdentifier, kSCHUserContentItemCONTENT_IDENTIFIER,
                                                                       book.DRMQualifier, kSCHUserContentItemDRM_QUALIFIER,
                                                                       nil]];
                [fetchRequest setFetchLimit:1];
                
                NSArray *userContentItems = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];	
                NSDate *date = [NSDate distantPast];
                if (userContentItems != nil && [userContentItems count] > 0) {
                    NSSet *orderItems = [[userContentItems objectAtIndex:0] OrderList];
                    if ([orderItems count] > 0) {
                        // use the latest date
                        NSArray *sortedOrderItems = [[orderItems allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]]];
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
                    
                SCHProfileItemSortObject *sortObj = [[SCHProfileItemSortObject alloc] init];
                sortObj.date = privAnnotations.LastPage.LastModified;
                sortObj.item = item;
                
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

- (BOOL) bookIsNewForProfileWithIdentifier: (SCHBookIdentifier *)identifier
{
    NSDictionary *defaultsDictionary = (NSDictionary *)[[NSUserDefaults standardUserDefaults] objectForKey:@"SCHProfileItemNewItemsDictionary"];
    
    if (!defaultsDictionary) {
        return YES;
    }
    
    NSDictionary *profileDictionary = [defaultsDictionary objectForKey:[self.ID stringValue]];
    
    if (!profileDictionary) {
        return YES;
    }
    
    NSNumber *item = [profileDictionary valueForKey:[identifier encodeAsString]];
    
    if (!item) {
        return YES;
    }
    
    return [item boolValue];

}

- (void)setBookIsNew:(BOOL)isNew forBookWithIdentifier:(SCHBookIdentifier *)identifier
{
    NSDictionary *defaultsDictionary = (NSDictionary *)[[NSUserDefaults standardUserDefaults] objectForKey:@"SCHProfileItemNewItemsDictionary"];
    NSMutableDictionary *trashedItems = nil;
    
    if (!defaultsDictionary) {
        trashedItems = [NSMutableDictionary dictionary];
    } else {
        trashedItems = [NSMutableDictionary dictionaryWithDictionary:defaultsDictionary];
    }
    
    NSDictionary *profileDictionary = [trashedItems objectForKey:[self.ID stringValue]];
    NSMutableDictionary *profileMutableDictionary = nil;
    
    if (profileDictionary) {
        profileMutableDictionary = [NSMutableDictionary dictionaryWithDictionary:profileDictionary];
    } else {
        profileMutableDictionary = [NSMutableDictionary dictionary];
    }
    
    NSNumber *newValue = [NSNumber numberWithBool:isNew];
    
    [profileMutableDictionary setValue:newValue forKey:[identifier encodeAsString]];
    [trashedItems setValue:[NSDictionary dictionaryWithDictionary:profileMutableDictionary] forKey:[self.ID stringValue]];
    [[NSUserDefaults standardUserDefaults] setValue:[NSDictionary dictionaryWithDictionary:trashedItems] forKey:@"SCHProfileItemNewItemsDictionary"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}


// structure: dictionary with profileID->isbndictionary, isbndictionary with isbn->nsnumber (bool)
- (BOOL)bookIsTrashedWithIdentifier:(SCHBookIdentifier *)identifier
{
    NSDictionary *defaultsDictionary = (NSDictionary *)[[NSUserDefaults standardUserDefaults] objectForKey:@"SCHProfileItemTrashedItemsDictionary"];
    
    if (!defaultsDictionary) {
        return NO;
    }
    
    NSDictionary *profileDictionary = [defaultsDictionary objectForKey:[self.ID stringValue]];
    
    if (!profileDictionary) {
        return NO;
    }
    
    NSNumber *item = [profileDictionary valueForKey:[identifier encodeAsString]];
    
    if (!item) {
        return NO;
    }
    
    return [item boolValue];
}

- (void)setTrashed:(BOOL)trashed forBookWithIdentifier:(SCHBookIdentifier *)identifier
{
    NSDictionary *defaultsDictionary = (NSDictionary *)[[NSUserDefaults standardUserDefaults] objectForKey:@"SCHProfileItemTrashedItemsDictionary"];
    NSMutableDictionary *trashedItems = nil;
    
    if (!defaultsDictionary) {
        trashedItems = [NSMutableDictionary dictionary];
    } else {
        trashedItems = [NSMutableDictionary dictionaryWithDictionary:defaultsDictionary];
    }
    
    NSDictionary *profileDictionary = [trashedItems objectForKey:[self.ID stringValue]];
    NSMutableDictionary *profileMutableDictionary = nil;
    
    if (profileDictionary) {
        profileMutableDictionary = [NSMutableDictionary dictionaryWithDictionary:profileDictionary];
    } else {
        profileMutableDictionary = [NSMutableDictionary dictionary];
    }
    
    NSNumber *newValue = [NSNumber numberWithBool:trashed];
    
    [profileMutableDictionary setValue:newValue forKey:[identifier encodeAsString]];
    [trashedItems setValue:[NSDictionary dictionaryWithDictionary:profileMutableDictionary] forKey:[self.ID stringValue]];
    [[NSUserDefaults standardUserDefaults] setValue:[NSDictionary dictionaryWithDictionary:trashedItems] forKey:@"SCHProfileItemTrashedItemsDictionary"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (SCHBookAnnotations *)annotationsForBook:(SCHBookIdentifier *)bookIdentifier
{
    SCHBookAnnotations *ret = nil;
    
    if (bookIdentifier != nil) {
        NSEntityDescription *entityDescription = [NSEntityDescription 
                                                  entityForName:kSCHPrivateAnnotations 
                                                  inManagedObjectContext:self.managedObjectContext];
        NSFetchRequest *fetchRequest = [entityDescription.managedObjectModel fetchRequestFromTemplateWithName:kSCHProfileItemFetchAnnotationsForProfileBook 
                                                                                        substitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                                                               self.ID, kSCHProfileItemPROFILE_ID, bookIdentifier.isbn, 
                                                                                                               kSCHProfileItemCONTENT_IDENTIFIER, bookIdentifier.DRMQualifier, 
                                                                                                               kSCHProfileItemDRM_QUALIFIER, nil]];
        
        NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
        if ([results count] > 0) {
            ret = [[[SCHBookAnnotations alloc] initWithPrivateAnnotations:[results objectAtIndex:0]] autorelease];
        }    
    }
    
    return(ret);
}

- (SCHBookStatistics *)newStatisticsForBook:(SCHBookIdentifier *)bookIdentifier
{
    SCHBookStatistics *ret = nil;
    SCHReadingStatsDetailItem *readingStatsDetailItem = nil;
    SCHReadingStatsContentItem *readingStatsContentItem = nil;
    SCHReadingStatsEntryItem *readingStatsEntryItem = nil;
    NSError *error = nil;
    
    if (bookIdentifier != nil) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        [fetchRequest setEntity:[NSEntityDescription entityForName:kSCHReadingStatsDetailItem 
                                            inManagedObjectContext:self.managedObjectContext]];	
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"ProfileID == %@", self.ID]];
        [fetchRequest setFetchLimit:1];
        
        NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest 
                                                                   error:&error];
        [fetchRequest release], fetchRequest = nil;
        if ([result count] > 0) {
            readingStatsDetailItem = [result objectAtIndex:0];
            for (SCHReadingStatsContentItem *contentItem in readingStatsDetailItem.ReadingStatsContentItem) {
                if ([contentItem.ContentIdentifier isEqualToString:bookIdentifier.isbn] == YES &&
                    [contentItem.DRMQualifier isEqualToNumber:bookIdentifier.DRMQualifier] == YES) {
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
            readingStatsContentItem = [self newReadingStatsContentItemForBook:bookIdentifier];   
            readingStatsContentItem.ReadingStatsDetailItem = readingStatsDetailItem;                
        }

        readingStatsEntryItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHReadingStatsEntryItem 
                                                              inManagedObjectContext:self.managedObjectContext];            
        readingStatsEntryItem.ReadingStatsContentItem = readingStatsContentItem;                            
        
        ret = [[[SCHBookStatistics alloc] initWithReadingStatsEntryItem:readingStatsEntryItem] autorelease];
    }
    
    return(ret);
}

- (SCHReadingStatsContentItem *)newReadingStatsContentItemForBook:(SCHBookIdentifier *)bookIdentifier
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

- (void)refreshAllContentMetadataItems
{	
	for (SCHContentProfileItem *contentProfileItem in [self valueForKey:kSCHProfileItemContentProfileItem]) {
        [[self managedObjectContext] refreshObject:contentProfileItem mergeChanges:YES];		
		SCHUserContentItem *userContentItem = [contentProfileItem valueForKey:kSCHProfileItemUserContentItem];
        [[self managedObjectContext] refreshObject:userContentItem mergeChanges:YES];		
		for (SCHContentMetadataItem *contentMetadataItem in [userContentItem valueForKey:kSCHProfileItemContentMetadataItem]) {
            [[self managedObjectContext] refreshObject:contentMetadataItem mergeChanges:YES];					
		}
	}	
}

- (void)saveBookOrder:(NSArray *)books
{
    [self clearBookOrder];
    
    for (int idx = 0; idx < [books count]; idx++) {
        SCHAppBookOrder *newBookOrder = [NSEntityDescription insertNewObjectForEntityForName:kSCHAppBookOrder inManagedObjectContext:self.managedObjectContext];
        
        newBookOrder.ISBN = [[books objectAtIndex:idx] isbn];
        newBookOrder.DRMQualifier = [[books objectAtIndex:idx] DRMQualifier];        
        newBookOrder.Order = [NSNumber numberWithInt:idx];
        
        [self addAppBookOrderObject:newBookOrder];
    }
}

- (void)clearBookOrder 
{
    for (NSManagedObject *bookOrder in self.AppBookOrder) {
        [[self managedObjectContext] deleteObject:bookOrder];
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

@end
