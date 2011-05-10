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

#import "SCHLibreAccessWebService.h"
#import "SCHAnnotationsList.h"
#import "SCHAnnotationsContentItem.h"
#import "SCHPrivateAnnotations.h"
#import "SCHLocationGraphics.h"
#import "SCHHighlight.h"
#import "SCHNote.h"
#import "SCHCoords.h"
#import "SCHBookmark.h"
#import "SCHLocationBookmark.h"
#import "SCHLastPage.h"
#import "SCHFavorite.h"
#import "SCHAppState.h"

@interface SCHAnnotationSyncComponent ()

- (void)setSyncDate:(NSDate *)date;
- (void)syncProfileContentAnnotations:(NSDictionary *)profileContentAnnotationList;
- (SCHAnnotationsContentItem *)annotationsContentItem:(NSDictionary *)annotationsContentItem;
- (SCHPrivateAnnotations *)privateAnnotation:(NSDictionary *)privateAnnotation;
- (SCHHighlight *)highlight:(NSDictionary *)highlight;
- (SCHNote *)note:(NSDictionary *)note;
- (SCHLocationGraphics *)locationGraphics:(NSDictionary *)locationGraphics;
- (SCHCoords *)coords:(NSDictionary *)coords;
- (SCHBookmark *)bookmark:(NSDictionary *)bookmark;
- (SCHLocationBookmark *)locationBookmark:(NSDictionary *)locationBookmark;
- (SCHLastPage *)lastPage:(NSDictionary *)lastPage;
- (SCHFavorite *)favorite:(NSDictionary *)favorite;

@property (retain, nonatomic) NSMutableDictionary *annotations;

@end

@implementation SCHAnnotationSyncComponent

@synthesize annotations;

- (id)init
{
	self = [super init];
	if (self != nil) {
		self.annotations = [NSMutableDictionary dictionary];		
	}
	
	return(self);
}

- (void)dealloc
{
	self.annotations = nil;
	
	[super dealloc];
}

- (void)addProfile:(NSNumber *)profileID withBooks:(NSArray *)books
{
	if (profileID != nil && books != nil && [books count] > 0) {
		[self.annotations setObject:books forKey:profileID];		
	}
}

- (BOOL)haveProfiles
{
	return([self.annotations count ] > 0);
}

- (BOOL)synchronize
{
	BOOL ret = YES;
	
	if (self.isSynchronizing == NO && [self haveProfiles] == YES) {
		NSNumber *profileID = [[self.annotations allKeys] objectAtIndex:0];
		NSArray *books = [self.annotations objectForKey:profileID];
		
		self.backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{ 
			self.isSynchronizing = NO;
			self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
		}];
		
		self.isSynchronizing = [self.libreAccessWebService listProfileContentAnnotations:books forProfile:profileID];
		if (self.isSynchronizing == NO) {
			[[SCHAuthenticationManager sharedAuthenticationManager] authenticate];				
			ret = NO;
		}
		[self.annotations removeObjectForKey:profileID];
	}
	
	return(ret);
}

