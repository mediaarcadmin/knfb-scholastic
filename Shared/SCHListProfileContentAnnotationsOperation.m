//
//  SCHListProfileContentAnnotationsOperation.m
//  Scholastic
//
//  Created by John Eddie on 19/06/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHListProfileContentAnnotationsOperation.h"

#import "SCHAnnotationSyncComponent.h"
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
#import "SCHMakeNullNil.h"

@interface SCHListProfileContentAnnotationsOperation ()

- (void)syncProfileContentAnnotations:(NSDictionary *)profileContentAnnotationList 
                         canSyncNotes:(BOOL)canSyncNotes
                        canSyncRating:(BOOL)canSyncRating
                             syncDate:(NSDate *)syncDate;
- (NSArray *)localAnnotationsItemForProfile:(NSNumber *)profileID;
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
- (NSArray *)removeNewlyCreatedAndSavedAnnotations:(NSArray *)annotationArray;

@end

@implementation SCHListProfileContentAnnotationsOperation

@synthesize profileID;

- (void)main
{
    @try {
        BOOL canSyncNotes = [[SCHAppStateManager sharedAppStateManager] canSyncNotes];
        BOOL canSyncRating = [[SCHAppStateManager sharedAppStateManager] isCOPPACompliant];
        NSDate *syncDate = [self.userInfo objectForKey:@"serverDate"];
        
        // if we don't have a serverDate from the request then use the persisted server date
        if (syncDate == nil || syncDate == (id)[NSNull null]) {
            syncDate = [NSDate serverDate];
        }
        
        [self syncProfileContentAnnotations:[self.result objectForKey:kSCHLibreAccessWebServiceListProfileContentAnnotations] 
                               canSyncNotes:canSyncNotes
                              canSyncRating:canSyncRating
                                   syncDate:syncDate];	            
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.isCancelled == NO) {
                [(SCHAnnotationSyncComponent *)self.syncComponent syncProfileContentAnnotationsCompleted:self.profileID 
                                                 usingMethod:kSCHLibreAccessWebServiceListProfileContentAnnotations
                                                    userInfo:self.userInfo];
            }
        });                
    }
    @catch (NSException *exception) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.isCancelled == NO) {
                NSDictionary *notificationUserInfo = [NSDictionary dictionaryWithObject:(self.profileID == nil ? (id)[NSNull null] : self.profileID)
                                                                                 forKey:SCHAnnotationSyncComponentProfileIDs];            
                NSError *error = [NSError errorWithDomain:kBITAPIErrorDomain 
                                                     code:kBITAPIExceptionError 
                                                 userInfo:[NSDictionary dictionaryWithObject:[exception reason]
                                                                                      forKey:NSLocalizedDescriptionKey]];
                
                [self.syncComponent completeWithFailureMethod:kSCHLibreAccessWebServiceSaveProfileContentAnnotations 
                                                        error:error 
                                                  requestInfo:nil 
                                                       result:self.result 
                                             notificationName:SCHAnnotationSyncComponentDidFailNotification
                                         notificationUserInfo:notificationUserInfo];
            }
        });   
    }
}

- (void)syncProfileContentAnnotations:(NSDictionary *)profileContentAnnotationList 
                         canSyncNotes:(BOOL)canSyncNotes
                        canSyncRating:(BOOL)canSyncRating
                             syncDate:(NSDate *)syncDate
{
	NSDictionary *annotationsList = makeNullNil([profileContentAnnotationList 
                                                       objectForKey:kSCHLibreAccessWebServiceAnnotationsList]);
	
    // uncomment if we require to use this info
    //	NSDictionary *itemsCount = makeNullNil([profileContentAnnotationList objectForKey:kSCHLibreAccessWebServiceItemsCount]);
    //	NSNumber *found = makeNullNil([itemsCount objectForKey:kSCHLibreAccessWebServiceFound]);
    //	NSNumber *returned = makeNullNil([itemsCount objectForKey:kSCHLibreAccessWebServiceReturned]);	
    
    for (NSDictionary *annotationsItem in annotationsList) {
        NSNumber *annotationProfileID = [annotationsItem objectForKey:kSCHLibreAccessWebServiceProfileID];
        NSArray *localAnnotationsItems = [self localAnnotationsItemForProfile:annotationProfileID];
        
        if ([localAnnotationsItems count] > 0) {
            // sync me baby
            NSArray *annotationsContentList = makeNullNil([annotationsItem objectForKey:kSCHLibreAccessWebServiceAnnotationsContentList]);
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
            newAnnotationsItem.ProfileID = annotationProfileID;
            for (NSDictionary *annotationsContentItem in [annotationsItem objectForKey:kSCHLibreAccessWebServiceAnnotationsContentList]) {
                [newAnnotationsItem addAnnotationsContentItemObject:[self annotationsContentItem:annotationsContentItem]];
            }
        }
    }
    
	[self saveWithManagedObjectContext:self.backgroundThreadManagedObjectContext];
}

