//
//  SCHReadingStatsSyncComponent.m
//  Scholastic
//
//  Created by John S. Eddie on 04/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHReadingStatsSyncComponent.h"
#import "SCHSyncComponentProtected.h"
#import "NSManagedObjectContext+Extensions.h"

#import "SCHLibreAccessWebService.h"
#import "SCHReadingStatsDetailItem.h"
#import "BITAPIError.h"
#import "SCHSaveReadingStatisticsDetailedOperation.h"

// Constants
NSString * const SCHReadingStatsSyncComponentDidCompleteNotification = @"SCHReadingStatsSyncComponentDidCompleteNotification";
NSString * const SCHReadingStatsSyncComponentDidFailNotification = @"SCHReadingStatsSyncComponentDidFailNotification";

@interface SCHReadingStatsSyncComponent ()

@property (nonatomic, retain) SCHLibreAccessWebService *libreAccessWebService;

@end

@implementation SCHReadingStatsSyncComponent

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
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
	if (self.isSynchronizing == NO) {
        [self beginBackgroundTask];
		
        [fetchRequest setEntity:[NSEntityDescription entityForName:kSCHReadingStatsDetailItem inManagedObjectContext:self.managedObjectContext]];	
       	NSArray *readingStats = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (readingStats == nil) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
        
        if ([readingStats count] > 0) {
            self.isSynchronizing = [self.libreAccessWebService saveReadingStatisticsDetailed:readingStats];
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
                           notificationName:SCHReadingStatsSyncComponentDidCompleteNotification 
                       notificationUserInfo:nil];
        }

        if (ret == NO) {
            [self endBackgroundTask];
        }         
	}
    [fetchRequest release], fetchRequest = nil;
    
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
    [self clearCoreDataUsingContext:self.managedObjectContext];
}

- (void)clearCoreDataUsingContext:(NSManagedObjectContext *)aManagedObjectContext
{
	NSError *error = nil;
	
	if (![aManagedObjectContext BITemptyEntity:kSCHReadingStatsDetailItem error:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}		
}

#pragma mark - Delegate methods

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result 
      userInfo:(NSDictionary *)userInfo
{
    SCHSaveReadingStatisticsDetailedOperation *operation = [[[SCHSaveReadingStatisticsDetailedOperation alloc] initWithSyncComponent:self
                                                                                                                              result:result
                                                                                                                            userInfo:userInfo] autorelease];
    [operation setThreadPriority:SCHSyncComponentThreadLowPriority];
    [self.backgroundProcessingQueue addOperation:operation];
}

- (void)method:(NSString *)method didFailWithError:(NSError *)error 
   requestInfo:(NSDictionary *)requestInfo
        result:(NSDictionary *)result
{
    NSLog(@"%@:didFailWithError\n%@", method, error);
    
    // server error so clear the stats
    if ([error domain] == kBITAPIErrorDomain) {
        SCHSaveReadingStatisticsDetailedOperation *operation = [[[SCHSaveReadingStatisticsDetailedOperation alloc] initWithSyncComponent:self
                                                                                                                                  result:result
                                                                                                                                userInfo:nil] autorelease];
        [operation setThreadPriority:SCHSyncComponentThreadLowPriority];
        [self.backgroundProcessingQueue addOperation:operation];
    } else {
        [self completeWithFailureMethod:method 
                                  error:error 
                            requestInfo:requestInfo 
                                 result:result 
                       notificationName:SCHReadingStatsSyncComponentDidFailNotification 
                   notificationUserInfo:nil];        
    }    
}

@end
