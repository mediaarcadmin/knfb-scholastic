//
//  SCHContentSyncComponent.m
//  Scholastic
//
//  Created by John S. Eddie on 04/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHContentSyncComponent.h"
#import "SCHSyncComponentProtected.h"
#import "NSManagedObjectContext+Extensions.h"

#import "SCHLibreAccessWebService.h"
#import "SCHUserContentItem.h"
#import "SCHOrderItem.h"
#import "SCHContentProfileItem.h"
#import "SCHListUserContentForRatingsOperation.h"

// Constants
NSString * const SCHContentSyncComponentWillDeleteNotification = @"SCHContentSyncComponentWillDeleteNotification";
NSString * const SCHContentSyncComponentDidAddBookToProfileNotification = @"SCHContentSyncComponentDidAddBookToProfileNotification";
NSString * const SCHContentSyncComponentAddedBookIdentifier = @"SCHContentSyncComponentAddedBookIdentifier";
NSString * const SCHContentSyncComponentAddedProfileIdentifier = @"SCHContentSyncComponentAddedProfileIdentifier";
NSString * const SCHContentSyncComponentDidCompleteNotification = @"SCHContentSyncComponentDidCompleteNotification";
NSString * const SCHContentSyncComponentDidFailNotification = @"SCHContentSyncComponentDidFailNotification";

@interface SCHContentSyncComponent ()

@property (nonatomic, retain) SCHLibreAccessWebService *libreAccessWebService;

- (BOOL)updateUserContentItems;

@end

@implementation SCHContentSyncComponent

@synthesize libreAccessWebService;

- (id)init
{
	self = [super init];
	if (self != nil) {
		libreAccessWebService = [[SCHLibreAccessWebService alloc] init];	
		libreAccessWebService.delegate = self;        
	}
	
	return(self);
}

- (void)dealloc
{
    libreAccessWebService.delegate = nil;
	[libreAccessWebService release], libreAccessWebService = nil;
    
	[super dealloc];
}

- (BOOL)synchronize
{
	BOOL ret = YES;
	
	if (self.isSynchronizing == NO) {
        [self beginBackgroundTask];
		
		ret = [self updateUserContentItems];
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
    // nop
}

- (void)clearCoreData
{
	NSError *error = nil;
    
	if (![self.managedObjectContext BITemptyEntity:kSCHUserContentItem error:&error] ||
		![self.managedObjectContext BITemptyEntity:kSCHOrderItem error:&error] ||
		![self.managedObjectContext BITemptyEntity:kSCHContentProfileItem error:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}		
}

#pragma mark - Delegate methods

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result
      userInfo:(NSDictionary *)userInfo
{	
    if([method compare:kSCHLibreAccessWebServiceSaveContentProfileAssignment] == NSOrderedSame) {	
        if (self.saveOnly == NO) {
            self.isSynchronizing = [self.libreAccessWebService listUserContent];
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
            }
        } else {
            [self completeWithSuccessMethod:method 
                                     result:result 
                                   userInfo:userInfo 
                           notificationName:SCHContentSyncComponentDidCompleteNotification 
                       notificationUserInfo:nil];
        }
    } else if([method compare:kSCHLibreAccessWebServiceListUserContentForRatings] == NSOrderedSame) {
        SCHListUserContentForRatingsOperation *operation = [[[SCHListUserContentForRatingsOperation alloc] initWithSyncComponent:self
                                                                                                                          result:result
                                                                                                                        userInfo:userInfo] autorelease];
        [operation setThreadPriority:SCHSyncComponentThreadLowPriority];
        [self.backgroundProcessingQueue addOperation:operation];
    }
}

- (void)method:(NSString *)method didFailWithError:(NSError *)error 
   requestInfo:(NSDictionary *)requestInfo
        result:(NSDictionary *)result
{
    NSLog(@"%@:didFailWithError\n%@", method, error);
    
    [self completeWithFailureMethod:method 
                              error:error 
                        requestInfo:requestInfo 
                             result:result 
                   notificationName:SCHContentSyncComponentDidFailNotification 
               notificationUserInfo:nil];
}

- (BOOL)updateUserContentItems
{		
	BOOL ret = YES;
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSError *error = nil;
    
	[fetchRequest setEntity:[NSEntityDescription entityForName:kSCHUserContentItem inManagedObjectContext:self.managedObjectContext]];	
	NSArray *changedStates = [NSArray arrayWithObjects:[NSNumber numberWithStatus:kSCHStatusModified],
					   [NSNumber numberWithStatus:kSCHStatusDeleted], nil];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"ANY ProfileList.State IN %@", changedStates]];
	
	NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (results == nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
	
	if ([results count] > 0) {
		self.isSynchronizing = [self.libreAccessWebService saveContentProfileAssignment:results];
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
        if (self.saveOnly == NO) {
            self.isSynchronizing = [self.libreAccessWebService listUserContent];
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
                           notificationName:SCHContentSyncComponentDidCompleteNotification 
                       notificationUserInfo:nil];
        }
	}
	[fetchRequest release], fetchRequest = nil;
	
	return(ret);	
}

- (void)syncUserContentItemsFromMainThread:(NSArray *)userContentList
{
    if (userContentList != nil) {
        SCHListUserContentForRatingsOperation *operation = [[[SCHListUserContentForRatingsOperation alloc] initWithSyncComponent:self 
                                                                                                                          result:nil
                                                                                                                        userInfo:nil] autorelease];
        [operation syncUserContentItems:userContentList managedObjectContext:self.managedObjectContext];
    }
}

- (void)addUserContentItemFromMainThread:(NSDictionary *)webUserContentItem
{
    if (webUserContentItem != nil) {
        SCHListUserContentForRatingsOperation *operation = [[[SCHListUserContentForRatingsOperation alloc] initWithSyncComponent:self 
                                                                                                                          result:nil
                                                                                                                        userInfo:nil] autorelease];
        
        [operation addUserContentItem:webUserContentItem managedObjectContext:self.managedObjectContext];
        [self saveWithManagedObjectContext:self.managedObjectContext];
    }
}

@end
