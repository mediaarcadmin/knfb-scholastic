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
#import "SCHProfileItem.h"
#import "SCHContentProfileItem.h"
#import "SCHUserDefaults.h"

static SCHSyncManager *sharedSyncManager = nil;
static NSTimeInterval const kSCHSyncManagerHeartbeatInterval = 30.0;

@interface SCHSyncManager ()

- (NSMutableArray *)bookAnnotationsFromProfile:(SCHProfileItem *)profileItem;
- (NSMutableDictionary *)annotationContentItemFromUserContentItem:(SCHUserContentItem *)userContentItem;
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

#pragma mark - Singleton Instance methods

+ (SCHSyncManager *)sharedSyncManager
{
    if (sharedSyncManager == nil) {
        sharedSyncManager = [[super allocWithZone:NULL] init];		
    }
	
    return(sharedSyncManager);
}

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
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(authenticationManager:) 
                                                     name:kSCHAuthenticationManagerSuccess 
                                                   object:nil];					
	}
	
	return(self);
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
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
	[newManagedObjectContext retain];
	[managedObjectContext release];    
	managedObjectContext = newManagedObjectContext;
	
	self.profileSyncComponent.managedObjectContext = newManagedObjectContext;
	self.contentSyncComponent.managedObjectContext = newManagedObjectContext;		
	self.bookshelfSyncComponent.managedObjectContext = newManagedObjectContext;
	self.annotationSyncComponent.managedObjectContext = newManagedObjectContext;		
	self.readingStatsSyncComponent.managedObjectContext = newManagedObjectContext;		
	self.settingsSyncComponent.managedObjectContext = newManagedObjectContext;			
}

- (BOOL)isSynchronizing
{
	BOOL ret = NO;
	
	if ([self.queue count] > 0) {
		SCHSyncComponent *syncComponent = [self.queue objectAtIndex:0];
		
		if (syncComponent != nil) {
			ret = [syncComponent isSynchronizing];
		}
	}		
	return(ret);
}

- (BOOL)isQueueEmpty
{
	return([self.queue count] < 1);
}

#pragma mark - Background Sync methods

- (void)start
{
	[self stop];
	self.timer = [NSTimer scheduledTimerWithTimeInterval:kSCHSyncManagerHeartbeatInterval 
                                             target:self 
                                           selector:@selector(backgroundSyncHeartbeat:) 
                                           userInfo:nil 
                                            repeats:YES];
}

- (void)stop
{
	[timer invalidate];
	self.timer = nil;
}

- (void)backgroundSyncHeartbeat:(NSTimer *)theTimer
{
	//NSLog(@"Background Sync Heartbeat!");

	[self kickQueue];
}

- (void)authenticationManager:(NSNotification *)notification
{
	NSDictionary *userInfo = [notification userInfo];
	
	if ([[userInfo valueForKey:kSCHAuthenticationManagerOfflineMode] boolValue] == NO) {
		NSLog(@"Authenticated!");
		
		[self kickQueue];	
	}
}

#pragma mark - Sync methods

- (void)clear
{
    [self.queue removeAllObjects];
    
	[self.profileSyncComponent clear];	
	[self.contentSyncComponent clear];	
	[self.bookshelfSyncComponent clear];
	[self.annotationSyncComponent clear];	
	[self.readingStatsSyncComponent clear];	
	[self.settingsSyncComponent clear];	
	
	[[NSUserDefaults standardUserDefaults] setBool:NO 
                                            forKey:kSCHUserDefaultsPerformedFirstSyncUpToBooks];
}

- (BOOL)havePerformedFirstSyncUpToBooks
{
	return([[NSUserDefaults standardUserDefaults] boolForKey:kSCHUserDefaultsPerformedFirstSyncUpToBooks]);
}

// after login or opening the app, also coming out of background
- (void)firstSync
{
#if LOCALDEBUG
	return;
#endif
	
	NSLog(@"Scheduling First Sync");
	
	[self addToQueue:self.profileSyncComponent];
	[self addToQueue:self.contentSyncComponent];
	[self addToQueue:self.bookshelfSyncComponent];
		
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:kSCHProfileItem 
                                                         inManagedObjectContext:self.managedObjectContext];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDescription];
	
	NSError *error = nil;				
	NSArray *profiles = [self.managedObjectContext executeFetchRequest:request error:&error];
	for (SCHProfileItem *profileItem in profiles) {	
		[self.annotationSyncComponent addProfile:[profileItem 
                                             valueForKey:kSCHLibreAccessWebServiceID] 
                                  withBooks:[self bookAnnotationsFromProfile:profileItem]];	
	}
	[request release], request = nil;

	if ([self.annotationSyncComponent haveProfiles] == YES) {
		[self addToQueue:self.annotationSyncComponent];		
	}
	
	[self addToQueue:self.readingStatsSyncComponent];
	[self addToQueue:self.settingsSyncComponent];
	
	[self kickQueue];	
}

- (void)changeProfile
{
#if LOCALDEBUG
	return;
#endif

	NSLog(@"Scheduling Change Profile");
	
	[self addToQueue:self.profileSyncComponent];
	
	[self kickQueue];
}

- (void)updateBookshelf
{
#if LOCALDEBUG
	return;
#endif

	NSLog(@"Scheduling Update Bookshelf");
	
	[self addToQueue:self.bookshelfSyncComponent];
	
	[self kickQueue];
}

