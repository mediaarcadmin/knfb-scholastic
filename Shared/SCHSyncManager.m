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
#import "SCHLocalDebugXPSReader.h"
#import "SCHAppBook.h"

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

- (void)checkPopulations;
- (void)populateLocalDebugStore;
- (void)populateWithTestInformation;
- (void)addBook:(NSDictionary *)book forProfiles:(NSArray *)profileIDs;
- (void)populateFromImport;
- (void)setAppStateForSample;
- (NSDictionary *)profileItemWith:(NSInteger)profileID
                            title:(NSString *)title 
                         password:(NSString *)password
                              age:(NSUInteger)age 
                        bookshelf:(SCHBookshelfStyles)bookshelf;
- (NSDictionary *)contentMetaDataItemWith:(NSString *)contentIdentifier
                                    title:(NSString *)title
                                   author:(NSString *)author
                               pageNumber:(NSInteger)pageNumber
                                 fileSize:(long long)fileSize
                              drmQualifer:(SCHDRMQualifiers)drmQualifer
                                 coverURL:(NSString *)coverURL
                               contentURL:(NSString *)contentURL
                                 enhanced:(BOOL)enhanced;
- (NSDictionary *)userContentItemWith:(NSString *)contentIdentifier 
                          drmQualifer:(SCHDRMQualifiers)drmQualifer
                            profileIDs:(NSArray *)profileIDs;
- (NSArray *)listXPSFilesFrom:(NSString *)directory;
- (void)populateBook:(NSString *)xpsFilePath profileIDs:(NSArray *)profileIDs;

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
        [self checkPopulations];

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
    }
}

- (void)changeProfile
{
    if ([self shouldSync] == YES) {	
        NSLog(@"Scheduling Change Profile");
        
        [self addToQueue:self.profileSyncComponent];
        
        [self kickQueue];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:SCHProfileSyncComponentDidCompleteNotification 
                                                            object:self];		
    }
}

- (void)updateBookshelf
{
    if ([self shouldSync] == YES) {	
        NSLog(@"Scheduling Update Bookshelf");
        
        [self addToQueue:self.bookshelfSyncComponent];
        
        [self kickQueue];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:SCHBookshelfSyncComponentDidCompleteNotification 
                                                            object:self];		
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
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:SCHAnnotationSyncComponentDidCompleteNotification 
                                                            object:self];		        
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
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:SCHAnnotationSyncComponentDidCompleteNotification 
                                                            object:self];		        
        [[NSNotificationCenter defaultCenter] postNotificationName:SCHReadingStatsSyncComponentDidCompleteNotification
                                                            object:nil];    
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

#pragma mark - Population methods

- (void)checkPopulations
{
    if ([[self.profileSyncComponent localProfiles] count] < 1) {
        [self populateLocalDebugStore];        
    }
    [self populateFromImport];
}

- (void)populateLocalDebugStore
{
    [self populateWithTestInformation];    
}

