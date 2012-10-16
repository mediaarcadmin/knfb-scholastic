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
#import "SCHListReadingStatisticsSyncComponent.h"
#import "SCHSettingsSyncComponent.h"
#import "SCHWishListSyncComponent.h"
#import "SCHRecommendationSyncComponent.h"
#import "SCHTopRatingsSyncComponent.h"
#import "SCHProfileItem.h"
#import "SCHContentProfileItem.h"
#import "SCHUserDefaults.h"
#import "SCHAppStateManager.h"
#import "SCHCoreDataHelper.h"
#import "SCHPopulateDataStore.h"
#import "SCHAppContentProfileItem.h"
#import "SCHVersionDownloadManager.h"
#import "SCHLibreAccessConstants.h"
#import "NSFileManager+Extensions.h"
#import "SCHBooksAssignment.h"
#import "SCHSyncDelay.h"

// Constants
NSString * const SCHSyncManagerDidCompleteNotification = @"SCHSyncManagerDidCompleteNotification";

static NSTimeInterval const kSCHSyncManagerHeartbeatInterval = 30.0;
static NSTimeInterval const kSCHLastFirstSyncInterval = -300.0;
static NSTimeInterval const kSCHLastBookshelfSyncInterval = -300.0;
static NSTimeInterval const kSCHLastWishListSyncInterval = -300.0;

// Core Data will fail to save changes if there is no disk space left
static unsigned long long const kSCHSyncManagerMinimumDiskSpaceRequiredForSync = 10485760; // 10mb

static NSUInteger const kSCHSyncManagerMaximumFailureRetries = 3;

@interface SCHSyncManager ()

@property (nonatomic, retain) SCHSyncDelay *accountSyncDelay;
@property (nonatomic, retain) SCHSyncDelay *bookshelfSyncDelay;
@property (nonatomic, retain) SCHSyncDelay *openBookSyncDelay;
@property (nonatomic, retain) SCHSyncDelay *closeBookSyncDelay;
@property (nonatomic, retain) SCHSyncDelay *wishlistSyncDelay;
@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTaskIdentifier;
@property (nonatomic, assign) BOOL flushSaveMode;

- (void)endBackgroundTask;
- (void)addAllProfilesToAnnotationSync;
- (void)addAllProfilesToReadingStatsSync;
- (NSMutableArray *)bookAnnotationsFromProfile:(SCHProfileItem *)profileItem;
- (NSDictionary *)annotationContentItemFromBooksAssignment:(SCHBooksAssignment *)booksAssignment
                                                forProfile:(NSNumber *)profileID;
- (BOOL)readingStatsActive;
- (BOOL)wishListSyncActive;
- (void)performFlushSaves;
- (SCHSyncComponent *)queueHead;
- (void)addToQueue:(SCHSyncComponent *)component;
- (void)moveToEndOfQueue:(SCHSyncComponent *)component;
- (void)removeFromQueue:(SCHSyncComponent *)component 
      includeDependants:(BOOL)includeDependants;
- (void)kickQueue;
- (void)performDelayedSyncIfRequired;
- (BOOL)shouldSync;

- (SCHPopulateDataStore *)populateDataStore;

@property (retain, nonatomic) NSTimer *timer;
@property (retain, nonatomic) NSMutableArray *queue;
@property (retain, nonatomic) SCHProfileSyncComponent *profileSyncComponent; 
@property (retain, nonatomic) SCHContentSyncComponent *contentSyncComponent;
@property (retain, nonatomic) SCHBookshelfSyncComponent *bookshelfSyncComponent;
@property (retain, nonatomic) SCHAnnotationSyncComponent *annotationSyncComponent;
@property (retain, nonatomic) SCHReadingStatsSyncComponent *readingStatsSyncComponent;
@property (retain, nonatomic) SCHListReadingStatisticsSyncComponent *listReadingStatisticsSyncComponent;
@property (retain, nonatomic) SCHSettingsSyncComponent *settingsSyncComponent;
@property (retain, nonatomic) SCHWishListSyncComponent *wishListSyncComponent;
@property (retain, nonatomic) SCHRecommendationSyncComponent *recommendationSyncComponent;
@property (retain, nonatomic) SCHTopRatingsSyncComponent *topRatingsSyncComponent;

@end

@implementation SCHSyncManager

@synthesize accountSyncDelay;
@synthesize bookshelfSyncDelay;
@synthesize openBookSyncDelay;
@synthesize closeBookSyncDelay;
@synthesize wishlistSyncDelay;
@synthesize timer;
@synthesize queue;
@synthesize managedObjectContext;
@synthesize profileSyncComponent;
@synthesize contentSyncComponent;
@synthesize bookshelfSyncComponent;
@synthesize annotationSyncComponent;
@synthesize readingStatsSyncComponent;
@synthesize listReadingStatisticsSyncComponent;
@synthesize settingsSyncComponent;
@synthesize wishListSyncComponent;
@synthesize recommendationSyncComponent;
@synthesize topRatingsSyncComponent;
@synthesize backgroundTaskIdentifier;
@synthesize flushSaveMode;
@synthesize suspended;

#pragma mark - Singleton Instance methods

