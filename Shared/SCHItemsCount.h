//
//  SCHItemsCount.h
//  Scholastic
//
//  Created by John S. Eddie on 31/01/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import <CoreData/CoreData.h>

@class SCHListProfileContentAnnotations;

static NSString * const kSCHItemsCount = @"SCHItemsCount";

@interface SCHItemsCount :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * Found;
@property (nonatomic, retain) NSNumber * Returned;
@property (nonatomic, retain) SCHListProfileContentAnnotations * ListProfileContentAnnotations;

@end



