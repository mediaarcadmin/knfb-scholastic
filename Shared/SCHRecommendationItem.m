//
//  SCHRecommendationItem.m
//  Scholastic
//
//  Created by John Eddie on 13/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHRecommendationItem.h"
#import "SCHRecommendationISBN.h"

// Constants
NSString * const kSCHRecommendationItem = @"SCHRecommendationItem";

NSString * const kSCHRecommendationOrder = @"order";

@implementation SCHRecommendationItem

@dynamic name;
@dynamic link;
@dynamic imageLink;
@dynamic regularPrice;
@dynamic salePrice;
@dynamic productCode;
@dynamic format;
@dynamic author;
@dynamic order;
@dynamic isbn;
@dynamic profile;

- (UIImage *)bookCover
{
    return nil;
}

@end
