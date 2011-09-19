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

// Constants
NSString * const kSCHAppContentProfileItem = @"SCHAppContentProfileItem";

NSString * const kSCHAppContentProfileItemDRMQualifier = @"DRMQualifier";
NSString * const kSCHAppContentProfileItemISBN = @"ISBN";
NSString * const kSCHAppContentProfileItemOrder = @"Order";

@implementation SCHAppContentProfileItem

@dynamic DRMQualifier;
@dynamic ISBN;
@dynamic IsTrashed;
@dynamic Order;
@dynamic LastAnnotationSync;
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
