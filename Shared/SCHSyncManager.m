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
#import "SCHWishListSyncComponent.h"
#import "SCHProfileItem.h"
#import "SCHContentProfileItem.h"
#import "SCHUserDefaults.h"
#import "SCHAppStateManager.h"
#import "SCHCoreDataHelper.h"
#import "SCHPopulateDataStore.h"
#import "SCHAppContentProfileItem.h"
#import "SCHAuthenticationManager.h"
#import "SCHVersionDownloadManager.h"
#import "SCHLibreAccessConstants.h"

// Constants
NSString * const SCHSyncManagerDidCompleteNotification = @"SCHSyncManagerDidCompleteNotification";

static NSTimeInterval const kSCHSyncManagerHeartbeatInterval = 30.0;
static NSTimeInterval const kSCHLastFirstSyncInterval = -300.0;

static NSUInteger const kSCHSyncManagerMaximumFailureRetries = 3;

@interface SCHSyncManager ()

@property (nonatomic, retain) NSDate *lastFirstSyncEnded;
@property (nonatomic, assign) BOOL syncAfterDelay;
@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTaskIdentifier;
@property (nonatomic, assign) BOOL flushSaveMode;

- (void)endBackgroundTask;
- (void)updateAnnotationSync;
- (void)addAllProfilesToAnnotationSync;
- (NSMutableArray *)bookAnnotationsFromProfile:(SCHProfileItem *)profileItem;
- (NSDictionary *)annotationContentItemFromUserContentItem:(SCHUserContentItem *)userContentItem
                                                       forProfile:(NSNumber *)profileID;
- (SCHSyncComponent *)queueHead;
- (void)addToQueue:(SCHSyncComponent *)component;
- (void)moveToEndOfQueue:(SCHSyncComponent *)component;
- (void)removeFromQueue:(SCHSyncComponent *)component 
      includeDependants:(BOOL)includeDependants;
- (void)kickQueue;
- (BOOL)shouldSync;

- (SCHPopulateDataStore *)populateDataStore;

@property (retain, nonatomic) NSTimer *timer;
@property (retain, nonatomic) NSMutableArray *queue;
@property (retain, nonatomic) SCHProfileSyncComponent *profileSyncComponent; 
@property (retain, nonatomic) SCHContentSyncComponent *contentSyncComponent;
@property (retain, nonatomic) SCHBookshelfSyncComponent *bookshelfSyncComponent;
@property (retain, nonatomic) SCHAnnotationSyncComponent *annotationSyncComponent;
@property (retain, nonatomic) SCHReadingStatsSyncComponent *readingStatsSyncComponent;
@property (retain, nonatomic) SCHSettingsSyncComponent *settingsSyncComponent;
@property (retain, nonatomic) SCHWishListSyncComponent *wishListSyncComponent;

@end

@implementation SCHSyncManager

@synthesize lastFirstSyncEnded;
@synthesize syncAfterDelay;
@synthesize timer;
@synthesize queue;
@synthesize managedObjectContext;
@synthesize profileSyncComponent;
@synthesize contentSyncComponent;
@synthesize bookshelfSyncComponent;
@synthesize annotationSyncComponent;
@synthesize readingStatsSyncComponent;
@synthesize settingsSyncComponent;
@synthesize wishListSyncComponent;
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
		settingsSyncComponent = [[SCHSettingsSyncComponent alloc] init];		
		settingsSyncComponent.delegate = self;	
		wishListSyncComponent = [[SCHWishListSyncComponent alloc] init];
        wishListSyncComponent.delegate = self;
        
        backgroundTaskIdentifier = UIBackgroundTaskInvalid;	
        
        flushSaveMode = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(coreDataHelperManagedObjectContextDidChangeNotification:) 
                                                     name:SCHCoreDataHelperManagedObjectContextDidChangeNotification 
                                                   object:nil];	

        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(contentSyncComponentWillDelete:) 
                                                     name:SCHContentSyncComponentWillDeleteNotification 
                                                   object:nil];	        

        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(updateAnnotationSync) 
                                                     name:SCHContentSyncComponentDidCompleteNotification 
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
    
    [lastFirstSyncEnded release], lastFirstSyncEnded = nil;
	[timer release], timer = nil;
	[queue release], queue = nil;
	[profileSyncComponent release], profileSyncComponent = nil;
	[contentSyncComponent release], contentSyncComponent = nil;
	[bookshelfSyncComponent release], bookshelfSyncComponent = nil;
	[annotationSyncComponent release], annotationSyncComponent = nil;
	[readingStatsSyncComponent release], readingStatsSyncComponent = nil;
	[settingsSyncComponent release], settingsSyncComponent = nil;
    [wishListSyncComponent release], wishListSyncComponent = nil;
	
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
    self.wishListSyncComponent.managedObjectContext = newManagedObjectContext;
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
        self.settingsSyncComponent.saveOnly = flushSaveMode;
        self.wishListSyncComponent.saveOnly = flushSaveMode;
    }    
}

