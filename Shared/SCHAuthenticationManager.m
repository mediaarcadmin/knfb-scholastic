//
//  SCHAuthenticationManager.m
//  Scholastic
//
//  Created by John S. Eddie on 21/01/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHAuthenticationManager.h"
#import "SCHAuthenticationManagerProtected.h"

#import "SCHLibreAccessWebService.h"
#import "SFHFKeychainUtils.h"
#import "Reachability.h"
#import "SCHDrmSession.h"
#import "SCHURLManager.h"
#import "SCHProcessingManager.h"                
#import "SCHSyncManager.h"
#import "SCHAppStateManager.h"
#import "AppDelegate_Shared.h"
#import "SCHBookManager.h"
#import "BITAPIError.h"
#import "SCHUserDefaults.h"
#import "NSString+URLEncoding.h"
#import "SCHNonDRMAuthenticationManager.h"
#import "SCHVersionDownloadManager.h"
#import "SCHCOPPAManager.h"
#import "SCHRecommendationManager.h"

// Constants
NSString * const SCHAuthenticationManagerReceivedServerDeregistrationNotification = @"SCHAuthenticationManagerReceivedServerDeregistrationNotification";
NSString * const SCHAuthenticationManagerDidDeregisterNotification = @"SCHAuthenticationManagerDidDeregisterNotification";
NSString * const kSCHAuthenticationManagerNSError = @"NSError";

NSString * const kSCHAuthenticationManagerErrorDomain = @"AuthenticationManagerErrorDomain";
NSInteger const kSCHAuthenticationManagerGeneralError = 2000;
NSInteger const kSCHAuthenticationManagerLoginError = 2001;
NSInteger const kSCHAuthenticationManagerOfflineError = 2002;

NSString * const kSCHAuthenticationManagerServiceName = @"Scholastic";

NSTimeInterval const kSCHAuthenticationManagerSecondsInAMinute = 60.0;

@interface SCHAuthenticationManager ()

- (void)aTokenOnMainThread;
- (void)isAuthenticatedOnMainThread:(NSValue *)returnValue;
- (void)hasUsernameAndPasswordOnMainThread:(NSValue *)returnValue;
- (void)performPostDeregistrationWaitUntilFinished:(BOOL)wait;
- (void)setLastKnownAuthToken:(NSString *)token;

@property (nonatomic, copy) SCHDrmRegistrationSuccessBlock registrationSuccessBlock;
@property (nonatomic, copy) SCHDrmRegistrationFailureBlock registrationFailureBlock;
@property (nonatomic, copy) SCHDrmDeregistrationSuccessBlock deregistrationSuccessBlock;
@property (nonatomic, copy) SCHDrmDeregistrationFailureBlock deregistrationFailureBlock;
@property (nonatomic, retain) NSTimer *renewTimer;

@end

/*
 * This class is thread safe in respect to all the exposed methods being
 * wrappers for private methods that are always executed on the MainThread.
 * Notifications are also sent on the Main Thread and should be handled and 
 * propogated to worker threads appropriately.
 */

@implementation SCHAuthenticationManager

@synthesize aToken;
@synthesize isAuthenticated;
@synthesize tokenExpires;
@synthesize accountValidation;
@synthesize libreAccessWebService;
@synthesize drmRegistrationSession;
@synthesize authenticationSuccessBlock;
@synthesize authenticationFailureBlock;
@synthesize registrationSuccessBlock;
@synthesize registrationFailureBlock;
@synthesize deregistrationSuccessBlock;
@synthesize deregistrationFailureBlock;
@synthesize renewTimer;
@synthesize authenticating;

#pragma mark - Singleton instance methods

+ (SCHAuthenticationManager *)sharedAuthenticationManager
{
    static dispatch_once_t pred;
    static SCHAuthenticationManager *sharedAuthenticationManager = nil;
    
    dispatch_once(&pred, ^{
        NSAssert([NSThread isMainThread] == YES, @"SCHAuthenticationManager:sharedAuthenticationManager MUST be executed on the main thread");
#if NON_DRM_AUTHENTICATION
        sharedAuthenticationManager = [[SCHNonDRMAuthenticationManager allocWithZone:NULL] init];
#else
        sharedAuthenticationManager = [[super allocWithZone:NULL] init];
#endif
    });
    
    return sharedAuthenticationManager;
}

#pragma mark - Object lifecycle 

- (id)init
{
	self = [super init];
	if (self != nil) {
		aToken = nil;
		tokenExpires = nil;
		
		accountValidation = [[SCHAccountValidation alloc] init];
		
		libreAccessWebService = [[SCHLibreAccessWebService alloc] init];	
		libreAccessWebService.delegate = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(applicationDidEnterBackground:) 
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(applicationSignificantTimeChange:) 
                                                     name:UIApplicationSignificantTimeChangeNotification 
                                                   object:nil];
	}
	return self;
}

