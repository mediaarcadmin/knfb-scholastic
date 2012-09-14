//
//  SCHAppRecommendationProfile.m
//  Scholastic
//
//  Created by John Eddie on 13/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHAppRecommendationProfile.h"
#import "SCHRecommendationItem.h"

// Constants
NSString * const kSCHAppRecommendationProfile = @"SCHAppRecommendationProfile";

@implementation SCHAppRecommendationProfile

@dynamic age;
@dynamic fetchDate;
@dynamic recommendationItems;

+ (BOOL)isValidProfileID:(NSNumber *)profileID
{
    return [profileID integerValue] > 0;
}

@end
