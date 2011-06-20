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
#import "SCHLocalDebugXPSReader.h"
#import "NSNumber+ObjectTypes.h"
#import "SCHBookManager.h"
#import "SCHProfileItem.h"
#import "SCHUserContentItem.h"
#import "SCHContentProfileItem.h"
#import "SCHOrderItem.h"
#import "SCHBookshelfSyncComponent.h"
#import "SCHAppBook.h"
#import "SCHAppProfile.h"
#import "SCHAnnotationsItem.h"
#import "SCHLastPage.h"
#import "SCHPrivateAnnotations.h"
#import "SCHAnnotationsContentItem.h"

@interface SCHLocalDebug ()

- (void)checkAndCopyLocalFilesToApplicationSupport:(NSString*)srcDir 
                                         deleteSrc:(BOOL)delete;
- (void)addAnnotationStructure:(SCHUserContentItem *)userContentItem 
               annotationsItem:(SCHAnnotationsItem *)annotationsItem;
- (void)clearProfiles;
- (void)clearUserContentItems;
- (void)clearBooks;
- (void)clearUserSettings;
- (void)clearAnnotations;
- (id)makeNullNil:(id)object;

@end

@implementation SCHLocalDebug

@synthesize managedObjectContext;

- (void)dealloc
{
	self.managedObjectContext = nil;
	
	[super dealloc];
}