- (void)dealloc 
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationSignificantTimeChangeNotification object:nil];
    
    [aToken release], aToken = nil;
    [tokenExpires release], tokenExpires = nil;
    [accountValidation release], accountValidation = nil;
    [libreAccessWebService release], libreAccessWebService = nil;
    [drmRegistrationSession release], drmRegistrationSession = nil;
    [authenticationSuccessBlock release], authenticationSuccessBlock = nil;
    [authenticationFailureBlock release], authenticationFailureBlock = nil;
    [registrationSuccessBlock release], registrationSuccessBlock = nil;
    [registrationFailureBlock release], registrationFailureBlock = nil;
    [deregistrationSuccessBlock release], deregistrationSuccessBlock = nil;
    [deregistrationFailureBlock release], deregistrationFailureBlock = nil;
    [renewTimer invalidate];
    [renewTimer release], renewTimer = nil;
    
    [super dealloc];
}

#pragma mark - Accessor methods

- (SCHDrmRegistrationSession *)drmRegistrationSession
{
    if(drmRegistrationSession == nil) {
        drmRegistrationSession = [[SCHDrmRegistrationSession alloc] init];
        drmRegistrationSession.delegate = self;   
    }
    
    return drmRegistrationSession;
}

#pragma mark - methods

- (void)authenticateWithUser:(NSString *)userName 
                    password:(NSString *)password
                successBlock:(SCHAuthenticationSuccessBlock)successBlock
                failureBlock:(SCHAuthenticationFailureBlock)failureBlock
 waitUntilVersionCheckIsDone:(BOOL)wait
{
    
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self authenticateWithUser:userName 
                              password:password 
                          successBlock:successBlock 
                          failureBlock:failureBlock
           waitUntilVersionCheckIsDone:wait];
        });
        return;
    }
        
    SCHAuthenticationSuccessBlock aSuccessBlock = ^(SCHAuthenticationManagerConnectivityMode connectivityMode){        
        if (successBlock) {
            successBlock(connectivityMode);
        }
    };
    
    SCHAuthenticationFailureBlock aFailureBlock = ^(NSError * error){
        [[SCHAuthenticationManager sharedAuthenticationManager] clear];
        
        if (failureBlock) {
            failureBlock(error);
        }
    };
    
    if([[SCHAppStateManager sharedAppStateManager] canAuthenticate] == YES) {
        if ([[Reachability reachabilityForInternetConnection] isReachable] == YES) {
            if (([[userName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) &&
                ([[password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0)) {
                
                [self clearOnMainThread];
                
                [[NSUserDefaults standardUserDefaults] setObject:userName forKey:kSCHAuthenticationManagerUsername];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [SFHFKeychainUtils storeUsername:userName 
                                     andPassword:password 
                                  forServiceName:kSCHAuthenticationManagerServiceName 
                                  updateExisting:YES 
                                           error:nil];
                
                [self authenticateWithSuccessBlock:aSuccessBlock
                                      failureBlock:aFailureBlock
                       waitUntilVersionCheckIsDone:wait];
                
            } else {
                NSError *error = [NSError errorWithDomain:kSCHAuthenticationManagerErrorDomain 
                                                     code:kSCHAuthenticationManagerLoginError 
                                                 userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"You must enter a username and password", @"") 
                                                                                      forKey:NSLocalizedDescriptionKey]];
                
                
                [self authenticationDidFailWithError:error];
            }
        } else {
            NSError *error = [NSError errorWithDomain:kSCHAuthenticationManagerErrorDomain 
                                                 code:kSCHAuthenticationManagerLoginError 
                                             userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"You must have internet access to login", @"") 
                                                                                  forKey:NSLocalizedDescriptionKey]];
            
            [self authenticationDidFailWithError:error];
        }
    } else {
        NSString *nonNullUserName = (userName == nil ? @"" : userName);

        [[NSUserDefaults standardUserDefaults] setObject:nonNullUserName forKey:kSCHAuthenticationManagerUsername];
        
        [SFHFKeychainUtils storeUsername:nonNullUserName
                             andPassword:password 
                          forServiceName:kSCHAuthenticationManagerServiceName 
                          updateExisting:YES 
                                   error:nil];
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSCHAuthenticationManagerDeviceKey];                        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSCHAuthenticationManagerUserKey];   
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        self.aToken = @"";
        self.tokenExpires = [NSDate distantFuture];
        self.authenticationSuccessBlock = aSuccessBlock;
        
        // TODO: Why does this need to be delayed?
        double delayInSeconds = 0.1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self authenticationDidSucceedWithOfflineMode:SCHAuthenticationManagerConnectivityModeOnline];
        });
    }
}

- (BOOL)hasUsernameAndPassword
{
    BOOL ret = NO;
    NSValue *resultValue = [NSValue valueWithPointer:&ret];

    // we block until the selector completes to make sure we always have the return object before use
    [self performSelectorOnMainThread:@selector(hasUsernameAndPasswordOnMainThread:) 
                           withObject:resultValue 
                        waitUntilDone:YES];

    return ret;
}

