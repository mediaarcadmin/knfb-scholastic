//
//  AppDelegate_Shared.m
//  Scholastic
//
//  Created by John S. Eddie on 30/12/2010.
//  Copyright 2010 BitWink Limited. All rights reserved.
//

#import "AppDelegate_Shared.h"
#import "SCHBookManager.h"
#import "SCHSyncManager.h"
#import "SCHAuthenticationManager.h"
#import "SCHUserDefaults.h"
#import "SCHURLManager.h"
#import "SCHProcessingManager.h"
#import "SCHDictionaryManager.h"

#ifdef LOCALDEBUG
#import "SCHLocalDebug.h"
#endif

static NSString * const kSCHClearLocalDebugMode = @"kSCHClearLocalDebugMode";

@implementation AppDelegate_Shared

@synthesize window;


#pragma mark -
#pragma mark Application lifecycle

- (void)copyLocalFilesIfMissing
{
#ifdef LOCALDEBUG    
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"SCHUserContentItem" inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSError *error = nil;
    NSArray *books = [moc executeFetchRequest:request error:&error];
    [request release];
    
    if (![books count])
    {
        NSLog(@"Copying local files as none present in database");
        SCHLocalDebug *localDebug = [[SCHLocalDebug alloc] init];
        localDebug.managedObjectContext = moc;
        [localDebug setup];
        [localDebug release];
    } else {
        NSLog(@"Not copying local files as already present in database");
    }
#endif
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions    
{
	
	NSNumber *currentValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"kSCHSpaceSaverMode"];
	
	if (!currentValue) {
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kSCHSpaceSaverMode"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
    
    SCHBookManager *bookManager = [SCHBookManager sharedBookManager];
    bookManager.persistentStoreCoordinator = self.persistentStoreCoordinator;
    bookManager.managedObjectContextForCurrentThread = self.managedObjectContext;
    
    SCHSyncManager *syncManager = [SCHSyncManager sharedSyncManager];
	syncManager.managedObjectContext = self.managedObjectContext;
	[syncManager start];
	
	SCHURLManager *urlManager = [SCHURLManager sharedURLManager];
	urlManager.managedObjectContext = self.managedObjectContext;
    
	// instantiate the shared processing manager
	[SCHProcessingManager sharedProcessingManager];
    
#ifdef LOCALDEBUG
    [self copyLocalFilesIfMissing];
#endif
	
	[SCHDictionaryManager sharedDictionaryManager];
	
	return YES;
}	

/**
 Save changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
    [self saveContext];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self saveContext];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)saveContext {
    
    NSError *error = nil;
	NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}    
    
- (void)mergeChangesFromContextDidSaveNotification:(NSNotification *)notification {
	[[self managedObjectContext] mergeChangesFromContextDidSaveNotification:notification];
}


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
    
    if (managedObjectContext_ != nil) {
        return managedObjectContext_;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext_ = [[NSManagedObjectContext alloc] init];
        [managedObjectContext_ setPersistentStoreCoordinator:coordinator];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mergeChangesFromContextDidSaveNotification:) name:NSManagedObjectContextDidSaveNotification object:nil];
		
    }
    return managedObjectContext_;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (managedObjectModel_ != nil) {
        return managedObjectModel_;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Scholastic" withExtension:@"momd"];
    managedObjectModel_ = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return managedObjectModel_;
}

- (NSURL *)storeURL
{
    return [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Scholastic.sqlite"];
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (persistentStoreCoordinator_ != nil) {
        return persistentStoreCoordinator_;
    }
    
    [self checkForModeSwitch];
	
    NSError *error = nil;
    persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self storeURL] options:nil error:&error]) {
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
            if (![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self storeURL] options:nil error:&error]) {        
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
    
    return persistentStoreCoordinator_;
}


#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


#pragma mark -
#pragma mark Local Debug Mode

- (void)checkForModeSwitch
{
	// check for change between local debug mode and normal network mode
	NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
								 [NSNumber numberWithBool:NO], kSCHUserDefaultsPerformedFirstSyncUpToBooks, nil];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];		
	
	BOOL localDebugMode = NO;
	
#ifdef LOCALDEBUG
	localDebugMode = YES;
#endif
	
	NSNumber *storedValue = (NSNumber *) [[NSUserDefaults standardUserDefaults] valueForKey:kSCHClearLocalDebugMode];
	
	if (storedValue) {
		if ([storedValue boolValue] != localDebugMode) {
			NSLog(@"Changed between local debug mode and network mode - deleting database & removing login details.");
            [[NSFileManager defaultManager] removeItemAtURL:[self storeURL] error:nil];		
            [[SCHAuthenticationManager sharedAuthenticationManager] clear];
		}		
		
	}
	
	NSLog(@"Currently in %@.", localDebugMode?@"\"Local Debug Mode\"":@"\"Network Mode\"");
	NSNumber *newValue = [NSNumber numberWithBool:localDebugMode];
	[[NSUserDefaults standardUserDefaults] setObject:newValue forKey:kSCHClearLocalDebugMode];
	[[NSUserDefaults standardUserDefaults] synchronize];
}	

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    
	[[NSNotificationCenter defaultCenter] removeObserver:managedObjectContext_];
    [managedObjectContext_ release];
    [managedObjectModel_ release];
    [persistentStoreCoordinator_ release];
    
    [window release];
    [super dealloc];
}


@end

