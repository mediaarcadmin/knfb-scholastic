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
#import "SCHRating.h"
#import "SCHAppStateManager.h"
#import "SCHProfileItem.h"
#import "SCHAppContentProfileItem.h"
#import "SCHBookIdentifier.h"
#import "BITAPIError.h"
#import "NSDate+ServerDate.h"
#import "SCHLibreAccessWebService.h"

// Constants
NSString * const SCHAnnotationSyncComponentDidCompleteNotification = @"SCHAnnotationSyncComponentDidCompleteNotification";
NSString * const SCHAnnotationSyncComponentDidFailNotification = @"SCHAnnotationSyncComponentDidFailNotification";
NSString * const SCHAnnotationSyncComponentProfileIDs = @"SCHAnnotationSyncComponentProfileIDs";

@interface SCHAnnotationSyncComponent ()

@property (nonatomic, retain) SCHLibreAccessWebService *libreAccessWebService;
@property (nonatomic, retain) NSManagedObjectContext *backgroundThreadManagedObjectContext;
@property (retain, nonatomic) NSMutableDictionary *annotations;
@property (retain, nonatomic) NSMutableArray *savedAnnotations;
@property (nonatomic, retain) NSDate *lastSyncSaveCalled;

- (NSNumber *)currentProfile;
- (BOOL)updateProfileContentAnnotations;
- (void)processSaveProfileContentAnnotations:(NSNumber *)profileID 
                                      result:(NSDictionary *)result;
- (void)trackAnnotationSaves:(NSSet *)annotationsArray;
- (void)applyAnnotationSaves:(NSArray *)annotationsArray;
- (BOOL)annotationIDIsValid:(NSNumber *)annotationID;
- (NSArray *)localModifiedAnnotationsItemForProfile:(NSNumber *)profileID;
- (NSArray *)localAnnotationsItemForProfile:(NSNumber *)profileID;
- (void)syncProfileContentAnnotations:(NSDictionary *)profileContentAnnotationList 
                              canSyncNotes:(BOOL)canSyncNotes
                        canSyncRating:(BOOL)canSyncRating
                             syncDate:(NSDate *)syncDate;
- (void)syncProfileContentAnnotationsCompleted:(NSNumber *)profileID 
                                   usingMethod:(NSString *)method
                                      userInfo:(NSDictionary *)userInfo;
- (void)syncAnnotationsContentList:(NSArray *)webAnnotationsContentList 
         withAnnotationContentList:(NSSet *)localAnnotationsContentList
                        insertInto:(SCHAnnotationsItem *)annotationsItem
                      canSyncNotes:(BOOL)canSyncNotes
                     canSyncRating:(BOOL)canSyncRating
                          syncDate:(NSDate *)syncDate;
- (void)syncAnnotationsContentItem:(NSDictionary *)webAnnotationsContentItem 
        withAnnotationsContentItem:(SCHAnnotationsContentItem *)localAnnotationsContentItem
                      canSyncNotes:(BOOL)canSyncNotes
                     canSyncRating:(BOOL)canSyncRating
                          syncDate:(NSDate *)syncDate;
- (SCHAnnotationsContentItem *)annotationsContentItem:(NSDictionary *)annotationsContentItem;
- (SCHPrivateAnnotations *)privateAnnotation:(NSDictionary *)privateAnnotation;
- (void)syncHighlights:(NSArray *)webHighlights
        withHighlights:(NSSet *)localHighlights
            insertInto:(SCHPrivateAnnotations *)privateAnnotations
              syncDate:(NSDate *)syncDate;
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
       insertInto:(SCHPrivateAnnotations *)privateAnnotations
         syncDate:(NSDate *)syncDate;
- (void)syncNote:(NSDictionary *)webNote
        withNote:(SCHNote *)localNote;
- (SCHNote *)note:(NSDictionary *)note;
- (void)syncLocationGraphics:(NSDictionary *)webLocationGraphics 
        withLocationGraphics:(SCHLocationGraphics *)localLocationGraphics;
- (SCHLocationGraphics *)locationGraphics:(NSDictionary *)locationGraphics;
- (void)syncBookmarks:(NSArray *)webBookmarks
        withBookmarks:(NSSet *)localBookmarks
           insertInto:(SCHPrivateAnnotations *)privateAnnotations
             syncDate:(NSDate *)syncDate;
- (void)syncBookmark:(NSDictionary *)webBookmark 
        withBookmark:(SCHBookmark *)localBookmark;
- (SCHBookmark *)bookmark:(NSDictionary *)bookmark;
- (void)syncLocationBookmark:(NSDictionary *)webLocationBookmark 
        withLocationBookmark:(SCHLocationBookmark *)localLocationBookmark;
- (SCHLocationBookmark *)locationBookmark:(NSDictionary *)locationBookmark;
- (void)syncLastPage:(NSDictionary *)webLastPage 
        withLastPage:(SCHLastPage *)localLastPage;
- (SCHLastPage *)lastPage:(NSDictionary *)lastPage;
- (void)syncRating:(NSDictionary *)webRating withRating:(SCHRating *)localRating;
- (SCHRating *)rating:(NSDictionary *)rating;
- (BOOL)shouldCreate:(NSDictionary *)webItem;
- (BOOL)shouldDelete:(NSDictionary *)webItem;
- (void)backgroundSave:(BOOL)batch;
- (NSArray *)removeNewlyCreatedAndSavedAnnotations:(NSArray *)annotationArray;

@end

@implementation SCHAnnotationSyncComponent

@synthesize libreAccessWebService;
@synthesize backgroundThreadManagedObjectContext;
@synthesize annotations;
@synthesize savedAnnotations;
@synthesize lastSyncSaveCalled;

- (id)init
{
	self = [super init];
	if (self != nil) {
		libreAccessWebService = [[SCHLibreAccessWebService alloc] init];	
		libreAccessWebService.delegate = self;
        
		annotations = [[NSMutableDictionary dictionary] retain];
		savedAnnotations = [[NSMutableArray array] retain];
	}
	
	return(self);
}