- (BOOL)hasDRMInformation
{
    return YES;
}

- (void)clear
{
    [self performSelectorOnMainThread: @selector(clearOnMainThread) 
                           withObject:nil 
                        waitUntilDone:YES];
}

- (void)clearAppProcessingWaitUntilFinished:(BOOL)wait
{
    dispatch_block_t clearBlock = ^{
        [self clearAppProcessingOnMainThreadWaitUntilFinished:wait];
    };
    
    if ([NSThread isMainThread]) {
        clearBlock();
    } else {
        dispatch_sync(dispatch_get_main_queue(), clearBlock);
    }
}

- (void)forceDeregistrationWithCompletionBlock:(SCHDrmDeregistrationSuccessBlock)completionBlock
{
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self forceDeregistrationWithCompletionBlock:completionBlock];
        });
        return;
    }
    
    self.deregistrationSuccessBlock = completionBlock;
    self.deregistrationFailureBlock = ^(NSError *error){
        [self performPostDeregistrationWaitUntilFinished:NO];
        
        if (completionBlock) {
            completionBlock();
        }
    };
        
    NSString *authToken = self.aToken;
    
    if (!authToken) {
        NSLog(@"Warning: an attempt was made to force deregisteration without a current auth token. Using last known auth token");
        authToken = [[SCHAppStateManager sharedAppStateManager] lastKnownAuthToken];
    }
    
    if (authToken) {
        [authToken retain];
        [self expireToken];
        [self.drmRegistrationSession deregisterDevice:[authToken autorelease]];
    } else {
        NSLog(@"Warning: no previous auth token was available. Completing deregistration without Leaving the DRM Domain.");
        [self registrationSession:nil deregistrationDidComplete:nil];
    }
}

- (void)deregisterWithSuccessBlock:(SCHDrmDeregistrationSuccessBlock)successBlock
                      failureBlock:(SCHDrmDeregistrationFailureBlock)failureBlock;
{
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self deregisterWithSuccessBlock:successBlock
                                failureBlock:failureBlock];
        });
        return;
    }
    
    self.deregistrationSuccessBlock = successBlock;
    self.deregistrationFailureBlock = failureBlock;
    
    if ([[SCHAppStateManager sharedAppStateManager] canAuthenticate] && self.aToken) {
        [self.drmRegistrationSession deregisterDevice:self.aToken];
    } else {
        // This fall-through case is only if we have tried to deregister but the app state says we should not authenticate 
        // or we don't have a current auth token. In either case we should allow the user to deregister
        [self forceDeregistrationWithCompletionBlock:^{
            if (successBlock) {
                successBlock();
            }
        }];
    }
}
    
- (NSString *)pToken
{
    return self.accountValidation.pToken;    
}

- (BOOL)pTokenWithValidation:(ValidateBlock)aValidateBlock
{
    BOOL ret = NO;
    NSString *currentPToken = self.accountValidation.pToken;
    
    if (currentPToken == nil) {
        NSString *storedUsername = [[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerUsername];
        NSString *storedPassword = [SFHFKeychainUtils getPasswordForUsername:storedUsername andServiceName:kSCHAuthenticationManagerServiceName error:nil];
        
        ret = [self.accountValidation validateWithUserName:storedUsername 
                                              withPassword:storedPassword 
                                             validateBlock:aValidateBlock];
    } else {
        if (aValidateBlock != nil) {
            aValidateBlock(currentPToken, nil);  
        }
    }
    
    return ret;
}

- (NSURL *)webParentToolURL:(NSString *)pToken
{   
    NSURL *ret = nil;
    
    if ([[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerUserKey] == nil) {
        ret = nil;
    } else {
        NSMutableArray *appln = [NSMutableArray array];
        
        [appln addObject:@"eReader"];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            [appln addObject:@"iPad"];                   
        } else if([[[UIDevice currentDevice] model] hasPrefix:@"iPod"] == YES) {
            [appln addObject:@"iPod"];
        } else {
            [appln addObject:@"iPhone"];        
        }
        
        [appln addObject:@"ns"];   
        
        NSString *token = (pToken == nil) ? self.accountValidation.pToken : pToken;
        NSString *escapedToken = [token urlEncodeUsingEncoding:NSUTF8StringEncoding];
        
        NSString *userKey = [[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerUserKey];
        NSString *escapedKey = [userKey urlEncodeUsingEncoding:NSUTF8StringEncoding];
        
        NSString *application = [appln componentsJoinedByString:@"|"];
        NSString *escapedApplication = [application urlEncodeUsingEncoding:NSUTF8StringEncoding];
        
        NSString *webParentToolsServer = nil;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            webParentToolsServer = WEB_PARENT_TOOLS_SERVER_PAD;
        } else {
            webParentToolsServer = WEB_PARENT_TOOLS_SERVER_PHONE;
        }
        
        NSString *escapedURL = [NSString stringWithFormat:@"%@?tk=%@&appln=%@&spsId=%@",
                                webParentToolsServer,
                                escapedToken, 
                                escapedApplication, 
                                escapedKey];
        
        ret = [NSURL URLWithString:escapedURL];
    }
    
    return ret;
}

#pragma mark - Accessor methods

- (NSString *)aToken
{
    // we block until the selector completes to make sure we always have the 
    // return object before use
    [self performSelectorOnMainThread:@selector(aTokenOnMainThread) 
                           withObject:nil 
                        waitUntilDone:YES];
    
	return aToken;
}

- (BOOL)isAuthenticated
{
    BOOL ret = NO;
    NSValue *resultValue = [NSValue valueWithPointer:&ret];
    
    // we block until the selector completes to make sure we always have the return object before use
    [self performSelectorOnMainThread:@selector(isAuthenticatedOnMainThread:) 
                           withObject:resultValue 
                        waitUntilDone:YES];
    
    return ret;
}

#pragma mark - Notification methods

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    [self.renewTimer invalidate];
    self.renewTimer = nil;
    
    // if the user kills the app while we are performing background tasks the 
    // DidEnterBackground notification is called again, so we disable it and 
    // enable it in the foreground
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIApplicationDidEnterBackgroundNotification 
                                                  object:nil];    
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(applicationWillEnterForeground) 
                                                 name:UIApplicationWillEnterForegroundNotification 
                                               object:nil];			            
}

