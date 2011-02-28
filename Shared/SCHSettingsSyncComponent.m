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
#import "SCHUserSettingsItem+Extensions.h"

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
	NSError *error = nil;
	
	if (![self.managedObjectContext emptyEntity:kSCHUserSettingsItem error:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}	
}

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result
{	
	[self updateUserSettings:[result objectForKey:kSCHLibreAccessWebServiceUserSettingsList]];
	
	[super method:method didCompleteWithResult:nil];	
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
