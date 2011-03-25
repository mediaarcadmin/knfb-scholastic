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

static SCHAuthenticationManager *sharedAuthenticationManager = nil;

static NSString * const kSCHAuthenticationManagerUsername = @"AuthenticationManager.Username";
static NSString * const kSCHAuthenticationManagerServiceName = @"Scholastic";

static NSTimeInterval const kSCHAuthenticationManagerSecondsInAMinute = 60.0;

struct AuthenticateWithUserNameParameters {
    NSString *username;
    NSString *password;
    BOOL ret;
};
typedef struct AuthenticateWithUserNameParameters AuthenticateWithUserNameParameters;

@interface SCHAuthenticationManager ()

+ (SCHAuthenticationManager *)sharedAuthenticationManagerOnMainThread;
- (void)aTokenOnMainThread;
- (void)authenticateWithUserNameOnMainThread:(NSValue *)parameters;
- (void)authenticateOnMainThread:(NSValue *)returnValue;
- (void)hasUsernameAndPasswordOnMainThread:(NSValue *)returnValue;
- (void)clearOnMainThread;

- (void)postSuccessWithOfflineMode:(BOOL)offlineMode;
- (void)postFailureWithError:(NSError *)error;

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

- (BOOL)authenticateWithUserName:(NSString *)username withPassword:(NSString *)password
{
    AuthenticateWithUserNameParameters authenticateWithUserNameParameters;
    
    authenticateWithUserNameParameters.username = username;
    authenticateWithUserNameParameters.password = password;
    authenticateWithUserNameParameters.ret = NO;
        
    NSValue *resultValue = [NSValue valueWithPointer:&authenticateWithUserNameParameters];
    
    // we block until the selector completes to make sure we always have the return object before use
    [self performSelectorOnMainThread: @selector(authenticateWithUserNameOnMainThread:) 
                           withObject:resultValue 
                        waitUntilDone:YES];
    
    return(authenticateWithUserNameParameters.ret);       
}

- (BOOL)authenticate
{
    BOOL ret = NO;
    NSValue *resultValue = [NSValue valueWithPointer:&ret];

    // we block until the selector completes to make sure we always have the return object before use
    [self performSelectorOnMainThread: @selector(authenticateOnMainThread:) 
                           withObject:resultValue 
                        waitUntilDone:YES];
    
    return(ret);    
}

- (BOOL)hasUsernameAndPassword
{
    BOOL ret = NO;
    NSValue *resultValue = [NSValue valueWithPointer:&ret];

    // we block until the selector completes to make sure we always have the return object before use
    [self performSelectorOnMainThread: @selector(hasUsernameAndPasswordOnMainThread:) 
                           withObject:resultValue 
                        waitUntilDone:YES];

    return(ret);
}

- (void)clear
{
    [self performSelectorOnMainThread: @selector(clearOnMainThread) withObject:nil waitUntilDone:NO];
}

#pragma -
#pragma Accessors

