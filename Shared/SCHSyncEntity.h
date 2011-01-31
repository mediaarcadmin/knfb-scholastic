//
//  SCHSyncEntity.h
//  Scholastic
//
//  Created by John S. Eddie on 31/01/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface SCHSyncEntity :  NSManagedObject  
{
}

@property (nonatomic, retain) NSDate * LastModified;
@property (nonatomic, retain) NSNumber * State;

@end



