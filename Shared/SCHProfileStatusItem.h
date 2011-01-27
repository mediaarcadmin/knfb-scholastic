//
//  SCHProfileStatusItem.h
//  Scholastic
//
//  Created by John S. Eddie on 27/01/2011.
//  Copyright 2011 Zicron Software Limited. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface SCHProfileStatusItem :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * ID;
@property (nonatomic, retain) NSNumber * StatusCode;
@property (nonatomic, retain) NSNumber * Action;
@property (nonatomic, retain) NSNumber * Status;
@property (nonatomic, retain) NSString * StatusMessage;
@property (nonatomic, retain) NSString * ScreenName;

@end



