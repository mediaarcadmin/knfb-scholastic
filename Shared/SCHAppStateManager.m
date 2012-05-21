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
#import "SCHSettingItem.h"

@interface SCHAppStateManager()

- (SCHAppState *)createAppStateIfNeeded;

@property (nonatomic, retain) SCHAppState *cachedAppState;

// thread-safe access to appstate object; the block is executed synchronously so may make
// changes to any __block storage locals
- (void)performWithAppState:(void (^)(SCHAppState *appState))block;

// thread-safe access to appstate object followed by save; the block is executed asynchronously
- (void)performWithAppStateAndSave:(void (^)(SCHAppState *appState))block;

@end

@implementation SCHAppStateManager

@synthesize managedObjectContext;
@synthesize cachedAppState;

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
    [managedObjectContext release], managedObjectContext = nil;
    
    [super dealloc];
}

#pragma mark - methods

- (SCHAppState *)appState
{
    NSAssert([NSThread isMainThread] == YES, @"appState SHOULD be executed on the main thread");

    if (!self.managedObjectContext) {
        return nil;
    }

    if (self.cachedAppState == nil) {
        self.cachedAppState = [self createAppStateIfNeeded];
    }
    
    return self.cachedAppState;    
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
    __block BOOL ret = NO;
    
    [self performWithAppState:^(SCHAppState *appState) {
        if (appState != nil) {
            ret = [appState.ShouldSync boolValue];
        }
    }];
    
    return ret;
}

- (void)setCanSync:(BOOL)sync
{
    [self performWithAppStateAndSave:^(SCHAppState *appState) {
        [appState setShouldSync:[NSNumber numberWithBool:sync]];
    }];
}

- (BOOL)canSyncNotes
{
    __block BOOL ret = NO;
    
#if IGNORE_COPPA_COMPLIANCE
    ret = YES;
#else
    [self performWithAppState:^(SCHAppState *appState) {
        if (appState != nil) {
            ret = [appState.ShouldSyncNotes boolValue];
        }
    }];
#endif
    
    return ret;
}

- (void)setCanSyncNotes:(BOOL)sync
{
    [self performWithAppStateAndSave:^(SCHAppState *appState) {
        [appState setShouldSyncNotes:[NSNumber numberWithBool:sync]];
    }];
}

- (BOOL)isCOPPACompliant
{
    __block BOOL ret = NO;
    
#if IGNORE_COPPA_COMPLIANCE
    ret = YES;
#else
    [self performWithAppState:^(SCHAppState *appState) {
        if (appState != nil) {
            ret = [appState.isCOPPACompliant boolValue];
        }
    }];
#endif
    
    return ret;
}

- (void)setCOPPACompliant:(BOOL)coppa
{
    [self performWithAppStateAndSave:^(SCHAppState *appState) {
        [appState setIsCOPPACompliant:[NSNumber numberWithBool:coppa]];
    }];
}

- (BOOL)canAuthenticate
{
    __block BOOL ret = NO;
    
    [self performWithAppState:^(SCHAppState *appState) {
        if (appState != nil) {
            ret = [appState.ShouldAuthenticate boolValue];
        }
    }];
    
    return ret;  
}

- (void)setCanAuthenticate:(BOOL)auth
{
    [self performWithAppStateAndSave:^(SCHAppState *appState) {
        [appState setShouldAuthenticate:[NSNumber numberWithBool:auth]];
    }];
}

- (void)setServerDateDelta:(NSTimeInterval)seconds
{
    [self performWithAppStateAndSave:^(SCHAppState *appState) {
        [appState setServerDateDelta:[NSNumber numberWithDouble:seconds]];
    }];
}

- (NSTimeInterval)serverDateDelta
{
    __block NSTimeInterval ret = 0.0;
    
    [self performWithAppState:^(SCHAppState *appState) {
        if (appState != nil) {
            ret = [appState.ServerDateDelta doubleValue];
        }
    }];
    
    return ret;  
}

- (BOOL)isStandardStore
{
    // Assume a standard store if there is no app state
    __block BOOL ret = YES;
    
    [self performWithAppState:^(SCHAppState *appState) {
        if (appState != nil) {
            ret = [appState.DataStoreType isEqualToNumber:[NSNumber numberWithDataStoreType:kSCHDataStoreTypesStandard]];
        }
    }];
    
    return ret;
}

- (BOOL)isSampleStore
{
    __block BOOL ret = NO;
    
    [self performWithAppState:^(SCHAppState *appState) {
        if (appState != nil) {
            ret = [appState.DataStoreType isEqualToNumber:[NSNumber numberWithDataStoreType:kSCHDataStoreTypesSample]];
        }
    }];
    
    return ret;
}

- (void)setDataStoreType:(SCHDataStoreTypes)type
{
    [self performWithAppStateAndSave:^(SCHAppState *appState) {
        [appState setDataStoreType:[NSNumber numberWithDataStoreType:type]];
    }];
}

- (NSString *)lastKnownAuthToken
{
    __block NSString *ret = nil;
    
    [self performWithAppState:^(SCHAppState *appState) {
        if (appState != nil) {
            ret = appState.LastKnownAuthToken;
        }
    }];
    
    return ret;  
}

- (void)setLastKnownAuthToken:(NSString *)token
{
    [self performWithAppStateAndSave:^(SCHAppState *appState) {
        [appState setLastKnownAuthToken:token];
    }];
}

- (NSDate *)lastRemoteManifestUpdateDate
{
    __block NSDate *ret = nil;
    
    [self performWithAppState:^(SCHAppState *appState) {
        if (appState != nil) {
            ret = appState.LastRemoteManifestUpdateDate;
        }
    }];
    
    return ret;  
}
- (void)setLastRemoteManifestUpdateDate:(NSDate *)date
{
    [self performWithAppStateAndSave:^(SCHAppState *appState) {
        [appState setLastRemoteManifestUpdateDate:date];
    }];
}

- (SCHScholasticAuthenticationWebServiceErrorCode)lastScholasticAuthenticationErrorCode
{
    __block SCHScholasticAuthenticationWebServiceErrorCode ret = kSCHScholasticAuthenticationWebServiceErrorCodeNone;
    
    [self performWithAppState:^(SCHAppState *appState) {
        if (appState != nil) {
            ret = [appState.lastScholasticAuthenticationErrorCode intValue];
        }
    }];
    
    return ret;
}

- (void)setLastScholasticAuthenticationErrorCode:(SCHScholasticAuthenticationWebServiceErrorCode)errorCode
{
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
    self.managedObjectContext = [[notification userInfo] objectForKey:SCHCoreDataHelperManagedObjectContext];
}

@end