- (void)populateWithTestInformation
{
    NSError *error = nil;
    
    // Younger bookshelf    
    NSDictionary *youngerProfileItem = [self profileItemWith:1
                                                       title:NSLocalizedString(@"Bookshelf #1", nil) 
                                                    password:@"pass"                                 
                                                         age:5 
                                                   bookshelf:kSCHBookshelfStyleYoungChild];
    [self.profileSyncComponent addProfile:youngerProfileItem];
    
    // Older bookshelf    
    NSDictionary *olderProfileItem = [self profileItemWith:2
                                                     title:NSLocalizedString(@"Bookshelf #2", nil) 
                                                  password:@"pass"                                 
                                                       age:14 
                                                 bookshelf:kSCHBookshelfStyleOlderChild];
    [self.profileSyncComponent addProfile:olderProfileItem];
    
    NSArray *youngerBookshelfOnly = [NSArray arrayWithObject:[youngerProfileItem objectForKey:kSCHLibreAccessWebServiceID]];
    NSArray *olderBookshelfOnly = [NSArray arrayWithObject:[olderProfileItem objectForKey:kSCHLibreAccessWebServiceID]];
    NSArray *allBookshelves = [NSArray arrayWithObjects:[youngerProfileItem objectForKey:kSCHLibreAccessWebServiceID],
                               [olderProfileItem objectForKey:kSCHLibreAccessWebServiceID], 
                               nil];
    
    // Books
    NSDictionary *book1 = [self contentMetaDataItemWith:@"9780545283502"
                                                  title:@"Classic Goosebumps: Night of the Living Dummy"
                                                 author:@"R.L. Stine"
                                             pageNumber:162
                                               fileSize:4142171
                                            drmQualifer:kSCHDRMQualifiersFullNoDRM
                                               coverURL:@"9780545283502.NightOfTheLivingDummy.jpg"
                                             contentURL:@"9780545283502.NightOfTheLivingDummy.xps"
                                               enhanced:YES];
    [self addBook:book1 forProfiles:olderBookshelfOnly];
    
    NSDictionary *book2 = [self contentMetaDataItemWith:@"9780545287012"
                                                  title:@"Scholastic Reader Level 1: Clifford and the Halloween Parade"
                                                 author:@"Norman Bridwell"
                                             pageNumber:34
                                               fileSize:5149305
                                            drmQualifer:kSCHDRMQualifiersFullNoDRM
                                               coverURL:@"9780545287012_r1.HalloweenParade.jpg"
                                             contentURL:@"9780545287012_r1.HalloweenParade.xps"
                                               enhanced:YES];
    [self addBook:book2 forProfiles:youngerBookshelfOnly];
    
    NSDictionary *book3 = [self contentMetaDataItemWith:@"9780545289726"
                                                  title:@"Ollie's New Tricks"
                                                 author:@"by True Kelley, illustrated by True Kelley"
                                             pageNumber:34
                                               fileSize:21251026
                                            drmQualifer:kSCHDRMQualifiersFullNoDRM
                                               coverURL:@"9780545289726_r1.OlliesNewTricks.jpg"
                                             contentURL:@"9780545289726_r1.OlliesNewTricks.xps"
                                               enhanced:YES];
    [self addBook:book3 forProfiles:youngerBookshelfOnly];
    
    NSDictionary *book4 = [self contentMetaDataItemWith:@"9780545345019"
                                                  title:@"Allie Finkle's Rules for Girls: Moving Day"
                                                 author:@"Meg Cabot"
                                             pageNumber:258
                                               fileSize:5620118
                                            drmQualifer:kSCHDRMQualifiersFullNoDRM
                                               coverURL:@"9780545345019_r1.AllieFinkleMovingDay.jpg"
                                             contentURL:@"9780545345019_r1.AllieFinkleMovingDay.xps"
                                               enhanced:YES];
    [self addBook:book4 forProfiles:olderBookshelfOnly];
    
    NSDictionary *book5 = [self contentMetaDataItemWith:@"9780545327619"
                                                  title:@"Who Will Carve the Turkey This Thanksgiving?"
                                                 author:@"by Jerry Pallotta, illustrated by David Biedrzycki"
                                             pageNumber:35
                                               fileSize:5808879
                                            drmQualifer:kSCHDRMQualifiersFullNoDRM
                                               coverURL:@"9780545327619_r1.WhoWillCarveTheTurkey.jpg"
                                             contentURL:@"9780545327619_r1.WhoWillCarveTheTurkey.xps"
                                               enhanced:YES];
    [self addBook:book5 forProfiles:youngerBookshelfOnly];
    
    NSDictionary *book6 = [self contentMetaDataItemWith:@"9780545366779"
                                                  title:@"The 39 Clues Book 1: The Maze of Bones"
                                                 author:@"Rick Riordan"
                                             pageNumber:247
                                               fileSize:9280193
                                            drmQualifer:kSCHDRMQualifiersFullNoDRM
                                               coverURL:@"9780545366779.2.MazeOfBones.jpg"
                                             contentURL:@"9780545366779.2.MazeOfBones.xps"
                                               enhanced:YES];
    [self addBook:book6 forProfiles:olderBookshelfOnly];
    
    NSDictionary *book7 = [self contentMetaDataItemWith:@"9780545308656"
                                                  title:@"Scholastic Reader Level 3: Stablemates: Patch"
                                                 author:@"by Kristin Earhart, illustrated by Lisa Papp"
                                             pageNumber:42
                                               fileSize:11099476
                                            drmQualifer:kSCHDRMQualifiersFullNoDRM
                                               coverURL:@"9780545308656.6.StableMatesPatch.jpg"
                                             contentURL:@"9780545308656.6.StableMatesPatch.xps"
                                               enhanced:YES];
    [self addBook:book7 forProfiles:allBookshelves];
    
    NSDictionary *book8 = [self contentMetaDataItemWith:@"9780545368896"
                                                  title:@"The Secrets of Droon #1: The Hidden Stairs and the Magic Carpet"
                                                 author:@"by Tony Abbott, illustrated by Tim Jessell"
                                             pageNumber:98
                                               fileSize:2794624
                                            drmQualifer:kSCHDRMQualifiersFullNoDRM
                                               coverURL:@"9780545368896_r1.TheHiddenStairs.jpg"
                                             contentURL:@"9780545368896_r1.TheHiddenStairs.xps"
                                               enhanced:YES];
    [self addBook:book8 forProfiles:olderBookshelfOnly]; 
    
    if ([self.managedObjectContext save:&error] == NO) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }     
}

