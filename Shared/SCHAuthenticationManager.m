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

@interface SCHAuthenticationManager ()

- (void)postSuccessWithOfflineMode:(BOOL)offlineMode;
- (void)postFailureWithError:(NSError *)error;

@end

@implementation SCHAuthenticationManager

@synthesize aToken;


#pragma mark -
#pragma mark Singleton methods

+ (SCHAuthenticationManager *)sharedAuthenticationManager
{
    if (sharedAuthenticationManager == nil) {
        sharedAuthenticationManager = [[super allocWithZone:NULL] init];		
    }
	
    return(sharedAuthenticationManager);
}

+ (id)allocWithZone:(NSZone *)zone
{
    return([[self sharedAuthenticationManager] retain]);
}

- (id)copyWithZone:(NSZone *)zone
{
    return(self);
}

- (id)retain
{
    return(self);
}

- (NSUInteger)retainCount
{
    return(NSUIntegerMax);  //denotes an object that cannot be released
}

- (void)release
{
    // do nothing
}

- (id)autorelease
{
    return(self);
}

#pragma mark -
#pragma mark methods

- (id)init
{
	self = [super init];
	if (self != nil) {
		self.aToken = nil;
		waitingOnResponse = NO;
		
		scholasticWebService = [[SCHScholasticWebService alloc] init];
		scholasticWebService.delegate = self;
		
		libreAccessWebService = [[SCHLibreAccessWebService alloc] init];	
		libreAccessWebService.delegate = self;
	}
	return(self);
}

- (void)authenticateUserName:(NSString *)username withPassword:(NSString *)password
{
	if (waitingOnResponse == NO) {
		
		if ([[Reachability reachabilityForInternetConnection] isReachable] == NO) {
			NSString *storedUsername = [[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerUsername];
			NSString *storedPassword = nil;
			
			if (username != nil &&
				[[username stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0 &&
				[storedUsername compare:username] == NSOrderedSame) {
				password = [SFHFKeychainUtils getPasswordForUsername:username andServiceName:kSCHAuthenticationManagerServiceName error:nil];
				if (password != nil &&
					[[password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0 &&
					[storedPassword compare:password] == NSOrderedSame) {
					[self postSuccessWithOfflineMode:YES];
				} else {
					NSError *error = [NSError errorWithDomain:kSCHAuthenticationManagerErrorDomain code:kSCHAuthenticationManagerLoginError 
													 userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"Incorrect username/password", @"") forKey:NSLocalizedDescriptionKey]];
					
					[self postFailureWithError:error];
				}
			}
		} else {
			[[NSUserDefaults standardUserDefaults] setObject:username forKey:kSCHAuthenticationManagerUsername];
			[SFHFKeychainUtils storeUsername:username andPassword:password forServiceName:kSCHAuthenticationManagerServiceName updateExisting:YES error:nil];
			self.aToken = nil;
			
			waitingOnResponse = YES;
			[scholasticWebService authenticateUserName:username withPassword:password];		
		}
	}
}

- (NSString *)aToken
{
	return(aToken);
}

- (BOOL)hasUsernameAndPassword
{
	NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerUsername];
	NSString *password = nil;
	BOOL ret = NO;
	
	if (username != nil && [[username stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
		password = [SFHFKeychainUtils getPasswordForUsername:username andServiceName:kSCHAuthenticationManagerServiceName error:nil];
		if (password != nil && [[password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
			ret = YES;
		}
	}
	
	return(ret);
}

- (BOOL)isAuthenticated
{
	return(self.aToken != nil && [[self.aToken stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0);
}

#pragma mark -
#pragma mark Private methods

- (void)postSuccessWithOfflineMode:(BOOL)offlineMode
{
	NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
	
	[userInfo setObject:self.aToken forKey:kSCHAuthenticationManagerAToken];
	[userInfo setObject:[NSNumber numberWithBool:offlineMode] forKey:kSCHAuthenticationManagerOfflineMode];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kSCHAuthenticationManagerSuccess 
														object:self 
													  userInfo:userInfo];				
}

- (void)postFailureWithError:(NSError *)error
{
	[[NSNotificationCenter defaultCenter] postNotificationName:kSCHAuthenticationManagerFailure
														object:self 
													  userInfo:[NSDictionary dictionaryWithObject:error forKey:kSCHAuthenticationManagerNSError]];		
}

#pragma mark -
#pragma mark BITAPIProxy Delegate methods

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result
{
	NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerUsername];
	
	if([method compare:kSCHScholasticWebServiceProcessRemote] == NSOrderedSame) {	
		[libreAccessWebService tokenExchange:[result objectForKey:kSCHScholasticWebServicePToken] forUser:username];
	} else if([method compare:kSCHLibreAccessWebServiceTokenExchange] == NSOrderedSame) {	
		self.aToken = [result objectForKey:kSCHLibreAccessWebServiceAuthToken];
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
