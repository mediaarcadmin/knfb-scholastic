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
#import "SCHPopulateDataStore.h"
#import "SCHDictionaryDownloadManager.h"
#import "SCHBookManager.h"
#import "Reachability.h"
#import "AppDelegate_Shared.h"
#import "SCHStartingViewController.h" /* For errors */
#import "NSString+EmailValidation.h"
#import "SCHProfileSyncComponent.h"
#import "SCHSampleBooksImporter.h"
#import "SCHProcessingManager.h"
#import "SCHBookIdentifier.h"
#import "SCHAppBook.h"

NSString * const kSCHAppModelErrorDomain  = @"com.knfb.scholastic.AppModelErrorDomain";
NSInteger const kSCHAppModelErrorBookDoesntExist = 1000;
NSInteger const kSCHAppModelErrorBookRequiresNetworkConnection = 1001;

typedef enum {
	kSCHAppModelSyncStateNone = 0,
    kSCHAppModelSyncStateWaitingForLoginToComplete,
    kSCHAppModelSyncStateWaitingForBookshelves,
    kSCHAppModelSyncStateWaitingForPassword,
    kSCHAppModelSyncStateWaitingForWebParentToolsToComplete,
    kSCHAppModelSyncStateWaitingForSettings
} SCHAppModelSyncState;

@interface SCHAppModel()

@property (nonatomic, assign) id<SCHAppController> appController;
@property (nonatomic, assign) SCHAppModelSyncState syncState;
@property (nonatomic, retain) SCHBookIdentifier *processingIdentifier;

- (void)createLocalSampleBooksWithCompletion:(dispatch_block_t)completion importLocalBooks:(BOOL)importLocal;
- (void)startSyncNow:(BOOL)now requireAuthentication:(BOOL)authenticate withSyncManager:(SCHSyncManager *)syncManager;

@end

@implementation SCHAppModel

@synthesize appController;
@synthesize syncState;
@synthesize processingIdentifier;

- (void)dealloc
{
    appController = nil;
    [processingIdentifier release], processingIdentifier = nil;

    [super dealloc];
}

- (id)initWithAppController:(id<SCHAppController>)anAppController
{
    if ((self = [super init])) {
        
        appController = anAppController;
        
    }
    
    return self;
}

#pragma mark - Actions

- (void)restoreAppState
{
    [self restoreAppStateWithAppStateManager:[SCHAppStateManager sharedAppStateManager]
                       authenticationManager:[SCHAuthenticationManager sharedAuthenticationManager]
                                 syncManager:[SCHSyncManager sharedSyncManager]];
}

- (void)restoreAppStateWithAppStateManager:(SCHAppStateManager *)appStateManager
                     authenticationManager:(SCHAuthenticationManager *)authenticationManager
                               syncManager:(SCHSyncManager *)syncManager
{
    if ([authenticationManager hasUsernameAndPassword] && 
        [authenticationManager hasDRMInformation] && 
        [syncManager havePerformedAccountSync]) {
        
        if ([self hasProfilesInManagedObjectContext:appStateManager.managedObjectContext]) {
            [self.appController presentProfiles];
        } else {
            [self.appController presentProfilesSetup];
        }
    } else {
        [self.appController presentLogin];
    }
}

- (void)setupSamples
{
    [self createLocalSampleBooksWithCompletion:^{
        [self.appController presentSamples];
    } importLocalBooks:YES];
    
}

- (void)setupTour
{
    [self createLocalSampleBooksWithCompletion:^{
        [[SCHProcessingManager sharedProcessingManager] checkStateForAllBooks];
        [self.appController presentTour];
    } importLocalBooks:NO];
}

- (void)loginWithUsername:(NSString *)username password:(NSString *)password
{
    [self loginWithUsername:username
                   password:password 
                syncManager:[SCHSyncManager sharedSyncManager] 
      authenticationManager:[SCHAuthenticationManager sharedAuthenticationManager]];
}