- (void)applicationWillEnterForeground
{
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(applicationDidEnterBackground:) 
                                                 name:UIApplicationDidEnterBackgroundNotification 
                                               object:nil];	
    
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIApplicationWillEnterForegroundNotification 
                                                  object:nil];    
}

- (void)applicationSignificantTimeChange:(NSNotification *)notification
{
    // when the device time changes we expire the token to force a renew of the
    // server date delta
    [self expireToken];
}

#pragma mark - Private methods

- (void)aTokenOnMainThread
{
    NSAssert([NSThread isMainThread] == YES, @"SCHAuthenticationManager::aTokenOnMainThread MUST be executed on the main thread");
    
    if(tokenExpires != nil && 
       [tokenExpires compare:[NSDate date]] == NSOrderedAscending) {
        [self expireToken];
    }
}

- (void)expireToken
{
    
    if (![NSThread isMainThread]) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self expireToken];
        });
        return;
    }
    
    self.tokenExpires = nil;
    self.aToken = nil;
}

- (void)expireDeviceKey
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSCHAuthenticationManagerDeviceKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)isAuthenticatedOnMainThread:(NSValue *)returnValue
{
    NSAssert([NSThread isMainThread] == YES, @"SCHAuthenticationManager::isAuthenticatedOnMainThread MUST be executed on the main thread");

    *(BOOL *)returnValue.pointerValue = YES;
    
    if([[SCHAppStateManager sharedAppStateManager] canAuthenticate] == YES) {
        SCHVersionDownloadManagerAppVersionState appVersionState = [[SCHVersionDownloadManager sharedVersionManager] appVersionState];
        
        *(BOOL *)returnValue.pointerValue = ((appVersionState != SCHVersionDownloadManagerAppVersionStatePendingCheck) &&
                                             (appVersionState != SCHVersionDownloadManagerAppVersionStateOutdatedRequiresForcedUpdate) &&                                             
                                             (self.aToken != nil) && 
                                             ([[self.aToken stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0));
        
    }
}



- (void)authenticateWithSuccessBlock:(SCHAuthenticationSuccessBlock)successBlock
                        failureBlock:(SCHAuthenticationFailureBlock)failureBlock;
{
    [self authenticateWithSuccessBlock:successBlock failureBlock:failureBlock waitUntilVersionCheckIsDone:NO];
}

- (void)authenticateWithSuccessBlock:(SCHAuthenticationSuccessBlock)successBlock
                        failureBlock:(SCHAuthenticationFailureBlock)failureBlock
         waitUntilVersionCheckIsDone:(BOOL)wait
{    
    
    SCHVersionDownloadManagerAppVersionState appVersionState = [[SCHVersionDownloadManager sharedVersionManager] appVersionState];
    
    if (wait && (appVersionState == SCHVersionDownloadManagerAppVersionStatePendingCheck)) {
        __block SCHAuthenticationManager *weakSelf = self;

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            [[[SCHVersionDownloadManager sharedVersionManager] versionDownloadQueue] waitUntilAllOperationsAreFinished];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf authenticateWithSuccessBlock:successBlock failureBlock:failureBlock waitUntilVersionCheckIsDone:NO];
            });
        });
        return;
    }
    
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self authenticateWithSuccessBlock:successBlock
                                  failureBlock:failureBlock];
        });
        return;
    }
    
    self.authenticationSuccessBlock = successBlock;
    self.authenticationFailureBlock = failureBlock;
    
    if (self.isAuthenticating) {
        return;
    }
    
    self.authenticating = YES;
        
    NSString *storedUsername = [[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerUsername];
    NSString *storedPassword = [SFHFKeychainUtils getPasswordForUsername:storedUsername andServiceName:kSCHAuthenticationManagerServiceName error:nil];
    NSString *deviceKey = [[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerDeviceKey];	
    
    NSLog(@"Authenticating %@ with %@", storedUsername, (deviceKey == nil ? @"no deviceKey" : deviceKey));        
    
    if([[SCHAppStateManager sharedAppStateManager] canAuthenticate]) {
        
        SCHVersionDownloadManagerAppVersionState appVersionState = [[SCHVersionDownloadManager sharedVersionManager] appVersionState];
        
        if (appVersionState == SCHVersionDownloadManagerAppVersionStatePendingCheck) {
            [self authenticationDidSucceedWithOfflineMode:SCHAuthenticationManagerConnectivityModeOfflineAwaitingAppVersion];
        } else if (appVersionState == SCHVersionDownloadManagerAppVersionStateOutdatedRequiresForcedUpdate) {
            [self authenticationDidSucceedWithOfflineMode:SCHAuthenticationManagerConnectivityModeOfflineOutdatedAppVersionRequiringUpdate];
        } else if ([[Reachability reachabilityForInternetConnection] isReachable]) {
            
            if (self.aToken != nil && [[self.aToken stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
                [self.libreAccessWebService renewToken:self.aToken];
            } else if (deviceKey != nil && [[deviceKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
                [self.libreAccessWebService authenticateDevice:deviceKey forUserKey:[[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerUserKey]];
            } else if ([[storedUsername stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0 &&
                       [[storedPassword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
                
                __block SCHAuthenticationManager *weakSelf = self;
                
                [self.accountValidation validateWithUserName:storedUsername withPassword:storedPassword validateBlock:^(NSString *pToken, NSError *error) {
                    if (error != nil) {
                        [weakSelf authenticationDidFailWithError:error];                            
                    } else {
                        [weakSelf.libreAccessWebService tokenExchange:pToken 
                                                              forUser:[[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerUsername]];                            
                        [[SCHCOPPAManager sharedCOPPAManager] checkCOPPAIfRequired];
                    }
                }];
                
            } else {
                
                NSError *error = [NSError errorWithDomain:kSCHAuthenticationManagerErrorDomain 
                                                     code:kSCHAuthenticationManagerLoginError 
                                                 userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"You must enter a username and password", @"") 
                                                                                      forKey:NSLocalizedDescriptionKey]];
                
                [self authenticationDidFailWithError:error];            
            }
        } else {
            
            if ([[storedUsername stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {     
                
                [self authenticationDidSucceedWithOfflineMode:SCHAuthenticationManagerConnectivityModeOfflineNoConnectivity];
            } else {
                NSError *error = [NSError errorWithDomain:kSCHAuthenticationManagerErrorDomain 
                                                     code:kSCHAuthenticationManagerLoginError 
                                                 userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"You must enter a username and password", @"") 
                                                                                      forKey:NSLocalizedDescriptionKey]];
                
                [self authenticationDidFailWithError:error]; 
            }
        }
    } else {
        self.aToken = @"";
        self.tokenExpires = [NSDate distantFuture];        
        
        // TODO: Why does this need to be delayed?
        double delayInSeconds = 0.1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self authenticationDidSucceedWithOfflineMode:SCHAuthenticationManagerConnectivityModeOnline];
        });
    }
}

- (void)hasUsernameAndPasswordOnMainThread:(NSValue *)returnValue
{
    NSAssert([NSThread isMainThread] == YES, @"SCHAuthenticationManager::hasUsernameAndPasswordOnMainThread MUST be executed on the main thread");
    
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerUsername];
    NSString *password = nil;
    
    if (username != nil && 
        [[username stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
        password = [SFHFKeychainUtils getPasswordForUsername:username andServiceName:kSCHAuthenticationManagerServiceName error:nil];
        if (password != nil && 
            [[password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
            *(BOOL *)returnValue.pointerValue = YES;
        }
    }
}

// make sure you have de-registered prior to calling this 
- (void)clearOnMainThread
{
    NSAssert([NSThread isMainThread] == YES, @"SCHAuthenticationManager::clearOnMainThread MUST be executed on the main thread");
    
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerUsername];	
    
    [self expireToken];       

    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSCHAuthenticationManagerDeviceKey];

    if (username != nil && 
        [[username stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
        [SFHFKeychainUtils deleteItemForUsername:username andServiceName:kSCHAuthenticationManagerServiceName error:nil];
    }
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSCHAuthenticationManagerUsername];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSCHAuthenticationManagerUserKey];    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[SCHCOPPAManager sharedCOPPAManager] resetCOPPA];
}

- (void)clearAppProcessingOnMainThreadWaitUntilFinished:(BOOL)wait
{
    NSAssert([NSThread isMainThread] == YES, @"SCHAuthenticationManager::clearAppProcessingOnMainThread MUST be executed on the main thread");
    NSAssert(wait == NO, @"wait until finished is not supported in the current architecture. See SCHProcessingManager and SCHRecommendationManager");
    
    [[SCHBookManager sharedBookManager] clearBookIdentifierCache];
    [[SCHURLManager sharedURLManager] clear];
    [[SCHProcessingManager sharedProcessingManager] cancelAllOperationsWaitUntilFinished:NO]; 
    [[SCHRecommendationManager sharedManager] cancelAllOperationsWaitUntilFinished:NO];
    [[SCHSyncManager sharedSyncManager] resetSync];    
}

#pragma mark - Private methods

- (void)performPostDeregistrationWaitUntilFinished:(BOOL)wait
{	        
    [self clearOnMainThread];
    [self clearAppProcessingOnMainThreadWaitUntilFinished:wait];
    [(AppDelegate_Shared *)[[UIApplication sharedApplication] delegate] clearUserDefaults];
    
    self.authenticationSuccessBlock = nil;
    self.authenticationFailureBlock = nil;
    self.deregistrationSuccessBlock = nil;
    self.deregistrationFailureBlock = nil;
    self.drmRegistrationSession = nil;    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SCHAuthenticationManagerDidDeregisterNotification
                                                        object:self 
                                                      userInfo:nil];
}

- (void)setLastKnownAuthToken:(NSString *)token
{
    if (token) {
        [[SCHAppStateManager sharedAppStateManager] setLastKnownAuthToken:token];
    }
}

#pragma mark - BITAPIProxy Delegate methods

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result
      userInfo:(NSDictionary *)userInfo
{	
    id userKeyValue = [result objectForKey:kSCHLibreAccessWebServiceUserKey];
    id deviceIsDeregisteredValue = [result objectForKey:kSCHLibreAccessWebServiceDeviceIsDeregistered]; 
    id returnedTokenValue = [result objectForKey:kSCHLibreAccessWebServiceAuthToken];
    id expiresInValue = [result objectForKey:kSCHLibreAccessWebServiceExpiresIn];
    
    NSString *userKey         = userKeyValue == [NSNull null] ? nil : userKeyValue;
    BOOL deviceIsDeregistered = deviceIsDeregisteredValue == [NSNull null] ? NO : [deviceIsDeregisteredValue boolValue];
    NSString *returnedToken   = returnedTokenValue == [NSNull null] ? nil : returnedTokenValue;
    NSInteger expiresIn       = expiresInValue == [NSNull null] ? 30 : [expiresInValue integerValue];
    
	if([method compare:kSCHLibreAccessWebServiceTokenExchange] == NSOrderedSame) {
        
        if (userKey) {
            [[NSUserDefaults standardUserDefaults] setObject:userKey forKey:kSCHAuthenticationManagerUserKey];
        } else {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSCHAuthenticationManagerUserKey];   
        }
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSString *deviceKey = [[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerDeviceKey];
        
        if (deviceIsDeregistered) {
            self.aToken = returnedToken;

            [self forceDeregistrationWithCompletionBlock:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:SCHAuthenticationManagerReceivedServerDeregistrationNotification
                                                                    object:self 
                                                                  userInfo:nil];
            }];
             
        } else if (deviceKey) {
            
            [self authenticationDidSucceedWithOfflineMode:SCHAuthenticationManagerConnectivityModeOnline];
        } else {
            
            self.registrationSuccessBlock = ^(NSString *deviceKey){
                [[NSUserDefaults standardUserDefaults] setObject:deviceKey forKey:kSCHAuthenticationManagerDeviceKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [libreAccessWebService authenticateDevice:deviceKey forUserKey:[[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerUserKey]];
            };
            
            self.registrationFailureBlock = ^(NSError *error){
                [self authenticationDidFailWithError:error];
            };
            
            [self.drmRegistrationSession registerDevice:returnedToken];
        }  
        
	} else if (([method compare:kSCHLibreAccessWebServiceAuthenticateDevice] == NSOrderedSame) ||
               ([method compare:kSCHLibreAccessWebServiceRenewToken] == NSOrderedSame)) {
                  
        [self expireToken];
        
        if (userInfo != nil) {
            NSNumber *serverDateDelta = [userInfo objectForKey:@"serverDateDelta"];
            if (serverDateDelta != nil) {
                [[SCHAppStateManager sharedAppStateManager] setServerDateDelta:[serverDateDelta doubleValue]];
            }
        }

        if ([method isEqualToString:kSCHLibreAccessWebServiceAuthenticateDevice] && deviceIsDeregistered) {
            
            self.aToken = returnedToken;
            
            [self forceDeregistrationWithCompletionBlock:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:SCHAuthenticationManagerReceivedServerDeregistrationNotification
                                                                    object:self 
                                                                  userInfo:nil];
            }];
             
        } else {
            if (returnedToken) {
                self.aToken = returnedToken;
                [self setLastKnownAuthToken:returnedToken];
                
                expiresIn = MAX(0, expiresIn);
                self.tokenExpires = [NSDate dateWithTimeIntervalSinceNow:(expiresIn * kSCHAuthenticationManagerSecondsInAMinute) - 30];
                if (expiresIn > 0) {
                    self.renewTimer = [NSTimer scheduledTimerWithTimeInterval:(expiresIn * kSCHAuthenticationManagerSecondsInAMinute) - 45
                                                                       target:self 
                                                                     selector:@selector(aTokenTimedOut:) 
                                                                     userInfo:nil 
                                                                      repeats:NO];
                }
                [self authenticationDidSucceedWithOfflineMode:SCHAuthenticationManagerConnectivityModeOnline];
            } else {
                [self authenticationDidSucceedWithOfflineMode:SCHAuthenticationManagerConnectivityModeAuthenticationError];
            }
        }
        
    }
}

- (void)aTokenTimedOut:(NSTimer *)timer
{
    [self authenticateWithSuccessBlock:nil failureBlock:nil];
    self.renewTimer = nil;
}

- (void)method:(NSString *)method didFailWithError:(NSError *)error 
   requestInfo:(NSDictionary *)requestInfo
        result:(NSDictionary *)result
{
    NSLog(@"AuthenticationManager:%@ %@", method, [error description]);
    
    id deviceIsDeregisteredValue = [result objectForKey:kSCHLibreAccessWebServiceDeviceIsDeregistered]; 
    id returnedTokenValue = [result objectForKey:kSCHLibreAccessWebServiceAuthToken];
    
    BOOL deviceIsDeregistered = deviceIsDeregisteredValue == [NSNull null] ? NO : [deviceIsDeregisteredValue boolValue];
    NSString *returnedToken   = returnedTokenValue == [NSNull null] ? nil : returnedTokenValue;

    if ([error domain] != kBITAPIErrorDomain) {
        if([method compare:kSCHLibreAccessWebServiceTokenExchange] == NSOrderedSame) {	
            if (deviceIsDeregistered) {
                
                self.aToken = returnedToken;
                
                [self forceDeregistrationWithCompletionBlock:^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:SCHAuthenticationManagerReceivedServerDeregistrationNotification
                                                                        object:self 
                                                                      userInfo:nil];
                }];
            } else {
                [self authenticationDidFailWithError:error];
            }
        } else if ([method compare:kSCHLibreAccessWebServiceAuthenticateDevice] == NSOrderedSame) {
                
            [self expireToken];     
            
            if (deviceIsDeregistered) {
                
                self.aToken = returnedToken;
                
                [self forceDeregistrationWithCompletionBlock:^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:SCHAuthenticationManagerReceivedServerDeregistrationNotification
                                                                        object:self 
                                                                      userInfo:nil];
                }];
            } else {
                // This must have been a server error so go into offline mode
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSCHAuthenticationManagerDeviceKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [self authenticationDidSucceedWithOfflineMode:SCHAuthenticationManagerConnectivityModeAuthenticationError];
            }
        } else if ([method compare:kSCHLibreAccessWebServiceRenewToken] == NSOrderedSame) {	
            [self expireToken];
            
            [self authenticationDidSucceedWithOfflineMode:SCHAuthenticationManagerConnectivityModeAuthenticationError];
        }
    } else {
        [self authenticationDidFailWithError:error];
    }
}

