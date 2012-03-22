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

@interface SCHAppRecommendationItem ()

- (void)deleteAllFiles;

@end

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
@dynamic wishListItems;

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

// FIXME: return a real image at some point...
- (UIImage *)bookCover
{
    return [UIImage imageNamed:@"sampleCoverImage.jpg"];
}

- (BOOL)isInUse
{
    return ([self.recommendationItems count] > 0 ||
            [self.wishListItems count] > 0);
}

- (void)prepareForDeletion
{
    [super prepareForDeletion];

    [self deleteAllFiles];
}

// TODO: Implement deletion of files
- (void)deleteAllFiles
{
//    NSError *error = nil;
    
    NSLog(@"We should be deleting files for %@. But we need to be implemneted first", self.ContentIdentifier);
    
//    [[SCHRecoomendationManager sharedRecommendationManager] cancelAllOperationsForBook:self.ContentIdentifier];

//    if ([[NSFileManager defaultManager] removeItemAtPath:self.filePath 
//                                                   error:&error] == NO) {
//        NSLog(@"Failed to delete files for %@, error: %@", 
//              self.ContentIdentifier, [error localizedDescription]);
//    }
}

@end