- (void)clear
{
	NSError *error = nil;
	
	if (![self.managedObjectContext BITemptyEntity:kSCHAnnotationsList error:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}	
}

- (NSDate *)lastSyncDate
{
    NSDate *ret = nil;
    
    NSEntityDescription *entityDescription = [NSEntityDescription 
                                              entityForName:kSCHAppState
                                              inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *fetchRequest = [entityDescription.managedObjectModel 
                                    fetchRequestTemplateForName:kSCHAppStatefetchAppState];
    
    NSArray *state = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];	
    
    if ([state count] > 0) {
        ret = [self makeNullNil:[[state objectAtIndex:0] LastAnnotationSync]];
    }
    
    return(ret);
}

- (void)setSyncDate:(NSDate *)date
{
    SCHAppState *appState = nil;
    
    NSEntityDescription *entityDescription = [NSEntityDescription 
                                              entityForName:kSCHAppState
                                              inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *fetchRequest = [entityDescription.managedObjectModel 
                                    fetchRequestTemplateForName:kSCHAppStatefetchAppState];
    fetchRequest.returnsObjectsAsFaults = NO;
    
    NSArray *state = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];	
    
    if ([state count] > 0) {
        appState = [state objectAtIndex:0];
    } else {
        appState = [NSEntityDescription insertNewObjectForEntityForName:kSCHAppState inManagedObjectContext:self.managedObjectContext];
    }
    
    appState.LastAnnotationSync = date;
    
    [self save];
}

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result
{	
	[self syncProfileContentAnnotations:[result objectForKey:kSCHLibreAccessWebServiceListProfileContentAnnotations]];	

    if ([self.annotations count] < 1) {
        [self setSyncDate:[NSDate date]];
        [[NSNotificationCenter defaultCenter] postNotificationName:kSCHAnnotationSyncComponentComplete object:self];
    }
     
    [super method:method didCompleteWithResult:nil];	
}

- (void)syncProfileContentAnnotations:(NSDictionary *)profileContentAnnotationList
{
	NSError *error = nil;
	NSDictionary *annotationsList = [self makeNullNil:[profileContentAnnotationList objectForKey:kSCHLibreAccessWebServiceAnnotationsList]];    
	
    // uncomment if we require to use this info
    //	NSDictionary *itemsCount = [self makeNullNil:[profileContentAnnotationList objectForKey:kSCHLibreAccessWebServiceItemsCount]];	
    //	NSNumber *found = [self makeNullNil:[itemsCount objectForKey:kSCHLibreAccessWebServiceFound]];
    //	NSNumber *returned = [self makeNullNil:[itemsCount objectForKey:kSCHLibreAccessWebServiceReturned]];	
    
    for (NSDictionary *annotationsItem in annotationsList) {
        NSNumber *profileID = [annotationsItem objectForKey:kSCHLibreAccessWebServiceProfileID];
        NSArray *localAnnotationList = [self localAnnotationsListForProfile:profileID];
        
        if ([localAnnotationList count] < 1) {
            SCHAnnotationsList *newAnnotationsList = [NSEntityDescription insertNewObjectForEntityForName:kSCHAnnotationsList inManagedObjectContext:self.managedObjectContext];
            for (NSDictionary *annotation in [annotationsItem objectForKey:kSCHLibreAccessWebServiceAnnotationsContentList]) {
                [newAnnotationsList addAnnotationContentItemObject:[self annotationsContentItem:annotation]];
            }
            newAnnotationsList.ProfileID = [annotationsItem objectForKey:kSCHLibreAccessWebServiceProfileID];
        } else {
            // sync me baby
        }
    }
    
	// Save the context.
	if (![self.managedObjectContext save:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}	    
}
- (NSArray *)localAnnotationsListForProfile:(NSNumber *)profileID
{
    NSEntityDescription *entityDescription = [NSEntityDescription 
                                              entityForName:kSCHAnnotationsList
                                              inManagedObjectContext:self.managedObjectContext];
    
    NSFetchRequest *fetchRequest = [entityDescription.managedObjectModel 
                                    fetchRequestFromTemplateWithName:kSCHAnnotationsListfetchAnnotationListForProfile 
                                    substitutionVariables:[NSDictionary 
                                                           dictionaryWithObject:profileID 
                                                           forKey:kSCHAnnotationsListPROFILE_ID]];
	
	return([self.managedObjectContext executeFetchRequest:fetchRequest error:nil]);
}

- (SCHPrivateAnnotations *)localPrivateAnnotationsForProfile:(NSNumber *)profileID
{
    SCHPrivateAnnotations *ret = nil;
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	[fetchRequest setEntity:[NSEntityDescription entityForName:kSCHPrivateAnnotations inManagedObjectContext:self.managedObjectContext]];	
	
	NSArray *p = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];	
	
    if ([p count] > 0) {
        ret = [p objectAtIndex:0];
    }
    
	[fetchRequest release], fetchRequest = nil;
	
	return(ret);
}

- (SCHAnnotationsContentItem *)annotationsContentItem:(NSDictionary *)annotationsContentItem
{
	SCHAnnotationsContentItem *ret = nil;
	
	if (annotationsContentItem != nil) {
		ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHAnnotationsContentItem inManagedObjectContext:self.managedObjectContext];
		
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
	SCHPrivateAnnotations *ret = nil;
	
	if (privateAnnotation != nil) {
		ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHPrivateAnnotations inManagedObjectContext:self.managedObjectContext];
		
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

// TODO: sync
- (SCHHighlight *)highlight:(NSDictionary *)highlight
{
	SCHHighlight *ret = nil;
	
	if (highlight != nil) {
		ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHHighlight inManagedObjectContext:self.managedObjectContext];
		
		ret.LastModified = [self makeNullNil:[highlight objectForKey:kSCHLibreAccessWebServiceLastModified]];
		
		ret.ID = [self makeNullNil:[highlight objectForKey:kSCHLibreAccessWebServiceID]];
		ret.Version = [self makeNullNil:[highlight objectForKey:kSCHLibreAccessWebServiceVersion]];
		
		ret.Color = [self makeNullNil:[highlight objectForKey:kSCHLibreAccessWebServiceColor]];
		ret.EndPage = [self makeNullNil:[highlight objectForKey:kSCHLibreAccessWebServiceEndPage]];
		ret.LocationText = [self makeNullNil:[highlight objectForKey:kSCHLibreAccessWebServiceLocationText]];
	}
	
	return(ret);
}

// TODO: sync
- (SCHNote *)note:(NSDictionary *)note
{
	SCHNote *ret = nil;
	
	if (note != nil) {
		ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHNote inManagedObjectContext:self.managedObjectContext];
		
		ret.LastModified = [self makeNullNil:[note objectForKey:kSCHLibreAccessWebServiceLastModified]];
		
		ret.ID = [self makeNullNil:[note objectForKey:kSCHLibreAccessWebServiceID]];
		ret.Version = [self makeNullNil:[note objectForKey:kSCHLibreAccessWebServiceVersion]];
		
		ret.Color = [self makeNullNil:[note objectForKey:kSCHLibreAccessWebServiceColor]];
		ret.Value = [self makeNullNil:[note objectForKey:kSCHLibreAccessWebServiceValue]];
		ret.LocationGraphics = [self locationGraphics:[note objectForKey:kSCHLibreAccessWebServiceLocationGraphics]];
	}
	
	return(ret);
}

