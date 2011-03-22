//
//  SCHContentProfileItem.h
//  Scholastic
//
//  Created by John S. Eddie on 31/01/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "SCHFavorite.h"

@class SCHUserContentItem;

static NSString * const kSCHContentProfileItem = @"SCHContentProfileItem";

@interface SCHContentProfileItem :  SCHFavorite  
{
}

@property (nonatomic, retain) NSNumber * ProfileID;
@property (nonatomic, retain) NSNumber * LastPageLocation;
@property (nonatomic, retain) SCHUserContentItem * UserContentItem;

@end



