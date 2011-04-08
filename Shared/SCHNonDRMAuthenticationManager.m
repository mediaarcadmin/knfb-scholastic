//
//  SCHNonDRMAuthenticationManager.m
//  Scholastic
//
//  Created by Gordon Christie on 06/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHNonDRMAuthenticationManager.h"

#import "SCHScholasticWebService.h"
#import "SCHLibreAccessWebService.h"
#import "SFHFKeychainUtils.h"
#import "Reachability.h"

static NSString * const kSCHAuthenticationManagerUsername = @"AuthenticationManager.Username";
static NSString * const kSCHAuthenticationManagerServiceName = @"Scholastic";
static NSTimeInterval const kSCHAuthenticationManagerSecondsInAMinute = 60.0;

@implementation SCHNonDRMAuthenticationManager

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
            }
        }
    } else {
        NSError *error = [NSError errorWithDomain:kSCHAuthenticationManagerErrorDomain 
                                             code:kSCHAuthenticationManagerLoginError 
                                         userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"You must enter a username and password", @"") 
                                                                              forKey:NSLocalizedDescriptionKey]];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kSCHAuthenticationManagerFailure
                                                            object:self 
                                                          userInfo:[NSDictionary dictionaryWithObject:error
                                                                                               forKey:kSCHAuthenticationManagerNSError]];	 
    }
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