//
//  SCHRecommendationItem.m
//  Scholastic
//
//  Created by John Eddie on 13/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHRecommendationItem.h"
#import "SCHRecommendationISBN.h"
#import "SCHRecommendationProfile.h"
#import "SCHAppRecommendationItem.h"

// Constants
NSString * const kSCHRecommendationItem = @"SCHRecommendationItem";

@implementation SCHRecommendationItem

@dynamic name;
@dynamic link;
@dynamic image_link;
@dynamic regular_price;
@dynamic sale_price;
@dynamic product_code;
@dynamic format;
@dynamic author;
@dynamic order;
@dynamic appRecommendationItem;
@dynamic recommendationISBN;
@dynamic recommendationProfile;

@end