+ (SCHSyncManager *)sharedSyncManager
{
    static dispatch_once_t pred;
    static SCHSyncManager *sharedSyncManager = nil;
    
    dispatch_once(&pred, ^{
        sharedSyncManager = [[super allocWithZone:NULL] init];		
    });
	
    return sharedSyncManager;
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
        listReadingStatisticsSyncComponent = [[SCHListReadingStatisticsSyncComponent alloc] init];
        listReadingStatisticsSyncComponent.delegate = self;
		settingsSyncComponent = [[SCHSettingsSyncComponent alloc] init];		
		settingsSyncComponent.delegate = self;	
		wishListSyncComponent = [[SCHWishListSyncComponent alloc] init];
        wishListSyncComponent.delegate = self;
        recommendationSyncComponent = [[SCHRecommendationSyncComponent alloc] init];
        recommendationSyncComponent.delegate = self;
#if USE_TOP_RATINGS_FOR_PROFILE_RECOMMENDATIONS
        topRatingsSyncComponent = [[SCHTopRatingsSyncComponent alloc] init];
        topRatingsSyncComponent.delegate = self;
#endif
        backgroundTaskIdentifier = UIBackgroundTaskInvalid;	

        accountSyncDelay = [[SCHSyncDelay alloc] init];
        bookshelfSyncDelay = [[SCHSyncDelay alloc] init];
        openBookSyncDelay = [[SCHSyncDelay alloc] init];
        closeBookSyncDelay = [[SCHSyncDelay alloc] init];
        wishlistSyncDelay = [[SCHSyncDelay alloc] init];
        flushSaveMode = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(applicationDidEnterBackground:) 
                                                     name:UIApplicationDidEnterBackgroundNotification 
                                                   object:nil];	

        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(coreDataHelperManagedObjectContextDidChangeNotification:) 
                                                     name:SCHCoreDataHelperManagedObjectContextDidChangeNotification 
                                                   object:nil];	

        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(contentSyncComponentWillDelete:) 
                                                     name:SCHContentSyncComponentWillDeleteNotification 
                                                   object:nil];	        

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(kickQueue)
                                                     name:SCHVersionDownloadManagerCompletedNotification 
                                                   object:nil];
	}
	
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
    [self endBackgroundTask];

    [accountSyncDelay release], accountSyncDelay = nil;
    [bookshelfSyncDelay release], bookshelfSyncDelay = nil;
    [openBookSyncDelay release], openBookSyncDelay = nil;
    [closeBookSyncDelay release], closeBookSyncDelay = nil;
    [wishlistSyncDelay release], wishlistSyncDelay = nil;
	[timer release], timer = nil;
	[queue release], queue = nil;
	[profileSyncComponent release], profileSyncComponent = nil;
	[contentSyncComponent release], contentSyncComponent = nil;
	[bookshelfSyncComponent release], bookshelfSyncComponent = nil;
	[annotationSyncComponent release], annotationSyncComponent = nil;
	[readingStatsSyncComponent release], readingStatsSyncComponent = nil;
    [listReadingStatisticsSyncComponent release], listReadingStatisticsSyncComponent = nil;
	[settingsSyncComponent release], settingsSyncComponent = nil;
    [wishListSyncComponent release], wishListSyncComponent = nil;
    [recommendationSyncComponent release], recommendationSyncComponent = nil;
#if USE_TOP_RATINGS_FOR_PROFILE_RECOMMENDATIONS
    [topRatingsSyncComponent release], topRatingsSyncComponent = nil;
#endif

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
    self.listReadingStatisticsSyncComponent.managedObjectContext = newManagedObjectContext;
	self.settingsSyncComponent.managedObjectContext = newManagedObjectContext;	
    self.wishListSyncComponent.managedObjectContext = newManagedObjectContext;
    self.recommendationSyncComponent.managedObjectContext = newManagedObjectContext;
#if USE_TOP_RATINGS_FOR_PROFILE_RECOMMENDATIONS
    self.topRatingsSyncComponent.managedObjectContext = newManagedObjectContext;
#endif
}

- (BOOL)isSynchronizing
{
	BOOL ret = NO;
	
    SCHSyncComponent *syncComponent = [self queueHead];
    if (syncComponent != nil) {
        ret = [syncComponent isSynchronizing];
	}		
    
	return ret;
}

- (BOOL)isQueueEmpty
{
	return [self.queue count] < 1;
}

- (void)setFlushSaveMode:(BOOL)setFlushSaveMode
{
    if (flushSaveMode != setFlushSaveMode) {
        flushSaveMode = setFlushSaveMode;
        
        self.profileSyncComponent.saveOnly = flushSaveMode;
        self.contentSyncComponent.saveOnly = flushSaveMode;
        self.bookshelfSyncComponent.saveOnly = flushSaveMode;
        self.annotationSyncComponent.saveOnly = flushSaveMode;
        self.readingStatsSyncComponent.saveOnly = flushSaveMode;
        self.listReadingStatisticsSyncComponent.saveOnly = flushSaveMode;
        self.settingsSyncComponent.saveOnly = flushSaveMode;
        self.wishListSyncComponent.saveOnly = flushSaveMode;
        self.recommendationSyncComponent.saveOnly = flushSaveMode;
#if USE_TOP_RATINGS_FOR_PROFILE_RECOMMENDATIONS
        self.topRatingsSyncComponent.saveOnly = flushSaveMode;
#endif
    }
}

