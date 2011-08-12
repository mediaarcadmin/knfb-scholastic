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
#import "SCHAppStateManager.h"
#import "SCHCoreDataHelper.h"

// Constants
NSString * const SCHSyncManagerDidCompleteNotification = @"SCHSyncManagerDidCompleteNotification";

static NSTimeInterval const kSCHSyncManagerHeartbeatInterval = 30.0;
static NSTimeInterval const kSCHLastFirstSyncInterval = -300.0;

@interface SCHSyncManager ()

@property (nonatomic, retain) NSDate *lastFirstSyncEnded;

- (NSMutableArray *)bookAnnotationsFromProfile:(SCHProfileItem *)profileItem;
- (NSMutableDictionary *)annotationContentItemFromUserContentItem:(SCHUserContentItem *)userContentItem;
- (void)addToQueue:(SCHSyncComponent *)component;
- (void)kickQueue;
- (BOOL)shouldSync;

- (void)setAppState;
- (NSDictionary *)profileItemWith:(NSString *)title 
                         password:(NSString *)password
                              age:(NSUInteger)age 
                        bookshelf:(SCHBookshelfStyles)bookshelf;
- (NSDictionary *)contentMetaDataItemWith:(NSString *)contentIdentifier
                                    title:(NSString *)title
                                   author:(NSString *)author
                               pageNumber:(NSInteger)pageNumber
                                 fileSize:(long long)fileSize
                                 coverURL:(NSString *)coverURL
                               contentURL:(NSString *)contentURL
                                 enhanced:(BOOL)enhanced;
- (NSDictionary *)userContentItemWith:(NSString *)contentIdentifier 
                            profielID:(NSNumber *)profileID;

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

@synthesize lastFirstSyncEnded;
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
    static dispatch_once_t pred;
    static SCHSyncManager *sharedSyncManager = nil;
    
    dispatch_once(&pred, ^{
        sharedSyncManager = [[super allocWithZone:NULL] init];		
    });
	
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
                                                     name:SCHAuthenticationManagerDidSucceedNotification 
                                                   object:nil];		
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(coreDataHelperManagedObjectContextDidChangeNotification:) 
                                                     name:SCHCoreDataHelperManagedObjectContextDidChangeNotification 
                                                   object:nil];	
        
	}
	
	return(self);
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
    [lastFirstSyncEnded release], lastFirstSyncEnded = nil;
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

#pragma mark - NSManagedObjectContext Changed Notification

