//
//  SCHDrmSession.h
//  Scholastic
//
//  Created by Arnold Chien on 3/13/11.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const kSCHDrmErrorDomain = @"DrmErrorDomain";
static NSInteger const kSCHDrmInitializationError = 2000;
static NSInteger const kSCHDrmNetworkError = 2001;
static NSInteger const kSCHDrmRegistrationError = 2002;
static NSInteger const kSCHDrmDeregistrationError = 2003;
static NSInteger const kSCHDrmLicenseAcquisitionError = 2004;

#if SERVEROVERRIDE
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

// Do not instantiate this class.
@interface SCHDrmSession : NSObject {
	
}

@property (nonatomic, assign) BOOL sessionInitialized;
@property (nonatomic, retain) NSURLConnection *urlConnection;
@property (nonatomic, retain) NSMutableData *connectionData;

- (NSMutableURLRequest *)createDrmRequest:(const void*)msg messageSize:(NSUInteger)msgSize  url:(NSString*)url soapAction:(SCHDrmSoapActionType)action;
- (NSError*)drmError:(NSInteger)errCode message:(NSString*)message;


@end
