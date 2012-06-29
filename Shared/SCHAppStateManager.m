//
//  SCHAppStateManager.m
//  Scholastic
//
//  Created by John S. Eddie on 08/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHAppStateManager.h"

#import <CoreData/CoreData.h>
#import "SCHCoreDataHelper.h"
#import "NSNumber+ObjectTypes.h"

@interface SCHAppStateManager()

- (SCHAppState *)createAppStateIfNeeded;

@property (nonatomic, retain) SCHAppState *cachedAppState;
@property (nonatomic, retain) NSNumber *cachedCanSync;
@property (nonatomic, retain) NSNumber *cachedCanSyncNotes;
@property (nonatomic, retain) NSNumber *cachedCOPPACompliant;
@property (nonatomic, retain) NSNumber *cachedCanAuthenticate;
@property (nonatomic, retain) NSNumber *cachedServerDateDelta;
@property (nonatomic, retain) NSNumber *cachedDataStoreType;
@property (nonatomic, copy) NSString *cachedLastKnownAuthToken;
@property (nonatomic, copy) NSDate *cachedLastRemoteManifestUpdateDate;
@property (nonatomic, retain) NSNumber *cachedLastScholasticAuthenticationErrorCode;

// thread-safe access to appstate object; the block is executed synchronously so may make
// changes to any __block storage locals
- (void)performWithAppState:(void (^)(SCHAppState *appState))block;

// thread-safe access to appstate object followed by save; the block is executed asynchronously
- (void)performWithAppStateAndSave:(void (^)(SCHAppState *appState))block;

- (void)warmupCachedProperties;
- (void)clearCachedProperties;

@end

@implementation SCHAppStateManager

@synthesize managedObjectContext;
@synthesize cachedAppState;
@synthesize cachedCanSync;
@synthesize cachedCanSyncNotes;
@synthesize cachedCOPPACompliant;
@synthesize cachedCanAuthenticate;
@synthesize cachedServerDateDelta;
@synthesize cachedDataStoreType;
@synthesize cachedLastKnownAuthToken;
@synthesize cachedLastRemoteManifestUpdateDate;
@synthesize cachedLastScholasticAuthenticationErrorCode;

#pragma mark - Singleton Instance methods

+ (SCHAppStateManager *)sharedAppStateManager
{
    static dispatch_once_t pred;
    static SCHAppStateManager *sharedAppStateManager = nil;
    
    dispatch_once(&pred, ^{
        sharedAppStateManager = [[super allocWithZone:NULL] init];		
    });
	
    return(sharedAppStateManager);
}

#pragma mark - Object lifecycle

