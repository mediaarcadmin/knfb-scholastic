//
//  SCHProfileItem+Extensions.m
//  Scholastic
//
//  Created by John S. Eddie on 17/01/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHProfileItem+Extensions.h"

#import <CommonCrypto/CommonDigest.h>

#import "SCHContentProfileItem+Extensions.h"
#import "SCHContentMetadataItem+Extensions.h"
#import "SCHUserContentItem+Extensions.h"
#import "SCHAppBookOrder+Extensions.h"
#import "SCHBookInfo.h"
#import "SCHBookManager.h"
#import "USAdditions.h"
#import "SCHLibreAccessWebService.h"

static NSString * const kSCHProfileItemContentProfileItem = @"ContentProfileItem";
static NSString * const kSCHProfileItemUserContentItem = @"UserContentItem";
static NSString * const kSCHProfileItemContentMetadataItem = @"ContentMetadataItem";
static NSString * const kSCHProfileItemUserContentItemContentMetadataItem = @"UserContentItem.ContentMetadataItem";

@interface SCHProfileItem ()

- (NSString *)MD5:(NSString *)string;

@end

@implementation SCHProfileItem (SCHProfileItemExtensions)

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

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super dealloc];
}

- (NSArray *)allContentMetadataItems
{
	NSMutableArray *books = [NSMutableArray array];
	
	for (SCHContentProfileItem *contentProfileItem in [self valueForKey:kSCHProfileItemContentProfileItem]) {
		for (SCHContentMetadataItem *contentMetadataItem in [contentProfileItem valueForKeyPath:kSCHProfileItemUserContentItemContentMetadataItem]) {
			
			SCHBookInfo *bookInfo = [SCHBookManager bookInfoWithBookIdentifier:contentMetadataItem.ContentIdentifier];
			
			[books addObject:bookInfo];
			[bookInfo release];
		}
	}
    
    // order the books
    if ([self.AppBookOrder count] > 0) {
        NSArray *bookOrder = [self.AppBookOrder sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHAppBookOrderOrder ascending:YES]]];
        for (int i = 0; i < [bookOrder count]; i++) {
            SCHAppBookOrder *bookOrderItem = [bookOrder objectAtIndex:i];
            
            NSUInteger bookIndex = [books indexOfObjectPassingTest:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([bookOrderItem.ISBN compare:[obj objectForMetadataKey:kSCHLibreAccessWebServiceContentIdentifier]] == NSOrderedSame) {
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
        SCHBookInfo *bookInfo = [books objectAtIndex:idx];
        SCHAppBookOrder *newBookOrder = [NSEntityDescription insertNewObjectForEntityForName:kSCHAppBookOrder inManagedObjectContext:self.managedObjectContext];

        newBookOrder.ISBN = [bookInfo objectForMetadataKey:kSCHLibreAccessWebServiceContentIdentifier];
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
	if ([self hasPassword] == NO || [self.Password compare:[self MD5:withPassword]] != NSOrderedSame) {
		return(NO);
	} else {
		return(YES);
	}
}

@end
