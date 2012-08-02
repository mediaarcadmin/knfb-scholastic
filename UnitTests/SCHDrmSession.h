//
//  SCHDrmSession.h
//  Scholastic
//
//  Created by Matt Farrugia on 31/07/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KNFBDrmBookDecrypter.h"

static NSString * const kSCHDrmErrorDomain = @"DrmErrorDomain";
static NSInteger const kSCHDrmInitializationError = 2000;
static NSInteger const kSCHDrmNetworkError = 2001;
static NSInteger const kSCHDrmRegistrationError = 2002;
static NSInteger const kSCHDrmDeregistrationError = 2003;
static NSInteger const kSCHDrmLicenseAcquisitionError = 2004;
static NSInteger const kSCHDrmDeviceLimitError = 2005;
static NSInteger const kSCHDrmDeviceRegisteredToAnotherDevice = 50;
static NSInteger const kSCHDrmDeviceUnableToAssign = 144;

static NSString* const drmServerUrl = DRM_RIGHTSMANAGER_SERVER;

typedef enum  {
	SCHDrmSoapActionAcquireLicense = 0,
    SCHDrmSoapActionJoinDomain,
    SCHDrmSoapActionLeaveDomain,
	SCHDrmSoapActionAcknowledgeLicense,
} SCHDrmSoapActionType;

struct SCHDrmIVars;

@class SCHBookIdentifier;

@interface SCHDrmSession : NSObject
@end

@protocol SCHDrmRegistrationSessionDelegate;

@interface SCHDrmRegistrationSession : SCHDrmSession
@end


@protocol SCHDrmLicenseAcquisitionSessionDelegate;
@interface SCHDrmLicenseAcquisitionSession : SCHDrmSession
@end

@interface SCHDrmDecryptionSession : SCHDrmSession<KNFBDrmBookDecrypter>
@end
