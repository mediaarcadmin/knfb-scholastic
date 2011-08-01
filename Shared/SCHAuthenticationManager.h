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
extern NSString * const kSCHAuthenticationManagerDidSucceedNotification;
extern NSString * const kSCHAuthenticationManagerDidFailNotification;
extern NSString * const kSCHAuthenticationManagerAToken;
extern NSString * const kSCHAuthenticationManagerOfflineMode;
extern NSString * const kSCHAuthenticationManagerDidDeregisterNotification;
extern NSString * const kSCHAuthenticationManagerNSError;

extern NSString * const kSCHAuthenticationManagerErrorDomain;
extern NSInteger const kSCHAuthenticationManagerGeneralError;
extern NSInteger const kSCHAuthenticationManagerLoginError;

extern NSString * const kSCHAuthenticationManagerDeviceKey;

@interface SCHAuthenticationManager : NSObject <BITAPIProxyDelegate, SCHDrmRegistrationSessionDelegate>  
{
}

@property (nonatomic, copy, readonly) NSString *aToken;
@property (nonatomic, assign, readonly) BOOL isAuthenticated;

+ (SCHAuthenticationManager *)sharedAuthenticationManager;

- (void)authenticateWithUserName:(NSString *)userName withPassword:(NSString *)password;
- (BOOL)validatePassword:(NSString *)password;
- (void)authenticate;
- (BOOL)hasUsernameAndPassword;
- (void)performDeregistration;
- (void)clear;
- (void)clearAppProcessing;

@end