- (void)addBook:(NSDictionary *)book forProfiles:(NSArray *)profileIDs
{
    if (book != nil && profileIDs != nil && [profileIDs count] > 0) {
        [self.contentSyncComponent addUserContentItem:[self userContentItemWith:[book objectForKey:kSCHLibreAccessWebServiceContentIdentifier]
                                                                    drmQualifer:[[book objectForKey:kSCHLibreAccessWebServiceDRMQualifier] DRMQualifierValue]
                                                                     profileIDs:profileIDs]];
        
        [self.bookshelfSyncComponent addContentMetadataItem:book];
    }
}

- (void)populateFromImport
{
    NSError *error = nil;
    NSArray *documentDirectorys = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = ([documentDirectorys count] > 0) ? [documentDirectorys objectAtIndex:0] : nil;

    if (documentDirectory != nil) {
        for (NSString *xpsFilePath in [self listXPSFilesFrom:documentDirectory]) {
            // use the first profile which we expect to be profileID 1
            [self populateBook:xpsFilePath profileIDs:[NSArray arrayWithObject:[NSNumber numberWithInteger:1]]];
        }
        
        if ([self.managedObjectContext save:&error] == NO) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }         
        
        // fire off processing
        [[NSNotificationCenter defaultCenter] postNotificationName:SCHBookshelfSyncComponentDidCompleteNotification object:self];
    }
}

- (NSArray *)listXPSFilesFrom:(NSString *)directory
{
    NSMutableArray *ret = nil;
    NSError *error = nil;
    
    NSArray *directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directory 
                                                                                     error:&error];	
	if (error != nil) {
		NSLog(@"Error retreiving XPS files: %@", [error localizedDescription]);
	} else {
        ret = [NSMutableArray arrayWithCapacity:[directoryContents count]];
        for (NSString *fileName in [directoryContents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.xps'"]]) {
            [ret addObject:[directory stringByAppendingPathComponent:fileName]];
        }        
    }
    
    return(ret);
}

#pragma mark - Sample bookshelf population methods