#pragma mark - NSManagedObjectContext Changed Notification

- (void)coreDataHelperManagedObjectContextDidChangeNotification:(NSNotification *)notification
{
    self.managedObjectContext = [[notification userInfo] objectForKey:SCHCoreDataHelperManagedObjectContext];
}

#pragma mark - Background Sync methods

- (void)startHeartbeat
{
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

- (void)clear
{
    [self.queue removeAllObjects];
    
	[self.profileSyncComponent clear];	
	[self.contentSyncComponent clear];	
	[self.bookshelfSyncComponent clear];
	[self.annotationSyncComponent clear];	
	[self.readingStatsSyncComponent clear];	
	[self.settingsSyncComponent clear];	
	[self.wishListSyncComponent clear];	
	
    self.lastFirstSyncEnded = nil;
    self.syncAfterDelay = NO;
    self.suspended = NO;
    
    [self endBackgroundTask];
        
	[[NSUserDefaults standardUserDefaults] setBool:NO 
                                            forKey:kSCHUserDefaultsPerformedFirstSyncUpToBooks];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

- (void)endBackgroundTask
{
    if (self.backgroundTaskIdentifier != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
        self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;			
    }    
}

- (BOOL)havePerformedFirstSyncUpToBooks
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:kSCHUserDefaultsPerformedFirstSyncUpToBooks];
}

- (void)firstSync:(BOOL)syncNow requireDeviceAuthentication:(BOOL)requireAuthentication
{
    // reset if the date has been changed in a backward motion
    if (self.lastFirstSyncEnded != nil &&
        [self.lastFirstSyncEnded compare:[NSDate date]] == NSOrderedDescending) {
        self.lastFirstSyncEnded = nil;
    }
    
    if (requireAuthentication) {
        [[SCHAuthenticationManager sharedAuthenticationManager] expireToken];
    }

    if ([self shouldSync] == YES) {	        
        if (syncNow == YES || self.lastFirstSyncEnded == nil || 
            [self.lastFirstSyncEnded timeIntervalSinceNow] < kSCHLastFirstSyncInterval) {
            NSLog(@"Scheduling First Sync");
            
            self.syncAfterDelay = NO;
            
            [self addToQueue:self.profileSyncComponent];
            [self addToQueue:self.contentSyncComponent];
            [self addToQueue:self.bookshelfSyncComponent];
                        
            [self addAllProfilesToAnnotationSync];
            if ([self.annotationSyncComponent haveProfiles] == YES) {
                [self addToQueue:self.annotationSyncComponent];		
            }
            
            [self addToQueue:self.readingStatsSyncComponent];
            [self addToQueue:self.settingsSyncComponent];
            
            [self addToQueue:self.wishListSyncComponent];
            
            [self kickQueue];	
        } else {
            self.syncAfterDelay = YES;
        }
    } else  {
        BOOL importedBooks = NO;
        
        if ([[SCHAppStateManager sharedAppStateManager] isSampleStore] == YES) {
            SCHPopulateDataStore *populateDataStore = [self populateDataStore];
            
            importedBooks = [populateDataStore populateFromImport] > 0;
        }

        if (syncNow == YES || importedBooks == YES || self.lastFirstSyncEnded == nil || 
            [self.lastFirstSyncEnded timeIntervalSinceNow] < kSCHLastFirstSyncInterval) {
            self.lastFirstSyncEnded = [NSDate date];
    
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [[NSNotificationCenter defaultCenter] postNotificationName:SCHProfileSyncComponentDidCompleteNotification 
                                                                    object:self];		
                [[NSNotificationCenter defaultCenter] postNotificationName:SCHContentSyncComponentDidCompleteNotification 
                                                                    object:self];		
                [[NSNotificationCenter defaultCenter] postNotificationName:SCHBookshelfSyncComponentDidCompleteNotification 
                                                                    object:self];		
                [[NSNotificationCenter defaultCenter] postNotificationName:SCHAnnotationSyncComponentDidCompleteNotification 
                                                                    object:self];		        
                [[NSNotificationCenter defaultCenter] postNotificationName:SCHReadingStatsSyncComponentDidCompleteNotification
                                                                    object:nil];    
                [[NSNotificationCenter defaultCenter] postNotificationName:SCHSettingsSyncComponentDidCompleteNotification
                                                                    object:nil];   
                [[NSNotificationCenter defaultCenter] postNotificationName:SCHWishListSyncComponentDidCompleteNotification
                                                                    object:nil];                   
            });
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
            }
            
            if ([self.annotationSyncComponent haveProfiles] == NO) {
                [self removeFromQueue:self.annotationSyncComponent includeDependants:YES];
            }        
        }
    }
}

