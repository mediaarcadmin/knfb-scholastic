//
//  SCHProfileItem+Extensions.h
//  Scholastic
//
//  Created by John S. Eddie on 17/01/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SCHProfileItem.h"

static NSString * const kSCHProfileItem = @"SCHProfileItem";

@interface SCHProfileItem (SCHProfileItemExtensions)

- (NSMutableArray *)allContentMetadataItems;
- (void)saveBookOrder:(NSArray *)books;
- (void)clearBookOrder;
- (void)setRawPassword:(NSString *)value;
- (BOOL)hasPassword;
- (BOOL)validatePasswordWith:(NSString *)withPassword;

@end