- (NSArray *)localAnnotationsItemForProfile:(NSNumber *)profileID
{
    NSArray *ret = nil;
    if (self.profileID != nil) {
        NSError *error = nil;
        NSEntityDescription *entityDescription = [NSEntityDescription 
                                                  entityForName:kSCHAnnotationsItem
                                                  inManagedObjectContext:self.backgroundThreadManagedObjectContext];
        
        NSFetchRequest *fetchRequest = [entityDescription.managedObjectModel 
                                        fetchRequestFromTemplateWithName:kSCHAnnotationsItemfetchAnnotationItemForProfile 
                                        substitutionVariables:[NSDictionary 
                                                               dictionaryWithObject:self.profileID 
                                                               forKey:kSCHAnnotationsItemPROFILE_ID]];
        
        ret = [self.backgroundThreadManagedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (ret == nil) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }
    
	return ret;
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
        }
    }
    
    [self saveWithManagedObjectContext:self.backgroundThreadManagedObjectContext];
}

- (void)syncAnnotationsContentItem:(NSDictionary *)webAnnotationsContentItem 
        withAnnotationsContentItem:(SCHAnnotationsContentItem *)localAnnotationsContentItem
                      canSyncNotes:(BOOL)canSyncNotes
                     canSyncRating:(BOOL)canSyncRating
                          syncDate:(NSDate *)syncDate
{
    if (webAnnotationsContentItem != nil) {
        localAnnotationsContentItem.DRMQualifier = makeNullNil([webAnnotationsContentItem objectForKey:kSCHLibreAccessWebServiceDRMQualifier]);
        localAnnotationsContentItem.ContentIdentifierType = makeNullNil([webAnnotationsContentItem objectForKey:kSCHLibreAccessWebServiceContentIdentifierType]);
        localAnnotationsContentItem.ContentIdentifier = makeNullNil([webAnnotationsContentItem objectForKey:kSCHLibreAccessWebServiceContentIdentifier]);
        
        localAnnotationsContentItem.Format = makeNullNil([webAnnotationsContentItem objectForKey:kSCHLibreAccessWebServiceFormat]);
        
        NSDictionary *privateAnnotations = makeNullNil([webAnnotationsContentItem objectForKey:kSCHLibreAccessWebServicePrivateAnnotations]);
        
        if (privateAnnotations != nil) {
            NSArray *annotation = makeNullNil([privateAnnotations objectForKey:kSCHLibreAccessWebServiceHighlights]);
            if (annotation != nil) {
                [self syncHighlights:annotation
                      withHighlights:localAnnotationsContentItem.PrivateAnnotations.Highlights 
                          insertInto:localAnnotationsContentItem.PrivateAnnotations
                            syncDate:syncDate];
            }
            if (canSyncNotes == YES) {
                annotation = makeNullNil([privateAnnotations objectForKey:kSCHLibreAccessWebServiceNotes]);
                if (annotation != nil) {        
                    [self syncNotes:annotation
                          withNotes:localAnnotationsContentItem.PrivateAnnotations.Notes 
                         insertInto:localAnnotationsContentItem.PrivateAnnotations
                           syncDate:syncDate];
                }
            }
            annotation = makeNullNil([privateAnnotations objectForKey:kSCHLibreAccessWebServiceBookmarks]);
            if (annotation != nil) {                
                [self syncBookmarks:annotation
                      withBookmarks:localAnnotationsContentItem.PrivateAnnotations.Bookmarks 
                         insertInto:localAnnotationsContentItem.PrivateAnnotations
                           syncDate:syncDate];        
            }
            [self syncLastPage:makeNullNil([privateAnnotations objectForKey:kSCHLibreAccessWebServiceLastPage])
                  withLastPage:localAnnotationsContentItem.PrivateAnnotations.LastPage];
            if (canSyncRating == YES) {
                [self syncRating:makeNullNil([privateAnnotations objectForKey:kSCHLibreAccessWebServiceRating])
                      withRating:localAnnotationsContentItem.PrivateAnnotations.rating];            
            }
        }
    }
}