- (void)populateSampleStore
{
    NSError *error = nil;

    [self setAppStateForSample];    

    // Younger bookshelf    
    NSDictionary *youngerProfileItem = [self profileItemWith:1
                                                       title:NSLocalizedString(@"Younger kids' bookshelf (3-6)", nil) 
                                                    password:@"pass"                                 
                                                         age:5 
                                                   bookshelf:kSCHBookshelfStyleYoungChild];
    [self.profileSyncComponent addProfile:youngerProfileItem];
    
    NSDictionary *youngerBook = [self contentMetaDataItemWith:@"0-393-05158-7"
                                                        title:@"A Christmas Carol"
                                                       author:@"Charles Dickens"
                                                   pageNumber:1
                                                     fileSize:862109
                                                  drmQualifer:kSCHDRMQualifiersSample
                                                     coverURL:@"http://bitwink.com/private/ChristmasCarol.jpg"
                                                   contentURL:@"http://bitwink.com/private/ChristmasCarol.xps"
                                                     enhanced:NO];
    [self addBook:youngerBook forProfiles:[NSArray arrayWithObject:[youngerProfileItem objectForKey:kSCHLibreAccessWebServiceID]]];
    
    // Older bookshelf    
    NSDictionary *olderProfileItem = [self profileItemWith:2
                                                     title:NSLocalizedString(@"Older kids' bookshelf (7+)", nil) 
                                                  password:@"pass"
                                                       age:14 
                                                 bookshelf:kSCHBookshelfStyleOlderChild];
    [self.profileSyncComponent addProfile:olderProfileItem];
    
    NSDictionary *olderBook = [self contentMetaDataItemWith:@"978-0-14-143960-0"
                                                      title:@"A Tale of Two Cities"
                                                     author:@"Charles Dickens"
                                                 pageNumber:1
                                                   fileSize:4023944
                                                drmQualifer:kSCHDRMQualifiersSample
                                                   coverURL:@"http://bitwink.com/private/ATaleOfTwoCities.jpg"
                                                 contentURL:@"http://bitwink.com/private/ATaleOfTwoCities.xps"
                                                   enhanced:NO];
    [self addBook:olderBook forProfiles:[NSArray arrayWithObject:[olderProfileItem objectForKey:kSCHLibreAccessWebServiceID]]];
    
    if ([self.managedObjectContext save:&error] == NO) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }     
}

- (void)populateLocalDebugSampleStore
{
    [self setAppStateForSample];
    [self populateWithTestInformation];     
}

- (void)setAppStateForSample
{
    SCHAppState *appState = [SCHAppStateManager sharedAppStateManager].appState;
    
    appState.ShouldSync = [NSNumber numberWithBool:NO];
    appState.ShouldAuthenticate = [NSNumber numberWithBool:NO];
    appState.DataStoreType = [NSNumber numberWithDataStoreType:kSCHDataStoreTypesSample];
}

#pragma mark - Core Data population methods

- (NSDictionary *)profileItemWith:(NSInteger)profileID
                            title:(NSString *)title 
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
    [ret setObject:[NSNumber numberWithInteger:profileID] forKey:kSCHLibreAccessWebServiceID];
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
                              drmQualifer:(SCHDRMQualifiers)drmQualifer
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
    [ret setObject:[NSNumber numberWithDRMQualifier:drmQualifer] forKey:kSCHLibreAccessWebServiceDRMQualifier];
    [ret setObject:(coverURL == nil ? (id)[NSNull null] : coverURL) forKey:kSCHLibreAccessWebServiceCoverURL];
    [ret setObject:(contentURL == nil ? (id)[NSNull null] : contentURL) forKey:kSCHLibreAccessWebServiceContentURL];
    [ret setObject:[NSNull null] forKey:kSCHLibreAccessWebServiceeReaderCategories];
    [ret setObject:[NSNumber numberWithBool:enhanced] forKey:kSCHLibreAccessWebServiceEnhanced];

    return(ret);    
}