- (id)init
{
    self = [super init];
    if (self) {
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
    
    [cachedAppState release], cachedAppState = nil;
    [cachedCanSync release], cachedCanSync = nil;
    [cachedCanSyncNotes release], cachedCanSyncNotes = nil;
    [cachedCOPPACompliant release], cachedCOPPACompliant = nil;
    [cachedCanAuthenticate release], cachedCanAuthenticate = nil;
    [cachedServerDateDelta release], cachedServerDateDelta = nil;
    [cachedDataStoreType release], cachedDataStoreType = nil;
    [cachedLastKnownAuthToken release], cachedLastKnownAuthToken = nil;
    [cachedLastRemoteManifestUpdateDate release], cachedLastRemoteManifestUpdateDate = nil;
    [cachedLastScholasticAuthenticationErrorCode release], cachedLastScholasticAuthenticationErrorCode = nil;
    
    [managedObjectContext release], managedObjectContext = nil;
    
    [super dealloc];
}

#pragma mark - methods

- (void)setManagedObjectContext:(NSManagedObjectContext *)newManagedObjectContext
{
    NSAssert([NSThread isMainThread] == YES, @"setManagedObjectContext SHOULD be executed on the main thread");
    
    if (managedObjectContext != newManagedObjectContext) {
        [managedObjectContext release];
        managedObjectContext = [newManagedObjectContext retain];
        if (managedObjectContext != nil) {
            self.cachedAppState = [self createAppStateIfNeeded];
            [self warmupCachedProperties];
        } else {
            self.cachedAppState = nil;
            [self clearCachedProperties];
        }
    }
}

- (SCHAppState *)appState
{
    NSAssert([NSThread isMainThread] == YES, @"appState SHOULD be executed on the main thread");
    
    return self.cachedAppState;    
}

- (void)warmupCachedProperties
{
    __block BOOL canSync = NO;
    __block BOOL syncNotes = NO;
    __block BOOL coppa = NO;
    __block BOOL canAuthenticate = NO;    
    __block NSTimeInterval serverDateDelta = 0.0;
    // Assume a standard store if there is no app state    
    __block SCHDataStoreTypes dataStoreType = kSCHDataStoreTypesStandard;
    __block NSString *lastKnownAuthToken = nil;
    __block NSDate *lastRemoteManifestUpdateDate = nil;
    __block SCHScholasticAuthenticationWebServiceErrorCode lastScholasticAuthenticationErrorCode = kSCHScholasticAuthenticationWebServiceErrorCodeNone;
    
    [self performWithAppState:^(SCHAppState *appState) {
        if (appState != nil) {
            canSync = [appState.ShouldSync boolValue];
            syncNotes = [appState.ShouldSyncNotes boolValue]; 
            coppa = [appState.isCOPPACompliant boolValue];  
            canAuthenticate = [appState.ShouldAuthenticate boolValue];
            serverDateDelta = [appState.ServerDateDelta doubleValue];
            dataStoreType = [appState.DataStoreType dataStoreTypeValue];
            lastKnownAuthToken = appState.LastKnownAuthToken;
            lastRemoteManifestUpdateDate = appState.LastRemoteManifestUpdateDate;
            lastScholasticAuthenticationErrorCode = [appState.lastScholasticAuthenticationErrorCode integerValue];
        }
    }];
#if IGNORE_COPPA_COMPLIANCE
    syncNotes = YES;
    coppa = YES;
#endif
    
    @synchronized (self) {
        self.cachedCanSync = [NSNumber numberWithBool:canSync];
        self.cachedCanSyncNotes = [NSNumber numberWithBool:syncNotes];   
        self.cachedCOPPACompliant = [NSNumber numberWithBool:coppa]; 
        self.cachedCanAuthenticate = [NSNumber numberWithBool:canAuthenticate];
        self.cachedServerDateDelta = [NSNumber numberWithDouble:serverDateDelta];   
        self.cachedDataStoreType = [NSNumber numberWithDataStoreType:dataStoreType];
        self.cachedLastKnownAuthToken = lastKnownAuthToken;
        self.cachedLastRemoteManifestUpdateDate = lastRemoteManifestUpdateDate;
        self.cachedLastScholasticAuthenticationErrorCode = [NSNumber numberWithInt:lastScholasticAuthenticationErrorCode];
    }    
}

- (void)clearCachedProperties
{
    @synchronized (self) {
        self.cachedCanSync = nil;
        self.cachedCanSyncNotes = nil;   
        self.cachedCOPPACompliant = nil; 
        self.cachedCanAuthenticate = nil;
        self.cachedServerDateDelta = nil;   
        self.cachedDataStoreType = nil;
        self.cachedLastKnownAuthToken = nil;
        self.cachedLastRemoteManifestUpdateDate = nil;
        self.cachedLastScholasticAuthenticationErrorCode = nil;
    }    
}

- (SCHAppState *)createAppStateIfNeeded
{
    NSAssert([NSThread isMainThread] == YES, @"createAppStateIfNeeded SHOULD be executed on the main thread");
    SCHAppState *ret = nil;
    
    NSError *error = nil;
    
    NSEntityDescription *entityDescription = [NSEntityDescription 
                                              entityForName:kSCHAppState
                                              inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *fetchRequest = [entityDescription.managedObjectModel 
                                    fetchRequestTemplateForName:kSCHAppStatefetchAppState];
    
    NSArray *state = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];	
    if (state == nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }

    if ([state count] < 1) {
        ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHAppState 
                                      inManagedObjectContext:self.managedObjectContext];
        
        if ([self.managedObjectContext save:&error] == NO) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }     
    } else {
        ret = [state objectAtIndex:0];
    }
    
    if (ret == nil) {
        NSLog(@"WARNING!!! App state is nil. This will lead to unexpected behaviour.");
    }
    
    return ret;
}

- (BOOL)canSync
{
    BOOL ret = NO;
    
    @synchronized (self) {
        if (self.cachedCanSync != nil) {
            ret = [self.cachedCanSync boolValue];
        }
    }
    
    return ret;
}

