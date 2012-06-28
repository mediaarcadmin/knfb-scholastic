//
//  SCHRecommendationThumbnailOperation.m
//  Scholastic
//
//  Created by Matt Farrugia on 27/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHRecommendationThumbnailOperation.h"
#import "UIImage+ScholasticAdditions.h"
#import "SCHAppRecommendationItem.h"

@implementation SCHRecommendationThumbnailOperation

- (void)beginOperation
{
    __block NSString *coverPath = nil;
    __block NSString *thumbPath = nil;
    
    [self performWithRecommendation:^(SCHAppRecommendationItem *item) {
        coverPath = [[item coverImagePath] copy];
        thumbPath = [[item thumbPath] copy];
    }];
    
    [coverPath autorelease];
    [thumbPath autorelease];
    
    NSUInteger maxDimension;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        maxDimension = kSCHRecommendationThumbnailMaxDimensionPad;
    } else {
        maxDimension = kSCHRecommendationThumbnailMaxDimensionPhone;
    }
    
    UIImage *createdThumb = [UIImage SCHCreateThumbWithSourcePath:coverPath destinationPath:thumbPath maxDimension:maxDimension];
    
    if (createdThumb) {
        [self setProcessingState:kSCHAppRecommendationProcessingStateComplete];
    } else {
        [self setProcessingState:kSCHAppRecommendationProcessingStateThumbnailError];
    }
    
    [self endOperation];
}

@end