- (void)dealloc
{
    libreAccessWebService.delegate = nil;
	[libreAccessWebService release], libreAccessWebService = nil;
	[backgroundThreadManagedObjectContext release], backgroundThreadManagedObjectContext = nil;
    
	[annotations release], annotations = nil;
    [savedAnnotations release], savedAnnotations = nil;
    [lastSyncSaveCalled release], lastSyncSaveCalled = nil;
    
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
                if (bookIdentifier != nil) {
                    __block BOOL bookAlreadyExists = NO;
                    [profileBooks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        SCHBookIdentifier *profileBookIdentifier = [[SCHBookIdentifier alloc] initWithObject:obj];
                        if (profileBookIdentifier != nil &&
                            [bookIdentifier isEqual:profileBookIdentifier] == YES) {
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
            }
        } else {
            [self.annotations setObject:[NSMutableArray arrayWithArray:books] forKey:profileID];		
        }
	}
}

// books is an array of BookIdentifiers
- (void)removeProfile:(NSNumber *)profileID withBooks:(NSArray *)books
{
	if (self.isSynchronizing == NO && profileID != nil && [books count] > 0) {
        NSMutableArray *profileBooks = [self.annotations objectForKey:profileID];
        if (profileBooks != nil) {
            for (SCHBookIdentifier *bookIdentifier in books) {
                __block NSUInteger removeBook = NSUIntegerMax;
                [profileBooks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    SCHBookIdentifier *profileBookIdentifier = [[SCHBookIdentifier alloc] initWithObject:obj];
                    if (profileBookIdentifier != nil &&
                        [bookIdentifier isEqual:profileBookIdentifier] == YES) {
                        removeBook = idx;
                        *stop = YES;
                    }
                    [profileBookIdentifier release], profileBookIdentifier = nil;                    
                }];
                if (removeBook != NSUIntegerMax && removeBook < [profileBooks count]) {
                    [profileBooks removeObjectAtIndex:removeBook];   
                }
            }
            if ([profileBooks count] < 1) {
                [self.annotations removeObjectForKey:profileID];
            }
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
    
    if ([self haveProfiles] == YES && [self.annotations count] > 0) {
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
        [self beginBackgroundTask];
        
		ret = [self updateProfileContentAnnotations];
        if (ret == NO) {
            [self endBackgroundTask];
        }         
	}
	
	return(ret);
}

#pragma - Overrideen methods used by resetSync

- (void)resetWebService
{
    [self.libreAccessWebService clear];    
}

- (void)clearComponent
{
    [self.annotations removeAllObjects];
    [self.savedAnnotations removeAllObjects];
    self.lastSyncSaveCalled = nil;    
}

- (void)clearCoreData
{
	NSError *error = nil;
	    
	if (![self.managedObjectContext BITemptyEntity:kSCHAnnotationsItem error:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}	    
}

#pragma mark - Delegate methods

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result
      userInfo:(NSDictionary *)userInfo
{
    NSNumber *profileID = [self currentProfile];
    
    if (profileID != nil) {
        @try {
            if([method compare:kSCHLibreAccessWebServiceSaveProfileContentAnnotationsForRatings] == NSOrderedSame) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    self.backgroundThreadManagedObjectContext = [[[NSManagedObjectContext alloc] init] autorelease];
                    [self.backgroundThreadManagedObjectContext setPersistentStoreCoordinator:self.managedObjectContext.persistentStoreCoordinator];
                    
                    [self processSaveProfileContentAnnotations:profileID result:result];
                    [self backgroundSave:NO];
                    self.backgroundThreadManagedObjectContext = nil;
                });
            } else if([method compare:kSCHLibreAccessWebServiceListProfileContentAnnotationsForRatings] == NSOrderedSame) {
                BOOL canSyncNotes = [[SCHAppStateManager sharedAppStateManager] canSyncNotes];
                BOOL canSyncRating = [[SCHAppStateManager sharedAppStateManager] isCOPPACompliant];
                NSDate *syncDate = [userInfo objectForKey:@"serverDate"];
                
                // if we don't have a serverDate then use the current device date
                if (syncDate == nil || syncDate == (id)[NSNull null]) {
                    syncDate = [NSDate serverDate];
                }
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    self.backgroundThreadManagedObjectContext = [[[NSManagedObjectContext alloc] init] autorelease];
                    [self.backgroundThreadManagedObjectContext setPersistentStoreCoordinator:self.managedObjectContext.persistentStoreCoordinator];
                    [self.backgroundThreadManagedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
                    
                    [self syncProfileContentAnnotations:[result objectForKey:kSCHLibreAccessWebServiceListProfileContentAnnotationsForRatings] 
                                           canSyncNotes:canSyncNotes
                                          canSyncRating:canSyncRating
                                               syncDate:syncDate];	            

                    [self backgroundSave:NO];
                    self.backgroundThreadManagedObjectContext = nil;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self syncProfileContentAnnotationsCompleted:profileID 
                                                         usingMethod:method
                                                            userInfo:userInfo];
                    });                
                });
            }
        }
        @catch (NSException *exception) {
            [[NSNotificationCenter defaultCenter] postNotificationName:SCHAnnotationSyncComponentDidFailNotification 
                                                                object:self 
                                                              userInfo:[NSDictionary dictionaryWithObject:(profileID == nil ? (id)[NSNull null] : profileID)
                                                                                                   forKey:SCHAnnotationSyncComponentProfileIDs]];            
            NSError *error = [NSError errorWithDomain:kBITAPIErrorDomain 
                                                 code:kBITAPIExceptionError 
                                             userInfo:[NSDictionary dictionaryWithObject:[exception reason]
                                                                                  forKey:NSLocalizedDescriptionKey]];
            [super method:method didFailWithError:error requestInfo:nil result:result];
            [self.savedAnnotations removeAllObjects];
        }    
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:SCHAnnotationSyncComponentDidCompleteNotification
                                                            object:self 
                                                          userInfo:[NSDictionary dictionaryWithObject:(profileID == nil ? (id)[NSNull null] : profileID)
                                                                                               forKey:SCHAnnotationSyncComponentProfileIDs]];                    
        [super method:method didCompleteWithResult:result userInfo:nil];        
        [self.savedAnnotations removeAllObjects];        
    }
}

