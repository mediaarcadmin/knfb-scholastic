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
        if (readingStats == nil) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();            
        } else if ([readingStats count] > 0) {
            self.isSynchronizing = [self.libreAccessWebService saveReadingStatisticsDetailed:readingStats];
            if (self.isSynchronizing == NO) {
                [[SCHAuthenticationManager sharedAuthenticationManager] authenticate];				
                ret = NO;			
            }		            
        } else {
            if([(id)self.delegate respondsToSelector:@selector(component:didCompleteWithResult:)]) {
                [(id)self.delegate component:self didCompleteWithResult:nil];		
            }	
            
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
		abort();
	}		
}

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result
{	
	NSLog(@"%@\n%@", method, result);
    
    [self clear];
    [[NSNotificationCenter defaultCenter] postNotificationName:SCHReadingStatsSyncComponentDidCompleteNotification 
                                                        object:self];
    [super method:method didCompleteWithResult:nil];				    
}

- (void)method:(NSString *)method didFailWithError:(NSError *)error requestInfo:(NSDictionary *)requestInfo
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SCHReadingStatsSyncComponentDidFailNotification 
                                                        object:self];
    
	[super method:method didFailWithError:error requestInfo:requestInfo];
}

@end
