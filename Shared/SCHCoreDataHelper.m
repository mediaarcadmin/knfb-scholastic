//
//  SCHCoreDataHelper.m
//  Scholastic
//
//  Created by John S. Eddie on 04/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHCoreDataHelper.h"

#import "SCHUserDefaults.h"
#import "SCHAuthenticationManager.h"
#import "AppDelegate_Shared.h"
#import "SCHAppStateManager.h"
#import "NSNumber+ObjectTypes.h"
#import "SCHSyncManager.h"
#import "SCHBookManager.h"

// Constants
NSString * const SCHCoreDataHelperManagedObjectContextDidChangeNotification = @"SCHCoreDataHelperManagedObjectContextDidChangeNotification";
NSString * const SCHCoreDataHelperManagedObjectContext = @"SCHCoreDataHelperManagedObjectContext";

static NSString * const kSCHCoreDataHelperMainStoreConfiguration = @"Main";
static NSString * const kSCHCoreDataHelperDictionaryStoreConfiguration = @"Dictionary";

static NSString * const kSCHCoreDataHelperStandardStoreName = @"Scholastic.sqlite";
static NSString * const kSCHCoreDataHelperDictionaryStoreName = @"Scholastic_Dictionary.sqlite";

@interface SCHCoreDataHelper ()

@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (BOOL)addPersistentStore:(NSPersistentStoreCoordinator *)aPersistentStoreCoordinator 
             configuration:(NSString *)configuration 
                       url:(NSURL *)url
                     error:(NSError **)errorPtr;
- (BOOL)performConfigurationMigrationWorkaroundWithPersistentStore:(NSPersistentStoreCoordinator *)aPersistentStoreCoordinator 
                                                     configuration:(NSString *)configuration 
                                                               url:(NSURL *)url
                                                           options:(NSDictionary *)options
                                                             error:(NSError **)errorPtr;
- (NSURL *)storeURL:(NSString *)storeName;
- (NSPersistentStore *)currentMainPersistentStore;
- (NSPersistentStore *)currentDictionaryPersistentStore;
- (BOOL)storeFileExists:(NSURL *)storeURL;
- (void)removeStoreAtURL:(NSURL *)storeURL;

@end

@implementation SCHCoreDataHelper

@synthesize managedObjectContext;
@synthesize managedObjectModel;
@synthesize persistentStoreCoordinator;

#pragma mark - Application lifecycle

- (void)dealloc 
{    
	[[NSNotificationCenter defaultCenter] removeObserver:managedObjectContext];
    
    [managedObjectContext release], managedObjectContext = nil;
    [managedObjectModel release], managedObjectModel = nil;
    [persistentStoreCoordinator release], persistentStoreCoordinator = nil;
    
    [super dealloc];
}

- (void)resetMainStore
{
    NSPersistentStore *currentMainStore = [self currentMainPersistentStore];
    NSError *error = nil;
    
    [[SCHAuthenticationManager sharedAuthenticationManager] clearAppProcessingWaitUntilFinished:NO];
    [[self managedObjectContext] reset];
    if (currentMainStore != nil &&
        [[self persistentStoreCoordinator] removePersistentStore:currentMainStore 
                                                           error:&error] == NO) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}      
    [self removeStoreAtURL:[self storeURL:kSCHCoreDataHelperStandardStoreName]];
    
    self.managedObjectContext = nil;
    
    if ([[self persistentStoreCoordinator] addPersistentStoreWithType:NSSQLiteStoreType 
                                                        configuration:kSCHCoreDataHelperMainStoreConfiguration 
                                                                  URL:[self storeURL:kSCHCoreDataHelperStandardStoreName] 
                                                              options:nil 
                                                                error:&error] == nil){   
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SCHCoreDataHelperManagedObjectContextDidChangeNotification 
                                                        object:self 
                                                      userInfo:[NSDictionary dictionaryWithObject:[self managedObjectContext] 
                                                                                           forKey:SCHCoreDataHelperManagedObjectContext]];
}

