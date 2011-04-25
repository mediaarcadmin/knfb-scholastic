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

#pragma - methods

- (void)authenticateOnMainThread
{    
    NSString *storedUsername = [[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerUsername];
    NSString *storedPassword = [SFHFKeychainUtils getPasswordForUsername:storedUsername andServiceName:kSCHAuthenticationManagerServiceName error:nil];
    
    if (self.waitingOnResponse == NO) {
        if ([[Reachability reachabilityForInternetConnection] isReachable] == YES) {
            if (storedUsername != nil &&
                [[storedUsername stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0 &&
                storedPassword != nil &&
                [[storedPassword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
                self.aToken = nil;
                self.tokenExpires = nil;

                [self.scholasticWebService authenticateUserName:storedUsername withPassword:storedPassword];
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
}

#pragma mark - BITAPIProxy Delegate methods

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result
{
	if([method compare:kSCHScholasticWebServiceProcessRemote] == NSOrderedSame) {	
		[self.libreAccessWebService tokenExchange:[result objectForKey:kSCHScholasticWebServicePToken] 
                                     forUser:[[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerUsername]];
	} else if([method compare:kSCHLibreAccessWebServiceTokenExchange] == NSOrderedSame) {	
        self.aToken = nil;
        self.tokenExpires = nil;        
        
        self.aToken = [result objectForKey:kSCHLibreAccessWebServiceAuthToken];
		NSInteger expiresIn = MAX(0, [[result objectForKey:kSCHLibreAccessWebServiceExpiresIn] integerValue] - 1);
		self.tokenExpires = [NSDate dateWithTimeIntervalSinceNow:expiresIn * kSCHAuthenticationManagerSecondsInAMinute];
		self.waitingOnResponse = NO;
		[self postSuccessWithOfflineMode:NO];
	}
}

- (void)method:(NSString *)method didFailWithError:(NSError *)error
{
    NSLog(@"AuthenticationManager:%@ %@", method, [error description]);
	self.waitingOnResponse = NO;
	[self postFailureWithError:error];
}

@end