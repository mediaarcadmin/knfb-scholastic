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
NSString * const SCHAuthenticationManagerReceivedServerDeregistrationNotification = @"SCHAuthenticationManagerReceivedServerDeregistrationNotification";
NSString * const kSCHAuthenticationManagerNSError = @"NSError";

NSString * const kSCHAuthenticationManagerErrorDomain = @"AuthenticationManagerErrorDomain";
NSInteger const kSCHAuthenticationManagerGeneralError = 2000;
NSInteger const kSCHAuthenticationManagerLoginError = 2001;

NSString * const kSCHAuthenticationManagerServiceName = @"Scholastic";

NSTimeInterval const kSCHAuthenticationManagerSecondsInAMinute = 60.0;

@interface SCHAuthenticationManager ()

- (void)aTokenOnMainThread;
- (void)isAuthenticatedOnMainThread:(NSValue *)returnValue;
- (void)hasUsernameAndPasswordOnMainThread:(NSValue *)returnValue;
- (void)performPostDeregistration;
- (void)setLastKnownAuthToken:(NSString *)token;

@property (nonatomic, copy) SCHDrmRegistrationSuccessBlock registrationSuccessBlock;
@property (nonatomic, copy) SCHDrmRegistrationFailureBlock registrationFailureBlock;
@property (nonatomic, copy) SCHDrmDeregistrationSuccessBlock deregistrationSuccessBlock;
@property (nonatomic, copy) SCHDrmDeregistrationFailureBlock deregistrationFailureBlock;

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
@synthesize authenticationSuccessBlock;
@synthesize authenticationFailureBlock;
@synthesize registrationSuccessBlock;
@synthesize registrationFailureBlock;
@synthesize deregistrationSuccessBlock;
@synthesize deregistrationFailureBlock;

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
    [authenticationSuccessBlock release], authenticationSuccessBlock = nil;
    [authenticationFailureBlock release], authenticationFailureBlock = nil;
    [registrationSuccessBlock release], registrationSuccessBlock = nil;
    [registrationFailureBlock release], registrationFailureBlock = nil;
    [deregistrationSuccessBlock release], deregistrationSuccessBlock = nil;
    [deregistrationFailureBlock release], deregistrationFailureBlock = nil;
    
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

