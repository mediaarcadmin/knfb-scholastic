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
