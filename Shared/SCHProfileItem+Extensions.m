//
//  SCHProfileItem+Extensions.m
//  Scholastic
//
//  Created by John S. Eddie on 17/01/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHProfileItem+Extensions.h"

#import "SCHContentProfileItem+Extensions.h"
#import "SCHContentMetadataItem+Extensions.h"

static NSString * const kSCHProfileItemContentProfileItem = @"ContentProfileItem";
static NSString * const kSCHProfileItemUserContentItemContentMetadataItem = @"UserContentItem.ContentMetadataItem";

@implementation SCHProfileItem (SCHProfileItemExtensions)

- (NSArray *)allContentMetadataItems
{
	NSMutableArray *books = [NSMutableArray array];
	
	for (SCHContentProfileItem *contentProfileItem in [self valueForKey:kSCHProfileItemContentProfileItem]) {
		for (SCHContentMetadataItem *contentMetadataItem in [contentProfileItem valueForKeyPath:kSCHProfileItemUserContentItemContentMetadataItem]) {
			[books addObject:contentMetadataItem];
		}
	}
	
	return(books);
}

@end