#pragma mark - Authentication Outcomes

- (void)authenticationDidSucceedWithOfflineMode:(SCHAuthenticationManagerConnectivityMode)connectivityMode
{
    self.authenticating = NO;
    
    if (self.authenticationSuccessBlock) {
        SCHAuthenticationSuccessBlock handler = Block_copy(self.authenticationSuccessBlock);
        self.authenticationSuccessBlock = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(connectivityMode);
        });
        Block_release(handler);
    }
    
    if ([[SCHSyncManager sharedSyncManager] isSuspended] && (connectivityMode == SCHAuthenticationManagerConnectivityModeOnline))  {
        NSLog(@"Warning Sync Manager suspended when authentication succeeded with online mode");
        [[SCHSyncManager sharedSyncManager] setSuspended:NO];
    }
    
    self.authenticationFailureBlock = nil;
}

- (void)authenticationDidFailWithError:(NSError *)error
{
    self.authenticating = NO;
    
    if (self.authenticationFailureBlock) {
        SCHAuthenticationFailureBlock handler = Block_copy(self.authenticationFailureBlock);
        self.authenticationFailureBlock = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(error);
        });
        Block_release(handler);
    }
    
    self.authenticationSuccessBlock = nil;
}

#pragma mark - DRM Registration Session Delegate methods

