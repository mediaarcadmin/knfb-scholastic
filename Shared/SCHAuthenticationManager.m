//
//  SCHAuthenticationManager.m
//  Scholastic
//
//  Created by John S. Eddie on 21/01/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHAuthenticationManager.h"
#import "SCHAuthenticationManagerProtected.h"

#import "SCHScholasticWebService.h"
#import "SCHLibreAccessWebService.h"
#import "SFHFKeychainUtils.h"
#import "Reachability.h"
#import "SCHDrmSession.h"
#import "SCHURLManager.h"
#import "SCHProcessingManager.h"                
#import "SCHSyncManager.h"
#import "SCHAppStateManager.h"

#import "SCHNonDRMAuthenticationManager.h"

// Constants
NSString * const SCHAuthenticationManagerDidSucceedNotification = @"SCHAuthenticationManagerDidSucceedNotification";
NSString * const SCHAuthenticationManagerDidFailNotification = @"SCHAuthenticationManagerDidFailNotification";
NSString * const kSCHAuthenticationManagerAToken = @"aToken";
NSString * const kSCHAuthenticationManagerOfflineMode = @"OfflineMode";
NSString * const SCHAuthenticationManagerDidDeregisterNotification = @"SCHAuthenticationManagerDidDeregisterNotification";
NSString * const SCHAuthenticationManagerDidFailDeregistrationNotification = @"SCHAuthenticationManagerDidFailDeregistrationNotification";
NSString * const kSCHAuthenticationManagerNSError = @"NSError";

NSString * const kSCHAuthenticationManagerErrorDomain = @"AuthenticationManagerErrorDomain";
NSInteger const kSCHAuthenticationManagerGeneralError = 2000;
NSInteger const kSCHAuthenticationManagerLoginError = 2001;

NSString * const kSCHAuthenticationManagerDeviceKey = @"AuthenticationManager.DeviceKey";

NSString * const kSCHAuthenticationManagerUsername = @"AuthenticationManager.Username";
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
- (void)authenticateWithUserNameOnMainThread:(NSValue *)parameters;
- (void)hasUsernameAndPasswordOnMainThread:(NSValue *)returnValue;
- (void)deregisterOnMainThread:(NSString *)token;

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
@synthesize scholasticWebService;
@synthesize libreAccessWebService;
@synthesize drmRegistrationSession;

#pragma mark - Singleton instance methods