- (void)processSaveProfileContentAnnotations:(NSNumber *)profileID 
                                      result:(NSDictionary *)result
{
    NSAssert([NSThread isMainThread] == NO, @"processSaveProfileContentAnnotations MUST NOT be executed on the main thread");        
    NSArray *books = [self.annotations objectForKey:profileID];
    BOOL shouldSyncNotes = NO;
    
    if (result != nil && [self.savedAnnotations count] > 0) {
        shouldSyncNotes = [[SCHAppStateManager sharedAppStateManager] canSyncNotes];
        for (NSDictionary *annotationStatusItem in [result objectForKey:kSCHLibreAccessWebServiceAnnotationStatusList]) {
            NSNumber *annotationProfileID = [annotationStatusItem objectForKey:kSCHLibreAccessWebServiceProfileID];
            if (annotationProfileID != nil && profileID != nil &&
                [annotationProfileID isEqualToNumber:profileID] == YES) {
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
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.saveOnly == NO) {
            self.isSynchronizing = [self.libreAccessWebService listProfileContentAnnotations:books 
                                                                                  forProfile:profileID];
            if (self.isSynchronizing == NO) {
                [[SCHAuthenticationManager sharedAuthenticationManager] authenticateWithSuccessBlock:^(SCHAuthenticationManagerConnectivityMode connectivityMode){
                    if (connectivityMode == SCHAuthenticationManagerConnectivityModeOnline) {
                        [self.delegate authenticationDidSucceed];
                    } else {
                        self.isSynchronizing = NO;
                    }
                } failureBlock:^(NSError *error){
                    self.isSynchronizing = NO;
                    [[NSNotificationCenter defaultCenter] postNotificationName:SCHSyncComponentDidFailAuthenticationNotification
                                                                        object:self];
                }];	
            }            
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:SCHAnnotationSyncComponentDidCompleteNotification 
                                                                object:self 
                                                              userInfo:[NSDictionary dictionaryWithObject:(profileID == nil ? (id)[NSNull null] : profileID)
                                                                                                   forKey:SCHAnnotationSyncComponentProfileIDs]];        
            if (profileID != nil) {
                [self.annotations removeObjectForKey:profileID];
            }
            
            [super method:nil didCompleteWithResult:nil userInfo:nil];
            [self.savedAnnotations removeAllObjects];        
        }
    });
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

// apply annotations changes by checking the server response
// confirmed deletions are deleted, confirmed creation ID's are applied
// any issues such as missing ID will be removed by removeNewlyCreatedAndSavedAnnotations
// the next list annotation will then resolve the issue
- (void)applyAnnotationSaves:(NSArray *)annotationsArray
{
    NSAssert([NSThread isMainThread] == NO, @"processSaveProfileContentAnnotations MUST NOT be executed on the main thread");            
    NSManagedObjectID *managedObjectID = nil;
    NSManagedObject *annotationManagedObject = nil;
    
    for (NSDictionary *annotation in annotationsArray) {
        if ([self.savedAnnotations count] > 0) {
            managedObjectID = [self.savedAnnotations objectAtIndex:0];
            if (managedObjectID != nil) {
                BOOL updatedID = NO;
                annotationManagedObject = [self.backgroundThreadManagedObjectContext objectWithID:managedObjectID];
                
                if ([[[annotation objectForKey:kSCHLibreAccessWebServiceStatusMessage] 
                      objectForKey:kSCHLibreAccessWebServiceStatus] statusCodeValue] == kSCHStatusCodesSuccess) {
                    switch ([[annotation objectForKey:kSCHLibreAccessWebServiceAction] saveActionValue]) {
                        case kSCHSaveActionsCreate:
                        {
                            NSNumber *annotationID = [self makeNullNil:[annotation objectForKey:kSCHLibreAccessWebServiceID]];
                            if ([self annotationIDIsValid:annotationID] == YES) {
                                updatedID = YES;
                                [annotationManagedObject setValue:annotationID forKey:kSCHLibreAccessWebServiceID];
                            }                                                   
                        }
                            break;
                        case kSCHSaveActionsRemove:                            
                        {
                            [self.backgroundThreadManagedObjectContext deleteObject:annotationManagedObject];
                        }
                            break;

                        default:
                            //nop
                            break;
                    }
                }
                                
                // We've attempted to save changes, reset to unmodified and now 
                // sync will update this with the truth from the server
                if (updatedID == YES && annotationManagedObject.isDeleted == NO) {
                    [annotationManagedObject setValue:[NSNumber numberWithStatus:kSCHStatusUnmodified] 
                                               forKey:SCHSyncEntityState];
                }
            }
            if ([self.savedAnnotations count] > 0) {
                [self.savedAnnotations removeObjectAtIndex:0];
            }
        }
        [self backgroundSave:NO];
    }
}

- (BOOL)annotationIDIsValid:(NSNumber *)annotationID
{
    return [annotationID integerValue] > 0;
}

- (void)method:(NSString *)method didFailWithError:(NSError *)error 
   requestInfo:(NSDictionary *)requestInfo 
        result:(NSDictionary *)result
{
    NSLog(@"%@:didFailWithError\n%@", method, error);
    NSNumber *profileID = [self currentProfile];
    
    // server error so process the result
    if ([error domain] == kBITAPIErrorDomain &&
        [method compare:kSCHLibreAccessWebServiceSaveProfileContentAnnotationsForRatings] == NSOrderedSame) {	            
        if (profileID != nil) {
            [self processSaveProfileContentAnnotations:profileID result:result];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:SCHAnnotationSyncComponentDidFailNotification 
                                                                object:self 
                                                              userInfo:[NSDictionary dictionaryWithObject:(profileID == nil ? (id)[NSNull null] : profileID)
                                                                                                   forKey:SCHAnnotationSyncComponentProfileIDs]];            
            [super method:method didFailWithError:error requestInfo:requestInfo result:result];            
        }
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:SCHAnnotationSyncComponentDidFailNotification 
                                                            object:self 
                                                          userInfo:[NSDictionary dictionaryWithObject:(profileID == nil ? (id)[NSNull null] : profileID)
                                                                                               forKey:SCHAnnotationSyncComponentProfileIDs]];            
        [super method:method didFailWithError:error requestInfo:requestInfo result:result];
    }
    [self.savedAnnotations removeAllObjects];
}

