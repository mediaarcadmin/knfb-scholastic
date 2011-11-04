//
//  SCHAuthenticationManagerProtected.h
//  Scholastic
//
//  Created by John S. Eddie on 11/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

@class SCHAccountValidation;
@class SCHLibreAccessWebService;
@class SCHDrmRegistrationSession;

// Constants
extern NSString * const kSCHAuthenticationManagerServiceName;

extern NSTimeInterval const kSCHAuthenticationManagerSecondsInAMinute;

@interface SCHAuthenticationManager ()

@property (nonatomic, copy, readwrite) NSString *aToken;
@property (nonatomic, retain) NSDate *tokenExpires;
@property (nonatomic, assign) BOOL waitingOnResponse;
@property (nonatomic, retain) SCHAccountValidation *accountValidation;
@property (nonatomic, retain) SCHLibreAccessWebService *libreAccessWebService;
@property (nonatomic, retain) SCHDrmRegistrationSession *drmRegistrationSession;

@property (nonatomic, copy) SCHAuthenticationSuccessBlock authenticationSuccessBlock;
@property (nonatomic, copy) SCHAuthenticationFailureBlock authenticationFailureBlock;

- (void)clearOnMainThread;
- (void)clearAppProcessingOnMainThread;

- (void)authenticationDidSucceedWithOfflineMode:(BOOL)offlineMode;
- (void)authenticationDidFailWithError:(NSError *)error;

@end