//
//  SCHWebServiceSync.m
//  Scholastic
//
//  Created by John S. Eddie on 13/01/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHWebServiceSync.h"

#import "SCHLibreAccessWebService.h"
#import "NSManagedObjectContext+Extensions.h"
#import "SCHAuthenticationManager.h"
#import "SCHUserSettingsItem.h"
#import "SCHProfileItem.h"
#import "SCHContentMetadataItem.h"

@interface SCHWebServiceSync ()

- (void)updateProfiles:(NSArray *)profileList;
- (void)clearBooks;
- (void)updateBooks:(NSArray *)bookList;
- (void)updateUserSettings:(NSArray *)settingsList;

@end

@implementation SCHWebServiceSync

@synthesize libreAccessWebService;
@synthesize managedObjectContext;

- (id)init
{
	self = [super init];
	if (self != nil) {
		self.libreAccessWebService = [[SCHLibreAccessWebService alloc] init];	
		self. libreAccessWebService.delegate = self;
		[self.libreAccessWebService release];
	}
	return(self);
}

- (void)dealloc
{	
	self.libreAccessWebService = nil;
	self.managedObjectContext = nil;
	
	[super dealloc];
}

- (BOOL)update
{
	BOOL ret = YES;
	
	if ([self.libreAccessWebService getUserProfiles] == NO ||
		[self.libreAccessWebService listUserContent] == NO ||
		[self.libreAccessWebService listUserSettings] == NO) {
		[[SCHAuthenticationManager sharedAuthenticationManager] authenticate];				
		ret = NO;
	}
	
	return(ret);
}

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result
{	
	NSLog(@"%@\n%@", method, result);
	
	if([method compare:kSCHLibreAccessWebServiceGetUserProfiles] == NSOrderedSame) {
		[self updateProfiles:[result objectForKey:kSCHLibreAccessWebServiceProfileList]];
	} else if([method compare:kSCHLibreAccessWebServiceListUserContent] == NSOrderedSame) {
		NSArray *books = [result objectForKey:kSCHLibreAccessWebServiceUserContentList];
		if ([books count] > 0) {
			[self.libreAccessWebService listContentMetadata:books includeURLs:NO];				
		} else {
			[self clearBooks];
		}
	} else if([method compare:kSCHLibreAccessWebServiceListContentMetadata] == NSOrderedSame) {
		[self updateBooks:[result objectForKey:kSCHLibreAccessWebServiceContentMetadataList]];
	} else if([method compare:kSCHLibreAccessWebServiceListUserSettings] == NSOrderedSame) {
		[self updateUserSettings:[result objectForKey:kSCHLibreAccessWebServiceUserSettingsList]];
	}
}

- (void)method:(NSString *)method didFailWithError:(NSError *)error
{
	NSLog(@"%@\n%@", method, error);	
}

- (void)updateProfiles:(NSArray *)profileList
{	
	NSError *error = nil;
	
	if (![self.managedObjectContext emptyEntity:@"SCHProfileItem" error:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}	
	
	// TEST THE SAVE
//	id profsave = [profileList objectAtIndex:1];
//	if(profsave != nil) {
//		[profsave setValue:@"MyName2" forKey:kSCHLibreAccessWebServiceFirstname];
//		[profsave setValue:@"MyName2" forKey:kSCHLibreAccessWebServiceScreenname];		
//		[profsave setValue:[NSNumber numberWithInt:3] forKey:kSCHLibreAccessWebServiceAction];		
//		[self.libreAccessWebService saveUserProfiles:self.aToken forUserProfiles:[NSArray arrayWithObject:profsave]];
//	}
	
	
	for (id profile in profileList) {
		SCHProfileItem *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"SCHProfileItem" inManagedObjectContext:self.managedObjectContext];
		
		newManagedObject.LastModified = [profile objectForKey:kSCHLibreAccessWebServiceLastModified];
		newManagedObject.State = [NSNumber numberWithInteger:0];		
		newManagedObject.ID = [profile objectForKey:kSCHLibreAccessWebServiceID];
		newManagedObject.ScreenName = [profile objectForKey:kSCHLibreAccessWebServiceScreenName];
		newManagedObject.ProfilePasswordRequired = [profile objectForKey:kSCHLibreAccessWebServiceProfilePasswordRequired];		
	}
	
	// Save the context.
	if (![self.managedObjectContext save:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}	
}

- (void)clearBooks
{
	NSError *error = nil;
	
	if (![self.managedObjectContext emptyEntity:@"SCHContentMetadataItem" error:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}	
}

- (void)updateBooks:(NSArray *)bookList
{
	NSError *error = nil;
	
	[self clearBooks];
	
	for (id book in bookList) {
		SCHContentMetadataItem *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"SCHContentMetadataItem" inManagedObjectContext:self.managedObjectContext];

		newManagedObject.Title = [book objectForKey:kSCHLibreAccessWebServiceTitle];
		newManagedObject.Author = [book objectForKey:kSCHLibreAccessWebServiceAuthor];
	}
	
	// Save the context.
	if (![self.managedObjectContext save:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}	
}

- (void)updateUserSettings:(NSArray *)settingsList
{
	NSError *error = nil;

	if (![self.managedObjectContext emptyEntity:@"SCHUserSettingsItem" error:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}	
	
	for (id setting in settingsList) {
		SCHUserSettingsItem *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"SCHUserSettingsItem" inManagedObjectContext:self.managedObjectContext];
		
		newManagedObject.SettingType = [setting objectForKey:kSCHLibreAccessWebServiceSettingType];
		newManagedObject.SettingValue = [setting objectForKey:kSCHLibreAccessWebServiceSettingValue];
	}
	
	// Save the context.
	if (![self.managedObjectContext save:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}	
}


@end
