//
//  SCHFavorite.h
//  Scholastic
//
//  Created by John S. Eddie on 31/01/2011.
//  Copyright 2011 Zicron Software Limited. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "SCHSyncEntity.h"

@class SCHPrivateAnnotations;

@interface SCHFavorite :  SCHSyncEntity  
{
}

@property (nonatomic, retain) NSNumber * IsFavorite;
@property (nonatomic, retain) SCHPrivateAnnotations * PrivateAnnotations;

@end