#pragma mark - NSManagedObjectContext Changed Notification

- (void)coreDataHelperManagedObjectContextDidChangeNotification:(NSNotification *)notification
{
    NSAssert([NSThread isMainThread], @"Must be called on main thread");
    self.managedObjectContext = [[notification userInfo] objectForKey:SCHCoreDataHelperManagedObjectContext];
}

#pragma mark - Background Sync methods

- (void)startHeartbeat
{
    NSAssert([NSThread isMainThread], @"Must be called on main thread");
    
	[self stopHeartbeat];
    self.flushSaveMode = NO;
	self.timer = [NSTimer scheduledTimerWithTimeInterval:kSCHSyncManagerHeartbeatInterval 
                                             target:self 
                                           selector:@selector(backgroundSyncHeartbeat:) 
                                           userInfo:nil 
                                            repeats:YES];
}

- (void)stopHeartbeat
{
    NSAssert([NSThread isMainThread], @"Must be called on main thread");
    
	[timer invalidate];
	self.timer = nil;
}

- (void)setSuspended:(BOOL)newSuspended
{
    if (newSuspended != suspended) {
        suspended = newSuspended;
        if (suspended) {
            [self stopHeartbeat];
        } else {
            [self startHeartbeat];
            [self kickQueue];
        }
    }
}

- (void)backgroundSyncHeartbeat:(NSTimer *)theTimer
{
	//NSLog(@"Background Sync Heartbeat!");

	[self kickQueue];
}

#pragma mark - Sync methods

- (void)flushSyncQueue
{
    NSAssert([NSThread isMainThread], @"Must be called on main thread");
    
    [self.queue removeAllObjects];    
}

- (void)resetSync
{
    NSAssert([NSThread isMainThread], @"Must be called on main thread");
    
    [self flushSyncQueue];
    
	[self.profileSyncComponent resetSync];	
	[self.contentSyncComponent resetSync];	
	[self.bookshelfSyncComponent resetSync];
	[self.annotationSyncComponent resetSync];	
	[self.readingStatsSyncComponent resetSync];
    [self.listReadingStatisticsSyncComponent resetSync];
	[self.settingsSyncComponent resetSync];	
	[self.wishListSyncComponent resetSync];	
    [self.recommendationSyncComponent resetSync];
#if USE_TOP_RATINGS_FOR_PROFILE_RECOMMENDATIONS
    [self.topRatingsSyncComponent resetSync];
#endif

    [self.accountSyncDelay clearSyncDelay];
    [self.bookshelfSyncDelay clearSyncDelay];
    [self.openBookSyncDelay clearSyncDelay];
    [self.closeBookSyncDelay clearSyncDelay];
    [self.wishlistSyncDelay clearSyncDelay];
    self.suspended = NO;
    
    [self endBackgroundTask];
        
	[[NSUserDefaults standardUserDefaults] setBool:NO 
                                            forKey:kSCHUserDefaultsPerformedAccountSync];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

- (void)endBackgroundTask
{
    if (self.backgroundTaskIdentifier != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
        self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;			
    }    
}

- (BOOL)havePerformedAccountSync
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:kSCHUserDefaultsPerformedAccountSync];
}

- (void)accountSyncForced:(BOOL)syncNow
requireDeviceAuthentication:(BOOL)requireAuthentication
{
    NSAssert([NSThread isMainThread], @"Must be called on main thread");
    
    if (requireAuthentication) {
        [[SCHAuthenticationManager sharedAuthenticationManager] expireToken];
    }

    if ([self shouldSync] == YES) {	        
        if (syncNow == YES || [self.accountSyncDelay shouldSync] == YES) {
            NSLog(@"Scheduling Account Sync");
            [self.accountSyncDelay syncStarted];
            
            [self addToQueue:self.settingsSyncComponent];
            
            [self addToQueue:self.profileSyncComponent];

            [self addToQueue:self.contentSyncComponent];

            [self kickQueue];	
        } else {
            [self.accountSyncDelay activateDelay];
        }
    } else  {
        if (syncNow == YES || [self.accountSyncDelay shouldSync] == YES) {
            [self.accountSyncDelay syncStarted];
    
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [[NSNotificationCenter defaultCenter] postNotificationName:SCHProfileSyncComponentDidCompleteNotification 
                                                                    object:self];		
                [[NSNotificationCenter defaultCenter] postNotificationName:SCHContentSyncComponentDidCompleteNotification 
                                                                    object:self];		
            });
        } else {
            [self.accountSyncDelay activateDelay];
        }
    }
}

