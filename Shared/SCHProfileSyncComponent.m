//
//  SCHProfileSyncComponent.m
//  Scholastic
//
//  Created by John S. Eddie on 04/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHProfileSyncComponent.h"
#import "SCHSyncComponentProtected.h"
#import "NSManagedObjectContext+Extensions.h"

#import "SCHProfileItem.h"
#import "BITAPIError.h"
#import "SCHAppProfile.h"
#import "SCHLibreAccessWebService.h"
#import "SCHWishListProfile.h"
#import "SCHWishListItem.h"
#import "SCHWishListSyncComponent.h"
#import "SCHGetUserProfilesResponseOperation.h"
#import "SCHSaveUserProfilesOperation.h"

// Constants
NSString * const SCHProfileSyncComponentWillDeleteNotification = @"SCHProfileSyncComponentWillDeleteNotification";
NSString * const SCHProfileSyncComponentDeletedProfileIDs = @"SCHProfileSyncComponentDeletedProfileIDs";
NSString * const SCHProfileSyncComponentDidCompleteNotification = @"SCHProfileSyncComponentDidCompleteNotification";
NSString * const SCHProfileSyncComponentDidFailNotification = @"SCHProfileSyncComponentDidFailNotification";

@interface SCHProfileSyncComponent ()

@property (nonatomic, retain) SCHLibreAccessWebService *libreAccessWebService;

- (void)trackProfileSaves:(NSArray *)profilesArray;
- (BOOL)requestSaveUserProfiles:(NSArray *)updatedProfiles;
- (BOOL)updateProfiles;
- (NSArray *)localProfilesWithManagedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;

@end

@implementation SCHProfileSyncComponent

@synthesize libreAccessWebService;
@synthesize savedProfiles;

- (id)init 
{
    self = [super init];
    if (self) {
        libreAccessWebService = [[SCHLibreAccessWebService alloc] init];	
		libreAccessWebService.delegate = self;

        savedProfiles = [[NSMutableArray array] retain];
    }
    return self;
}

- (void)dealloc 
{
    libreAccessWebService.delegate = nil;
	[libreAccessWebService release], libreAccessWebService = nil;
    
    [savedProfiles release], savedProfiles = nil;
    [super dealloc];
}

- (BOOL)synchronize
{
	BOOL ret = YES;
	
	if (self.isSynchronizing == NO) {
        [self beginBackgroundTask];
		
		ret = [self updateProfiles];	
        if (ret == NO) {
            [self endBackgroundTask];
        }         
	}

	return(ret);	
}
#pragma - Overrideen methods used by resetSync

- (void)resetWebService
{
    [self.libreAccessWebService clear];    
}

- (void)clearComponent
{
    [self.savedProfiles removeAllObjects];    
}

- (void)clearCoreData
{
	NSError *error = nil;
    
	if (![self.managedObjectContext BITemptyEntity:kSCHProfileItem error:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}		
}

#pragma mark - Delegate methods

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result 
      userInfo:(NSDictionary *)userInfo
{	
    @try {
        if([method compare:kSCHLibreAccessWebServiceSaveUserProfiles] == NSOrderedSame) {
            SCHSaveUserProfilesOperation *operation = [[[SCHSaveUserProfilesOperation alloc] initWithSyncComponent:self
                                                                                                            result:result
                                                                                                          userInfo:userInfo] autorelease];
            [operation setThreadPriority:SCHSyncComponentThreadLowPriority];
            [self.backgroundProcessingQueue addOperation:operation];
        } else if([method compare:kSCHLibreAccessWebServiceGetUserProfiles] == NSOrderedSame) {
            SCHGetUserProfilesResponseOperation *operation = [[[SCHGetUserProfilesResponseOperation alloc] initWithSyncComponent:self
                                                                                                                         result:result
                                                                                                                       userInfo:userInfo] autorelease];
            [operation setThreadPriority:SCHSyncComponentThreadLowPriority];
            [self.backgroundProcessingQueue addOperation:operation];
        }
    }
    @catch (NSException *exception) {
        NSError *error = [NSError errorWithDomain:kBITAPIErrorDomain 
                                             code:kBITAPIExceptionError 
                                         userInfo:[NSDictionary dictionaryWithObject:[exception reason]
                                                                              forKey:NSLocalizedDescriptionKey]];
        [self completeWithFailureMethod:method 
                                  error:error 
                            requestInfo:nil 
                                 result:result 
                       notificationName:SCHProfileSyncComponentDidFailNotification
                   notificationUserInfo:nil];
        [self.savedProfiles removeAllObjects];        
    }
}

// track profiles that need to be saved
- (void)trackProfileSaves:(NSArray *)profilesArray
{
    for (SCHProfileItem *profile in profilesArray) {
        if ([profile.Action saveActionValue] != kSCHSaveActionsNone) {
            [self.savedProfiles addObject:[profile objectID]];
        }
    }
}

- (BOOL)requestSaveUserProfiles:(NSArray *)updatedProfiles
{
    BOOL ret = YES;
    
    [self trackProfileSaves:updatedProfiles];
    
    self.isSynchronizing = [self.libreAccessWebService saveUserProfiles:updatedProfiles];
    if (self.isSynchronizing == NO) {
        [[SCHAuthenticationManager sharedAuthenticationManager] authenticateWithSuccessBlock:^(SCHAuthenticationManagerConnectivityMode connectivityMode){
            if (connectivityMode == SCHAuthenticationManagerConnectivityModeOnline) {
                [self.delegate authenticationDidSucceed];
            } else {
                self.isSynchronizing = NO;
            }
        } failureBlock:^(NSError *error){
            self.isSynchronizing = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:SCHSyncComponentDidFailAuthenticationNotification
                                                                object:self];                
        }];				
        ret = NO;			
    }		

    return ret;
}

