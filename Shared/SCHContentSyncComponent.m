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
#import "SCHUserContentItem.h"
#import "SCHOrderItem.h"
#import "SCHContentProfileItem.h"
#import "SCHProfileItem.h"
#import "SCHAnnotationsItem.h"
#import "SCHAnnotationsContentItem.h"
#import "SCHFavorite.h"
#import "SCHLastPage.h"
#import "SCHPrivateAnnotations.h"

@interface SCHContentSyncComponent ()

- (BOOL)updateUserContentItems;

- (NSArray *)localUserContentItems;
- (void)syncUserContentItems:(NSArray *)userContentList;
- (void)addUserContentItem:(NSDictionary *)webUserContentItem;
- (void)addAnnotationStructure:(SCHUserContentItem *)userContentItem 
                    forProfile:(SCHContentProfileItem *)contentProfileItem;
- (SCHOrderItem *)addOrderItem:(NSDictionary *)orderItem;
- (SCHContentProfileItem *)addContentProfileItem:(NSDictionary *)contentProfileItem;
- (void)syncUserContentItem:(NSDictionary *)webUserContentItem 
        withUserContentItem:(SCHUserContentItem *)localUserContentItem;
- (void)syncOrderItems:(NSArray *)webOrderList 
        localOrderList:(NSSet *)localOrderList;
- (void)syncOrderItem:(NSDictionary *)webOrderItem 
        withOrderItem:(SCHOrderItem *)localOrderItem;
- (void)syncContentProfileItems:(NSArray *)webContentProfileList 
        localContentProfileList:(NSSet *)localContentProfileList;
- (void)syncContentProfileItem:(NSDictionary *)webContentProfileItem 
        withContentProfileItem:(SCHContentProfileItem *)localContentProfileItem;

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
		
		ret = [self updateUserContentItems];
	}
	
	return(ret);		
}

- (void)clear
{
	NSError *error = nil;
	
	if (![self.managedObjectContext BITemptyEntity:kSCHUserContentItem error:&error] ||
		![self.managedObjectContext BITemptyEntity:kSCHOrderItem error:&error] ||
		![self.managedObjectContext BITemptyEntity:kSCHContentProfileItem error:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}		
}

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result
{	
	if([method compare:kSCHLibreAccessWebServiceSaveContentProfileAssignment] == NSOrderedSame) {	
		self.isSynchronizing = [self.libreAccessWebService listUserContent];
		if (self.isSynchronizing == NO) {
			[[SCHAuthenticationManager sharedAuthenticationManager] authenticate];				
		}
	} else if([method compare:kSCHLibreAccessWebServiceListUserContent] == NSOrderedSame) {
		NSArray *content = [result objectForKey:kSCHLibreAccessWebServiceUserContentList];
		
		[self syncUserContentItems:content];
		[[NSNotificationCenter defaultCenter] postNotificationName:kSCHContentSyncComponentComplete object:self];
		[super method:method didCompleteWithResult:nil];				
	}
}

- (BOOL)updateUserContentItems
{		
	BOOL ret = YES;
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	[fetchRequest setEntity:[NSEntityDescription entityForName:kSCHUserContentItem inManagedObjectContext:self.managedObjectContext]];	
	NSArray *changedStates = [NSArray arrayWithObjects:[NSNumber numberWithStatus:kSCHStatusCreated], 
					   [NSNumber numberWithStatus:kSCHStatusModified],
					   [NSNumber numberWithStatus:kSCHStatusDeleted], nil];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"ANY ProfileList.State IN %@", changedStates]];
	
	NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
		
	if( [results count] > 0) {
		self.isSynchronizing = [self.libreAccessWebService saveContentProfileAssignment:results];
		if (self.isSynchronizing == NO) {
			[[SCHAuthenticationManager sharedAuthenticationManager] authenticate];				
			ret = NO;			
		}		
	} else {
		self.isSynchronizing = [self.libreAccessWebService listUserContent];
		if (self.isSynchronizing == NO) {
			[[SCHAuthenticationManager sharedAuthenticationManager] authenticate];				
			ret = NO;
		}
	}
	[fetchRequest release], fetchRequest = nil;
	
	return(ret);	
}