- (BOOL)updateProfileContentAnnotations
{
	BOOL ret = YES;
    BOOL shouldSyncNotes = NO;
	
    NSNumber *profileID = [self currentProfile];
    
    if (profileID != nil) {
        NSArray *books = [self.annotations objectForKey:profileID];
        
        self.lastSyncSaveCalled = nil;
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
                [[SCHAuthenticationManager sharedAuthenticationManager] authenticateWithSuccessBlock:^(SCHAuthenticationManagerConnectivityMode connectivityMode){
                    if (connectivityMode == SCHAuthenticationManagerConnectivityModeOnline) {
                        [self.delegate authenticationDidSucceed];
                    } else {
                        self.isSynchronizing = NO;
                    }
                } failureBlock:^(NSError *error){
                    self.isSynchronizing = NO;
                    [[NSNotificationCenter defaultCenter] postNotificationName:SCHSyncComponentDidFailAuthenticationNotification
                                                                        object:self];                
                }];				
                ret = NO;
            } else {
                self.lastSyncSaveCalled = [NSDate date];
            }
        } else if (self.saveOnly == NO && [self.annotations count] > 0) {
            self.isSynchronizing = [self.libreAccessWebService listProfileContentAnnotations:books 
                                                                                  forProfile:profileID];
            if (self.isSynchronizing == NO) {
                [[SCHAuthenticationManager sharedAuthenticationManager] authenticateWithSuccessBlock:^(SCHAuthenticationManagerConnectivityMode connectivityMode){
                    if (connectivityMode == SCHAuthenticationManagerConnectivityModeOnline) {
                        [self.delegate authenticationDidSucceed];
                    } else {
                        self.isSynchronizing = NO;
                    }
                } failureBlock:^(NSError *error){
                    self.isSynchronizing = NO;
                    [[NSNotificationCenter defaultCenter] postNotificationName:SCHSyncComponentDidFailAuthenticationNotification
                                                                        object:self];                
                }];					
                ret = NO;
            }
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:SCHAnnotationSyncComponentDidCompleteNotification 
                                                                object:self 
                                                              userInfo:[NSDictionary dictionaryWithObject:(profileID == nil ? (id)[NSNull null] : profileID)
                                                                                                   forKey:SCHAnnotationSyncComponentProfileIDs]];        
            if (profileID != nil) {
                [self.annotations removeObjectForKey:profileID];
            }
            
            [super method:nil didCompleteWithResult:nil userInfo:nil];
            [self.savedAnnotations removeAllObjects];                    
        }
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:SCHAnnotationSyncComponentDidCompleteNotification 
                                                            object:self 
                                                          userInfo:[NSDictionary dictionaryWithObject:(profileID == nil ? (id)[NSNull null] : profileID)
                                                                                               forKey:SCHAnnotationSyncComponentProfileIDs]];        
        
        [super method:nil didCompleteWithResult:nil userInfo:nil];        
        [self.savedAnnotations removeAllObjects];                            
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
    // we don't check all the annotations as if they have changed then the last page or rating has also change
    // the resulting array will contain all books and annotations for this profile when we eventually 
    // call the annotation save it will only save books with a modified LastPage and within each book
    // annotations that have been modified
    NSPredicate *predicate = nil;
    if ([[SCHAppStateManager sharedAppStateManager] isCOPPACompliant] == YES) {
        predicate = [NSPredicate predicateWithFormat:
                     @"ProfileID == %@ AND ((ANY AnnotationsContentItem.PrivateAnnotations.LastPage.State IN %@) OR (ANY AnnotationsContentItem.PrivateAnnotations.rating.State IN %@))", 
                     profileID, changedStates, changedStates];
    } else {
        predicate = [NSPredicate predicateWithFormat:
                     @"ProfileID == %@ AND ANY AnnotationsContentItem.PrivateAnnotations.LastPage.State IN %@", 
                     profileID, changedStates];        
    }
	[fetchRequest setPredicate:predicate];
	    
	ret = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release], fetchRequest = nil;
    if (ret == nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
	
	return(ret);	
}

- (NSArray *)localAnnotationsItemForProfile:(NSNumber *)profileID
{
    NSAssert([NSThread isMainThread] == NO, @"localAnnotationsItemForProfile MUST NOT be executed on the main thread");
    NSArray *ret = nil;
    if (profileID != nil) {
        NSError *error = nil;
        NSEntityDescription *entityDescription = [NSEntityDescription 
                                                  entityForName:kSCHAnnotationsItem
                                                  inManagedObjectContext:self.backgroundThreadManagedObjectContext];
        
        NSFetchRequest *fetchRequest = [entityDescription.managedObjectModel 
                                        fetchRequestFromTemplateWithName:kSCHAnnotationsItemfetchAnnotationItemForProfile 
                                        substitutionVariables:[NSDictionary 
                                                               dictionaryWithObject:profileID 
                                                               forKey:kSCHAnnotationsItemPROFILE_ID]];
        
        ret = [self.backgroundThreadManagedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (ret == nil) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }
    
	return ret;
}

- (void)syncProfileContentAnnotations:(NSDictionary *)profileContentAnnotationList 
                         canSyncNotes:(BOOL)canSyncNotes
                        canSyncRating:(BOOL)canSyncRating
                             syncDate:(NSDate *)syncDate
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
                                      insertInto:[localAnnotationsItems objectAtIndex:0]
                                    canSyncNotes:canSyncNotes
                                   canSyncRating:canSyncRating
                                        syncDate:syncDate];
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

