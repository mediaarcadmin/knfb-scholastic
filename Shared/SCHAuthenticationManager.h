//
//  SCHAuthenticationManager.h
//  Scholastic
//
//  Created by John S. Eddie on 21/01/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BITAPIProxyDelegate.h"
#import "SCHDrmRegistrationSessionDelegate.h"

// Constants
extern NSString * const SCHAuthenticationManagerDidSucceedNotification;
extern NSString * const SCHAuthenticationManagerDidFailNotification;
extern NSString * const kSCHAuthenticationManagerAToken;
extern NSString * const kSCHAuthenticationManagerOfflineMode;
extern NSString * const SCHAuthenticationManagerDidDeregisterNotification;
extern NSString * const SCHAuthenticationManagerDidClearAfterDeregisterNotification;
extern NSString * const SCHAuthenticationManagerDidFailDeregistrationNotification;
extern NSString * const kSCHAuthenticationManagerNSError;

extern NSString * const kSCHAuthenticationManagerErrorDomain;
extern NSInteger const kSCHAuthenticationManagerGeneralError;
extern NSInteger const kSCHAuthenticationManagerLoginError;

@interface SCHAuthenticationManager : NSObject <BITAPIProxyDelegate, SCHDrmRegistrationSessionDelegate>  
{
}

// returns nil if the previous aToken expired
@property (nonatomic, copy, readonly) NSString *aToken;
@property (nonatomic, assign, readonly) BOOL isAuthenticated;

+ (SCHAuthenticationManager *)sharedAuthenticationManager;

- (void)authenticateWithUserName:(NSString *)userName withPassword:(NSString *)password;
- (void)authenticate;
- (BOOL)hasUsernameAndPassword;
- (void)deregister;
- (void)clear;
- (void)clearAppProcessing;
- (NSString *)pToken;
- (NSURL *)webParentToolURL:(NSString *)pToken;

@end
