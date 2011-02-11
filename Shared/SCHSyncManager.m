//
//  SCHSyncManager.m
//  Scholastic
//
//  Created by John S. Eddie on 04/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHSyncManager.h"

#import "SCHProfileSyncComponent.h"
#import "SCHContentSyncComponent.h"
#import "SCHBookshelfSyncComponent.h"
#import "SCHAnnotationSyncComponent.h"
#import "SCHReadingStatsSyncComponent.h"
#import "SCHSettingsSyncComponent.h"
#import "SCHProfileItem+Extensions.h"
#import "SCHContentProfileItem+Extensions.h"

static SCHSyncManager *sharedSyncManager = nil;
static NSTimeInterval const kSCHSyncManagerHeartbeatInterval = 30.0;

@interface SCHSyncManager ()

- (NSMutableArray *)bookAnnotationsFromProfile:(SCHProfileItem *)profileItem;
- (void)addToQueue:(SCHSyncComponent *)component;
- (void)kickQueue;

@property (retain, nonatomic) NSTimer *timer;
@property (retain, nonatomic) NSMutableArray *queue;
@property (retain, nonatomic) SCHProfileSyncComponent *profileSyncComponent; 
@property (retain, nonatomic) SCHContentSyncComponent *contentSyncComponent;
@property (retain, nonatomic) SCHBookshelfSyncComponent *bookshelfSyncComponent;
@property (retain, nonatomic) SCHAnnotationSyncComponent *annotationSyncComponent;
@property (retain, nonatomic) SCHReadingStatsSyncComponent *readingStatsSyncComponent;
@property (retain, nonatomic) SCHSettingsSyncComponent *settingsSyncComponent;

@end

@implementation SCHSyncManager

@synthesize timer;
@synthesize queue;
@synthesize managedObjectContext;
@synthesize profileSyncComponent;
@synthesize contentSyncComponent;
@synthesize bookshelfSyncComponent;
@synthesize annotationSyncComponent;
@synthesize readingStatsSyncComponent;
@synthesize settingsSyncComponent;

#pragma mark -
#pragma mark Singleton methods

+ (SCHSyncManager *)sharedSyncManager
{
    if (sharedSyncManager == nil) {
        sharedSyncManager = [[super allocWithZone:NULL] init];		
    }
	
    return(sharedSyncManager);
}

+ (id)allocWithZone:(NSZone *)zone
{
    return([[self sharedSyncManager] retain]);
}

- (id)copyWithZone:(NSZone *)zone
{
    return(self);
}

- (id)retain
{
    return(self);
}

- (NSUInteger)retainCount
{
    return(NSUIntegerMax);  //denotes an object that cannot be released
}

- (void)release
{
    // do nothing
}

- (id)autorelease
{
    return(self);
}

#pragma mark -
#pragma mark methods

- (id)init
{
	self = [super init];
	if (self != nil) {
		timer = nil;
		queue = [[NSMutableArray alloc] init];	
		profileSyncComponent = [[SCHProfileSyncComponent alloc] init];
		profileSyncComponent.delegate = self;
		contentSyncComponent = [[SCHContentSyncComponent alloc] init];
		contentSyncComponent.delegate = self;		
		bookshelfSyncComponent = [[SCHBookshelfSyncComponent alloc] init];
		bookshelfSyncComponent.delegate = self;		
		annotationSyncComponent = [[SCHAnnotationSyncComponent alloc] init];
		annotationSyncComponent.delegate = self;		
		readingStatsSyncComponent = [[SCHReadingStatsSyncComponent alloc] init];
		readingStatsSyncComponent.delegate = self;		
		settingsSyncComponent = [[SCHSettingsSyncComponent alloc] init];		
		settingsSyncComponent.delegate = self;		
	}
	
	return(self);
}

- (void)dealloc
{
	[timer release], timer = nil;
	[queue release], queue = nil;
	[profileSyncComponent release], profileSyncComponent = nil;
	[contentSyncComponent release], contentSyncComponent = nil;
	[bookshelfSyncComponent release], bookshelfSyncComponent = nil;
	[annotationSyncComponent release], annotationSyncComponent = nil;
	[readingStatsSyncComponent release], readingStatsSyncComponent = nil;
	[settingsSyncComponent release], settingsSyncComponent = nil;
	
	[super dealloc];
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)newManagedObjectContext
{
	[managedObjectContext release];
	managedObjectContext = newManagedObjectContext;
	[managedObjectContext retain];
	
	profileSyncComponent.managedObjectContext = newManagedObjectContext;
	contentSyncComponent.managedObjectContext = newManagedObjectContext;		
	bookshelfSyncComponent.managedObjectContext = newManagedObjectContext;		
	annotationSyncComponent.managedObjectContext = newManagedObjectContext;		
	readingStatsSyncComponent.managedObjectContext = newManagedObjectContext;		
	settingsSyncComponent.managedObjectContext = newManagedObjectContext;			
}

#pragma mark -
#pragma mark Background Sync methods

- (void)start
{
	[self stop];
	timer = [NSTimer scheduledTimerWithTimeInterval:kSCHSyncManagerHeartbeatInterval target:self selector:@selector(backgroundSyncHeartbeat:) userInfo:nil repeats:YES];
}

- (void)stop
{
	[timer invalidate];
	[timer release], timer = nil;
}

- (void)backgroundSyncHeartbeat:(NSTimer*)theTimer
{
	NSLog(@"Background Sync Heartbeat!");

	[self kickQueue];
}

#pragma mark -
#pragma mark Sync methods

