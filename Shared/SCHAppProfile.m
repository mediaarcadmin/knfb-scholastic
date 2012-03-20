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

// Constants
NSString * const kSCHAppProfile = @"SCHAppProfile";

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
    ret = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];	
    if (ret == nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
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
    ret = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];	
    if (ret == nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    [fetchRequest release], fetchRequest = nil;        
    
    return ret;
}

@end