- (void)registrationSession:(SCHDrmRegistrationSession *)registrationSession 
    registrationDidComplete:(NSString *)deviceKey
{
    if (self.registrationSuccessBlock) {
        SCHDrmRegistrationSuccessBlock handler = Block_copy(self.registrationSuccessBlock);
        self.registrationSuccessBlock = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(deviceKey);
        });
        Block_release(handler);
    }
    
    self.registrationFailureBlock = nil;
    self.drmRegistrationSession = nil;
}

- (void)registrationSession:(SCHDrmRegistrationSession *)registrationSession 
    registrationDidFailWithError:(NSError *)error
{
    if (self.registrationFailureBlock) {
        SCHDrmRegistrationFailureBlock handler = Block_copy(self.registrationFailureBlock);
        self.registrationFailureBlock = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(error);
        });
        Block_release(handler);
    }
    
    self.registrationSuccessBlock = nil;
    self.drmRegistrationSession = nil;    
}

- (void)registrationSession:(SCHDrmRegistrationSession *)registrationSession 
    deregistrationDidComplete:(NSString *)deviceKey
{    
    SCHDrmDeregistrationSuccessBlock postClearingBlock = nil;
    
    if (self.deregistrationSuccessBlock) {
        postClearingBlock = Block_copy(self.deregistrationSuccessBlock);
        self.deregistrationSuccessBlock = nil;
    }
    
    [self performPostDeregistrationWaitUntilFinished:NO];

    if (postClearingBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            postClearingBlock();
        });
        Block_release(postClearingBlock);
    }
    
    self.deregistrationFailureBlock = nil;
    self.drmRegistrationSession = nil;
    self.authenticating = NO;
}