// guarantee the annotation sync contains any new profiles or books
- (void)updateAnnotationSync
{
    if (self.flushSaveMode == NO && [self shouldSync] == YES) {	    
        [self addAllProfilesToAnnotationSync];
        if ([self.queue containsObject:self.annotationSyncComponent] == NO &&
            [self.annotationSyncComponent haveProfiles] == YES) {
            [self addToQueue:self.annotationSyncComponent];		
            [self kickQueue];	            
        }
    }
}

- (void)performFlushSaves
{
    if ([self shouldSync] == YES) {	  
        // go into flush save mode
        self.flushSaveMode = YES;
        
        NSLog(@"Performing Flush Saves");
        
        [self.queue removeAllObjects];
        
        [self addAllProfilesToAnnotationSync];
        if ([self.annotationSyncComponent haveProfiles] == YES) {
            [self.annotationSyncComponent synchronize];
        }
        [self.readingStatsSyncComponent synchronize];
        [self.profileSyncComponent synchronize];
        [self.contentSyncComponent synchronize];
        [self.wishListSyncComponent synchronize];
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

- (void)profileSync
{
    if ([self shouldSync] == YES) {	
        NSLog(@"Scheduling Change Profile");
        
        [self addToQueue:self.profileSyncComponent];
        
        [self kickQueue];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [[NSNotificationCenter defaultCenter] postNotificationName:SCHProfileSyncComponentDidCompleteNotification 
                                                                object:self];		
        });
    }
}

- (void)bookshelfSync
{
    if ([self shouldSync] == YES) {	
        NSLog(@"Scheduling Update Bookshelf");
        
        [self addToQueue:self.bookshelfSyncComponent];
        
        [self kickQueue];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [[NSNotificationCenter defaultCenter] postNotificationName:SCHBookshelfSyncComponentDidCompleteNotification 
                                                                object:self];		
        });        
    }
}

- (NSMutableArray *)bookAnnotationsFromProfile:(SCHProfileItem *)profileItem  
{
	NSMutableArray *ret = [NSMutableArray array];
	
	for (SCHContentProfileItem *contentProfileItem in profileItem.ContentProfileItem) {
        if (contentProfileItem.UserContentItem) {
            NSDictionary *annotationContentItem = [self annotationContentItemFromUserContentItem:contentProfileItem.UserContentItem forProfile:profileItem.ID];
            if (annotationContentItem != nil) {
                [ret addObject:annotationContentItem];
            }
        }
	}
	
	return ret;
}

