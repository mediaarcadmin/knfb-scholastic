//
//  SCHAppRecommendationItem.m
//  Scholastic
//
//  Created by John Eddie on 19/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHAppRecommendationItem.h"
#import "SCHRecommendationItem.h"

// Constants
NSString * const kSCHAppRecommendationItem = @"SCHAppRecommendationItem";

@implementation SCHAppRecommendationItem

@dynamic Author;
@dynamic AverageRating;
@dynamic ContentURL;
@dynamic CoverURL;
@dynamic Description;
@dynamic Enhanced;
@dynamic FileName;
@dynamic FileSize;
@dynamic PageNumber;
@dynamic Title;
@dynamic Version;
@dynamic recommendationItems;

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

- (UIImage *)bookCover
{
    // FIXME: return a real image at some point...
    return [UIImage imageNamed:@"sampleCoverImage.jpg"];
}


@end
