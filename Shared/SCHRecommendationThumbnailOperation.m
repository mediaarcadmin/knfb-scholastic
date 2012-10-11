//
//  SCHRecommendationThumbnailOperation.m
//  Scholastic
//
//  Created by Matt Farrugia on 27/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHRecommendationThumbnailOperation.h"
#import "UIImage+ScholasticAdditions.h"

// Constants
NSString * const SCHRecommendationThumbnailOperationDidUpdateNotification = @"SCHRecommendationThumbnailOperationDidUpdateNotification";

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
        [self performWithRecommendation:^(SCHAppRecommendationItem *item) {
            NSDictionary *recommendationItemDictionary = [item dictionary];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.isCancelled == NO) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:SCHRecommendationThumbnailOperationDidUpdateNotification
                                                                        object:self
                                                                      userInfo:recommendationItemDictionary];
                }
            });
        }];
    } else {
        [self setProcessingState:kSCHAppRecommendationProcessingStateThumbnailError];
    }
    
    [self endOperation];
}

@end
