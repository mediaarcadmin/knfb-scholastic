//
//  SCHDrmSession.h
//  Scholastic
//
//  Created by Arnold Chien on 3/13/11.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KNFBDrmBookDecrypter.h"

static NSString * const kSCHDrmErrorDomain = @"DrmErrorDomain";
static NSInteger const kSCHDrmInitializationError = 2000;
static NSInteger const kSCHDrmNetworkError = 2001;
static NSInteger const kSCHDrmRegistrationError = 2002;
static NSInteger const kSCHDrmDeregistrationError = 2003;
static NSInteger const kSCHDrmLicenseAcquisitionError = 2004;

#if UATSERVER
static NSString* const drmServerUrl = @"http://plr.uat.cld.libredigital.com/rightsmanager.asmx";
#else
static NSString* const drmServerUrl = @"http://plr.devint.cld.libredigital.com/rightsmanager.asmx";
#endif

#define MAX_URL_SIZE	1024

typedef enum  {
	SCHDrmSoapActionAcquireLicense = 0,
    SCHDrmSoapActionJoinDomain,
    SCHDrmSoapActionLeaveDomain,
	SCHDrmSoapActionAcknowledgeLicense,
} SCHDrmSoapActionType;

struct SCHDrmIVars;

@class SCHBookIdentifier;

// Do not instantiate this class.
@interface SCHDrmSession : NSObject {
	struct SCHDrmIVars *drmIVars; 
}
- (id)initWithBook:(SCHBookIdentifier*)identifier;
- (NSError*)drmError:(NSInteger)errCode message:(NSString*)message;

@end


@protocol SCHDrmRegistrationSessionDelegate;

@interface SCHDrmRegistrationSession : SCHDrmSession   
{ 
    id<SCHDrmRegistrationSessionDelegate> delegate;
    BOOL isJoining;
    NSURLConnection *urlConnection;
    NSMutableData *connectionData;
}

@property (nonatomic, retain) id<SCHDrmRegistrationSessionDelegate> delegate;

- (void)registerDevice:(NSString *)token;
- (void)deregisterDevice:(NSString *)token;

@end


@protocol SCHDrmLicenseAcquisitionSessionDelegate;

@interface SCHDrmLicenseAcquisitionSession : SCHDrmSession      
{ 
    id<SCHDrmLicenseAcquisitionSessionDelegate> delegate;
}

@property (nonatomic, retain) id<SCHDrmLicenseAcquisitionSessionDelegate> delegate;

- (void)acquireLicense:(NSString *)token bookID:(SCHBookIdentifier *)identifier;

@end

@interface SCHDrmDecryptionSession : SCHDrmSession<KNFBDrmBookDecrypter>   
{ 
}

@end
 
 
