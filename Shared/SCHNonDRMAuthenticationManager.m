//
//  SCHNonDRMAuthenticationManager.m
//  Scholastic
//
//  Created by Gordon Christie on 06/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHNonDRMAuthenticationManager.h"
#import "SCHAuthenticationManagerProtected.h"

#import "SCHLibreAccessWebService.h"
#import "SFHFKeychainUtils.h"
#import "Reachability.h"
#import "SCHAccountValidation.h"
#import "SCHUserDefaults.h"

@implementation SCHNonDRMAuthenticationManager

#pragma - methods

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
    
    NSAssert([NSThread isMainThread] == YES, @"SCHAuthenticationManager::authenticateOnMainThread MUST be executed on the main thread");
    
    self.authenticationSuccessBlock = successBlock;
    self.authenticationFailureBlock = failureBlock;
    
    if (self.isAuthenticating) {
        return;
    }
    
    self.authenticating = YES;
    
    NSString *storedUsername = [[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerUsername];
    NSString *storedPassword = [SFHFKeychainUtils getPasswordForUsername:storedUsername andServiceName:kSCHAuthenticationManagerServiceName error:nil];
    
    if ([[Reachability reachabilityForInternetConnection] isReachable] == YES) {
        if (storedUsername != nil &&
            [[storedUsername stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0 &&
            storedPassword != nil &&
            [[storedPassword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
            self.aToken = nil;
            self.tokenExpires = nil;                
            
            __block SCHAuthenticationManager *weakSelf = self;
            [self.accountValidation validateWithUserName:storedUsername withPassword:storedPassword validateBlock:^(NSString *pToken, NSError *error) {
                if (error != nil) {
                    [weakSelf authenticationDidFailWithError:error];                            
                } else {
                    [weakSelf.libreAccessWebService tokenExchange:pToken 
                                                          forUser:[[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerUsername]];                            
                }
            }];
            
        } else {
            NSError *error = [NSError errorWithDomain:kSCHAuthenticationManagerErrorDomain 
                                                 code:kSCHAuthenticationManagerLoginError 
                                             userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"You must enter a username and password", @"") 
                                                                                  forKey:NSLocalizedDescriptionKey]];
            
            [self authenticationDidFailWithError:error];            
        }
    } else if (storedUsername != nil &&
               [[storedUsername stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {            
        [self authenticationDidSucceedWithOfflineMode:YES];
    } else {
        NSError *error = [NSError errorWithDomain:kSCHAuthenticationManagerErrorDomain 
                                             code:kSCHAuthenticationManagerLoginError 
                                         userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"You must enter a username and password", @"") 
                                                                              forKey:NSLocalizedDescriptionKey]];
        
        [self authenticationDidFailWithError:error];
    }
}

#pragma mark - BITAPIProxy Delegate methods

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result
      userInfo:(NSDictionary *)userInfo
{
	if([method compare:kSCHLibreAccessWebServiceTokenExchange] == NSOrderedSame) {	
        self.aToken = nil;
        self.tokenExpires = nil;        
        
        self.aToken = [result objectForKey:kSCHLibreAccessWebServiceAuthToken];
		NSInteger expiresIn = MAX(0, [[result objectForKey:kSCHLibreAccessWebServiceExpiresIn] integerValue] - 1);
		self.tokenExpires = [NSDate dateWithTimeIntervalSinceNow:expiresIn * kSCHAuthenticationManagerSecondsInAMinute];
		[self authenticationDidSucceedWithOfflineMode:NO];
	}
}

- (void)method:(NSString *)method didFailWithError:(NSError *)error 
   requestInfo:(NSDictionary *)requestInfo
        result:(NSDictionary *)result
{
    NSLog(@"AuthenticationManager:%@ %@", method, [error description]);
    [self clearOnMainThread];
	[self authenticationDidFailWithError:error];
}

@end