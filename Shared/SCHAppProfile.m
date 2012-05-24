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
#import "SCHRecommendationProfile.h"
#import "SCHRecommendationConstants.h"
#import "SCHWishListItem.h"
#import "SCHWishListProfile.h"
#import "SCHAppRecommendationItem.h"
#import "NSNumber+ObjectTypes.h"
#import "SCHWishListConstants.h"
#import "SCHUserContentItem.h"
#import "NSNumber+ObjectTypes.h"

// Constants
NSString * const kSCHAppProfile = @"SCHAppProfile";

@interface SCHAppProfile ()

- (NSArray *)purchasedBooks;
- (id)makeNullNil:(id)object;
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

- (SCHRecommendationProfile *)recommendationProfile
{
    SCHRecommendationProfile *ret = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:kSCHRecommendationProfile 
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

// returns an array of isbns
- (NSArray *)purchasedBooks
{
    NSArray *ret = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:kSCHUserContentItem 
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
    NSSet *allItems = [[self recommendationProfile] recommendationItems];
    NSPredicate *readyRecommendations = [NSPredicate predicateWithFormat:@"appRecommendationItem.isReady = %d", YES];
    NSArray *filteredItems = [[allItems filteredSetUsingPredicate:readyRecommendations] 
                              sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES]]];

    NSMutableArray *objectArray = [NSMutableArray arrayWithCapacity:[filteredItems count]];
    if ([filteredItems count] > 0) {
        NSArray *purchasedBooks = [self purchasedBooks];
        
        for(SCHRecommendationItem *item in filteredItems) {
            NSDictionary *recommendationDictionary = [item.appRecommendationItem dictionary];
            
            if (recommendationDictionary && 
                [purchasedBooks containsObject:[recommendationDictionary objectForKey:kSCHAppRecommendationISBN]] == NO) {
                [objectArray addObject:recommendationDictionary];
            }
        }
    }
    
    ret = [NSArray arrayWithArray:objectArray];
    
    return ret;
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
        NSMutableArray *objectArray = [NSMutableArray arrayWithCapacity:[result count]];
        
        for (SCHWishListItem *item in result) {
            NSDictionary *wishlistDictionary = [item dictionary];
            if (wishlistDictionary) {
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
            
            newWishListItem.Title = [self makeNullNil:[wishListItem objectForKey:kSCHWishListTitle]];
            newWishListItem.Author = [self makeNullNil:[wishListItem objectForKey:kSCHWishListAuthor]];
            newWishListItem.ISBN = [self makeNullNil:[wishListItem objectForKey:kSCHWishListISBN]];
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

- (id)makeNullNil:(id)object
{
	return(object == [NSNull null] ? nil : object);
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
