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
#import "BITAPIError.h"

// Constants
NSString * const SCHSettingsSyncComponentDidCompleteNotification = @"SCHSettingsSyncComponentDidCompleteNotification";
NSString * const SCHSettingsSyncComponentDidFailNotification = @"SCHSettingsSyncComponentDidFailNotification";

@interface SCHSettingsSyncComponent ()

@property (nonatomic, retain) SCHLibreAccessWebService *libreAccessWebService;

- (void)clearCoreDataUsingContext:(NSManagedObjectContext *)aManagedObjectContext;
- (void)updateUserSettings:(NSArray *)settingsList 
      managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;

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
    @try {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{        
            NSManagedObjectContext *backgroundThreadManagedObjectContext = [[NSManagedObjectContext alloc] init];
            [backgroundThreadManagedObjectContext setPersistentStoreCoordinator:self.managedObjectContext.persistentStoreCoordinator];
            [backgroundThreadManagedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
            
            [self updateUserSettings:[result objectForKey:kSCHLibreAccessWebServiceUserSettingsList]
             managedObjectContext:backgroundThreadManagedObjectContext];
            
            [self saveWithManagedObjectContext:backgroundThreadManagedObjectContext];
            [backgroundThreadManagedObjectContext release], backgroundThreadManagedObjectContext = nil;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self completeWithSuccessMethod:method 
                                         result:nil 
                                       userInfo:userInfo 
                               notificationName:SCHSettingsSyncComponentDidCompleteNotification 
                           notificationUserInfo:nil];
            });                
        });                                                        
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
                       notificationName:SCHSettingsSyncComponentDidFailNotification 
                   notificationUserInfo:nil];
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
                   notificationName:SCHSettingsSyncComponentDidFailNotification 
               notificationUserInfo:nil];
}

- (void)updateUserSettings:(NSArray *)settingsList 
      managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
{	
    if ([settingsList count] > 0) {
        [self clearCoreDataUsingContext:aManagedObjectContext];
        
        for (id setting in settingsList) {
            SCHSettingItem *newUserSettingsItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHSettingItem 
                                                                                inManagedObjectContext:aManagedObjectContext];
            
            newUserSettingsItem.SettingName = [self makeNullNil:[setting objectForKey:kSCHLibreAccessWebServiceSettingName]];
            newUserSettingsItem.SettingValue = [self makeNullNil:[setting objectForKey:kSCHLibreAccessWebServiceSettingValue]];
        }
        
        [self saveWithManagedObjectContext:aManagedObjectContext];
    }
}

@end