- (void)loginWithUsername:(NSString *)username 
                 password:(NSString *)password 
              syncManager:(SCHSyncManager *)syncManager
    authenticationManager:(SCHAuthenticationManager *)authenticationManager
{
    if ([[Reachability reachabilityForInternetConnection] isReachable] == NO) {
        NSError *error = [NSError errorWithDomain:kSCHLoginErrorDomain  
                                             code:kSCHLoginReachabilityError 
                                         userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"An Internet connection is required to sign into your account.", @"")  
                                                                              forKey:NSLocalizedDescriptionKey]];
        
        [self.appController failedLoginWithError:error];
        
    } else {
        [syncManager resetSync]; 
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
                [authenticationManager authenticateWithUser:username 
                                                        password:password
                                                    successBlock:^(SCHAuthenticationManagerConnectivityMode connectivityMode) { 
                                                        if (connectivityMode == SCHAuthenticationManagerConnectivityModeOnline) {
                                                            [self startSyncNow:YES requireAuthentication:NO withSyncManager:syncManager];
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
                                                            NSMutableDictionary *mutableInfo = nil;
                                                            if ([error userInfo]) {
                                                                mutableInfo = [[[error userInfo] mutableCopy] autorelease];
                                                            } else {
                                                                mutableInfo = [NSMutableDictionary dictionary];
                                                            }
                                                            
                                                            NSString *localizedMessage = [[SCHAuthenticationManager sharedAuthenticationManager] localizedMessageForAuthenticationError:error];
                                                            
                                                            if (localizedMessage) {
                                                                [mutableInfo setValue:localizedMessage forKey:NSLocalizedDescriptionKey];
                                                            }
                                                            
                                                            NSError *localizedError = [NSError errorWithDomain:[error domain] code:[error code] userInfo:mutableInfo];
                                                            
                                                            [self.appController failedLoginWithError:localizedError];
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

- (void)waitForPassword
{
    self.syncState = kSCHAppModelSyncStateWaitingForPassword;
}

- (void)waitForSettings
{
    [self waitForSettingsWithSyncManager:[SCHSyncManager sharedSyncManager]];
}

- (void)waitForSettingsWithSyncManager:(SCHSyncManager *)syncManager
{
    self.syncState = kSCHAppModelSyncStateWaitingForSettings;
    [self startSyncNow:YES requireAuthentication:YES withSyncManager:syncManager];
}

- (void)waitForBookshelves
{
    [self waitForBookshelvesWithSyncManager:[SCHSyncManager sharedSyncManager]];
}

- (void)waitForBookshelvesWithSyncManager:(SCHSyncManager *)syncManager
{
    self.syncState = kSCHAppModelSyncStateWaitingForBookshelves;
    [self startSyncNow:YES requireAuthentication:YES withSyncManager:syncManager];
}

- (void)waitForWebParentToolsToComplete
{
    [self waitForWebParentToolsToCompleteWithSyncManager:[SCHSyncManager sharedSyncManager]];
}

- (void)waitForWebParentToolsToCompleteWithSyncManager:(SCHSyncManager *)syncManager
{
    self.syncState = kSCHAppModelSyncStateWaitingForWebParentToolsToComplete;
    // Need to also sync here in case the user has has set up a bookshelf in WPT outside the app
    // We never want to enter WPT not in wizard mode as there is no close button
    [self startSyncNow:YES requireAuthentication:YES withSyncManager:syncManager];
}

- (void)waitForTourBookWithIdentifier:(SCHBookIdentifier *)identifier
{
    self.processingIdentifier = identifier;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tourBookProcessingUpdate:) name:@"SCHBookStateUpdate" object:nil];
}

#pragma mark - Utility Methods

- (void)createLocalSampleBooksWithCompletion:(dispatch_block_t)completion importLocalBooks:(BOOL)importLocal
{
    AppDelegate_Shared *appDelegate = (AppDelegate_Shared *)[[UIApplication sharedApplication] delegate];
    [appDelegate setStoreType:kSCHStoreTypeSampleStore];
        
    SCHSampleBooksImporter *importer = [[[SCHSampleBooksImporter alloc] init] autorelease];
    
    BOOL sampleSuccess = [importer importSampleBooks];
    
    if (!sampleSuccess) {
        NSError *error = [NSError errorWithDomain:kSCHSamplesErrorDomain code:kSCHSamplesUnspecifiedError userInfo:[NSDictionary dictionaryWithObject:@"Failed to import Sample eBooks" forKey:@"failureReason"]];
        [self.appController failedSamplesWithError:error];
    } else {
        BOOL localSuccess =  YES;
        
        if (importLocal && [self hasBooksToImport]) {
            localSuccess = [importer importLocalBooks];
        }
        
        if (!localSuccess) {
            NSError *error = [NSError errorWithDomain:kSCHSamplesErrorDomain code:kSCHSamplesUnspecifiedError userInfo:[NSDictionary dictionaryWithObject:@"Failed to import local eBooks" forKey:@"failureReason"]];
            [self.appController failedSamplesWithError:error];
        } else {
            if (completion) {
                completion();
            }
        }
    }
}

- (void)startSyncNow:(BOOL)now requireAuthentication:(BOOL)authenticate withSyncManager:(SCHSyncManager *)syncManager
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncSucceeded:) name:SCHProfileSyncComponentDidCompleteNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncFailed:) name:SCHProfileSyncComponentDidFailNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDeregistered:) name:SCHAuthenticationManagerReceivedServerDeregistrationNotification object:nil];

    [syncManager accountSyncForced:now
       requireDeviceAuthentication:authenticate];
    [syncManager forceAllBookshelvesToSyncOnOpen];
}

