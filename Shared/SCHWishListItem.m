//
//  SCHWishListItem.m
//  Scholastic
//
//  Created by John Eddie on 02/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHWishListItem.h"
#import "SCHWishListProfile.h"
#import "SCHAppRecommendationItem.h"

// Constants
NSString * const kSCHWishListItem = @"SCHWishListItem";
NSString * const kSCHWishListTitle = @"Title";
NSString * const kSCHWishListAuthor = @"Author";
NSString * const kSCHWishListISBN = @"ISBN";
NSString * const kSCHWishListAverageRating = @"AverageRating";
NSString * const kSCHWishListFullCoverImagePath = @"FullCoverImagePath";
NSString * const kSCHWishListCoverImage = @"CoverImage";
NSString * const kSCHWishListObjectID = @"objectID";

@implementation SCHWishListItem

@dynamic Author;
@dynamic InitiatedBy;
@dynamic ISBN;
@dynamic Timestamp;
@dynamic Title;
@dynamic WishListProfile;
@dynamic appRecommendationItem;

- (NSDate *)Timestamp
{
    return self.LastModified;
}

- (void)assignAppRecommendationItem
{
    if (self.ISBN != nil) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        [fetchRequest setEntity:[NSEntityDescription entityForName:kSCHAppRecommendationItem 
                                            inManagedObjectContext:self.managedObjectContext]];	
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"ContentIdentifier = %@", self.ISBN]];
        
        NSError *error = nil;
        NSArray *items = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];	
        [fetchRequest release], fetchRequest = nil;  
        
        if (items == nil) {
            NSLog(@"Unresolved error in assignAppRecommendationItem %@, %@", error, [error userInfo]);
        } else if ([items count] > 0) {
            self.appRecommendationItem = [items objectAtIndex:0];
        } else {
            self.appRecommendationItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHAppRecommendationItem 
                                                inManagedObjectContext:self.managedObjectContext];
            self.appRecommendationItem.ContentIdentifier = self.ISBN;
        }
    }
}

- (NSDictionary *)dictionary
{
    NSMutableDictionary *wishListDict = [NSMutableDictionary dictionary];
    SCHAppRecommendationItem *recommendationItem = [self appRecommendationItem];
    
    if ([recommendationItem Title]) {
        [wishListDict setValue:[recommendationItem Title] 
                        forKey:kSCHWishListTitle];
    } else if ([self Title]) {
        [wishListDict setValue:[self Title] 
                        forKey:kSCHWishListTitle];
    }
    
    if ([recommendationItem Author]) {
        [wishListDict setValue:[recommendationItem Author] 
                        forKey:kSCHWishListAuthor];
    } else if ([self Author]) {
        [wishListDict setValue:[self Author]
                        forKey:kSCHWishListAuthor];
    }
    
    if ([recommendationItem ContentIdentifier]) {
        [wishListDict setValue:[recommendationItem ContentIdentifier] 
                        forKey:kSCHWishListISBN];
    } else if ([self ISBN]) {
        [wishListDict setValue:[self ISBN] 
                        forKey:kSCHWishListISBN];
    }

    if ([recommendationItem AverageRating] ) {
        [wishListDict setValue:[recommendationItem AverageRating] 
                        forKey:kSCHWishListAverageRating];
    }
    
    if ([recommendationItem coverImagePath] ) {
        [wishListDict setValue:[recommendationItem coverImagePath] 
                        forKey:kSCHWishListFullCoverImagePath];
    }
    
    UIImage *coverImage = [recommendationItem bookCover];
    
    if (coverImage) {
        [wishListDict setValue:coverImage
                        forKey:kSCHWishListCoverImage];
    }
    
    if ([self objectID]) {
        [wishListDict setValue:[self objectID]
                        forKey:kSCHWishListObjectID];
    }
    
    return wishListDict;
}

+ (BOOL)isValidItemID:(NSString *)itemID
{
    return [[itemID stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0;
}

@end
