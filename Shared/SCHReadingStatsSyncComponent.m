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

// Constants
NSString * const SCHReadingStatsSyncComponentDidCompleteNotification = @"SCHReadingStatsSyncComponentDidCompleteNotification";
NSString * const SCHReadingStatsSyncComponentDidFailNotification = @"SCHReadingStatsSyncComponentDidFailNotification";

@interface SCHReadingStatsSyncComponent ()

- (void)clearStatistics;

@end

@implementation SCHReadingStatsSyncComponent

- (BOOL)synchronize
{
	BOOL ret = YES;
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
	if (self.isSynchronizing == NO) {
		self.backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{ 
			self.isSynchronizing = NO;
            [self endBackgroundTask];
		}];
		
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
            [[NSNotificationCenter defaultCenter] postNotificationName:SCHReadingStatsSyncComponentDidCompleteNotification 
                                                                object:self];            
            [super method:nil didCompleteWithResult:nil userInfo:nil];		
        }

        if (ret == NO) {
            [self endBackgroundTask];
        }         
	}
    [fetchRequest release], fetchRequest = nil;
    
	return(ret);		
}

- (void)clear
{
    [super clear];
    [self clearStatistics];
}

- (void)clearStatistics
{
	NSError *error = nil;
	
	if (![self.managedObjectContext BITemptyEntity:kSCHReadingStatsDetailItem error:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}		
}

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result 
      userInfo:(NSDictionary *)userInfo
{
    @try {
        [self clearStatistics];
        [[NSNotificationCenter defaultCenter] postNotificationName:SCHReadingStatsSyncComponentDidCompleteNotification 
                                                            object:self];
        [super method:method didCompleteWithResult:nil userInfo:userInfo];				    
    }
    @catch (NSException *exception) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SCHReadingStatsSyncComponentDidFailNotification 
                                                            object:self];
        NSError *error = [NSError errorWithDomain:kBITAPIErrorDomain 
                                             code:kBITAPIExceptionError 
                                         userInfo:[NSDictionary dictionaryWithObject:[exception reason]
                                                                              forKey:NSLocalizedDescriptionKey]];
        [super method:method didFailWithError:error requestInfo:nil result:result];
    }
}

- (void)method:(NSString *)method didFailWithError:(NSError *)error 
   requestInfo:(NSDictionary *)requestInfo
        result:(NSDictionary *)result
{
    NSLog(@"%@:didFailWithError\n%@", method, error);
    
    // server error so clear the stats
    if ([error domain] == kBITAPIErrorDomain) {
        [self clearStatistics];        
    }    
    [[NSNotificationCenter defaultCenter] postNotificationName:SCHReadingStatsSyncComponentDidFailNotification 
                                                        object:self];
    [super method:method didFailWithError:error requestInfo:requestInfo result:result];    
}

@end
