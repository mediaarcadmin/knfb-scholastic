//
//  SCHProfileItem.m
//  Scholastic
//
//  Created by John S. Eddie on 18/03/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import "SCHProfileItem.h"
#import "SCHAppBookOrder.h"

#import <CommonCrypto/CommonDigest.h>

#import "SCHContentProfileItem.h"
#import "SCHContentMetadataItem.h"
#import "SCHUserContentItem.h"
#import "SCHBookManager.h"
#import "USAdditions.h"
#import "SCHLibreAccessWebService.h"
#import "SCHAppBook.h"

static NSString * const kSCHProfileItemContentProfileItem = @"ContentProfileItem";
static NSString * const kSCHProfileItemUserContentItem = @"UserContentItem";
static NSString * const kSCHProfileItemContentMetadataItem = @"ContentMetadataItem";
static NSString * const kSCHProfileItemUserContentItemContentMetadataItem = @"UserContentItem.ContentMetadataItem";

@interface SCHProfileItem ()

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

- (NSMutableArray *)allISBNs
{
	NSMutableArray *books = [NSMutableArray array];
	
	for (SCHContentProfileItem *contentProfileItem in [self valueForKey:kSCHProfileItemContentProfileItem]) {
		for (SCHContentMetadataItem *contentMetadataItem in [contentProfileItem valueForKeyPath:kSCHProfileItemUserContentItemContentMetadataItem]) {
			[books addObject:contentMetadataItem.ContentIdentifier];
		}
	}
    
    // order the books
    if ([self.AppBookOrder count] > 0) {
        NSArray *bookOrder = [self.AppBookOrder sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHAppBookOrderOrder ascending:YES]]];
        for (int i = 0; i < [bookOrder count]; i++) {
            SCHAppBookOrder *bookOrderItem = [bookOrder objectAtIndex:i];
            
            NSUInteger bookIndex = [books indexOfObjectPassingTest:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([bookOrderItem.ISBN compare:obj] == NSOrderedSame) {
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

- (void)setRawPassword:(NSString *)value 
{
    self.Password = [self MD5:value];
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

@end
