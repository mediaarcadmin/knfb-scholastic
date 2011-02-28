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

- (BOOL)updateProfiles;
- (NSArray *)localProfiles;
- (void)syncProfiles:(NSArray *)profileList;
- (void)addProfile:(NSDictionary *)webProfile;
- (void)syncProfile:(NSDictionary *)webProfile withProfile:(SCHProfileItem *)localProfile;

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
		
		ret = [self updateProfiles];		
	}

	return(ret);	
}

- (void)clear
{
	NSError *error = nil;
	
	if (![self.managedObjectContext emptyEntity:kSCHProfileItem error:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}		
}

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result
{	
	if([method compare:kSCHLibreAccessWebServiceSaveUserProfiles] == NSOrderedSame) {	
		self.isSynchronizing = [self.libreAccessWebService getUserProfiles];
		if (self.isSynchronizing == NO) {
			[[SCHAuthenticationManager sharedAuthenticationManager] authenticate];				
		}		
	} else if([method compare:kSCHLibreAccessWebServiceGetUserProfiles] == NSOrderedSame) {
		[self syncProfiles:[result objectForKey:kSCHLibreAccessWebServiceProfileList]];
		
		[super method:method didCompleteWithResult:nil];	
	}	
}

- (BOOL)updateProfiles
{
	BOOL ret = YES;
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	[fetchRequest setEntity:[NSEntityDescription entityForName:kSCHProfileItem inManagedObjectContext:self.managedObjectContext]];	
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"State IN %@", 
								[NSArray arrayWithObjects:[NSNumber numberWithStatus:kSCHStatusCreated], 
								 [NSNumber numberWithStatus:kSCHStatusModified],
								 [NSNumber numberWithStatus:kSCHStatusDeleted], nil]]];
		
	NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];

	if( [results count] > 0) {
		self.isSynchronizing = [self.libreAccessWebService saveUserProfiles:results];
		if (self.isSynchronizing == NO) {
			[[SCHAuthenticationManager sharedAuthenticationManager] authenticate];				
			ret = NO;			
		}		
	} else {
		
		self.isSynchronizing = [self.libreAccessWebService getUserProfiles];
		if (self.isSynchronizing == NO) {
			[[SCHAuthenticationManager sharedAuthenticationManager] authenticate];				
			ret = NO;
		}
	}
	[fetchRequest release], fetchRequest = nil;
	
	[self.managedObjectContext save:nil];	
	
	return(ret);
}

- (NSArray *)localProfiles
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	[fetchRequest setEntity:[NSEntityDescription entityForName:kSCHProfileItem inManagedObjectContext:self.managedObjectContext]];	
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceID ascending:YES]]];
	
	NSArray *ret = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];	
	
	[fetchRequest release], fetchRequest = nil;
	
	return(ret);
}

- (void)syncProfiles:(NSArray *)profileList
{		
	NSMutableSet *deletePool = [NSMutableSet set];
	NSMutableSet *creationPool = [NSMutableSet set];
	
	NSArray *webProfiles = [profileList sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceID ascending:YES]]];		
	NSArray *localProfiles = [self localProfiles];
						   
	NSEnumerator *webEnumerator = [webProfiles objectEnumerator];			  
	NSEnumerator *localEnumerator = [localProfiles objectEnumerator];			  			  

	NSDictionary *webItem = [webEnumerator nextObject];
	SCHProfileItem *localItem = [localEnumerator nextObject];
	
	while (webItem != nil || localItem != nil) {		
		if (webItem == nil) {
			while (localItem != nil) {
				[deletePool addObject:localItem];
				localItem = [localEnumerator nextObject];
			} 
			break;
		}
		
		if (localItem == nil) {
			while (webItem != nil) {
				[creationPool addObject:webItem];
				webItem = [webEnumerator nextObject];
			} 
			break;			
		}

		NSNumber *webItemID = [webItem valueForKey:kSCHLibreAccessWebServiceID];
		NSNumber *localItemID = [localItem valueForKey:kSCHLibreAccessWebServiceID];

		switch ([webItemID compare:localItemID]) {
			case NSOrderedSame:
				[self syncProfile:webItem withProfile:localItem];
				webItem = nil;
				localItem = nil;
				break;
			case NSOrderedAscending:
				[creationPool addObject:webItem];
				webItem = nil;
				break;
			case NSOrderedDescending:
				[deletePool addObject:localItem];
				localItem = nil;
				break;			
		}		
		
		if (webItem == nil) {
			webItem = [webEnumerator nextObject];
		}
		if (localItem == nil) {
			localItem = [localEnumerator nextObject];
		}		
	}
	
	for (SCHProfileItem *localItem in deletePool) {
		[self.managedObjectContext deleteObject:localItem];
	}
	
	for (NSDictionary *webItem in creationPool) {
		[self addProfile:webItem];
	}
	
	[self save];
}

- (void)addProfile:(NSDictionary *)webProfile
{
	SCHProfileItem *newProfileItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHProfileItem inManagedObjectContext:self.managedObjectContext];
	
	newProfileItem.StoryInteractionEnabled = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceStoryInteractionEnabled]];
	newProfileItem.ID = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceID]];
	newProfileItem.LastPasswordModified = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceLastPasswordModified]];
	newProfileItem.Password = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServicePassword]];
	newProfileItem.Birthday = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceBirthday]];
	newProfileItem.FirstName = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceFirstName]];
	newProfileItem.ProfilePasswordRequired = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceProfilePasswordRequired]];
	newProfileItem.Type = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceType]];
	newProfileItem.ScreenName = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceScreenName]];
	newProfileItem.AutoAssignContentToProfiles = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceAutoAssignContentToProfiles]];
	newProfileItem.LastScreenNameModified = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceLastScreenNameModified]];
	newProfileItem.UserKey = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceUserKey]];
	newProfileItem.BookshelfStyle = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceBookshelfStyle]];
	newProfileItem.LastName = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceLastName]];
	newProfileItem.LastModified = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceLastModified]];
	newProfileItem.State = [NSNumber numberWithStatus:kSCHStatusUnmodified];				
}

- (void)syncProfile:(NSDictionary *)webProfile withProfile:(SCHProfileItem *)localProfile
{	
	localProfile.StoryInteractionEnabled = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceStoryInteractionEnabled]];
	localProfile.ID = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceID]];
	localProfile.LastPasswordModified = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceLastPasswordModified]];
	localProfile.Password = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServicePassword]];
	localProfile.Birthday = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceBirthday]];
	localProfile.FirstName = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceFirstName]];
	localProfile.ProfilePasswordRequired = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceProfilePasswordRequired]];
	localProfile.Type = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceType]];
	localProfile.ScreenName = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceScreenName]];
	localProfile.AutoAssignContentToProfiles = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceAutoAssignContentToProfiles]];
	localProfile.LastScreenNameModified = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceLastScreenNameModified]];
	localProfile.UserKey = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceUserKey]];
	localProfile.BookshelfStyle = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceBookshelfStyle]];
	localProfile.LastName = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceLastName]];
	localProfile.LastModified = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceLastModified]];
	localProfile.State = [NSNumber numberWithStatus:kSCHStatusUnmodified];				
}

@end