- (void)registrationSession:(SCHDrmRegistrationSession *)registrationSession 
deregistrationDidFailWithError:(NSError *)error
{
    if (self.deregistrationFailureBlock) {
        SCHDrmDeregistrationFailureBlock handler = Block_copy(self.deregistrationFailureBlock);
        self.deregistrationFailureBlock = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(error);
        });
        Block_release(handler);
    }
    
    self.deregistrationSuccessBlock = nil;
    self.drmRegistrationSession = nil;   
    self.authenticating = NO;
}

- (void)setAuthenticationSuccessBlock:(SCHAuthenticationSuccessBlock)newBlock
{
    if (newBlock) {
        if (authenticationSuccessBlock) {
            if (authenticationSuccessBlock != newBlock) {
                
                SCHAuthenticationSuccessBlock existingBlock = Block_copy(authenticationSuccessBlock);
                
                Block_release(authenticationSuccessBlock);
                
                SCHAuthenticationSuccessBlock combinedBlock = ^(SCHAuthenticationManagerConnectivityMode connectivityMode){
                    existingBlock(connectivityMode);
                    newBlock(connectivityMode);
                };
                
                authenticationSuccessBlock = Block_copy(combinedBlock);
                Block_release(existingBlock);
            }
        } else {
            authenticationSuccessBlock = Block_copy(newBlock);
        }
    } else {
        
        if (authenticationSuccessBlock) {
            Block_release(authenticationSuccessBlock);
        }
        
        authenticationSuccessBlock = nil;
    }
}

