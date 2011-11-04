//
//  SCHAnnotationSyncComponent.m
//  Scholastic
//
//  Created by John S. Eddie on 04/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHAnnotationSyncComponent.h"
#import "SCHSyncComponentProtected.h"

#import "NSManagedObjectContext+Extensions.h"

#import "SCHAnnotationsItem.h"
#import "SCHAnnotationsContentItem.h"
#import "SCHPrivateAnnotations.h"
#import "SCHHighlight.h"
#import "SCHLocationText.h"
#import "SCHWordIndex.h"
#import "SCHNote.h"
#import "SCHLocationGraphics.h"
#import "SCHBookmark.h"
#import "SCHLocationBookmark.h"
#import "SCHLastPage.h"
#import "SCHAppStateManager.h"
#import "SCHProfileItem.h"
#import "SCHAppContentProfileItem.h"
#import "SCHBookIdentifier.h"
#import "BITAPIError.h"

// Constants
NSString * const SCHAnnotationSyncComponentDidCompleteNotification = @"SCHAnnotationSyncComponentDidCompleteNotification";
NSString * const SCHAnnotationSyncComponentDidFailNotification = @"SCHAnnotationSyncComponentDidFailNotification";
NSString * const SCHAnnotationSyncComponentCompletedProfileIDs = @"SCHAnnotationSyncComponentCompletedProfileIDs";

@interface SCHAnnotationSyncComponent ()

- (NSNumber *)currentProfile;
- (BOOL)updateProfileContentAnnotations;
- (void)processSaveProfileContentAnnotations:(NSNumber *)profileID 
                                      result:(NSDictionary *)result;
- (void)trackAnnotationSaves:(NSSet *)annotationsArray;
- (void)applyAnnotationSaves:(NSArray *)annotationsArray;
- (NSArray *)localModifiedAnnotationsItemForProfile:(NSNumber *)profileID;
- (NSArray *)localAnnotationsItemForProfile:(NSNumber *)profileID;
- (void)syncProfileContentAnnotations:(NSDictionary *)profileContentAnnotationList;
- (void)syncProfileContentAnnotationsCompleted:(NSNumber *)profileID 
                                   usingMethod:(NSString *)method;
- (void)syncAnnotationsContentList:(NSArray *)webAnnotationsContentList 
         withAnnotationContentList:(NSArray *)localAnnotationsContentList
                        insertInto:(SCHAnnotationsItem *)annotationsItem;
- (void)syncAnnotationsContentItem:(NSDictionary *)webAnnotationsContentItem 
        withAnnotationsContentItem:(SCHAnnotationsContentItem *)localAnnotationsContentItem;
- (SCHAnnotationsContentItem *)annotationsContentItem:(NSDictionary *)annotationsContentItem;
- (SCHPrivateAnnotations *)privateAnnotation:(NSDictionary *)privateAnnotation;
- (void)syncHighlights:(NSArray *)webHighlights
        withHighlights:(NSSet *)localHighlights
            insertInto:(SCHPrivateAnnotations *)privateAnnotations;
- (void)syncHighlight:(NSDictionary *)webHighlight
        withHighlight:(SCHHighlight *)localHighlight;
- (SCHHighlight *)highlight:(NSDictionary *)highlight;
- (void)syncLocationText:(NSDictionary *)webLocationText
        withLocationText:(SCHLocationText *)localLocationText;
- (SCHLocationText *)locationText:(NSDictionary *)locationText;
- (void)syncWordIndex:(NSDictionary *)websyncWordIndex
        withWordIndex:(SCHWordIndex *)localsyncWordIndex;
- (SCHWordIndex *)wordIndex:(NSDictionary *)wordIndex;
- (void)syncNotes:(NSArray *)webNotes
        withNotes:(NSSet *)localNotes
       insertInto:(SCHPrivateAnnotations *)privateAnnotations;
- (void)syncNote:(NSDictionary *)webNote
        withNote:(SCHNote *)localNote;
- (SCHNote *)note:(NSDictionary *)note;
- (void)syncLocationGraphics:(NSDictionary *)webLocationGraphics 
        withLocationGraphics:(SCHLocationGraphics *)localLocationGraphics;
- (SCHLocationGraphics *)locationGraphics:(NSDictionary *)locationGraphics;
- (void)syncBookmarks:(NSArray *)webBookmarks
        withBookmarks:(NSSet *)localBookmarks
           insertInto:(SCHPrivateAnnotations *)privateAnnotations;
- (void)syncBookmark:(NSDictionary *)webBookmark 
        withBookmark:(SCHBookmark *)localBookmark;
- (SCHBookmark *)bookmark:(NSDictionary *)bookmark;
- (void)syncLocationBookmark:(NSDictionary *)webLocationBookmark 
        withLocationBookmark:(SCHLocationBookmark *)localLocationBookmark;
- (SCHLocationBookmark *)locationBookmark:(NSDictionary *)locationBookmark;
- (void)syncLastPage:(NSDictionary *)webLastPage 
        withLastPage:(SCHLastPage *)localLastPage;
- (SCHLastPage *)lastPage:(NSDictionary *)lastPage;
- (void)backgroundSave:(BOOL)batch;

@property (retain, nonatomic) NSMutableDictionary *annotations;
@property (retain, nonatomic) NSMutableArray *savedAnnotations;
@property (nonatomic, retain) NSManagedObjectContext *backgroundThreadManagedObjectContext;

@end

@implementation SCHAnnotationSyncComponent

@synthesize annotations;
@synthesize savedAnnotations;
@synthesize backgroundThreadManagedObjectContext;

- (id)init
{
	self = [super init];
	if (self != nil) {
		annotations = [[NSMutableDictionary dictionary] retain];
		savedAnnotations = [[NSMutableArray array] retain];
	}
	
	return(self);
}

- (void)dealloc
{
	[annotations release], annotations = nil;
    [savedAnnotations release], savedAnnotations = nil;
	[backgroundThreadManagedObjectContext release], backgroundThreadManagedObjectContext = nil;
    
	[super dealloc];
}

