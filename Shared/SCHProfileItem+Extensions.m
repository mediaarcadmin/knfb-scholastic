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
#import "SCHBookInfo.h"
#import "USAdditions.h"

static NSString * const kSCHProfileItemContentProfileItem = @"ContentProfileItem";
static NSString * const kSCHProfileItemUserContentItemContentMetadataItem = @"UserContentItem.ContentMetadataItem";

@interface SCHProfileItem ()

- (NSString *)MD5:(NSString *)string;

@end

@implementation SCHProfileItem (SCHProfileItemExtensions)

- (NSArray *)allContentMetadataItems
{
	NSMutableArray *books = [NSMutableArray array];
	
	for (SCHContentProfileItem *contentProfileItem in [self valueForKey:kSCHProfileItemContentProfileItem]) {
		for (SCHContentMetadataItem *contentMetadataItem in [contentProfileItem valueForKeyPath:kSCHProfileItemUserContentItemContentMetadataItem]) {
			
			SCHBookInfo *bookInfo = [[SCHBookInfo alloc] initWithContentMetadataItem:contentMetadataItem];
			
			[books addObject:bookInfo];
			[bookInfo release];
		}
	}
	
	return(books);
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