- (void)checkImports 
{
    NSArray *xpsFiles = nil;
    NSError *error = nil;
    NSArray * importPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* importPath = ([importPaths count] > 0) ? [importPaths objectAtIndex:0] : nil;
    NSArray *importContents = (NSArray *)[[NSFileManager defaultManager] contentsOfDirectoryAtPath:importPath error:&error];
    
    NSMutableArray *xpsContents = [[NSMutableArray alloc] init];
    for (NSString *item in [importContents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.xps'"]]) {
        [xpsContents addObject:item];
    }
    xpsFiles = [NSArray arrayWithArray:xpsContents];
    [xpsContents release];
    
    if ( [xpsFiles count] == 0 ) {
        NSLog(@"No files to import.");
        return;
    }
    
    [self checkAndCopyLocalFilesToApplicationSupport:importPath deleteSrc:YES];
    
    NSDate *now = [NSDate date];
    SCHContentMetadataItem *newContentMetadataItem = nil;
	SCHUserContentItem *newUserContentItem = nil;
	SCHContentProfileItem *newContentProfileItem = nil;
    NSMutableArray *importedBooks = [NSMutableArray array];
    
    NSArray  *applicationSupportPaths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *applicationSupportPath = ([applicationSupportPaths count] > 0) ? [applicationSupportPaths objectAtIndex:0] : nil;
    if ( applicationSupportPath == nil ) {
        NSLog(@"Error importing book: application support directory doesn't exist.");
        return;
    }
	for (NSInteger count = 0; count < [xpsFiles count]; count++) {
        NSString *xpsFile = [xpsFiles objectAtIndex:count];
        
		newContentMetadataItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHContentMetadataItem inManagedObjectContext:self.managedObjectContext];
		newContentMetadataItem.AppBook = [NSEntityDescription insertNewObjectForEntityForName:kSCHAppBook inManagedObjectContext:self.managedObjectContext];
        
        NSString *currentPath = [[applicationSupportPath stringByAppendingString:@"/"] stringByAppendingString:xpsFile];
        xpsFile = [xpsFile stringByDeletingPathExtension];
		
		SCHLocalDebugXPSReader *provider = [[SCHLocalDebugXPSReader alloc] initWithPath:currentPath];
		
		if (provider.ISBN != nil && [[provider.ISBN stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
			newContentMetadataItem.ContentIdentifierType = [NSNumber numberWithContentIdentifierType:kSCHContentItemContentIdentifierTypesISBN13];
		} else {
			newContentMetadataItem.ContentIdentifierType = [NSNumber numberWithContentIdentifierType:kSCHContentIdentifierTypesNone];			
		}
		newContentMetadataItem.ContentIdentifier = provider.ISBN;
        [importedBooks addObject:provider.ISBN];
        
		newContentMetadataItem.Author = provider.author;
		newContentMetadataItem.FileSize = [NSNumber numberWithLongLong:provider.fileSize];
		newContentMetadataItem.PageNumber = [NSNumber numberWithInteger:provider.pageCount];
		newContentMetadataItem.Title = provider.title;
		newContentMetadataItem.FileName = xpsFile;		
		
		[provider release];
  
        // Add the book to the all books (Jimmy's) profile
        newUserContentItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHUserContentItem inManagedObjectContext:self.managedObjectContext];
		
		newUserContentItem.LastModified = now;
		
		newUserContentItem.ContentIdentifier = newContentMetadataItem.ContentIdentifier;
		newUserContentItem.ContentIdentifierType = newContentMetadataItem.ContentIdentifierType;
        
        newContentProfileItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHContentProfileItem inManagedObjectContext:self.managedObjectContext];			
		
		newContentProfileItem.LastModified = now;
		newContentProfileItem.IsFavorite = [NSNumber numberWithBool:YES];
        newContentProfileItem.ProfileID = [NSNumber numberWithInt:3];
		
		[newUserContentItem addProfileListObject:newContentProfileItem];	
        
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Error saving managed object context: %@ : %@", error, [error userInfo]); 
        }
       
        [[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:newUserContentItem.ContentIdentifier state:SCHBookProcessingStateNoCoverImage];
		
	}
    
	// Save the context.
	if (![self.managedObjectContext save:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}	
    
	[[NSNotificationCenter defaultCenter] postNotificationName:kSCHBookshelfSyncComponentComplete object:self];
    
}

- (void)setup
{
	static BOOL runOnce = NO;
	
	if (runOnce == NO) {
		runOnce = YES;
		NSError *error = nil;
		NSArray *xpsFiles = nil;
		
        [self checkAndCopyLocalFilesToApplicationSupport:[[NSBundle mainBundle] bundlePath] deleteSrc:NO];
		
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


- (void)checkAndCopyLocalFilesToApplicationSupport:(NSString*)srcDir deleteSrc:(BOOL)delete
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
    NSArray *srcDirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:srcDir error:&error];
	
	if (error) {
		NSLog(@"Error: %@", [error localizedDescription]);
		return;
	}
	
    NSArray *srcXPSContents = [srcDirContents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.xps'"]];
	
	NSArray *appDirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:applicationSupportPath error:&error];
	if (error) {
		NSLog(@"Error: %@", [error localizedDescription]);
		return;
	}
	
	NSArray *supportDirXPSContents = [appDirContents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.xps'"]];
	
	for (NSString *item in srcXPSContents) {
		
		bool fileAlreadyCopied = NO;
		
		for (NSString *appItem in supportDirXPSContents) {
			if ([[item stringByDeletingPathExtension] compare:[appItem stringByDeletingPathExtension]] == NSOrderedSame) {
				fileAlreadyCopied = YES;
				break;
			}
		}
		
		if (!fileAlreadyCopied) {
            NSString *fullSourcePath = [NSString stringWithFormat:@"%@/%@", srcDir, item];
			NSString *fullDestinationPath = [NSString stringWithFormat:@"%@/%@", applicationSupportPath, item];
			
			[[NSFileManager defaultManager] copyItemAtPath:fullSourcePath toPath:fullDestinationPath error:&error];
			if (error) {
				NSLog(@"File copy error: %@, %@",
					  error, [error userInfo]);
			}
            
            if (delete) {
                if (![[NSFileManager defaultManager] removeItemAtPath:fullSourcePath error:&error]) {
                    NSLog(@"Failed to delete file to import %@ in the Documents Directory with error: %@", 
                          item, [error localizedDescription]);
                }
                else 
                    NSLog(@"Successfully deleted file to import %@ in the Documents Directory.",item);
            }
		}
	}
        
}

- (void)setupLocalDataWithXPSFiles:(NSArray *)XPSFiles
{
	NSError *error = nil;
	NSDate *now = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    
	[self clearProfiles];
	[self clearUserContentItems];
	[self clearBooks];
	[self clearUserSettings];
	[self clearAnnotations];
	
	SCHProfileItem *youngProfileItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHProfileItem inManagedObjectContext:self.managedObjectContext];
	
	youngProfileItem.LastModified = now;
	
	youngProfileItem.StoryInteractionEnabled = [NSNumber numberWithBool:YES];
	youngProfileItem.ID = [NSNumber numberWithInt:1];
    dateComponents.year = -5;
	youngProfileItem.Birthday = [gregorian dateByAddingComponents:dateComponents toDate:[NSDate date] options:0];
	youngProfileItem.FirstName = @"Joe";
	youngProfileItem.ProfilePasswordRequired = [NSNumber numberWithBool:NO];
	youngProfileItem.Type = [NSNumber numberWithProfileType:kSCHProfileTypesCHILD];
	youngProfileItem.ScreenName = @"Young Child";
	youngProfileItem.AutoAssignContentToProfiles = [NSNumber numberWithBool:YES];
	youngProfileItem.LastScreenNameModified = now;
	youngProfileItem.BookshelfStyle = [NSNumber numberWithBookshelfStyle:kSCHBookshelfStyleYoungChild];
	youngProfileItem.LastName = @"Doe";
	youngProfileItem.LastModified = now;
    youngProfileItem.AppProfile = [NSEntityDescription insertNewObjectForEntityForName:kSCHAppProfile inManagedObjectContext:self.managedObjectContext];
    
    SCHAnnotationsItem *youngAnnotationsItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHAnnotationsItem inManagedObjectContext:self.managedObjectContext];
    youngAnnotationsItem.ProfileID = youngProfileItem.ID;    
    
	SCHProfileItem *olderProfileItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHProfileItem inManagedObjectContext:self.managedObjectContext];
	
	olderProfileItem.LastModified = now;
	
	olderProfileItem.StoryInteractionEnabled = [NSNumber numberWithBool:YES];
	olderProfileItem.ID = [NSNumber numberWithInt:2];
    dateComponents.year = -14;
	olderProfileItem.Birthday = [gregorian dateByAddingComponents:dateComponents toDate:[NSDate date] options:0];
	olderProfileItem.FirstName = @"John";
	olderProfileItem.ProfilePasswordRequired = [NSNumber numberWithBool:NO];
	olderProfileItem.Type = [NSNumber numberWithProfileType:kSCHProfileTypesCHILD];
	olderProfileItem.ScreenName = @"Older Child";
	olderProfileItem.AutoAssignContentToProfiles = [NSNumber numberWithBool:YES];
	olderProfileItem.LastScreenNameModified = now;
	olderProfileItem.BookshelfStyle = [NSNumber numberWithBookshelfStyle:kSCHBookshelfStyleOlderChild];
	olderProfileItem.LastName = @"Doe";
	olderProfileItem.LastModified = now;
    olderProfileItem.AppProfile = [NSEntityDescription insertNewObjectForEntityForName:kSCHAppProfile inManagedObjectContext:self.managedObjectContext];
    
    SCHAnnotationsItem *olderAnnotationsItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHAnnotationsItem inManagedObjectContext:self.managedObjectContext];
    olderAnnotationsItem.ProfileID = olderProfileItem.ID;    
    
	SCHProfileItem *allBooksProfileItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHProfileItem inManagedObjectContext:self.managedObjectContext];
	
	allBooksProfileItem.LastModified = now;
	
	allBooksProfileItem.StoryInteractionEnabled = [NSNumber numberWithBool:YES];
	allBooksProfileItem.ID = [NSNumber numberWithInt:3];
    dateComponents.year = -8;
	allBooksProfileItem.Birthday = [gregorian dateByAddingComponents:dateComponents toDate:[NSDate date] options:0];
	allBooksProfileItem.FirstName = @"Jimmy";
	allBooksProfileItem.ProfilePasswordRequired = [NSNumber numberWithBool:NO];
	allBooksProfileItem.Type = [NSNumber numberWithProfileType:kSCHProfileTypesCHILD];
	allBooksProfileItem.ScreenName = @"FullProfile";
	allBooksProfileItem.AutoAssignContentToProfiles = [NSNumber numberWithBool:YES];
	allBooksProfileItem.LastScreenNameModified = now;
	allBooksProfileItem.BookshelfStyle = [NSNumber numberWithBookshelfStyle:kSCHBookshelfStyleOlderChild];
	allBooksProfileItem.LastName = @"Smith";
	allBooksProfileItem.LastModified = now;    
    allBooksProfileItem.AppProfile = [NSEntityDescription insertNewObjectForEntityForName:kSCHAppProfile inManagedObjectContext:self.managedObjectContext];
    
    SCHAnnotationsItem *allBooksAnnotationsItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHAnnotationsItem inManagedObjectContext:self.managedObjectContext];
    allBooksAnnotationsItem.ProfileID = allBooksProfileItem.ID;    
    
	SCHContentMetadataItem *newContentMetadataItem = nil;
	SCHUserContentItem *newUserContentItem = nil;
	SCHContentProfileItem *newContentProfileItem = nil;
    SCHOrderItem *newOrderItem = nil; 
    NSInteger orderID = 1;

	for (NSInteger count = 0; count < [XPSFiles count]; count++) {
        NSString *xpsFile = [XPSFiles objectAtIndex:count];
        
		newContentMetadataItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHContentMetadataItem inManagedObjectContext:self.managedObjectContext];
		newContentMetadataItem.AppBook = [NSEntityDescription insertNewObjectForEntityForName:kSCHAppBook inManagedObjectContext:self.managedObjectContext];
				
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
        
        if ([newContentMetadataItem.FileName isEqualToString:@"OlliesNewTricks"] ||
            [newContentMetadataItem.FileName isEqualToString:@"WhoWillCarveTurkey"]) {
            newContentProfileItem.ProfileID = [NSNumber numberWithInt:1];
            [self addAnnotationStructure:newUserContentItem annotationsItem:youngAnnotationsItem];
        } else {
            newContentProfileItem.ProfileID = [NSNumber numberWithInt:2];
            [self addAnnotationStructure:newUserContentItem annotationsItem:olderAnnotationsItem];            
        }
		
		[newUserContentItem addProfileListObject:newContentProfileItem];	

        // Add the book to an all books profile
        newContentProfileItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHContentProfileItem inManagedObjectContext:self.managedObjectContext];			
		
		newContentProfileItem.LastModified = now;
		newContentProfileItem.IsFavorite = [NSNumber numberWithBool:YES];
        newContentProfileItem.ProfileID = [NSNumber numberWithInt:3];
        [self addAnnotationStructure:newUserContentItem annotationsItem:allBooksAnnotationsItem];            
		
		[newUserContentItem addProfileListObject:newContentProfileItem];	
        
        newOrderItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHOrderItem inManagedObjectContext:self.managedObjectContext];
        newOrderItem.OrderID = [[NSNumber numberWithInteger:orderID++] stringValue];
        newOrderItem.OrderDate = [NSDate dateWithTimeIntervalSinceNow:orderID * 60];
        [newUserContentItem addOrderListObject:newOrderItem];	
        
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Error saving managed object context: %@ : %@", error, [error userInfo]); 
        }