- (void)addProfile:(NSNumber *)profileID withBooks:(NSArray *)books
{
	if (profileID != nil && books != nil && [books count] > 0) {
        NSMutableArray *profileBooks = [self.annotations objectForKey:profileID]; 
        if (profileBooks != nil) {
            // Only add books that do not already exist
            for (NSDictionary *book in books) {
                SCHBookIdentifier *bookIdentifier = [[SCHBookIdentifier alloc] initWithObject:book];
                __block BOOL bookAlreadyExists = NO;
                [profileBooks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    SCHBookIdentifier *profileBookIdentifier = [[SCHBookIdentifier alloc] initWithObject:obj];
                    if ([bookIdentifier isEqual:profileBookIdentifier] == YES) {
                        bookAlreadyExists = YES;
                        *stop = YES;
                    }
                    [profileBookIdentifier release], profileBookIdentifier = nil;                    
                }];
                [bookIdentifier release], bookIdentifier = nil;
                
                if (bookAlreadyExists == NO) {
                    [profileBooks addObject:book];
                }
            }
        } else {
            [self.annotations setObject:[NSMutableArray arrayWithArray:books] forKey:profileID];		
        }
	}
}

- (BOOL)haveProfiles
{
	return([self.annotations count ] > 0);
}

- (NSNumber *)currentProfile
{
    NSNumber *ret = nil;
    
    if ([self haveProfiles] == YES) {
        ret = [[[self.annotations allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:0];    
    }
    
    return ret;
}

- (BOOL)nextProfile
{
    NSNumber *currentProfile = [self currentProfile];
   
    if (currentProfile != nil) {
        [self.annotations removeObjectForKey:currentProfile];    
    }
    [self clearFailures];
    
    return [self haveProfiles];
}

- (BOOL)synchronize
{
	BOOL ret = YES;
	
	if (self.isSynchronizing == NO) {
		self.backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{ 
			self.isSynchronizing = NO;
			self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
		}];

		ret = [self updateProfileContentAnnotations];
	}
	
	return(ret);
}

- (void)clear
{
    [super clear];
	NSError *error = nil;
	
    [self.annotations removeAllObjects];
    [self.savedAnnotations removeAllObjects];
    
	if (![self.managedObjectContext BITemptyEntity:kSCHAnnotationsItem error:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}	
}

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result
{
    NSNumber *profileID = [self currentProfile];
    
    @try {
        if([method compare:kSCHLibreAccessWebServiceSaveProfileContentAnnotations] == NSOrderedSame) {
            [self processSaveProfileContentAnnotations:profileID result:result];
        } else if([method compare:kSCHLibreAccessWebServiceListProfileContentAnnotations] == NSOrderedSame) {	    
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                self.backgroundThreadManagedObjectContext = [[[NSManagedObjectContext alloc] init] autorelease];
                [self.backgroundThreadManagedObjectContext setPersistentStoreCoordinator:self.managedObjectContext.persistentStoreCoordinator];
                
                [self syncProfileContentAnnotations:[result objectForKey:kSCHLibreAccessWebServiceListProfileContentAnnotations]];	            
                
                self.backgroundThreadManagedObjectContext = nil;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self syncProfileContentAnnotationsCompleted:profileID usingMethod:method];
                });                
            });
        }
    }
    @catch (NSException *exception) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SCHAnnotationSyncComponentDidFailNotification 
                                                            object:self 
                                                          userInfo:[NSDictionary dictionaryWithObject:profileID 
                                                                                               forKey:SCHAnnotationSyncComponentCompletedProfileIDs]];            
        NSError *error = [NSError errorWithDomain:kBITAPIErrorDomain 
                                             code:kBITAPIExceptionError 
                                         userInfo:[NSDictionary dictionaryWithObject:[exception reason]
                                                                              forKey:NSLocalizedDescriptionKey]];
        [super method:method didFailWithError:error requestInfo:nil result:result];
        [self.savedAnnotations removeAllObjects];
    }    
}

- (void)processSaveProfileContentAnnotations:(NSNumber *)profileID 
                                      result:(NSDictionary *)result
{
    NSArray *books = [self.annotations objectForKey:profileID];
    BOOL shouldSyncNotes = NO;
    
    if (result != nil && [self.savedAnnotations count] > 0) {
        shouldSyncNotes = [[SCHAppStateManager sharedAppStateManager] canSyncNotes];
        for (NSDictionary *annotationStatusItem in [result objectForKey:kSCHLibreAccessWebServiceAnnotationStatusList]) {
            if ([[annotationStatusItem objectForKey:kSCHLibreAccessWebServiceProfileID] isEqualToNumber:profileID] == YES) {
                for (NSDictionary *annotationStatusContentItem in [annotationStatusItem objectForKey:kSCHLibreAccessWebServiceAnnotationStatusContentList]) {            
                    NSDictionary *privateAnnotationsStatus = [annotationStatusContentItem objectForKey:kSCHLibreAccessWebServicePrivateAnnotationsStatus];
                    
                    [self applyAnnotationSaves:[privateAnnotationsStatus objectForKey:kSCHLibreAccessWebServiceHighlightsStatusList]];
                    if (shouldSyncNotes == YES) {
                        [self applyAnnotationSaves:[privateAnnotationsStatus objectForKey:kSCHLibreAccessWebServiceNotesStatusList]];
                    }
                    [self applyAnnotationSaves:[privateAnnotationsStatus objectForKey:kSCHLibreAccessWebServiceBookmarksStatusList]];
                }
                break;
            }
        }
    }
    
    self.isSynchronizing = [self.libreAccessWebService listProfileContentAnnotations:books 
                                                                          forProfile:profileID];
    if (self.isSynchronizing == NO) {
        [[SCHAuthenticationManager sharedAuthenticationManager] authenticateWithSuccessBlock:^(BOOL offlineMode){
            if (!offlineMode) {
                [self.delegate authenticationDidSucceed];
            }
        } failureBlock:nil];
    }            
}

// track annotations that need to be saved
- (void)trackAnnotationSaves:(NSSet *)annotationsArray
{
    for (SCHAnnotation *annotation in annotationsArray) {
        if ([annotation.Action saveActionValue] != kSCHSaveActionsNone) {
            [self.savedAnnotations addObject:[annotation objectID]];
        }
    }
}

