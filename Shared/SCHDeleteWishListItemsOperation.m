//
//  SCHDeleteWishListItemsOperation.m
//  Scholastic
//
//  Created by John Eddie on 25/06/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHDeleteWishListItemsOperation.h"

#import "SCHWishListSyncComponent.h"
#import "SCHWishListConstants.h"
#import "SCHWishListItem.h"
#import "BITAPIError.h" 

@interface SCHDeleteWishListItemsOperation ()

- (void)processDeletedWishListItems:(NSArray *)wishListItems;

@end

@implementation SCHDeleteWishListItemsOperation

- (void)main
{
    @try {
        NSDictionary *deleteWishListItems = [self makeNullNil:[self.result objectForKey:kSCHWishListWebServiceDeleteWishListItems]];
        NSArray *profileStatusList = [self makeNullNil:[deleteWishListItems objectForKey:kSCHWishListWebServiceProfileStatusList]];                
        
        if ([profileStatusList count] > 0) {
            [self processDeletedWishListItems:profileStatusList];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.isCancelled == NO) {
                [(SCHWishListSyncComponent *)self.syncComponent deleteWishListItemsCompletion];
            }
        });                
    }
    @catch (NSException *exception) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.isCancelled == NO) {
                NSError *error = [NSError errorWithDomain:kBITAPIErrorDomain 
                                                     code:kBITAPIExceptionError 
                                                 userInfo:[NSDictionary dictionaryWithObject:[exception reason]
                                                                                      forKey:NSLocalizedDescriptionKey]];
                [self.syncComponent completeWithFailureMethod:kSCHWishListWebServiceDeleteWishListItems 
                                                        error:error 
                                                  requestInfo:nil 
                                                       result:self.result 
                                             notificationName:SCHWishListSyncComponentDidFailNotification 
                                         notificationUserInfo:nil];                
            }
        });   
    }                    
}

- (void)processDeletedWishListItems:(NSArray *)wishListItems
{
    if ([wishListItems count] > 0) {
        for (NSDictionary *wishListItem in wishListItems) {
            NSNumber *profileID = [self makeNullNil:[wishListItem objectForKey:kSCHWishListWebServiceProfileID]];
            if ([profileID integerValue] > 0) {
                for (NSDictionary *item in [self makeNullNil:[wishListItem objectForKey:kSCHWishListWebServiceItemStatusList]]) {
                    NSString *isbn = [self makeNullNil:[item objectForKey:kSCHWishListWebServiceISBN]];
                    NSDictionary *wishListError = [self makeNullNil:[item objectForKey:kSCHWishListWebServiceWishListError]];
                    if (wishListError != nil) {
                        NSNumber *errorCode = [self makeNullNil:[wishListError objectForKey:kSCHWishListWebServiceErrorCode]];
                        
                        if (isbn != nil && errorCode != nil && [errorCode integerValue] == 0) {
                            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                            NSError *error = nil;
                            
                            [fetchRequest setEntity:[NSEntityDescription entityForName:kSCHWishListItem 
                                                                inManagedObjectContext:self.backgroundThreadManagedObjectContext]];	
                            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:
                                                        @"ISBN = %@ AND WishListProfile.ProfileID = %@", isbn, profileID]];
                            
                            NSArray *localWishListItem = [self.backgroundThreadManagedObjectContext executeFetchRequest:fetchRequest error:&error];	
                            [fetchRequest release], fetchRequest = nil;
                            if (localWishListItem == nil) {
                                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                            } else if ([localWishListItem count] > 0) {
                                [self.backgroundThreadManagedObjectContext deleteObject:[localWishListItem objectAtIndex:0]];
                            }
                        }
                    }
                }
            }
        }
        [self saveWithManagedObjectContext:self.backgroundThreadManagedObjectContext];
    }
}

@end
