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
#import "SCHUserSettingsItem.h"

// Constants
NSString * const SCHSettingsSyncComponentDidCompleteNotification = @"SCHSettingsSyncComponentDidCompleteNotification";
NSString * const SCHSettingsSyncComponentDidFailNotification = @"SCHSettingsSyncComponentDidFailNotification";

@interface SCHSettingsSyncComponent ()

- (void)updateUserSettings:(NSArray *)settingsList;

@end

@implementation SCHSettingsSyncComponent

- (BOOL)synchronize
{
	BOOL ret = YES;
	
	if (self.isSynchronizing == NO) {
		self.backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{ 
			self.isSynchronizing = NO;
			self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
		}];
		
		self.isSynchronizing = [self.libreAccessWebService listUserSettings];
		if (self.isSynchronizing == NO) {
			[[SCHAuthenticationManager sharedAuthenticationManager] authenticate];				
			ret = NO;
		}
	}
	
	return(ret);	
}

- (void)clear
{
    [super clear];
	NSError *error = nil;
	
	if (![self.managedObjectContext BITemptyEntity:kSCHUserSettingsItem error:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}	
}

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result
{	
	[self updateUserSettings:[result objectForKey:kSCHLibreAccessWebServiceUserSettingsList]];
	[[NSNotificationCenter defaultCenter] postNotificationName:SCHSettingsSyncComponentDidCompleteNotification object:self];			
	[super method:method didCompleteWithResult:nil];	
}

- (void)method:(NSString *)method didFailWithError:(NSError *)error requestInfo:(NSDictionary *)requestInfo
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SCHSettingsSyncComponentDidFailNotification 
                                                        object:self];
    
	[super method:method didFailWithError:error requestInfo:requestInfo];
}

- (void)updateUserSettings:(NSArray *)settingsList
{
	NSError *error = nil;
	
	[self clear];
	
	for (id setting in settingsList) {
		SCHUserSettingsItem *newUserSettingsItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHUserSettingsItem inManagedObjectContext:self.managedObjectContext];
		
		newUserSettingsItem.SettingType = [self makeNullNil:[setting objectForKey:kSCHLibreAccessWebServiceSettingType]];
		newUserSettingsItem.SettingValue = [self makeNullNil:[setting objectForKey:kSCHLibreAccessWebServiceSettingValue]];
	}
	
	// Save the context.
	if (![self.managedObjectContext save:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}	
}

@end