- (NSArray *)localUserContentItems
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	[fetchRequest setEntity:[NSEntityDescription entityForName:kSCHUserContentItem inManagedObjectContext:self.managedObjectContext]];	
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceContentIdentifier ascending:YES]]];
	
	NSArray *ret = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];	
	
	[fetchRequest release], fetchRequest = nil;
	
	return(ret);
}

- (void)syncUserContentItems:(NSArray *)userContentList
{		
	NSMutableSet *deletePool = [NSMutableSet set];
	NSMutableSet *creationPool = [NSMutableSet set];
	
	NSArray *webProfiles = [userContentList sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceContentIdentifier ascending:YES]]];		
	NSArray *localProfiles = [self localUserContentItems];
	
	NSEnumerator *webEnumerator = [webProfiles objectEnumerator];			  
	NSEnumerator *localEnumerator = [localProfiles objectEnumerator];			  			  
	
	NSDictionary *webItem = [webEnumerator nextObject];
	SCHUserContentItem *localItem = [localEnumerator nextObject];
	
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
		
		id webItemID = [webItem valueForKey:kSCHLibreAccessWebServiceContentIdentifier];
		id localItemID = [localItem valueForKey:kSCHLibreAccessWebServiceContentIdentifier];
		
		switch ([webItemID compare:localItemID]) {
			case NSOrderedSame:
				[self syncUserContentItem:webItem withUserContentItem:localItem];
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
	
	for (SCHUserContentItem *localItem in deletePool) {
		[self.managedObjectContext deleteObject:localItem];
	}
	
	for (NSDictionary *webItem in creationPool) {
		[self addUserContentItem:webItem];
	}
	
	[self save];
}

- (void)addUserContentItem:(NSDictionary *)webUserContentItem
{
	SCHUserContentItem *newUserContentItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHUserContentItem inManagedObjectContext:self.managedObjectContext];
	
	newUserContentItem.DRMQualifier = [self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceDRMQualifier]];
	newUserContentItem.Version = [self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceVersion]];
	newUserContentItem.ContentIdentifier = [self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceContentIdentifier]];
	newUserContentItem.Format = [self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceFormat]];		
	newUserContentItem.DefaultAssignment = [self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceDefaultAssignment]];		
	newUserContentItem.ContentIdentifierType = [self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceContentIdentifierType]];				
	
	NSArray *orderList = [self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceOrderList]];
	for (NSDictionary *orderItem in orderList) {
		[newUserContentItem addOrderListObject:[self addOrderItem:orderItem]];
	}
	
	NSArray *profileList = [self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceProfileList]];
	for (NSDictionary *profileItem in profileList) {     
        SCHContentProfileItem *contentProfileItem = [self addContentProfileItem:profileItem];
		[newUserContentItem addProfileListObject:contentProfileItem];
        [self addAnnotationStructure:newUserContentItem forProfile:contentProfileItem];
	}
    	
	newUserContentItem.LastModified = [self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceLastModified]];
	newUserContentItem.State = [NSNumber numberWithStatus:kSCHStatusUnmodified];				
}

