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

@property (nonatomic, retain) SCHLibreAccessWebService *libreAccessWebService;
@property (nonatomic, retain) NSManagedObjectContext *backgroundThreadManagedObjectContext;

- (void)clearCoreDataUsingContext:(NSManagedObjectContext *)aManagedObjectContext;

@end

@implementation SCHReadingStatsSyncComponent

@synthesize libreAccessWebService;
@synthesize backgroundThreadManagedObjectContext;

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
    [backgroundThreadManagedObjectContext release], backgroundThreadManagedObjectContext = nil;
    
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
    @try {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            self.backgroundThreadManagedObjectContext = [[[NSManagedObjectContext alloc] init] autorelease];
            [self.backgroundThreadManagedObjectContext setPersistentStoreCoordinator:self.managedObjectContext.persistentStoreCoordinator];
            
            [self clearCoreDataUsingContext:self.backgroundThreadManagedObjectContext];
            
            self.backgroundThreadManagedObjectContext = nil;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:SCHReadingStatsSyncComponentDidCompleteNotification 
                                                                    object:self];
                [super method:method didCompleteWithResult:nil userInfo:userInfo];	
            });                
        });                                            
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
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{        
        // server error so clear the stats
        if ([error domain] == kBITAPIErrorDomain) {
            self.backgroundThreadManagedObjectContext = [[[NSManagedObjectContext alloc] init] autorelease];
            [self.backgroundThreadManagedObjectContext setPersistentStoreCoordinator:self.managedObjectContext.persistentStoreCoordinator];
            
            [self clearCoreDataUsingContext:self.backgroundThreadManagedObjectContext];
            
            self.backgroundThreadManagedObjectContext = nil;
        }    
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:SCHReadingStatsSyncComponentDidFailNotification 
                                                                object:self];
            [super method:method didFailWithError:error requestInfo:requestInfo result:result];    
        });                
    });                                                        
}

@end