- (void)applyAnnotationSaves:(NSArray *)annotationsArray
{
    NSManagedObjectID *managedObjectID = nil;
    NSManagedObject *annotationManagedObject = nil;
    
    for (NSDictionary *annotation in annotationsArray) {
        if ([self.savedAnnotations count] > 0) {
            managedObjectID = [self.savedAnnotations objectAtIndex:0];
            if (managedObjectID != nil) {
                annotationManagedObject = [self.managedObjectContext objectWithID:managedObjectID];
                
                if ([[[annotation objectForKey:kSCHLibreAccessWebServiceStatusMessage] 
                      objectForKey:kSCHLibreAccessWebServiceStatus] statusCodeValue] == kSCHStatusCodesSuccess) {
                    switch ([[annotation objectForKey:kSCHLibreAccessWebServiceStatus] saveActionValue]) {
                        case kSCHSaveActionsCreate:
                        {
                            NSNumber *annotationID = [self makeNullNil:[annotation objectForKey:kSCHLibreAccessWebServiceID]];
                            if (annotationID != nil) {
                                [annotationManagedObject setValue:annotationID forKey:kSCHLibreAccessWebServiceID];
                            } else {
                                // if the server didnt give us an ID then we remove the annotation
                                [self.managedObjectContext deleteObject:annotationManagedObject];
                            }                                                    
                        }
                            break;
                        case kSCHSaveActionsRemove:                            
                        {
                            [self.managedObjectContext deleteObject:annotationManagedObject];
                        }
                            break;

                        default:
                            //nop
                            break;
                    }
                } else {
                    // if the server wasnt happy then we remove the annotation
                    [self.managedObjectContext deleteObject:annotationManagedObject];
                }
                                
                // We've attempted to save changes, reset to unmodified and now 
                // sync will update this with the truth from the server
                if (annotationManagedObject.isDeleted == NO) {
                    [annotationManagedObject setValue:[NSNumber numberWithStatus:kSCHStatusUnmodified] 
                                               forKey:SCHSyncEntityState];
                }
            }
            [self.savedAnnotations removeObjectAtIndex:0];
        }
        [self save];
    }
}

- (void)method:(NSString *)method didFailWithError:(NSError *)error 
   requestInfo:(NSDictionary *)requestInfo 
        result:(NSDictionary *)result
{
    NSLog(@"%@:didFailWithError\n%@", method, error);
    NSNumber *profileID = [self currentProfile];
    
    // server error so process the result
    if ([error domain] == kBITAPIErrorDomain &&
        [method compare:kSCHLibreAccessWebServiceSaveProfileContentAnnotations] == NSOrderedSame) {	            
        [self processSaveProfileContentAnnotations:profileID result:result];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:SCHAnnotationSyncComponentDidFailNotification 
                                                            object:self 
                                                          userInfo:[NSDictionary dictionaryWithObject:profileID 
                                                                                               forKey:SCHAnnotationSyncComponentCompletedProfileIDs]];            
        [super method:method didFailWithError:error requestInfo:requestInfo result:result];
    }
    [self.savedAnnotations removeAllObjects];
}

- (BOOL)updateProfileContentAnnotations
{
	BOOL ret = YES;
    BOOL shouldSyncNotes = NO;
	
    NSNumber *profileID = [self currentProfile];
    NSArray *books = [self.annotations objectForKey:profileID];
    
	[self.savedAnnotations removeAllObjects];
    NSArray *updatedAnnotations = [self localModifiedAnnotationsItemForProfile:profileID];
    if ([updatedAnnotations count] > 0) {
        shouldSyncNotes = [[SCHAppStateManager sharedAppStateManager] canSyncNotes];
        for (SCHAnnotationsItem *annotionItem in updatedAnnotations) {
            for (SCHAnnotationsContentItem *annotationContentItem in annotionItem.AnnotationsContentItem) {
                [self trackAnnotationSaves:annotationContentItem.PrivateAnnotations.Highlights];
                if (shouldSyncNotes == YES) {
                    [self trackAnnotationSaves:annotationContentItem.PrivateAnnotations.Notes];
                }
                [self trackAnnotationSaves:annotationContentItem.PrivateAnnotations.Bookmarks];
            }
        }
        
        self.isSynchronizing = [self.libreAccessWebService saveProfileContentAnnotations:updatedAnnotations];
        if (self.isSynchronizing == NO) {
            [[SCHAuthenticationManager sharedAuthenticationManager] authenticateWithSuccessBlock:^(BOOL offlineMode){
                if (!offlineMode) {
                    [self.delegate authenticationDidSucceed];
                }
            } failureBlock:nil];				
            ret = NO;
        }
    } else if ([self.annotations count] > 0) {
        self.isSynchronizing = [self.libreAccessWebService listProfileContentAnnotations:books 
                                                                              forProfile:profileID];
        if (self.isSynchronizing == NO) {
            [[SCHAuthenticationManager sharedAuthenticationManager] authenticateWithSuccessBlock:^(BOOL offlineMode){
                if (!offlineMode) {
                    [self.delegate authenticationDidSucceed];
                }
            } failureBlock:nil];				
            ret = NO;
        }
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:SCHAnnotationSyncComponentDidCompleteNotification 
                                                            object:self 
                                                          userInfo:[NSDictionary dictionaryWithObject:profileID 
                                                                                               forKey:SCHAnnotationSyncComponentCompletedProfileIDs]];        
        [self.annotations removeObjectForKey:profileID];
        
        [super method:nil didCompleteWithResult:nil];
    }
	
	return(ret);    
}

- (NSArray *)localModifiedAnnotationsItemForProfile:(NSNumber *)profileID
{	
    NSArray *ret = nil;
	NSError *error = nil;
    
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	[fetchRequest setEntity:[NSEntityDescription entityForName:kSCHAnnotationsItem inManagedObjectContext:self.managedObjectContext]];	
	NSArray *changedStates = [NSArray arrayWithObjects:[NSNumber numberWithStatus:kSCHStatusModified],
                              [NSNumber numberWithStatus:kSCHStatusDeleted], nil];
    // we don't check all the annotations as if they have changed then the last page has also change
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:
                                @"ProfileID == %@ AND ANY AnnotationsContentItem.PrivateAnnotations.LastPage.State IN %@", 
                                profileID, changedStates]];
	    
	ret = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
	[fetchRequest release], fetchRequest = nil;
	
	return(ret);	
}

