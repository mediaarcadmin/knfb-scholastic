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

@interface SCHAnnotationSyncComponent ()

- (void)updateProfileContentAnnotations:(NSDictionary *)profileContentAnnotationList;
- (SCHAnnotationsContentItem *)annotationsContentItem:(NSDictionary *)annotationsContentItem;
- (SCHPrivateAnnotations *)privateAnnotation:(NSDictionary *)privateAnnotation;
- (SCHHighlight *)highlight:(NSDictionary *)highlight;
- (SCHNote *)note:(NSDictionary *)note;
- (SCHLocationGraphics *)locationGraphics:(NSDictionary *)locationGraphics;
- (SCHCoords *)coords:(NSDictionary *)coords;
- (SCHBookmark *)bookmark:(NSDictionary *)bookmark;
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
	
	if (![self.managedObjectContext emptyEntity:kSCHListProfileContentAnnotations error:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}	
}

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result
{	
	[self updateProfileContentAnnotations:[result objectForKey:kSCHLibreAccessWebServiceListProfileContentAnnotations]];	
	
	[super method:method didCompleteWithResult:nil];	
}

- (void)updateProfileContentAnnotations:(NSDictionary *)profileContentAnnotationList
{
	NSError *error = nil;
	
	SCHListProfileContentAnnotations *newListProfileContentAnnotations = [NSEntityDescription insertNewObjectForEntityForName:kSCHListProfileContentAnnotations inManagedObjectContext:self.managedObjectContext];
	SCHAnnotationsList *newAnnotationsList = nil;
	SCHItemsCount *newItemsCount = [NSEntityDescription insertNewObjectForEntityForName:kSCHItemsCount inManagedObjectContext:self.managedObjectContext];
	
	NSDictionary *annotationsList = [self makeNullNil:[profileContentAnnotationList objectForKey:kSCHLibreAccessWebServiceAnnotationsList]];
	NSDictionary *itemsCount = [self makeNullNil:[profileContentAnnotationList objectForKey:kSCHLibreAccessWebServiceItemsCount]];	
	
	for (NSDictionary *annotationsItem in annotationsList) {
		newAnnotationsList = [NSEntityDescription insertNewObjectForEntityForName:kSCHAnnotationsList inManagedObjectContext:self.managedObjectContext];
		for (NSDictionary *annotation in [annotationsItem objectForKey:kSCHLibreAccessWebServiceAnnotationsContentList]) {
			[newAnnotationsList addAnnotationContentItemObject:[self annotationsContentItem:annotation]];
		}
		newAnnotationsList.ProfileID = [annotationsItem objectForKey:kSCHLibreAccessWebServiceProfileID];
		[newListProfileContentAnnotations addAnnotationsListObject:newAnnotationsList];
	}
	
	newItemsCount.Found = [self makeNullNil:[itemsCount objectForKey:kSCHLibreAccessWebServiceFound]];
	newItemsCount.Returned = [self makeNullNil:[itemsCount objectForKey:kSCHLibreAccessWebServiceReturned]];	
	newListProfileContentAnnotations.ItemsCount = newItemsCount;
	
	// Save the context.
	if (![self.managedObjectContext save:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}	
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

- (SCHHighlight *)highlight:(NSDictionary *)highlight
{
	SCHHighlight *ret = nil;
	
	if (highlight != nil) {
		ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHHighlight inManagedObjectContext:self.managedObjectContext];
		
		ret.LastModified = [self makeNullNil:[highlight objectForKey:kSCHLibreAccessWebServiceLastModified]];
		
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
	SCHNote *ret = nil;
	
	if (note != nil) {
		ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHNote inManagedObjectContext:self.managedObjectContext];
		
		ret.LastModified = [self makeNullNil:[note objectForKey:kSCHLibreAccessWebServiceLastModified]];
		
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

- (SCHBookmark *)bookmark:(NSDictionary *)bookmark
{
	SCHBookmark *ret = nil;
	
	if (bookmark != nil) {
		ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHBookmark inManagedObjectContext:self.managedObjectContext];
		
		ret.LastModified = [self makeNullNil:[bookmark objectForKey:kSCHLibreAccessWebServiceLastModified]];
		
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
