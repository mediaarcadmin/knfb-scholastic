// 
//  SCHAnnotationsContentItem.m
//  Scholastic
//
//  Created by John S. Eddie on 02/02/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import "SCHAnnotationsContentItem.h"

#import "SCHAnnotationsItem.h"
#import "SCHPrivateAnnotations.h"

// Constants
NSString * const kSCHAnnotationsContentItem = @"SCHAnnotationsContentItem";

NSString * const kSCHAnnotationsContentItemfetchAnnotationsContentItemsForBook = @"fetchAnnotationsContentItemsForBook";
NSString * const kSCHAnnotationsContentItemCONTENT_IDENTIFIER = @"CONTENT_IDENTIFIER";
NSString * const kSCHAnnotationsContentItemDRM_QUALIFIER = @"DRM_QUALIFIER";

@implementation SCHAnnotationsContentItem 

@dynamic Format;
@dynamic AverageRating;
@dynamic Rating;
@dynamic LastModified;
@dynamic AnnotationsItem;
@dynamic PrivateAnnotations;

- (NSNumber *)AverageRatingAsNumber
{    
    NSString *averageRating = self.AverageRating;
    
    if (averageRating == nil || 
        [[averageRating stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]  < 1) {
        averageRating = @"0";
    }
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *number = [formatter numberFromString:averageRating];
    [formatter release];
    
    return number;
}

@end
