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
#import "SCHAccountValidation.h"
#import "SCHBookManager.h"
#import "BITAPIError.h"
#import "SCHUserDefaults.h"

#import "SCHNonDRMAuthenticationManager.h"

// Constants
NSString * const SCHAuthenticationManagerDidSucceedNotification = @"SCHAuthenticationManagerDidSucceedNotification";
NSString * const SCHAuthenticationManagerDidFailNotification = @"SCHAuthenticationManagerDidFailNotification";
NSString * const kSCHAuthenticationManagerAToken = @"aToken";
NSString * const kSCHAuthenticationManagerOfflineMode = @"OfflineMode";
NSString * const SCHAuthenticationManagerDidDeregisterNotification = @"SCHAuthenticationManagerDidDeregisterNotification";
NSString * const SCHAuthenticationManagerDidClearAfterDeregisterNotification = @"SCHAuthenticationManagerDidClearAfterDeregisterNotification";
NSString * const SCHAuthenticationManagerDidFailDeregistrationNotification = @"SCHAuthenticationManagerDidFailDeregistrationNotification";
NSString * const kSCHAuthenticationManagerNSError = @"NSError";

NSString * const kSCHAuthenticationManagerErrorDomain = @"AuthenticationManagerErrorDomain";
NSInteger const kSCHAuthenticationManagerGeneralError = 2000;
NSInteger const kSCHAuthenticationManagerLoginError = 2001;

NSString * const kSCHAuthenticationManagerServiceName = @"Scholastic";

NSTimeInterval const kSCHAuthenticationManagerSecondsInAMinute = 60.0;

struct AuthenticateWithUserNameParameters 
{
    NSString *username;
    NSString *password;
};
typedef struct AuthenticateWithUserNameParameters AuthenticateWithUserNameParameters;

@interface SCHAuthenticationManager ()

- (void)aTokenOnMainThread;
- (void)isAuthenticatedOnMainThread:(NSValue *)returnValue;
- (void)authenticateWithUserNameOnMainThread:(NSValue *)parameters;
- (void)hasUsernameAndPasswordOnMainThread:(NSValue *)returnValue;
- (void)deregisterOnMainThread:(NSString *)token;
- (void)performPostDeregistration;
- (void)performForcedDeregistrationWithToken:(id)token;
- (void)setLastKnownAuthToken:(NSString *)token;

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
@synthesize waitingOnResponse;
@synthesize accountValidation;
@synthesize libreAccessWebService;
@synthesize drmRegistrationSession;

#pragma mark - Singleton instance methods

+ (SCHAuthenticationManager *)sharedAuthenticationManager
{
    static dispatch_once_t pred;
    static SCHAuthenticationManager *sharedAuthenticationManager = nil;
    
    dispatch_once(&pred, ^{
        NSAssert([NSThread isMainThread] == YES, @"SCHAuthenticationManager:sharedAuthenticationManager MUST be executed on the main thread");
#if NONDRMAUTHENTICATION
        sharedAuthenticationManager = [[SCHNonDRMAuthenticationManager allocWithZone:NULL] init];
#else
        sharedAuthenticationManager = [[super allocWithZone:NULL] init];
#endif
    });
    
    return(sharedAuthenticationManager);
}

#pragma mark - Object lifecycle 

- (id)init
{
	self = [super init];
	if (self != nil) {
		aToken = nil;
		tokenExpires = nil;
		waitingOnResponse = NO;
		
		accountValidation = [[SCHAccountValidation alloc] init];
		
		libreAccessWebService = [[SCHLibreAccessWebService alloc] init];	
		libreAccessWebService.delegate = self;
	}
	return(self);
}

- (void)dealloc 
{
    [aToken release], aToken = nil;
    [tokenExpires release], tokenExpires = nil;
    [accountValidation release], accountValidation = nil;
    [libreAccessWebService release], libreAccessWebService = nil;
    [drmRegistrationSession release], drmRegistrationSession = nil;
    
    [super dealloc];
}

#pragma mark - Accessor methods

