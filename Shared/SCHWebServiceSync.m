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
#import "SCHUserSettingsItem+Extensions.h"
#import "SCHProfileItem+Extensions.h"
#import "SCHContentMetadataItem+Extensions.h"
#import "NSNumber+ObjectTypes.h"
#import "SCHUserContentItem+Extensions.h"
#import "SCHOrderItem+Extensions.h"
#import "SCHContentProfileItem+Extensions.h"
#import "SCHListProfileContentAnnotations+Extensions.h"
#import "SCHItemsCount+Extensions.h"
#import "SCHAnnotationsList+Extensions.h"
#import "SCHAnnotationsContentItem+Extensions.h"
#import "SCHPrivateAnnotations+Extensions.h"
#import "SCHLocationGraphics+Extensions.h"
#import "SCHHighlight+Extensions.h"
#import "SCHNote+Extensions.h"
#import "SCHCoords+Extensions.h"
#import "SCHBookmark+Extensions.h"
#import "SCHLastPage+Extensions.h"
#import "SCHFavorite+Extensions.h"

@interface SCHWebServiceSync ()

- (void)clearProfiles;
- (void)updateProfiles:(NSArray *)profileList;
- (void)clearUserContentItems;
- (void)updateUserContentItems:(NSArray *)userContentList;
- (void)clearBooks;
- (void)updateBooks:(NSArray *)bookList;
- (void)clearUserSettings;
- (void)updateUserSettings:(NSArray *)settingsList;
- (void)clearProfileContentAnnotations;
- (void)updateProfileContentAnnotations:(NSDictionary *)profileContentAnnotationList;
- (SCHPrivateAnnotations *)privateAnnotation:(NSDictionary *)privateAnnotation;
- (SCHHighlight *)highlight:(NSDictionary *)highlight;
- (SCHNote *)note:(NSDictionary *)note;
- (SCHLocationGraphics *)locationGraphics:(NSDictionary *)locationGraphics;
- (SCHCoords *)coords:(NSDictionary *)coords;
- (SCHBookmark *)bookmark:(NSDictionary *)bookmark;
- (SCHLastPage *)lastPage:(NSDictionary *)lastPage;
- (SCHFavorite *)favorite:(NSDictionary *)favorite;

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
		NSArray *content = [result objectForKey:kSCHLibreAccessWebServiceUserContentList];
		if ([content count] > 0) {
			[self.libreAccessWebService listContentMetadata:content includeURLs:NO];
			
			[self clearProfileContentAnnotations];			
			
			NSMutableDictionary *profiles = [NSMutableDictionary dictionary];
			for(NSMutableDictionary *contentItem in content) {
				NSArray *contentProfileItems = [self makeNullNil:[contentItem objectForKey:kSCHLibreAccessWebServiceProfileList]];
				if (contentProfileItems != nil) {
					for (NSDictionary *contentProfileItem in contentProfileItems) {
						NSNumber *profileID = [self makeNullNil:[contentProfileItem objectForKey:kSCHLibreAccessWebServiceProfileID]];
						NSMutableArray *books = [self makeNullNil:[profiles objectForKey:profileID]];
						
						NSMutableDictionary *privateAnnotation = [NSMutableDictionary dictionary];
						NSDate *date = [NSDate distantPast];
						
						[privateAnnotation setObject:[contentItem objectForKey:kSCHLibreAccessWebServiceVersion] forKey:kSCHLibreAccessWebServiceVersion];
						[privateAnnotation setObject:date forKey:kSCHLibreAccessWebServiceHighlightsAfter];
						[privateAnnotation setObject:date forKey:kSCHLibreAccessWebServiceNotesAfter];
						[privateAnnotation setObject:date forKey:kSCHLibreAccessWebServiceBookmarksAfter];
						
						[contentItem setValue:privateAnnotation forKey:kSCHLibreAccessWebServicePrivateAnnotations];
						
						if (books == nil) {
							[profiles setObject:[NSMutableArray arrayWithObject:contentItem] forKey:profileID];
						} else {
							[books addObject:contentItem];
						}
					}
				}
			}
			
			for(NSNumber *profileID in [profiles allKeys]) {
				[self.libreAccessWebService listProfileContentAnnotations:[profiles objectForKey:profileID] forProfile:profileID];
			}
		} else {
			[self clearBooks];
		}
	} else if([method compare:kSCHLibreAccessWebServiceListContentMetadata] == NSOrderedSame) {
		[self updateBooks:[result objectForKey:kSCHLibreAccessWebServiceContentMetadataList]];
	} else if([method compare:kSCHLibreAccessWebServiceListUserSettings] == NSOrderedSame) {
		[self updateUserSettings:[result objectForKey:kSCHLibreAccessWebServiceUserSettingsList]];
	} else if([method compare:kSCHLibreAccessWebServiceListProfileContentAnnotations] == NSOrderedSame) {
		[self updateProfileContentAnnotations:[result objectForKey:kSCHLibreAccessWebServiceListProfileContentAnnotations]];
	}
}

