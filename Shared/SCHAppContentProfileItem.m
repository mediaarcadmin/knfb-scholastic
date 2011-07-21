//
//  SCHAppContentProfileItem.m
//  Scholastic
//
//  Created by John S. Eddie on 18/03/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import "SCHAppContentProfileItem.h"

#import "SCHProfileItem.h"
#import "SCHBookIdentifier.h"

@implementation SCHAppContentProfileItem

@dynamic DRMQualifier;
@dynamic ISBN;
@dynamic IsNew;
@dynamic IsTrashed;
@dynamic Order;
@dynamic ProfileItem;
@dynamic ContentProfileItem;

@synthesize bookIdentifier;

- (SCHBookIdentifier *)bookIdentifier
{
    SCHBookIdentifier *identifier = [[SCHBookIdentifier alloc] initWithISBN:self.ISBN
                                                               DRMQualifier:self.DRMQualifier];
    return([identifier autorelease]);
}

@end