// after login or opening the app
// also coming out of background
- (void)firstSync
{
	NSLog(@"Scheduling First Sync");
	
	[self addToQueue:profileSyncComponent];
	[self addToQueue:contentSyncComponent];
//	[self addToQueue:bookshelfSyncComponent];
		
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:kSCHProfileItem inManagedObjectContext:self.managedObjectContext];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDescription];
	
	NSError *error = nil;				
	NSArray *profiles = [self.managedObjectContext executeFetchRequest:request error:&error];
	for (SCHProfileItem *profileItem in profiles) {
		annotationSyncComponent.profileID = [profileItem valueForKey:kSCHLibreAccessWebServiceID];
		annotationSyncComponent.books = [self bookAnnotationsFromProfile:profileItem];
		
		[self addToQueue:annotationSyncComponent];		
	}
	[request release], request = nil;
	
//	[self addToQueue:readingStatsSyncComponent];
	[self addToQueue:settingsSyncComponent];
	
	[self kickQueue];
	
	// profiles GetUserProfile
	// content ListUserContent
	// bookshelf ListContentMetadata
	// annotations ListProfileContentAnnotations
	// reading stats
	// settings ListUserSettings
}

- (NSMutableArray *)bookAnnotationsFromProfile:(SCHProfileItem *)profileItem  
{
	NSMutableArray *ret = [NSMutableArray array];
	
	for (SCHContentProfileItem *contentProfileItem in [profileItem valueForKey:@"ContentProfileItem"]) {
		SCHUserContentItem *userContentItem = contentProfileItem.UserContentItem;
		
		NSMutableDictionary *annotationContentItem = [NSMutableDictionary dictionary];
		
		[annotationContentItem setObject:[userContentItem valueForKey:kSCHLibreAccessWebServiceContentIdentifier] forKey:kSCHLibreAccessWebServiceContentIdentifier];
		[annotationContentItem setObject:[userContentItem valueForKey:kSCHLibreAccessWebServiceContentIdentifierType] forKey:kSCHLibreAccessWebServiceContentIdentifierType];
		[annotationContentItem setObject:[userContentItem valueForKey:kSCHLibreAccessWebServiceDRMQualifier] forKey:kSCHLibreAccessWebServiceDRMQualifier];
		[annotationContentItem setObject:[userContentItem valueForKey:kSCHLibreAccessWebServiceFormat] forKey:kSCHLibreAccessWebServiceFormat];
		
		NSMutableDictionary *privateAnnotation = [NSMutableDictionary dictionary];
		NSDate *date = [NSDate distantPast];
		
		[privateAnnotation setObject:[userContentItem valueForKey:kSCHLibreAccessWebServiceVersion] forKey:kSCHLibreAccessWebServiceVersion];
		[privateAnnotation setObject:date forKey:kSCHLibreAccessWebServiceHighlightsAfter];
		[privateAnnotation setObject:date forKey:kSCHLibreAccessWebServiceNotesAfter];
		[privateAnnotation setObject:date forKey:kSCHLibreAccessWebServiceBookmarksAfter];
		
		[annotationContentItem setObject:privateAnnotation forKey:kSCHLibreAccessWebServicePrivateAnnotations];
		
		[ret addObject:annotationContentItem];
	}
	
	return(ret);
}

- (void)openDocument:(NSString *)ISBN forProfile:(NSNumber *)profileID
{
	NSLog(@"Scheduling Open Document");
	
	[self addToQueue:annotationSyncComponent];

	[self kickQueue];
	
	// annotations SaveProfileContentAnnotations/ListProfileContentAnnotations
}

- (void)openDocumentForProfile:(NSString *)ISBN forProfile:(NSNumber *)profileID
{
	NSLog(@"Scheduling Close Document");
	
	[self addToQueue:annotationSyncComponent];
//	[self addToQueue:readingStatsSyncComponent];
	
	[self kickQueue];
	
	// annotations SaveProfileContentAnnotations/ListProfileContentAnnotations
	// reading stats SaveReadingStatisticsDetailed
}

- (void)exitParentalTools:(BOOL)syncNow
{
	NSLog(@"Scheduling Exit Parental Tools");

	[self addToQueue:profileSyncComponent];
	[self addToQueue:contentSyncComponent];
//	[self addToQueue:bookshelfSyncComponent];
	[self addToQueue:settingsSyncComponent];
	
	[self kickQueue];
	
	// profiles SaveUserProfile/GetUserProfile
	// content SaveContentProfileAssignment/ListUserContent
	// bookshelf ListContentMetadata
	// settings SaveUserSettings/ListUserSettings
}

#pragma mark -
#pragma mark SCHComponent Delegate methods

- (void)component:(SCHComponent *)component didCompleteWithResult:(NSDictionary *)result
{
	NSLog(@"Removing %@ from the sync manager queue", [component class]);
	[queue removeObject:component];
	[self kickQueue];
}

- (void)component:(SCHComponent *)component didFailWithError:(NSError *)error
{
	// leave a retry to the heartbeat, give the error time to correct itself
}

#pragma mark -
#pragma mark Sync methods

- (void)addToQueue:(SCHSyncComponent *)component
{
	// TODO: handle multiple annotations
	if ([queue containsObject:component] == NO) {
		NSLog(@"Adding %@ to the sync manager queue", [component class]);
		[queue addObject:component];
	}
}

- (void)kickQueue
{
	// if the queue has stopped then start it up again
	if ([queue count] > 0) {
		SCHSyncComponent *syncComponent = [queue objectAtIndex:0];
		
		if (syncComponent != nil && [syncComponent isSynchronizing] == NO) {
			NSLog(@"Kicking %@", [syncComponent class]);			
			[syncComponent synchronize];
		}
	} else {
		NSLog(@"Queue is empty");
	}
}

@end