- (SCHDrmRegistrationSession *)drmRegistrationSession
{
    if(drmRegistrationSession == nil) {
        drmRegistrationSession = [[SCHDrmRegistrationSession alloc] init];
        drmRegistrationSession.delegate = self;   
    }
    
    return(drmRegistrationSession);
}

#pragma mark - methods

- (void)authenticateWithUserName:(NSString *)username withPassword:(NSString *)password
{
    AuthenticateWithUserNameParameters authenticateWithUserNameParameters;
    
    authenticateWithUserNameParameters.username = username;
    authenticateWithUserNameParameters.password = password;
    
    // we block until the selector completes to make sure the parameters don't get freed up
    [self performSelectorOnMainThread:@selector(authenticateWithUserNameOnMainThread:) 
                           withObject:[NSValue valueWithPointer:&authenticateWithUserNameParameters]
                        waitUntilDone:YES];
}

- (BOOL)validatePassword:(NSString *)password
{
    BOOL ret = YES;
    
    NSString *storedUsername = [[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerUsername];
    NSString *storedPassword = [SFHFKeychainUtils getPasswordForUsername:storedUsername andServiceName:kSCHAuthenticationManagerServiceName error:nil];
        
    ret = ([password isEqualToString:storedPassword] == YES);
    
    return(ret);
}

- (void)authenticate
{
    [self performSelectorOnMainThread:@selector(authenticateOnMainThread) 
                           withObject:nil 
                        waitUntilDone:NO];
}

- (BOOL)hasUsernameAndPassword
{
    BOOL ret = NO;
    NSValue *resultValue = [NSValue valueWithPointer:&ret];

    // we block until the selector completes to make sure we always have the return object before use
    [self performSelectorOnMainThread:@selector(hasUsernameAndPasswordOnMainThread:) 
                           withObject:resultValue 
                        waitUntilDone:YES];

    return(ret);
}

- (void)clear
{
    [self performSelectorOnMainThread: @selector(clearOnMainThread) 
                           withObject:nil 
                        waitUntilDone:YES];
}

- (void)clearAppProcessing
{
    [self performSelectorOnMainThread: @selector(clearAppProcessingOnMainThread) 
                           withObject:nil 
                        waitUntilDone:YES];
}

- (void)deregister
{
    [self performSelectorOnMainThread: @selector(deregisterOnMainThread:) 
                           withObject:self.aToken 
                        waitUntilDone:YES];
}
    
- (NSString *)pToken
{
    return(self.accountValidation.pToken);    
}

- (NSURL *)webParentToolURL:(NSString *)pToken
{    
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
    
    return([NSURL URLWithString:[[NSString stringWithFormat:@"https://ebooks2uat.scholastic.com/wpt/auth?tk=%@&appln=%@&spsId=%@", 
                                  (pToken == nil ? self.accountValidation.pToken : pToken), 
                                  [appln componentsJoinedByString:@"|"], 
                                  [[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerUserKey]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]);
}

#pragma mark - Accessor methods

- (NSString *)aToken
{
    // we block until the selector completes to make sure we always have the 
    // return object before use
    [self performSelectorOnMainThread:@selector(aTokenOnMainThread) 
                           withObject:nil 
                        waitUntilDone:YES];
    
	return(aToken);
}

- (BOOL)isAuthenticated
{
    BOOL ret = NO;
    NSValue *resultValue = [NSValue valueWithPointer:&ret];
    
    // we block until the selector completes to make sure we always have the return object before use
    [self performSelectorOnMainThread:@selector(isAuthenticatedOnMainThread:) 
                           withObject:resultValue 
                        waitUntilDone:YES];
    
    return(ret);
}

#pragma mark - Private methods

- (void)aTokenOnMainThread
{
    NSAssert([NSThread isMainThread] == YES, @"SCHAuthenticationManager::aTokenOnMainThread MUST be executed on the main thread");
    
    if([tokenExpires compare:[NSDate date]] == NSOrderedAscending) {
        [aToken release], aToken = nil;
        self.tokenExpires = nil;        
    }
}

- (void)isAuthenticatedOnMainThread:(NSValue *)returnValue
{
    NSAssert([NSThread isMainThread] == YES, @"SCHAuthenticationManager::isAuthenticatedOnMainThread MUST be executed on the main thread");

    *(BOOL *)returnValue.pointerValue = YES;
    
    if([[SCHAppStateManager sharedAppStateManager] canAuthenticate] == YES) {
        *(BOOL *)returnValue.pointerValue = (self.aToken != nil && 
               [[self.aToken stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0);
        
    }
}

- (void)authenticateWithUserNameOnMainThread:(NSValue *)parameters
{	
    NSAssert([NSThread isMainThread] == YES, @"SCHAuthenticationManager::authenticateWithUserNameOnMainThread MUST be executed on the main thread");
    
    AuthenticateWithUserNameParameters *authenticateWithUserNameParameters = parameters.pointerValue;
    
    if([[SCHAppStateManager sharedAppStateManager] canAuthenticate] == YES) {
        if ([[Reachability reachabilityForInternetConnection] isReachable] == YES) {
            if (authenticateWithUserNameParameters->username != nil &&
                [[authenticateWithUserNameParameters->username stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0 &&
                authenticateWithUserNameParameters->password != nil &&
                [[authenticateWithUserNameParameters->password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
                [self clearOnMainThread];
                [[NSUserDefaults standardUserDefaults] setObject:authenticateWithUserNameParameters->username 
                                                          forKey:kSCHAuthenticationManagerUsername];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [SFHFKeychainUtils storeUsername:authenticateWithUserNameParameters->username 
                                     andPassword:authenticateWithUserNameParameters->password 
                                  forServiceName:kSCHAuthenticationManagerServiceName 
                                  updateExisting:YES 
                                           error:nil];
                [self authenticateOnMainThread];
            } else {
                NSError *error = [NSError errorWithDomain:kSCHAuthenticationManagerErrorDomain 
                                                     code:kSCHAuthenticationManagerLoginError 
                                                 userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"You must enter a username and password", @"") 
                                                                                      forKey:NSLocalizedDescriptionKey]];
                
                [self postFailureWithError:error];
            }
        } else {
            NSError *error = [NSError errorWithDomain:kSCHAuthenticationManagerErrorDomain 
                                                 code:kSCHAuthenticationManagerLoginError 
                                             userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"You must have internet access to login", @"") 
                                                                                  forKey:NSLocalizedDescriptionKey]];
            
            [self postFailureWithError:error];	
        }
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:authenticateWithUserNameParameters->username 
                                                  forKey:kSCHAuthenticationManagerUsername];

        [SFHFKeychainUtils storeUsername:authenticateWithUserNameParameters->username 
                             andPassword:authenticateWithUserNameParameters->password 
                          forServiceName:kSCHAuthenticationManagerServiceName 
                          updateExisting:YES 
                                   error:nil];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSCHAuthenticationManagerDeviceKey];                        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSCHAuthenticationManagerUserKey];   
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        self.aToken = @"";
        self.tokenExpires = [NSDate distantFuture];        
        
        [self performSelector:@selector(postSuccessWithOfflineMode:) withObject:[NSNumber numberWithBool:NO] afterDelay:0.1];
    }
}

- (void)authenticateOnMainThread
{    
    NSAssert([NSThread isMainThread] == YES, @"SCHAuthenticationManager::authenticateOnMainThread MUST be executed on the main thread");
    
    NSString *storedUsername = [[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerUsername];
    NSString *storedPassword = [SFHFKeychainUtils getPasswordForUsername:storedUsername andServiceName:kSCHAuthenticationManagerServiceName error:nil];
    NSString *deviceKey = [[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerDeviceKey];	
    
    NSLog(@"Authenticating %@ with %@", storedUsername, (deviceKey == nil ? @"no deviceKey" : deviceKey));        
    
    if([[SCHAppStateManager sharedAppStateManager] canAuthenticate] == YES) {
        if (self.waitingOnResponse == NO) {
            if ([[Reachability reachabilityForInternetConnection] isReachable] == YES) {
                if (self.aToken != nil && [[self.aToken stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
                    [self.libreAccessWebService renewToken:self.aToken];
                    self.waitingOnResponse = YES;                
                } else if (deviceKey != nil && [[deviceKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
                    [self.libreAccessWebService authenticateDevice:deviceKey forUserKey:nil];
                    self.waitingOnResponse = YES;                                
                } else if (storedUsername != nil &&
                           [[storedUsername stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0 &&
                           storedPassword != nil &&
                           [[storedPassword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
                    __block SCHAuthenticationManager *weakSelf = self;
                    [self.accountValidation validateWithUserName:storedUsername withPassword:storedPassword validateBlock:^(NSString *pToken, NSError *error) {
                        if (error != nil) {
                            weakSelf.waitingOnResponse = NO;
                            [weakSelf postFailureWithError:error];                            
                        } else {
                            [weakSelf.libreAccessWebService tokenExchange:pToken 
                                                              forUser:[[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerUsername]];                            
                        }
                    }];
                    self.waitingOnResponse = YES;         
                } else {
                    NSError *error = [NSError errorWithDomain:kSCHAuthenticationManagerErrorDomain 
                                                         code:kSCHAuthenticationManagerLoginError 
                                                     userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"You must enter a username and password", @"") 
                                                                                          forKey:NSLocalizedDescriptionKey]];
                    
                    [self postFailureWithError:error];            
                }
            } else if (storedUsername != nil &&
                       [[storedUsername stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {            
                [self postSuccessWithOfflineMode:YES];
            } else {
                NSError *error = [NSError errorWithDomain:kSCHAuthenticationManagerErrorDomain 
                                                     code:kSCHAuthenticationManagerLoginError 
                                                 userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"You must enter a username and password", @"") 
                                                                                      forKey:NSLocalizedDescriptionKey]];
                
                [self postFailureWithError:error];
            }
        } 
    } else {
        self.aToken = @"";
        self.tokenExpires = [NSDate distantFuture];        
        
        [self performSelector:@selector(postSuccessWithOfflineMode:) withObject:[NSNumber numberWithBool:NO] afterDelay:0.1];
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
    
    self.aToken = nil;
    self.tokenExpires = nil;        

    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSCHAuthenticationManagerDeviceKey];

    if (username != nil && 
        [[username stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
        [SFHFKeychainUtils deleteItemForUsername:username andServiceName:kSCHAuthenticationManagerServiceName error:nil];
    }
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSCHAuthenticationManagerUsername];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSCHAuthenticationManagerUserKey];    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)clearAppProcessingOnMainThread
{
    NSAssert([NSThread isMainThread] == YES, @"SCHAuthenticationManager::clearAppProcessingOnMainThread MUST be executed on the main thread");
    
    [[SCHBookManager sharedBookManager] clearBookIdentifierCache];
    [[SCHURLManager sharedURLManager] clear];
    [[SCHProcessingManager sharedProcessingManager] cancelAllOperations];                
    [[SCHSyncManager sharedSyncManager] clear];    
}

#pragma mark - Private methods

- (void)postSuccessWithOfflineMode:(BOOL)offlineMode
{
	NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
	
	[userInfo setObject:(aToken == nil ? (id)[NSNull null] : aToken) 
                 forKey:kSCHAuthenticationManagerAToken];
	[userInfo setObject:[NSNumber numberWithBool:offlineMode] 
                 forKey:kSCHAuthenticationManagerOfflineMode];
	
    NSLog(@"Authentication: %@", (offlineMode == YES ? @" offline" : @"successful!"));
    
	[[NSNotificationCenter defaultCenter] postNotificationName:SCHAuthenticationManagerDidSucceedNotification 
														object:self 
													  userInfo:userInfo];				
}

- (void)postFailureWithError:(NSError *)error
{
	[[NSNotificationCenter defaultCenter] postNotificationName:SCHAuthenticationManagerDidFailNotification
														object:self 
													  userInfo:[NSDictionary dictionaryWithObject:error
                                                                                           forKey:kSCHAuthenticationManagerNSError]];		
}

- (void)deregisterOnMainThread:(NSString *)token
{
    NSAssert([NSThread isMainThread] == YES, @"SCHAuthenticationManager::deregisterOnMainThread MUST be executed on the main thread");
    
    if ([[SCHAppStateManager sharedAppStateManager] canAuthenticate] == YES && token != nil) {
        [self.drmRegistrationSession deregisterDevice:token];
    }
}

- (void)performForcedDeregistrationWithToken:(id)token
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(performForcedDeregistrationWithToken:) withObject:token waitUntilDone:YES];
        return;
    }
    
    NSString *authToken = token == [NSNull null] ? nil : token;
    
    if (authToken) {
        [self.drmRegistrationSession deregisterDevice:authToken];
    } else {
        NSLog(@"Warning: an attempt was made to force deregisteration without a returned token. Using last known auth token");
        SCHAppState *appState = [SCHAppStateManager sharedAppStateManager].appState;
        NSString *lastToken = appState.LastKnownAuthToken;
        
        if (lastToken) {
            [self.drmRegistrationSession deregisterDevice:lastToken];
        } else {
            NSLog(@"Warning: no previous auth token was available.");
        }
    }
    
    [self performPostDeregistration];
}

- (void)performPostDeregistration
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SCHAuthenticationManagerDidDeregisterNotification
                                                        object:self 
                                                      userInfo:nil];		        
    [self clearOnMainThread];
    [self clearAppProcessingOnMainThread];
    [(AppDelegate_Shared *)[[UIApplication sharedApplication] delegate] clearUserDefaults];
    [[NSNotificationCenter defaultCenter] postNotificationName:SCHAuthenticationManagerDidClearAfterDeregisterNotification
                                                        object:self 
                                                      userInfo:nil];		                    
}

- (void)setLastKnownAuthToken:(NSString *)token
{
    if (token) {
        SCHAppState *appState = [SCHAppStateManager sharedAppStateManager].appState;
        appState.LastKnownAuthToken = token;
        
        NSError *error;
        if ([appState.managedObjectContext save:&error] == NO) {
            NSLog(@"Unable to save the LastKnownAuthToken (%@) in the app state %@, %@", token, error, [error userInfo]);
        }
    }
}

#pragma mark - BITAPIProxy Delegate methods

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result
{	
	if([method compare:kSCHLibreAccessWebServiceTokenExchange] == NSOrderedSame) {
        id userKey = [result objectForKey:kSCHLibreAccessWebServiceUserKey];
        id deviceIsDeregistered = [result objectForKey:kSCHLibreAccessWebServiceDeviceIsDeregistered]; 
        id returnedToken = [result objectForKey:kSCHLibreAccessWebServiceAuthToken];

        [[NSUserDefaults standardUserDefaults] setObject:(userKey == [NSNull null] ? nil : userKey) 
                                                  forKey:kSCHAuthenticationManagerUserKey];

        
        if ([deviceIsDeregistered isKindOfClass:[NSNumber class]] &&
            [deviceIsDeregistered boolValue] == YES) {
            [self performForcedDeregistrationWithToken:returnedToken];
            self.waitingOnResponse = NO;
        } else if (![[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerDeviceKey]) {
            [self.drmRegistrationSession registerDevice:returnedToken];
        }        
	} else if (([method compare:kSCHLibreAccessWebServiceAuthenticateDevice] == NSOrderedSame) ||
               ([method compare:kSCHLibreAccessWebServiceRenewToken] == NSOrderedSame)) {
        
                   
        self.aToken = nil;
        self.tokenExpires = nil;        

        id deviceIsDeregistered = [result objectForKey:kSCHLibreAccessWebServiceDeviceIsDeregistered]; 
        id returnedToken = [result objectForKey:kSCHLibreAccessWebServiceAuthToken];
        id expiresIn = [result objectForKey:kSCHLibreAccessWebServiceExpiresIn];
        
        if ([method isEqualToString:kSCHLibreAccessWebServiceAuthenticateDevice] &&
            [deviceIsDeregistered isKindOfClass:[NSNumber class]] &&
            [deviceIsDeregistered boolValue] == YES) {
            [self performForcedDeregistrationWithToken:returnedToken];
        } else {
            
            NSString *authToken = returnedToken == [NSNull null] ? nil : returnedToken;
            NSInteger expires = expiresIn == [NSNull null] ? 30 : [expiresIn integerValue];
            
            if (authToken) {
                self.aToken = authToken;
                [self setLastKnownAuthToken:authToken];
                
                expires = MAX(0, expires - 1);
                self.tokenExpires = [NSDate dateWithTimeIntervalSinceNow:expires * kSCHAuthenticationManagerSecondsInAMinute];
                [self postSuccessWithOfflineMode:NO];
            } else {
                [self performForcedDeregistrationWithToken:returnedToken];
            }
        }
        
		self.waitingOnResponse = NO;        
    }
}

- (void)method:(NSString *)method didFailWithError:(NSError *)error 
   requestInfo:(NSDictionary *)requestInfo
        result:(NSDictionary *)result
{
    NSLog(@"AuthenticationManager:%@ %@", method, [error description]);
    self.waitingOnResponse = NO;

    if ([error domain] != kBITAPIErrorDomain) {
        if([method compare:kSCHLibreAccessWebServiceTokenExchange] == NSOrderedSame) {	
            NSNumber *deviceIsDeregistered = [result objectForKey:kSCHLibreAccessWebServiceDeviceIsDeregistered];        
            if ([deviceIsDeregistered isKindOfClass:[NSNumber class]] == YES &&
                [[result objectForKey:kSCHLibreAccessWebServiceDeviceIsDeregistered] boolValue] == YES) {
                NSString *returnedToken = [result objectForKey:kSCHLibreAccessWebServiceAuthToken];
                [self performForcedDeregistrationWithToken:returnedToken];
                return;
            }
        } else if ([method compare:kSCHLibreAccessWebServiceAuthenticateDevice] == NSOrderedSame) {	
            self.aToken = nil;
            self.tokenExpires = nil;        
            
            NSNumber *deviceIsDeregistered = [result objectForKey:kSCHLibreAccessWebServiceDeviceIsDeregistered];        
            if ([deviceIsDeregistered isKindOfClass:[NSNumber class]] == YES &&
                [[result objectForKey:kSCHLibreAccessWebServiceDeviceIsDeregistered] boolValue] == YES) {
                NSString *returnedToken = [result objectForKey:kSCHLibreAccessWebServiceAuthToken];
                [self performForcedDeregistrationWithToken:returnedToken];
                return;
            } else {
                // we only step back to authenticate if this was a server error
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSCHAuthenticationManagerDeviceKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        } else if ([method compare:kSCHLibreAccessWebServiceRenewToken] == NSOrderedSame) {	
            self.aToken = nil;
            self.tokenExpires = nil;        
        }
    }

	[self postFailureWithError:error];
}

#pragma mark - DRM Registration Session Delegate methods

- (void)registrationSession:(SCHDrmRegistrationSession *)registrationSession 
                didComplete:(NSString *)deviceKey
{
    if (deviceKey != nil) {
        [[NSUserDefaults standardUserDefaults] setObject:deviceKey 
                                                  forKey:kSCHAuthenticationManagerDeviceKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [libreAccessWebService authenticateDevice:deviceKey forUserKey:nil];
    } else {
        // Successful deregistration
        if (self.waitingOnResponse) {
            self.waitingOnResponse = NO;
            [self performPostDeregistration];
        }
    }
    self.drmRegistrationSession = nil;
}

- (void)registrationSession:(SCHDrmRegistrationSession *)registrationSession 
           didFailWithError:(NSError *)error
{
    NSLog(@"AuthenticationManager:DRM %@", [error description]);
	self.waitingOnResponse = NO;
	
    // were we de-registered?
    if ([error code] == kSCHDrmDeregistrationError) {
        [self performPostDeregistration];        
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:SCHAuthenticationManagerDidFailDeregistrationNotification
                                                            object:self 
                                                          userInfo:[NSDictionary dictionaryWithObject:error forKey:kSCHAuthenticationManagerNSError]];		        
        
        [self postFailureWithError:error];
    }

    self.drmRegistrationSession = nil;    
}

@end