- (void)authenticateWithUser:(NSString *)userName 
                    password:(NSString *)password
                successBlock:(SCHAuthenticationSuccessBlock)successBlock
                failureBlock:(SCHAuthenticationFailureBlock)failureBlock
{
    
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self authenticateWithUser:userName 
                              password:password 
                          successBlock:successBlock 
                          failureBlock:failureBlock];
        });
        return;
    }
        
    self.authenticationSuccessBlock = ^(BOOL offlineMode){
        [[SCHAuthenticationManager sharedAuthenticationManager] clearAppProcessing];
        
        if (successBlock) {
            successBlock(offlineMode);
        }
    };
    
    self.authenticationFailureBlock = ^(NSError * error){
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
                
                [self authenticateWithSuccessBlock:self.authenticationSuccessBlock
                                      failureBlock:self.authenticationFailureBlock];
                
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
        [[NSUserDefaults standardUserDefaults] setObject:userName forKey:kSCHAuthenticationManagerUsername];
        
        [SFHFKeychainUtils storeUsername:userName 
                             andPassword:password 
                          forServiceName:kSCHAuthenticationManagerServiceName 
                          updateExisting:YES 
                                   error:nil];
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSCHAuthenticationManagerDeviceKey];                        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSCHAuthenticationManagerUserKey];   
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        self.aToken = @"";
        self.tokenExpires = [NSDate distantFuture];
        
        // TODO: Why does this need to be delayed?
        double delayInSeconds = 0.1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self authenticationDidSucceedWithOfflineMode:NO];
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
        if (completionBlock) {
            completionBlock();
        }
    };
    
    self.waitingOnResponse = NO;
    
    NSString *authToken = self.aToken;
    
    if (!authToken) {
        NSLog(@"Warning: an attempt was made to force deregisteration without a current auth token. Using last known auth token");
        SCHAppState *appState = [SCHAppStateManager sharedAppStateManager].appState;
        authToken = appState.LastKnownAuthToken;
    }
    
    if (authToken) {
        [self.drmRegistrationSession deregisterDevice:authToken];
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
    return(self.accountValidation.pToken);    
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
        
        ret = [NSURL URLWithString:[[NSString stringWithFormat:@"https://ebooks2uat.scholastic.com/wpt/auth?tk=%@&appln=%@&spsId=%@", 
                                     (pToken == nil ? self.accountValidation.pToken : pToken), 
                                     [appln componentsJoinedByString:@"|"], 
                                     [[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerUserKey]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
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

- (void)isAuthenticatedOnMainThread:(NSValue *)returnValue
{
    NSAssert([NSThread isMainThread] == YES, @"SCHAuthenticationManager::isAuthenticatedOnMainThread MUST be executed on the main thread");

    *(BOOL *)returnValue.pointerValue = YES;
    
    if([[SCHAppStateManager sharedAppStateManager] canAuthenticate] == YES) {
        *(BOOL *)returnValue.pointerValue = (self.aToken != nil && 
               [[self.aToken stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0);
        
    }
}

- (void)authenticateWithSuccessBlock:(SCHAuthenticationSuccessBlock)successBlock
                        failureBlock:(SCHAuthenticationFailureBlock)failureBlock;
{    
    
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self authenticateWithSuccessBlock:successBlock
                                  failureBlock:failureBlock];
        });
        return;
    }
    
    self.authenticationSuccessBlock = successBlock;
    self.authenticationFailureBlock = failureBlock;
    
    NSString *storedUsername = [[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerUsername];
    NSString *storedPassword = [SFHFKeychainUtils getPasswordForUsername:storedUsername andServiceName:kSCHAuthenticationManagerServiceName error:nil];
    NSString *deviceKey = [[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerDeviceKey];	
    
    NSLog(@"Authenticating %@ with %@", storedUsername, (deviceKey == nil ? @"no deviceKey" : deviceKey));        
    
    if([[SCHAppStateManager sharedAppStateManager] canAuthenticate]) {
        if (self.waitingOnResponse == NO) {
            if ([[Reachability reachabilityForInternetConnection] isReachable]) {
                
                if (self.aToken != nil && [[self.aToken stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
                    
                    [self.libreAccessWebService renewToken:self.aToken];
                    self.waitingOnResponse = YES;                
                } else if (deviceKey != nil && [[deviceKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
                    
                    [self.libreAccessWebService authenticateDevice:deviceKey forUserKey:nil];
                    self.waitingOnResponse = YES;                                
                } else if ([[storedUsername stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0 &&
                           [[storedPassword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
                    
                    __block SCHAuthenticationManager *weakSelf = self;
                    
                    [self.accountValidation validateWithUserName:storedUsername withPassword:storedPassword validateBlock:^(NSString *pToken, NSError *error) {
                        if (error != nil) {
                            weakSelf.waitingOnResponse = NO;
                            [weakSelf authenticationDidFailWithError:error];                            
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
                    
                    [self authenticationDidFailWithError:error];            
                }
            } else {
                
                if ([[storedUsername stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {     
                
                    [self authenticationDidSucceedWithOfflineMode:YES];
                } else {
                    NSError *error = [NSError errorWithDomain:kSCHAuthenticationManagerErrorDomain 
                                                     code:kSCHAuthenticationManagerLoginError 
                                                 userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"You must enter a username and password", @"") 
                                                                                      forKey:NSLocalizedDescriptionKey]];
                
                    [self authenticationDidFailWithError:error]; 
                }
            }
        } 
    } else {
        self.aToken = @"";
        self.tokenExpires = [NSDate distantFuture];        
        
        // TODO: Why does this need to be delayed?
        double delayInSeconds = 0.1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self authenticationDidSucceedWithOfflineMode:NO];
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

- (void)performPostDeregistration
{	        
    [self clearOnMainThread];
    [self clearAppProcessingOnMainThread];
    [(AppDelegate_Shared *)[[UIApplication sharedApplication] delegate] clearUserDefaults];
    
    self.authenticationSuccessBlock = nil;
    self.authenticationFailureBlock = nil;
    self.deregistrationSuccessBlock = nil;
    self.deregistrationFailureBlock = nil;
    self.drmRegistrationSession = nil;
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
             
            self.waitingOnResponse = NO;
        } else if (deviceKey) {
            
            [self authenticationDidSucceedWithOfflineMode:NO];
        } else {
            
            self.registrationSuccessBlock = ^(NSString *deviceKey){
                [[NSUserDefaults standardUserDefaults] setObject:deviceKey forKey:kSCHAuthenticationManagerDeviceKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [libreAccessWebService authenticateDevice:deviceKey forUserKey:nil];
            };
            
            self.registrationFailureBlock = ^(NSError *error){
                [self authenticationDidFailWithError:error];
            };
            
            [self.drmRegistrationSession registerDevice:returnedToken];
        }  
        
	} else if (([method compare:kSCHLibreAccessWebServiceAuthenticateDevice] == NSOrderedSame) ||
               ([method compare:kSCHLibreAccessWebServiceRenewToken] == NSOrderedSame)) {
                  
        [self expireToken];
        
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
                
                expiresIn = MAX(0, expiresIn - 1);
                self.tokenExpires = [NSDate dateWithTimeIntervalSinceNow:expiresIn * kSCHAuthenticationManagerSecondsInAMinute];
                [self authenticationDidSucceedWithOfflineMode:NO];
            } else {
                [self authenticationDidSucceedWithOfflineMode:YES];
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
                
                [self authenticationDidSucceedWithOfflineMode:YES];
            }
        } else if ([method compare:kSCHLibreAccessWebServiceRenewToken] == NSOrderedSame) {	
            [self expireToken];
            
            [self authenticationDidSucceedWithOfflineMode:YES];
        }
    } else {
        [self authenticationDidFailWithError:error];
    }
}

#pragma mark - Authentication Outcomes

- (void)authenticationDidSucceedWithOfflineMode:(BOOL)offlineMode
{
    self.waitingOnResponse = NO;
    
    if (self.authenticationSuccessBlock) {
        SCHAuthenticationSuccessBlock handler = Block_copy(self.authenticationSuccessBlock);
        self.authenticationSuccessBlock = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(offlineMode);
        });
        Block_release(handler);
    }
    
    self.authenticationFailureBlock = nil;
}

- (void)authenticationDidFailWithError:(NSError *)error
{
    self.waitingOnResponse = NO;
    
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
    if (self.deregistrationSuccessBlock) {
        SCHDrmDeregistrationSuccessBlock handler = Block_copy(self.deregistrationSuccessBlock);
        self.deregistrationSuccessBlock = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            handler();
        });
        Block_release(handler);
    }
    
    self.deregistrationFailureBlock = nil;
    self.drmRegistrationSession = nil;
    
    [self performPostDeregistration];
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
}

@end
