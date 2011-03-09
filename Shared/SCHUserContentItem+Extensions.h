//
//  SCHUserContentItem+Extensions.h
//  Scholastic
//
//  Created by John S. Eddie on 17/01/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SCHUserContentItem.h"

static NSString * const kSCHUserContentItem = @"SCHUserContentItem";

static NSString * const kSCHUserContentItemFetchWithContentIdentifier = @"fetchWithContentIdentifier";
static NSString * const kSCHUserContentItemCONTENT_IDENTIFIER = @"CONTENT_IDENTIFIER";

@interface SCHUserContentItem (SCHUserContentItemExtensions)

@property (nonatomic, readonly) NSSet *AssignedProfileList;

@end