- (void)coreDataHelperManagedObjectContextDidChangeNotification:(NSNotification *)notification
{
    self.managedObjectContext = [[notification userInfo] objectForKey:SCHCoreDataHelperManagedObjectContext];
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
- (void)firstSync:(BOOL)syncNow;
{
    if ([self shouldSync] == YES) {	
        // reset if the date has been changed in a backward motion
        if ([self.lastFirstSyncEnded compare:[NSDate date]] == NSOrderedDescending) {
            self.lastFirstSyncEnded = nil;
        }
        
        if (syncNow == YES || self.lastFirstSyncEnded == nil || 
            [self.lastFirstSyncEnded timeIntervalSinceNow] < kSCHLastFirstSyncInterval) {
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
    } else {
        // used to kick off the processing manager so even though we're not
        // syncing we still post the notification
        [[NSNotificationCenter defaultCenter] postNotificationName:SCHBookshelfSyncComponentDidCompleteNotification object:nil];    
    }
}

- (void)changeProfile
{
    if ([self shouldSync] == YES) {	
        NSLog(@"Scheduling Change Profile");
        
        [self addToQueue:self.profileSyncComponent];
        
        [self kickQueue];
    }
}

- (void)updateBookshelf
{
    if ([self shouldSync] == YES) {	
        NSLog(@"Scheduling Update Bookshelf");
        
        [self addToQueue:self.bookshelfSyncComponent];
        
        [self kickQueue];
    }
}

- (NSMutableArray *)bookAnnotationsFromProfile:(SCHProfileItem *)profileItem  
{
	NSMutableArray *ret = [NSMutableArray array];
	
	for (SCHContentProfileItem *contentProfileItem in profileItem.ContentProfileItem) {
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
    if ([self shouldSync] == YES) {	
        NSLog(@"Scheduling Open Document");
        
        if (userContentItem != nil && profileID != nil) {
            [self.annotationSyncComponent addProfile:profileID 
                                           withBooks:[NSMutableArray arrayWithObject:[self annotationContentItemFromUserContentItem:userContentItem]]];	
            [self addToQueue:self.annotationSyncComponent];
            
            [self kickQueue];
        }
    }
}

- (void)closeDocument:(SCHUserContentItem *)userContentItem forProfile:(NSNumber *)profileID
{
    // save any changes first
    NSError *error = nil;
    [self.managedObjectContext save:&error];
    
    if ([self shouldSync] == YES) {	
        NSLog(@"Scheduling Close Document");
        
        if (userContentItem != nil && profileID != nil) {
            [self.annotationSyncComponent addProfile:profileID 
                                           withBooks:[NSMutableArray arrayWithObject:[self annotationContentItemFromUserContentItem:userContentItem]]];	
            [self addToQueue:self.annotationSyncComponent];
            [self addToQueue:self.readingStatsSyncComponent];
            
            [self kickQueue];	
        }
    }
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

    // the settings sync is the last component in the firstSync so signal it is complete
    if ([component isKindOfClass:[SCHSettingsSyncComponent class]] == YES) {
        self.lastFirstSyncEnded = [NSDate date];
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
	if ([self.queue count] > 0 && 
        [UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
		SCHSyncComponent *syncComponent = [self.queue objectAtIndex:0];
		NSLog(@"Sync component is %@", syncComponent);
		if (syncComponent != nil && [syncComponent isSynchronizing] == NO) {
			NSLog(@"Kicking %@", [syncComponent class]);			
			// if the queue has stopped then start it up again
			[syncComponent synchronize];
		} else {
			NSLog(@"Kicked but already syncing %@", [syncComponent class]);
		}
	}  else {
        [[NSNotificationCenter defaultCenter] postNotificationName:SCHSyncManagerDidCompleteNotification 
                                                            object:self];        
        
        //		NSLog(@"Queue is empty");
	}
}

- (BOOL)shouldSync
{
    BOOL ret = NO;
    SCHAppState *appState = [SCHAppStateManager sharedAppStateManager].appState;
    
    if (appState != nil) {
        ret = [appState.ShouldSync boolValue];        
    }
    
    return(ret);    
}

#pragma mark - Sample bookshelf population methods

- (void)populateYoungerSampleStore
{
    NSError *error = nil;

    [self setAppState];    
    
    NSDictionary *profileItem = [self profileItemWith:NSLocalizedString(@"Younger kids' bookshelf (3-6)", nil) 
                                             password:@"pass"                                 
                                                  age:5 
                                            bookshelf:kSCHBookshelfStyleYoungChild];
    [self.profileSyncComponent addProfile:profileItem];

    NSDictionary *book = [self contentMetaDataItemWith:@"0-393-05158-7"
                                                 title:@"A Christmas Carol"
                                                author:@"Charles Dickens"
                                            pageNumber:1
                                              fileSize:862109
                                              coverURL:@"http://bitwink.com/private/ChristmasCarol.jpg"
                                            contentURL:@"http://bitwink.com/private/ChristmasCarol.xps"
                                              enhanced:NO];
    
    [self.contentSyncComponent addUserContentItem:[self userContentItemWith:[book objectForKey:kSCHLibreAccessWebServiceContentIdentifier]
                                                                  profielID:[profileItem objectForKey:kSCHLibreAccessWebServiceID]]];

    [self.bookshelfSyncComponent addContentMetadataItem:book];
    
    if ([self.managedObjectContext save:&error] == NO) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }     
}

- (void)populateOlderSampleStore
{
    NSError *error = nil;
    
    [self setAppState];    
    
    NSDictionary *profileItem = [self profileItemWith:NSLocalizedString(@"Older kids' bookshelf (7+)", nil) 
                                             password:@"pass"
                                                  age:14 
                                            bookshelf:kSCHBookshelfStyleOlderChild];
    [self.profileSyncComponent addProfile:profileItem];
    
    NSDictionary *book = [self contentMetaDataItemWith:@"978-0-14-143960-0"
                                                 title:@"A Tale of Two Cities"
                                                author:@"Charles Dickens"
                                            pageNumber:1
                                              fileSize:4023944
                                              coverURL:@"http://bitwink.com/private/ATaleOfTwoCities.jpg"
                                            contentURL:@"http://bitwink.com/private/ATaleOfTwoCities.xps"
                                              enhanced:NO];
    
    
    [self.contentSyncComponent addUserContentItem:[self userContentItemWith:[book objectForKey:kSCHLibreAccessWebServiceContentIdentifier] 
                                                                  profielID:[profileItem objectForKey:kSCHLibreAccessWebServiceID]]];
     
    [self.bookshelfSyncComponent addContentMetadataItem:book];

    if ([self.managedObjectContext save:&error] == NO) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }     
}

- (void)setAppState
{
    SCHAppState *appState = [SCHAppStateManager sharedAppStateManager].appState;
    
    appState.ShouldSync = [NSNumber numberWithBool:NO];
    appState.ShouldDownloadBooks = [NSNumber numberWithBool:YES];
    appState.ShouldAuthenticate = [NSNumber numberWithBool:NO];
    appState.DataStoreType = [NSNumber numberWithDataStoreType:kSCHDataStoreTypesSample];
}

- (NSDictionary *)profileItemWith:(NSString *)title 
                         password:(NSString *)password
                              age:(NSUInteger)age 
                        bookshelf:(SCHBookshelfStyles)bookshelf
{
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    NSDate *dateNow = [NSDate date];
    NSCalendar *gregorian = [[[NSCalendar alloc]
                              initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    NSDateComponents *dateComponents = [[[NSDateComponents alloc] init] autorelease];        

    [ret setObject:[NSNumber numberWithBool:YES] forKey:kSCHLibreAccessWebServiceStoryInteractionEnabled];
    [ret setObject:[NSNumber numberWithInt:1] forKey:kSCHLibreAccessWebServiceID];
    [ret setObject:dateNow forKey:kSCHLibreAccessWebServiceLastPasswordModified];    
    [ret setObject:password forKey:kSCHLibreAccessWebServicePassword]; 
    dateComponents.year = -age;
    [ret setObject:[gregorian dateByAddingComponents:dateComponents toDate:dateNow options:0] forKey:kSCHLibreAccessWebServiceBirthday];    
    [ret setObject:title forKey:kSCHLibreAccessWebServiceFirstName];    
    [ret setObject:[NSNumber numberWithBool:NO] forKey:kSCHLibreAccessWebServiceProfilePasswordRequired];    
    [ret setObject:[NSNumber numberWithProfileType:kSCHProfileTypesCHILD] forKey:kSCHLibreAccessWebServiceType];        
    [ret setObject:title forKey:kSCHLibreAccessWebServiceScreenName];        
    [ret setObject:[NSNumber numberWithBool:YES] forKey:kSCHLibreAccessWebServiceAutoAssignContentToProfiles];        
    [ret setObject:dateNow forKey:kSCHLibreAccessWebServiceLastScreenNameModified];            
    [ret setObject:@"" forKey:kSCHLibreAccessWebServiceUserKey];            
    [ret setObject:[NSNumber numberWithBookshelfStyle:bookshelf] forKey:kSCHLibreAccessWebServiceBookshelfStyle];                
    [ret setObject:title forKey:kSCHLibreAccessWebServiceLastName];                
    [ret setObject:dateNow forKey:kSCHLibreAccessWebServiceLastModified];                

    return(ret);
}

- (NSDictionary *)contentMetaDataItemWith:(NSString *)contentIdentifier
                                    title:(NSString *)title
                                   author:(NSString *)author
                               pageNumber:(NSInteger)pageNumber
                                 fileSize:(long long)fileSize
                                 coverURL:(NSString *)coverURL
                               contentURL:(NSString *)contentURL
                                 enhanced:(BOOL)enhanced
{
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];    
    
    [ret setObject:contentIdentifier forKey:kSCHLibreAccessWebServiceContentIdentifier];
    [ret setObject:[NSNumber numberWithContentIdentifierType:kSCHContentItemContentIdentifierTypesISBN13] forKey:kSCHLibreAccessWebServiceContentIdentifierType];
    [ret setObject:title forKey:kSCHLibreAccessWebServiceTitle];
    [ret setObject:author forKey:kSCHLibreAccessWebServiceAuthor];
    [ret setObject:[NSString stringWithFormat:@"A book by %@", author] forKey:kSCHLibreAccessWebServiceDescription];
    [ret setObject:@"1" forKey:kSCHLibreAccessWebServiceVersion];
    [ret setObject:[NSNumber numberWithInteger:pageNumber] forKey:kSCHLibreAccessWebServicePageNumber];
    [ret setObject:[NSNumber numberWithLongLong:fileSize] forKey:kSCHLibreAccessWebServiceFileSize];
    [ret setObject:[NSNumber numberWithDRMQualifier:kSCHDRMQualifiersSample] forKey:kSCHLibreAccessWebServiceDRMQualifier];
    [ret setObject:coverURL forKey:kSCHLibreAccessWebServiceCoverURL];
    [ret setObject:contentURL forKey:kSCHLibreAccessWebServiceContentURL];
    [ret setObject:[NSNull null] forKey:kSCHLibreAccessWebServiceeReaderCategories];
    [ret setObject:[NSNumber numberWithBool:enhanced] forKey:kSCHLibreAccessWebServiceEnhanced];

    return(ret);    
}

- (NSDictionary *)userContentItemWith:(NSString *)contentIdentifier 
                            profielID:(NSNumber *)profileID
{
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];    
    NSDate *dateNow = [NSDate date];

    NSMutableDictionary *profileList = [NSMutableDictionary dictionary];
    [profileList setObject:profileID forKey:kSCHLibreAccessWebServiceProfileID];        
    [profileList setObject:[NSNumber numberWithBool:NO] forKey:kSCHLibreAccessWebServiceIsFavorite];        
    [profileList setObject:[NSNumber numberWithInteger:0] forKey:kSCHLibreAccessWebServiceLastPageLocation];            
    [profileList setObject:dateNow forKey:kSCHLibreAccessWebServiceLastModified];        
    
    NSMutableDictionary *orderList = [NSMutableDictionary dictionary];
    [orderList setObject:@"1" forKey:kSCHLibreAccessWebServiceOrderID];        
    [orderList setObject:dateNow forKey:kSCHLibreAccessWebServiceOrderDate];        

    [ret setObject:contentIdentifier forKey:kSCHLibreAccessWebServiceContentIdentifier];
    [ret setObject:[NSNumber numberWithContentIdentifierType:kSCHContentItemContentIdentifierTypesISBN13] forKey:kSCHLibreAccessWebServiceContentIdentifierType];
    [ret setObject:[NSNumber numberWithDRMQualifier:kSCHDRMQualifiersSample] forKey:kSCHLibreAccessWebServiceDRMQualifier];
    [ret setObject:@"XPS" forKey:kSCHLibreAccessWebServiceFormat];
    [ret setObject:@"1" forKey:kSCHLibreAccessWebServiceVersion];    
    [ret setObject:[NSArray arrayWithObject:profileList] forKey:kSCHLibreAccessWebServiceProfileList];
    [ret setObject:[NSArray arrayWithObject:orderList] forKey:kSCHLibreAccessWebServiceOrderList];        
    [ret setObject:dateNow forKey:kSCHLibreAccessWebServiceLastModified];
    [ret setObject:[NSNumber numberWithBool:NO] forKey:kSCHLibreAccessWebServiceDefaultAssignment];
    
    return(ret);    
}

@end