- (void)setCanSync:(BOOL)sync
{
    @synchronized (self) {
        self.cachedCanSync = [NSNumber numberWithBool:sync];
    }
    
    [self performWithAppStateAndSave:^(SCHAppState *appState) {
        [appState setShouldSync:[NSNumber numberWithBool:sync]];
    }];
}

- (BOOL)canSyncNotes
{
    BOOL ret = NO;
    
    @synchronized (self) {
        if (self.cachedCanSyncNotes != nil) {
            ret = [self.cachedCanSyncNotes boolValue];
        }
    }
    
    return ret;
}

- (void)setCanSyncNotes:(BOOL)sync
{
    @synchronized (self) {
        self.cachedCanSyncNotes = [NSNumber numberWithBool:sync];
    }

    [self performWithAppStateAndSave:^(SCHAppState *appState) {
        [appState setShouldSyncNotes:[NSNumber numberWithBool:sync]];
    }];
}

- (BOOL)isCOPPACompliant
{
    BOOL ret = NO;
    
    @synchronized (self) {
        if (self.cachedCOPPACompliant != nil) {
            ret = [self.cachedCOPPACompliant boolValue];
        }
    }
    
    return ret;
}

- (void)setCOPPACompliant:(BOOL)coppa
{
    @synchronized (self) {
        self.cachedCOPPACompliant = [NSNumber numberWithBool:coppa];
    }
    
    [self performWithAppStateAndSave:^(SCHAppState *appState) {
        [appState setIsCOPPACompliant:[NSNumber numberWithBool:coppa]];
    }];
}

- (BOOL)canAuthenticate
{
    BOOL ret = NO;
    
    @synchronized (self) {
        if (self.cachedCanAuthenticate != nil) {
            ret = [self.cachedCanAuthenticate boolValue];
        }
    }
    
    return ret;  
}

- (void)setCanAuthenticate:(BOOL)auth
{
    @synchronized (self) {
        self.cachedCanAuthenticate = [NSNumber numberWithBool:auth];
    }

    [self performWithAppStateAndSave:^(SCHAppState *appState) {
        [appState setShouldAuthenticate:[NSNumber numberWithBool:auth]];
    }];
}

- (void)setServerDateDelta:(NSTimeInterval)seconds
{
    @synchronized (self) {
        self.cachedServerDateDelta = [NSNumber numberWithDouble:seconds];
    }
    
    [self performWithAppStateAndSave:^(SCHAppState *appState) {
        [appState setServerDateDelta:[NSNumber numberWithDouble:seconds]];
    }];
}

- (NSTimeInterval)serverDateDelta
{
    NSTimeInterval ret = 0.0;
    
    @synchronized (self) {
        if (self.cachedServerDateDelta != nil) {
            ret = [self.cachedServerDateDelta doubleValue];
        }
    }
    
    return ret;  
}

- (BOOL)shouldShowWishList
{
    if ([self lastScholasticAuthenticationErrorCode] == kSCHScholasticAuthenticationWebServiceErrorCodeInvalidUsernamePassword) {
        return NO;
    } else if (![self isCOPPACompliant]) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)isStandardStore
{
    // Assume a standard store if there is no app state
    BOOL ret = YES;

    @synchronized (self) {
        if (self.cachedDataStoreType != nil) {
            ret = [self.cachedDataStoreType isEqualToNumber:[NSNumber numberWithDataStoreType:kSCHDataStoreTypesStandard]];
        }
    }
    
    return ret;
}

- (BOOL)isSampleStore
{
    BOOL ret = NO;
    
    @synchronized (self) {
        if (self.cachedDataStoreType != nil) {
            ret = [self.cachedDataStoreType isEqualToNumber:[NSNumber numberWithDataStoreType:kSCHDataStoreTypesSample]];
        }
    }
    
    return ret;
}

- (void)setDataStoreType:(SCHDataStoreTypes)type
{
    @synchronized (self) {
        self.cachedDataStoreType = [NSNumber numberWithDataStoreType:type];
    }

    [self performWithAppStateAndSave:^(SCHAppState *appState) {
        [appState setDataStoreType:[NSNumber numberWithDataStoreType:type]];
    }];
}

