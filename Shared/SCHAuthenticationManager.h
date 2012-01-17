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

typedef enum {
	SCHAuthenticationManagerConnectivityModeAuthenticationError = -1,
    SCHAuthenticationManagerConnectivityModeUnknown = 0,
	SCHAuthenticationManagerConnectivityModeOnline,
	SCHAuthenticationManagerConnectivityModeOfflineNoConnectivity,
	SCHAuthenticationManagerConnectivityModeOfflineAwaitingAppVersion,    
	SCHAuthenticationManagerConnectivityModeOfflineOutdatedAppVersionRequiringUpdate,        
} SCHAuthenticationManagerConnectivityMode;

typedef void (^SCHAuthenticationSuccessBlock)(SCHAuthenticationManagerConnectivityMode connectivityMode);
typedef void (^SCHAuthenticationFailureBlock)(NSError *error);
typedef void (^SCHDrmRegistrationSuccessBlock)(NSString *deviceKey);
typedef void (^SCHDrmRegistrationFailureBlock)(NSError *error);
typedef void (^SCHDrmDeregistrationSuccessBlock)(void);
typedef void (^SCHDrmDeregistrationFailureBlock)(NSError *error);

extern NSString * const SCHAuthenticationManagerReceivedServerDeregistrationNotification;

extern NSString * const kSCHAuthenticationManagerErrorDomain;
extern NSInteger const kSCHAuthenticationManagerGeneralError;
extern NSInteger const kSCHAuthenticationManagerLoginError;
extern NSInteger const kSCHAuthenticationManagerOfflineError;

@interface SCHAuthenticationManager : NSObject <BITAPIProxyDelegate, SCHDrmRegistrationSessionDelegate>  
{
}

// returns nil if the previous aToken expired
@property (nonatomic, copy, readonly) NSString *aToken;
@property (nonatomic, assign, readonly) BOOL isAuthenticated;

+ (SCHAuthenticationManager *)sharedAuthenticationManager;

- (BOOL)hasUsernameAndPassword;
- (NSString *)pToken;
- (NSURL *)webParentToolURL:(NSString *)pToken;
- (void)clear;
- (void)clearAppProcessing;

- (void)authenticateWithUser:(NSString *)userName 
                    password:(NSString *)password
                successBlock:(SCHAuthenticationSuccessBlock)successBlock
                failureBlock:(SCHAuthenticationFailureBlock)failureBlock
 waitUntilVersionCheckIsDone:(BOOL)wait;

// authenticateWithSuccessBlock:failureBlock: is effectively re-entrant
// success and failure blocks are nested if authentication is already taking place
- (void)authenticateWithSuccessBlock:(SCHAuthenticationSuccessBlock)successBlock
                        failureBlock:(SCHAuthenticationFailureBlock)failureBlock;

- (void)authenticateWithSuccessBlock:(SCHAuthenticationSuccessBlock)successBlock
                        failureBlock:(SCHAuthenticationFailureBlock)failureBlock
         waitUntilVersionCheckIsDone:(BOOL)wait;

- (void)deregisterWithSuccessBlock:(SCHDrmDeregistrationSuccessBlock)successBlock
                      failureBlock:(SCHDrmDeregistrationFailureBlock)failureBlock;

- (void)forceDeregistrationWithCompletionBlock:(SCHDrmDeregistrationSuccessBlock)completionBlock;

- (void)expireToken;

@end
