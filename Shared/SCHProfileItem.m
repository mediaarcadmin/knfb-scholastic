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

static NSString * const kSCHProfileItemContentProfileItem = @"ContentProfileItem";
static NSString * const kSCHProfileItemUserContentItem = @"UserContentItem";
static NSString * const kSCHProfileItemContentMetadataItem = @"ContentMetadataItem";
static NSString * const kSCHProfileItemUserContentItemContentMetadataItem = @"UserContentItem.ContentMetadataItem";

@interface SCHProfileItem ()

- (SCHContentProfileItem *)contentProfileItemForBook:(NSString *)contentIdentifier;
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
                    if ([bookOrderItem.ISBN compare:identifier.isbn] == NSOrderedSame) {
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
                                                fetchRequestTemplateForName:kSCHUserContentItemFetchWithContentIdentifier];
                
                [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"ContentIdentifier == %@", book.ContentIdentifier]];
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

- (BOOL) bookIsNewForProfileWithIdentifier: (NSString *)isbn
{
    NSEntityDescription *entityDescription = [NSEntityDescription 
                                              entityForName:kSCHUserContentItem
                                              inManagedObjectContext:self.managedObjectContext];

    NSFetchRequest *fetchRequest = [entityDescription.managedObjectModel 
                                    fetchRequestTemplateForName:kSCHUserContentItemFetchWithContentIdentifier];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"ContentIdentifier == %@", isbn]];
    [fetchRequest setFetchLimit:1];
    
    NSArray *userContentItems = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];	
    NSDate *creationDate = nil;
    if (userContentItems != nil && [userContentItems count] > 0) {
        NSSet *orderItems = [[userContentItems objectAtIndex:0] OrderList];
        if ([orderItems count] > 0) {
            // use the latest date
            NSArray *sortedOrderItems = [[orderItems allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]]];
            SCHOrderItem *orderItem = [sortedOrderItems objectAtIndex:0];
            creationDate = [orderItem OrderDate];
        }
    }

    if (!creationDate) {
        return NO;
    }
    
    NSDate *now = [NSDate date];
    NSTimeInterval interval = [now timeIntervalSinceDate:creationDate];
    
    // if the date is within 7 days of now, it is new
    if (interval >= 604800) {
        return YES;
    } else {
        return NO;
    }
}

- (SCHBookAnnotations *)annotationsForBook:(NSString *)isbn
{
    SCHBookAnnotations *ret = nil;
    
    if (isbn != nil) {
        NSEntityDescription *entityDescription = [NSEntityDescription 
                                                  entityForName:kSCHPrivateAnnotations 
                                                  inManagedObjectContext:self.managedObjectContext];
        NSFetchRequest *fetchRequest = [entityDescription.managedObjectModel fetchRequestFromTemplateWithName:kSCHProfileItemFetchAnnotationsForProfileBook 
                                                                                        substitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                                                               self.ID, kSCHProfileItemPROFILE_ID, isbn, 
                                                                                                               kSCHProfileItemCONTENT_IDENTIFIER, nil]];
        
        NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
        if ([results count] > 0) {
            ret = [[[SCHBookAnnotations alloc] initWithPrivateAnnotations:[results objectAtIndex:0]] autorelease];
        }    
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
        
        newBookOrder.ISBN = [books objectAtIndex:idx];
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

#pragma mark - Accessor delegated methods

// this information is read-only to change use the LastPage annotation
- (NSInteger)contentIdentifierLastPageLocation:(NSString *)contentIdentifier
{
    SCHContentProfileItem *ret = [self contentProfileItemForBook:contentIdentifier];
    
    return([ret.LastPageLocation integerValue]);
}

- (SCHContentProfileItem *)contentProfileItemForBook:(NSString *)contentIdentifier
{
    SCHContentProfileItem *ret = nil;
    
    if (contentIdentifier != nil) {
        for (SCHContentProfileItem *contentProfileItem in [self valueForKey:kSCHProfileItemContentProfileItem]) {
            SCHUserContentItem *userContentItem = [contentProfileItem valueForKeyPath:kSCHProfileItemUserContentItem];
            if ([userContentItem.ContentIdentifier isEqualToString:contentIdentifier] == YES) {
                ret = contentProfileItem;
                break;
            }
        }
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