- (NSArray *)localAnnotationsItemForProfile:(NSNumber *)profileID
{
    NSAssert([NSThread isMainThread] == NO, @"localAnnotationsItemForProfile MUST NOT be executed on the main thread");
    NSEntityDescription *entityDescription = [NSEntityDescription 
                                              entityForName:kSCHAnnotationsItem
                                              inManagedObjectContext:self.backgroundThreadManagedObjectContext];
    
    NSFetchRequest *fetchRequest = [entityDescription.managedObjectModel 
                                    fetchRequestFromTemplateWithName:kSCHAnnotationsItemfetchAnnotationItemForProfile 
                                    substitutionVariables:[NSDictionary 
                                                           dictionaryWithObject:profileID 
                                                           forKey:kSCHAnnotationsItemPROFILE_ID]];
	
	return([self.backgroundThreadManagedObjectContext executeFetchRequest:fetchRequest error:nil]);
}

- (void)syncProfileContentAnnotations:(NSDictionary *)profileContentAnnotationList
{
    NSAssert([NSThread isMainThread] == NO, @"syncProfileContentAnnotations MUST NOT be executed on the main thread");
	NSDictionary *annotationsList = [self makeNullNil:[profileContentAnnotationList 
                                                       objectForKey:kSCHLibreAccessWebServiceAnnotationsList]];
	
    // uncomment if we require to use this info
    //	NSDictionary *itemsCount = [self makeNullNil:[profileContentAnnotationList objectForKey:kSCHLibreAccessWebServiceItemsCount]];	
    //	NSNumber *found = [self makeNullNil:[itemsCount objectForKey:kSCHLibreAccessWebServiceFound]];
    //	NSNumber *returned = [self makeNullNil:[itemsCount objectForKey:kSCHLibreAccessWebServiceReturned]];	
    
    for (NSDictionary *annotationsItem in annotationsList) {
        NSNumber *profileID = [annotationsItem objectForKey:kSCHLibreAccessWebServiceProfileID];
        NSArray *localAnnotationsItems = [self localAnnotationsItemForProfile:profileID];
        
        if ([localAnnotationsItems count] > 0) {
            // sync me baby
            NSArray *annotationsContentList = [self makeNullNil:[annotationsItem objectForKey:kSCHLibreAccessWebServiceAnnotationsContentList]];
            if ([annotationsItem objectForKey:kSCHLibreAccessWebServiceAnnotationsContentList] != nil) {
                [self syncAnnotationsContentList:annotationsContentList
                       withAnnotationContentList:[[localAnnotationsItems objectAtIndex:0] AnnotationsContentItem] 
                                      insertInto:[localAnnotationsItems objectAtIndex:0]];
            }
        } else {
            SCHAnnotationsItem *newAnnotationsItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHAnnotationsItem 
                                                                                   inManagedObjectContext:self.backgroundThreadManagedObjectContext];
            newAnnotationsItem.ProfileID = profileID;
            for (NSDictionary *annotationsContentItem in [annotationsItem objectForKey:kSCHLibreAccessWebServiceAnnotationsContentList]) {
                [newAnnotationsItem addAnnotationsContentItemObject:[self annotationsContentItem:annotationsContentItem]];
            }
        }
    }
    
	[self backgroundSave:NO];
}

- (void)syncProfileContentAnnotationsCompleted:(NSNumber *)profileID usingMethod:(NSString *)method
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kSCHProfileItem
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"ID == %@", profileID]];
    
    NSArray *profiles = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    if ([profiles count] > 0) {
        SCHProfileItem *profileItem = [profiles objectAtIndex:0];
        for (SCHAppContentProfileItem *appContentProfileItem in profileItem.AppContentProfileItem) {
            appContentProfileItem.LastAnnotationSync = [NSDate date];
        }
    }
    [fetchRequest release];
    [self.managedObjectContext save:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SCHAnnotationSyncComponentDidCompleteNotification 
                                                        object:self 
                                                      userInfo:[NSDictionary dictionaryWithObject:profileID 
                                                                                           forKey:SCHAnnotationSyncComponentCompletedProfileIDs]];        
    [self.annotations removeObjectForKey:profileID];
    
    [super method:method didCompleteWithResult:nil];
}

- (void)syncAnnotationsContentList:(NSArray *)webAnnotationsContentList 
         withAnnotationContentList:(NSArray *)localAnnotationsContentList
                        insertInto:(SCHAnnotationsItem *)annotationsItem
{
	NSMutableArray *creationPool = [NSMutableArray array];
	
	webAnnotationsContentList = [webAnnotationsContentList sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceContentIdentifier ascending:YES],
                                                                                        [NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceDRMQualifier ascending:YES],                                                                             
                                                                                        nil]];		
	localAnnotationsContentList = [localAnnotationsContentList sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceContentIdentifier ascending:YES],
                                                                                            [NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceDRMQualifier ascending:YES],                                                                             
                                                                                            nil]];
    
	NSEnumerator *webEnumerator = [webAnnotationsContentList objectEnumerator];			  
	NSEnumerator *localEnumerator = [localAnnotationsContentList objectEnumerator];			  			  
    
	NSDictionary *webItem = [webEnumerator nextObject];
	SCHAnnotationsContentItem *localItem = [localEnumerator nextObject];
	
	while (webItem != nil || localItem != nil) {		
		if (webItem == nil) {
			break;
		}
		
		if (localItem == nil) {
			while (webItem != nil) {
				[creationPool addObject:webItem];
				webItem = [webEnumerator nextObject];
			} 
			break;			
		}
				
        SCHBookIdentifier *webBookIdentifier = [[SCHBookIdentifier alloc] initWithObject:webItem];
        SCHBookIdentifier *localBookIdentifier = localItem.bookIdentifier;
        
		switch ([webBookIdentifier compare:localBookIdentifier]) {
			case NSOrderedSame:
				[self syncAnnotationsContentItem:webItem withAnnotationsContentItem:localItem];
                [self backgroundSave:YES];
				webItem = nil;
				localItem = nil;
				break;
			case NSOrderedAscending:
				[creationPool addObject:webItem];
				webItem = nil;
				break;
			case NSOrderedDescending:
				localItem = nil;
				break;			
		}		
        
		[webBookIdentifier release], webBookIdentifier = nil;
        
		if (webItem == nil) {
			webItem = [webEnumerator nextObject];
		}
		if (localItem == nil) {
			localItem = [localEnumerator nextObject];
		}		
	}
    
	for (NSDictionary *webItem in creationPool) {
        SCHAnnotationsContentItem *item = [self annotationsContentItem:webItem];
        if (item != nil) {
            [annotationsItem addAnnotationsContentItemObject:item];
            [self backgroundSave:YES];
        }
    }
    
    [self backgroundSave:NO];
}