- (NSDictionary *)annotationContentItemFromUserContentItem:(SCHUserContentItem *)userContentItem                                                        
                                                forProfile:(NSNumber *)profileID;
{	
	NSMutableDictionary *ret = nil;
    
    if (userContentItem != nil && profileID != nil) {
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
                                                               [userContentItem bookIdentifier]];        
            
            id contentIdentifier = [userContentItem valueForKey:kSCHLibreAccessWebServiceContentIdentifier];
            id contentIdentifierType = [userContentItem valueForKey:kSCHLibreAccessWebServiceContentIdentifierType];
            id DRMQualifier = [userContentItem valueForKey:kSCHLibreAccessWebServiceDRMQualifier];
            id format = [userContentItem valueForKey:kSCHLibreAccessWebServiceFormat];
            id version = [userContentItem valueForKey:kSCHLibreAccessWebServiceLastVersion];
            id averageRating = [userContentItem valueForKey:kSCHLibreAccessWebServiceAverageRating];
            
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

- (void)openDocumentSync:(SCHUserContentItem *)userContentItem 
          forProfile:(NSNumber *)profileID
{
    if ([self shouldSync] == YES) {	
        NSLog(@"Scheduling Open Document");
        
        if (userContentItem != nil && profileID != nil) {
            NSDictionary *annotationContentItem = [self annotationContentItemFromUserContentItem:userContentItem forProfile:profileID];
            if (annotationContentItem != nil) {
                [self.annotationSyncComponent addProfile:profileID 
                                               withBooks:[NSMutableArray arrayWithObject:annotationContentItem]];	
                [self addToQueue:self.annotationSyncComponent];
                
                [self kickQueue];
            }
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [[NSNotificationCenter defaultCenter] postNotificationName:SCHAnnotationSyncComponentDidCompleteNotification 
                                                                object:self];		        
        });        
    }
}

- (void)closeDocumentSync:(SCHUserContentItem *)userContentItem forProfile:(NSNumber *)profileID
{
    // save any changes first
    NSError *error = nil;    
    if ([self.managedObjectContext hasChanges] == YES &&
        ![self.managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    } 
    
    if ([self shouldSync] == YES) {	
        NSLog(@"Scheduling Close Document");
        
        if (userContentItem != nil && profileID != nil) {
            NSDictionary *annotationContentItem = [self annotationContentItemFromUserContentItem:userContentItem forProfile:profileID];
            if (annotationContentItem != nil) {
                [self.annotationSyncComponent addProfile:profileID 
                                               withBooks:[NSMutableArray arrayWithObject:annotationContentItem]];	
                [self addToQueue:self.annotationSyncComponent];
                [self addToQueue:self.readingStatsSyncComponent];
                
                [self kickQueue];	
            }
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [[NSNotificationCenter defaultCenter] postNotificationName:SCHAnnotationSyncComponentDidCompleteNotification 
                                                                object:self];		        
            [[NSNotificationCenter defaultCenter] postNotificationName:SCHReadingStatsSyncComponentDidCompleteNotification
                                                                object:nil];    
        });        
    }
}

#pragma mark - SCHComponent Delegate methods

- (void)authenticationDidSucceed
{
    [self kickQueue];
}

- (void)component:(SCHComponent *)component didCompleteWithResult:(NSDictionary *)result
{
	if ([component isKindOfClass:[SCHBookshelfSyncComponent class]] == YES) {
		[[NSUserDefaults standardUserDefaults] setBool:YES 
                                                forKey:kSCHUserDefaultsPerformedFirstSyncUpToBooks];
        [[NSUserDefaults standardUserDefaults] synchronize];
	}
	
    [self removeFromQueue:(SCHSyncComponent *)component includeDependants:NO];

    // the settings sync is the last component in the firstSync so signal it is complete
    if ([component isKindOfClass:[SCHSettingsSyncComponent class]] == YES) {
        self.lastFirstSyncEnded = [NSDate date];
    }
    
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
        if (self.flushSaveMode == NO && self.syncAfterDelay == YES) {
            [self firstSync:NO requireDeviceAuthentication:NO];   
        }
	}
}

- (BOOL)shouldSync
{
    return [[SCHAppStateManager sharedAppStateManager] canSync];
}

#pragma mark - Population methods

- (void)populateTestSampleStore
{
    SCHPopulateDataStore *populateDataStore = [self populateDataStore];
    
    [populateDataStore populateTestSampleStore];
}

- (void)populateSampleStore
{
    SCHPopulateDataStore *populateDataStore = [self populateDataStore];
    
    [populateDataStore populateSampleStore];
}

- (BOOL)populateSampleStoreFromManifestEntries:(NSArray *)entries;
{
    SCHPopulateDataStore *populateDataStore = [self populateDataStore];
    return [populateDataStore populateSampleStoreFromManifestEntries:entries];
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
