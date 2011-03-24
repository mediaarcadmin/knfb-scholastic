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

- (void)registrationSession:(SCHDrmRegistrationSession *)registrationSession didComplete:(NSString *)deviceKey;
- (void)registrationSession:(SCHDrmRegistrationSession *)registrationSession didFailWithError:(NSError *)error;

@end