// make sure we do not sync any profile books that have been removed
- (void)contentSyncComponentWillDelete:(NSNotification *)notification
{
    if ([self shouldSync] == YES) {
        NSDictionary *userInfo = [notification userInfo];
        
        if (userInfo != nil ) {
            for (NSNumber *profileID in [userInfo allKeys]) {
                [self.annotationSyncComponent removeProfile:profileID withBooks:[userInfo objectForKey:profileID]];
                [self.readingStatsSyncComponent removeProfile:profileID];
                [self.listReadingStatisticsSyncComponent removeProfile:profileID withBooks:[userInfo objectForKey:profileID]];
            }
            
            if ([self.annotationSyncComponent haveProfiles] == NO) {
                [self removeFromQueue:self.annotationSyncComponent includeDependants:YES];
            }
            if ([self.readingStatsSyncComponent haveProfiles] == NO) {
                [self removeFromQueue:self.readingStatsSyncComponent includeDependants:YES];
            }
            if ([self.listReadingStatisticsSyncComponent haveProfiles] == NO) {
                [self removeFromQueue:self.listReadingStatisticsSyncComponent includeDependants:YES];
            }
            
        }
    }
}

- (void)performFlushSaves
{
    NSAssert([NSThread isMainThread], @"Must be called on main thread");
    
    if ([self shouldSync] == YES) {	  
        // go into flush save mode
        self.flushSaveMode = YES;
        
        NSLog(@"Performing Flush Saves");
        
        [self flushSyncQueue];

        [self.profileSyncComponent synchronize];

        [self addAllProfilesToAnnotationSync];
        if ([self.annotationSyncComponent haveProfiles] == YES) {
            [self.annotationSyncComponent synchronize];
        }
        if ([self readingStatsActive] == YES) {
            [self addAllProfilesToReadingStatsSync];
            if ([self.readingStatsSyncComponent haveProfiles] == YES) {
                [self.readingStatsSyncComponent synchronize];
            }
        }

        if ([self wishListSyncActive] == YES) {
            [self.wishListSyncComponent synchronize];
        }
    }    
}

- (void)addAllProfilesToAnnotationSync
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:kSCHProfileItem 
                                                         inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSError *error = nil;				
    NSArray *profiles = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (profiles == nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    for (SCHProfileItem *profileItem in profiles) {	
        [self.annotationSyncComponent addProfile:[profileItem 
                                                  valueForKey:kSCHLibreAccessWebServiceID] 
                                       withBooks:[self bookAnnotationsFromProfile:profileItem]];	
    }
    [request release], request = nil;
}

- (void)addAllProfilesToReadingStatsSync
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:kSCHProfileItem
                                                         inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];

    NSError *error = nil;
    NSArray *profiles = [self.managedObjectContext executeFetchRequest:request
                                                                 error:&error];
    if (profiles == nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }

    for (SCHProfileItem *profileItem in profiles) {
        [self.readingStatsSyncComponent addProfile:[profileItem valueForKey:kSCHLibreAccessWebServiceID]];
    }
    [request release], request = nil;
}

- (void)passwordSync
{
    NSAssert([NSThread isMainThread], @"Must be called on main thread");
    
    if ([self shouldSync] == YES) {	
        NSLog(@"Scheduling Password Sync");
        
        [self addToQueue:self.profileSyncComponent];
        
        [self kickQueue];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [[NSNotificationCenter defaultCenter] postNotificationName:SCHProfileSyncComponentDidCompleteNotification 
                                                                object:self];		
        });
    }
}

- (void)bookshelfSyncForced:(BOOL)syncNow
{
    NSAssert([NSThread isMainThread], @"Must be called on main thread");
        
    if ([self shouldSync] == YES) {
        if (syncNow == YES || [self.bookshelfSyncDelay shouldSync] == YES) {
            NSLog(@"Scheduling Bookshelf Sync");
            [self.bookshelfSyncDelay syncStarted];

            [self addToQueue:self.bookshelfSyncComponent];

            [self addAllProfilesToAnnotationSync];
            if ([self.annotationSyncComponent haveProfiles] == YES) {
                [self addToQueue:self.annotationSyncComponent];
            }

            [self kickQueue];
        } else {
            [self.bookshelfSyncDelay activateDelay];
        }
    } else {
        if (syncNow == YES || [self.bookshelfSyncDelay shouldSync] == YES) {
            [self.bookshelfSyncDelay syncStarted];
        
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [[NSNotificationCenter defaultCenter] postNotificationName:SCHBookshelfSyncComponentDidCompleteNotification
                                                                    object:self];
                [[NSNotificationCenter defaultCenter] postNotificationName:SCHAnnotationSyncComponentDidCompleteNotification
                                                                    object:self];
                [[NSNotificationCenter defaultCenter] postNotificationName:SCHSettingsSyncComponentDidCompleteNotification
                                                                    object:nil];
            });
        } else {
            [self.bookshelfSyncDelay activateDelay];
        }
    }
}

- (NSMutableArray *)bookAnnotationsFromProfile:(SCHProfileItem *)profileItem
{
	NSMutableArray *ret = [NSMutableArray array];
	
	for (SCHContentProfileItem *contentProfileItem in profileItem.ContentProfileItem) {
        if (contentProfileItem.booksAssignment) {
            NSDictionary *annotationContentItem = [self annotationContentItemFromBooksAssignment:contentProfileItem.booksAssignment forProfile:profileItem.ID];
            if (annotationContentItem != nil) {
                [ret addObject:annotationContentItem];
            }
        }
	}
	
	return ret;
}