- (void)addAnnotationStructure:(SCHUserContentItem *)userContentItem forProfile:(SCHContentProfileItem *)contentProfileItem
{
    if (userContentItem != nil && contentProfileItem != nil) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        [fetchRequest setEntity:[NSEntityDescription entityForName:kSCHAnnotationsItem inManagedObjectContext:self.managedObjectContext]];	
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"ProfileID == %@", contentProfileItem.ProfileID]];
        
        NSArray *annotationsItems = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];	
        
        [fetchRequest release], fetchRequest = nil;
        
        if([annotationsItems count] > 0) {
            NSDate *date = [NSDate date];
            
            SCHFavorite *newFavorite = [NSEntityDescription insertNewObjectForEntityForName:kSCHFavorite 
                                                                     inManagedObjectContext:self.managedObjectContext];
            newFavorite.LastModified = date;
            newFavorite.State = [NSNumber numberWithStatus:kSCHStatusCreated];
            newFavorite.IsFavorite = [NSNumber numberWithBool:NO];
            
            SCHLastPage *newLastPage = [NSEntityDescription insertNewObjectForEntityForName:kSCHLastPage 
                                                                     inManagedObjectContext:self.managedObjectContext];
            newLastPage.LastModified = date;
            newLastPage.State = [NSNumber numberWithStatus:kSCHStatusCreated];
            newLastPage.LastPageLocation = [NSNumber numberWithInteger:0];
            newLastPage.Percentage = [NSNumber numberWithFloat:0.0];
            newLastPage.Component = @"";
            
            SCHPrivateAnnotations *newPrivateAnnotations = [NSEntityDescription insertNewObjectForEntityForName:kSCHPrivateAnnotations 
                                                                                         inManagedObjectContext:self.managedObjectContext];
            newPrivateAnnotations.LastPage = newLastPage;
            newPrivateAnnotations.Favorite = newFavorite;
            
            SCHAnnotationsContentItem *newAnnotationsContentItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHAnnotationsContentItem 
                                                                                                 inManagedObjectContext:self.managedObjectContext];
            newAnnotationsContentItem.AnnotationsItem = [annotationsItems objectAtIndex:0];
            newAnnotationsContentItem.DRMQualifier = userContentItem.DRMQualifier;
            newAnnotationsContentItem.ContentIdentifier = userContentItem.ContentIdentifier;
            newAnnotationsContentItem.Format = userContentItem.Format;
            newAnnotationsContentItem.ContentIdentifierType = userContentItem.ContentIdentifierType;
            newAnnotationsContentItem.PrivateAnnotations = newPrivateAnnotations;
        }
    }
}

- (SCHOrderItem *)addOrderItem:(NSDictionary *)orderItem
{
	SCHOrderItem *ret = nil;
	
	if (orderItem != nil) {	
		ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHOrderItem inManagedObjectContext:self.managedObjectContext];			
		
		ret.OrderID = [self makeNullNil:[orderItem objectForKey:kSCHLibreAccessWebServiceOrderID]];
		ret.OrderDate = [self makeNullNil:[orderItem objectForKey:kSCHLibreAccessWebServiceOrderDate]];
	}
	
	return(ret);
}

- (SCHContentProfileItem *)addContentProfileItem:(NSDictionary *)contentProfileItem
{
	SCHContentProfileItem *ret = nil;
	
	if (contentProfileItem != nil) {		
		ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHContentProfileItem inManagedObjectContext:self.managedObjectContext];			
		
		ret.LastModified = [self makeNullNil:[contentProfileItem objectForKey:kSCHLibreAccessWebServiceLastModified]];
		ret.State = [NSNumber numberWithStatus:kSCHStatusUnmodified];
		
		ret.IsFavorite = [self makeNullNil:[contentProfileItem objectForKey:kSCHLibreAccessWebServiceIsFavorite]];
		
		ret.ProfileID = [self makeNullNil:[contentProfileItem objectForKey:kSCHLibreAccessWebServiceProfileID]];
		ret.LastPageLocation = [self makeNullNil:[contentProfileItem objectForKey:kSCHLibreAccessWebServiceLastPageLocation]];
	}
	
	return(ret);
}

- (void)syncUserContentItem:(NSDictionary *)webUserContentItem withUserContentItem:(SCHUserContentItem *)localUserContentItem
{
	localUserContentItem.DRMQualifier = [self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceDRMQualifier]];
	localUserContentItem.Version = [self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceVersion]];
	localUserContentItem.ContentIdentifier = [self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceContentIdentifier]];
	localUserContentItem.Format = [self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceFormat]];		
	localUserContentItem.DefaultAssignment = [self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceDefaultAssignment]];		
	localUserContentItem.ContentIdentifierType = [self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceContentIdentifierType]];				
	
	[self syncOrderItems:[self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceOrderList]] localOrderList:localUserContentItem.OrderList];

	[self syncContentProfileItems:[self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceProfileList]] localContentProfileList:localUserContentItem.ProfileList];
	
	localUserContentItem.LastModified = [self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceLastModified]];
	localUserContentItem.State = [NSNumber numberWithStatus:kSCHStatusUnmodified];				
}

