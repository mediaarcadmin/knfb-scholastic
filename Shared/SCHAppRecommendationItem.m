//
//  SCHAppRecommendationItem.m
//  Scholastic
//
//  Created by John Eddie on 19/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHAppRecommendationItem.h"
#import "SCHRecommendationItem.h"
#import "NSNumber+ObjectTypes.h"
#import "SCHRecommendationManager.h"

// Constants
NSString * const kSCHAppRecommendationItem = @"SCHAppRecommendationItem";
NSString * const kSCHAppRecommendationItemIsbn = @"isbn";
NSString * const kSCHAppRecommendationFilenameSeparator = @"-";

@interface SCHAppRecommendationItem()

@property (nonatomic, copy) NSString *cachedRecommendationDirectory;

- (void)deleteAllFiles;

@end

@implementation SCHAppRecommendationItem

@dynamic ContentIdentifier;
@dynamic Author;
@dynamic AverageRating;
@dynamic CoverURL;
@dynamic Title;
@dynamic recommendationItems;
@dynamic state;
@dynamic wishListItems;

@synthesize cachedRecommendationDirectory;

- (void)didTurnIntoFault
{
    [cachedRecommendationDirectory release], cachedRecommendationDirectory = nil;
    [super willTurnIntoFault];
}

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

- (SCHAppRecommendationProcessingState)processingState
{
	return (SCHAppRecommendationProcessingState) [self.state intValue];
}

- (void)setProcessingState:(SCHAppRecommendationProcessingState)processingState
{
    self.state = [NSNumber numberWithInt:processingState];
}

#pragma mark - SCHContentItem overriden implementations

- (NSNumber *)DRMQualifier
{
    return [NSNumber numberWithInt:kSCHDRMQualifiersFullWithDRM];
}

- (NSNumber *)ContentIdentifierType
{
    return [NSNumber numberWithInt:kSCHContentItemContentIdentifierTypesISBN13];
}

#pragma mark - Thumbnail/Cover Caching

- (NSString *)coverImagePath
{
	return [[self recommendationDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@%@.jpg", 
                                                                             self.ContentIdentifier, 
                                                                             kSCHAppRecommendationFilenameSeparator,
                                                                             [NSNumber numberWithInteger:kSCHDRMQualifiersFullWithDRM]]];    
}	

- (NSString *)thumbPathForSize:(CGSize)size
{    
    CGFloat scale = 1.0f;
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        scale = [[UIScreen mainScreen] scale];
    }
    
    NSString *thumbPath = [[self recommendationDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@%@%@%d%@%d", 
                                                                         self.ContentIdentifier, 
                                                                         kSCHAppRecommendationFilenameSeparator,
                                                                         [NSNumber numberWithInteger:kSCHDRMQualifiersFullWithDRM], 
                                                                         kSCHAppRecommendationFilenameSeparator,                                                                         
                                                                         (int)size.width, 
                                                                         kSCHAppRecommendationFilenameSeparator,
                                                                         (int)size.height]];
    if (scale != 1) {
        thumbPath = [thumbPath stringByAppendingFormat:@"@%dx",(int)scale];
    }
    
    thumbPath = [thumbPath stringByAppendingPathExtension:@"png"];
    
	return thumbPath;
}

- (NSString *)recommendationDirectory 
{
    
    if (!cachedRecommendationDirectory) {
        NSString *recommendationDirectory = [[SCHAppRecommendationItem recommendationsDirectory] stringByAppendingPathComponent:self.ContentIdentifier];
        
        NSFileManager *localFileManager = [[NSFileManager alloc] init];
        NSError *error = nil;
        BOOL isDirectory = NO;
        
        if (![localFileManager fileExistsAtPath:recommendationDirectory isDirectory:&isDirectory]) {
            [localFileManager createDirectoryAtPath:recommendationDirectory withIntermediateDirectories:YES attributes:nil error:&error];
            
            if (error) {
                NSLog(@"Warning: problem creating recommendation directory. %@", [error localizedDescription]);
            }
        }
        
        [localFileManager release], localFileManager = nil;
        
        cachedRecommendationDirectory = [recommendationDirectory copy];
    }
    
    return cachedRecommendationDirectory;
}

+ (NSString *)recommendationsDirectory
{
    static dispatch_once_t pred;
	static NSString *cachedRecommendationsDirectory = nil;
	
    dispatch_once(&pred, ^{
        NSString *applicationSupportDirectory = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject];
        cachedRecommendationsDirectory = [[applicationSupportDirectory stringByAppendingPathComponent:@"Recommendations"] retain];
        
        NSFileManager *localFileManager = [[NSFileManager alloc] init];
        NSError *error = nil;
        BOOL isDirectory = NO;
        
        if (![localFileManager fileExistsAtPath:cachedRecommendationsDirectory isDirectory:&isDirectory]) {
            [localFileManager createDirectoryAtPath:cachedRecommendationsDirectory withIntermediateDirectories:YES attributes:nil error:&error];
            
            if (error) {
                NSLog(@"Warning: problem creating recommendations directory. %@", [error localizedDescription]);
            }
        }
        
        [localFileManager release], localFileManager = nil;   
    });
    
	return cachedRecommendationsDirectory;
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

// when there are no wishlist or recommendation items the appRecommendationItem
// gets deleted as well as the on disk files
- (void)deleteAllFiles
{
    NSError *error = nil;
    
    [[SCHRecommendationManager sharedManager] cancelAllOperationsForIsbn:self.ContentIdentifier];
    if ([[NSFileManager defaultManager] removeItemAtPath:[self recommendationDirectory]
                                                   error:&error] == NO) {
        NSLog(@"Failed to delete files for %@, error: %@", 
              self.ContentIdentifier, [error localizedDescription]);
    }
}

@end