- (void)resetDictionaryStore
{
    NSPersistentStore *currentDictionaryStore = [self currentDictionaryPersistentStore];
    NSError *error = nil;
    
    [[SCHBookManager sharedBookManager] clearBookIdentifierCache];
    [[self managedObjectContext] save:&error];
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
    [coordinator removePersistentStore:currentDictionaryStore error:&error];  
    [self removeStoreAtURL:[self storeURL:kSCHCoreDataHelperDictionaryStoreName]];
    
    if ([coordinator addPersistentStoreWithType:NSSQLiteStoreType 
                                                        configuration:kSCHCoreDataHelperDictionaryStoreConfiguration 
                                                                  URL:[self storeURL:kSCHCoreDataHelperDictionaryStoreName] 
                                                              options:nil 
                                                                error:&error] == nil){   
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        return;
    }
}

#pragma mark - File methods
                       
- (BOOL)storeFileExists:(NSURL *)storeURL
{
    BOOL ret = NO;
    
    if (storeURL != nil) {
        NSFileManager *threadSafeFileManager = [[[NSFileManager alloc] init] autorelease];
        
        ret = [threadSafeFileManager fileExistsAtPath:[storeURL path]];
    }
    
    return ret;
}

- (void)removeStoreAtURL:(NSURL *)storeURL
{
    NSString *storePath = [storeURL path];
    NSFileManager *threadSafeFileManager = [[[NSFileManager alloc] init] autorelease];
    
    NSError *error = nil;
    if ([threadSafeFileManager fileExistsAtPath:storePath]) {
        if (![threadSafeFileManager removeItemAtPath:storePath error:&error]) {
            NSLog(@"Error removing Store: %@, %@", error, [error userInfo]);
        }            
    }
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext 
{    
    if (managedObjectContext != nil) {
        return(managedObjectContext);
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator:coordinator];
        [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
		[[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(mergeChangesFromContextDidSaveNotification:) 
                                                     name:NSManagedObjectContextDidSaveNotification 
                                                   object:nil];
		
    }
    return(managedObjectContext);
}

- (void)mergeChangesFromContextDidSaveNotification:(NSNotification *)notification 
{
    if (notification.object != self.managedObjectContext) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = nil;
            [[self managedObjectContext] mergeChangesFromContextDidSaveNotification:notification];
            if ([[self managedObjectContext] save:&error] == NO) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            }
        });
    }
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel 
{    
    if (managedObjectModel != nil) {
        return(managedObjectModel);
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Scholastic" withExtension:@"momd"];
    managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    

    return(managedObjectModel);
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinatorWithError:(NSError **)errorPtr
{    
    if (persistentStoreCoordinator != nil) {
        return(persistentStoreCoordinator);
    }
	    
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    BOOL success = NO;
    
    if ([self addPersistentStore:persistentStoreCoordinator 
                              configuration:kSCHCoreDataHelperMainStoreConfiguration 
                                                 url:[self storeURL:kSCHCoreDataHelperStandardStoreName]
                           error:errorPtr]) {
        if ([self addPersistentStore:persistentStoreCoordinator 
                       configuration:kSCHCoreDataHelperDictionaryStoreConfiguration 
                                 url:[self storeURL:kSCHCoreDataHelperDictionaryStoreName]
                               error:errorPtr]) {
            success = YES;
        }
    }

    if (success) {
        // setup the appState
        SCHAppStateManager *appStateManager = [SCHAppStateManager sharedAppStateManager];
        appStateManager.managedObjectContext = self.managedObjectContext;
    } else {
        [persistentStoreCoordinator release], persistentStoreCoordinator = nil;
    }
    
    return persistentStoreCoordinator;
}

- (BOOL)addPersistentStore:(NSPersistentStoreCoordinator *)aPersistentStoreCoordinator 
             configuration:(NSString *)configuration 
                       url:(NSURL *)url
                     error:(NSError **)errorPtr
{
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    if ([self performConfigurationMigrationWorkaroundWithPersistentStore:aPersistentStoreCoordinator 
                                                           configuration:configuration 
                                                                     url:url
                                                                 options:options
                                                                   error:errorPtr] == NO) {
        NSLog(@"Unresolved error %@, %@", *errorPtr, [*errorPtr userInfo]);
        return NO;        
    }
    
    if ([aPersistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:configuration URL:url options:options error:errorPtr] == nil) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        
        BOOL bailOut = NO;
        
        if ([*errorPtr code] == NSPersistentStoreIncompatibleVersionHashError) {
            NSLog(@"Your %@ Core Data store is incompatible, we're gonna replace the store for you. You may need to re-populate it.", configuration);
            [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
            if ([aPersistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:configuration URL:url options:options error:errorPtr] == nil) {        
                bailOut = YES;
            }
        } else {
            bailOut = YES;
        }
        
        if (bailOut == YES) {
            NSLog(@"Unresolved error %@, %@", *errorPtr, [*errorPtr userInfo]);
            return NO;
        }
    }
    
    return YES;
}

// work around for migrating with configurations
// return NO if an error occured
- (BOOL)performConfigurationMigrationWorkaroundWithPersistentStore:(NSPersistentStoreCoordinator *)aPersistentStoreCoordinator 
                                                     configuration:(NSString *)configuration 
                                                               url:(NSURL *)url
                                                           options:(NSDictionary *)options
                                                             error:(NSError **)errorPtr
{
    BOOL ret = YES;
    
    if ([self storeFileExists:url] == YES) {
        // check if we need to perform a migration
        NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType
                                                                                                  URL:url
                                                                                                error:errorPtr];
        
        if (sourceMetadata == nil) {
            ret = NO;
        } else {
            if ([[aPersistentStoreCoordinator managedObjectModel] isConfiguration:configuration 
                                                      compatibleWithStoreMetadata:sourceMetadata] == NO) {
                // using nil configuration workaround so the migration succeeds
                NSPersistentStore *persistentStore = [aPersistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType 
                                                                                               configuration:nil 
                                                                                                         URL:url 
                                                                                                     options:options 
                                                                                                       error:errorPtr];
                // migration performed now remove the persistent store
                if (persistentStore == nil) {  
                    ret = NO;
                } else if ([aPersistentStoreCoordinator removePersistentStore:persistentStore error:errorPtr] == NO) {
                    ret = NO;
                }
            }    
        }    
    }
    
    return ret;
}

- (void)saveContext 
{    
    NSError *error = nil;
    if (self.managedObjectContext != nil) {
        if ([self.managedObjectContext hasChanges] && 
            ![self.managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }
}    

- (NSURL *)storeURL:(NSString *)storeName
{
    NSURL *applicationSupportDocumentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    
    return [applicationSupportDocumentsDirectory URLByAppendingPathComponent:storeName];    
}

- (NSPersistentStore *)currentMainPersistentStore
{
    NSPersistentStore *ret = nil;
    
    if ([self persistentStoreCoordinator] != nil) {
        for (NSPersistentStore *store in [[self persistentStoreCoordinator] persistentStores]) {
            if ([store.URL isEqual:[self storeURL:kSCHCoreDataHelperStandardStoreName]]) {
                ret = store;
                break;
            }
        }
    }
    
    return(ret);
}

- (NSPersistentStore *)currentDictionaryPersistentStore
{
    NSPersistentStore *ret = nil;
    
    if ([self persistentStoreCoordinator] != nil) {
        for (NSPersistentStore *store in [[self persistentStoreCoordinator] persistentStores]) {
            if ([store.URL isEqual:[self storeURL:kSCHCoreDataHelperDictionaryStoreName]]) {
                ret = store;
                break;
            }
        }
    }
    
    return(ret);
}

@end
