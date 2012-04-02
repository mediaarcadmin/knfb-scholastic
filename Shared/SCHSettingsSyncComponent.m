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

- (void)updateUserSettings:(NSArray *)settingsList;

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
		self.backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{ 
			self.isSynchronizing = NO;
            [self endBackgroundTask];
		}];
		
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

- (void)clear
{
	NSError *error = nil;
	
    [self.libreAccessWebService clear];
    
	if (![self.managedObjectContext BITemptyEntity:kSCHSettingItem error:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}	
}

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result 
      userInfo:(NSDictionary *)userInfo
{	
    @try {
        [self updateUserSettings:[result objectForKey:kSCHLibreAccessWebServiceUserSettingsList]];
        [[NSNotificationCenter defaultCenter] postNotificationName:SCHSettingsSyncComponentDidCompleteNotification object:self];			
        [super method:method didCompleteWithResult:nil userInfo:userInfo];	
    }
    @catch (NSException *exception) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SCHSettingsSyncComponentDidFailNotification 
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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SCHSettingsSyncComponentDidFailNotification 
                                                        object:self];        
    [super method:method didFailWithError:error requestInfo:requestInfo result:result];
}

- (void)updateUserSettings:(NSArray *)settingsList
{	
    if ([settingsList count] > 0) {
        [self clear];
        
        for (id setting in settingsList) {
            SCHSettingItem *newUserSettingsItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHSettingItem inManagedObjectContext:self.managedObjectContext];
            
            newUserSettingsItem.SettingName = [self makeNullNil:[setting objectForKey:kSCHLibreAccessWebServiceSettingName]];
            newUserSettingsItem.SettingValue = [self makeNullNil:[setting objectForKey:kSCHLibreAccessWebServiceSettingValue]];
        }
        
        [self save];
    }
}

@end
