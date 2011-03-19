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
#import "SCHLocalDebugXPSReader.h"
#import "NSNumber+ObjectTypes.h"
#import "SCHBookManager.h"
#import "SCHProfileItem+Extensions.h"
#import "SCHUserContentItem+Extensions.h"
#import "SCHContentProfileItem+Extensions.h"
#import "SCHOrderItem+Extensions.h"
#import "SCHListProfileContentAnnotations+Extensions.h"
#import "SCHBookshelfSyncComponent.h"

@interface SCHLocalDebug ()

- (void)checkAndCopyLocalFilesToApplicationSupport;
- (void)clearProfiles;
- (void)clearUserContentItems;
- (void)clearBooks;
- (void)clearUserSettings;
- (void)clearProfileContentAnnotations;
- (id)makeNullNil:(id)object;

@end

@implementation SCHLocalDebug

@synthesize managedObjectContext;

- (void)dealloc
{
	self.managedObjectContext = nil;
	
	[super dealloc];
}

- (void)setup
{
	static BOOL runOnce = NO;
	
	if (runOnce == NO) {
		runOnce = YES;
		NSError *error = nil;
		NSArray *xpsFiles = nil;
		
		[self checkAndCopyLocalFilesToApplicationSupport];
		
		//	NSString *bundleRoot = [[NSBundle mainBundle] bundlePath];
		
		NSArray  *applicationSupportPaths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
		NSString *applicationSupportPath = ([applicationSupportPaths count] > 0) ? [applicationSupportPaths objectAtIndex:0] : nil;
		
		NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:applicationSupportPath error:&error];
		
		if (error) {
			NSLog(@"Error: %@", [error localizedDescription]);
		}
		
		NSArray *xpsContents = [dirContents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.xps'"]];
		
		NSMutableArray *trimmedXpsContents = [[NSMutableArray alloc] init];
		for (NSString *item in xpsContents) {
			[trimmedXpsContents addObject:[item stringByDeletingPathExtension]];
		}
		
		xpsFiles = [NSArray arrayWithArray:trimmedXpsContents];
		[trimmedXpsContents release];
		
		[self setupLocalDataWithXPSFiles:xpsFiles];		
	}
}

- (void)checkAndCopyLocalFilesToApplicationSupport
{
	// first, check the application support directory exists, and if
	// not, create it. (code from Blio)
	NSArray  *applicationSupportPaths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *applicationSupportPath = ([applicationSupportPaths count] > 0) ? [applicationSupportPaths objectAtIndex:0] : nil;
	
	BOOL isDir;
	if (![[NSFileManager defaultManager] fileExistsAtPath:applicationSupportPath isDirectory:&isDir] || !isDir) {
		NSError * createApplicationSupportDirError = nil;
		
		if (![[NSFileManager defaultManager] createDirectoryAtPath:applicationSupportPath 
									   withIntermediateDirectories:YES 
														attributes:nil 
															 error:&createApplicationSupportDirError]) 
		{
			NSLog(@"Error: could not create Application Support directory in the Library directory! %@, %@", 
				  createApplicationSupportDirError, [createApplicationSupportDirError userInfo]);
			return;
		} else {
			NSLog(@"Created Application Support directory within Library.");
		}
	}
	
	
	// now create a list of bundle XPS files
	NSError *error = nil;
	NSString *bundleRoot = [[NSBundle mainBundle] bundlePath];
	NSArray *bundleDirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:bundleRoot error:&error];
	
	if (error) {
		NSLog(@"Error: %@", [error localizedDescription]);
		return;
	}
	
	NSArray *bundleXPSContents = [bundleDirContents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.xps'"]];
	
	NSArray *appDirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:applicationSupportPath error:&error];
	if (error) {
		NSLog(@"Error: %@", [error localizedDescription]);
		return;
	}
	
	NSArray *supportDirXPSContents = [appDirContents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.xps'"]];
	
	
	for (NSString *item in bundleXPSContents) {
		
		bool fileAlreadyCopied = NO;
		
		for (NSString *appItem in supportDirXPSContents) {
			if ([[item stringByDeletingPathExtension] compare:[appItem stringByDeletingPathExtension]] == NSOrderedSame) {
				fileAlreadyCopied = YES;
				break;
			}
		}
		
		if (!fileAlreadyCopied) {
			NSString *fullSourcePath = [NSString stringWithFormat:@"%@/%@", bundleRoot, item];
			NSString *fullDestinationPath = [NSString stringWithFormat:@"%@/%@", applicationSupportPath, item];
			
			[[NSFileManager defaultManager] copyItemAtPath:fullSourcePath toPath:fullDestinationPath error:&error];
			if (error) {
				NSLog(@"File copy error: %@, %@",
					  error, [error userInfo]);
			}
		}
	}
}

