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
#import "SCHContentMetadataItem+Extensions.h"
#import "BWKXPSProvider.h"
#import "NSNumber+ObjectTypes.h"
#import "BWKBookManager.h"

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
		newContentMetadataItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHContentMetadataItem inManagedObjectContext:self.managedObjectContext];
		
		NSString *xpsPath = [[NSBundle mainBundle] pathForResource:xpsFile ofType:@"xps"];

		//BWKXPSProvider *provider = [[BWKXPSProvider alloc] initWithPath:xpsPath];
		BWKXPSProvider *provider = [[BWKBookManager sharedBookManager] checkOutXPSProviderForBookWithPath:xpsPath];
		
//		NSLog(@"Provider: %p", provider);
//		NSLog(@"Provider count: %d", [provider retainCount]);
		
		//	newContentMetadataItem.DRMQualifier = provider.author;
		if (provider.ISBN != nil && [[provider.ISBN stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
			newContentMetadataItem.ContentIdentifierType = [NSNumber numberWithContentIdentifierType:kSCHContentItemContentIdentifierTypesISBN13];
		} else {
			newContentMetadataItem.ContentIdentifierType = [NSNumber numberWithContentIdentifierType:kSCHContentIdentifierTypesNone];			
		}
		newContentMetadataItem.ContentIdentifier = provider.ISBN;

		newContentMetadataItem.Author = provider.author;
		//	newContentMetadataItem.Version = [self makeNullNil:[book objectForKey:kSCHLibreAccessWebServiceVersion]];
		//newContentMetadataItem.ProductType = [self makeNullNil:[book objectForKey:kSCHLibreAccessWebServiceProductType]];
		newContentMetadataItem.FileSize = [NSNumber numberWithLongLong:provider.fileSize];
		//	newContentMetadataItem.CoverURL = [self makeNullNil:[book objectForKey:kSCHLibreAccessWebServiceCoverURL]];
		//	newContentMetadataItem.ContentURL = [self makeNullNil:[book objectForKey:kSCHLibreAccessWebServiceContentURL]];
		newContentMetadataItem.PageNumber = [NSNumber numberWithInteger:provider.pageCount];
		newContentMetadataItem.Title = provider.title;
		newContentMetadataItem.FileName = xpsFile;		
		//	newContentMetadataItem.Description = [self makeNullNil:[book objectForKey:kSCHLibreAccessWebServiceDescription]];
		
		//[provider release], provider = nil;
		[[BWKBookManager sharedBookManager] checkInXPSProviderForBookWithPath:xpsPath];
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
