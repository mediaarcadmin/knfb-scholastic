//
//  SCHAppModel.m
//  Scholastic
//
//  Created by Matt Farrugia on 19/07/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHAppModel.h"
#import "SCHAppController.h"
#import "SCHAppStateManager.h"
#import "SCHAuthenticationManager.h"
#import "SCHSyncManager.h"
#import "SCHProfileItem.h"
#import "SCHSampleBooksImporter.h"
#import "SCHDictionaryDownloadManager.h"
#import "Reachability.h"
#import "AppDelegate_Shared.h"
#import "SCHStartingViewController.h" /* For errors */
#import "NSString+EmailValidation.h"

typedef enum {
	kSCHAppModelSyncStateNone = 0,
    kSCHAppModelSyncStateWaitingForLoginToComplete,
    kSCHAppModelSyncStateWaitingForBookshelves,
    kSCHAppModelSyncStateWaitingForPassword,
    kSCHAppModelSyncStateWaitingForWebParentToolsToComplete
} SCHAppModelSyncState;

@interface SCHAppModel()

@property (nonatomic, assign) id<SCHAppController> appController;
@property (nonatomic, assign) SCHAppStateManager *appStateManager;
@property (nonatomic, assign) SCHAuthenticationManager *authenticationManager;
@property (nonatomic, assign) SCHSyncManager *syncManager;
@property (nonatomic, assign) SCHAppModelSyncState syncState;

- (BOOL)hasProfiles;

@end

@implementation SCHAppModel

@synthesize appController;
@synthesize appStateManager;
@synthesize authenticationManager;
@synthesize syncManager;
@synthesize syncState;

- (void)dealloc
{
    appController = nil;
    appStateManager = nil;
    authenticationManager = nil;
    syncManager = nil;
    
    [super dealloc];
}

- (id)initWithAppController:(id<SCHAppController>)anAppController
{
    return [self initWithAppController:anAppController
                       appStateManager:[SCHAppStateManager sharedAppStateManager]
                 authenticationManager:[SCHAuthenticationManager sharedAuthenticationManager]
                           syncManager:[SCHSyncManager sharedSyncManager]];
            
}

- (id)initWithAppController:(id<SCHAppController>)anAppController
            appStateManager:(SCHAppStateManager *)anAppStateManager
      authenticationManager:(SCHAuthenticationManager *)anAuthenticationManager
                syncManager:(SCHSyncManager *)aSyncManager
{
    if ((self = [super init])) {
        
        appController = anAppController;
        appStateManager = anAppStateManager;
        authenticationManager = anAuthenticationManager;
        syncManager = aSyncManager;
        
        if ([authenticationManager hasUsernameAndPassword] && 
            [authenticationManager hasDRMInformation] && 
            [syncManager havePerformedFirstSyncUpToBooks]) {
            
            if ([self hasProfiles]) {
                [appController presentProfiles];
            } else {
                [appController presentProfilesSetup];
            }
        } else if ([appStateManager isSampleStore]) {
            [appController presentSamplesWithWelcome:NO];
        } else {
            [appController presentLogin];
        }
    }
    
    return self;
}

#pragma mark - Actions

- (void)setupPreview
{
    [self setupPreviewWithImporter:[SCHSampleBooksImporter sharedImporter]];
}

- (void)setupPreviewWithImporter:(SCHSampleBooksImporter *)importer
{
    AppDelegate_Shared *appDelegate = (AppDelegate_Shared *)[[UIApplication sharedApplication] delegate];
    [appDelegate setStoreType:kSCHStoreTypeSampleStore];
    
    NSString *localManifest = [[NSBundle mainBundle] pathForResource:kSCHSampleBooksLocalManifestFile ofType:nil];
    NSURL *localManifestURL = localManifest ? [NSURL fileURLWithPath:localManifest] : nil;
            
    [importer importSampleBooksFromRemoteManifest:[NSURL URLWithString:kSCHSampleBooksRemoteManifestURL] 
                                                                   localManifest:localManifestURL
                                                                    successBlock:^{
                                                                        [self.appController presentSamplesWithWelcome:YES];
                                                                    }
                                                                    failureBlock:^(NSString * failureReason){
                                                                        NSError *error = [NSError errorWithDomain:kSCHSamplesErrorDomain code:kSCHSamplesUnspecifiedError userInfo:[NSDictionary dictionaryWithObject:failureReason forKey:@"failureReason"]];
                                                                        [self.appController failedSamplesWithError:error];
                                                                    }];
}

