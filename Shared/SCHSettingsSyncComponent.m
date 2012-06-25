//
//  SCHSettingsSyncComponent.m
//  Scholastic
//
//  Created by John S. Eddie on 04/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHSettingsSyncComponent.h"
#import "SCHSyncComponentProtected.h"
#import "NSManagedObjectContext+Extensions.h"

#import "SCHLibreAccessWebService.h"
#import "SCHSettingItem.h"
#import "SCHListUserSettingsOperation.h"

// Constants
NSString * const SCHSettingsSyncComponentDidCompleteNotification = @"SCHSettingsSyncComponentDidCompleteNotification";
NSString * const SCHSettingsSyncComponentDidFailNotification = @"SCHSettingsSyncComponentDidFailNotification";

@interface SCHSettingsSyncComponent ()

@property (nonatomic, retain) SCHLibreAccessWebService *libreAccessWebService;


@end

@implementation SCHSettingsSyncComponent

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
		
		self.isSynchronizing = [self.libreAccessWebService listUserSettings];
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
    [self clearCoreDataUsingContext:self.managedObjectContext];
}

- (void)clearCoreDataUsingContext:(NSManagedObjectContext *)aManagedObjectContext
{
	NSError *error = nil;
	
	if (![aManagedObjectContext BITemptyEntity:kSCHSettingItem error:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}	
}

#pragma mark - Delegate methods

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result 
      userInfo:(NSDictionary *)userInfo
{	
    SCHListUserSettingsOperation *operation = [[[SCHListUserSettingsOperation alloc] initWithSyncComponent:self
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
    
    [self completeWithFailureMethod:method 
                              error:error 
                        requestInfo:requestInfo 
                             result:result 
                   notificationName:SCHSettingsSyncComponentDidFailNotification 
               notificationUserInfo:nil];
}

@end
