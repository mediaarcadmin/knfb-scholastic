//
//  SCHOldAuthenticationManager.h
//  Scholastic
//
//  Created by Gordon Christie on 06/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

#if OLDAUTHENTICATION

#import "BITAPIProxyDelegate.h"

@class SCHScholasticWebService;
@class SCHLibreAccessWebService;

static NSString * const kSCHAuthenticationManagerSuccess = @"AuthenticationManagerSuccess";
static NSString * const kSCHAuthenticationManagerFailure = @"AuthenticationManagerFailure";
static NSString * const kSCHAuthenticationManagerAToken = @"aToken";
static NSString * const kSCHAuthenticationManagerOfflineMode = @"OfflineMode";
static NSString * const kSCHAuthenticationManagerNSError = @"NSError";

static NSString * const kSCHAuthenticationManagerErrorDomain = @"AuthenticationManagerErrorDomain";
static NSInteger const kSCHAuthenticationManagerGeneralError = 2000;
static NSInteger const kSCHAuthenticationManagerLoginError = 2001;

@interface SCHAuthenticationManager : NSObject <BITAPIProxyDelegate>  {
    NSString *aToken;
    NSDate *tokenExpires;
	BOOL waitingOnResponse;
    
	SCHScholasticWebService *scholasticWebService;
	SCHLibreAccessWebService *libreAccessWebService;
}

@property (readonly) NSString *aToken;
@property (readonly) BOOL isAuthenticated;

+ (SCHAuthenticationManager *)sharedAuthenticationManager;

- (BOOL)authenticateWithUserName:(NSString *)userName withPassword:(NSString *)password;
- (BOOL)authenticate;
- (BOOL)hasUsernameAndPassword;
- (void)clear;

@end

#else

#import "BITAPIProxyDelegate.h"
#import "SCHDrmRegistrationSessionDelegate.h"

@class SCHScholasticWebService;
@class SCHLibreAccessWebService;
@class SCHDrmRegistrationSession;

static NSString * const kSCHAuthenticationManagerSuccess = @"AuthenticationManagerSuccess";
static NSString * const kSCHAuthenticationManagerFailure = @"AuthenticationManagerFailure";
static NSString * const kSCHAuthenticationManagerAToken = @"aToken";
static NSString * const kSCHAuthenticationManagerOfflineMode = @"OfflineMode";
static NSString * const kSCHAuthenticationManagerNSError = @"NSError";

static NSString * const kSCHAuthenticationManagerErrorDomain = @"AuthenticationManagerErrorDomain";
static NSInteger const kSCHAuthenticationManagerGeneralError = 2000;
static NSInteger const kSCHAuthenticationManagerLoginError = 2001;

@interface SCHAuthenticationManager : NSObject <BITAPIProxyDelegate, SCHDrmRegistrationSessionDelegate>  {
    NSString *aToken;
    NSDate *tokenExpires;
	BOOL waitingOnResponse;
    
	SCHScholasticWebService *scholasticWebService;
	SCHLibreAccessWebService *libreAccessWebService;
    SCHDrmRegistrationSession *drmRegistrationSession;
}

@property (readonly) NSString *aToken;
@property (readonly) BOOL isAuthenticated;

+ (SCHAuthenticationManager *)sharedAuthenticationManager;

- (void)authenticateWithUserName:(NSString *)userName withPassword:(NSString *)password;
- (void)authenticate;
- (BOOL)hasUsernameAndPassword;
- (void)clear;

@end

#endif