//		SCHBookInfo *bookInfo = [SCHBookManager bookInfoWithBookIdentifier:newUserContentItem.ContentIdentifier];
//		[bookInfo setProcessingState:SCHBookProcessingStateNoCoverImage];
        
        [[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:newUserContentItem.ContentIdentifier state:SCHBookProcessingStateNoCoverImage];
		
	}

	// Save the context.
	if (![self.managedObjectContext save:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}	
	
    [dateComponents release], dateComponents = nil;
    [gregorian release], gregorian = nil;
     
	// fire off processing
	[[NSNotificationCenter defaultCenter] postNotificationName:kSCHBookshelfSyncComponentComplete object:self];
	
}

- (void)addAnnotationStructure:(SCHUserContentItem *)userContentItem annotationsItem:(SCHAnnotationsItem *)annotationsItem
{
    if (annotationsItem != nil && userContentItem != nil) {
        NSDate *date = [NSDate date];
                
        SCHLastPage *newLastPage = [NSEntityDescription insertNewObjectForEntityForName:kSCHLastPage 
                                                                 inManagedObjectContext:self.managedObjectContext];
        newLastPage.LastModified = date;
        newLastPage.State = [NSNumber numberWithStatus:kSCHStatusCreated];
        newLastPage.LastPageLocation = [NSNumber numberWithInteger:1];
        newLastPage.Percentage = [NSNumber numberWithFloat:0.0];
        newLastPage.Component = @"";
        
        SCHPrivateAnnotations *newPrivateAnnotations = [NSEntityDescription insertNewObjectForEntityForName:kSCHPrivateAnnotations 
                                                                                     inManagedObjectContext:self.managedObjectContext];
        newPrivateAnnotations.LastPage = newLastPage;
        
        SCHAnnotationsContentItem *newAnnotationsContentItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHAnnotationsContentItem 
                                                                                             inManagedObjectContext:self.managedObjectContext];
        newAnnotationsContentItem.AnnotationsItem = annotationsItem;
        newAnnotationsContentItem.DRMQualifier = userContentItem.DRMQualifier;
        newAnnotationsContentItem.ContentIdentifier = userContentItem.ContentIdentifier;
        newAnnotationsContentItem.Format = userContentItem.Format;
        newAnnotationsContentItem.ContentIdentifierType = userContentItem.ContentIdentifierType;
        newAnnotationsContentItem.PrivateAnnotations = newPrivateAnnotations;
    }
}

- (void)clearProfiles
{
	NSError *error = nil;
	
	if (![self.managedObjectContext BITemptyEntity:@"SCHProfileItem" error:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}		
}

- (void)clearUserContentItems
{
	NSError *error = nil;
	
	if (![self.managedObjectContext BITemptyEntity:kSCHUserContentItem error:&error] ||
		![self.managedObjectContext BITemptyEntity:kSCHOrderItem error:&error] ||
		![self.managedObjectContext BITemptyEntity:kSCHContentProfileItem error:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}		
}

- (void)clearBooks
{
	NSError *error = nil;
	
	if (![self.managedObjectContext BITemptyEntity:@"SCHContentMetadataItem" error:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}	
}

- (void)clearUserSettings
{
	NSError *error = nil;
	
	if (![self.managedObjectContext BITemptyEntity:@"SCHUserSettingsItem" error:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}	
}

- (void)clearAnnotations
{
	NSError *error = nil;
	
	if (![self.managedObjectContext BITemptyEntity:kSCHAnnotationsItem error:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}	
}
- (id)makeNullNil:(id)object
{
	return(object == [NSNull null] ? nil : object);
}

@end
