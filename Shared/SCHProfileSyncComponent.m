//
//  SCHProfileSyncComponent.m
//  Scholastic
//
//  Created by John S. Eddie on 04/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHProfileSyncComponent.h"
#import "SCHSyncComponentProtected.h"
#import "NSManagedObjectContext+Extensions.h"

#import "SCHLibreAccessWebService.h"
#import "SCHProfileItem+Extensions.h"

@interface SCHProfileSyncComponent ()

- (void)clearProfiles;
- (void)syncProfiles:(NSArray *)profileList;

@end

@implementation SCHProfileSyncComponent

- (BOOL)synchronize
{
	BOOL ret = YES;
	
	if (self.isSynchronizing == NO) {
		self.backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{ 
			self.isSynchronizing = NO;
			self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
		}];
		
		self.isSynchronizing = [self.libreAccessWebService getUserProfiles];
		if (self.isSynchronizing == NO) {
			[[SCHAuthenticationManager sharedAuthenticationManager] authenticate];				
			ret = NO;
		}
	}
	
	return(ret);	
}

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result
{	
	[self syncProfiles:[result objectForKey:kSCHLibreAccessWebServiceProfileList]];
	
	[super method:method didCompleteWithResult:nil];
}

- (void)clearProfiles
{
	NSError *error = nil;
	
	if (![self.managedObjectContext emptyEntity:kSCHProfileItem error:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}		
}

- (void)syncProfiles:(NSArray *)profileList
{	
	[self clearProfiles];
	
	for (id profile in profileList) {
		SCHProfileItem *newProfileItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHProfileItem inManagedObjectContext:self.managedObjectContext];
		
		newProfileItem.LastModified = [self makeNullNil:[profile objectForKey:kSCHLibreAccessWebServiceLastModified]];
		
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
		
	[self save];
}

@end
