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
#import "NSFileManager+Extensions.h"

// Constants
NSString * const kSCHAppRecommendationItem = @"SCHAppRecommendationItem";
NSString * const kSCHAppRecommendationItemIsbn = @"isbn";
NSString * const kSCHAppRecommendationItemErrorCode = @"errorCode";
NSString * const kSCHAppRecommendationFilenameSeparator = @"-";
NSUInteger const kSCHRecommendationThumbnailMaxDimensionPad = 140;
NSUInteger const kSCHRecommendationThumbnailMaxDimensionPhone = 134;

NSString * const kSCHAppRecommendationItemTitle = @"Title";
NSString * const kSCHAppRecommendationItemAuthor = @"Author";
NSString * const kSCHAppRecommendationItemISBN = @"ISBN";
NSString * const kSCHAppRecommendationItemAverageRating = @"AverageRating";
NSString * const kSCHAppRecommendationItemCoverImage = @"CoverImage";
NSString * const kSCHAppRecommendationItemFullCoverImagePath = @"FullCoverImagePath";

@interface SCHAppRecommendationItem()

@property (nonatomic, copy) NSString *cachedRecommendationDirectory;

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
@dynamic coverURLExpiredCount;

@synthesize cachedRecommendationDirectory;

- (void)didTurnIntoFault
{
    [cachedRecommendationDirectory release], cachedRecommendationDirectory = nil;
    [super didTurnIntoFault];
}

- (SCHAppRecommendationProcessingState)processingState
{
	return (SCHAppRecommendationProcessingState) [self.state intValue];
}

- (void)setProcessingState:(SCHAppRecommendationProcessingState)processingState
{
    self.state = [NSNumber numberWithInt:processingState];
}

#pragma SCHISBNItem protocol methods

- (NSNumber *)DRMQualifier
{
    return [NSNumber numberWithInt:kSCHDRMQualifiersFullWithDRM];
}

- (NSNumber *)ContentIdentifierType
{
    return [NSNumber numberWithInt:kSCHContentItemContentIdentifierTypesISBN13];
}

- (BOOL)coverURLOnly
{
    return YES;
}

#pragma mark - Thumbnail/Cover Caching

- (NSString *)coverImagePath
{
	return [[self recommendationDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@%@.jpg", 
                                                                             self.ContentIdentifier, 
                                                                             kSCHAppRecommendationFilenameSeparator,
                                                                             [NSNumber numberWithInteger:kSCHDRMQualifiersFullWithDRM]]];    
}	

- (NSString *)thumbPath
{    
    CGFloat scale = 1.0f;
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        scale = [[UIScreen mainScreen] scale];
    }
    
    NSUInteger maxDimension;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        maxDimension = kSCHRecommendationThumbnailMaxDimensionPad;
    } else {
        maxDimension = kSCHRecommendationThumbnailMaxDimensionPhone;
    }
    
    NSString *thumbPath = [[self recommendationDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@%@%@%d", 
                                                                         self.ContentIdentifier, 
                                                                         kSCHAppRecommendationFilenameSeparator,
                                                                         [NSNumber numberWithInteger:kSCHDRMQualifiersFullWithDRM], 
                                                                         kSCHAppRecommendationFilenameSeparator,                                                                         
                                                                         maxDimension]];
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

- (UIImage *)bookCover
{
    UIImage *ret = nil;
    NSData *imageData = [NSData dataWithContentsOfMappedFile:[self thumbPath]];
    
    if (imageData) {
        ret = [UIImage imageWithData:imageData];
    }
    
    return ret;
}

- (BOOL)isInUse
{
    return ([self.recommendationItems count] > 0 ||
            [self.wishListItems count] > 0);
}

- (BOOL)isReady
{
    BOOL isReady = NO;
    
    // N.B. This is a pretty loose definition of isReady. Provided we don't have an unexpected error and have got back a non-error response from LD that the book is in their system
    // we allow the recommendation to be show, even if there was a problem getting the cover URLs, the cover or generating the thumbnails
    switch ([self processingState]) {
        case kSCHAppRecommendationProcessingStateUnspecifiedError:               
        case kSCHAppRecommendationProcessingStateWaitingOnUserAction:  
        case kSCHAppRecommendationProcessingStateInvalidRecommendation:
        case kSCHAppRecommendationProcessingStateNoMetadata:
            isReady = NO;
            break;
        case kSCHAppRecommendationProcessingStateThumbnailError:      
        case kSCHAppRecommendationProcessingStateCachedCoverError:    
        case kSCHAppRecommendationProcessingStateURLsNotPopulated:
        case kSCHAppRecommendationProcessingStateDownloadFailed:
        case kSCHAppRecommendationProcessingStateNoCover:
        case kSCHAppRecommendationProcessingStateNoThumbnails:
        case kSCHAppRecommendationProcessingStateComplete:
            isReady = YES;
            break;
    }
    
    return isReady;
}

