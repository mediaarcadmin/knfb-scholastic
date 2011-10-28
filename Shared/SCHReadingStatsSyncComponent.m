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

@implementation SCHReadingStatsSyncComponent

- (BOOL)synchronize
{
	BOOL ret = YES;
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
	if (self.isSynchronizing == NO) {
		self.backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{ 
			self.isSynchronizing = NO;
			self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
		}];
		
        [fetchRequest setEntity:[NSEntityDescription entityForName:kSCHReadingStatsDetailItem inManagedObjectContext:self.managedObjectContext]];	
       	NSArray *readingStats = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if ([readingStats count] > 0) {
            self.isSynchronizing = [self.libreAccessWebService saveReadingStatisticsDetailed:readingStats];
            if (self.isSynchronizing == NO) {
                [[SCHAuthenticationManager sharedAuthenticationManager] authenticate];				
                ret = NO;			
            }		            
        } else {
            [super method:nil didCompleteWithResult:nil];		
        }
	}
    [fetchRequest release], fetchRequest = nil;
    
	return(ret);		
}

- (void)clear
{
    [super clear];
	NSError *error = nil;
	
	if (![self.managedObjectContext BITemptyEntity:kSCHReadingStatsDetailItem error:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}		
}

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result
{
    @try {
        [self clear];
        [[NSNotificationCenter defaultCenter] postNotificationName:SCHReadingStatsSyncComponentDidCompleteNotification 
                                                            object:self];
        [super method:method didCompleteWithResult:nil];				    
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
    
    // a valid error otherwise server error
    if ([error domain] != kBITAPIErrorDomain) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SCHReadingStatsSyncComponentDidFailNotification 
                                                            object:self];
        [super method:method didFailWithError:error requestInfo:requestInfo result:result];
    } else {
        [self clear];        
        [[NSNotificationCenter defaultCenter] postNotificationName:SCHReadingStatsSyncComponentDidCompleteNotification object:self];			
        [super method:method didCompleteWithResult:nil];	
    }    
}

@end