- (SCHAnnotationsContentItem *)annotationsContentItem:(NSDictionary *)annotationsContentItem
{
	SCHAnnotationsContentItem *ret = nil;
	SCHBookIdentifier *webBookIdentifier = [[SCHBookIdentifier alloc] initWithObject:annotationsContentItem];
    
	if (annotationsContentItem != nil && webBookIdentifier != nil) {
        ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHAnnotationsContentItem
                                            inManagedObjectContext:self.backgroundThreadManagedObjectContext];
        
		ret.DRMQualifier = webBookIdentifier.DRMQualifier;
		ret.ContentIdentifierType = makeNullNil([annotationsContentItem objectForKey:kSCHLibreAccessWebServiceContentIdentifierType]);
		ret.ContentIdentifier = webBookIdentifier.isbn;
		
		ret.Format = makeNullNil([annotationsContentItem objectForKey:kSCHLibreAccessWebServiceFormat]);
        ret.PrivateAnnotations = [self privateAnnotation:[annotationsContentItem objectForKey:kSCHLibreAccessWebServicePrivateAnnotations]];        
    }
	[webBookIdentifier release], webBookIdentifier = nil;
    
	return ret;
}

- (SCHPrivateAnnotations *)privateAnnotation:(NSDictionary *)privateAnnotation
{
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
		
		id webItemID = makeNullNil([webItem valueForKey:kSCHLibreAccessWebServiceID]);
		id localItemID = [localItem valueForKey:kSCHLibreAccessWebServiceID];
		
        if (webItemID == nil || [SCHAnnotation isValidAnnotationID:webItemID] == NO) {
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
    }                
    
	for (NSDictionary *webItem in creationPool) {
        SCHHighlight *newHighlight = [self highlight:webItem];
        if (newHighlight != nil) {
            [privateAnnotations addHighlightsObject:newHighlight];
        }
	}
    
    SCHAppContentProfileItem *appContentProfileItem = [[privateAnnotations.AnnotationsContentItem.AnnotationsItem profileItem] 
                                                       appContentProfileItemForBookIdentifier:[privateAnnotations.AnnotationsContentItem bookIdentifier]];
    if (appContentProfileItem != nil) {
        appContentProfileItem.LastHighlightAnnotationSync = syncDate;
    }
	
	[self saveWithManagedObjectContext:self.backgroundThreadManagedObjectContext];        
}

- (void)syncHighlight:(NSDictionary *)webHighlight
        withHighlight:(SCHHighlight *)localHighlight
{
    if ([localHighlight.State statusValue] == kSCHStatusUnmodified) {
        localHighlight.Color = makeNullNil([webHighlight objectForKey:kSCHLibreAccessWebServiceColor]);
        localHighlight.EndPage = makeNullNil([webHighlight objectForKey:kSCHLibreAccessWebServiceEndPage]);
        
        localHighlight.ID = makeNullNil([webHighlight objectForKey:kSCHLibreAccessWebServiceID]);
        localHighlight.Version = makeNullNil([webHighlight objectForKey:kSCHLibreAccessWebServiceVersion]);
        
        localHighlight.LastModified = makeNullNil([webHighlight objectForKey:kSCHLibreAccessWebServiceLastModified]);
        localHighlight.State = [NSNumber numberWithStatus:kSCHStatusSyncUpdate];				        
        
        [self syncLocationText:makeNullNil([webHighlight objectForKey:kSCHLibreAccessWebServiceLocation])
              withLocationText:localHighlight.Location];
    }
}

