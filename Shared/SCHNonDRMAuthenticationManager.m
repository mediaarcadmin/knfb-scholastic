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
}

#pragma mark - BITAPIProxy Delegate methods

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result
{
	if([method compare:kSCHLibreAccessWebServiceTokenExchange] == NSOrderedSame) {	
        self.aToken = nil;
        self.tokenExpires = nil;        
        
        self.aToken = [result objectForKey:kSCHLibreAccessWebServiceAuthToken];
		NSInteger expiresIn = MAX(0, [[result objectForKey:kSCHLibreAccessWebServiceExpiresIn] integerValue] - 1);
		self.tokenExpires = [NSDate dateWithTimeIntervalSinceNow:expiresIn * kSCHAuthenticationManagerSecondsInAMinute];
		self.waitingOnResponse = NO;
		[self authenticationDidSucceedWithOfflineMode:NO];
	}
}

- (void)method:(NSString *)method didFailWithError:(NSError *)error userInfo:(NSDictionary *)userInfo
{
    NSLog(@"AuthenticationManager:%@ %@", method, [error description]);
    [self clearOnMainThread];
	self.waitingOnResponse = NO;
	[self authenticationDidFailWithError:error];
}

@end