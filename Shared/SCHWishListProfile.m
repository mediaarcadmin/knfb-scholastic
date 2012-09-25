//
//  SCHWishListProfile.m
//  Scholastic
//
//  Created by John Eddie on 02/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHWishListProfile.h"

#import "SCHProfileItem.h"

NSString * const kSCHWishListProfile = @"SCHWishListProfile";

@implementation SCHWishListProfile

@dynamic ProfileID;
@dynamic ProfileName;
@dynamic ItemList;

- (SCHProfileItem *)profileItem
{
    SCHProfileItem *ret = nil;
    NSError *error = nil;

    if (self.ProfileID != nil) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

        [fetchRequest setEntity:[NSEntityDescription entityForName:kSCHProfileItem
                                            inManagedObjectContext:self.managedObjectContext]];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"ID == %@", self.ProfileID]];

        NSArray *profiles = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        [fetchRequest release];
        if (profiles == nil) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        } else if ([profiles count] > 0) {
            ret = [profiles objectAtIndex:0];
        }
    }

    return ret;
}

- (NSString *)profileNameFromProfileItem
{
    NSString *ret = nil;
    SCHProfileItem *profileItem = [self profileItem];

    if (profileItem != nil) {
        NSString *name = [profileItem displayName];
        if ([[name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
            ret = name;
        }
    }

    return ret;
}

- (NSDate *)Timestamp
{
    return self.LastModified;
}

+ (BOOL)isValidProfileID:(NSNumber *)profileID
{
    return [profileID integerValue] > 0;
}

@end
