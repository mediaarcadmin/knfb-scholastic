//
//  AppDelegate_Shared.m
//  Scholastic
//
//  Created by John S. Eddie on 30/12/2010.
//  Copyright 2010 BitWink Limited. All rights reserved.
//

#import "AppDelegate_Shared.h"
#import "AppDelegate_Private.h"
#import "SCHBookManager.h"
#import "SCHSyncManager.h"
#import "SCHUserDefaults.h"
#import "SCHURLManager.h"
#import "SCHDictionaryDownloadManager.h"
#import "SCHDictionaryAccessManager.h"
#import <CoreText/CoreText.h>
#if RUN_KIF_TESTS
#import "SCHKIFTestController.h"
#endif

static NSString* const wmModelCertFilename = @"devcerttemplate.dat";
static NSString* const prModelCertFilename = @"iphonecert.dat";

@interface AppDelegate_Shared ()

- (void)setupUserDefaults;
- (BOOL)createApplicationSupportDirectory;
- (void)ensureCorrectCertsAvailable;

@end

@implementation AppDelegate_Shared

@synthesize window;
@synthesize startingViewController;
@synthesize coreDataHelper;

#pragma mark - Application lifecycle

- (void)dealloc 
{    
    [coreDataHelper release], coreDataHelper = nil;
    [startingViewController release], startingViewController = nil;
    [window release], window = nil;
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions    
{
    [self setupUserDefaults];
    
    if ([self createApplicationSupportDirectory] == NO) {
		NSLog(@"Application Support directory could not be created.");
	}
    
    SCHBookManager *bookManager = [SCHBookManager sharedBookManager];
    bookManager.persistentStoreCoordinator = self.coreDataHelper.persistentStoreCoordinator;
    bookManager.mainThreadManagedObjectContext = self.coreDataHelper.managedObjectContext;
    
    SCHSyncManager *syncManager = [SCHSyncManager sharedSyncManager];
	syncManager.managedObjectContext = self.coreDataHelper.managedObjectContext;
	[syncManager start];
	
    // You must clean the app from the simulator and uncomment the population 
    // method then break immediately afterwards. Whilst broken copy 
    // Scholastic.sqlite database to the project as Scholastic_Sample.sqlite
//  [[SCHSyncManager sharedSyncManager] populateTestSampleStore];
//  [[SCHSyncManager sharedSyncManager] populateSampleStore];
    
	SCHURLManager *urlManager = [SCHURLManager sharedURLManager];
	urlManager.managedObjectContext = self.coreDataHelper.managedObjectContext;
    
	// instantiate the shared processing manager
	[SCHProcessingManager sharedProcessingManager].managedObjectContext = self.coreDataHelper.managedObjectContext;
    
    // pre-warm Core Text
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        [attributes setObject:@"Arial" forKey:(id)kCTFontFamilyNameAttribute];
        [attributes setObject:[NSNumber numberWithFloat:36.0f] forKey:(id)kCTFontSizeAttribute];
        CTFontDescriptorRef fontDesc = CTFontDescriptorCreateWithAttributes((CFDictionaryRef)attributes);
        CTFontRef matchingFont = CTFontCreateWithFontDescriptor(fontDesc, 36.0f, NULL);
        CFRelease(matchingFont);
        CFRelease(fontDesc);
    });
	
    SCHDictionaryDownloadManager *ddm = [SCHDictionaryDownloadManager sharedDownloadManager];
    ddm.mainThreadManagedObjectContext = self.coreDataHelper.managedObjectContext;
    ddm.persistentStoreCoordinator = self.coreDataHelper.persistentStoreCoordinator;
    [ddm checkIfUpdateNeeded];

	// instantiate the shared dictionary access manager
	SCHDictionaryAccessManager *dam = [SCHDictionaryAccessManager sharedAccessManager];
    dam.mainThreadManagedObjectContext = self.coreDataHelper.managedObjectContext;
    dam.persistentStoreCoordinator = self.coreDataHelper.persistentStoreCoordinator;
	
	[self ensureCorrectCertsAvailable];
	    
#if RUN_KIF_TESTS
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [[SCHKIFTestController sharedInstance] startTestingWithCompletionBlock:^{
            // Exit after the tests complete so that CI knows we're done
            exit([[SCHKIFTestController sharedInstance] failureCount]);
        }];
        
    });
#endif    

	return YES;
}	

- (void)setupUserDefaults
{
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
								 [NSNumber numberWithBool:NO], kSCHUserDefaultsPerformedFirstSyncUpToBooks,
								 [NSNumber numberWithBool:YES], kSCHUserDefaultsSpaceSaverMode,
                                 nil];
    
	[[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
}

- (void)clearUserDefaults
{
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:[[NSBundle mainBundle] bundleIdentifier]];
}

/**
 Save changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application 
{
    [self.coreDataHelper saveContext];
}

- (void)applicationDidEnterBackground:(UIApplication *)application 
{
    [self.coreDataHelper saveContext];
}

- (void)applicationWillEnterForeground:(UIApplication *)application 
{
    // when we enter the foreground, check to see if the dictionary needs updating
    [[SCHDictionaryDownloadManager sharedDownloadManager] checkIfUpdateNeeded];
}

#pragma mark - Application directory functions

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory 
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSURL *)applicationSupportDocumentsDirectory 
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
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

- (void)ensureCorrectCertsAvailable 
{
    // Copy DRM resources to writeable directory.
	if (![self createApplicationSupportDirectory]) {
		NSLog(@"Application Support directory could not be created for DRM certificates.");
		return;
	}
	NSURL* supportDir = [[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
	NSURL* srcWmModelCert = [[[[[NSBundle mainBundle] resourceURL] URLByAppendingPathComponent:@"DRM"] 
                              URLByAppendingPathComponent:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone?@"iPhone":@"iPad")] 
                             URLByAppendingPathComponent:wmModelCertFilename]; 

	NSURL* destWmModelCert = [supportDir URLByAppendingPathComponent:wmModelCertFilename];
	NSError* err = nil;
	[[NSFileManager defaultManager] copyItemAtURL:srcWmModelCert toURL:destWmModelCert error:&err];
	if ( err != nil) {
		//NSLog(@"Copying DRM-WM certificate: %@, aborting copy.", [err localizedDescription]);
		return;
	}
    NSURL* srcPRModelCert = [[[[[NSBundle mainBundle] resourceURL] URLByAppendingPathComponent:@"DRM"] 
                              URLByAppendingPathComponent:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone?@"iPhone":@"iPad")] 
                             URLByAppendingPathComponent:prModelCertFilename]; 
	NSURL* destPRModelCert = [supportDir URLByAppendingPathComponent:prModelCertFilename];
	[[NSFileManager defaultManager] copyItemAtURL:srcPRModelCert toURL:destPRModelCert error:&err];  
	if ( err != nil) {
		// Very unlikely to get here.
		NSLog(@"Copying DRM-PR certificate: %@", [err localizedDescription]);
		return;
	}
	NSLog(@"Copied DRM certificates to Application Support directory.");
}
    
#pragma mark - Core Data stack

- (SCHCoreDataHelper *)coreDataHelper
{
    if (coreDataHelper == nil) {
        coreDataHelper = [[SCHCoreDataHelper alloc] init];
    }

    return(coreDataHelper);
}

@end