- (void)syncOrderItems:(NSArray *)webOrderList localOrderList:(NSSet *)localOrderList
{		
	NSArray *sortDescriptor = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceOrderID ascending:YES]];
	NSMutableSet *deletePool = [NSMutableSet set];
	NSMutableSet *creationPool = [NSMutableSet set];
	
	NSArray *webProfiles = [webOrderList sortedArrayUsingDescriptors:sortDescriptor];		
	NSArray *localProfiles = [localOrderList sortedArrayUsingDescriptors:sortDescriptor];
	
	NSEnumerator *webEnumerator = [webProfiles objectEnumerator];			  
	NSEnumerator *localEnumerator = [localProfiles objectEnumerator];			  			  
	
	NSDictionary *webItem = [webEnumerator nextObject];
	SCHOrderItem *localItem = [localEnumerator nextObject];
	
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
		
		NSNumber *webItemID = [webItem valueForKey:kSCHLibreAccessWebServiceOrderID];
		NSNumber *localItemID = [localItem valueForKey:kSCHLibreAccessWebServiceOrderID];
		
		switch ([webItemID compare:localItemID]) {
			case NSOrderedSame:
				[self syncOrderItem:webItem withOrderItem:localItem];
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
	
	for (SCHOrderItem *localItem in deletePool) {
		[self.managedObjectContext deleteObject:localItem];
	}
	
	for (NSDictionary *webItem in creationPool) {
		[self addOrderItem:webItem];
	}
}

- (void)syncOrderItem:(NSDictionary *)webOrderItem withOrderItem:(SCHOrderItem *)localOrderItem
{
	localOrderItem.OrderID = [self makeNullNil:[webOrderItem objectForKey:kSCHLibreAccessWebServiceOrderID]];
	localOrderItem.OrderDate = [self makeNullNil:[webOrderItem objectForKey:kSCHLibreAccessWebServiceOrderDate]];
}

- (void)syncContentProfileItems:(NSArray *)webContentProfileList localContentProfileList:(NSSet *)localContentProfileList
{		
	NSArray *sortDescriptor = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceProfileID ascending:YES]];
	NSMutableSet *deletePool = [NSMutableSet set];
	NSMutableSet *creationPool = [NSMutableSet set];
	
	NSArray *webProfiles = [webContentProfileList sortedArrayUsingDescriptors:sortDescriptor];		
	NSArray *localProfiles = [localContentProfileList sortedArrayUsingDescriptors:sortDescriptor];
	
	NSEnumerator *webEnumerator = [webProfiles objectEnumerator];			  
	NSEnumerator *localEnumerator = [localProfiles objectEnumerator];			  			  
	
	NSDictionary *webItem = [webEnumerator nextObject];
	SCHContentProfileItem *localItem = [localEnumerator nextObject];
	
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
		
		NSNumber *webItemID = [webItem valueForKey:kSCHLibreAccessWebServiceProfileID];
		NSNumber *localItemID = [localItem valueForKey:kSCHLibreAccessWebServiceProfileID];
		
		switch ([webItemID compare:localItemID]) {
			case NSOrderedSame:
				[self syncContentProfileItem:webItem withContentProfileItem:localItem];
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
	
	for (SCHContentProfileItem *localItem in deletePool) {
		[self.managedObjectContext deleteObject:localItem];
	}
	
	for (NSDictionary *webItem in creationPool) {
		[self addContentProfileItem:webItem];
	}
}

- (void)syncContentProfileItem:(NSDictionary *)webContentProfileItem withContentProfileItem:(SCHContentProfileItem *)localContentProfileItem
{
	localContentProfileItem.LastModified = [self makeNullNil:[webContentProfileItem objectForKey:kSCHLibreAccessWebServiceLastModified]];
	localContentProfileItem.State = [NSNumber numberWithStatus:kSCHStatusUnmodified];
	
	localContentProfileItem.IsFavorite = [self makeNullNil:[webContentProfileItem objectForKey:kSCHLibreAccessWebServiceIsFavorite]];
	
	localContentProfileItem.ProfileID = [self makeNullNil:[webContentProfileItem objectForKey:kSCHLibreAccessWebServiceProfileID]];
	localContentProfileItem.LastPageLocation = [self makeNullNil:[webContentProfileItem objectForKey:kSCHLibreAccessWebServiceLastPageLocation]];
}

@end
