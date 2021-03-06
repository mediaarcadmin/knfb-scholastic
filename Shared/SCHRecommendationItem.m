//
//  SCHRecommendationItem.m
//  Scholastic
//
//  Created by John Eddie on 13/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHRecommendationItem.h"
#import "SCHAppRecommendationISBN.h"
#import "SCHAppRecommendationProfile.h"
#import "SCHAppRecommendationItem.h"

// Constants
NSString * const kSCHRecommendationItem = @"SCHRecommendationItem";

@implementation SCHRecommendationItem

@dynamic name;
@dynamic link;
@dynamic image_link;
@dynamic regular_price;
@dynamic sale_price;
@dynamic product_code;
@dynamic format;
@dynamic author;
@dynamic order;
@dynamic appRecommendationItem;
@dynamic appRecommendationISBN;
@dynamic appRecommendationProfile;
@dynamic appRecommendationTopRating;

- (void)assignAppRecommendationItem
{
    if (self.product_code != nil) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        [fetchRequest setEntity:[NSEntityDescription entityForName:kSCHAppRecommendationItem 
                                            inManagedObjectContext:self.managedObjectContext]];	
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"ContentIdentifier = %@", self.product_code]];
        
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
            self.appRecommendationItem.ContentIdentifier = self.product_code;
        }
    }
}

- (NSString *)isbn
{
    return [self product_code];
}

+ (BOOL)isValidItemID:(NSString *)itemID
{
    return [[itemID stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0;
}

@end