- (NSString *)aToken
{
    // we block until the selector completes to make sure we always have the return object before use
    [self performSelectorOnMainThread: @selector(aTokenOnMainThread) withObject:nil waitUntilDone:YES];
    
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
        sharedAuthenticationManager = [[super allocWithZone:NULL] init];		
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
    
    if (waitingOnResponse == NO) {
        if ([[Reachability reachabilityForInternetConnection] isReachable] == NO) {
            NSString *storedUsername = [[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerUsername];
            NSString *storedPassword = nil;
            
            if (authenticateWithUserNameParameters->username != nil &&
                [[authenticateWithUserNameParameters->username stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0 &&
                [storedUsername compare:authenticateWithUserNameParameters->username] == NSOrderedSame) {
                storedPassword = [SFHFKeychainUtils getPasswordForUsername:authenticateWithUserNameParameters->username 
                                                            andServiceName:kSCHAuthenticationManagerServiceName error:nil];
                if (authenticateWithUserNameParameters->password != nil &&
                    [[authenticateWithUserNameParameters->password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0 &&
                    [storedPassword compare:authenticateWithUserNameParameters->password] == NSOrderedSame) {
                    [self postSuccessWithOfflineMode:YES];
                } else {
                    NSError *error = [NSError errorWithDomain:kSCHAuthenticationManagerErrorDomain 
                                                         code:kSCHAuthenticationManagerLoginError 
                                                     userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"Incorrect username/password", @"") 
                                                                                          forKey:NSLocalizedDescriptionKey]];
                    
                    [self postFailureWithError:error];
                }
            } else {
                NSError *error = [NSError errorWithDomain:kSCHAuthenticationManagerErrorDomain 
                                                     code:kSCHAuthenticationManagerLoginError 
                                                 userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"Incorrect username/password", @"") 
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
            
            authenticateWithUserNameParameters->ret = [self authenticate];
        }
    } else {
        authenticateWithUserNameParameters->ret = YES;
    }
}

- (void)authenticateOnMainThread:(NSValue *)returnValue
{    
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerUsername];
    NSString *password = nil;
    
    if (waitingOnResponse == NO) {
        if ([[Reachability reachabilityForInternetConnection] isReachable] == YES &&
            username != nil &&
            [[username stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
            password = [SFHFKeychainUtils getPasswordForUsername:username andServiceName:kSCHAuthenticationManagerServiceName error:nil];
            if (password != nil &&
                [[password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
                [aToken release], aToken = nil;
                [tokenExpires release], tokenExpires = nil;
                
                waitingOnResponse = YES;
                [scholasticWebService authenticateUserName:username withPassword:password];	
                *(BOOL *)returnValue.pointerValue = YES;
            }
        }
    } else {
        *(BOOL *)returnValue.pointerValue = YES;
    }
}

- (void)hasUsernameAndPasswordOnMainThread:(NSValue *)returnValue
{
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerUsername];
    NSString *password = nil;
    
    if (username != nil && [[username stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
        password = [SFHFKeychainUtils getPasswordForUsername:username andServiceName:kSCHAuthenticationManagerServiceName error:nil];
        if (password != nil && [[password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
            *(BOOL *)returnValue.pointerValue = YES;
        }
    }
}

- (void)clearOnMainThread
{
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerUsername];	
    
    if (username != nil && [[username stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
        [SFHFKeychainUtils deleteItemForUsername:username andServiceName:kSCHAuthenticationManagerServiceName error:nil];
    }
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSCHAuthenticationManagerUsername];
}

#pragma mark -
#pragma mark Private methods

- (void)postSuccessWithOfflineMode:(BOOL)offlineMode
{
	NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
	
	[userInfo setObject:(self.aToken == nil ? (id)[NSNull null] : self.aToken) forKey:kSCHAuthenticationManagerAToken];
	[userInfo setObject:[NSNumber numberWithBool:offlineMode] forKey:kSCHAuthenticationManagerOfflineMode];
	
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
	NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerUsername];
	
	if([method compare:kSCHScholasticWebServiceProcessRemote] == NSOrderedSame) {	
		[libreAccessWebService tokenExchange:[result objectForKey:kSCHScholasticWebServicePToken] forUser:username];
	} else if([method compare:kSCHLibreAccessWebServiceTokenExchange] == NSOrderedSame) {	
		aToken = [[result objectForKey:kSCHLibreAccessWebServiceAuthToken] retain];
		NSInteger expiresIn = MAX(0, [[result objectForKey:kSCHLibreAccessWebServiceExpiresIn] integerValue] - 1);
		tokenExpires = [[NSDate dateWithTimeIntervalSinceNow:expiresIn * kSCHAuthenticationManagerSecondsInAMinute] retain];
		waitingOnResponse = NO;
		[self postSuccessWithOfflineMode:NO];
	}
}

- (void)method:(NSString *)method didFailWithError:(NSError *)error
{
	waitingOnResponse = NO;
	[self postFailureWithError:error];
}

@end