- (void)loginWithUsername:(NSString *)username password:(NSString *)password
{
    if ([[Reachability reachabilityForInternetConnection] isReachable] == NO) {
        NSError *error = [NSError errorWithDomain:kSCHLoginErrorDomain  
                                             code:kSCHLoginReachabilityError 
                                         userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"An Internet connection is required to sign into your account.", @"")  
                                                                              forKey:NSLocalizedDescriptionKey]];
        
        [self.appController failedLoginWithError:error];
        
    } else {
        [self.syncManager resetSync]; 
        AppDelegate_Shared *appDelegate = (AppDelegate_Shared *)[[UIApplication sharedApplication] delegate];
        [appDelegate setStoreType:kSCHStoreTypeStandardStore];
        
        self.syncState = kSCHAppModelSyncStateWaitingForLoginToComplete;
        
        if ([[username stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0 &&
            [[password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {      
#if USE_EMAIL_ADDRESS_AS_USERNAME
            NSString *errorMessage = NSLocalizedString(@"There was a problem checking your email and password. Please try again.", @"");
            if ([username isValidEmailAddress] == NO) {
                NSError *anError = [NSError errorWithDomain:kSCHAccountValidationErrorDomain  
                                                       code:kSCHAccountValidationMalformedEmailError  
                                                   userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"Email address is not valid. Please try again.", @"")  
                                                                                        forKey:NSLocalizedDescriptionKey]];
                [self.appController failedLoginWithError:anError];
            } else {
#else 
                NSString *errorMessage = NSLocalizedString(@"There was a problem checking your username and password. Please try again.", @"");
#endif
                [self.authenticationManager authenticateWithUser:username 
                                                        password:password
                                                    successBlock:^(SCHAuthenticationManagerConnectivityMode connectivityMode) { 
                                                        if (connectivityMode == SCHAuthenticationManagerConnectivityModeOnline) { 
                                                            [[SCHSyncManager sharedSyncManager] firstSync:YES requireDeviceAuthentication:NO];
                                                        } else { 
                                                            NSError *anError = [NSError errorWithDomain:kSCHAuthenticationManagerErrorDomain  
                                                                                                   code:kSCHAuthenticationManagerOfflineError  
                                                                                               userInfo:[NSDictionary dictionaryWithObject:errorMessage  
                                                                                                                                    forKey:NSLocalizedDescriptionKey]];        
                                                            [self.appController failedLoginWithError:anError];
                                                        } 
                                                    } 
                                                    failureBlock:^(NSError * error){
                                                        if (error == nil) {
                                                            NSError *anError = [NSError errorWithDomain:kSCHAuthenticationManagerErrorDomain  
                                                                                                   code:kSCHAuthenticationManagerGeneralError  
                                                                                               userInfo:[NSDictionary dictionaryWithObject:errorMessage  
                                                                                                                                    forKey:NSLocalizedDescriptionKey]];  
                                                            
                                                            [self.appController failedLoginWithError:anError];
                                                        } else {
                                                            [self.appController failedLoginWithError:error];
                                                        }
                                                    }
                                     waitUntilVersionCheckIsDone:YES];    
#if USE_EMAIL_ADDRESS_AS_USERNAME
            }
#endif
        } else {
            NSError *anError = [NSError errorWithDomain:kSCHAccountValidationErrorDomain  
                                                   code:kSCHAccountValidationCredentialsMissingError  
                                               userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"Username and password must not be blank. Please try again.", @"")  
                                                                                    forKey:NSLocalizedDescriptionKey]];
            [self.appController failedLoginWithError:anError];
        }    
    }
}

#pragma mark - Temp state methods

- (void)waitingForPassword
{
    self.syncState = kSCHAppModelSyncStateWaitingForPassword;
}

- (void)waitingForBookshelves
{
    self.syncState = kSCHAppModelSyncStateWaitingForBookshelves;
}

- (void)waitingForWebParentToolsToComplete
{
    self.syncState = kSCHAppModelSyncStateWaitingForWebParentToolsToComplete;
    // Need to also sync here in case the user has has set up a bookshelf in WPT outside teh app
    // We never want to enter WPT not in wizard mode as there is no close button
    [[SCHSyncManager sharedSyncManager] firstSync:YES requireDeviceAuthentication:YES];
}

#pragma mark - Utility Methods

- (BOOL)hasProfiles;
{
    NSAssert([NSThread isMainThread], @"hasProfiles must be called on the main thread");
    
    BOOL ret = NO;
    NSManagedObjectContext *moc = self.appStateManager.managedObjectContext;
    
    if (moc) {
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:[NSEntityDescription entityForName:kSCHProfileItem inManagedObjectContext:moc]];
        [request setIncludesSubentities:NO];
        
        NSError *error;
        NSUInteger count = [moc countForFetchRequest:request error:&error];
        if (count == NSNotFound) {
            NSLog(@"Error whilst fetching profile count %@", error);
        } else if (count > 0) {
            ret = YES;
        }
    }
    
    return ret;
}

- (BOOL)dictionaryDownloadRequired
{
    BOOL downloadRequired = 
    ([[SCHDictionaryDownloadManager sharedDownloadManager] userRequestState] == SCHDictionaryUserNotYetAsked) 
    || ([[SCHDictionaryDownloadManager sharedDownloadManager] dictionaryProcessingState] == SCHDictionaryProcessingStateUserSetup);
    
    return (downloadRequired && [[Reachability reachabilityForLocalWiFi] isReachable]);
}

@end
