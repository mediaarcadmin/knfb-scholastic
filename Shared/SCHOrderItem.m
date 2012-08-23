// 
//  SCHOrderItem.m
//  Scholastic
//
//  Created by John S. Eddie on 31/01/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import "SCHOrderItem.h"

#import "SCHUserContentItem.h"

// Constants
NSString * const kSCHOrderItem = @"SCHOrderItem";

@implementation SCHOrderItem 

@dynamic OrderID;
@dynamic OrderDate;
@dynamic UserContentItem;

+ (BOOL)isValidOrderID:(NSNumber *)orderID
{
    return [orderID integerValue] > 0;
}

@end
