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

// thread-safe access to appstate object; the block is executed synchronously so may make
// changes to any __block storage locals
- (void)performWithAppState:(void (^)(SCHAppState *appState))block;

// thread-safe access to appstate object followed by save; the block is executed asynchronously
- (void)performWithAppStateAndSave:(void (^)(SCHAppState *appState))block;

@end

@implementation SCHAppStateManager

@synthesize managedObjectContext;

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
    
    [managedObjectContext release], managedObjectContext = nil;
    
    [super dealloc];
}

#pragma mark - methods

- (SCHAppState *)appState
{
    NSAssert([NSThread isMainThread] == YES, @"appState SHOULD be executed on the main thread");
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

    if ([state count] > 0) {
        ret = [state objectAtIndex:0];
    } else {
        ret = [self createAppStateIfNeeded];
    }
    
    if (!ret) {
        NSLog(@"WARNING!!! App state is nil. This will lead to unexpected behaviour.");
    }
    
    return(ret);    
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
    
    [self performWithAppState:^(SCHAppState *appState) {
        if (appState != nil) {
            ret = [appState.ShouldSyncNotes boolValue];
        }
    }];
    
    return ret;
}

- (void)setCanSyncNotes:(BOOL)sync
{
    [self performWithAppStateAndSave:^(SCHAppState *appState) {
        [appState setShouldSyncNotes:[NSNumber numberWithBool:sync]];
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

#pragma mark - NSManagedObjectContext Changed Notification

- (void)coreDataHelperManagedObjectContextDidChangeNotification:(NSNotification *)notification
{
    self.managedObjectContext = [[notification userInfo] objectForKey:SCHCoreDataHelperManagedObjectContext];
}

@end