- (void)syncAnnotationsContentItem:(NSDictionary *)webAnnotationsContentItem withAnnotationsContentItem:(SCHAnnotationsContentItem *)localAnnotationsContentItem
{
    if (webAnnotationsContentItem != nil) {
        localAnnotationsContentItem.DRMQualifier = [self makeNullNil:[webAnnotationsContentItem objectForKey:kSCHLibreAccessWebServiceDRMQualifier]];
        localAnnotationsContentItem.ContentIdentifierType = [self makeNullNil:[webAnnotationsContentItem objectForKey:kSCHLibreAccessWebServiceContentIdentifierType]];
        localAnnotationsContentItem.ContentIdentifier = [self makeNullNil:[webAnnotationsContentItem objectForKey:kSCHLibreAccessWebServiceContentIdentifier]];
        
        localAnnotationsContentItem.Format = [self makeNullNil:[webAnnotationsContentItem objectForKey:kSCHLibreAccessWebServiceFormat]];
        
        NSDictionary *privateAnnotations = [self makeNullNil:[webAnnotationsContentItem objectForKey:kSCHLibreAccessWebServicePrivateAnnotations]];
        
        if (privateAnnotations != nil) {
            NSArray *annotation = [self makeNullNil:[privateAnnotations objectForKey:kSCHLibreAccessWebServiceHighlights]];
            if (annotation != nil) {
                [self syncHighlights:annotation
                      withHighlights:localAnnotationsContentItem.PrivateAnnotations.Highlights 
                          insertInto:localAnnotationsContentItem.PrivateAnnotations];
            }
            if ([[SCHAppStateManager sharedAppStateManager] canSyncNotes] == YES) {
                annotation = [self makeNullNil:[privateAnnotations objectForKey:kSCHLibreAccessWebServiceNotes]];
                if (annotation != nil) {        
                    [self syncNotes:annotation
                          withNotes:localAnnotationsContentItem.PrivateAnnotations.Notes 
                         insertInto:localAnnotationsContentItem.PrivateAnnotations];
                }
            }
            annotation = [self makeNullNil:[privateAnnotations objectForKey:kSCHLibreAccessWebServiceBookmarks]] ;
            if (annotation != nil) {                
                [self syncBookmarks:annotation
                      withBookmarks:localAnnotationsContentItem.PrivateAnnotations.Bookmarks 
                         insertInto:localAnnotationsContentItem.PrivateAnnotations];        
            }
            [self syncLastPage:[self makeNullNil:[privateAnnotations objectForKey:kSCHLibreAccessWebServiceLastPage]] 
                  withLastPage:localAnnotationsContentItem.PrivateAnnotations.LastPage];
        }
    }
}

- (SCHAnnotationsContentItem *)annotationsContentItem:(NSDictionary *)annotationsContentItem
{
    NSAssert([NSThread isMainThread] == NO, @"annotationsContentItem MUST NOT be executed on the main thread");
	SCHAnnotationsContentItem *ret = nil;
	
	if (annotationsContentItem != nil) {
        ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHAnnotationsContentItem 
                                            inManagedObjectContext:self.backgroundThreadManagedObjectContext];
        
		ret.DRMQualifier = [self makeNullNil:[annotationsContentItem objectForKey:kSCHLibreAccessWebServiceDRMQualifier]];
		ret.ContentIdentifierType = [self makeNullNil:[annotationsContentItem objectForKey:kSCHLibreAccessWebServiceContentIdentifierType]];
		ret.ContentIdentifier = [self makeNullNil:[annotationsContentItem objectForKey:kSCHLibreAccessWebServiceContentIdentifier]];
		
		ret.Format = [self makeNullNil:[annotationsContentItem objectForKey:kSCHLibreAccessWebServiceFormat]];
        ret.PrivateAnnotations = [self privateAnnotation:[annotationsContentItem objectForKey:kSCHLibreAccessWebServicePrivateAnnotations]];        
    }
	
	return(ret);
}

- (SCHPrivateAnnotations *)privateAnnotation:(NSDictionary *)privateAnnotation
{
    NSAssert([NSThread isMainThread] == NO, @"privateAnnotation MUST NOT be executed on the main thread");
	SCHPrivateAnnotations *ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHPrivateAnnotations 
                                                               inManagedObjectContext:self.backgroundThreadManagedObjectContext];
	
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
	}
    ret.LastPage = [self lastPage:[privateAnnotation objectForKey:kSCHLibreAccessWebServiceLastPage]];
	
	return(ret);
}

