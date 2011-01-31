//
//  SCHAnnotation.h
//  Scholastic
//
//  Created by John S. Eddie on 31/01/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "SCHSyncEntity.h"


@interface SCHAnnotation :  SCHSyncEntity  
{
}

@property (nonatomic, retain) NSNumber * ID;
@property (nonatomic, retain) NSNumber * Version;
@property (nonatomic, retain) NSNumber * Action;

@end



