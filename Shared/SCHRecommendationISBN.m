//
//  SCHRecommendationISBN.m
//  Scholastic
//
//  Created by John Eddie on 13/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHRecommendationISBN.h"

#import "SCHBookIdentifier.h"

// Constants
NSString * const kSCHRecommendationISBN = @"SCHRecommendationISBN";

@implementation SCHRecommendationISBN

@dynamic isbn;
@dynamic fetchDate;
@dynamic DRMQualifier;
@dynamic recommendationItems;

- (SCHBookIdentifier *)bookIdentifier
{
    SCHBookIdentifier *identifier = [[SCHBookIdentifier alloc] initWithISBN:self.isbn
                                                               DRMQualifier:self.DRMQualifier];
    return [identifier autorelease];
}

@end