- (NSDictionary *)userContentItemWith:(NSString *)contentIdentifier
                          drmQualifer:(SCHDRMQualifiers)drmQualifer
                            profileIDs:(NSArray *)profileIDs
{
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];    
    NSDate *dateNow = [NSDate date];

    NSMutableArray *profileList = [NSMutableArray arrayWithCapacity:[profileIDs count]];
    NSMutableArray *orderList = [NSMutableArray arrayWithCapacity:[profileIDs count]];    
    NSInteger orderID = 1;
    for (NSNumber *profileID in profileIDs) {
        NSMutableDictionary *profileItem = [NSMutableDictionary dictionary];
        [profileItem setObject:profileID forKey:kSCHLibreAccessWebServiceProfileID];        
        [profileItem setObject:[NSNumber numberWithBool:NO] forKey:kSCHLibreAccessWebServiceIsFavorite];        
        [profileItem setObject:[NSNumber numberWithInteger:0] forKey:kSCHLibreAccessWebServiceLastPageLocation];            
        [profileItem setObject:dateNow forKey:kSCHLibreAccessWebServiceLastModified];        
        
        [profileList addObject:profileItem];
        
        NSMutableDictionary *orderItem = [NSMutableDictionary dictionary];
        [orderItem setObject:[NSString stringWithFormat:@"%lx", orderID++] forKey:kSCHLibreAccessWebServiceOrderID];        
        [orderItem setObject:dateNow forKey:kSCHLibreAccessWebServiceOrderDate];                
    }

    [ret setObject:contentIdentifier forKey:kSCHLibreAccessWebServiceContentIdentifier];
    [ret setObject:[NSNumber numberWithContentIdentifierType:kSCHContentItemContentIdentifierTypesISBN13] forKey:kSCHLibreAccessWebServiceContentIdentifierType];
    [ret setObject:[NSNumber numberWithDRMQualifier:drmQualifer] forKey:kSCHLibreAccessWebServiceDRMQualifier];
    [ret setObject:@"XPS" forKey:kSCHLibreAccessWebServiceFormat];
    [ret setObject:@"1" forKey:kSCHLibreAccessWebServiceVersion];    
    [ret setObject:profileList forKey:kSCHLibreAccessWebServiceProfileList];
    [ret setObject:orderList forKey:kSCHLibreAccessWebServiceOrderList];        
    [ret setObject:dateNow forKey:kSCHLibreAccessWebServiceLastModified];
    [ret setObject:[NSNumber numberWithBool:NO] forKey:kSCHLibreAccessWebServiceDefaultAssignment];
    
    return(ret);    
}

- (void)populateBook:(NSString *)xpsFilePath profileIDs:(NSArray *)profileIDs
{
    NSError *error = nil;
    SCHLocalDebugXPSReader *localDebugXPSReader = [[SCHLocalDebugXPSReader alloc] initWithPath:xpsFilePath];
    NSDictionary *book = [self contentMetaDataItemWith:localDebugXPSReader.ISBN
                                                 title:localDebugXPSReader.title
                                                author:localDebugXPSReader.author
                                            pageNumber:localDebugXPSReader.pageCount
                                              fileSize:localDebugXPSReader.fileSize
                                           drmQualifer:kSCHDRMQualifiersFullNoDRM
                                              coverURL:nil
                                            contentURL:nil
                                              enhanced:localDebugXPSReader.enhanced];
    
    [self.contentSyncComponent addUserContentItem:[self userContentItemWith:[book objectForKey:kSCHLibreAccessWebServiceContentIdentifier] 
                                                                drmQualifer:[[book objectForKey:kSCHLibreAccessWebServiceDRMQualifier] DRMQualifierValue]                                                    
                                                                 profileIDs:profileIDs]];
    SCHContentMetadataItem *newContentMetadataItem = [self.bookshelfSyncComponent addContentMetadataItem:book];
    newContentMetadataItem.FileName = [xpsFilePath lastPathComponent];
    // copy the XPS file from the bundle
    [[NSFileManager defaultManager] copyItemAtPath:xpsFilePath 
                                            toPath:[newContentMetadataItem.AppBook xpsPath] 
                                             error:&error];        
    if (error != nil) {
        NSLog(@"Error copying XPS file from bundle: %@, %@", error, [error userInfo]);
    }
    
    newContentMetadataItem.AppBook.State = [NSNumber numberWithInt:SCHBookProcessingStateNoCoverImage];
    
    [localDebugXPSReader release], localDebugXPSReader = nil;
}

@end
