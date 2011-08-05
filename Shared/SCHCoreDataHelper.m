//
//  SCHCoreDataHelper.m
//  Scholastic
//
//  Created by John S. Eddie on 04/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHCoreDataHelper.h"

#import "SCHAppState.h"
#import "SCHUserDefaults.h"
#import "SCHAuthenticationManager.h"
#import "AppDelegate_Shared.h"

static NSString * const kSCHCoreDataHelperStoreName = @"Scholastic.sqlite";
static NSString * const kSCHCoreDataHelperSampleStoreName = @"Scholastic_Sample.sqlite";

@interface SCHCoreDataHelper ()

@property (nonatomic, retain) NSString *storeName;

- (NSURL *)storeURL;
- (void)checkForModeSwitch;
- (void)postStoreCreationForStandardStore;
- (void)postStoreCreationForSampleStore;
- (void)postStoreCreationForLocalFilesStore;

@end

@implementation SCHCoreDataHelper

@synthesize managedObjectContext;
@synthesize managedObjectModel;
@synthesize persistentStoreCoordinator;
@synthesize storeName;

#pragma mark - Application lifecycle

- (id)init 
{
    self = [super init];
    if (self) {
        [self setStoreType:[[NSUserDefaults standardUserDefaults] integerForKey:kSCHUserDefaultsCoreDataStoreType]];
    }
    return(self);
}

- (void)dealloc 
{    
	[[NSNotificationCenter defaultCenter] removeObserver:managedObjectContext];
    
    [storeName release], storeName = nil;
    [managedObjectContext release], managedObjectContext = nil;
    [managedObjectModel release], managedObjectModel = nil;
    [persistentStoreCoordinator release], persistentStoreCoordinator = nil;
    
    [super dealloc];
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
            [[self managedObjectContext] mergeChangesFromContextDidSaveNotification:notification];
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
    
    [self checkForModeSwitch];
	
    NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self storeURL] options:nil error:&error]) {
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
            NSLog(@"Your Core Data store is incompatible, we're gonna replace the store for you. You may need to re-populate it.");
            [[NSFileManager defaultManager] removeItemAtURL:[self storeURL] error:nil];
            if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self storeURL] options:nil error:&error]) {        
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
    
    return(persistentStoreCoordinator);
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

#pragma mark - Local Debug Mode

- (void)checkForModeSwitch
{
	// check for change between local debug mode and normal network mode	
	BOOL localDebugMode = NO;
	
#if LOCALDEBUG
	localDebugMode = YES;
#endif
	
	NSNumber *storedValue = (NSNumber *) [[NSUserDefaults standardUserDefaults] valueForKey:kSCHUserDefaultsClearLocalDebugMode];

	if (storedValue) {
		if ([storedValue boolValue] != localDebugMode) {
			NSLog(@"Changed between local debug mode and network mode - deleting database & removing login details.");
            [[NSFileManager defaultManager] removeItemAtURL:[self storeURL] error:nil];		
            [[SCHAuthenticationManager sharedAuthenticationManager] clear];
		}		
		
	}
	
	NSLog(@"Currently in %@.", localDebugMode?@"\"Local Debug Mode\"":@"\"Network Mode\"");
	NSNumber *newValue = [NSNumber numberWithBool:localDebugMode];
	[[NSUserDefaults standardUserDefaults] setObject:newValue forKey:kSCHUserDefaultsClearLocalDebugMode];
	[[NSUserDefaults standardUserDefaults] synchronize];
}	

- (NSURL *)storeURL
{
    AppDelegate_Shared *appDelegate = (AppDelegate_Shared *)[[UIApplication sharedApplication] delegate];
    NSURL *applicationSupportDocumentsDirectory = appDelegate.applicationSupportDocumentsDirectory;

    return [applicationSupportDocumentsDirectory URLByAppendingPathComponent:self.storeName];    
}

#pragma mark - Database clear

- (void)clearDatabase
{
    [managedObjectContext release], managedObjectContext = nil;
    [persistentStoreCoordinator release], persistentStoreCoordinator = nil;
    
    NSError *error = nil;
    if (![[NSFileManager defaultManager] removeItemAtURL:[self storeURL] error:&error]) {
        NSLog(@"failed to remove database: %@", error);
    }
    
    NSLog(@"Cleared local database! Exiting.");
    exit(0);
}

- (BOOL)standardStore
{
    return YES;
}

- (BOOL)synchronise
{
    return YES;
}

- (BOOL)downloadBooks
{
    return YES;
}

- (void)setStoreType:(SCHCoreDataHelperStoreType)storeType
{   
    [[NSUserDefaults standardUserDefaults] setInteger:storeType 
                                               forKey:kSCHUserDefaultsCoreDataStoreType];                
    [[NSUserDefaults standardUserDefaults] synchronize];

    switch (storeType) {
        default:
        case SCHCoreDataHelperStoreTypeStandard:
            self.storeName = kSCHCoreDataHelperStoreName;
            [self postStoreCreationForStandardStore];
            break;
        case SCHCoreDataHelperStoreTypeSample:
            self.storeName = kSCHCoreDataHelperSampleStoreName;
            [self postStoreCreationForSampleStore];
            break;
        case SCHCoreDataHelperStoreTypeLocalFiles:
            self.storeName = kSCHCoreDataHelperStoreName;
            [self postStoreCreationForLocalFilesStore];
            break;            
    }    
}

- (void)postStoreCreationForStandardStore
{
    // set the store type in appstate
}

- (void)postStoreCreationForSampleStore
{

}

- (void)postStoreCreationForLocalFilesStore
{
    // set the store type in appstate
    // copy XPS files into place
}


@end