- (void)syncProfileContentAnnotationsCompleted:(NSNumber *)profileID 
                                   usingMethod:(NSString *)method
                                      userInfo:(NSDictionary *)userInfo
{
    NSParameterAssert(profileID);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SCHAnnotationSyncComponentDidCompleteNotification 
                                                        object:self 
                                                      userInfo:[NSDictionary dictionaryWithObject:(profileID == nil ? (id)[NSNull null] : profileID) 
                                                                                           forKey:SCHAnnotationSyncComponentProfileIDs]];        
    if (profileID != nil) {
        [self.annotations removeObjectForKey:profileID];
    }
    
    [super method:method didCompleteWithResult:nil userInfo:userInfo];
    [self.savedAnnotations removeAllObjects];        
}

- (void)syncAnnotationsContentList:(NSArray *)webAnnotationsContentList 
         withAnnotationContentList:(NSSet *)localAnnotationsContentList
                        insertInto:(SCHAnnotationsItem *)annotationsItem
                      canSyncNotes:(BOOL)canSyncNotes
                     canSyncRating:(BOOL)canSyncRating
                          syncDate:(NSDate *)syncDate
{
	NSMutableArray *creationPool = [NSMutableArray array];
	
	webAnnotationsContentList = [webAnnotationsContentList sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceContentIdentifier ascending:YES],
                                                                                        [NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceDRMQualifier ascending:YES],                                                                             
                                                                                        nil]];		
	NSArray *localAnnotationsContentArray = [localAnnotationsContentList sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceContentIdentifier ascending:YES],
                                                                                            [NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceDRMQualifier ascending:YES],                                                                             
                                                                                            nil]];
    
	NSEnumerator *webEnumerator = [webAnnotationsContentList objectEnumerator];			  
	NSEnumerator *localEnumerator = [localAnnotationsContentArray objectEnumerator];			  			  
    
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
        
        if (webBookIdentifier == nil) {
            webItem = nil;
        } else if (localBookIdentifier == nil) {
            localItem = nil;                                
        } else {
            switch ([webBookIdentifier compare:localBookIdentifier]) {
                case NSOrderedSame:
                    [self syncAnnotationsContentItem:webItem 
                          withAnnotationsContentItem:localItem 
                                        canSyncNotes:canSyncNotes
                                       canSyncRating:canSyncRating                         
                                            syncDate:syncDate];
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

- (void)syncAnnotationsContentItem:(NSDictionary *)webAnnotationsContentItem 
        withAnnotationsContentItem:(SCHAnnotationsContentItem *)localAnnotationsContentItem
                      canSyncNotes:(BOOL)canSyncNotes
                      canSyncRating:(BOOL)canSyncRating
                          syncDate:(NSDate *)syncDate
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
                          insertInto:localAnnotationsContentItem.PrivateAnnotations
                            syncDate:syncDate];
            }
            if (canSyncNotes == YES) {
                annotation = [self makeNullNil:[privateAnnotations objectForKey:kSCHLibreAccessWebServiceNotes]];
                if (annotation != nil) {        
                    [self syncNotes:annotation
                          withNotes:localAnnotationsContentItem.PrivateAnnotations.Notes 
                         insertInto:localAnnotationsContentItem.PrivateAnnotations
                           syncDate:syncDate];
                }
            }
            annotation = [self makeNullNil:[privateAnnotations objectForKey:kSCHLibreAccessWebServiceBookmarks]] ;
            if (annotation != nil) {                
                [self syncBookmarks:annotation
                      withBookmarks:localAnnotationsContentItem.PrivateAnnotations.Bookmarks 
                         insertInto:localAnnotationsContentItem.PrivateAnnotations
                           syncDate:syncDate];        
            }
            [self syncLastPage:[self makeNullNil:[privateAnnotations objectForKey:kSCHLibreAccessWebServiceLastPage]] 
                  withLastPage:localAnnotationsContentItem.PrivateAnnotations.LastPage];
            if (canSyncRating == YES) {
                [self syncRating:[self makeNullNil:[privateAnnotations objectForKey:kSCHLibreAccessWebServiceRating]] 
                      withRating:localAnnotationsContentItem.PrivateAnnotations.rating];            
            }
        }
    }
}

- (SCHAnnotationsContentItem *)annotationsContentItem:(NSDictionary *)annotationsContentItem
{
    NSAssert([NSThread isMainThread] == NO, @"annotationsContentItem MUST NOT be executed on the main thread");
	SCHAnnotationsContentItem *ret = nil;
	SCHBookIdentifier *webBookIdentifier = [[SCHBookIdentifier alloc] initWithObject:annotationsContentItem];
    
	if (annotationsContentItem != nil && webBookIdentifier != nil) {
        ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHAnnotationsContentItem 
                                            inManagedObjectContext:self.backgroundThreadManagedObjectContext];
        
		ret.DRMQualifier = webBookIdentifier.DRMQualifier;
		ret.ContentIdentifierType = [self makeNullNil:[annotationsContentItem objectForKey:kSCHLibreAccessWebServiceContentIdentifierType]];
		ret.ContentIdentifier = webBookIdentifier.isbn;
		
		ret.Format = [self makeNullNil:[annotationsContentItem objectForKey:kSCHLibreAccessWebServiceFormat]];
        ret.PrivateAnnotations = [self privateAnnotation:[annotationsContentItem objectForKey:kSCHLibreAccessWebServicePrivateAnnotations]];        
    }
	[webBookIdentifier release], webBookIdentifier = nil;
    
	return ret;
}

