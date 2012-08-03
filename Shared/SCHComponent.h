//
//  SCHComponent.h
//  Scholastic
//
//  Created by John S. Eddie on 04/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SCHComponentDelegate.h"
#import "BITAPIProxyDelegate.h"
#import "SCHAuthenticationManager.h"

@interface SCHComponent : NSObject <BITAPIProxyDelegate> 
{
}

@property (assign, nonatomic) id<SCHComponentDelegate> delegate;	

- (void)clearComponent;

- (void)completeWithSuccessMethod:(NSString *)method 
                           result:(NSDictionary *)result 
                         userInfo:(NSDictionary *)userInfo
                 notificationName:(NSString *)notificationName
             notificationUserInfo:(NSDictionary *)notificationUserInfo;
- (void)completeWithFailureMethod:(NSString *)method 
                            error:(NSError *)error 
                      requestInfo:(NSDictionary *)requestInfo 
                           result:(NSDictionary *)result
                 notificationName:(NSString *)notificationName
             notificationUserInfo:(NSDictionary *)notificationUserInfo;

@end