- (NSString *)lastKnownAuthToken
{
    NSString *ret = nil;

    @synchronized (self) {
        if (self.cachedLastKnownAuthToken != nil) {
            ret = self.cachedLastKnownAuthToken;
        }
    }
    
    return ret;  
}

- (void)setLastKnownAuthToken:(NSString *)token
{
    @synchronized (self) {
        self.cachedLastKnownAuthToken = token;
    }

    [self performWithAppStateAndSave:^(SCHAppState *appState) {
        [appState setLastKnownAuthToken:token];
    }];
}

- (NSDate *)lastRemoteManifestUpdateDate
{
    NSDate *ret = nil;

    @synchronized (self) {
        if (self.cachedLastRemoteManifestUpdateDate != nil) {
            ret = self.cachedLastRemoteManifestUpdateDate;
        }
    }
    
    return ret;  
}

- (void)setLastRemoteManifestUpdateDate:(NSDate *)date
{
    @synchronized (self) {
        self.cachedLastRemoteManifestUpdateDate = date;
    }

    [self performWithAppStateAndSave:^(SCHAppState *appState) {
        [appState setLastRemoteManifestUpdateDate:date];
    }];
}

- (SCHScholasticAuthenticationWebServiceErrorCode)lastScholasticAuthenticationErrorCode
{
    SCHScholasticAuthenticationWebServiceErrorCode ret = kSCHScholasticAuthenticationWebServiceErrorCodeNone;
    
    @synchronized (self) {
        if (self.cachedLastScholasticAuthenticationErrorCode != nil) {
            ret = [self.cachedLastScholasticAuthenticationErrorCode intValue];
        }
    }
    
    return ret;
}

- (void)setLastScholasticAuthenticationErrorCode:(SCHScholasticAuthenticationWebServiceErrorCode)errorCode
{
    @synchronized (self) {
        self.cachedLastScholasticAuthenticationErrorCode = [NSNumber numberWithInt:errorCode];
    }

    [self performWithAppStateAndSave:^(SCHAppState *appState) {
        [appState setLastScholasticAuthenticationErrorCode:[NSNumber numberWithInt:errorCode]];
    }];
}

#pragma mark - Thread safe access to AppState

- (void)performWithAppState:(void (^)(SCHAppState *appState))block
{
    dispatch_block_t accessBlock = ^{
        SCHAppState *appState = [self appState];
        block(appState);
    };
    
    if ([NSThread isMainThread]) {
        accessBlock();
    } else {
        dispatch_sync(dispatch_get_main_queue(), accessBlock);
    }
}

- (void)performWithAppStateAndSave:(void (^)(SCHAppState *appState))block
{
    dispatch_block_t accessBlock = ^{
        if (block) {
            SCHAppState *appState = [self appState];
            block(appState);
        }
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"failed to save: %@", error);
        }
    };
    
    if ([NSThread isMainThread]) {
        accessBlock();
    } else {
        dispatch_async(dispatch_get_main_queue(), accessBlock);
    }
}

#pragma mark - Setting Item methods

- (NSString *)settingNamed:(NSString *)settingName
{
    __block NSString *ret = nil;
    
    if (settingName == nil || !self.managedObjectContext) {
        return nil;
    }

    dispatch_block_t accessBlock = ^{
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entityDescription = [NSEntityDescription 
                                                  entityForName:kSCHSettingItem
                                                  inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entityDescription];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"settingName = %@", settingName]];
        
        NSError *error = nil;
        NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (fetchedObjects == nil) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        } else if ([fetchedObjects count] > 0) {
            SCHSettingItem *item = [fetchedObjects objectAtIndex:0];
            
            ret = [item.SettingValue copy];
        }    
        [fetchRequest release], fetchedObjects = nil;
    };
    
    if ([NSThread isMainThread]) {
        accessBlock();
    } else {
        dispatch_async(dispatch_get_main_queue(), accessBlock);
    }
    
    return [ret autorelease];    
}

#pragma mark - NSManagedObjectContext Changed Notification

- (void)coreDataHelperManagedObjectContextDidChangeNotification:(NSNotification *)notification
{
    NSAssert([NSThread isMainThread] == YES, @"coreDataHelperManagedObjectContextDidChangeNotification SHOULD be executed on the main thread");
    // setting the managed object context also resets the caches
    self.managedObjectContext = [[notification userInfo] objectForKey:SCHCoreDataHelperManagedObjectContext];
}

@end