- (NSDictionary *)annotationContentItemFromBooksAssignment:(SCHBooksAssignment *)booksAssignment
                                                forProfile:(NSNumber *)profileID;
{	
	NSMutableDictionary *ret = nil;
    
    if (booksAssignment != nil && profileID != nil) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSError *error = nil;
        
        [fetchRequest setEntity:[NSEntityDescription entityForName:kSCHProfileItem
                                            inManagedObjectContext:self.managedObjectContext]];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"ID == %@", profileID]];
        
        NSArray *profiles = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        [fetchRequest release];
        if (profiles == nil) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
        
        if ([profiles count] > 0) {
            SCHAppContentProfileItem *appContentProfileItem = [[profiles objectAtIndex:0] appContentProfileItemForBookIdentifier:
                                                               [booksAssignment bookIdentifier]];        
            
            id contentIdentifier = [booksAssignment valueForKey:kSCHLibreAccessWebServiceContentIdentifier];
            id contentIdentifierType = [booksAssignment valueForKey:kSCHLibreAccessWebServiceContentIdentifierType];
            id DRMQualifier = [booksAssignment valueForKey:kSCHLibreAccessWebServiceDRMQualifier];
            id format = [booksAssignment valueForKey:kSCHLibreAccessWebServiceFormat];
            id version = [booksAssignment valueForKey:kSCHLibreAccessWebServiceVersion];
            id averageRating = [booksAssignment valueForKey:kSCHLibreAccessWebServiceAverageRating];
            
            if (appContentProfileItem != nil && 
                contentIdentifier != nil && contentIdentifier != [NSNull null] && 
                contentIdentifierType != nil && contentIdentifierType != [NSNull null] && 
                DRMQualifier != nil && DRMQualifier != [NSNull null] &&
                format != nil && format != [NSNull null] && 
                version != nil && version != [NSNull null] &&
                averageRating != nil && averageRating != [NSNull null]) {
                ret = [NSMutableDictionary dictionary];
                
                [ret setObject:contentIdentifier forKey:kSCHLibreAccessWebServiceContentIdentifier];
                [ret setObject:contentIdentifierType forKey:kSCHLibreAccessWebServiceContentIdentifierType];
                [ret setObject:DRMQualifier forKey:kSCHLibreAccessWebServiceDRMQualifier];
                [ret setObject:format forKey:kSCHLibreAccessWebServiceFormat];
                [ret setObject:averageRating forKey:kSCHLibreAccessWebServiceAverageRating];
                
                NSMutableDictionary *privateAnnotation = [NSMutableDictionary dictionary];	
                
                NSDate *highlightsAfter = appContentProfileItem.LastHighlightAnnotationSync;
                NSDate *notesAfter = appContentProfileItem.LastNoteAnnotationSync;
                NSDate *bookmarksAfter = appContentProfileItem.LastBookmarkAnnotationSync;
                
                [privateAnnotation setObject:version forKey:kSCHLibreAccessWebServiceVersion];
                [privateAnnotation setObject:(highlightsAfter == nil ? [NSDate distantPast] : highlightsAfter)
                                      forKey:kSCHLibreAccessWebServiceHighlightsAfter];
                [privateAnnotation setObject:(notesAfter == nil ? [NSDate distantPast] : notesAfter)
                                      forKey:kSCHLibreAccessWebServiceNotesAfter];
                [privateAnnotation setObject:(bookmarksAfter == nil ? [NSDate distantPast] : bookmarksAfter)
                                      forKey:kSCHLibreAccessWebServiceBookmarksAfter];
                
                [ret setObject:privateAnnotation 
                        forKey:kSCHLibreAccessWebServicePrivateAnnotations];            
            }
        }
    }
    
	return ret;
}

- (void)openBookSyncForced:(BOOL)syncNow
           booksAssignment:(SCHBooksAssignment *)booksAssignment
                forProfile:(NSNumber *)profileID
       requestReadingStats:(BOOL)requestReadingStats
{
    NSAssert([NSThread isMainThread], @"Must be called on main thread");
    
    if ([self shouldSync] == YES) {
        if (syncNow == YES || [self.openBookSyncDelay shouldSync] == YES) {
            NSLog(@"Scheduling Open Book");
            [self.openBookSyncDelay syncStarted];
            
            if (booksAssignment != nil && profileID != nil) {
                NSDictionary *annotationContentItem = [self annotationContentItemFromBooksAssignment:booksAssignment forProfile:profileID];
                if (annotationContentItem != nil) {
                    [self.annotationSyncComponent addProfile:profileID
                                                   withBooks:[NSMutableArray arrayWithObject:annotationContentItem]];
                    [self addToQueue:self.annotationSyncComponent];

                    if (requestReadingStats == YES) {
                        [self.listReadingStatisticsSyncComponent addProfile:profileID
                                                                  withBooks:[NSMutableArray arrayWithObject:annotationContentItem]];
                        [self addToQueue:self.listReadingStatisticsSyncComponent];
                    }

                    [self kickQueue];
                }
            }
        } else {
            [self.openBookSyncDelay activateDelay];
        }
    } else {
        if (syncNow == YES || [self.openBookSyncDelay shouldSync] == YES) {
            [self.openBookSyncDelay syncStarted];

            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [[NSNotificationCenter defaultCenter] postNotificationName:SCHAnnotationSyncComponentDidCompleteNotification
                                                                    object:self];
                if (requestReadingStats == YES) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:SCHListReadingStatisticsSyncComponentDidCompleteNotification
                                                                        object:self];
                }
            });
        } else {
            [self.openBookSyncDelay activateDelay];
        }
    }
}