- (void)method:(NSString *)method didFailWithError:(NSError *)error
{
	NSLog(@"%@\n%@", method, error);	
}

- (void)clearProfiles
{
	NSError *error = nil;
	
	if (![self.managedObjectContext emptyEntity:kSCHProfileItem error:&error]) {
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
		SCHProfileItem *newProfileItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHProfileItem inManagedObjectContext:self.managedObjectContext];
		
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
	
	if (![self.managedObjectContext emptyEntity:kSCHUserContentItem error:&error] ||
		![self.managedObjectContext emptyEntity:kSCHOrderItem error:&error] ||
		![self.managedObjectContext emptyEntity:kSCHContentProfileItem error:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}		
}

- (void)updateUserContentItems:(NSArray *)userContentList
{
	NSError *error = nil;
	
	[self clearUserContentItems];
	
	for (id userContentItem in userContentList) {
		SCHUserContentItem *newUserContentItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHUserContentItem inManagedObjectContext:self.managedObjectContext];
		
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
			SCHOrderItem *newOrderItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHOrderItem inManagedObjectContext:self.managedObjectContext];			

			newOrderItem.OrderID = [self makeNullNil:[userContentItem objectForKey:kSCHLibreAccessWebServiceOrderID]];
			newOrderItem.OrderDate = [self makeNullNil:[userContentItem objectForKey:kSCHLibreAccessWebServiceOrderDate]];

			[newUserContentItem addOrderListObject:newOrderItem];
		}
		
		NSArray *profileList = [self makeNullNil:[userContentItem objectForKey:kSCHLibreAccessWebServiceProfileList]];
		for (NSDictionary *profileItem in profileList) {
			SCHContentProfileItem *newContentProfileItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHContentProfileItem inManagedObjectContext:self.managedObjectContext];			
			
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

	if (![self.managedObjectContext emptyEntity:kSCHUserSettingsItem error:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}	
}

