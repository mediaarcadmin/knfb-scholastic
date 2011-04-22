//
//  SCHNonDRMAuthenticationManager.m
//  Scholastic
//
//  Created by Gordon Christie on 06/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHNonDRMAuthenticationManager.h"
#import "SCHAuthenticationManagerProtected.h"

#import "SCHScholasticWebService.h"
#import "SCHLibreAccessWebService.h"
#import "SFHFKeychainUtils.h"
#import "Reachability.h"

@implementation SCHNonDRMAuthenticationManager

- (void)authenticateOnMainThread
{    
    NSString *storedUsername = [[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerUsername];
    NSString *storedPassword = [SFHFKeychainUtils getPasswordForUsername:storedUsername andServiceName:kSCHAuthenticationManagerServiceName error:nil];
    
    if (waitingOnResponse == NO) {
        if ([[Reachability reachabilityForInternetConnection] isReachable] == YES) {
            if (storedUsername != nil &&
                [[storedUsername stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0 &&
                storedPassword != nil &&
                [[storedPassword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
                [aToken release], aToken = nil;
                [tokenExpires release], tokenExpires = nil;

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

#pragma mark -
#pragma mark BITAPIProxy Delegate methods

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result
{
	if([method compare:kSCHScholasticWebServiceProcessRemote] == NSOrderedSame) {	
		[libreAccessWebService tokenExchange:[result objectForKey:kSCHScholasticWebServicePToken] 
                                     forUser:[[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerUsername]];
	} else if([method compare:kSCHLibreAccessWebServiceTokenExchange] == NSOrderedSame) {	
		[aToken release], aToken = nil;            
        [tokenExpires release], tokenExpires = nil;
        
        aToken = [[result objectForKey:kSCHLibreAccessWebServiceAuthToken] retain];
		NSInteger expiresIn = MAX(0, [[result objectForKey:kSCHLibreAccessWebServiceExpiresIn] integerValue] - 1);
		tokenExpires = [[NSDate dateWithTimeIntervalSinceNow:expiresIn * kSCHAuthenticationManagerSecondsInAMinute] retain];
		waitingOnResponse = NO;
		[self postSuccessWithOfflineMode:NO];
	}
}

- (void)method:(NSString *)method didFailWithError:(NSError *)error
{
    NSLog(@"AuthenticationManager:%@ %@", method, [error description]);
	waitingOnResponse = NO;
	[self postFailureWithError:error];
}

@end