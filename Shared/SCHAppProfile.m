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
#import "SCHWishListConstants.h"
#import "SCHAppRecommendationItem.h"
#import "SCHLibreAccessConstants.h"

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

- (NSArray *)recommendations
{
    NSArray *ret = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:kSCHRecommendationItem 
                                        inManagedObjectContext:self.managedObjectContext]];	
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"recommendationProfile.age = %d", self.ProfileItem.age]];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:
                                      [NSSortDescriptor sortDescriptorWithKey:kSCHRecommendationWebServiceOrder ascending:YES]]];
    
    NSError *error = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];	
    if (result == nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    } else {
        NSMutableArray *objectArray = [NSMutableArray arrayWithCapacity:[result count]];
        
        for(SCHRecommendationItem *item in result) {
            NSMutableDictionary *recommendationItem = [NSMutableDictionary dictionary];
            
            [recommendationItem setValue:(item.name == nil ? (id)[NSNull null] : item.name) 
                                  forKey:kSCHRecommendationWebServiceName];
            [recommendationItem setValue:(item.link == nil ? (id)[NSNull null] : item.link) 
                                  forKey:kSCHRecommendationWebServiceLink];
            [recommendationItem setValue:(item.product_code == nil ? (id)[NSNull null] : item.product_code) 
                                  forKey:kSCHRecommendationWebServiceProductCode];
            [recommendationItem setValue:(item.author == nil ? (id)[NSNull null] : item.author) 
                                  forKey:kSCHRecommendationWebServiceAuthor];
            [recommendationItem setValue:[item.appRecommendationItem AverageRatingAsNumber] 
                                  forKey:kSCHLibreAccessWebServiceAverageRating];
            
            [objectArray addObject:[NSDictionary dictionaryWithDictionary:recommendationItem]];
        }
        
        ret = [NSArray arrayWithArray:objectArray];
    }
    
    [fetchRequest release], fetchRequest = nil;        
    
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

- (NSArray *)wishListItems
{
    NSArray *ret = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:kSCHWishListItem 
                                        inManagedObjectContext:self.managedObjectContext]];	
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"WishListProfile.ProfileID = %@", self.ProfileItem.ID]];
    
    NSError *error = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];	
    if (result == nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    } else {
        NSMutableArray *objectArray = [NSMutableArray arrayWithCapacity:[result count]];
        
        for(SCHWishListItem *item in result) {
            NSMutableDictionary *wishListItem = [NSMutableDictionary dictionary];
            
            [wishListItem setValue:(item.Author == nil ? (id)[NSNull null] : item.Author) 
                            forKey:kSCHWishListWebServiceAuthor];
            [wishListItem setValue:(item.ISBN == nil ? (id)[NSNull null] : item.ISBN) 
                            forKey:kSCHWishListWebServiceISBN];
            [wishListItem setValue:(item.Title == nil ? (id)[NSNull null] : item.Title) 
                            forKey:kSCHWishListWebServiceTitle];
            [wishListItem setValue:item.objectID
                            forKey:@"objectID"];
            
            
            [objectArray addObject:[NSDictionary dictionaryWithDictionary:wishListItem]];
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
            
            newWishListItem.Author = [self makeNullNil:[wishListItem objectForKey:kSCHWishListWebServiceAuthor]];
            newWishListItem.InitiatedBy = [self makeNullNil:[wishListItem objectForKey:kSCHWishListWebServiceInitiatedBy]];
            newWishListItem.ISBN = [self makeNullNil:[wishListItem objectForKey:kSCHWishListWebServiceISBN]];
            newWishListItem.Title = [self makeNullNil:[wishListItem objectForKey:kSCHWishListWebServiceTitle]];
            
            [wishListProfile addItemListObject:newWishListItem];
            
            [self save];
        }
    }
}

- (void)removeFromWishList:(NSDictionary *)wishListItem
{
    if (wishListItem != nil) {
        NSManagedObjectID *objectID = [wishListItem objectForKey:@"objectID"];
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