- (void)closeBookSyncForced:(BOOL)syncNow
            booksAssignment:(SCHBooksAssignment *)booksAssignment
                 forProfile:(NSNumber *)profileID
{
    NSAssert([NSThread isMainThread], @"Must be called on main thread");
    
    // save any changes first
    NSError *error = nil;    
    if ([self.managedObjectContext hasChanges] == YES &&
        ![self.managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    } 
    
    if ([self shouldSync] == YES) {
        if (syncNow == YES || [self.closeBookSyncDelay shouldSync] == YES) {
            NSLog(@"Scheduling Close Book");
            [self.closeBookSyncDelay syncStarted];

            if (booksAssignment != nil && profileID != nil) {
                NSDictionary *annotationContentItem = [self annotationContentItemFromBooksAssignment:booksAssignment forProfile:profileID];
                if (annotationContentItem != nil) {
                    [self.annotationSyncComponent addProfile:profileID
                                                   withBooks:[NSMutableArray arrayWithObject:annotationContentItem]];
                    [self addToQueue:self.annotationSyncComponent];

                    if ([self readingStatsActive] == YES) {
                        [self.readingStatsSyncComponent addProfile:profileID];
                        [self addToQueue:self.readingStatsSyncComponent];
                    } else {
                        NSLog(@"Reading Stats are OFF");
                    }

                    [self kickQueue];	
                }
            }
        } else {
            [self.closeBookSyncDelay activateDelay];
        }
    } else {
        if (syncNow == YES || [self.closeBookSyncDelay shouldSync] == YES) {
            [self.closeBookSyncDelay syncStarted];
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [[NSNotificationCenter defaultCenter] postNotificationName:SCHAnnotationSyncComponentDidCompleteNotification
                                                                    object:self];
                if ([self readingStatsActive] == YES) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:SCHReadingStatsSyncComponentDidCompleteNotification
                                                                        object:nil];
                }
            });
        } else {
            [self.closeBookSyncDelay activateDelay];
        }
    }
}

- (BOOL)readingStatsActive
{
    NSString *settingValue = [[SCHAppStateManager sharedAppStateManager] settingNamed:kSCHSettingItemSTORE_READ_STAT];
    
    return [settingValue boolValue];
}

- (void)backOfBookRecommendationSync
{
    NSAssert([NSThread isMainThread], @"Must be called on main thread");
    
    if ([self shouldSync] == YES) {	 
        NSLog(@"Scheduling Back of Book Recommendation Sync");
        
        [self addToQueue:self.recommendationSyncComponent];

        [self kickQueue];	
    } else {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [[NSNotificationCenter defaultCenter] postNotificationName:SCHRecommendationSyncComponentDidCompleteNotification
                                                                object:self];
        });
    }
}

- (void)topRatingsSync
{
    NSAssert([NSThread isMainThread], @"Must be called on main thread");
    
#if USE_TOP_RATINGS_FOR_PROFILE_RECOMMENDATIONS
    if ([self shouldSync] == YES) {
        NSLog(@"Scheduling Top Ratings Sync");

        [self addToQueue:self.topRatingsSyncComponent];

        [self kickQueue];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [[NSNotificationCenter defaultCenter] postNotificationName:SCHTopRatingsSyncComponentDidCompleteNotification
                                                                object:self];
        });
    }
#endif
}

- (BOOL)wishListSyncActive
{
    return [[SCHAppStateManager sharedAppStateManager] isCOPPACompliant];
}

- (void)wishListSyncForced:(BOOL)syncNow
{
    NSAssert([NSThread isMainThread], @"Must be called on main thread");

    if ([self wishListSyncActive] == YES) {
        if ([self shouldSync] == YES) {
            if (syncNow == YES || [self.wishlistSyncDelay shouldSync] == YES) {
                NSLog(@"Scheduling Wishlist Sync");
                [self.wishlistSyncDelay syncStarted];

                [self addToQueue:self.wishListSyncComponent];

                [self kickQueue];
            } else {
                [self.wishlistSyncDelay activateDelay];
            }
        } else {
            if (syncNow == YES || [self.wishlistSyncDelay shouldSync] == YES) {
                [self.wishlistSyncDelay syncStarted];

                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:SCHWishListSyncComponentDidCompleteNotification
                                                                        object:self];
                });
            } else {
                [self.wishlistSyncDelay activateDelay];
            }
        }
    } else {
        NSLog(@"Wishlists are OFF");
    }
}

- (void)deregistrationSync
{
    [self performFlushSaves];
}

#pragma mark - SCHComponent Delegate methods

- (void)authenticationDidSucceed
{
    NSAssert([NSThread isMainThread], @"Must be called on main thread");
    
    [self kickQueue];
}

