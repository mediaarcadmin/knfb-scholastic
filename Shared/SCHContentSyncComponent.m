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
#import "SCHBooksAssignment.h"
#import "SCHContentProfileItem.h"
#import "SCHListBooksAssignmentOperation.h"
#import "SCHAnnotationsContentItem.h"
#import "SCHReadingStatsContentItem.h"

// Constants
NSString * const SCHContentSyncComponentWillDeleteNotification = @"SCHContentSyncComponentWillDeleteNotification";
NSString * const SCHContentSyncComponentDidAddBookToProfileNotification = @"SCHContentSyncComponentDidAddBookToProfileNotification";
NSString * const SCHContentSyncComponentAddedBookIdentifier = @"SCHContentSyncComponentAddedBookIdentifier";
NSString * const SCHContentSyncComponentAddedProfileIdentifier = @"SCHContentSyncComponentAddedProfileIdentifier";
NSString * const SCHContentSyncComponentDidCompleteNotification = @"SCHContentSyncComponentDidCompleteNotification";
NSString * const SCHContentSyncComponentDidFailNotification = @"SCHContentSyncComponentDidFailNotification";

@interface SCHContentSyncComponent ()

@property (nonatomic, retain) SCHLibreAccessWebService *libreAccessWebService;

- (BOOL)updateBooksAssignments;

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
		
		ret = [self updateBooksAssignments];
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
    
	if (![self.managedObjectContext BITemptyEntity:kSCHBooksAssignment error:&error priorToDeletionBlock:nil] ||
		![self.managedObjectContext BITemptyEntity:kSCHContentProfileItem error:&error priorToDeletionBlock:nil] ||
        ![self.managedObjectContext BITemptyEntity:kSCHAnnotationsContentItem error:&error priorToDeletionBlock:nil] ||
        ![self.managedObjectContext BITemptyEntity:kSCHReadingStatsContentItem error:&error priorToDeletionBlock:nil]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}		
}

#pragma mark - Delegate methods

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result
      userInfo:(NSDictionary *)userInfo
{	
    if([method compare:kSCHLibreAccessWebServiceSaveContentProfileAssignment] == NSOrderedSame) {	
        if (self.saveOnly == NO) {
            self.isSynchronizing = [self.libreAccessWebService listBooksAssignment];
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
    } else if([method compare:kSCHLibreAccessWebServiceListBooksAssignment] == NSOrderedSame) {
        SCHListBooksAssignmentOperation *operation = [[[SCHListBooksAssignmentOperation alloc] initWithSyncComponent:self
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

- (BOOL)updateBooksAssignments
{		
	BOOL ret = YES;
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSError *error = nil;
    
	[fetchRequest setEntity:[NSEntityDescription entityForName:kSCHBooksAssignment inManagedObjectContext:self.managedObjectContext]];
	NSArray *changedStates = [NSArray arrayWithObjects:[NSNumber numberWithStatus:kSCHStatusModified],
					   [NSNumber numberWithStatus:kSCHStatusDeleted], nil];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"ANY profileList.State IN %@", changedStates]];
	
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
            self.isSynchronizing = [self.libreAccessWebService listBooksAssignment];
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

- (void)syncBooksAssignmentsFromMainThread:(NSArray *)booksAssignmentList
{
    if (booksAssignmentList != nil) {
        SCHListBooksAssignmentOperation *operation = [[[SCHListBooksAssignmentOperation alloc] initWithSyncComponent:self
                                                                                                              result:nil
                                                                                                            userInfo:nil] autorelease];
        [operation syncBooksAssignments:booksAssignmentList managedObjectContext:self.managedObjectContext];
    }
}

- (void)addBooksAssignmentFromMainThread:(NSDictionary *)webBooksAssignment
{
    if (webBooksAssignment != nil) {
        SCHListBooksAssignmentOperation *operation = [[[SCHListBooksAssignmentOperation alloc] initWithSyncComponent:self
                                                                                                              result:nil
                                                                                                            userInfo:nil] autorelease];
        
        [operation addBooksAssignment:webBooksAssignment managedObjectContext:self.managedObjectContext];
    }
}

@end