- (NSMutableArray *)bookAnnotationsFromProfile:(SCHProfileItem *)profileItem  
{
	NSMutableArray *ret = [NSMutableArray array];
	
	for (SCHContentProfileItem *contentProfileItem in [profileItem valueForKey:@"ContentProfileItem"]) {
		[ret addObject:[self annotationContentItemFromUserContentItem:contentProfileItem.UserContentItem]];
	}
	
	return(ret);
}

- (NSMutableDictionary *)annotationContentItemFromUserContentItem:(SCHUserContentItem *)userContentItem
{	
	NSMutableDictionary *ret = [NSMutableDictionary dictionary];
	
	[ret setObject:[userContentItem valueForKey:kSCHLibreAccessWebServiceContentIdentifier] 
            forKey:kSCHLibreAccessWebServiceContentIdentifier];
	[ret setObject:[userContentItem valueForKey:kSCHLibreAccessWebServiceContentIdentifierType] 
            forKey:kSCHLibreAccessWebServiceContentIdentifierType];
	[ret setObject:[userContentItem valueForKey:kSCHLibreAccessWebServiceDRMQualifier] 
            forKey:kSCHLibreAccessWebServiceDRMQualifier];
	[ret setObject:[userContentItem valueForKey:kSCHLibreAccessWebServiceFormat] 
            forKey:kSCHLibreAccessWebServiceFormat];
	
	NSMutableDictionary *privateAnnotation = [NSMutableDictionary dictionary];
	NSDate *date = [self.annotationSyncComponent lastSyncDate];
	
    if (date == nil) {
        date = [NSDate distantPast];
    }

	[privateAnnotation setObject:[userContentItem valueForKey:kSCHLibreAccessWebServiceVersion] 
                          forKey:kSCHLibreAccessWebServiceVersion];
	[privateAnnotation setObject:date 
                          forKey:kSCHLibreAccessWebServiceHighlightsAfter];
	[privateAnnotation setObject:date 
                          forKey:kSCHLibreAccessWebServiceNotesAfter];
	[privateAnnotation setObject:date 
                          forKey:kSCHLibreAccessWebServiceBookmarksAfter];
	
	[ret setObject:privateAnnotation 
            forKey:kSCHLibreAccessWebServicePrivateAnnotations];

	return(ret);
}

- (void)openDocument:(SCHUserContentItem *)userContentItem 
          forProfile:(NSNumber *)profileID
{
#if LOCALDEBUG
	return;
#endif

	NSLog(@"Scheduling Open Document");
	
	[self.annotationSyncComponent addProfile:profileID 
                              withBooks:[NSMutableArray arrayWithObject:[self annotationContentItemFromUserContentItem:userContentItem]]];	
	[self addToQueue:self.annotationSyncComponent];

	[self kickQueue];
}

- (void)closeDocument:(SCHUserContentItem *)userContentItem forProfile:(NSNumber *)profileID
{
    // save any changes first
    NSError *error = nil;
    [self.managedObjectContext save:&error];
#if LOCALDEBUG
	return;
#endif

	NSLog(@"Scheduling Close Document");
	
	[self.annotationSyncComponent addProfile:profileID 
                              withBooks:[NSMutableArray arrayWithObject:[self annotationContentItemFromUserContentItem:userContentItem]]];	
	[self addToQueue:self.annotationSyncComponent];
	[self addToQueue:self.readingStatsSyncComponent];
	
	[self kickQueue];	
}

- (void)exitParentalTools:(BOOL)syncNow
{
#if LOCALDEBUG
	return;
#endif

	NSLog(@"Scheduling Exit Parental Tools");

	[self addToQueue:self.profileSyncComponent];
	[self addToQueue:self.contentSyncComponent];
	[self addToQueue:self.bookshelfSyncComponent];
	[self addToQueue:self.settingsSyncComponent];
	
	[self kickQueue];	
}

#pragma mark - SCHComponent Delegate methods

- (void)component:(SCHComponent *)component didCompleteWithResult:(NSDictionary *)result
{
	if ([component isKindOfClass:[SCHBookshelfSyncComponent class]] == YES) {
		[[NSUserDefaults standardUserDefaults] setBool:YES 
                                                forKey:kSCHUserDefaultsPerformedFirstSyncUpToBooks];
	}
	
	if ([component isKindOfClass:[SCHAnnotationSyncComponent class]] == YES && 
        [(SCHAnnotationSyncComponent *)component haveProfiles] == YES) {
		NSLog(@"Next annotation profile");
	} else {
		NSLog(@"Removing %@ from the sync manager queue", [component class]);
		[self.queue removeObject:component];
	}
	[self kickQueue];
}

- (void)component:(SCHComponent *)component didFailWithError:(NSError *)error
{
	// leave a retry to the heartbeat, give the error time to correct itself
}

#pragma mark - Sync methods

- (void)addToQueue:(SCHSyncComponent *)component
{
	if ([self.queue containsObject:component] == NO) {
		NSLog(@"Adding %@ to the sync manager queue", [component class]);
		[self.queue addObject:component];
	}
}

- (void)kickQueue
{
	if ([self.queue count] > 0) {
		SCHSyncComponent *syncComponent = [self.queue objectAtIndex:0];
		NSLog(@"Sync component is %@", syncComponent);
		if (syncComponent != nil && [syncComponent isSynchronizing] == NO) {
			NSLog(@"Kicking %@", [syncComponent class]);			
			// if the queue has stopped then start it up again
			[syncComponent synchronize];
		} else {
			NSLog(@"Kicked but already syncing %@", [syncComponent class]);
		}
	} // else {
//		NSLog(@"Queue is empty");
//	}
}

@end
