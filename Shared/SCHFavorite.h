//
//  SCHFavorite.h
//  Scholastic
//
//  Created by John S. Eddie on 31/01/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "SCHSyncEntity.h"

@class SCHPrivateAnnotations;

static NSString * const kSCHFavorite = @"SCHFavorite";

@interface SCHFavorite :  SCHSyncEntity  
{
}

@property (nonatomic, retain) NSNumber * IsFavorite;
@property (nonatomic, retain) SCHPrivateAnnotations * PrivateAnnotations;

@end



