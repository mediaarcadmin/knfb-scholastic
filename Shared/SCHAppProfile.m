//
//  SCHAppProfile.m
//  Scholastic
//
//  Created by John S. Eddie on 06/05/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import "SCHAppProfile.h"

#import "SCHProfileItem.h"
#import "SCHRecommendationItem.h"
#import "SCHAppRecommendationProfile.h"
#import "SCHRecommendationTopRating.h"
#import "SCHRecommendationConstants.h"
#import "SCHWishListItem.h"
#import "SCHWishListProfile.h"
#import "SCHAppRecommendationItem.h"
#import "NSNumber+ObjectTypes.h"
#import "SCHWishListConstants.h"
#import "SCHBooksAssignment.h"
#import "NSNumber+ObjectTypes.h"
#import "SCHRecommendationManager.h"
#import "SCHMakeNullNil.h"

// Constants
NSString * const kSCHAppProfile = @"SCHAppProfile";

@interface SCHAppProfile ()

- (NSSet *)recommendationItems;
- (NSArray *)purchasedBooks;
- (void)save;

@end

@implementation SCHAppProfile

@dynamic AutomaticallyLaunchBook;
@dynamic SelectedTheme;
@dynamic ProfileItem;
@dynamic FontIndex;
@dynamic LayoutType;
@dynamic PaperType;
@dynamic SortType;
@dynamic ShowListView;
@dynamic lastEnteredBookshelfDate;

- (SCHAppRecommendationProfile *)appRecommendationProfile
{
    SCHAppRecommendationProfile *ret = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:kSCHAppRecommendationProfile 
                                        inManagedObjectContext:self.managedObjectContext]];	
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"age = %d", self.ProfileItem.age]];
    
    NSError *error = nil;
    NSArray *profiles = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];	
    if (profiles == nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    } else if ([profiles count] > 0) {
        ret = [profiles objectAtIndex:0];
    }
    
    [fetchRequest release], fetchRequest = nil;        
    
    return ret;
}

- (SCHAppRecommendationTopRating *)appRecommendationTopRating
{
    SCHAppRecommendationTopRating *ret = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    [fetchRequest setEntity:[NSEntityDescription entityForName:kSCHAppRecommendationTopRating
                                        inManagedObjectContext:self.managedObjectContext]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"categoryClass = %@", self.ProfileItem.categoryClass]];

    NSError *error = nil;
    NSArray *topRatings = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (topRatings == nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    } else if ([topRatings count] > 0) {
        ret = [topRatings objectAtIndex:0];
    }

    [fetchRequest release], fetchRequest = nil;

    return ret;
}

- (NSSet *)recommendationItems
{
#if USE_TOP_RATINGS_FOR_PROFILE_RECOMMENDATIONS
    return [[self appRecommendationTopRating] recommendationItems];
#else
    return [[self recommendationProfile] recommendationItems];
#endif
}

// returns an array of isbns
- (NSArray *)purchasedBooks
{
    NSArray *ret = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:kSCHBooksAssignment
                                        inManagedObjectContext:self.managedObjectContext]];	
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"DRMQualifier IN %@", 
                                [NSNumber arrayOfPurchasedDRMQualifiers]]];

    NSError *error = nil;
    NSArray *books = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];	
    if (books == nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    } else {
        ret = [books valueForKeyPath:@"@unionOfObjects.ContentIdentifier"];
    }
    [fetchRequest release], fetchRequest = nil;        
    
    return ret;
}

- (NSArray *)recommendationDictionaries
{
    NSArray *ret = nil;
    NSSet *allItems = [[self appRecommendationProfile] recommendationItems];
    NSPredicate *readyRecommendations = [NSPredicate predicateWithFormat:@"appRecommendationItem.isReady = %d", YES];
    NSArray *filteredItems = [[allItems filteredSetUsingPredicate:readyRecommendations] 
                              sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES]]];

    NSMutableArray *objectArray = [NSMutableArray arrayWithCapacity:[filteredItems count]];
    if ([filteredItems count] > 0) {
        NSArray *purchasedBooks = [self purchasedBooks];
        
        for(SCHRecommendationItem *item in filteredItems) {
            NSDictionary *recommendationDictionary = [item.appRecommendationItem dictionary];
            
            if (recommendationDictionary && 
                [purchasedBooks containsObject:[recommendationDictionary objectForKey:kSCHAppRecommendationItemISBN]] == NO) {
                [objectArray addObject:recommendationDictionary];
            }
        }
    }
    
    ret = [NSArray arrayWithArray:objectArray];
    
    [self processUserAction:allItems];

    return ret;
}

