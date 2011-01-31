//
//  SCHWordIndex.h
//  Scholastic
//
//  Created by John S. Eddie on 31/01/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import <CoreData/CoreData.h>

@class SCHLocationText;

@interface SCHWordIndex :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * Start;
@property (nonatomic, retain) NSNumber * End;
@property (nonatomic, retain) SCHLocationText * LocationText;

@end



