//
//  SCHWishListSyncComponent.m
//  Scholastic
//
//  Created by John Eddie on 23/02/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHWishListSyncComponent.h"

#import "SCHWishListWebService.h"
#import "SCHWishListConstants.h"
#import "SCHAccountValidation.h"
#import "SCHUserDefaults.h"
#import "SFHFKeychainUtils.h"
#import "SCHProfileItem.h"

// Constants
NSString * const SCHWishListSyncComponentDidCompleteNotification = @"SCHWishListSyncComponentDidCompleteNotification";
NSString * const SCHWishListSyncComponentDidFailNotification = @"SCHWishListSyncComponentDidFailNotification";

@interface SCHWishListSyncComponent ()

- (NSArray *)localProfiles;

@end

@implementation SCHWishListSyncComponent

- (BOOL)synchronize
{
	BOOL ret = YES;

    SCHWishListWebService *wishListWebService = [[SCHWishListWebService alloc] init];
    wishListWebService.delegate = self;

    SCHAccountValidation *accountValidation = [[SCHAccountValidation alloc] init];
    
    NSString *storedUsername = [[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerUsername];
    NSString *storedPassword = [SFHFKeychainUtils getPasswordForUsername:storedUsername andServiceName:@"Scholastic" error:nil];

    NSString *pToken = [SCHAuthenticationManager sharedAuthenticationManager].pToken;
    
    if (pToken == nil) {
        [accountValidation validateWithUserName:storedUsername withPassword:storedPassword validateBlock:^(NSString *pToken2, NSError *error) {
            if (error != nil) {
                //            [weakSelf authenticationDidFailWithError:error];                            
            } else {
                NSArray *profiles = [self localProfiles];
                if ([profiles count] > 0) {
                    NSMutableArray *profileIDs = [NSMutableArray arrayWithCapacity:[profiles count]];
                    for (id item in profiles) {
                        [profileIDs addObject:[item valueForKey:kSCHLibreAccessWebServiceID]];
                    }
            
//                                        [wishListWebService getWishListItems:pToken2 profiles:profileIDs];            
                    
                    NSMutableDictionary *wlpi = [NSMutableDictionary dictionary];
                    NSMutableDictionary *wli = [NSMutableDictionary dictionary];
                    NSMutableDictionary *ib = [NSMutableDictionary dictionary];

                    [ib setObject:@"CHILD" forKey:kSCHWishListWebServiceValue];
                    
                    [wli setObject:@"Norman Bridwell" forKey:kSCHWishListWebServiceAuthor];
                    [wli setObject:ib forKey:kSCHWishListWebServiceInitiatedBy];                    
                    [wli setObject:@"9780545323024" forKey:kSCHWishListWebServiceISBN];
                    [wli setObject:[NSDate date] forKey:kSCHWishListWebServiceTimestamp];
                    [wli setObject:@"Clifford's Good Deeds" forKey:kSCHWishListWebServiceTitle];
                    
                    NSMutableDictionary *profile = [NSMutableDictionary dictionary];
                    
                    NSDictionary *p = [profiles objectAtIndex:0];
                    [profile setObject:[p valueForKey:kSCHLibreAccessWebServiceID] forKey:kSCHWishListWebServiceProfileID];
                    [profile setObject:[p valueForKey:kSCHLibreAccessWebServiceScreenName] forKey:kSCHWishListWebServiceProfileName];
                    [profile setObject:[NSDate date] forKey:kSCHWishListWebServiceTimestamp];
                    
                    [wlpi setObject:[NSArray arrayWithObject:wli] forKey:kSCHWishListWebServiceItemList];
                    [wlpi setObject:profile forKey:kSCHWishListWebServiceProfile];                    

                    [wishListWebService addItemsToWishList:pToken2 wishListItems:[NSArray arrayWithObject:wlpi]];      
                    
//                    [wishListWebService deleteWishList:pToken2 wishListProfiles:[NSArray arrayWithObject:profile]];
                    
                    NSMutableDictionary *pi = [NSMutableDictionary dictionary];
                    [pi setObject:[NSArray arrayWithObject:wli] forKey:kSCHWishListWebServiceItemList];
                    [pi setObject:profile forKey:kSCHWishListWebServiceProfile];
                    
//                    [wishListWebService deleteWishListItems:pToken2 wishListItems:[NSArray arrayWithObject:pi]];
                    
                }
            }
        }];
    } else {
        NSArray *profiles = [self localProfiles];
        if ([profiles count] > 0) {
            NSMutableArray *profileIDs = [NSMutableArray arrayWithCapacity:[profiles count]];
            for (SCHProfileItem *item in profiles) {
                [profileIDs addObject:item.ID];
            }
            
            [wishListWebService getWishListItems:pToken profiles:profileIDs];            
        }        
    }

    self.isSynchronizing = YES;
    
	return(ret);	
}

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result 
      userInfo:(NSDictionary *)userInfo
{	
    NSLog(@"%@:didCompleteWithResult\n%@", method, result);
//    @try {
//        if([method compare:kSCHLibreAccessWebServiceSaveUserProfiles] == NSOrderedSame) {
//            [self processSaveUserProfilesWithResult:result];
//        } else if([method compare:kSCHLibreAccessWebServiceGetUserProfiles] == NSOrderedSame) {
//            [self syncProfiles:[result objectForKey:kSCHLibreAccessWebServiceProfileList]];
//            [[NSNotificationCenter defaultCenter] postNotificationName:SCHProfileSyncComponentDidCompleteNotification 
//                                                                object:self];		
//            [super method:method didCompleteWithResult:result userInfo:userInfo];	
//        }
//    }
//    @catch (NSException *exception) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:SCHProfileSyncComponentDidFailNotification 
//                                                            object:self];		    
//        NSError *error = [NSError errorWithDomain:kBITAPIErrorDomain 
//                                             code:kBITAPIExceptionError 
//                                         userInfo:[NSDictionary dictionaryWithObject:[exception reason]
//                                                                              forKey:NSLocalizedDescriptionKey]];
//        [super method:method didFailWithError:error requestInfo:nil result:result];
//        [self.savedProfiles removeAllObjects];        
//    }
}

- (void)method:(NSString *)method didFailWithError:(NSError *)error 
   requestInfo:(NSDictionary *)requestInfo
        result:(NSDictionary *)result
{
    NSLog(@"%@:didFailWithError\n%@", method, error);
    
    // server error so process the result
//    if ([error domain] == kBITAPIErrorDomain && 
//        [method compare:kSCHLibreAccessWebServiceSaveUserProfiles] == NSOrderedSame) {
//        [self processSaveUserProfilesWithResult:result];
//    } else {
//        [[NSNotificationCenter defaultCenter] postNotificationName:SCHProfileSyncComponentDidFailNotification 
//                                                            object:self];		    
//        [super method:method didFailWithError:error requestInfo:requestInfo result:result];
//    }
//    [self.savedProfiles removeAllObjects];
}

- (NSArray *)localProfiles
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSError *error = nil;
	
	[fetchRequest setEntity:[NSEntityDescription entityForName:kSCHProfileItem inManagedObjectContext:self.managedObjectContext]];	
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceID ascending:YES]]];
	
	NSArray *ret = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];	
	[fetchRequest release], fetchRequest = nil;
    if (ret == nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
	
	return(ret);
}

@end