- (BOOL)requestUserProfiles
{
    BOOL ret = YES;
    
    if (self.saveOnly == NO) {
        self.isSynchronizing = [self.libreAccessWebService getUserProfiles];
        if (self.isSynchronizing == NO) {
            [[SCHAuthenticationManager sharedAuthenticationManager] authenticateWithSuccessBlock:^(SCHAuthenticationManagerConnectivityMode connectivityMode){
                if (connectivityMode == SCHAuthenticationManagerConnectivityModeOnline) {
                    [self.delegate authenticationDidSucceed];
                } else {
                    self.isSynchronizing = NO;
                }
            } failureBlock:^(NSError *error){
                self.isSynchronizing = NO;
                [[NSNotificationCenter defaultCenter] postNotificationName:SCHSyncComponentDidFailAuthenticationNotification
                                                                    object:self];            
            }];	
			ret = NO;
        }	
    } else {
        [self completeWithSuccessMethod:nil 
                                 result:nil 
                               userInfo:nil 
                       notificationName:SCHProfileSyncComponentDidCompleteNotification
                   notificationUserInfo:nil];
    }
    
    return ret;
}

- (void)method:(NSString *)method didFailWithError:(NSError *)error 
   requestInfo:(NSDictionary *)requestInfo
        result:(NSDictionary *)result
{
    NSLog(@"%@:didFailWithError\n%@", method, error);
    
    // server error so process the result
    if ([error domain] == kBITAPIErrorDomain && 
        [method compare:kSCHLibreAccessWebServiceSaveUserProfiles] == NSOrderedSame) {
        SCHSaveUserProfilesOperation *operation = [[[SCHSaveUserProfilesOperation alloc] initWithSyncComponent:self
                                                                                                        result:result
                                                                                                      userInfo:nil] autorelease];        
        [operation setThreadPriority:SCHSyncComponentThreadLowPriority];
        [self.backgroundProcessingQueue addOperation:operation];
    } else {
        [self completeWithFailureMethod:method 
                                  error:error 
                            requestInfo:requestInfo 
                                 result:result 
                       notificationName:SCHProfileSyncComponentDidFailNotification
                   notificationUserInfo:nil];
    }
    [self.savedProfiles removeAllObjects];
}

- (BOOL)updateProfiles
{
	BOOL ret = YES;
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSError *error = nil;
    
    [self.savedProfiles removeAllObjects];
	[fetchRequest setEntity:[NSEntityDescription entityForName:kSCHProfileItem inManagedObjectContext:self.managedObjectContext]];	
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"State IN %@", 
								[NSArray arrayWithObjects:[NSNumber numberWithStatus:kSCHStatusModified],
								 [NSNumber numberWithStatus:kSCHStatusDeleted], nil]]];
	NSArray *updatedProfiles = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (updatedProfiles == nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
	if([updatedProfiles count] > 0) {
        ret = [self requestSaveUserProfiles:updatedProfiles];
	} else {
        ret = [self requestUserProfiles];
    }
	[fetchRequest release], fetchRequest = nil;
	
	return(ret);
}

- (NSArray *)localProfilesWithManagedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSError *error = nil;
	
	[fetchRequest setEntity:[NSEntityDescription entityForName:kSCHProfileItem 
                                        inManagedObjectContext:aManagedObjectContext]];	
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceID ascending:YES]]];
	
	NSArray *ret = [aManagedObjectContext executeFetchRequest:fetchRequest error:&error];	
	[fetchRequest release], fetchRequest = nil;
    if (ret == nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
	
	return(ret);
}

- (void)syncProfilesFromMainThread:(NSArray *)profileList
{
    if (profileList != nil) {
        NSDictionary *result = [NSDictionary dictionaryWithObject:profileList forKey:kSCHLibreAccessWebServiceProfileList];
        SCHGetUserProfilesResponseOperation *operation = [[[SCHGetUserProfilesResponseOperation alloc] initWithSyncComponent:self 
                                                                                                                      result:result
                                                                                                                    userInfo:nil] autorelease];
        [operation start];
    }
}

- (void)addProfileFromMainThread:(NSDictionary *)webProfile
{
    SCHGetUserProfilesResponseOperation *operation = [[[SCHGetUserProfilesResponseOperation alloc] initWithSyncComponent:self 
                                                                                                                  result:nil
                                                                                                                userInfo:nil] autorelease];
    
    [operation addProfile:webProfile managedObjectContext:self.managedObjectContext];
    [self saveWithManagedObjectContext:self.managedObjectContext];
}

#pragma mark - Class methods

+ (void)removeWishListForProfile:(SCHProfileItem *)profileItem
            managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
{
    if (profileItem != nil) {
        SCHWishListProfile *wishListProfile = [profileItem.AppProfile wishListProfile];
        if (wishListProfile != nil) {
            [aManagedObjectContext deleteObject:wishListProfile];
        }    
    }
}

@end
