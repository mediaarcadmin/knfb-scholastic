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
    BOOL ret = NO;
    SCHAppState *appState = [self appState];
    
    if (appState != nil) {
        ret = [appState.ShouldSync boolValue];
    }
    
    return(ret);
}

- (BOOL)canSyncNotes
{
    BOOL ret = NO;
    SCHAppState *appState = [self appState];
    
    if (appState != nil) {
        ret = [appState.ShouldSyncNotes boolValue];
    }
    
    return(ret);
}

- (BOOL)canAuthenticate
{
    BOOL ret = NO;
    SCHAppState *appState = [self appState];
    
    if (appState != nil) {
        ret = [appState.ShouldAuthenticate boolValue];
    }
    
    return(ret);    
}

- (BOOL)isStandardStore
{
    return([[self appState].DataStoreType isEqualToNumber:[NSNumber numberWithDataStoreType:kSCHDataStoreTypesStandard]]);
}

- (BOOL)isSampleStore
{
    return([[self appState].DataStoreType isEqualToNumber:[NSNumber numberWithDataStoreType:kSCHDataStoreTypesSample]]);
}

#pragma mark - NSManagedObjectContext Changed Notification

- (void)coreDataHelperManagedObjectContextDidChangeNotification:(NSNotification *)notification
{
    self.managedObjectContext = [[notification userInfo] objectForKey:SCHCoreDataHelperManagedObjectContext];
}

@end