- (void)syncHighlights:(NSArray *)webHighlights
        withHighlights:(NSSet *)localHighlights
            insertInto:(SCHPrivateAnnotations *)privateAnnotations
{
    NSAssert([NSThread isMainThread] == NO, @"syncHighlights MUST NOT be executed on the main thread");
    NSMutableArray *deletePool = [NSMutableArray array];
	NSMutableArray *creationPool = [NSMutableArray array];
	
	webHighlights = [webHighlights sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceID ascending:YES]]];		
	NSArray *localHighlightsArray = [localHighlights sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceID ascending:YES]]];
    
	NSEnumerator *webEnumerator = [webHighlights objectEnumerator];			  
	NSEnumerator *localEnumerator = [localHighlightsArray objectEnumerator];			  			  
    
	NSDictionary *webItem = [webEnumerator nextObject];
	SCHHighlight *localItem = [localEnumerator nextObject];
	
	while (webItem != nil || localItem != nil) {		
		if (webItem == nil) {
			while (localItem != nil) {
                if ([localItem.State statusValue] == kSCHStatusUnmodified) {
                    [deletePool addObject:localItem];
                }
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
		
		id webItemID = [webItem valueForKey:kSCHLibreAccessWebServiceID];
		id localItemID = [localItem valueForKey:kSCHLibreAccessWebServiceID];
		
		switch ([webItemID compare:localItemID]) {
			case NSOrderedSame:
				[self syncHighlight:webItem withHighlight:localItem];
                [self backgroundSave:YES];
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
    
    for (SCHHighlight *localItem in deletePool) {
		[self.backgroundThreadManagedObjectContext deleteObject:localItem];
        [self backgroundSave:YES];
	}

	for (NSDictionary *webItem in creationPool) {
        [privateAnnotations addHighlightsObject:[self highlight:webItem]];
        [self backgroundSave:YES];
	}
	
	[self backgroundSave:NO];        
}

- (void)syncHighlight:(NSDictionary *)webHighlight
        withHighlight:(SCHHighlight *)localHighlight
{
    if ([localHighlight.State statusValue] == kSCHStatusUnmodified) {
        localHighlight.Color = [self makeNullNil:[webHighlight objectForKey:kSCHLibreAccessWebServiceColor]];
        localHighlight.EndPage = [self makeNullNil:[webHighlight objectForKey:kSCHLibreAccessWebServiceEndPage]];
        
        localHighlight.ID = [self makeNullNil:[webHighlight objectForKey:kSCHLibreAccessWebServiceID]];
        localHighlight.Version = [self makeNullNil:[webHighlight objectForKey:kSCHLibreAccessWebServiceVersion]];
        
        localHighlight.LastModified = [self makeNullNil:[webHighlight objectForKey:kSCHLibreAccessWebServiceLastModified]];
        localHighlight.State = [NSNumber numberWithStatus:kSCHStatusSyncUpdate];				        
        
        [self syncLocationText:[self makeNullNil:[webHighlight objectForKey:kSCHLibreAccessWebServiceLocation]] 
              withLocationText:localHighlight.Location];
    }
}

- (SCHHighlight *)highlight:(NSDictionary *)highlight
{
    NSAssert([NSThread isMainThread] == NO, @"highlight MUST NOT be executed on the main thread");
	SCHHighlight *ret = nil;
	
	if (highlight != nil) {
		ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHHighlight 
                                            inManagedObjectContext:self.backgroundThreadManagedObjectContext];
		
		ret.LastModified = [self makeNullNil:[highlight objectForKey:kSCHLibreAccessWebServiceLastModified]];
        ret.State = [NSNumber numberWithStatus:kSCHStatusUnmodified];
        
		ret.ID = [self makeNullNil:[highlight objectForKey:kSCHLibreAccessWebServiceID]];
		ret.Version = [self makeNullNil:[highlight objectForKey:kSCHLibreAccessWebServiceVersion]];
		
		ret.Color = [self makeNullNil:[highlight objectForKey:kSCHLibreAccessWebServiceColor]];
		ret.EndPage = [self makeNullNil:[highlight objectForKey:kSCHLibreAccessWebServiceEndPage]];
		ret.Location = [self locationText:[highlight objectForKey:kSCHLibreAccessWebServiceLocation]];
	}
	
	return(ret);
}

- (void)syncLocationText:(NSDictionary *)webLocationText
        withLocationText:(SCHLocationText *)localLocationText
{
    if (webLocationText != nil) {
        localLocationText.Page = [self makeNullNil:[webLocationText objectForKey:kSCHLibreAccessWebServicePage]];    
        
        [self syncWordIndex:[self makeNullNil:[webLocationText objectForKey:kSCHLibreAccessWebServiceWordIndex]] 
              withWordIndex:localLocationText.WordIndex];    
    }
}

- (SCHLocationText *)locationText:(NSDictionary *)locationText
{
    NSAssert([NSThread isMainThread] == NO, @"locationText MUST NOT be executed on the main thread");
	SCHLocationText *ret = ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHLocationText
                                                               inManagedObjectContext:self.backgroundThreadManagedObjectContext];

	if (locationText != nil) {
		ret.Page = [self makeNullNil:[locationText objectForKey:kSCHLibreAccessWebServicePage]];
	} else {
        [ret setInitialValues];
    }
    ret.WordIndex = [self wordIndex:[locationText objectForKey:kSCHLibreAccessWebServiceWordIndex]];        
	
	return(ret);
}

- (void)syncWordIndex:(NSDictionary *)websyncWordIndex
        withWordIndex:(SCHWordIndex *)localsyncWordIndex
{
    if (websyncWordIndex != nil) {
        localsyncWordIndex.Start = [self makeNullNil:[websyncWordIndex objectForKey:kSCHLibreAccessWebServiceStart]];
        localsyncWordIndex.End = [self makeNullNil:[websyncWordIndex objectForKey:kSCHLibreAccessWebServiceEnd]];        
    }
}

- (SCHWordIndex *)wordIndex:(NSDictionary *)wordIndex
{
    NSAssert([NSThread isMainThread] == NO, @"wordIndex MUST NOT be executed on the main thread");
	SCHWordIndex *ret = ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHWordIndex
                                                            inManagedObjectContext:self.backgroundThreadManagedObjectContext];

	
	if (wordIndex != nil) {
		ret.Start = [self makeNullNil:[wordIndex objectForKey:kSCHLibreAccessWebServiceStart]];
		ret.End = [self makeNullNil:[wordIndex objectForKey:kSCHLibreAccessWebServiceEnd]];
	} else {
        [ret setInitialValues];
    }
	
	return(ret);
}