- (void)updateUserSettings:(NSArray *)settingsList
{
	NSError *error = nil;

	[self clearUserSettings];
	
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

- (void)clearProfileContentAnnotations
{
	NSError *error = nil;
	
	if (![self.managedObjectContext emptyEntity:kSCHListProfileContentAnnotations error:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}	
}

- (void)updateProfileContentAnnotations:(NSDictionary *)profileContentAnnotationList
{
	NSError *error = nil;
	
	SCHListProfileContentAnnotations *newListProfileContentAnnotations = [NSEntityDescription insertNewObjectForEntityForName:kSCHListProfileContentAnnotations inManagedObjectContext:self.managedObjectContext];
	SCHAnnotationsList *newAnnotationsList = [NSEntityDescription insertNewObjectForEntityForName:kSCHAnnotationsList inManagedObjectContext:self.managedObjectContext];
	SCHItemsCount *newItemsCount = [NSEntityDescription insertNewObjectForEntityForName:kSCHItemsCount inManagedObjectContext:self.managedObjectContext];
	
	NSDictionary *annotationsList = [self makeNullNil:[profileContentAnnotationList objectForKey:kSCHLibreAccessWebServiceAnnotationsList]];
	NSDictionary *itemsCount = [self makeNullNil:[profileContentAnnotationList objectForKey:kSCHLibreAccessWebServiceItemsCount]];	
	
	for (NSDictionary *annotationContentItem in annotationsList) {
		SCHAnnotationsContentItem *newAnnotationsContentItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHAnnotationsContentItem inManagedObjectContext:self.managedObjectContext];
		
		newAnnotationsContentItem.DRMQualifier = [self makeNullNil:[annotationContentItem objectForKey:kSCHLibreAccessWebServiceDRMQualifier]];
		newAnnotationsContentItem.ContentIdentifierType = [self makeNullNil:[annotationContentItem objectForKey:kSCHLibreAccessWebServiceContentIdentifierType]];
		newAnnotationsContentItem.ContentIdentifier = [self makeNullNil:[annotationContentItem objectForKey:kSCHLibreAccessWebServiceContentIdentifier]];
		
		newAnnotationsContentItem.Format = [self makeNullNil:[annotationContentItem objectForKey:kSCHLibreAccessWebServiceFormat]];
		//		SCHPrivateAnnotations *newPrivateAnnotations = [NSEntityDescription insertNewObjectForEntityForName:kSCHPrivateAnnotations inManagedObjectContext:self.managedObjectContext];
		
		
		//		[newAnnotationsContentItem.PrivateAnnotation = newPrivateAnnotations;
		
		[newAnnotationsList addAnnotationContentItemObject:newAnnotationsContentItem];
	}
	[newListProfileContentAnnotations addAnnotationsListObject:newAnnotationsList];
	
	newItemsCount.Found = [self makeNullNil:[itemsCount objectForKey:kSCHLibreAccessWebServiceFound]];
	newItemsCount.Returned = [self makeNullNil:[itemsCount objectForKey:kSCHLibreAccessWebServiceReturned]];	
	newListProfileContentAnnotations.ItemsCount = newItemsCount;
	
	// Save the context.
	if (![self.managedObjectContext save:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}	
}

- (SCHPrivateAnnotations *)privateAnnotation:(NSDictionary *)privateAnnotation
{
	SCHPrivateAnnotations *ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHPrivateAnnotations inManagedObjectContext:self.managedObjectContext];
	
	if (privateAnnotation != nil) {
		for (NSDictionary *highlight in [privateAnnotation objectForKey:kSCHLibreAccessWebServiceHighlights]) { 
			[ret addHighlightsObject:[self highlight:highlight]];
		}
		for (NSDictionary *note in [privateAnnotation objectForKey:kSCHLibreAccessWebServiceNotes]) { 
			[ret addNotesObject:[self note:note]];
		}
		for (NSDictionary *bookmark in [privateAnnotation objectForKey:kSCHLibreAccessWebServiceBookmarks]) { 
			[ret addBookmarksObject:[self bookmark:bookmark]];
		}
		ret.LastPage = [self lastPage:[privateAnnotation objectForKey:kSCHLibreAccessWebServiceLastPage]];
		ret.Favorite = [self favorite:[privateAnnotation objectForKey:kSCHLibreAccessWebServiceFavorite]];		 
	}
	return(ret);
}

- (SCHHighlight *)highlight:(NSDictionary *)highlight
{
	SCHHighlight *ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHHighlight inManagedObjectContext:self.managedObjectContext];
	
	if (highlight != nil) {
		ret.LastModified = [self makeNullNil:[highlight objectForKey:kSCHLibreAccessWebServiceLastModified]];
		ret.State = [NSNumber numberWithStatus:kSCHStatusCreated];
		
		ret.ID = [self makeNullNil:[highlight objectForKey:kSCHLibreAccessWebServiceID]];
		ret.Version = [self makeNullNil:[highlight objectForKey:kSCHLibreAccessWebServiceVersion]];
		ret.Action = [self makeNullNil:[highlight objectForKey:kSCHLibreAccessWebServiceAction]];
		
		ret.Color = [self makeNullNil:[highlight objectForKey:kSCHLibreAccessWebServiceColor]];
		ret.EndPage = [self makeNullNil:[highlight objectForKey:kSCHLibreAccessWebServiceEndPage]];
		ret.LocationText = [self makeNullNil:[highlight objectForKey:kSCHLibreAccessWebServiceLocationText]];
	}
	
	return(ret);
}

- (SCHNote *)note:(NSDictionary *)note
{
	SCHNote *ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHNote inManagedObjectContext:self.managedObjectContext];
	
	if (note != nil) {
		ret.LastModified = [self makeNullNil:[note objectForKey:kSCHLibreAccessWebServiceLastModified]];
		ret.State = [NSNumber numberWithStatus:kSCHStatusCreated];
		
		ret.ID = [self makeNullNil:[note objectForKey:kSCHLibreAccessWebServiceID]];
		ret.Version = [self makeNullNil:[note objectForKey:kSCHLibreAccessWebServiceVersion]];
		ret.Action = [self makeNullNil:[note objectForKey:kSCHLibreAccessWebServiceAction]];
		
		ret.Color = [self makeNullNil:[note objectForKey:kSCHLibreAccessWebServiceColor]];
		ret.Value = [self makeNullNil:[note objectForKey:kSCHLibreAccessWebServiceValue]];
		ret.LocationGraphics = [self locationGraphics:[note objectForKey:kSCHLibreAccessWebServiceLocationGraphics]];
	}
	
	return(ret);
}