- (SCHHighlight *)highlight:(NSDictionary *)highlight
{
	SCHHighlight *ret = nil;
	id annotationID = makeNullNil([highlight valueForKey:kSCHLibreAccessWebServiceID]);
    
	if (highlight != nil && [SCHAnnotation isValidAnnotationID:annotationID] == YES) {
		ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHHighlight 
                                            inManagedObjectContext:self.backgroundThreadManagedObjectContext];
		
		ret.LastModified = makeNullNil([highlight objectForKey:kSCHLibreAccessWebServiceLastModified]);
        ret.State = [NSNumber numberWithStatus:kSCHStatusUnmodified];
        
		ret.ID = annotationID;
		ret.Version = makeNullNil([highlight objectForKey:kSCHLibreAccessWebServiceVersion]);
		
		ret.Color = makeNullNil([highlight objectForKey:kSCHLibreAccessWebServiceColor]);
		ret.EndPage = makeNullNil([highlight objectForKey:kSCHLibreAccessWebServiceEndPage]);
		ret.Location = [self locationText:[highlight objectForKey:kSCHLibreAccessWebServiceLocation]];
	}
	
	return ret;
}

- (void)syncLocationText:(NSDictionary *)webLocationText
        withLocationText:(SCHLocationText *)localLocationText
{
    if (webLocationText != nil) {
        localLocationText.Page = makeNullNil([webLocationText objectForKey:kSCHLibreAccessWebServicePage]);
        
        [self syncWordIndex:makeNullNil([webLocationText objectForKey:kSCHLibreAccessWebServiceWordIndex])
              withWordIndex:localLocationText.WordIndex];    
    }
}

- (SCHLocationText *)locationText:(NSDictionary *)locationText
{
	SCHLocationText *ret = ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHLocationText
                                                               inManagedObjectContext:self.backgroundThreadManagedObjectContext];
    
	if (locationText != nil) {
		ret.Page = makeNullNil([locationText objectForKey:kSCHLibreAccessWebServicePage]);
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
        localsyncWordIndex.Start = makeNullNil([websyncWordIndex objectForKey:kSCHLibreAccessWebServiceStart]);
        localsyncWordIndex.End = makeNullNil([websyncWordIndex objectForKey:kSCHLibreAccessWebServiceEnd]);
    }
}

- (SCHWordIndex *)wordIndex:(NSDictionary *)wordIndex
{
	SCHWordIndex *ret = ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHWordIndex
                                                            inManagedObjectContext:self.backgroundThreadManagedObjectContext];
    
	
	if (wordIndex != nil) {
		ret.Start = makeNullNil([wordIndex objectForKey:kSCHLibreAccessWebServiceStart]);
		ret.End = makeNullNil([wordIndex objectForKey:kSCHLibreAccessWebServiceEnd]);
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
		
		id webItemID = makeNullNil([webItem valueForKey:kSCHLibreAccessWebServiceID]);
		id localItemID = [localItem valueForKey:kSCHLibreAccessWebServiceID];
		
        if (webItemID == nil || [SCHAnnotation isValidAnnotationID:webItemID] == NO) {
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
    }                
    
	for (NSDictionary *webItem in creationPool) {
        SCHNote *newNote = [self note:webItem];
        if (newNote != nil) {
            [privateAnnotations addNotesObject:newNote];
        }
	}
    
    SCHAppContentProfileItem *appContentProfileItem = [[privateAnnotations.AnnotationsContentItem.AnnotationsItem profileItem] 
                                                       appContentProfileItemForBookIdentifier:[privateAnnotations.AnnotationsContentItem bookIdentifier]];
    if (appContentProfileItem != nil) {
        appContentProfileItem.LastNoteAnnotationSync = syncDate;
    }
	
	[self saveWithManagedObjectContext:self.backgroundThreadManagedObjectContext];        
}

