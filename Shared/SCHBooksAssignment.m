//
//  SCHBooksAssignment.m
//  Scholastic
//
//  Created by John S. Eddie on 02/08/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHBooksAssignment.h"
#import "SCHContentProfileItem.h"

#import "SCHContentMetadataItem.h"
#import "SCHAppContentProfileItem.h"

// Constants
NSString * const kSCHBooksAssignment = @"SCHBooksAssignment";

@implementation SCHBooksAssignment

@dynamic averageRating;
@dynamic defaultAssignment;
@dynamic format;
@dynamic freeBook;
@dynamic lastOrderDate;
@dynamic lastVersion;
@dynamic quantity;
@dynamic quantityInit;
@dynamic version;
@dynamic numVotes;
@dynamic profileList;

- (NSSet *)ContentMetadataItem
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSError *error = nil;
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:kSCHContentMetadataItem
                                        inManagedObjectContext:self.managedObjectContext]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"ContentIdentifier == %@ AND DRMQualifier == %@",
                                self.ContentIdentifier, self.DRMQualifier]];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    
    NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest
                                                               error:&error];
    [fetchRequest release], fetchRequest = nil;
    if (result == nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }

    // It is no longer the case that isbn and DRM qualifier uniquely identify a book, given that there
    // can now be both a regular and a subscription version of a DRMed book.  So the below assertion is
    // no longer valid.  But if there is more than one version of the book, we only recognize one of them
    // for display purposes and arbitrarily take the first.
    
    //NSAssert([result count] <= 1, @"There should never be more than one SCHContentMetadataItem for a SCHBooksAssignment");
    //return((result == nil ? [NSSet set] : [NSSet setWithArray:result]));
    
    if (result == nil)
        return [NSSet set];
    else if ([result count] == 0)
        return [NSSet setWithArray:result];
    else
        return [NSSet setWithArray:[NSArray arrayWithObject:[result objectAtIndex:0]]];
}

//- (NSSet *)AssignedProfileList
//{
//	return(self.profileList);
//}

- (NSDate *)earlierOpenedDate
{
    NSDate *ret = nil;

    for (SCHContentProfileItem *item in self.profileList) {
        NSDate *lastOpenedDate = item.AppContentProfileItem.lastOpenedDate;
        if (lastOpenedDate != nil &&
            (ret == nil ||
             [ret earlierDate:lastOpenedDate] == lastOpenedDate)) {
                ret = lastOpenedDate;
            }
    }

    return ret;
}

#pragma SCHISBNItem protocol methods

- (BOOL)coverURLOnly
{
    return NO;
}

@end