- (void)component:(SCHComponent *)component didCompleteWithResult:(NSDictionary *)result
{
	if ([component isKindOfClass:[SCHContentSyncComponent class]] == YES) {
		[[NSUserDefaults standardUserDefaults] setBool:YES 
                                                forKey:kSCHUserDefaultsPerformedAccountSync];
        [[NSUserDefaults standardUserDefaults] synchronize];
	}
	
    [self removeFromQueue:(SCHSyncComponent *)component includeDependants:NO];

	[self kickQueue];
}

- (void)component:(SCHComponent *)component didFailWithError:(NSError *)error
{
    SCHSyncComponent *syncComponent = (SCHSyncComponent *)component;
    
    // push to the end of the queue to retry
    if (syncComponent.failureCount <= kSCHSyncManagerMaximumFailureRetries) {
        NSLog(@"%@ failed, moving to the end of the sync manager queue", [component class]);
        [self moveToEndOfQueue:syncComponent];
    } else {
        if ([component isKindOfClass:[SCHAnnotationSyncComponent class]] &&
            [(SCHAnnotationSyncComponent *)component nextProfile] == YES) {
            // try the next profile
            NSLog(@"%@ failed %d times, removing the current profile from the sync",
                  [syncComponent class],
                  kSCHSyncManagerMaximumFailureRetries);
        } else if ([component isKindOfClass:[SCHReadingStatsSyncComponent class]] &&
                   [(SCHReadingStatsSyncComponent *)component nextProfile] == YES) {
            // try the next profile
            NSLog(@"%@ failed %d times, removing the current profile from the sync",
                  [syncComponent class],
                  kSCHSyncManagerMaximumFailureRetries);
        } else if ([component isKindOfClass:[SCHListReadingStatisticsSyncComponent class]] &&
                   [(SCHListReadingStatisticsSyncComponent *)component nextProfile] == YES) {
            // try the next profile
            NSLog(@"%@ failed %d times, removing the current profile from the sync",
                  [syncComponent class],
                  kSCHSyncManagerMaximumFailureRetries);
        } else {
            // remove from the queue when we have exhausted the retries
            NSLog(@"%@ failed %d times, removing from the sync manager queue", 
                  [syncComponent class],
                  kSCHSyncManagerMaximumFailureRetries);
            [self removeFromQueue:syncComponent includeDependants:YES];
        }
    }
    
    // Kick the queue to continue but leave the heartbeat to trigger if it's the 
    // failed component
    SCHSyncComponent *queueHead = [self queueHead];
    if (queueHead != nil && queueHead != component) {
        [self kickQueue];
    }
}

#pragma mark - Queue methods

- (SCHSyncComponent *)queueHead
{
    SCHSyncComponent *ret = nil;
    
	if ([self.queue count] > 0) {
		ret = [self.queue objectAtIndex:0];
    }
    
    return ret;
}

- (void)addToQueue:(SCHSyncComponent *)component
{
    if (self.backgroundTaskIdentifier == UIBackgroundTaskInvalid) {
        self.backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{ 
            [self endBackgroundTask];
        }];			
    }
    
    self.flushSaveMode = NO;
    
	if ([self.queue containsObject:component] == NO) {
		NSLog(@"Adding %@ to the sync manager queue", [component class]);
        [component clearFailures];
		[self.queue addObject:component];
	}
}

- (void)moveToEndOfQueue:(SCHSyncComponent *)component
{
	if ([self.queue containsObject:component] == YES) {
		NSLog(@"Moving %@ to the end of the sync manager queue", [component class]);
        [self.queue removeObject:component];
        [self.queue addObject:component];
        
        NSMutableArray *moveToEndOfQueue = [NSMutableArray array];
        if ([component isKindOfClass:[SCHProfileSyncComponent class]] == YES) {            
            // if we have a content sync make sure it's performed after the profile sync
            for (SCHComponent *comp in self.queue) {
                if ([comp isKindOfClass:[SCHContentSyncComponent class]] == YES) {
                    [moveToEndOfQueue addObject:comp]; 
                    break;
                }
            }
            // also move the bookshelf sync make sure it's performed after the content sync            
            for (SCHComponent *comp in self.queue) {
                if ([comp isKindOfClass:[SCHBookshelfSyncComponent class]] == YES) {
                    [moveToEndOfQueue addObject:comp]; 
                    break;
                }
            }
            [self.queue removeObjectsInArray:moveToEndOfQueue];
            [self.queue addObjectsFromArray:moveToEndOfQueue];
        }        
	}
}

