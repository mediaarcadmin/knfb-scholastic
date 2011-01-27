//
//  SCHLastPage.h
//  Scholastic
//
//  Created by John S. Eddie on 27/01/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "SCHSyncEntity.h"


@interface SCHLastPage :  SCHSyncEntity  
{
}

@property (nonatomic, retain) NSNumber * Percentage;
@property (nonatomic, retain) NSString * Component;
@property (nonatomic, retain) NSNumber * LastPageLocation;

@end



