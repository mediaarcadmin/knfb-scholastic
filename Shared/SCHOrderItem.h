//
//  SCHOrderItem.h
//  Scholastic
//
//  Created by John S. Eddie on 27/01/2011.
//  Copyright 2011 Zicron Software Limited. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface SCHOrderItem :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * OrderID;
@property (nonatomic, retain) NSDate * OrderDate;

@end



