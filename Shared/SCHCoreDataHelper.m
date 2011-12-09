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

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (void)addPersistentStore:(NSPersistentStoreCoordinator *)aPersistentStoreCoordinator 
             configuration:(NSString *)configuration 
                       url:(NSURL *)url;
- (NSURL *)storeURL:(NSString *)storeName;
- (NSPersistentStore *)currentMainPersistentStore;
- (NSPersistentStore *)currentDictionaryPersistentStore;
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
    
    [[SCHAuthenticationManager sharedAuthenticationManager] clearAppProcessing];
    [[self managedObjectContext] reset];
    [[self persistentStoreCoordinator] removePersistentStore:currentMainStore 
                                                       error:&error];  
    [self removeStoreAtURL:[self storeURL:kSCHCoreDataHelperStandardStoreName]];
    
    self.managedObjectContext = nil;
    
    if ([[self persistentStoreCoordinator] addPersistentStoreWithType:NSSQLiteStoreType 
                                                        configuration:kSCHCoreDataHelperMainStoreConfiguration 
                                                                  URL:[self storeURL:kSCHCoreDataHelperStandardStoreName] 
                                                              options:nil 
                                                                error:&error] == nil){   
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
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
        abort();
    }
}

#pragma mark - File methods
             
//- (BOOL)storeExists:(NSString *)storeName
//{
//    NSURL *applicationSupportDocumentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
//    NSURL *destinationSampleStoreURL = [applicationSupportDocumentsDirectory URLByAppendingPathComponent:storeName];    
//    NSString *destinationSampleStorePath = [destinationSampleStoreURL path];
//    
//    return([[NSFileManager defaultManager] fileExistsAtPath:destinationSampleStorePath]);
//}
//
//- (void)setupSampleStore
//{  
//    if ([self storeExists:kSCHCoreDataHelperSampleStoreName] == NO) {
//        NSString *sourceSampleStorePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:kSCHCoreDataHelperStandardStoreName];
//        NSURL *applicationSupportDocumentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
//        NSURL *destinationSampleStoreURL = [applicationSupportDocumentsDirectory URLByAppendingPathComponent:kSCHCoreDataHelperSampleStoreName];    
//        NSString *destinationSampleStorePath = [destinationSampleStoreURL path];
//        
//        NSError *error = nil;
//        if ([[NSFileManager defaultManager] copyItemAtPath:sourceSampleStorePath 
//                                                    toPath:destinationSampleStorePath
//                                                     error:&error] == NO) {
//            NSLog(@"Error copying Sample Data Store: %@, %@", error, [error userInfo]);
//        }            
//    }
//}
//             
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
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator 
{    
    if (persistentStoreCoordinator != nil) {
        return(persistentStoreCoordinator);
    }
	    
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    [self addPersistentStore:persistentStoreCoordinator 
               configuration:kSCHCoreDataHelperMainStoreConfiguration 
                         url:[self storeURL:kSCHCoreDataHelperStandardStoreName]];
    [self addPersistentStore:persistentStoreCoordinator 
               configuration:kSCHCoreDataHelperDictionaryStoreConfiguration 
                         url:[self storeURL:kSCHCoreDataHelperDictionaryStoreName]];
        
    // setup the appState
    SCHAppStateManager *appStateManager = [SCHAppStateManager sharedAppStateManager];
    appStateManager.managedObjectContext = self.managedObjectContext;
    
    return(persistentStoreCoordinator);
}

- (void)addPersistentStore:(NSPersistentStoreCoordinator *)aPersistentStoreCoordinator 
             configuration:(NSString *)configuration 
                       url:(NSURL *)url
{
    NSError *error = nil;
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    if ([aPersistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:configuration URL:url options:options error:&error] == nil) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
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
        
        if ([error code] == NSPersistentStoreIncompatibleVersionHashError) {
            NSLog(@"Your %@ Core Data store is incompatible, we're gonna replace the store for you. You may need to re-populate it.", configuration);
            [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
            if ([aPersistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:configuration URL:url options:options error:&error] == nil) {        
                bailOut = YES;
            }
        } else {
            bailOut = YES;
        }
        
        if (bailOut == YES) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)saveContext 
{    
    NSError *error = nil;
    if (self.managedObjectContext != nil) {
        if ([self.managedObjectContext hasChanges] && 
            ![self.managedObjectContext save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}    

- (NSURL *)storeURL:(NSString *)storeName
{
    NSURL *applicationSupportDocumentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [applicationSupportDocumentsDirectory URLByAppendingPathComponent:storeName];    
}

//- (void)setStoreType:(SCHCoreDataHelperStoreType)storeType
//{                                             
//    switch (storeType) {
//        default:
//        case SCHCoreDataHelperStandardStore:
//            if ([self switchPersistentStore:kSCHCoreDataHelperStandardStoreName] == YES) {            
//                // post switch steps
//            }            
//            break;
//        case SCHCoreDataHelperSampleStore:
//            if ([self switchPersistentStore:kSCHCoreDataHelperSampleStoreName] == YES) {            
//                // post switch steps
//            }
//            break;
//    }    
//}
//
//- (BOOL)switchPersistentStore:(NSString *)storeName
//{
//    BOOL ret = NO;
//    NSPersistentStore *currentMainStore = [self currentMainPersistentStore];
//    NSString *storeFileName = [[[[self persistentStoreCoordinator] URLForPersistentStore:currentMainStore] path] lastPathComponent];
//    NSError *error = nil;
//    
//    if ([storeFileName isEqualToString:storeName] == NO) {
//        NSLog(@"Switching store from %@ to %@", storeFileName, storeName);
//        [[SCHAuthenticationManager sharedAuthenticationManager] clearAppProcessing];
//        [[self managedObjectContext] reset];
//        [[self persistentStoreCoordinator] removePersistentStore:currentMainStore 
//                                                           error:&error];  
//        self.managedObjectContext = nil;
//        if ([[self persistentStoreCoordinator] addPersistentStoreWithType:NSSQLiteStoreType 
//                                                            configuration:kSCHCoreDataHelperMainStoreConfiguration 
//                                                                      URL:[self storeURL:storeName] 
//                                                                  options:nil 
//                                                                    error:&error] == nil){   
//            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//            abort();
//        }
//
//        [[NSNotificationCenter defaultCenter] postNotificationName:SCHCoreDataHelperManagedObjectContextDidChangeNotification 
//                                                            object:self 
//                                                          userInfo:[NSDictionary dictionaryWithObject:[self managedObjectContext] 
//                                                                                               forKey:SCHCoreDataHelperManagedObjectContext]];
//        ret = YES;
//    }
//    
//    return(ret);
//}
//
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
