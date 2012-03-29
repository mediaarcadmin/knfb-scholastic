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
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        } else if ([items count] > 0) {
            self.appRecommendationItem = [items objectAtIndex:0];
        } else {
            self.appRecommendationItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHAppRecommendationItem 
                                                inManagedObjectContext:self.managedObjectContext];
            self.appRecommendationItem.ContentIdentifier = self.ISBN;
        }
    }
}

@end
