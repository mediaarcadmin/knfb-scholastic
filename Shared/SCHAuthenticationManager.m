//
//  SCHAuthenticationManager.m
//  Scholastic
//
//  Created by John S. Eddie on 21/01/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHAuthenticationManager.h"

#import "SCHScholasticWebService.h"
#import "SCHLibreAccessWebService.h"
#import "SFHFKeychainUtils.h"
#import "Reachability.h"
#import "SCHDrmRegistrationSession.h"

#import "SCHNonDRMAuthenticationManager.h"

// DeviceKeys
// od1
// od2 {ed9532e2-de12-9a44-ae81-11eafd5a9f3f} - doesnt seem to work
// mf

static SCHAuthenticationManager *sharedAuthenticationManager = nil;

static NSString * const kSCHAuthenticationManagerUsername = @"AuthenticationManager.Username";
static NSString * const kSCHAuthenticationManagerServiceName = @"Scholastic";
NSString * const kSCHAuthenticationManagerDeviceKey = @"AuthenticationManager.DeviceKey";

static NSTimeInterval const kSCHAuthenticationManagerSecondsInAMinute = 60.0;

struct AuthenticateWithUserNameParameters {
    NSString *username;
    NSString *password;
};
typedef struct AuthenticateWithUserNameParameters AuthenticateWithUserNameParameters;

@interface SCHAuthenticationManager ()

+ (SCHAuthenticationManager *)sharedAuthenticationManagerOnMainThread;
- (void)aTokenOnMainThread;
- (void)authenticateWithUserNameOnMainThread:(NSValue *)parameters;
- (void)authenticateOnMainThread:(NSValue *)returnValue;
- (void)hasUsernameAndPasswordOnMainThread:(NSValue *)returnValue;
- (void)clearOnMainThread;

@end

/*
 * This class is thread safe in respect to all the exposed methods being
 * wrappers for private methods that are always executed on the MainThread.
 * Notifications are also sent on the Main Thread and should be handled and 
 * propogated to worker threads appropriately.
 */

@implementation SCHAuthenticationManager

#pragma mark -
#pragma mark Singleton instance methods

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

#pragma mark -
#pragma mark methods

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

- (void)authenticate
{
    [self performSelectorOnMainThread:@selector(authenticateOnMainThread:) 
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

#pragma -
#pragma Accessors

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

#pragma -
#pragma Private methods

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
        [tokenExpires release], tokenExpires = nil;		
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

- (void)authenticateOnMainThread:(NSValue *)returnValue
{    
    NSString *storedUsername = [[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerUsername];
    NSString *storedPassword = [SFHFKeychainUtils getPasswordForUsername:storedUsername andServiceName:kSCHAuthenticationManagerServiceName error:nil];
    NSString *deviceKey = [[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerDeviceKey];	
    
    if (waitingOnResponse == NO) {
        if ([[Reachability reachabilityForInternetConnection] isReachable] == YES) {
            if (self.aToken != nil && [[self.aToken stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
                [libreAccessWebService renewToken:aToken];
                waitingOnResponse = YES;                
            } else if (deviceKey != nil && [[deviceKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
                [libreAccessWebService authenticateDevice:deviceKey forUserKey:nil];
                waitingOnResponse = YES;                                
            } else if (storedUsername != nil &&
                       [[storedUsername stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0 &&
                       storedPassword != nil &&
                       [[storedPassword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
                [scholasticWebService authenticateUserName:storedUsername withPassword:storedPassword];
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
    NSString *deviceKey = [[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerDeviceKey];	
    
    [aToken release], aToken = nil;
    [tokenExpires release], tokenExpires = nil;

    if (deviceKey != nil && 
        [[deviceKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
        // TODO: deregisterDevice
        // [drmRegistrationSession deregisterDevice:deviceKey];
    }
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSCHAuthenticationManagerDeviceKey];    

    if (username != nil && 
        [[username stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
        [SFHFKeychainUtils deleteItemForUsername:username andServiceName:kSCHAuthenticationManagerServiceName error:nil];
    }
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSCHAuthenticationManagerUsername];
}

#pragma mark -
#pragma mark Private methods

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

#pragma mark -
#pragma mark BITAPIProxy Delegate methods

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result
{	
	if([method compare:kSCHScholasticWebServiceProcessRemote] == NSOrderedSame) {	
		[libreAccessWebService tokenExchange:[result objectForKey:kSCHScholasticWebServicePToken] 
                                     forUser:[[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerUsername]];
	} else if([method compare:kSCHLibreAccessWebServiceTokenExchange] == NSOrderedSame) {	
        if (![[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerDeviceKey]) {
            drmRegistrationSession = [[SCHDrmRegistrationSession alloc] init];
            drmRegistrationSession.delegate = self;
            [drmRegistrationSession registerDevice:[result objectForKey:kSCHLibreAccessWebServiceAuthToken]];
        }        
	} else if([method compare:kSCHLibreAccessWebServiceAuthenticateDevice] == NSOrderedSame ||
              [method compare:kSCHLibreAccessWebServiceRenewToken] == NSOrderedSame) {	
        [aToken release], aToken = nil;            
        [tokenExpires release], tokenExpires = nil;                    

        NSNumber *deviceIsDeregistered = [result objectForKey:kSCHLibreAccessWebServiceDeviceIsDeregistered];
        if ([deviceIsDeregistered isKindOfClass:[NSNumber class]] == YES && [deviceIsDeregistered boolValue] == YES) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSCHAuthenticationManagerDeviceKey];
        } else {
            aToken = [[result objectForKey:kSCHLibreAccessWebServiceAuthToken] retain];
            NSInteger expiresIn = MAX(0, [[result objectForKey:kSCHLibreAccessWebServiceExpiresIn] integerValue] - 1);
            tokenExpires = [[NSDate dateWithTimeIntervalSinceNow:expiresIn * kSCHAuthenticationManagerSecondsInAMinute] retain];
        }
        
		waitingOnResponse = NO;
		[self postSuccessWithOfflineMode:NO];        
    }
}

- (void)method:(NSString *)method didFailWithError:(NSError *)error
{
    if([method compare:kSCHLibreAccessWebServiceAuthenticateDevice] == NSOrderedSame) {
        // TODO: we need to decide when to retry and when to re-register the device
        [aToken release], aToken = nil;
        [tokenExpires release], tokenExpires = nil;                
    } else if([method compare:kSCHLibreAccessWebServiceRenewToken] == NSOrderedSame) {	
        [aToken release], aToken = nil;
        [tokenExpires release], tokenExpires = nil;        
    }
    
	waitingOnResponse = NO;
	[self postFailureWithError:error];
}

#pragma mark -
#pragma mark DRM Registration Session Delegate methods

- (void)registrationSession:(SCHDrmRegistrationSession *)registrationSession didComplete:(NSString *)deviceKey
{
    if ( deviceKey != nil ) {
        [[NSUserDefaults standardUserDefaults] setObject:deviceKey 
                                                  forKey:kSCHAuthenticationManagerDeviceKey];
        [libreAccessWebService authenticateDevice:deviceKey forUserKey:nil];
    }
    else
        NSLog(@"Unknown DRM error:  no device key returned from successful registration.");
    [drmRegistrationSession release];
}

- (void)registrationSession:(SCHDrmRegistrationSession *)registrationSession didFailWithError:(NSError *)error
{
	waitingOnResponse = NO;
	[self postFailureWithError:error];       
    [drmRegistrationSession release];
}

@end