- (void)setupLocalDataWithXPSFiles:(NSArray *)XPSFiles
{
	NSError *error = nil;
	NSDate *now = [NSDate date];
	
	[self clearProfiles];
	[self clearUserContentItems];
	[self clearBooks];
	[self clearUserSettings];
	[self clearProfileContentAnnotations];
	
	SCHProfileItem *newProfileItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHProfileItem inManagedObjectContext:self.managedObjectContext];
	
	newProfileItem.LastModified = now;
	
	newProfileItem.StoryInteractionEnabled = [NSNumber numberWithBool:YES];
	newProfileItem.ID = [NSNumber numberWithInt:1];
	newProfileItem.Birthday = now;
	newProfileItem.FirstName = @"John";
	newProfileItem.ProfilePasswordRequired = [NSNumber numberWithBool:NO];
	newProfileItem.Type = [NSNumber numberWithProfileType:kSCHProfileTypesCHILD];
	newProfileItem.ScreenName = @"Default";
	newProfileItem.AutoAssignContentToProfiles = [NSNumber numberWithBool:YES];
	newProfileItem.LastScreenNameModified = now;
	newProfileItem.BookshelfStyle = [NSNumber numberWithBookshelfStyle:kSCHBookshelfStyleAdult];
	newProfileItem.LastName = @"Doe";
	newProfileItem.LastModified = now;
	
	SCHContentMetadataItem *newContentMetadataItem = nil;
	SCHAppBook *newAppBookItem = nil;
	SCHUserContentItem *newUserContentItem = nil;
	SCHContentProfileItem *newContentProfileItem = nil;
	
	for (NSString *xpsFile in XPSFiles) {
		newContentMetadataItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHContentMetadataItem inManagedObjectContext:self.managedObjectContext];
		newAppBookItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHAppBook inManagedObjectContext:self.managedObjectContext];
		
		newContentMetadataItem.AppBook = newAppBookItem;
		newAppBookItem.ContentMetadataItem = newContentMetadataItem;
		
		NSString *currentPath = [[NSBundle mainBundle] pathForResource:xpsFile ofType:@"xps"];
		
		SCHLocalDebugXPSReader *provider = [[SCHLocalDebugXPSReader alloc] initWithPath:currentPath];
		
		//	newContentMetadataItem.DRMQualifier = provider.author;
		if (provider.ISBN != nil && [[provider.ISBN stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
			newContentMetadataItem.ContentIdentifierType = [NSNumber numberWithContentIdentifierType:kSCHContentItemContentIdentifierTypesISBN13];
		} else {
			newContentMetadataItem.ContentIdentifierType = [NSNumber numberWithContentIdentifierType:kSCHContentIdentifierTypesNone];			
		}
		newContentMetadataItem.ContentIdentifier = provider.ISBN;

		newContentMetadataItem.Author = provider.author;
		//	newContentMetadataItem.Version = [self makeNullNil:[book objectForKey:kSCHLibreAccessWebServiceVersion]];
		//newContentMetadataItem.Enhanced = [self makeNullNil:[book objectForKey:kSCHLibreAccessWebServiceEnhanced]];
		newContentMetadataItem.FileSize = [NSNumber numberWithLongLong:provider.fileSize];
		//	newContentMetadataItem.CoverURL = [self makeNullNil:[book objectForKey:kSCHLibreAccessWebServiceCoverURL]];
		//	newContentMetadataItem.ContentURL = [self makeNullNil:[book objectForKey:kSCHLibreAccessWebServiceContentURL]];
		newContentMetadataItem.PageNumber = [NSNumber numberWithInteger:provider.pageCount];
		newContentMetadataItem.Title = provider.title;
		newContentMetadataItem.FileName = xpsFile;		
		//	newContentMetadataItem.Description = [self makeNullNil:[book objectForKey:kSCHLibreAccessWebServiceDescription]];
		
		[provider release];
		
		newUserContentItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHUserContentItem inManagedObjectContext:self.managedObjectContext];
		
		newUserContentItem.LastModified = now;
		
		newUserContentItem.ContentIdentifier = newContentMetadataItem.ContentIdentifier;
		newUserContentItem.ContentIdentifierType = newContentMetadataItem.ContentIdentifierType;
		
		newContentProfileItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHContentProfileItem inManagedObjectContext:self.managedObjectContext];			
		
		newContentProfileItem.LastModified = now;
		
		newContentProfileItem.IsFavorite = [NSNumber numberWithBool:YES];
		newContentProfileItem.ProfileID = [NSNumber numberWithInt:1];
		
		[newUserContentItem addProfileListObject:newContentProfileItem];	
        
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Error saving managed object context: %@ : %@", error, [error userInfo]); 
        }
		
		SCHBookInfo *bookInfo = [SCHBookManager bookInfoWithBookIdentifier:newUserContentItem.ContentIdentifier];
		[bookInfo setProcessingState:SCHBookInfoProcessingStateNoCoverImage];
								 
	}

	// Save the context.
	if (![self.managedObjectContext save:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}	
	
	// fire off processing
	[[NSNotificationCenter defaultCenter] postNotificationName:kSCHBookshelfSyncComponentComplete object:self];
	
}



- (void)clearProfiles
{
	NSError *error = nil;
	
	if (![self.managedObjectContext emptyEntity:@"SCHProfileItem" error:&error]) {
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

- (void)clearProfileContentAnnotations
{
	NSError *error = nil;
	
	if (![self.managedObjectContext emptyEntity:kSCHListProfileContentAnnotations error:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}	
}
- (id)makeNullNil:(id)object
{
	return(object == [NSNull null] ? nil : object);
}

@end
