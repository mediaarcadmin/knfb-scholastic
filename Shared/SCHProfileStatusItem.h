//
//  SCHProfileStatusItem.h
//  Scholastic
//
//  Created by John S. Eddie on 31/01/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface SCHProfileStatusItem :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * ID;
@property (nonatomic, retain) NSString * ScreenName;
@property (nonatomic, retain) NSNumber * Action;
@property (nonatomic, retain) NSNumber * Status;
@property (nonatomic, retain) NSNumber * StatusCode;
@property (nonatomic, retain) NSString * StatusMessage;

@end



