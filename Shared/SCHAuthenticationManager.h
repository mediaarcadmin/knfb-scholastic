//
//  SCHAuthenticationManager.h
//  Scholastic
//
//  Created by John S. Eddie on 21/01/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

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

@private
	BOOL waitingOnResponse;
	SCHScholasticWebService *scholasticWebService;
	SCHLibreAccessWebService *libreAccessWebService;
}


@property (nonatomic, retain) NSString *aToken;
@property (nonatomic, retain) NSDate *tokenExpires;
@property (nonatomic, readonly) BOOL isAuthenticated;


+ (SCHAuthenticationManager *)sharedAuthenticationManager;

- (BOOL)authenticateWithUserName:(NSString *)userName withPassword:(NSString *)password;
- (BOOL)authenticate;
- (BOOL)hasUsernameAndPassword;
- (BOOL)isAuthenticated;
- (void)clear;

@end