- (SCHLocationGraphics *)locationGraphics:(NSDictionary *)locationGraphics
{
	SCHLocationGraphics *ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHLocationGraphics inManagedObjectContext:self.managedObjectContext];
	
	if (locationGraphics != nil) {
		ret.Page = [self makeNullNil:[locationGraphics objectForKey:kSCHLibreAccessWebServicePage]];
		ret.Coords = [self coords:[locationGraphics objectForKey:kSCHLibreAccessWebServiceWordIndex]];
		ret.WordIndex = [self makeNullNil:[locationGraphics objectForKey:kSCHLibreAccessWebServiceWordIndex]];		
	}
	
	return(ret);
}

- (SCHCoords *)coords:(NSDictionary *)coords
{
	SCHCoords *ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHCoords inManagedObjectContext:self.managedObjectContext];
	
	if (coords != nil) {
		ret.X = [self makeNullNil:[coords objectForKey:kSCHLibreAccessWebServiceX]];
		ret.Y = [self makeNullNil:[coords objectForKey:kSCHLibreAccessWebServiceY]];		
	}
	
	return(ret);
}

- (SCHBookmark *)bookmark:(NSDictionary *)bookmark
{
	SCHBookmark *ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHBookmark inManagedObjectContext:self.managedObjectContext];
	
	if (bookmark != nil) {
		ret.LastModified = [self makeNullNil:[bookmark objectForKey:kSCHLibreAccessWebServiceLastModified]];
		ret.State = [NSNumber numberWithStatus:kSCHStatusCreated];
		
		ret.ID = [self makeNullNil:[bookmark objectForKey:kSCHLibreAccessWebServiceID]];
		ret.Version = [self makeNullNil:[bookmark objectForKey:kSCHLibreAccessWebServiceVersion]];
		ret.Action = [self makeNullNil:[bookmark objectForKey:kSCHLibreAccessWebServiceAction]];
		
		ret.Disabled = [self makeNullNil:[bookmark objectForKey:kSCHLibreAccessWebServiceDisabled]];
		ret.Text = [self makeNullNil:[bookmark objectForKey:kSCHLibreAccessWebServiceText]];
		ret.Page = [self makeNullNil:[bookmark objectForKey:kSCHLibreAccessWebServicePage]];
	}
	
	return(ret);
}

- (SCHLastPage *)lastPage:(NSDictionary *)lastPage
{
	SCHLastPage *ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHLastPage inManagedObjectContext:self.managedObjectContext];
	
	if (lastPage != nil) {
		ret.LastModified = [self makeNullNil:[lastPage objectForKey:kSCHLibreAccessWebServiceLastModified]];
		ret.State = [NSNumber numberWithStatus:kSCHStatusCreated];
		
		ret.LastPageLocation = [self makeNullNil:[lastPage objectForKey:kSCHLibreAccessWebServiceLastPageLocation]];
		ret.Percentage = [self makeNullNil:[lastPage objectForKey:kSCHLibreAccessWebServicePercentage]];
		ret.Component = [self makeNullNil:[lastPage objectForKey:kSCHLibreAccessWebServiceComponent]];
	}
	
	return(ret);
}

- (SCHFavorite *)favorite:(NSDictionary *)favorite
{
	SCHFavorite *ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHFavorite inManagedObjectContext:self.managedObjectContext];
	
	if (favorite != nil) {
		ret.LastModified = [self makeNullNil:[favorite objectForKey:kSCHLibreAccessWebServiceLastModified]];
		ret.State = [NSNumber numberWithStatus:kSCHStatusCreated];
		
		ret.IsFavorite = [self makeNullNil:[favorite objectForKey:kSCHLibreAccessWebServiceIsFavorite]];
	}
	
	return(ret);
}

- (id)makeNullNil:(id)object
{
	return(object == [NSNull null] ? nil : object);
}

@end