- (void)syncNote:(NSDictionary *)webNote
        withNote:(SCHNote *)localNote
{
    if ([localNote.State statusValue] == kSCHStatusUnmodified) {
        localNote.Color = makeNullNil([webNote objectForKey:kSCHLibreAccessWebServiceColor]);
        localNote.Value = makeNullNil([webNote objectForKey:kSCHLibreAccessWebServiceValue]);
        
        localNote.ID = makeNullNil([webNote objectForKey:kSCHLibreAccessWebServiceID]);
        localNote.Version = makeNullNil([webNote objectForKey:kSCHLibreAccessWebServiceVersion]);
        
        localNote.LastModified = makeNullNil([webNote objectForKey:kSCHLibreAccessWebServiceLastModified]);
        localNote.State = [NSNumber numberWithStatus:kSCHStatusSyncUpdate];				        
        
        [self syncLocationGraphics:makeNullNil([webNote objectForKey:kSCHLibreAccessWebServiceLocation])
              withLocationGraphics:localNote.Location];
    }
}

- (SCHNote *)note:(NSDictionary *)note
{
	SCHNote *ret = nil;
	id annotationID = makeNullNil([note valueForKey:kSCHLibreAccessWebServiceID]);
    
	if (note != nil && [SCHAnnotation isValidAnnotationID:annotationID] == YES) {
		ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHNote 
                                            inManagedObjectContext:self.backgroundThreadManagedObjectContext];
		
		ret.LastModified = makeNullNil([note objectForKey:kSCHLibreAccessWebServiceLastModified]);
        ret.State = [NSNumber numberWithStatus:kSCHStatusUnmodified];
        
		ret.ID = annotationID;
		ret.Version = makeNullNil([note objectForKey:kSCHLibreAccessWebServiceVersion]);
		
		ret.Color = makeNullNil([note objectForKey:kSCHLibreAccessWebServiceColor]);
		ret.Value = makeNullNil([note objectForKey:kSCHLibreAccessWebServiceValue]);
		ret.Location = [self locationGraphics:[note objectForKey:kSCHLibreAccessWebServiceLocation]];
	}
	
	return ret;
}

- (void)syncLocationGraphics:(NSDictionary *)webLocationGraphics 
        withLocationGraphics:(SCHLocationGraphics *)localLocationGraphics
{
    if (webLocationGraphics != nil) {
        localLocationGraphics.Page = makeNullNil([webLocationGraphics objectForKey:kSCHLibreAccessWebServicePage]);
    }
}

- (SCHLocationGraphics *)locationGraphics:(NSDictionary *)locationGraphics
{
	SCHLocationGraphics *ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHLocationGraphics 
                                                             inManagedObjectContext:self.backgroundThreadManagedObjectContext];
    
	if (locationGraphics != nil) {		
		ret.Page = makeNullNil([locationGraphics objectForKey:kSCHLibreAccessWebServicePage]);
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
		
		id webItemID = makeNullNil([webItem valueForKey:kSCHLibreAccessWebServiceID]);
		id localItemID = [localItem valueForKey:kSCHLibreAccessWebServiceID];
		
        if (webItemID == nil || [SCHAnnotation isValidAnnotationID:webItemID] == NO) {
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
    }                
    
	for (NSDictionary *webItem in creationPool) {
        SCHBookmark *newBookmark = [self bookmark:webItem];
        if (newBookmark != nil) {
            [privateAnnotations addBookmarksObject:newBookmark];
        }
	}
	
    SCHAppContentProfileItem *appContentProfileItem = [[privateAnnotations.AnnotationsContentItem.AnnotationsItem profileItem] 
                                                       appContentProfileItemForBookIdentifier:[privateAnnotations.AnnotationsContentItem bookIdentifier]];
    if (appContentProfileItem != nil) {
        appContentProfileItem.LastBookmarkAnnotationSync = syncDate;
    }    
    
	[self saveWithManagedObjectContext:self.backgroundThreadManagedObjectContext];    
}