- (SCHPrivateAnnotations *)privateAnnotation:(NSDictionary *)privateAnnotation
{
    NSAssert([NSThread isMainThread] == NO, @"privateAnnotation MUST NOT be executed on the main thread");
	SCHPrivateAnnotations *ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHPrivateAnnotations 
                                                               inManagedObjectContext:self.backgroundThreadManagedObjectContext];
	
	if (privateAnnotation != nil) {		
		for (NSDictionary *highlight in [privateAnnotation objectForKey:kSCHLibreAccessWebServiceHighlights]) { 
            SCHHighlight *newHighlight = [self highlight:highlight];
            if (newHighlight != nil) {
                [ret addHighlightsObject:newHighlight];
            }
		}
		for (NSDictionary *note in [privateAnnotation objectForKey:kSCHLibreAccessWebServiceNotes]) { 
            SCHNote *newNote = [self note:note];
            if (newNote != nil) {
                [ret addNotesObject:newNote];
            }
		}
		for (NSDictionary *bookmark in [privateAnnotation objectForKey:kSCHLibreAccessWebServiceBookmarks]) { 
            SCHBookmark *newBookmark = [self bookmark:bookmark];
            if (newBookmark != nil) {
                [ret addBookmarksObject:newBookmark];
            }
		}
	}
    ret.LastPage = [self lastPage:[privateAnnotation objectForKey:kSCHLibreAccessWebServiceLastPage]];
    ret.rating = [self rating:[privateAnnotation objectForKey:kSCHLibreAccessWebServiceRating]];
	
	return(ret);
}