- (void)removeFromQueue:(SCHSyncComponent *)component includeDependants:(BOOL)includeDependants
{
    if ([component isKindOfClass:[SCHAnnotationSyncComponent class]] == YES &&
        [(SCHAnnotationSyncComponent *)component haveProfiles] == YES) {
        NSLog(@"Next annotation profile");
    } else if ([component isKindOfClass:[SCHReadingStatsSyncComponent class]] == YES &&
               [(SCHReadingStatsSyncComponent *)component haveProfiles] == YES) {
        NSLog(@"Next reading statistics profile");
    } else if ([component isKindOfClass:[SCHListReadingStatisticsSyncComponent class]] == YES &&
               [(SCHListReadingStatisticsSyncComponent *)component haveProfiles] == YES) {
        NSLog(@"Next list reading statistics profile");
    } else if ([self.queue containsObject:component] == YES) {
		NSLog(@"Removing %@ from the sync manager queue", [component class]);
        [self.queue removeObject:component];
        
        if (includeDependants) {
            NSMutableArray *removeFromQueue = [NSMutableArray array];
            // if we have a content sync make then remove it too as it's dependant
            if ([component isKindOfClass:[SCHProfileSyncComponent class]] == YES) {
                for (SCHComponent *comp in self.queue) {
                    if ([comp isKindOfClass:[SCHContentSyncComponent class]] == YES) {
                        [removeFromQueue addObject:comp];
                        break;
                    }
                }
                [self.queue removeObjectsInArray:removeFromQueue];
            }
        }
	}
    
	if ([self isQueueEmpty] == YES) {
        [self endBackgroundTask];
    }
}

- (void)kickQueue
{
    if (self.suspended) {
        NSLog(@"WARNING: Sync queue kicked whilst manager is suspended");
        return;
    }

    SCHSyncComponent *syncComponent = [self queueHead];
    
    if (syncComponent != nil) {
		NSLog(@"Sync component is %@", syncComponent);
		if ([syncComponent isSynchronizing] == NO) {
			NSLog(@"Kicking %@", [syncComponent class]);			
			// if the queue has stopped then start it up again
			[syncComponent synchronize];
		} else {
			NSLog(@"Kicked but already syncing %@", [syncComponent class]);
		}
	}  else {
        if ([self isQueueEmpty] == YES) {
            [self endBackgroundTask];			
        }    
        
        [[NSNotificationCenter defaultCenter] postNotificationName:SCHSyncManagerDidCompleteNotification 
                                                            object:self];        
        
        [self performDelayedSyncIfRequired];
	}
}

- (void)performDelayedSyncIfRequired
{
    if (self.flushSaveMode == NO) {
        if (self.accountSyncDelay.delayActive == YES) {
            [self accountSyncForced:NO requireDeviceAuthentication:NO];
        }
        if (self.bookshelfSyncDelay.delayActive == YES) {
            [self bookshelfSyncForced:NO];
        }
        if (self.openBookSyncDelay.delayActive == YES) {
            [self openBookSyncForced:NO booksAssignment:nil forProfile:nil requestReadingStats:NO];
        }
        if (self.closeBookSyncDelay.delayActive == YES) {
            [self closeBookSyncForced:NO booksAssignment:nil forProfile:nil];
        }
        if (self.wishlistSyncDelay.delayActive == YES) {
            [self wishListSyncForced:NO];
        }
    } 
}

- (BOOL)shouldSync
{
    return [[SCHAppStateManager sharedAppStateManager] canSync] && 
        [[NSFileManager defaultManager] BITfileSystemHasBytesAvailable:kSCHSyncManagerMinimumDiskSpaceRequiredForSync];
}

#pragma mark - Notification methods

- (void)applicationDidEnterBackground:(NSNotification *)notification 
{
    if (self.flushSaveMode == NO) {
        // force any delayed syncs to perform now
        [self.accountSyncDelay clearLastSyncDate];
        [self.bookshelfSyncDelay clearLastSyncDate];
        [self.openBookSyncDelay clearLastSyncDate];
        [self.closeBookSyncDelay clearLastSyncDate];
        [self.wishlistSyncDelay clearLastSyncDate];
        
        [self performDelayedSyncIfRequired];
    }
}

#pragma mark - Population methods

- (void)populateTestSampleStore
{
    NSAssert([NSThread isMainThread], @"Must be called on main thread");
    
    SCHPopulateDataStore *populateDataStore = [self populateDataStore];
    
    [populateDataStore populateTestSampleStore];
}

- (void)populateSampleStore
{
    NSAssert([NSThread isMainThread], @"Must be called on main thread");
    
    SCHPopulateDataStore *populateDataStore = [self populateDataStore];

    [populateDataStore populateSampleStore];
}

- (BOOL)populateSampleStoreFromManifestEntries:(NSArray *)entries;
{
    NSAssert([NSThread isMainThread], @"Must be called on main thread");
    
    SCHPopulateDataStore *populateDataStore = [self populateDataStore];
    return [populateDataStore populateSampleStoreFromManifestEntries:entries];
}

- (BOOL)populateSampleStoreFromImport
{
    BOOL importedBooks = NO;
    
    SCHPopulateDataStore *populateDataStore = [self populateDataStore];
    importedBooks = [populateDataStore populateFromImport] > 0;
    
    return importedBooks;
}

- (SCHPopulateDataStore *)populateDataStore
{
    SCHPopulateDataStore *ret = [[SCHPopulateDataStore alloc] init];
    
    ret.managedObjectContext = self.managedObjectContext;
    ret.profileSyncComponent = self.profileSyncComponent;
    ret.contentSyncComponent = self.contentSyncComponent;
    ret.bookshelfSyncComponent = self.bookshelfSyncComponent;
    ret.annotationSyncComponent = self.annotationSyncComponent;
    ret.readingStatsSyncComponent = self.readingStatsSyncComponent;
    ret.settingsSyncComponent = self.settingsSyncComponent;
    
    return [ret autorelease];
}

@end
