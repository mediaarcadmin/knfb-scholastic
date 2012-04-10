//
//  SCHRating.h
//  Scholastic
//
//  Created by John Eddie on 29/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SCHSyncEntity.h"

@class SCHPrivateAnnotations;

// Constants
extern NSString * const kSCHRating;

@interface SCHRating : SCHSyncEntity

@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSNumber * averageRating;
@property (nonatomic, retain) SCHPrivateAnnotations *PrivateAnnotations;

- (void)setInitialValues;

@end
