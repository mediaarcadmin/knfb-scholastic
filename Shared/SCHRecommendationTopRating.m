//
//  SCHRecommendationTopRating.m
//  Scholastic
//
//  Created by John S. Eddie on 27/08/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHRecommendationTopRating.h"
#import "SCHRecommendationItem.h"

// Constants
NSString * const kSCHRecommendationTopRating = @"SCHRecommendationTopRating";

@implementation SCHRecommendationTopRating

@dynamic categoryClass;
@dynamic fetchDate;
@dynamic recommendationItems;

+ (BOOL)isValidCategoryClass:(NSString *)categoryClass
{
    return [[categoryClass stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0;
}

@end
