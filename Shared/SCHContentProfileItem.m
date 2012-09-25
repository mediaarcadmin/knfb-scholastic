// 
//  SCHContentProfileItem.m
//  Scholastic
//
//  Created by John S. Eddie on 31/01/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import "SCHContentProfileItem.h"

#import "SCHAnnotationsContentItem.h"
#import "SCHReadingStatsContentItem.h"
#import "SCHBookIdentifier.h"
#import "SCHProfileItem.h"

// Constants
NSString * const kSCHContentProfileItem = @"SCHContentProfileItem";

@implementation SCHContentProfileItem 

@dynamic ProfileID;
@dynamic LastPageLocation;
@dynamic booksAssignment;
@dynamic AppContentProfileItem;
@dynamic Rating;

- (NSSet *)ProfileItem
{
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    NSError *error = nil;

    [fetchRequest setEntity:[NSEntityDescription entityForName:kSCHProfileItem
                                        inManagedObjectContext:self.managedObjectContext]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"ID == %@",
                                self.ProfileID]];


    NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest
                                                               error:&error];
    if (result == nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }

    return((result == nil ? [NSSet set] : [NSSet setWithArray:result]));
}


- (void)deleteAnnotationsForBook:(SCHBookIdentifier *)bookIdentifier
{
    if (self.ProfileID != nil && bookIdentifier != nil) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init]; 
        NSError *error = nil;
        
        [fetchRequest setEntity:[NSEntityDescription entityForName:kSCHAnnotationsContentItem 
                                            inManagedObjectContext:self.managedObjectContext]];	                                                                            
        [fetchRequest setPredicate:
         [NSPredicate predicateWithFormat:@"ContentIdentifier == %@ AND DRMQualifier == %@ AND AnnotationsItem.ProfileID == %@", 
          bookIdentifier.isbn, bookIdentifier.DRMQualifier, self.ProfileID]];    
        
        NSArray *books = [self.managedObjectContext executeFetchRequest:fetchRequest 
                                                                  error:&error];
        [fetchRequest release], fetchRequest = nil;
        if (books == nil) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }

        if ([books count] > 0) {
            [self.managedObjectContext deleteObject:[books objectAtIndex:0]];
        }
    }    
}

- (void)deleteStatisticsForBook:(SCHBookIdentifier *)bookIdentifier
{
    if (self.ProfileID != nil && bookIdentifier != nil) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init]; 
        NSError *error = nil;
        
        [fetchRequest setEntity:[NSEntityDescription entityForName:kSCHReadingStatsContentItem 
                                            inManagedObjectContext:self.managedObjectContext]];	                                                                            
        [fetchRequest setPredicate:
         [NSPredicate predicateWithFormat:@"ContentIdentifier == %@ AND DRMQualifier == %@ AND ReadingStatsDetailItem.ProfileID == %@", 
          bookIdentifier.isbn, bookIdentifier.DRMQualifier, self.ProfileID]];    
        
        NSArray *books = [self.managedObjectContext executeFetchRequest:fetchRequest 
                                                                  error:&error];
        [fetchRequest release], fetchRequest = nil;
        if (books == nil) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }

        if ([books count] > 0) {
            [self.managedObjectContext deleteObject:[books objectAtIndex:0]];
        }
    }
}

@end
