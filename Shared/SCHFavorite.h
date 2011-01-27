//
//  SCHFavorite.h
//  Scholastic
//
//  Created by John S. Eddie on 27/01/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "SCHSyncEntity.h"


@interface SCHFavorite :  SCHSyncEntity  
{
}

@property (nonatomic, retain) NSNumber * IsFavorite;

@end



