//
//  SCHOrderItem.h
//  Scholastic
//
//  Created by John S. Eddie on 31/01/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import <CoreData/CoreData.h>

@class SCHUserContentItem;

static NSString * const kSCHOrderItem = @"SCHOrderItem";

@interface SCHOrderItem :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * OrderID;
@property (nonatomic, retain) NSDate * OrderDate;
@property (nonatomic, retain) SCHUserContentItem * UserContentItem;

@end