- (void)syncHighlights:(NSArray *)webHighlights
        withHighlights:(NSSet *)localHighlights
            insertInto:(SCHPrivateAnnotations *)privateAnnotations
              syncDate:(NSDate *)syncDate
{
    NSAssert([NSThread isMainThread] == NO, @"syncHighlights MUST NOT be executed on the main thread");
	NSMutableArray *deletePool = [NSMutableArray array];
	NSMutableArray *creationPool = [NSMutableArray array];
	
	webHighlights = [webHighlights sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceID ascending:YES]]];		
	NSArray *localHighlightsArray = [localHighlights sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceID ascending:YES]]];
    localHighlightsArray = [self removeNewlyCreatedAndSavedAnnotations:localHighlightsArray];
    
	NSEnumerator *webEnumerator = [webHighlights objectEnumerator];			  
	NSEnumerator *localEnumerator = [localHighlightsArray objectEnumerator];			  			  
    
	NSDictionary *webItem = [webEnumerator nextObject];
	SCHHighlight *localItem = [localEnumerator nextObject];
	
	while (webItem != nil || localItem != nil) {		
		if (webItem == nil) {
			break;
		}
		
		if (localItem == nil) {
			while (webItem != nil) {
                if ([self shouldCreate:webItem] == YES) {
                    [creationPool addObject:webItem];
                }
				webItem = [webEnumerator nextObject];
			} 
			break;			
		}
		
		id webItemID = [self makeNullNil:[webItem valueForKey:kSCHLibreAccessWebServiceID]];
		id localItemID = [localItem valueForKey:kSCHLibreAccessWebServiceID];
		
        if (webItemID == nil || [self annotationIDIsValid:webItemID] == NO) {
            webItem = nil;
        } else if (localItemID == nil) {
            localItem = nil;            
        } else {                
            switch ([webItemID compare:localItemID]) {
                case NSOrderedSame:
                    if ([self shouldDelete:webItem] == YES) {
                        [deletePool addObject:localItem];
                    } else {
                        [self syncHighlight:webItem withHighlight:localItem];
                        [self backgroundSave:YES];
                    }
                    webItem = nil;
                    localItem = nil;
                    break;
                case NSOrderedAscending:
                    if ([self shouldCreate:webItem] == YES) {
                        [creationPool addObject:webItem];
                    }
                    webItem = nil;
                    break;
                case NSOrderedDescending:
                    localItem = nil;
                    break;			
            }		
        }
		
		if (webItem == nil) {
			webItem = [webEnumerator nextObject];
		}
		if (localItem == nil) {
			localItem = [localEnumerator nextObject];
		}		
	}
    
    for (SCHHighlight *highlightItem in deletePool) {
        [self.backgroundThreadManagedObjectContext deleteObject:highlightItem];
        [self backgroundSave:YES];
    }                

	for (NSDictionary *webItem in creationPool) {
        SCHHighlight *newHighlight = [self highlight:webItem];
        if (newHighlight != nil) {
            [privateAnnotations addHighlightsObject:newHighlight];
            [self backgroundSave:YES];
        }
	}

    SCHAppContentProfileItem *appContentProfileItem = [[privateAnnotations.AnnotationsContentItem.AnnotationsItem profileItem] 
                                                       appContentProfileItemForBookIdentifier:[privateAnnotations.AnnotationsContentItem bookIdentifier]];
    if (appContentProfileItem != nil) {
        appContentProfileItem.LastHighlightAnnotationSync = syncDate;
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
	id annotationID = [self makeNullNil:[highlight valueForKey:kSCHLibreAccessWebServiceID]];

	if (highlight != nil && [self annotationIDIsValid:annotationID] == YES) {
		ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHHighlight 
                                            inManagedObjectContext:self.backgroundThreadManagedObjectContext];
		
		ret.LastModified = [self makeNullNil:[highlight objectForKey:kSCHLibreAccessWebServiceLastModified]];
        ret.State = [NSNumber numberWithStatus:kSCHStatusUnmodified];
        
		ret.ID = annotationID;
		ret.Version = [self makeNullNil:[highlight objectForKey:kSCHLibreAccessWebServiceVersion]];
		
		ret.Color = [self makeNullNil:[highlight objectForKey:kSCHLibreAccessWebServiceColor]];
		ret.EndPage = [self makeNullNil:[highlight objectForKey:kSCHLibreAccessWebServiceEndPage]];
		ret.Location = [self locationText:[highlight objectForKey:kSCHLibreAccessWebServiceLocation]];
	}
	
	return ret;
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
         syncDate:(NSDate *)syncDate
{
    NSAssert([NSThread isMainThread] == NO, @"syncNotes MUST NOT be executed on the main thread");
	NSMutableArray *deletePool = [NSMutableArray array];    
	NSMutableArray *creationPool = [NSMutableArray array];
	
	webNotes = [webNotes sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceID ascending:YES]]];		
	NSArray *localNotesArray = [localNotes sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceID ascending:YES]]];
    localNotesArray = [self removeNewlyCreatedAndSavedAnnotations:localNotesArray];
    
	NSEnumerator *webEnumerator = [webNotes objectEnumerator];			  
	NSEnumerator *localEnumerator = [localNotesArray objectEnumerator];			  			  
    
	NSDictionary *webItem = [webEnumerator nextObject];
	SCHNote *localItem = [localEnumerator nextObject];
	
	while (webItem != nil || localItem != nil) {		
		if (webItem == nil) {
			break;
		}
		
		if (localItem == nil) {
			while (webItem != nil) {
                if ([self shouldCreate:webItem] == YES) {
                    [creationPool addObject:webItem];
                }
				webItem = [webEnumerator nextObject];
			} 
			break;			
		}
		
		id webItemID = [self makeNullNil:[webItem valueForKey:kSCHLibreAccessWebServiceID]];
		id localItemID = [localItem valueForKey:kSCHLibreAccessWebServiceID];
		
        if (webItemID == nil || [self annotationIDIsValid:webItemID] == NO) {
            webItem = nil;
        } else if (localItemID == nil) {
            localItem = nil;            
        } else {        
            switch ([webItemID compare:localItemID]) {
                case NSOrderedSame:
                    if ([self shouldDelete:webItem] == YES) {
                        [deletePool addObject:localItem];
                    } else {
                        [self syncNote:webItem withNote:localItem];
                        [self backgroundSave:YES];
                    }
                    webItem = nil;
                    localItem = nil;
                    break;
                case NSOrderedAscending:
                    if ([self shouldCreate:webItem] == YES) {
                        [creationPool addObject:webItem];
                    }
                    webItem = nil;
                    break;
                case NSOrderedDescending:
                    localItem = nil;
                    break;			
            }		
        }
		
		if (webItem == nil) {
			webItem = [webEnumerator nextObject];
		}
		if (localItem == nil) {
			localItem = [localEnumerator nextObject];
		}		
	}

    for (SCHNote *noteItem in deletePool) {
        [self.backgroundThreadManagedObjectContext deleteObject:noteItem];
        [self backgroundSave:YES];
    }                

	for (NSDictionary *webItem in creationPool) {
        SCHNote *newNote = [self note:webItem];
        if (newNote != nil) {
            [privateAnnotations addNotesObject:newNote];
            [self backgroundSave:YES];
        }
	}
    
    SCHAppContentProfileItem *appContentProfileItem = [[privateAnnotations.AnnotationsContentItem.AnnotationsItem profileItem] 
                                                       appContentProfileItemForBookIdentifier:[privateAnnotations.AnnotationsContentItem bookIdentifier]];
    if (appContentProfileItem != nil) {
        appContentProfileItem.LastNoteAnnotationSync = syncDate;
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
	id annotationID = [self makeNullNil:[note valueForKey:kSCHLibreAccessWebServiceID]];
    
	if (note != nil && [self annotationIDIsValid:annotationID] == YES) {
		ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHNote 
                                            inManagedObjectContext:self.backgroundThreadManagedObjectContext];
		
		ret.LastModified = [self makeNullNil:[note objectForKey:kSCHLibreAccessWebServiceLastModified]];
        ret.State = [NSNumber numberWithStatus:kSCHStatusUnmodified];
        
		ret.ID = annotationID;
		ret.Version = [self makeNullNil:[note objectForKey:kSCHLibreAccessWebServiceVersion]];
		
		ret.Color = [self makeNullNil:[note objectForKey:kSCHLibreAccessWebServiceColor]];
		ret.Value = [self makeNullNil:[note objectForKey:kSCHLibreAccessWebServiceValue]];
		ret.Location = [self locationGraphics:[note objectForKey:kSCHLibreAccessWebServiceLocation]];
	}
	
	return ret;
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
             syncDate:(NSDate *)syncDate
{
    NSAssert([NSThread isMainThread] == NO, @"syncBookmarks MUST NOT be executed on the main thread");
	NSMutableArray *deletePool = [NSMutableArray array];
	NSMutableArray *creationPool = [NSMutableArray array];
	
	webBookmarks = [webBookmarks sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceID ascending:YES]]];		
	NSArray *localBookmarksArray = [localBookmarks sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceID ascending:YES]]];
    localBookmarksArray = [self removeNewlyCreatedAndSavedAnnotations:localBookmarksArray];
    
	NSEnumerator *webEnumerator = [webBookmarks objectEnumerator];			  
	NSEnumerator *localEnumerator = [localBookmarksArray objectEnumerator];			  			  
    
	NSDictionary *webItem = [webEnumerator nextObject];
	SCHBookmark *localItem = [localEnumerator nextObject];
	
	while (webItem != nil || localItem != nil) {		            
        if (webItem == nil) {
			break;
		}
		
		if (localItem == nil) {
			while (webItem != nil) {
                if ([self shouldCreate:webItem] == YES) {
                    [creationPool addObject:webItem];
                }
				webItem = [webEnumerator nextObject];
			} 
			break;			
		}
		
		id webItemID = [self makeNullNil:[webItem valueForKey:kSCHLibreAccessWebServiceID]];
		id localItemID = [localItem valueForKey:kSCHLibreAccessWebServiceID];
		
        if (webItemID == nil || [self annotationIDIsValid:webItemID] == NO) {
            webItem = nil;
        } else if (localItemID == nil) {
            localItem = nil;
        } else {
            switch ([webItemID compare:localItemID]) {
                case NSOrderedSame:
                    if ([self shouldDelete:webItem] == YES) {
                        [deletePool addObject:localItem];
                    } else {
                        [self syncBookmark:webItem withBookmark:localItem];
                        [self backgroundSave:YES];
                    }
                    webItem = nil;
                    localItem = nil;
                    break;
                case NSOrderedAscending:
                    if ([self shouldCreate:webItem] == YES) {
                        [creationPool addObject:webItem];
                    }
                    webItem = nil;
                    break;
                case NSOrderedDescending:
                    localItem = nil;
                    break;			
            }		
        }
		
		if (webItem == nil) {
			webItem = [webEnumerator nextObject];
		}
		if (localItem == nil) {
			localItem = [localEnumerator nextObject];
		}		
	}
    
    for (SCHBookmark *bookmarkItem in deletePool) {
        [self.backgroundThreadManagedObjectContext deleteObject:bookmarkItem];
        [self backgroundSave:YES];
    }                

	for (NSDictionary *webItem in creationPool) {
        SCHBookmark *newBookmark = [self bookmark:webItem];
        if (newBookmark != nil) {
            [privateAnnotations addBookmarksObject:newBookmark];
            [self backgroundSave:YES];
        }
	}
	
    SCHAppContentProfileItem *appContentProfileItem = [[privateAnnotations.AnnotationsContentItem.AnnotationsItem profileItem] 
                                                       appContentProfileItemForBookIdentifier:[privateAnnotations.AnnotationsContentItem bookIdentifier]];
    if (appContentProfileItem != nil) {
        appContentProfileItem.LastBookmarkAnnotationSync = syncDate;
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
	id annotationID = [self makeNullNil:[bookmark valueForKey:kSCHLibreAccessWebServiceID]];
    
	if (bookmark != nil && [self annotationIDIsValid:annotationID] == YES) {
		ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHBookmark 
                                            inManagedObjectContext:self.backgroundThreadManagedObjectContext];
		
		ret.LastModified = [self makeNullNil:[bookmark objectForKey:kSCHLibreAccessWebServiceLastModified]];
        ret.State = [NSNumber numberWithStatus:kSCHStatusUnmodified];
        
		ret.ID = annotationID;
		ret.Version = [self makeNullNil:[bookmark objectForKey:kSCHLibreAccessWebServiceVersion]];
		
		ret.Disabled = [self makeNullNil:[bookmark objectForKey:kSCHLibreAccessWebServiceDisabled]];
		ret.Text = [self makeNullNil:[bookmark objectForKey:kSCHLibreAccessWebServiceText]];
		ret.Location = [self locationBookmark:[bookmark objectForKey:kSCHLibreAccessWebServiceLocation]];
	}
	
	return ret;
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