- (BOOL)hasProfilesInManagedObjectContext:(NSManagedObjectContext *)moc
{
    NSAssert([NSThread isMainThread], @"hasProfiles must be called on the main thread");
    
    BOOL ret = NO;

    if (moc) {
        
        NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
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

#pragma mark - Notification handlers

- (void)deviceDeregistered:(NSNotification *)note
{
    [self.appController presentDeviceDeregistered];
}

- (void)syncSucceeded:(NSNotification *)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SCHProfileSyncComponentDidCompleteNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SCHProfileSyncComponentDidFailNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SCHAuthenticationManagerReceivedServerDeregistrationNotification object:nil];

    SCHAppModelSyncState currentSyncState = self.syncState;
    self.syncState = kSCHAppModelSyncStateNone;
    
    if (![self hasProfilesInManagedObjectContext:[SCHAppStateManager sharedAppStateManager].managedObjectContext]) {
        switch (currentSyncState) {
            case kSCHAppModelSyncStateWaitingForPassword:
                self.syncState = kSCHAppModelSyncStateWaitingForPassword;
                break;
            case kSCHAppModelSyncStateWaitingForWebParentToolsToComplete:
                self.syncState = kSCHAppModelSyncStateWaitingForWebParentToolsToComplete;
                break;
            case kSCHAppModelSyncStateWaitingForSettings:
                [self.appController presentSettings];
                break;
            default:
                [self.appController presentProfilesSetup];
        }
    } else {
        switch (currentSyncState) {
            case kSCHAppModelSyncStateWaitingForLoginToComplete:
            case kSCHAppModelSyncStateWaitingForBookshelves:
                [self.appController presentProfiles];
                break;
            case kSCHAppModelSyncStateWaitingForSettings:
                [self.appController presentSettings];
                break;
            default:
                break;
        }
    }
}

- (void)syncFailed:(NSNotification *)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SCHProfileSyncComponentDidCompleteNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SCHProfileSyncComponentDidFailNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SCHAuthenticationManagerReceivedServerDeregistrationNotification object:nil];

    NSError *error = [NSError errorWithDomain:kSCHSyncManagerErrorDomain
                                         code:kSCHSyncManagerGeneralError  
                                     userInfo:nil];  
    
    if (self.syncState == kSCHAppModelSyncStateWaitingForLoginToComplete) {
        [self.appController failedLoginWithError:error];
    } else if (self.syncState == kSCHAppModelSyncStateWaitingForSettings) {
        [self.appController presentSettings];
    } else {
        [self.appController failedSyncWithError:error];
    }
}

