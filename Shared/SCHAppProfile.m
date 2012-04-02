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

// Constants
NSString * const kSCHAppProfile = @"SCHAppProfile";

@interface SCHAppProfile ()

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

- (NSArray *)recommendationDictionaries
{
 /*   
    NSArray *ret = nil;
    NSSet *allItems = [[self recommendationProfile] recommendationItems];
    NSPredicate *readyRecommendations = [NSPredicate predicateWithFormat:@"appRecommendationItem.processingState = %d", kSCHAppRecommendationProcessingStateComplete];
    NSSet *filteredItems = [allItems filteredSetUsingPredicate:readyRecommendations];

    NSMutableArray *objectArray = [NSMutableArray arrayWithCapacity:[filteredItems count]];
    
    for(SCHRecommendationItem *item in filteredItems) {
        NSDictionary *recommendationDictionary = [item.appRecommendationItem dictionary];
        
        if (recommendationDictionary) {
            [objectArray addObject:recommendationDictionary];
        }
    }
    
    ret = [NSArray arrayWithArray:objectArray];
    
    return ret;
    */
    
    NSMutableDictionary *recommendationDict1 = [NSMutableDictionary dictionary];
    
    [recommendationDict1 setValue:@"Be Mine"
                           forKey:kSCHAppRecommendationTitle];
    [recommendationDict1 setValue:@"Book ISBN 1"
                           forKey:kSCHAppRecommendationISBN];
    [recommendationDict1 setValue:@"by Sabrina James"
                           forKey:kSCHAppRecommendationAuthor];
    [recommendationDict1 setValue:[NSNumber numberWithInt:2] 
                           forKey:kSCHAppRecommendationAverageRating];
    [recommendationDict1 setValue:[UIImage imageNamed:@"sampleCoverImage.jpg"]
                           forKey:kSCHAppRecommendationCoverImage];

    NSMutableDictionary *recommendationDict2 = [NSMutableDictionary dictionary];
    
    [recommendationDict2 setValue:@"Marcelo and the Real World"
                           forKey:kSCHAppRecommendationTitle];
    [recommendationDict2 setValue:@"Book ISBN 2"
                           forKey:kSCHAppRecommendationISBN];
    [recommendationDict2 setValue:@"by Francisco X. Stork"
                           forKey:kSCHAppRecommendationAuthor];
    [recommendationDict2 setValue:[NSNumber numberWithInt:5] 
                           forKey:kSCHAppRecommendationAverageRating];
    [recommendationDict2 setValue:[UIImage imageNamed:@"sampleCoverImage.jpg"]
                           forKey:kSCHAppRecommendationCoverImage];

    NSMutableDictionary *recommendationDict3 = [NSMutableDictionary dictionary];
    
    [recommendationDict3 setValue:@"Wish"
                           forKey:kSCHAppRecommendationTitle];
    [recommendationDict3 setValue:@"Book ISBN 3"
                           forKey:kSCHAppRecommendationISBN];
    [recommendationDict3 setValue:@"by Alexandria Bullen"
                           forKey:kSCHAppRecommendationAuthor];
    [recommendationDict3 setValue:[NSNumber numberWithInt:2] 
                           forKey:kSCHAppRecommendationAverageRating];
    [recommendationDict3 setValue:[UIImage imageNamed:@"sampleCoverImage.jpg"]
                           forKey:kSCHAppRecommendationCoverImage];

    return [NSArray arrayWithObjects:recommendationDict1, recommendationDict2, recommendationDict3, nil];
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
            SCHWishListItem *wishListItem = (SCHWishListItem *)[self.managedObjectContext objectRegisteredForID:objectID];
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
