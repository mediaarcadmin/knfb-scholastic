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

#import "SCHNonDRMAuthenticationManager.h"

static SCHAuthenticationManager *sharedAuthenticationManager = nil;

NSString * const kSCHAuthenticationManagerDeviceKey = @"AuthenticationManager.DeviceKey";

struct AuthenticateWithUserNameParameters 
{
    NSString *username;
    NSString *password;
};
typedef struct AuthenticateWithUserNameParameters AuthenticateWithUserNameParameters;

@interface SCHAuthenticationManager ()

+ (SCHAuthenticationManager *)sharedAuthenticationManagerOnMainThread;
- (void)aTokenOnMainThread;
- (void)authenticateWithUserNameOnMainThread:(NSValue *)parameters;
- (void)hasUsernameAndPasswordOnMainThread:(NSValue *)returnValue;

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
    if (sharedAuthenticationManager == nil) {
        // we block until the selector completes to make sure we always have the object before use
        [SCHAuthenticationManager performSelectorOnMainThread:@selector(sharedAuthenticationManagerOnMainThread) 
                                                   withObject:nil 
                                                waitUntilDone:YES];
    }
    
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
    return YES;
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
                        waitUntilDone:NO];
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
	return(self.aToken != nil && 
           [[self.aToken stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0);
}

#pragma mark - Private methods

+ (SCHAuthenticationManager *)sharedAuthenticationManagerOnMainThread
{
    if (sharedAuthenticationManager == nil) {
#if NONDRMAUTHENTICATION
        sharedAuthenticationManager = [[SCHNonDRMAuthenticationManager allocWithZone:NULL] init];
#else
        sharedAuthenticationManager = [[super allocWithZone:NULL] init];
#endif
    }
    
    return(sharedAuthenticationManager);
}

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

- (void)clearOnMainThread
{
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerUsername];	
    
    /* TODO:  We can't deregister without an authentication token, which we 
     can't assume is available here; we have to authenticate the device.  But  
     if we are clearing because we're going into local mode, then we're not 
     to be in an authenticated state.
     NSString *deviceKey = [[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerDeviceKey];	
     if (deviceKey != nil && 
     [[deviceKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
     // Get a token for deregistration.
     [libreAccessWebService authenticateDevice:deviceKey forUserKey:nil];
     }
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:kSCHAuthenticationManagerDeviceKey]; 
     */
    
    
    self.aToken = nil;
    self.tokenExpires = nil;    
    
    if (username != nil && 
        [[username stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
        [SFHFKeychainUtils deleteItemForUsername:username andServiceName:kSCHAuthenticationManagerServiceName error:nil];
    }
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSCHAuthenticationManagerUsername];
}

#pragma mark - Private methods

- (void)postSuccessWithOfflineMode:(BOOL)offlineMode
{
	NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
	
	[userInfo setObject:(aToken == nil ? (id)[NSNull null] : aToken) 
                 forKey:kSCHAuthenticationManagerAToken];
	[userInfo setObject:[NSNumber numberWithBool:offlineMode] 
                 forKey:kSCHAuthenticationManagerOfflineMode];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kSCHAuthenticationManagerSuccess 
														object:self 
													  userInfo:userInfo];				
}

- (void)postFailureWithError:(NSError *)error
{
	[[NSNotificationCenter defaultCenter] postNotificationName:kSCHAuthenticationManagerFailure
														object:self 
													  userInfo:[NSDictionary dictionaryWithObject:error
                                                                                           forKey:kSCHAuthenticationManagerNSError]];		
}

#pragma mark - BITAPIProxy Delegate methods

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result
{	
	if([method compare:kSCHScholasticWebServiceProcessRemote] == NSOrderedSame) {	
		[self.libreAccessWebService tokenExchange:[result objectForKey:kSCHScholasticWebServicePToken] 
                                     forUser:[[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerUsername]];
	} else if([method compare:kSCHLibreAccessWebServiceTokenExchange] == NSOrderedSame) {	
        if (![[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerDeviceKey]) {
            self.drmRegistrationSession = [[[SCHDrmRegistrationSession alloc] init] autorelease];
            drmRegistrationSession.delegate = self;
            [drmRegistrationSession registerDevice:[result objectForKey:kSCHLibreAccessWebServiceAuthToken]];
        }        
	} else if([method compare:kSCHLibreAccessWebServiceAuthenticateDevice] == NSOrderedSame ||
              [method compare:kSCHLibreAccessWebServiceRenewToken] == NSOrderedSame) {	
        self.aToken = nil;
        self.tokenExpires = nil;        

        NSNumber *deviceIsDeregistered = [result objectForKey:kSCHLibreAccessWebServiceDeviceIsDeregistered];
        if ([deviceIsDeregistered isKindOfClass:[NSNumber class]] == YES && [deviceIsDeregistered boolValue] == YES) {
            //[[NSUserDefaults standardUserDefaults] removeObjectForKey:kSCHAuthenticationManagerDeviceKey];
            // Someone has deregistered the device externally using parent tools, so we must complete 
            // the process on the client.
            if ( drmRegistrationSession == nil ) {
                drmRegistrationSession = [[SCHDrmRegistrationSession alloc] init];
                drmRegistrationSession.delegate = self;
                [drmRegistrationSession deregisterDevice:[result objectForKey:kSCHLibreAccessWebServiceAuthToken]];
            }
            waitingOnResponse = NO;
            [self postFailureWithError:[drmRegistrationSession drmError:kSCHDrmRegistrationError 
                                                                message:@"Cannot process books because device has been deregistered."]];
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

- (void)method:(NSString *)method didFailWithError:(NSError *)error
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

    [self clearOnMainThread];
	waitingOnResponse = NO;
	[self postFailureWithError:error];
}

#pragma mark - DRM Registration Session Delegate methods

- (void)registrationSession:(SCHDrmRegistrationSession *)registrationSession didComplete:(NSString *)deviceKey
{
    if (deviceKey != nil ) {
        [[NSUserDefaults standardUserDefaults] setObject:deviceKey 
                                                  forKey:kSCHAuthenticationManagerDeviceKey];
        [libreAccessWebService authenticateDevice:deviceKey forUserKey:nil];
    }
    else
        // Successful deregistration
        // removeObjectForKey does not change the value...
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kSCHAuthenticationManagerDeviceKey];
    self.drmRegistrationSession = nil;
}

- (void)registrationSession:(SCHDrmRegistrationSession *)registrationSession didFailWithError:(NSError *)error
{
    NSLog(@"AuthenticationManager:DRM %@", [error description]);
	waitingOnResponse = NO;
	[self postFailureWithError:error];       
    self.drmRegistrationSession = nil;
}

@end