+ (SCHAuthenticationManager *)sharedAuthenticationManager
{
    static dispatch_once_t pred;
    static SCHAuthenticationManager *sharedAuthenticationManager = nil;
    
    dispatch_once(&pred, ^{
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
		
		scholasticWebService = [[SCHScholasticWebService alloc] init];
		scholasticWebService.delegate = self;
		
		libreAccessWebService = [[SCHLibreAccessWebService alloc] init];	
		libreAccessWebService.delegate = self;
	}
	return(self);
}

- (void)dealloc 
{
    [aToken release], aToken = nil;
    [tokenExpires release], tokenExpires = nil;
    [scholasticWebService release], scholasticWebService = nil;
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
    
    if ([[SCHAppStateManager sharedAppStateManager] canAuthenticate] == YES) {
        NSString *storedUsername = [[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerUsername];
        NSString *storedPassword = [SFHFKeychainUtils getPasswordForUsername:storedUsername andServiceName:kSCHAuthenticationManagerServiceName error:nil];
        
        ret = ([password isEqualToString:storedPassword] == YES);
    }
    
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

#pragma mark - Accessor methods

- (NSString *)aToken
{
    // we block until the selector completes to make sure we always have the 
    // return object before use
    [self performSelectorOnMainThread: @selector(aTokenOnMainThread) 
                           withObject:nil 
                        waitUntilDone:YES];
    
	return(aToken);
}

- (BOOL)isAuthenticated
{
    BOOL ret = YES;
    
    if([[SCHAppStateManager sharedAppStateManager] canAuthenticate] == YES) {
        ret = (self.aToken != nil && 
               [[self.aToken stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0);
        
    }
    
    return(ret);
}

#pragma mark - Private methods

- (void)aTokenOnMainThread
{
    if([tokenExpires compare:[NSDate date]] == NSOrderedAscending) {
        [aToken release], aToken = nil;
        self.tokenExpires = nil;        
    }
}

- (void)authenticateWithUserNameOnMainThread:(NSValue *)parameters
{	
    AuthenticateWithUserNameParameters *authenticateWithUserNameParameters = parameters.pointerValue;
    
    if ([[Reachability reachabilityForInternetConnection] isReachable] == YES) {
        if (authenticateWithUserNameParameters->username != nil &&
            [[authenticateWithUserNameParameters->username stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0 &&
            authenticateWithUserNameParameters->password != nil &&
            [[authenticateWithUserNameParameters->password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
            [self clearOnMainThread];
            [[NSUserDefaults standardUserDefaults] setObject:authenticateWithUserNameParameters->username 
                                                      forKey:kSCHAuthenticationManagerUsername];
            [SFHFKeychainUtils storeUsername:authenticateWithUserNameParameters->username 
                                 andPassword:authenticateWithUserNameParameters->password 
                              forServiceName:kSCHAuthenticationManagerServiceName 
                              updateExisting:YES 
                                       error:nil];
            [self authenticate];
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
}

- (void)authenticateOnMainThread
{    
    NSString *storedUsername = [[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerUsername];
    NSString *storedPassword = [SFHFKeychainUtils getPasswordForUsername:storedUsername andServiceName:kSCHAuthenticationManagerServiceName error:nil];
    NSString *deviceKey = [[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerDeviceKey];	
    
    NSLog(@"Authenticating %@ with %@", storedUsername, (deviceKey == nil ? @"no deviceKey" :deviceKey));        
    
    if (waitingOnResponse == NO) {
        if ([[Reachability reachabilityForInternetConnection] isReachable] == YES) {
            if (self.aToken != nil && [[self.aToken stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
                [self.libreAccessWebService renewToken:self.aToken];
                waitingOnResponse = YES;                
            } else if (deviceKey != nil && [[deviceKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
                [self.libreAccessWebService authenticateDevice:deviceKey forUserKey:nil];
                waitingOnResponse = YES;                                
            } else if (storedUsername != nil &&
                       [[storedUsername stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0 &&
                       storedPassword != nil &&
                       [[storedPassword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
                [self.scholasticWebService authenticateUserName:storedUsername withPassword:storedPassword];
                waitingOnResponse = YES;         
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
}

- (void)hasUsernameAndPasswordOnMainThread:(NSValue *)returnValue
{
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
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerUsername];	
    
    self.aToken = nil;
    self.tokenExpires = nil;        

    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSCHAuthenticationManagerDeviceKey];

    if (username != nil && 
        [[username stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
        [SFHFKeychainUtils deleteItemForUsername:username andServiceName:kSCHAuthenticationManagerServiceName error:nil];
    }
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSCHAuthenticationManagerUsername];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)clearAppProcessingOnMainThread
{
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
    if (token != nil) {
        [self.drmRegistrationSession deregisterDevice:token];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:SCHAuthenticationManagerDidDeregisterNotification
                                                            object:self 
                                                          userInfo:nil];		        
        [self clearOnMainThread];
        [self clearAppProcessingOnMainThread];
    }
}

#pragma mark - BITAPIProxy Delegate methods

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result
{	
	if([method compare:kSCHScholasticWebServiceProcessRemote] == NSOrderedSame) {	
		[self.libreAccessWebService tokenExchange:[result objectForKey:kSCHScholasticWebServicePToken] 
                                     forUser:[[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerUsername]];
	} else if([method compare:kSCHLibreAccessWebServiceTokenExchange] == NSOrderedSame) {	
        NSNumber *deviceIsDeregistered = [result objectForKey:kSCHLibreAccessWebServiceDeviceIsDeregistered];        
        if ([deviceIsDeregistered isKindOfClass:[NSNumber class]] == YES &&
            [[result objectForKey:kSCHLibreAccessWebServiceDeviceIsDeregistered] boolValue] == YES) {
            [self deregisterOnMainThread:[result objectForKey:kSCHLibreAccessWebServiceAuthToken]];
        } else if (![[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerDeviceKey]) {
            [self.drmRegistrationSession registerDevice:[result objectForKey:kSCHLibreAccessWebServiceAuthToken]];
        }        
	} else if([method compare:kSCHLibreAccessWebServiceAuthenticateDevice] == NSOrderedSame ||
              [method compare:kSCHLibreAccessWebServiceRenewToken] == NSOrderedSame) {	
        self.aToken = nil;
        self.tokenExpires = nil;        

        NSNumber *deviceIsDeregistered = [result objectForKey:kSCHLibreAccessWebServiceDeviceIsDeregistered];        
        if ([method isEqualToString:kSCHLibreAccessWebServiceAuthenticateDevice] == YES &&
            [deviceIsDeregistered isKindOfClass:[NSNumber class]] == YES &&
            [[result objectForKey:kSCHLibreAccessWebServiceDeviceIsDeregistered] boolValue] == YES) {
            [self deregisterOnMainThread:[result objectForKey:kSCHLibreAccessWebServiceAuthToken]];
            return;
        } else {
            self.aToken = [result objectForKey:kSCHLibreAccessWebServiceAuthToken];
            NSInteger expiresIn = MAX(0, [[result objectForKey:kSCHLibreAccessWebServiceExpiresIn] integerValue] - 1);
            self.tokenExpires = [NSDate dateWithTimeIntervalSinceNow:expiresIn * kSCHAuthenticationManagerSecondsInAMinute];
        }
        
		waitingOnResponse = NO;
		[self postSuccessWithOfflineMode:NO];        
    }
}

- (void)method:(NSString *)method didFailWithError:(NSError *)error requestInfo:(NSDictionary *)requestInfo
{
    NSLog(@"AuthenticationManager:%@ %@", method, [error description]);
    if([method compare:kSCHLibreAccessWebServiceAuthenticateDevice] == NSOrderedSame) {
        // TODO: we need to decide when to retry and when to re-register the device
        self.aToken = nil;
        self.tokenExpires = nil;        
    } else if([method compare:kSCHLibreAccessWebServiceRenewToken] == NSOrderedSame) {	
        self.aToken = nil;
        self.tokenExpires = nil;        
    }

	waitingOnResponse = NO;
	[self postFailureWithError:error];
}

#pragma mark - DRM Registration Session Delegate methods

- (void)registrationSession:(SCHDrmRegistrationSession *)registrationSession didComplete:(NSString *)deviceKey
{
    if (deviceKey != nil) {
        [[NSUserDefaults standardUserDefaults] setObject:deviceKey 
                                                  forKey:kSCHAuthenticationManagerDeviceKey];
        [libreAccessWebService authenticateDevice:deviceKey forUserKey:nil];
    } else {
        // Successful deregistration
        waitingOnResponse = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:SCHAuthenticationManagerDidDeregisterNotification
                                                            object:self 
                                                          userInfo:nil];		        
        [self clearOnMainThread];
        [self clearAppProcessingOnMainThread];
    }
    self.drmRegistrationSession = nil;
}

- (void)registrationSession:(SCHDrmRegistrationSession *)registrationSession didFailWithError:(NSError *)error
{
    NSLog(@"AuthenticationManager:DRM %@", [error description]);
	waitingOnResponse = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:SCHAuthenticationManagerDidFailDeregistrationNotification
                                                        object:self 
                                                      userInfo:[NSDictionary dictionaryWithObject:error forKey:kSCHAuthenticationManagerNSError]];		        
	[self postFailureWithError:error];       
    self.drmRegistrationSession = nil;
}

@end