- (void)setAuthenticationFailureBlock:(SCHAuthenticationFailureBlock)newBlock
{
    if (newBlock) {
        if (authenticationFailureBlock) {
            if (authenticationFailureBlock != newBlock) {
                SCHAuthenticationFailureBlock existingBlock = Block_copy(authenticationFailureBlock);
                
                Block_release(authenticationFailureBlock);
                
                SCHAuthenticationFailureBlock combinedBlock = ^(NSError *error){
                    existingBlock(error);
                    newBlock(error);
                };
                
                authenticationFailureBlock = Block_copy(combinedBlock);
                Block_release(existingBlock);
            }
        } else {
            authenticationFailureBlock = Block_copy(newBlock);
        }
    } else {
        
        if (authenticationFailureBlock) {
            Block_release(authenticationFailureBlock);
        }
        
        authenticationFailureBlock = nil;
    }
}

- (NSString *)localizedMessageForAuthenticationError:(NSError *)error
{
    NSString *localizedMessage = nil;
    
    if ([error code] == kSCHDrmDeviceLimitError) {
        localizedMessage = NSLocalizedString(@"Storia is already installed on five devices, which is the maximum allowed. Before installing it on this device, you need to deregister Storia on one of your current devices.", nil);
    } else if (([error code] == kSCHDrmDeviceRegisteredToAnotherDevice) || 
               ([error code] == kSCHDrmDeviceUnableToAssign)) {
        localizedMessage = NSLocalizedString(@"This device is registered to another Scholastic account. The owner of that account needs to deregister this device before it can be registered to a new account.", nil);
    } else {
        localizedMessage = [NSString stringWithFormat:
                            NSLocalizedString(@"A problem occured. If this problem persists please contact support.\n\n '%@'", nil), 
                            [error localizedDescription]];   
    }
    
    return localizedMessage;

}

@end
