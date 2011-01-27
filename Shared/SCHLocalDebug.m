//
//  SCHLocalDebug.m
//  Scholastic
//
//  Created by John S. Eddie on 13/01/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHLocalDebug.h"

#import "SCHLibreAccessWebService.h"
#import "NSManagedObjectContext+Extensions.h"
#import "SCHAuthenticationManager.h"
#import "SCHUserSettingsItem.h"
#import "SCHProfileItem.h"
#import "SCHContentMetadataItem.h"

@interface SCHLocalDebug ()

- (void)clearProfiles;
- (void)clearBooks;
- (void)clearUserSettings;
- (id)makeNullNil:(id)object;

@end

@implementation SCHLocalDebug

@synthesize managedObjectContext;

- (void)dealloc
{
	self.managedObjectContext = nil;
	
	[super dealloc];
}

- (void)setupLocalDataWithXPSFiles:(NSArray *)XPSFiles
{
	NSError *error = nil;
	
	[self clearProfiles];
	[self clearBooks];
	[self clearUserSettings];
	
	SCHContentMetadataItem *newContentMetadataItem = nil;
	
	for (NSString *xpsFile in XPSFiles) {
		newContentMetadataItem = [NSEntityDescription insertNewObjectForEntityForName:@"SCHContentMetadataItem" inManagedObjectContext:self.managedObjectContext];
		
		//	newContentMetadataItem.Author = [self makeNullNil:[book objectForKey:kSCHLibreAccessWebServiceAuthor]];
		//	newContentMetadataItem.Version = [self makeNullNil:[book objectForKey:kSCHLibreAccessWebServiceVersion]];
		//	newContentMetadataItem.ProductType = [self makeNullNil:[book objectForKey:kSCHLibreAccessWebServiceProductType]];
		//	newContentMetadataItem.FileSize = [self makeNullNil:[book objectForKey:kSCHLibreAccessWebServiceFileSize]];
		//	newContentMetadataItem.CoverURL = [self makeNullNil:[book objectForKey:kSCHLibreAccessWebServiceCoverURL]];
		//	newContentMetadataItem.ContentURL = [self makeNullNil:[book objectForKey:kSCHLibreAccessWebServiceContentURL]];
		//	newContentMetadataItem.PageNumber = [self makeNullNil:[book objectForKey:kSCHLibreAccessWebServicePageNumber]];
		newContentMetadataItem.Title = xpsFile;
		newContentMetadataItem.FileName = xpsFile;		
		//	newContentMetadataItem.Description = [self makeNullNil:[book objectForKey:kSCHLibreAccessWebServiceDescription]];
	}

	// Save the context.
	if (![self.managedObjectContext save:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}	
}

- (void)clearProfiles
{
	NSError *error = nil;
	
	if (![self.managedObjectContext emptyEntity:@"SCHProfileItem" error:&error]) {
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

- (void)clearUserSettings
{
	NSError *error = nil;
	
	if (![self.managedObjectContext emptyEntity:@"SCHUserSettingsItem" error:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}	
}

- (id)makeNullNil:(id)object
{
	return(object == [NSNull null] ? nil : object);
}

@end
