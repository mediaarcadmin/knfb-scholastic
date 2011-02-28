//
//  SCHContentSyncComponent.m
//  Scholastic
//
//  Created by John S. Eddie on 04/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHContentSyncComponent.h"
#import "SCHSyncComponentProtected.h"
#import "NSManagedObjectContext+Extensions.h"

#import "SCHLibreAccessWebService.h"
#import "SCHUserContentItem+Extensions.h"
#import "SCHContentMetadataItem+Extensions.h"
#import "SCHOrderItem+Extensions.h"
#import "SCHContentProfileItem+Extensions.h"

@interface SCHContentSyncComponent ()

- (void)updateUserContentItems:(NSArray *)userContentList;
- (SCHOrderItem *)orderItem:(NSDictionary *)orderItem;
- (SCHContentProfileItem *)contentProfileItem:(NSDictionary *)contentProfileItem;
- (void)clearBooks;
- (void)updateBooks:(NSArray *)bookList;

@end

@implementation SCHContentSyncComponent

- (BOOL)synchronize
{
	BOOL ret = YES;
	
	if (self.isSynchronizing == NO) {
		self.backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{ 
			self.isSynchronizing = NO;
			self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
		}];
		
		self.isSynchronizing = [self.libreAccessWebService listUserContent];
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
	
	if (![self.managedObjectContext emptyEntity:kSCHUserContentItem error:&error] ||
		![self.managedObjectContext emptyEntity:kSCHOrderItem error:&error] ||
		![self.managedObjectContext emptyEntity:kSCHContentProfileItem error:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}		
}

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result
{	
	if([method compare:kSCHLibreAccessWebServiceListUserContent] == NSOrderedSame) {
		[self updateUserContentItems:[result objectForKey:kSCHLibreAccessWebServiceUserContentList]];
		NSArray *content = [result objectForKey:kSCHLibreAccessWebServiceUserContentList];
		if ([content count] > 0) {
			[self.libreAccessWebService listContentMetadata:content includeURLs:YES];
		} else {
			[self clearBooks];
		}
	} else if([method compare:kSCHLibreAccessWebServiceListContentMetadata] == NSOrderedSame) {
		[self updateBooks:[result objectForKey:kSCHLibreAccessWebServiceContentMetadataList]];
		
		[super method:method didCompleteWithResult:nil];	
	}	
}

- (void)updateUserContentItems:(NSArray *)userContentList
{
	NSError *error = nil;
	
	[self clear];
	
	for (id userContentItem in userContentList) {
		SCHUserContentItem *newUserContentItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHUserContentItem inManagedObjectContext:self.managedObjectContext];
		
		newUserContentItem.LastModified = [self makeNullNil:[userContentItem objectForKey:kSCHLibreAccessWebServiceLastModified]];
		
		newUserContentItem.DRMQualifier = [self makeNullNil:[userContentItem objectForKey:kSCHLibreAccessWebServiceDRMQualifier]];
		newUserContentItem.Version = [self makeNullNil:[userContentItem objectForKey:kSCHLibreAccessWebServiceVersion]];
		newUserContentItem.ContentIdentifier = [self makeNullNil:[userContentItem objectForKey:kSCHLibreAccessWebServiceContentIdentifier]];
		newUserContentItem.Format = [self makeNullNil:[userContentItem objectForKey:kSCHLibreAccessWebServiceFormat]];		
		newUserContentItem.DefaultAssignment = [self makeNullNil:[userContentItem objectForKey:kSCHLibreAccessWebServiceDefaultAssignment]];		
		newUserContentItem.ContentIdentifierType = [self makeNullNil:[userContentItem objectForKey:kSCHLibreAccessWebServiceContentIdentifierType]];				
		
		NSArray *orderList = [self makeNullNil:[userContentItem objectForKey:kSCHLibreAccessWebServiceOrderList]];
		for (NSDictionary *orderItem in orderList) {
			[newUserContentItem addOrderListObject:[self orderItem:orderItem]];
		}
		
		NSArray *profileList = [self makeNullNil:[userContentItem objectForKey:kSCHLibreAccessWebServiceProfileList]];
		for (NSDictionary *profileItem in profileList) {
			[newUserContentItem addProfileListObject:[self contentProfileItem:profileItem]];
		}
		
	}
	
	// Save the context.
	if (![self.managedObjectContext save:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}	
}

- (SCHOrderItem *)orderItem:(NSDictionary *)orderItem
{
	SCHOrderItem *ret = nil;
	
	if (orderItem != nil) {	
		ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHOrderItem inManagedObjectContext:self.managedObjectContext];			
		
		ret.OrderID = [self makeNullNil:[orderItem objectForKey:kSCHLibreAccessWebServiceOrderID]];
		ret.OrderDate = [self makeNullNil:[orderItem objectForKey:kSCHLibreAccessWebServiceOrderDate]];
	}
	
	return(ret);
}

- (SCHContentProfileItem *)contentProfileItem:(NSDictionary *)contentProfileItem
{
	SCHContentProfileItem *ret = nil;
	
	if (contentProfileItem != nil) {		
		ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHContentProfileItem inManagedObjectContext:self.managedObjectContext];			
		
		ret.LastModified = [self makeNullNil:[contentProfileItem objectForKey:kSCHLibreAccessWebServiceLastModified]];
		
		ret.IsFavorite = [self makeNullNil:[contentProfileItem objectForKey:kSCHLibreAccessWebServiceIsFavorite]];
		
		ret.ProfileID = [self makeNullNil:[contentProfileItem objectForKey:kSCHLibreAccessWebServiceProfileID]];
		ret.LastPageLocation = [self makeNullNil:[contentProfileItem objectForKey:kSCHLibreAccessWebServiceLastPageLocation]];
	}
	
	return(ret);
}

- (void)clearBooks
{
	NSError *error = nil;
	
	if (![self.managedObjectContext emptyEntity:kSCHContentMetadataItem error:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}	
}

- (void)updateBooks:(NSArray *)bookList
{
	NSError *error = nil;
	
	[self clearBooks];
	
	for (id book in bookList) {
		SCHContentMetadataItem *newContentMetadataItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHContentMetadataItem inManagedObjectContext:self.managedObjectContext];
		
		newContentMetadataItem.DRMQualifier = [self makeNullNil:[book objectForKey:kSCHLibreAccessWebServiceDRMQualifier]];
		newContentMetadataItem.ContentIdentifierType = [self makeNullNil:[book objectForKey:kSCHLibreAccessWebServiceContentIdentifierType]];
		newContentMetadataItem.ContentIdentifier = [self makeNullNil:[book objectForKey:kSCHLibreAccessWebServiceContentIdentifier]];
		
		newContentMetadataItem.Author = [self makeNullNil:[book objectForKey:kSCHLibreAccessWebServiceAuthor]];
		newContentMetadataItem.Version = [self makeNullNil:[book objectForKey:kSCHLibreAccessWebServiceVersion]];
		newContentMetadataItem.Enhanced = [self makeNullNil:[book objectForKey:kSCHLibreAccessWebServiceEnhanced]];
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

@end