- (void)syncBookmark:(NSDictionary *)webBookmark 
        withBookmark:(SCHBookmark *)localBookmark
{
    if ([localBookmark.State statusValue] == kSCHStatusUnmodified) {
        localBookmark.Disabled = makeNullNil([webBookmark objectForKey:kSCHLibreAccessWebServiceDisabled]);
        localBookmark.Text = makeNullNil([webBookmark objectForKey:kSCHLibreAccessWebServiceText]);
        
        localBookmark.ID = makeNullNil([webBookmark objectForKey:kSCHLibreAccessWebServiceID]);
        localBookmark.Version = makeNullNil([webBookmark objectForKey:kSCHLibreAccessWebServiceVersion]);
        
        localBookmark.LastModified = makeNullNil([webBookmark objectForKey:kSCHLibreAccessWebServiceLastModified]);
        localBookmark.State = [NSNumber numberWithStatus:kSCHStatusSyncUpdate];				        
        
        [self syncLocationBookmark:makeNullNil([webBookmark objectForKey:kSCHLibreAccessWebServiceLocation])
              withLocationBookmark:localBookmark.Location];
    }
}

- (SCHBookmark *)bookmark:(NSDictionary *)bookmark
{
	SCHBookmark *ret = nil;
	id annotationID = makeNullNil([bookmark valueForKey:kSCHLibreAccessWebServiceID]);
    
	if (bookmark != nil && [SCHAnnotation isValidAnnotationID:annotationID] == YES) {
		ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHBookmark 
                                            inManagedObjectContext:self.backgroundThreadManagedObjectContext];
		
		ret.LastModified = makeNullNil([bookmark objectForKey:kSCHLibreAccessWebServiceLastModified]);
        ret.State = [NSNumber numberWithStatus:kSCHStatusUnmodified];
        
		ret.ID = annotationID;
		ret.Version = makeNullNil([bookmark objectForKey:kSCHLibreAccessWebServiceVersion]);
		
		ret.Disabled = makeNullNil([bookmark objectForKey:kSCHLibreAccessWebServiceDisabled]);
		ret.Text = makeNullNil([bookmark objectForKey:kSCHLibreAccessWebServiceText]);
		ret.Location = [self locationBookmark:[bookmark objectForKey:kSCHLibreAccessWebServiceLocation]];
	}
	
	return ret;
}

- (void)syncLocationBookmark:(NSDictionary *)webLocationBookmark 
        withLocationBookmark:(SCHLocationBookmark *)localLocationBookmark
{
    if (webLocationBookmark != nil) {
        localLocationBookmark.Page = makeNullNil([webLocationBookmark objectForKey:kSCHLibreAccessWebServicePage]);
    }
}

- (SCHLocationBookmark *)locationBookmark:(NSDictionary *)locationBookmark
{
	SCHLocationBookmark *ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHLocationBookmark 
                                                             inManagedObjectContext:self.backgroundThreadManagedObjectContext];
    
    if (locationBookmark != nil) {
		ret.Page = makeNullNil([locationBookmark objectForKey:kSCHLibreAccessWebServicePage]);
	} else {
        [ret setInitialValues];
    }
	
	return(ret);
}

- (void)syncLastPage:(NSDictionary *)webLastPage withLastPage:(SCHLastPage *)localLastPage
{
    if (webLastPage != nil) {
        localLastPage.LastPageLocation = makeNullNil([webLastPage objectForKey:kSCHLibreAccessWebServiceLastPageLocation]);
        localLastPage.Component = makeNullNil([webLastPage objectForKey:kSCHLibreAccessWebServiceComponent]);
        localLastPage.Percentage = makeNullNil([webLastPage objectForKey:kSCHLibreAccessWebServicePercentage]);
        
        localLastPage.LastModified = makeNullNil([webLastPage objectForKey:kSCHLibreAccessWebServiceLastModified]);
        localLastPage.State = [NSNumber numberWithStatus:kSCHStatusSyncUpdate];				    
    }
}

