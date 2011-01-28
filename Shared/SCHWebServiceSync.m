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
#import "NSNumber+ObjectTypes.h"
#import "SCHUserContentItem.h"
#import "SCHOrderItem.h"
#import "SCHContentProfileItem.h"

@interface SCHWebServiceSync ()

- (void)clearProfiles;
- (void)updateProfiles:(NSArray *)profileList;
- (void)clearUserContentItems;
- (void)updateUserContentItems:(NSArray *)userContentList;
- (void)clearBooks;
- (void)updateBooks:(NSArray *)bookList;
- (void)clearUserSettings;
- (void)updateUserSettings:(NSArray *)settingsList;
- (id)makeNullNil:(id)object;

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
		[self updateUserContentItems:[result objectForKey:kSCHLibreAccessWebServiceUserContentList]];
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

- (void)clearProfiles
{
	NSError *error = nil;
	
	if (![self.managedObjectContext emptyEntity:@"SCHProfileItem" error:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}		
}

- (void)updateProfiles:(NSArray *)profileList
{	
	NSError *error = nil;
	
	[self clearProfiles];
	
	// TEST THE SAVE
//	id profsave = [profileList objectAtIndex:1];
//	if(profsave != nil) {
//		[profsave setValue:@"MyName2" forKey:kSCHLibreAccessWebServiceFirstname];
//		[profsave setValue:@"MyName2" forKey:kSCHLibreAccessWebServiceScreenname];		
//		[profsave setValue:[NSNumber numberWithInt:3] forKey:kSCHLibreAccessWebServiceAction];		
//		[self.libreAccessWebService saveUserProfiles:self.aToken forUserProfiles:[NSArray arrayWithObject:profsave]];
//	}
	
	
	for (id profile in profileList) {
		SCHProfileItem *newProfileItem = [NSEntityDescription insertNewObjectForEntityForName:@"SCHProfileItem" inManagedObjectContext:self.managedObjectContext];
		
		newProfileItem.LastModified = [self makeNullNil:[profile objectForKey:kSCHLibreAccessWebServiceLastModified]];
		newProfileItem.State = [NSNumber numberWithStatus:kSCHStatusCreated];

		newProfileItem.StoryInteractionEnabled = [self makeNullNil:[profile objectForKey:kSCHLibreAccessWebServiceStoryInteractionEnabled]];
		newProfileItem.ID = [self makeNullNil:[profile objectForKey:kSCHLibreAccessWebServiceID]];
		newProfileItem.LastPasswordModified = [self makeNullNil:[profile objectForKey:kSCHLibreAccessWebServiceLastPasswordModified]];
		newProfileItem.Password = [self makeNullNil:[profile objectForKey:kSCHLibreAccessWebServicePassword]];
		newProfileItem.Birthday = [self makeNullNil:[profile objectForKey:kSCHLibreAccessWebServiceBirthday]];
		newProfileItem.FirstName = [self makeNullNil:[profile objectForKey:kSCHLibreAccessWebServiceFirstName]];
		newProfileItem.ProfilePasswordRequired = [self makeNullNil:[profile objectForKey:kSCHLibreAccessWebServiceProfilePasswordRequired]];
		newProfileItem.Type = [self makeNullNil:[profile objectForKey:kSCHLibreAccessWebServiceType]];
		newProfileItem.ScreenName = [self makeNullNil:[profile objectForKey:kSCHLibreAccessWebServiceScreenName]];
		newProfileItem.AutoAssignContentToProfiles = [self makeNullNil:[profile objectForKey:kSCHLibreAccessWebServiceAutoAssignContentToProfiles]];
		newProfileItem.LastScreenNameModified = [self makeNullNil:[profile objectForKey:kSCHLibreAccessWebServiceLastScreenNameModified]];
		newProfileItem.UserKey = [self makeNullNil:[profile objectForKey:kSCHLibreAccessWebServiceUserKey]];
		newProfileItem.BookshelfStyle = [self makeNullNil:[profile objectForKey:kSCHLibreAccessWebServiceBookshelfStyle]];
		newProfileItem.LastName = [self makeNullNil:[profile objectForKey:kSCHLibreAccessWebServiceLastName]];
		newProfileItem.LastModified = [self makeNullNil:[profile objectForKey:kSCHLibreAccessWebServiceLastModified]];
		newProfileItem.State = [NSNumber numberWithInteger:0];				
	}
	
	// Save the context.
	if (![self.managedObjectContext save:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}	
}

- (void)clearUserContentItems
{
	NSError *error = nil;
	
	if (![self.managedObjectContext emptyEntity:@"SCHUserContentItem" error:&error] ||
		![self.managedObjectContext emptyEntity:@"SCHOrderItem" error:&error] ||
		![self.managedObjectContext emptyEntity:@"SCHContentProfileItem" error:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}		
}

- (void)updateUserContentItems:(NSArray *)userContentList
{
	NSError *error = nil;
	
	[self clearUserContentItems];
	
	for (id userContentItem in userContentList) {
		SCHUserContentItem *newUserContentItem = [NSEntityDescription insertNewObjectForEntityForName:@"SCHUserContentItem" inManagedObjectContext:self.managedObjectContext];
		
		newUserContentItem.LastModified = [self makeNullNil:[userContentItem objectForKey:kSCHLibreAccessWebServiceLastModified]];
		newUserContentItem.State = [NSNumber numberWithStatus:kSCHStatusCreated];

		newUserContentItem.DRMQualifier = [self makeNullNil:[userContentItem objectForKey:kSCHLibreAccessWebServiceDRMQualifier]];
		newUserContentItem.Version = [self makeNullNil:[userContentItem objectForKey:kSCHLibreAccessWebServiceVersion]];
		newUserContentItem.ContentIdentifier = [self makeNullNil:[userContentItem objectForKey:kSCHLibreAccessWebServiceContentIdentifier]];
		newUserContentItem.Format = [self makeNullNil:[userContentItem objectForKey:kSCHLibreAccessWebServiceFormat]];		
		newUserContentItem.DefaultAssignment = [self makeNullNil:[userContentItem objectForKey:kSCHLibreAccessWebServiceDefaultAssignment]];		
		newUserContentItem.ContentIdentifierType = [self makeNullNil:[userContentItem objectForKey:kSCHLibreAccessWebServiceContentIdentifierType]];				
		
		NSArray *orderList = [self makeNullNil:[userContentItem objectForKey:kSCHLibreAccessWebServiceOrderList]];
		for (NSDictionary *orderItem in orderList) {
			SCHOrderItem *newOrderItem = [NSEntityDescription insertNewObjectForEntityForName:@"SCHOrderItem" inManagedObjectContext:self.managedObjectContext];			

			newOrderItem.OrderID = [self makeNullNil:[userContentItem objectForKey:kSCHLibreAccessWebServiceOrderID]];
			newOrderItem.OrderDate = [self makeNullNil:[userContentItem objectForKey:kSCHLibreAccessWebServiceOrderDate]];

			[newUserContentItem addOrderListObject:newOrderItem];
		}
		
		NSArray *profileList = [self makeNullNil:[userContentItem objectForKey:kSCHLibreAccessWebServiceProfileList]];
		for (NSDictionary *profileItem in profileList) {
			SCHContentProfileItem *newContentProfileItem = [NSEntityDescription insertNewObjectForEntityForName:@"SCHContentProfileItem" inManagedObjectContext:self.managedObjectContext];			
			
			newContentProfileItem.LastModified = [self makeNullNil:[profileItem objectForKey:kSCHLibreAccessWebServiceLastModified]];
			newContentProfileItem.State = [NSNumber numberWithStatus:kSCHStatusCreated];
			
			newContentProfileItem.IsFavorite = [self makeNullNil:[profileItem objectForKey:kSCHLibreAccessWebServiceIsFavorite]];

			newContentProfileItem.ProfileID = [self makeNullNil:[profileItem objectForKey:kSCHLibreAccessWebServiceProfileID]];
			newContentProfileItem.LastPageLocation = [self makeNullNil:[profileItem objectForKey:kSCHLibreAccessWebServiceLastPageLocation]];
			
			[newUserContentItem addProfileListObject:newContentProfileItem];
		}
		
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
		SCHContentMetadataItem *newContentMetadataItem = [NSEntityDescription insertNewObjectForEntityForName:@"SCHContentMetadataItem" inManagedObjectContext:self.managedObjectContext];
		
		newContentMetadataItem.DRMQualifier = [self makeNullNil:[book objectForKey:kSCHLibreAccessWebServiceDRMQualifier]];
		newContentMetadataItem.ContentIdentifierType = [self makeNullNil:[book objectForKey:kSCHLibreAccessWebServiceContentIdentifierType]];
		newContentMetadataItem.ContentIdentifier = [self makeNullNil:[book objectForKey:kSCHLibreAccessWebServiceContentIdentifier]];
		
		newContentMetadataItem.Author = [self makeNullNil:[book objectForKey:kSCHLibreAccessWebServiceAuthor]];
		newContentMetadataItem.Version = [self makeNullNil:[book objectForKey:kSCHLibreAccessWebServiceVersion]];
		newContentMetadataItem.ProductType = [self makeNullNil:[book objectForKey:kSCHLibreAccessWebServiceProductType]];
		newContentMetadataItem.FileSize = [self makeNullNil:[book objectForKey:kSCHLibreAccessWebServiceFileSize]];
		newContentMetadataItem.CoverURL = [self makeNullNil:[book objectForKey:kSCHLibreAccessWebServiceCoverURL]];
		newContentMetadataItem.ContentURL = [self makeNullNil:[book objectForKey:kSCHLibreAccessWebServiceContentURL]];
		newContentMetadataItem.PageNumber = [self makeNullNil:[book objectForKey:kSCHLibreAccessWebServicePageNumber]];
		newContentMetadataItem.Title = [self makeNullNil:[book objectForKey:kSCHLibreAccessWebServiceTitle]];
		newContentMetadataItem.Description = [self makeNullNil:[book objectForKey:kSCHLibreAccessWebServiceDescription]];
	}
	
	// Save the context.
	if (![self.managedObjectContext save:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}	
}

- (void)clearUserSettings
{
	NSError *error = nil;

	if (![self.managedObjectContext emptyEntity:@"SCHUserSettingsItem" error:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}	
}

- (void)updateUserSettings:(NSArray *)settingsList
{
	NSError *error = nil;

	[self clearUserSettings];
	
	for (id setting in settingsList) {
		SCHUserSettingsItem *newUserSettingsItem = [NSEntityDescription insertNewObjectForEntityForName:@"SCHUserSettingsItem" inManagedObjectContext:self.managedObjectContext];
		
		newUserSettingsItem.SettingType = [self makeNullNil:[setting objectForKey:kSCHLibreAccessWebServiceSettingType]];
		newUserSettingsItem.SettingValue = [self makeNullNil:[setting objectForKey:kSCHLibreAccessWebServiceSettingValue]];
	}
	
	// Save the context.
	if (![self.managedObjectContext save:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}	
}

- (id)makeNullNil:(id)object
{
	return(object == [NSNull null] ? nil : object);
}

@end
