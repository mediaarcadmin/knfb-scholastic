//
//  SCHAuthenticationManagerProtected.h
//  Scholastic
//
//  Created by John S. Eddie on 11/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

@class SCHScholasticWebService;
@class SCHLibreAccessWebService;
@class SCHDrmRegistrationSession;

// Constants
extern NSString * const kSCHAuthenticationManagerUsername;
extern NSString * const kSCHAuthenticationManagerServiceName;

extern NSTimeInterval const kSCHAuthenticationManagerSecondsInAMinute;

@interface SCHAuthenticationManager ()

@property (nonatomic, copy, readwrite) NSString *aToken;
@property (nonatomic, retain) NSDate *tokenExpires;
@property (nonatomic, assign) BOOL waitingOnResponse;
@property (nonatomic, retain) SCHScholasticWebService *scholasticWebService;
@property (nonatomic, retain) SCHLibreAccessWebService *libreAccessWebService;
@property (nonatomic, retain) SCHDrmRegistrationSession *drmRegistrationSession;

- (void)authenticateOnMainThread;
- (void)clearOnMainThread;
- (void)clearAppProcessingOnMainThread;

- (void)postSuccessWithOfflineMode:(BOOL)offlineMode;
- (void)postFailureWithError:(NSError *)error;

@end