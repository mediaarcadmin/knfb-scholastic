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

- (NSArray *)recommendations
{
    NSArray *ret = nil;
    NSNumber *profileID = self.ProfileItem.ID;
    
    if ([profileID integerValue] > 0) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        [fetchRequest setEntity:[NSEntityDescription entityForName:kSCHRecommendationItem 
                                            inManagedObjectContext:self.managedObjectContext]];	
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"recommendationProfile.profileID = %@", profileID]];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:
                                          [NSSortDescriptor sortDescriptorWithKey:kSCHRecommendationOrder ascending:YES]]];
        
        NSError *error = nil;
        ret = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];	
        if (ret == nil) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
        
        [fetchRequest release], fetchRequest = nil;        
    }
    
    return ret;
}


@end