- (void)processUserAction:(NSSet *)recommendations
{
    for (SCHRecommendationItem *item in recommendations) {
        [item.appRecommendationItem processUserAction];
    }

    [self save];
}

- (SCHWishListProfile *)wishListProfile
{
    SCHWishListProfile *ret = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:kSCHWishListProfile 
                                        inManagedObjectContext:self.managedObjectContext]];	
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"ProfileID = %@", self.ProfileItem.ID]];
    
    NSError *error = nil;
    NSArray *profiles = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];	
    if (profiles == nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    } else if ([profiles count] > 0) {
        ret = [profiles objectAtIndex:0];
    }
    
    [fetchRequest release], fetchRequest = nil;        
    
    return ret;
}


- (NSArray *)wishListItemDictionaries
{
    NSArray *ret = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:kSCHWishListItem 
                                        inManagedObjectContext:self.managedObjectContext]];	
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"WishListProfile.ProfileID = %@ AND State != %@", 
                                self.ProfileItem.ID, [NSNumber numberWithStatus:kSCHStatusDeleted]]];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObjects:
                                      [NSSortDescriptor sortDescriptorWithKey:SCHSyncEntityLastModified ascending:NO],
                                      [NSSortDescriptor sortDescriptorWithKey:kSCHWishListTitle ascending:YES],
                                      nil]];
    
    
    NSError *error = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];	
    if (result == nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    } else {
        
        NSArray *purchasedBooks = [self purchasedBooks];
        
        NSMutableArray *objectArray = [NSMutableArray arrayWithCapacity:[result count]];
        
        for (SCHWishListItem *item in result) {
            NSDictionary *wishlistDictionary = [item dictionary];
            if (wishlistDictionary &&
                [purchasedBooks containsObject:[wishlistDictionary objectForKey:kSCHWishListISBN]] == NO) {
                [objectArray addObject:wishlistDictionary];
            }
        }
        
        ret = [NSArray arrayWithArray:objectArray];
    }
    
    [fetchRequest release], fetchRequest = nil;        
    
    return ret;
}

- (void)addToWishList:(NSDictionary *)wishListItem
{
    if (wishListItem != nil) {
        SCHWishListProfile *wishListProfile = [self wishListProfile];
        if (wishListProfile != nil) {
            SCHWishListItem *newWishListItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHWishListItem 
                                                                             inManagedObjectContext:self.managedObjectContext];
            
            newWishListItem.Title = makeNullNil([wishListItem objectForKey:kSCHWishListTitle]);
            newWishListItem.Author = makeNullNil([wishListItem objectForKey:kSCHWishListAuthor]);
            newWishListItem.ISBN = makeNullNil([wishListItem objectForKey:kSCHWishListISBN]);
            newWishListItem.InitiatedBy = kSCHWishListWebServiceCHILD;
            
            [newWishListItem assignAppRecommendationItem];
            
            [wishListProfile addItemListObject:newWishListItem];
            
            [self save];
        }
    }
}

- (void)removeFromWishList:(NSDictionary *)wishListItem
{
    if (wishListItem != nil) {
        NSManagedObjectID *objectID = [wishListItem objectForKey:kSCHWishListObjectID];
        if (objectID != nil) {
            SCHWishListItem *wishListItem = (SCHWishListItem *)[self.managedObjectContext existingObjectWithID:objectID 
                                                                                                         error:nil];
            [wishListItem syncDelete];
            [self save];
        }
    }
}

- (void)save
{
    NSError *error = nil;
    
    if ([self.managedObjectContext hasChanges] == YES &&
        ![self.managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    } 
}

@end