- (void)syncNotes:(NSArray *)webNotes
        withNotes:(NSSet *)localNotes
       insertInto:(SCHPrivateAnnotations *)privateAnnotations
{
    NSAssert([NSThread isMainThread] == NO, @"syncNotes MUST NOT be executed on the main thread");
    NSMutableArray *deletePool = [NSMutableArray array];
	NSMutableArray *creationPool = [NSMutableArray array];
	
	webNotes = [webNotes sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceID ascending:YES]]];		
	NSArray *localNotesArray = [localNotes sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceID ascending:YES]]];
    
	NSEnumerator *webEnumerator = [webNotes objectEnumerator];			  
	NSEnumerator *localEnumerator = [localNotesArray objectEnumerator];			  			  
    
	NSDictionary *webItem = [webEnumerator nextObject];
	SCHNote *localItem = [localEnumerator nextObject];
	
	while (webItem != nil || localItem != nil) {		
		if (webItem == nil) {
			while (localItem != nil) {
                if ([localItem.State statusValue] == kSCHStatusUnmodified) {
                    [deletePool addObject:localItem];
                }
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
		
		id webItemID = [webItem valueForKey:kSCHLibreAccessWebServiceID];
		id localItemID = [localItem valueForKey:kSCHLibreAccessWebServiceID];
		
		switch ([webItemID compare:localItemID]) {
			case NSOrderedSame:
				[self syncNote:webItem withNote:localItem];
                [self backgroundSave:YES];
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

    for (SCHNote *localItem in deletePool) {
		[self.backgroundThreadManagedObjectContext deleteObject:localItem];
        [self backgroundSave:YES];
	}

	for (NSDictionary *webItem in creationPool) {
        [privateAnnotations addNotesObject:[self note:webItem]];
        [self backgroundSave:YES];
	}
	
	[self backgroundSave:NO];        
}

- (void)syncNote:(NSDictionary *)webNote
        withNote:(SCHNote *)localNote
{
    if ([localNote.State statusValue] == kSCHStatusUnmodified) {
        localNote.Color = [self makeNullNil:[webNote objectForKey:kSCHLibreAccessWebServiceColor]];
        localNote.Value = [self makeNullNil:[webNote objectForKey:kSCHLibreAccessWebServiceValue]];
        
        localNote.ID = [self makeNullNil:[webNote objectForKey:kSCHLibreAccessWebServiceID]];
        localNote.Version = [self makeNullNil:[webNote objectForKey:kSCHLibreAccessWebServiceVersion]];
        
        localNote.LastModified = [self makeNullNil:[webNote objectForKey:kSCHLibreAccessWebServiceLastModified]];
        localNote.State = [NSNumber numberWithStatus:kSCHStatusSyncUpdate];				        
        
        [self syncLocationGraphics:[self makeNullNil:[webNote objectForKey:kSCHLibreAccessWebServiceLocation]] 
              withLocationGraphics:localNote.Location];
    }
}

- (SCHNote *)note:(NSDictionary *)note
{
    NSAssert([NSThread isMainThread] == NO, @"note MUST NOT be executed on the main thread");
	SCHNote *ret = nil;
	
	if (note != nil) {
		ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHNote 
                                            inManagedObjectContext:self.backgroundThreadManagedObjectContext];
		
		ret.LastModified = [self makeNullNil:[note objectForKey:kSCHLibreAccessWebServiceLastModified]];
        ret.State = [NSNumber numberWithStatus:kSCHStatusUnmodified];
        
		ret.ID = [self makeNullNil:[note objectForKey:kSCHLibreAccessWebServiceID]];
		ret.Version = [self makeNullNil:[note objectForKey:kSCHLibreAccessWebServiceVersion]];
		
		ret.Color = [self makeNullNil:[note objectForKey:kSCHLibreAccessWebServiceColor]];
		ret.Value = [self makeNullNil:[note objectForKey:kSCHLibreAccessWebServiceValue]];
		ret.Location = [self locationGraphics:[note objectForKey:kSCHLibreAccessWebServiceLocation]];
	}
	
	return(ret);
}

- (void)syncLocationGraphics:(NSDictionary *)webLocationGraphics 
        withLocationGraphics:(SCHLocationGraphics *)localLocationGraphics
{
    if (webLocationGraphics != nil) {
        localLocationGraphics.Page = [self makeNullNil:[webLocationGraphics objectForKey:kSCHLibreAccessWebServicePage]];    
    }
}

- (SCHLocationGraphics *)locationGraphics:(NSDictionary *)locationGraphics
{
    NSAssert([NSThread isMainThread] == NO, @"locationGraphics MUST NOT be executed on the main thread");
	SCHLocationGraphics *ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHLocationGraphics 
                                            inManagedObjectContext:self.backgroundThreadManagedObjectContext];
    
	if (locationGraphics != nil) {		
		ret.Page = [self makeNullNil:[locationGraphics objectForKey:kSCHLibreAccessWebServicePage]];
	} else {
        [ret setInitialValues];
    }
	
	return(ret);
}

- (void)syncBookmarks:(NSArray *)webBookmarks
        withBookmarks:(NSSet *)localBookmarks
           insertInto:(SCHPrivateAnnotations *)privateAnnotations
{
    NSAssert([NSThread isMainThread] == NO, @"syncBookmarks MUST NOT be executed on the main thread");
    NSMutableArray *deletePool = [NSMutableArray array];
	NSMutableArray *creationPool = [NSMutableArray array];
	
	webBookmarks = [webBookmarks sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceID ascending:YES]]];		
	NSArray *localBookmarksArray = [localBookmarks sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceID ascending:YES]]];
    
	NSEnumerator *webEnumerator = [webBookmarks objectEnumerator];			  
	NSEnumerator *localEnumerator = [localBookmarksArray objectEnumerator];			  			  
    
	NSDictionary *webItem = [webEnumerator nextObject];
	SCHBookmark *localItem = [localEnumerator nextObject];
	
	while (webItem != nil || localItem != nil) {		
		if (webItem == nil) {
			while (localItem != nil) {
                if ([localItem.State statusValue] == kSCHStatusUnmodified) {
                    [deletePool addObject:localItem];
                }
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
		
		id webItemID = [webItem valueForKey:kSCHLibreAccessWebServiceID];
		id localItemID = [localItem valueForKey:kSCHLibreAccessWebServiceID];
		
		switch ([webItemID compare:localItemID]) {
			case NSOrderedSame:
				[self syncBookmark:webItem withBookmark:localItem];
                [self backgroundSave:YES];
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
    
    for (SCHBookmark *localItem in deletePool) {
		[self.backgroundThreadManagedObjectContext deleteObject:localItem];
        [self backgroundSave:YES];
	}

	for (NSDictionary *webItem in creationPool) {
        [privateAnnotations addBookmarksObject:[self bookmark:webItem]];
        [self backgroundSave:YES];
	}
	
	[self backgroundSave:NO];    
}

- (void)syncBookmark:(NSDictionary *)webBookmark 
        withBookmark:(SCHBookmark *)localBookmark
{
    if ([localBookmark.State statusValue] == kSCHStatusUnmodified) {
        localBookmark.Disabled = [self makeNullNil:[webBookmark objectForKey:kSCHLibreAccessWebServiceDisabled]];
        localBookmark.Text = [self makeNullNil:[webBookmark objectForKey:kSCHLibreAccessWebServiceText]];
        
        localBookmark.ID = [self makeNullNil:[webBookmark objectForKey:kSCHLibreAccessWebServiceID]];
        localBookmark.Version = [self makeNullNil:[webBookmark objectForKey:kSCHLibreAccessWebServiceVersion]];
        
        localBookmark.LastModified = [self makeNullNil:[webBookmark objectForKey:kSCHLibreAccessWebServiceLastModified]];
        localBookmark.State = [NSNumber numberWithStatus:kSCHStatusSyncUpdate];				        
        
        [self syncLocationBookmark:[self makeNullNil:[webBookmark objectForKey:kSCHLibreAccessWebServiceLocation]] 
              withLocationBookmark:localBookmark.Location];
    }
}

- (SCHBookmark *)bookmark:(NSDictionary *)bookmark
{
    NSAssert([NSThread isMainThread] == NO, @"bookmark MUST NOT be executed on the main thread");
	SCHBookmark *ret = nil;
	
	if (bookmark != nil) {
		ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHBookmark 
                                            inManagedObjectContext:self.backgroundThreadManagedObjectContext];
		
		ret.LastModified = [self makeNullNil:[bookmark objectForKey:kSCHLibreAccessWebServiceLastModified]];
        ret.State = [NSNumber numberWithStatus:kSCHStatusUnmodified];
        
		ret.ID = [self makeNullNil:[bookmark objectForKey:kSCHLibreAccessWebServiceID]];
		ret.Version = [self makeNullNil:[bookmark objectForKey:kSCHLibreAccessWebServiceVersion]];
		
		ret.Disabled = [self makeNullNil:[bookmark objectForKey:kSCHLibreAccessWebServiceDisabled]];
		ret.Text = [self makeNullNil:[bookmark objectForKey:kSCHLibreAccessWebServiceText]];
		ret.Location = [self locationBookmark:[bookmark objectForKey:kSCHLibreAccessWebServiceLocation]];
	}
	
	return(ret);
}

- (void)syncLocationBookmark:(NSDictionary *)webLocationBookmark 
        withLocationBookmark:(SCHLocationBookmark *)localLocationBookmark
{
    if (webLocationBookmark != nil) {
        localLocationBookmark.Page = [self makeNullNil:[webLocationBookmark objectForKey:kSCHLibreAccessWebServicePage]];
    }
}

- (SCHLocationBookmark *)locationBookmark:(NSDictionary *)locationBookmark
{
    NSAssert([NSThread isMainThread] == NO, @"locationBookmark MUST NOT be executed on the main thread");
	SCHLocationBookmark *ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHLocationBookmark 
                                            inManagedObjectContext:self.backgroundThreadManagedObjectContext];
		
    if (locationBookmark != nil) {
		ret.Page = [self makeNullNil:[locationBookmark objectForKey:kSCHLibreAccessWebServicePage]];
	} else {
        [ret setInitialValues];
    }
	
	return(ret);
}

- (void)syncLastPage:(NSDictionary *)webLastPage withLastPage:(SCHLastPage *)localLastPage
{
    if (webLastPage != nil) {
        localLastPage.LastPageLocation = [self makeNullNil:[webLastPage objectForKey:kSCHLibreAccessWebServiceLastPageLocation]];
        localLastPage.Component = [self makeNullNil:[webLastPage objectForKey:kSCHLibreAccessWebServiceComponent]];
        localLastPage.Percentage = [self makeNullNil:[webLastPage objectForKey:kSCHLibreAccessWebServicePercentage]];	
        
        localLastPage.LastModified = [self makeNullNil:[webLastPage objectForKey:kSCHLibreAccessWebServiceLastModified]];
        localLastPage.State = [NSNumber numberWithStatus:kSCHStatusSyncUpdate];				    
    }
}

- (SCHLastPage *)lastPage:(NSDictionary *)lastPage
{
    NSAssert([NSThread isMainThread] == NO, @"lastPage MUST NOT be executed on the main thread");
	SCHLastPage *ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHLastPage 
                                        inManagedObjectContext:self.backgroundThreadManagedObjectContext];

	if (lastPage != nil) {				
		ret.LastPageLocation = [self makeNullNil:[lastPage objectForKey:kSCHLibreAccessWebServiceLastPageLocation]];
		ret.Percentage = [self makeNullNil:[lastPage objectForKey:kSCHLibreAccessWebServicePercentage]];
		ret.Component = [self makeNullNil:[lastPage objectForKey:kSCHLibreAccessWebServiceComponent]];
        
		ret.LastModified = [self makeNullNil:[lastPage objectForKey:kSCHLibreAccessWebServiceLastModified]];
		ret.State = [NSNumber numberWithStatus:kSCHStatusUnmodified];        
	} else {
        [ret setInitialValues];
    }
	
	return(ret);
}

- (void)backgroundSave:(BOOL)batch
{
    NSAssert([NSThread isMainThread] == NO, @"backgroundSave MUST NOT be executed on the main thread");

	NSError *error = nil;
	static NSUInteger batchCount = 0;
    
    if (batch == NO || ++batchCount > 250) {
        batchCount = 0;
        if (![self.backgroundThreadManagedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        } 
    }
}

@end