- (void)tourBookProcessingUpdate:(NSNotification *)notification
{
    SCHBookIdentifier *bookIdentifier = [[notification userInfo] objectForKey:@"bookIdentifier"];
    if (self.processingIdentifier && [bookIdentifier isEqual:self.processingIdentifier]) {
        SCHBookCurrentProcessingState bookState = [[[notification userInfo] objectForKey:@"bookState"] intValue];
        if (bookState == SCHBookProcessingStateReadyToRead) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SCHBookStateUpdate" object:nil];
            self.processingIdentifier = nil;
            [self.appController presentTourBookWithIdentifier:bookIdentifier];
        }
    }
}

#pragma mark - Interrogate App State

- (BOOL)hasBooksToImport
{
    return [SCHPopulateDataStore hasBooksToImport];
}

- (BOOL)hasExtraSampleBooks
{
    BOOL ret = NO;
    
    NSUInteger expectedSampleBookCount = 2;
    
    SCHAppStateManager *appStateManager = [SCHAppStateManager sharedAppStateManager];

    if ([appStateManager isSampleStore]) {
        NSArray *allSampleBooks = [[SCHBookManager sharedBookManager] allBookIdentifiersInManagedObjectContext:appStateManager.managedObjectContext];
        
        if ([allSampleBooks count] > expectedSampleBookCount) {
            ret = YES;
        }
    } else {
        SCHSampleBooksImporter *importer = [[[SCHSampleBooksImporter alloc] init] autorelease];
        return ([importer sampleBookCount] > expectedSampleBookCount);
    }
    
    return ret;
}

#pragma mark - Interrogate Book State

- (BOOL)canOpenBookWithIdentifier:(SCHBookIdentifier *)identifier error:(NSError **)error
{
    BOOL canOpen = NO;
    
    SCHAppStateManager *appStateManager = [SCHAppStateManager sharedAppStateManager];
    SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:identifier inManagedObjectContext:appStateManager.managedObjectContext];
    
    if (book) {
        if ([book requiresNetworkForProcessing] && ![[Reachability reachabilityForInternetConnection] isReachable]) {
            NSDictionary *eDict = [NSDictionary dictionaryWithObject:NSLocalizedString(@"This eBook has not yet been downloaded. Please connect to the Internet in order to download and read this eBook.", @"")
                                                              forKey:NSLocalizedDescriptionKey];
            
            if (error != NULL) {
                *error = [[[NSError alloc] initWithDomain:kSCHAppModelErrorDomain
                                                     code:kSCHAppModelErrorBookRequiresNetworkConnection userInfo:eDict] autorelease];
            }
        } else {
            canOpen = [book canOpenBookError:error];
        }
    } else {
        if (error != NULL) {
            *error = [[[NSError alloc] initWithDomain:kSCHAppModelErrorDomain
                                                 code:kSCHAppModelErrorBookDoesntExist userInfo:nil] autorelease];
        }
    }
    
    return canOpen;
}

- (NSInteger)bookshelfStyleForBookWithIdentifier:(SCHBookIdentifier *)identifier
{
    SCHAppStateManager *appStateManager = [SCHAppStateManager sharedAppStateManager];
    SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:identifier inManagedObjectContext:appStateManager.managedObjectContext];

    SCHBookshelfStyles ret = kSCHBookshelfStyleNone;
    NSString *categoryType = book.categoryType;
    
    if ([categoryType isEqualToString:kSCHAppBookYoungReader]) {
        ret = kSCHBookshelfStyleYoungChild;
    } else if ([categoryType isEqualToString:kSCHAppBookOldReader]) {
        ret = kSCHBookshelfStyleOlderChild;
    }
    
    return ret;
}
    
@end
