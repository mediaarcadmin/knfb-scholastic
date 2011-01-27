//
//  SCHContentProfileItem.h
//  Scholastic
//
//  Created by John S. Eddie on 27/01/2011.
//  Copyright 2011 Zicron Software Limited. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "SCHFavorite.h"


@interface SCHContentProfileItem :  SCHFavorite  
{
}

@property (nonatomic, retain) NSNumber * ProfileID;
@property (nonatomic, retain) NSNumber * LastPageLocation;

@end



