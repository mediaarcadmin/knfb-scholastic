//
//  SCHDrmRegistrationSessionDelegate.h
//  Scholastic
//
//  Created by John S. Eddie on 10/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SCHDrmRegistrationSession;

@protocol SCHDrmRegistrationSessionDelegate

- (void)registrationSession:(SCHDrmRegistrationSession *)registrationSession registrationDidComplete:(NSString *)deviceKey;
- (void)registrationSession:(SCHDrmRegistrationSession *)registrationSession registrationDidFailWithError:(NSError *)error;
- (void)registrationSession:(SCHDrmRegistrationSession *)registrationSession deregistrationDidComplete:(NSString *)deviceKey;
- (void)registrationSession:(SCHDrmRegistrationSession *)registrationSession deregistrationDidFailWithError:(NSError *)error;

@end