// when there are no wishlist or recommendation items the appRecommendationItem
// gets deleted as well as the on disk files
- (void)deleteAllFiles
{
    NSString *recommendationDirectory = [self recommendationDirectory];
    NSString *contentIdentifier = [[self.ContentIdentifier copy] autorelease];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{    
        NSError *error = nil;
        NSFileManager *localManager = [[[NSFileManager alloc] init] autorelease];
        NSString *temporaryDirectory = [NSFileManager BITtemporaryDirectoryIfExistsOrCreated];
        NSString *temporaryRecommendationDirectory = nil;

        // wait till any processing of this book has finished        
        [[SCHRecommendationManager sharedManager] cancelAllOperationsForIsbn:contentIdentifier
                                                           waitUntilFinished:YES];

        // if possible move the directory to tmp while we delete it
        if (temporaryDirectory != nil) {
            CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
            NSString *uniqueDirectoryName = (NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
            [uniqueDirectoryName autorelease];
            CFRelease(uuid);
            
            temporaryRecommendationDirectory = [temporaryDirectory stringByAppendingPathComponent:uniqueDirectoryName];
            
            if ([localManager moveItemAtPath:recommendationDirectory 
                                      toPath:temporaryRecommendationDirectory error:&error] == NO) {
                NSLog(@"Unable to create tempory directory for deleted appRecommendationItem files with error %@ : %@", error, [error userInfo]);
                temporaryRecommendationDirectory = nil;
            }
        }

        if ([localManager removeItemAtPath:(temporaryRecommendationDirectory != nil ? temporaryRecommendationDirectory : recommendationDirectory)
                                     error:&error] == NO) {
            NSLog(@"Failed to delete files for %@, error: %@", 
                  contentIdentifier, [error localizedDescription]);
        }
    });
}

- (NSDictionary *)dictionary {
    NSMutableDictionary *recommendationDict = [NSMutableDictionary dictionary];
    
    if ([self Title]) {
        [recommendationDict setValue:[self Title] 
                              forKey:kSCHAppRecommendationItemTitle];
    } else {
        for (SCHRecommendationItem *item in [self recommendationItems]) {
            if ([[item name] length] > 0) {
                [recommendationDict setValue:[item name] 
                                      forKey:kSCHAppRecommendationItemTitle];
                break;
            }
        }
    }
    
    if ([self ContentIdentifier]) {
        [recommendationDict setValue:[self ContentIdentifier] 
                              forKey:kSCHAppRecommendationItemISBN];
    }
    
    if ([self Author]) {
        [recommendationDict setValue:[self Author]
                              forKey:kSCHAppRecommendationItemAuthor];
    } else {
        for (SCHRecommendationItem *item in [self recommendationItems]) {
            if ([[item author] length] > 0) {
                [recommendationDict setValue:[item author] 
                                      forKey:kSCHAppRecommendationItemAuthor];
                break;
            }
        }
    }
    
    if ([self AverageRating]) {
        [recommendationDict setValue:[self AverageRating] 
                              forKey:kSCHAppRecommendationItemAverageRating];
    }
    
    if ([self coverImagePath]) {
        [recommendationDict setValue:[self coverImagePath] 
                              forKey:kSCHAppRecommendationItemFullCoverImagePath];
    }
    
    UIImage *coverImage = [self bookCover];
    
    if (coverImage) {
        [recommendationDict setValue:coverImage
                              forKey:kSCHAppRecommendationItemCoverImage];
    }
    
    return recommendationDict;

}

#pragma mark Class methods

+ (void)purgeUnusedAppRecommendationItemsUsingManagedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
{
    NSParameterAssert(aManagedObjectContext);
    
    if (aManagedObjectContext != nil) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:kSCHAppRecommendationItem 
                                                  inManagedObjectContext:aManagedObjectContext];
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"recommendationItems.@count < 1 AND wishListItems.@count < 1"]];    
        
        NSError *error = nil;
        NSArray *fetchedObjects = [aManagedObjectContext executeFetchRequest:fetchRequest 
                                                                       error:&error];
        if (fetchedObjects == nil) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        } else if ([fetchedObjects count] > 1) {
            for (SCHAppRecommendationItem *appRecommendationItem in fetchedObjects) {
                [appRecommendationItem deleteAllFiles];
                [aManagedObjectContext deleteObject:appRecommendationItem];
            }
            
            if ([aManagedObjectContext save:&error] == NO) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            } 
        }
        
        [fetchRequest release], fetchRequest = nil;
    }
}

@end