- (void)syncRating:(NSDictionary *)webRating withRating:(SCHRating *)localRating
{
    if (webRating != nil) {
        localRating.averageRating = [self makeNullNil:[webRating objectForKey:kSCHLibreAccessWebServiceAverageRating]];
        localRating.rating = [self makeNullNil:[webRating objectForKey:kSCHLibreAccessWebServiceRating]];
        
        localRating.LastModified = [self makeNullNil:[webRating objectForKey:kSCHLibreAccessWebServiceLastModified]];
        localRating.State = [NSNumber numberWithStatus:kSCHStatusSyncUpdate];				    
    }
}

- (SCHRating *)rating:(NSDictionary *)rating
{
    NSAssert([NSThread isMainThread] == NO, @"rating MUST NOT be executed on the main thread");
	SCHRating *ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHRating
                                                     inManagedObjectContext:self.backgroundThreadManagedObjectContext];
    
	if (rating != nil) {				
		ret.averageRating = [self makeNullNil:[rating objectForKey:kSCHLibreAccessWebServiceAverageRating]];
		ret.rating = [self makeNullNil:[rating objectForKey:kSCHLibreAccessWebServiceRating]];
        
		ret.LastModified = [self makeNullNil:[rating objectForKey:kSCHLibreAccessWebServiceLastModified]];
		ret.State = [NSNumber numberWithStatus:kSCHStatusUnmodified];        
	} else {
        [ret setInitialValues];
    }
	
	return(ret);
}

- (BOOL)shouldCreate:(NSDictionary *)webItem
{
    BOOL ret = NO;
    NSNumber *saveAction = [self makeNullNil:[webItem valueForKey:kSCHLibreAccessWebServiceAction]];
    
    if ([saveAction saveActionValue] != kSCHSaveActionsRemove) {
        ret = YES;
    }
    
    return ret;
}

- (BOOL)shouldDelete:(NSDictionary *)webItem
{
    BOOL ret = NO;
    NSNumber *saveAction = [self makeNullNil:[webItem valueForKey:kSCHLibreAccessWebServiceAction]];
    
    if ([saveAction saveActionValue] == kSCHSaveActionsRemove) {                    
        ret = YES;
    }
    
    return ret;
}

- (void)backgroundSave:(BOOL)batch
{
    NSAssert([NSThread isMainThread] == NO, @"backgroundSave MUST NOT be executed on the main thread");

	NSError *error = nil;
	static NSUInteger batchCount = 0;
    
    if (batch == NO || ++batchCount > 250) {
        batchCount = 0;
        if ([self.backgroundThreadManagedObjectContext hasChanges] == YES &&
            ![self.backgroundThreadManagedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        } 
    }
}

- (NSArray *)removeNewlyCreatedAndSavedAnnotations:(NSArray *)annotationArray
{
    NSAssert([NSThread isMainThread] == NO, @"removeNewlyCreatedAndSavedAnnotations MUST NOT be executed on the main thread");
    NSMutableArray *ret = nil;
    
    if (self.lastSyncSaveCalled == nil) {
        return annotationArray;
    } else {
        ret = [NSMutableArray arrayWithCapacity:[annotationArray count]];
        
        [annotationArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            SCHStatus status = [[obj State] statusValue];
            NSDate *lastModified = [obj LastModified];
            if ((status == kSCHStatusCreated || status == kSCHStatusDeleted) &&
                [lastModified earlierDate:self.lastSyncSaveCalled] == lastModified) {
                [self.backgroundThreadManagedObjectContext deleteObject:obj];
            } else {
                [ret addObject:obj];
            }
        }];
        
        [self backgroundSave:YES];
    }
    
    return ret;
}
        
@end