- (SCHLocationGraphics *)locationGraphics:(NSDictionary *)locationGraphics
{
	SCHLocationGraphics *ret = nil;
	
	if (locationGraphics != nil) {
		ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHLocationGraphics inManagedObjectContext:self.managedObjectContext];
		
		ret.Page = [self makeNullNil:[locationGraphics objectForKey:kSCHLibreAccessWebServicePage]];
		ret.Coords = [self coords:[locationGraphics objectForKey:kSCHLibreAccessWebServiceWordIndex]];
		ret.WordIndex = [self makeNullNil:[locationGraphics objectForKey:kSCHLibreAccessWebServiceWordIndex]];		
	}
	
	return(ret);
}

- (SCHCoords *)coords:(NSDictionary *)coords
{
	SCHCoords *ret = nil;
	
	if (coords != nil) {
		ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHCoords inManagedObjectContext:self.managedObjectContext];
		
		ret.X = [self makeNullNil:[coords objectForKey:kSCHLibreAccessWebServiceX]];
		ret.Y = [self makeNullNil:[coords objectForKey:kSCHLibreAccessWebServiceY]];		
	}
	
	return(ret);
}

// TODO: sync
- (SCHBookmark *)bookmark:(NSDictionary *)bookmark
{
	SCHBookmark *ret = nil;
	
	if (bookmark != nil) {
		ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHBookmark inManagedObjectContext:self.managedObjectContext];
		
		ret.LastModified = [self makeNullNil:[bookmark objectForKey:kSCHLibreAccessWebServiceLastModified]];
		
		ret.ID = [self makeNullNil:[bookmark objectForKey:kSCHLibreAccessWebServiceID]];
		ret.Version = [self makeNullNil:[bookmark objectForKey:kSCHLibreAccessWebServiceVersion]];
		
		ret.Disabled = [self makeNullNil:[bookmark objectForKey:kSCHLibreAccessWebServiceDisabled]];
		ret.Text = [self makeNullNil:[bookmark objectForKey:kSCHLibreAccessWebServiceText]];
		ret.LocationBookmark = [self locationBookmark:[bookmark objectForKey:kSCHLibreAccessWebServicePage]];
	}
	
	return(ret);
}

- (SCHLocationBookmark *)locationBookmark:(NSDictionary *)locationBookmark
{
	SCHLocationBookmark *ret = nil;
	
	if (locationBookmark != nil) {
		ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHLocationBookmark inManagedObjectContext:self.managedObjectContext];
		
		ret.Page = [self makeNullNil:[locationBookmark objectForKey:kSCHLibreAccessWebServicePage]];
	}
	
	return(ret);
}

// TODO: sync
- (SCHLastPage *)lastPage:(NSDictionary *)lastPage
{
	SCHLastPage *ret = nil;
	
	if (lastPage != nil) {
		ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHLastPage inManagedObjectContext:self.managedObjectContext];
		
		ret.LastModified = [self makeNullNil:[lastPage objectForKey:kSCHLibreAccessWebServiceLastModified]];
		
		ret.LastPageLocation = [self makeNullNil:[lastPage objectForKey:kSCHLibreAccessWebServiceLastPageLocation]];
		ret.Percentage = [self makeNullNil:[lastPage objectForKey:kSCHLibreAccessWebServicePercentage]];
		ret.Component = [self makeNullNil:[lastPage objectForKey:kSCHLibreAccessWebServiceComponent]];
	}
	
	return(ret);
}

// TODO: sync
- (SCHFavorite *)favorite:(NSDictionary *)favorite
{
	SCHFavorite *ret = nil;
	
	if (favorite != nil) {
		ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHFavorite inManagedObjectContext:self.managedObjectContext];
		
		ret.LastModified = [self makeNullNil:[favorite objectForKey:kSCHLibreAccessWebServiceLastModified]];
		ret.State = [NSNumber numberWithStatus:kSCHStatusUnmodified];
		
		ret.IsFavorite = [self makeNullNil:[favorite objectForKey:kSCHLibreAccessWebServiceIsFavorite]];
	}
	
	return(ret);
}

@end
