//
//  SCHRating.m
//  Scholastic
//
//  Created by John Eddie on 29/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHRating.h"
#import "SCHPrivateAnnotations.h"

#import "NSNumber+ObjectTypes.h"

// Constants
NSString * const kSCHRating = @"SCHRating";

@implementation SCHRating

@dynamic rating;
@dynamic averageRating;
@dynamic PrivateAnnotations;

- (void)setInitialValues
{
    self.rating = [NSNumber numberWithFloat:0.0];
    self.averageRating = [NSNumber numberWithFloat:0.0];
    
    self.LastModified = [NSDate distantPast];
    self.State = [NSNumber numberWithStatus:kSCHStatusUnmodified];    
}

@end
