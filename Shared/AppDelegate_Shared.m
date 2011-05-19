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
#import "SCHBookshelfSyncComponent.h"

#if LOCALDEBUG
#import "SCHLocalDebug.h"
#endif

static NSString * const kSCHClearLocalDebugMode = @"kSCHClearLocalDebugMode";
static NSString* const wmModelCertFilename = @"devcerttemplate.dat";
static NSString* const prModelCertFilename = @"iphonecert.dat";

@implementation AppDelegate_Shared

@synthesize window;

- (void)dealloc 
{    
	[[NSNotificationCenter defaultCenter] removeObserver:managedObjectContext_];
    [managedObjectContext_ release];
    [managedObjectModel_ release];
    [persistentStoreCoordinator_ release];
    
    [window release];
    [super dealloc];
}

#pragma mark - Application directory functions

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory 
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

/**
 Creates the application's Application Support directory if it doesn't already exist.
 */
- (BOOL)createApplicationSupportDirectory
{
	NSArray  *applicationSupportPaths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *applicationSupportPath = ([applicationSupportPaths count] > 0) ? [applicationSupportPaths objectAtIndex:0] : nil;
	
	BOOL isDir;
	if (![[NSFileManager defaultManager] fileExistsAtPath:applicationSupportPath isDirectory:&isDir] || !isDir) {
		NSError * createApplicationSupportDirError = nil;
		
		if (![[NSFileManager defaultManager] createDirectoryAtPath:applicationSupportPath 
									   withIntermediateDirectories:YES 
														attributes:nil 
															 error:&createApplicationSupportDirError]) 
		{
			NSLog(@"Error: could not create Application Support directory in the Library directory! %@, %@", 
				  createApplicationSupportDirError, [createApplicationSupportDirError userInfo]);
			return NO;
		} 
		else {
			NSLog(@"Created Application Support directory within Library.");
			return YES;
		}
	}
	else {
		return YES;
	}
}

#pragma mark - Application lifecycle

- (void)ensureCorrectCertsAvailable 
{
    // Copy DRM resources to writeable directory.
	if (![self createApplicationSupportDirectory]) {
		NSLog(@"Application Support directory could not be created for DRM certificates.");
		return;
	}
	NSURL* supportDir = [[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
	// TODO ipad certs have same name, must be gotten from a different location
    NSURL* srcWmModelCert = [[[NSBundle mainBundle] resourceURL] URLByAppendingPathComponent:wmModelCertFilename]; 
	NSURL* destWmModelCert = [supportDir URLByAppendingPathComponent:wmModelCertFilename];
	NSError* err = nil;
	[[NSFileManager defaultManager] copyItemAtURL:srcWmModelCert toURL:destWmModelCert error:&err];
	if ( err != nil) {
		//NSLog(@"Copying DRM-WM certificate: %@, aborting copy.", [err localizedDescription]);
		return;
	}
	NSURL* srcPRModelCert = [[[NSBundle mainBundle] resourceURL] URLByAppendingPathComponent:prModelCertFilename]; 
	NSURL* destPRModelCert = [supportDir URLByAppendingPathComponent:prModelCertFilename];
	[[NSFileManager defaultManager] copyItemAtURL:srcPRModelCert toURL:destPRModelCert error:&err];  
	if ( err != nil) {
		// Very unlikely to get here.
		NSLog(@"Copying DRM-PR certificate: %@", [err localizedDescription]);
		return;
	}
	NSLog(@"Copied DRM certificates to Application Support directory.");
}

- (void)copyLocalFilesIfMissing
{
#if LOCALDEBUG    
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"SCHUserContentItem" inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSError *error = nil;
    NSArray *books = [moc executeFetchRequest:request error:&error];
    [request release];
    
    SCHLocalDebug *localDebug = [[SCHLocalDebug alloc] init];
    localDebug.managedObjectContext = moc;
    if (![books count])
    {
        NSLog(@"Copying local files as none present in database");
        [localDebug setup];
    } else {
        NSLog(@"Not copying local files as already present in database");
        [localDebug checkImports];
    }
    [localDebug release];
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
    
#if LOCALDEBUG
	[[NSNotificationCenter defaultCenter] postNotificationName:kSCHBookshelfSyncComponentComplete object:nil];
    [self performSelector:@selector(copyLocalFilesIfMissing) withObject:nil afterDelay:0.1f]; // Stop the watchdog from killing us on launch
#endif
	
	[[SCHDictionaryManager sharedDictionaryManager] checkIfUpdateNeeded];
	
	[self ensureCorrectCertsAvailable];
	
	return YES;
}	

/**
 Save changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application 
{
    [self saveContext];
}


- (void)applicationDidEnterBackground:(UIApplication *)application 
{
    [self saveContext];
}

- (void)applicationWillEnterForeground:(UIApplication *)application 
{
}

- (void)saveContext 
{    
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
    
- (void)mergeChangesFromContextDidSaveNotification:(NSNotification *)notification 
{
    [[self managedObjectContext] lock];
	[[self managedObjectContext] mergeChangesFromContextDidSaveNotification:notification];
    [[self managedObjectContext] unlock];
}

#pragma mark - Core Data stack

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
- (NSManagedObjectModel *)managedObjectModel 
{    
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
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator 
{    
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

#pragma mark - Local Debug Mode

- (void)checkForModeSwitch
{
	// check for change between local debug mode and normal network mode
	NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
								 [NSNumber numberWithBool:NO], kSCHUserDefaultsPerformedFirstSyncUpToBooks, nil];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];		
	
	BOOL localDebugMode = NO;
	
#if LOCALDEBUG
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

@end