- (SCHLastPage *)lastPage:(NSDictionary *)lastPage
{
	SCHLastPage *ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHLastPage 
                                                     inManagedObjectContext:self.backgroundThreadManagedObjectContext];
    
	if (lastPage != nil) {				
		ret.LastPageLocation = makeNullNil([lastPage objectForKey:kSCHLibreAccessWebServiceLastPageLocation]);
		ret.Percentage = makeNullNil([lastPage objectForKey:kSCHLibreAccessWebServicePercentage]);
		ret.Component = makeNullNil([lastPage objectForKey:kSCHLibreAccessWebServiceComponent]);
        
		ret.LastModified = makeNullNil([lastPage objectForKey:kSCHLibreAccessWebServiceLastModified]);
		ret.State = [NSNumber numberWithStatus:kSCHStatusUnmodified];        
	} else {
        [ret setInitialValues];
    }
	
	return(ret);
}

- (void)syncRating:(NSDictionary *)webRating withRating:(SCHRating *)localRating
{
    if (webRating != nil) {
        localRating.averageRating = makeNullNil([webRating objectForKey:kSCHLibreAccessWebServiceAverageRating]);
        localRating.rating = makeNullNil([webRating objectForKey:kSCHLibreAccessWebServiceRating]);
        localRating.numVotes = makeNullNil([webRating objectForKey:kSCHLibreAccessWebServiceNumVotes]);
        
        localRating.LastModified = makeNullNil([webRating objectForKey:kSCHLibreAccessWebServiceLastModified]);
        localRating.State = [NSNumber numberWithStatus:kSCHStatusSyncUpdate];				    
    }
}

- (SCHRating *)rating:(NSDictionary *)rating
{
	SCHRating *ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHRating
                                                   inManagedObjectContext:self.backgroundThreadManagedObjectContext];
    
	if (rating != nil) {				
		ret.averageRating = makeNullNil([rating objectForKey:kSCHLibreAccessWebServiceAverageRating]);
		ret.rating = makeNullNil([rating objectForKey:kSCHLibreAccessWebServiceRating]);
        ret.numVotes = makeNullNil([rating objectForKey:kSCHLibreAccessWebServiceNumVotes]);
        
		ret.LastModified = makeNullNil([rating objectForKey:kSCHLibreAccessWebServiceLastModified]);
		ret.State = [NSNumber numberWithStatus:kSCHStatusUnmodified];        
	} else {
        [ret setInitialValues];
    }
	
	return(ret);
}

- (BOOL)shouldCreate:(NSDictionary *)webItem
{
    BOOL ret = NO;
    NSNumber *saveAction = makeNullNil([webItem valueForKey:kSCHLibreAccessWebServiceAction]);
    
    if ([saveAction saveActionValue] != kSCHSaveActionsRemove) {
        ret = YES;
    }
    
    return ret;
}

- (BOOL)shouldDelete:(NSDictionary *)webItem
{
    BOOL ret = NO;
    NSNumber *saveAction = makeNullNil([webItem valueForKey:kSCHLibreAccessWebServiceAction]);
    
    if ([saveAction saveActionValue] == kSCHSaveActionsRemove) {                    
        ret = YES;
    }
    
    return ret;
}

- (NSArray *)removeNewlyCreatedAndSavedAnnotations:(NSArray *)annotationArray
{
    NSMutableArray *ret = nil;
    SCHAnnotationSyncComponent *annotationSyncComponent = (SCHAnnotationSyncComponent *)self.syncComponent;
    
    if (annotationSyncComponent.lastSyncSaveCalled == nil) {
        return annotationArray;
    } else {
        ret = [NSMutableArray arrayWithCapacity:[annotationArray count]];
        
        [annotationArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            SCHStatus status = [[obj State] statusValue];
            NSDate *lastModified = [obj LastModified];
            if ((status == kSCHStatusCreated || status == kSCHStatusDeleted) &&
                [lastModified earlierDate:annotationSyncComponent.lastSyncSaveCalled] == lastModified) {
                [self.backgroundThreadManagedObjectContext deleteObject:obj];
            } else {
                [ret addObject:obj];
            }
        }];
        
        [self saveWithManagedObjectContext:self.backgroundThreadManagedObjectContext];
    }
    
    return ret;
}

@end
