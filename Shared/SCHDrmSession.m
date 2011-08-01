//
//  SCHDrmSession.m
//  Scholastic
//
//  Created by Arnold Chien on 3/13/11.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHDrmSession.h"
#import "SCHDrmRegistrationSessionDelegate.h"
#import "SCHDrmLicenseAcquisitionSessionDelegate.h"
#import "SCHBookManager.h"
#import "SCHBookIdentifier.h"
#import "SCHXPSProvider.h"
#import "KNFBXPSConstants.h"
#import "DrmGlobals.h"

struct SCHDrmIVars {
    DRM_APP_CONTEXT* drmAppContext;
    DRM_BYTE drmRevocationBuffer[REVOCATION_BUFFER_SIZE];
    DRM_DECRYPT_CONTEXT  drmDecryptContext;
};

@interface SCHDrmSession()

@property (nonatomic, assign) BOOL sessionInitialized;
@property (nonatomic, retain) SCHBookIdentifier* bookID;
@property (nonatomic, retain) SCHBookIdentifier* boundBookID;
@property (nonatomic, retain) NSString* serverResponse;

@end

#pragma mark -
@implementation SCHDrmSession 

@synthesize sessionInitialized, bookID, boundBookID, serverResponse;

-(void) dealloc {
	Drm_Uninitialize(drmIVars->drmAppContext); 
	Oem_MemFree(drmIVars->drmAppContext);    
    free(drmIVars);
	self.bookID = nil;
	[super dealloc];
}

- (DRM_RESULT)setHeaderForBookWithID:(SCHBookIdentifier *)aBookID {
	DRM_RESULT dr = DRM_SUCCESS;
	
	SCHXPSProvider *xpsProvider = [[SCHBookManager sharedBookManager] threadSafeCheckOutXPSProviderForBookIdentifier:aBookID];
    NSData *headerData = [xpsProvider dataForComponentAtPath:KNFBXPSKNFBDRMHeaderFile];
    [[SCHBookManager sharedBookManager] checkInXPSProviderForBookIdentifier:aBookID];
    
	unsigned char* headerBuff = (unsigned char*)[headerData bytes]; 
	ChkDR( Drm_Content_SetProperty( drmIVars->drmAppContext,
								   DRM_CSP_AUTODETECT_HEADER,
								   headerBuff,   
								   [headerData length] ) );
    
    self.bookID = aBookID;
    
ErrorExit:
	return dr;
}

 - (void)initialize {
 
     // Data store.
     DRM_CONST_STRING  dstrDataStoreFile = CREATE_DRM_STRING( HDS_STORE_FILE );
     dstrDataStoreFile.pwszString = [DrmGlobals getDrmGlobals].dataStore.pwszString;
     dstrDataStoreFile.cchString = [DrmGlobals getDrmGlobals].dataStore.cchString;
 
     // Initialize the session.
     drmIVars->drmAppContext = Oem_MemAlloc( SIZEOF( DRM_APP_CONTEXT ) );
     DRM_RESULT dr = DRM_SUCCESS;	
     @synchronized (self) {
         ChkDR( Drm_Initialize( drmIVars->drmAppContext,
                               NULL,
                               &dstrDataStoreFile ) );
 
         ChkDR( Drm_Revocation_SetBuffer( drmIVars->drmAppContext, 
                                         drmIVars->drmRevocationBuffer, 
                                         SIZEOF(drmIVars->drmRevocationBuffer)));
 
         if ( self.bookID != nil )
            ChkDR( [self setHeaderForBookWithID:self.bookID] );
     }
 
 ErrorExit:
     if ( dr != DRM_SUCCESS ) {
         NSLog(@"DRM initialization error: %08X",dr);
         self.sessionInitialized = NO;
         return;
     }
     self.sessionInitialized = YES;
}
 
 

-(id)initWithBook:(SCHBookIdentifier*)identifier
{
    if((self = [super init])) {
		self.bookID = identifier;
		drmIVars = calloc(1, sizeof(struct SCHDrmIVars));
        [self initialize];
    }
    return self;
}

- (NSError*)drmError:(NSInteger)errCode message:(NSString*)message {
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:message
														 forKey:NSLocalizedDescriptionKey];
	return [NSError errorWithDomain:@"kSCHDrmErrorDomain" code:errCode userInfo:userInfo];
}


- (NSMutableURLRequest *)createDrmRequest:(const void*)msg messageSize:(NSUInteger)msgSize  url:(NSString*)url soapAction:(SCHDrmSoapActionType)action {
	
	NSMutableURLRequest *aRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
	
    NSLog(@"DRM using: %@", drmServerUrl);
    
	[aRequest setHTTPMethod:@"POST"];
	[aRequest setValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
	[aRequest setValue:@"*/*" forHTTPHeaderField:@"Accept"];
	[aRequest setValue:@"Microsoft-PlayReady-DRM/1.0" forHTTPHeaderField:@"User-Agent"];
	
	if ( action == SCHDrmSoapActionAcquireLicense ) 
		[aRequest setValue:@"http://schemas.microsoft.com/DRM/2007/03/protocols/AcquireLicense" forHTTPHeaderField:@"SoapAction"];
	else if ( action == SCHDrmSoapActionJoinDomain ) 
		[aRequest setValue:@"http://schemas.microsoft.com/DRM/2007/03/protocols/JoinDomain" forHTTPHeaderField:@"SoapAction"];
	else if ( action == SCHDrmSoapActionLeaveDomain ) 
		[aRequest setValue:@"http://schemas.microsoft.com/DRM/2007/03/protocols/LeaveDomain" forHTTPHeaderField:@"SoapAction"];
	else if ( action == SCHDrmSoapActionAcknowledgeLicense ) 
		[aRequest setValue:@"http://schemas.microsoft.com/DRM/2007/03/protocols/AcknowledgeLicense" forHTTPHeaderField:@"SoapAction"];
	
	[aRequest setValue:[NSString stringWithFormat:@"%d",msgSize] forHTTPHeaderField:@"Content-Length"];
	[aRequest setHTTPBody:[NSData dataWithBytes:(const void*)msg length:(NSUInteger)msgSize]];		
	
	return [aRequest autorelease]; 
}

- (void)emptyGUID:(DRM_GUID*)guid {
    guid->Data1 = 0;
    guid->Data2 = 0;
    guid->Data3 = 0;
    for (int i=0; i<8; ++i)
        guid->Data4[i] = 0;
}

// Instead of parsing...
- (NSString*)getTagValue:(NSString*)xmlStr xmlTag:(NSString*)tag {
	NSString* beginTag = @"&lt;";
	beginTag = [[beginTag stringByAppendingString:tag] stringByAppendingString:@"&gt;"];
	NSRange beginTagRange = [xmlStr rangeOfString:beginTag]; 
	if ( beginTagRange.location != NSNotFound ) {
		NSString* endTag = @"&lt;/";
		endTag = [[endTag stringByAppendingString:tag] stringByAppendingString:@"&gt;"];
		NSRange endTagRange = [xmlStr rangeOfString:endTag]; 
		if ( endTagRange.location != NSNotFound ) {
			NSRange valRange;
			valRange.location = beginTagRange.location + beginTagRange.length;
			valRange.length = endTagRange.location - valRange.location;
			return [xmlStr substringWithRange:valRange];
		}
	}
	return nil;
}

- (NSString*)getPriorityError:(DRM_RESULT)result {
	if (result==DRM_E_SERVER_COMPUTER_LIMIT_REACHED || result==DRM_E_SERVER_DEVICE_LIMIT_REACHED) {
        return NSLocalizedString(@"You are at your limit of five registered devices.  You must deregister another device before you can register this one.",@"Device limit message.");
	}
	else if (result==DRM_E_LICEVAL_LICENSE_REVOKED) { 
		return NSLocalizedString(@"The license for one your books has been revoked.",@"License revocation message.");
	}
	else if (result==DRM_E_CERTIFICATE_REVOKED) {
		return NSLocalizedString(@"A certificate on your device has been revoked.",@"Certificate revocation message.");
	}
	else if (result==DRM_E_DEVCERT_REVOKED) {
		return NSLocalizedString(@"Your device certificate has been revoked.",@"Device certificate revocation message.");
	}
	else if (result==DRM_E_LICENSEEXPIRED) {
		return NSLocalizedString(@"The license for this book has expired.",@"Expired license message.");
	}
	else if (result==DRM_E_LICENSENOTFOUND) {
		return NSLocalizedString(@"This book is not licensed.",@"Missing license message.");
	}
    else if (result==DRM_E_XMLNOTFOUND) {
        return [self getTagValue:self.serverResponse xmlTag:@"Message"];
    }
	return nil;
}

@end

@interface SCHDrmRegistrationSession ()

- (void)callSuccessDelegate:(NSString *)deviceKey;
- (void)callFailureDelegate:(NSError *)error;

@end


@interface SCHDrmRegistrationSession()

@property (nonatomic, assign) BOOL isJoining;
@property (nonatomic, retain) NSURLConnection *urlConnection;
@property (nonatomic, retain) NSMutableData *connectionData;

@end
 
#pragma mark -
@implementation SCHDrmRegistrationSession 

@synthesize delegate, isJoining, connectionData, urlConnection;

-(void) dealloc {
	self.urlConnection = nil;
	self.connectionData = nil;
	self.delegate = nil;
	[super dealloc];
}

-(id)init 
{
    if((self = [super init])) {
        self.bookID = nil;
		self.connectionData = [NSMutableData dataWithCapacity:7000];
		drmIVars = calloc(1, sizeof(struct SCHDrmIVars));
        [self initialize];
    }
    return self;
}

- (void)registerDevice:(NSString*)token {
	DRM_RESULT dr = DRM_SUCCESS;
    DRM_DOMAIN_ID domainID;
    DRM_DWORD cbChallenge = 0;
    DRM_BYTE *pbChallenge = NULL;
	 
	if ( !self.sessionInitialized ) {
        //NSLog(@"DRM error: cannot join domain because DRM is not initialized.");
		[self callFailureDelegate:[self drmError:kSCHDrmInitializationError 
										 message:NSLocalizedString(@"Cannot register device because DRM is not initialized.",@"DRM initialization error message")]];
        return;
    }
	
	if ( token == nil ) {
		//NSLog(@"DRM error attempting to join domain outside login session.");
		[self callFailureDelegate:[self drmError:kSCHDrmInitializationError 
										 message:NSLocalizedString(@"Cannot register device because login is required.",@"DRM login requirement message")]];
		return;
	}
	 
	NSString* iosPlatform = [[[UIDevice currentDevice] model] stringByAppendingString:
							 [[UIDevice currentDevice] systemVersion]];
	NSString* beginTags = @"<CustomData><AuthToken>";
	NSString* middleTags = @"</AuthToken><devicePlatform>";
	NSString* endTags = @"</devicePlatform></CustomData>";
	
	DRM_CHAR* customData = (DRM_CHAR*)[[[[[[NSString stringWithString:beginTags] 
										   stringByAppendingString:token] 
										  stringByAppendingString:middleTags]
										 stringByAppendingString:iosPlatform]
										stringByAppendingString:endTags]
									   UTF8String];
	
	DRM_DWORD customDataSz = (DRM_DWORD)([beginTags length] + [middleTags length] + [endTags length] + [iosPlatform length] + [token length]);
	
    dr = Drm_JoinDomain_GenerateChallenge( drmIVars->drmAppContext,
										  DRM_REGISTER_NULL_DATA,
										  &domainID,
										  NULL,
										  0,
										  customData,
										  customDataSz,
										  pbChallenge,
										  &cbChallenge );
 
	
    if( dr == DRM_E_BUFFERTOOSMALL )
    {
        [self emptyGUID:&domainID.m_oServiceID];
        [self emptyGUID:&domainID.m_oAccountID];
        domainID.m_dwRevision = 0;
        
		ChkMem( pbChallenge = Oem_MemAlloc( cbChallenge ) );
        ChkDR( Drm_JoinDomain_GenerateChallenge( drmIVars->drmAppContext,
												DRM_REGISTER_NULL_DATA,
												&domainID,
												NULL,
												0,
												customData,
												customDataSz,
												pbChallenge,
												&cbChallenge ) );
 
    }
    else
    {
        ChkDR( dr );
    }
		
	//NSLog(@"DRM join domain challenge: %s",(unsigned char*)pbChallenge);
	NSMutableURLRequest* request = [self createDrmRequest:(const void*)pbChallenge 
											messageSize:(NSUInteger)cbChallenge
													url:drmServerUrl
											soapAction:SCHDrmSoapActionJoinDomain];
	
	self.urlConnection = [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
	if (!self.urlConnection)
	{
		//NSLog(@"Failed to created url connection for join domain request.");
		[self callFailureDelegate:[self drmError:kSCHDrmNetworkError 
										 message:NSLocalizedString(@"Cannot register device because connection can't be created.",@"DRM connection error message")]];
		return;
	}
	self.isJoining = YES;
    
ErrorExit:
	if ( pbChallenge )
		Oem_MemFree(pbChallenge);    
	if ( !DRM_SUCCEEDED(dr)  ) {
		//NSLog(@"DRM error joining domain: %08X", dr);
		[self callFailureDelegate:[self drmError:kSCHDrmRegistrationError 
                                         message:[NSString stringWithFormat:NSLocalizedString(@"Cannot register device because of DRM error: %08X",@"Generic registration error message"),dr]]];
	}
 
}

- (void)deregisterDevice:(NSString*)token {

	DRM_RESULT dr = DRM_SUCCESS;
    DRM_DWORD cbChallenge = 0;
    DRM_BYTE *pbChallenge = NULL;
	DRM_DOMAIN_CERT_ENUM_CONTEXT  oDomainCertEnumContext = { 0 };
    DRM_DOMAINCERT_INFO           oDomainCertInfo        = { 0 };
    DRM_DWORD                     cchDomainCert          = 0;
	
	if ( !self.sessionInitialized ) {
        //NSLog(@"DRM error: cannot leave domain because DRM is not initialized.");
		[self callFailureDelegate:[self drmError:kSCHDrmInitializationError 
                                        message:NSLocalizedString(@"Cannot deregister device because DRM is not initialized.",@"DRM initialization error message")]];
        return;
    }
	
	if ( token == nil ) {
		//NSLog(@"DRM error: attempting to leave domain outside login session.");
		[self callFailureDelegate:[self drmError:kSCHDrmInitializationError 
										 message:NSLocalizedString(@"Cannot deregister device because login is required.",@"DRM login requirement message")]];
		return;
	}
	
	// Find the domain id from the domain certificate.  
	ChkDR( Drm_DomainCert_InitEnum( drmIVars->drmAppContext,
								   &oDomainCertEnumContext ) );
	for ( int i=0; ; ++i )
    {
        dr = Drm_DomainCert_EnumNext( &oDomainCertEnumContext,
									 &cchDomainCert,
									 &oDomainCertInfo );
        if ( dr == DRM_E_NOMORE )
        {
			if ( i==0 ) {
				//NSLog(@"DRM error: attempting to leave domain when no domain has been joined.");
				[self callFailureDelegate:[self drmError:kSCHDrmInitializationError 
                                                 message:NSLocalizedString(@"Cannot deregister device because device is not registered.",@"DRM deregistration requires registration message")]];
				return;
			}
			else if ( i== 1 ) {
				dr = DRM_SUCCESS;
				break;
			}
			else {
				// Not clear if this would be a failure.  Assume not for now.
				NSLog(@"DRM warning: there's more than one domain certificate in the store.");
				dr = DRM_SUCCESS;
				break;
			}
        }
        else {
            ChkDR( dr );
		}
		
	}
	 
	NSString* beginTags = @"<CustomData><AuthToken>";
	NSString* endTags = @"</AuthToken></CustomData>";
	DRM_CHAR* customData = (DRM_CHAR*)[[[[NSString stringWithString:beginTags] 
										 stringByAppendingString:token] 
										stringByAppendingString:endTags]
									   UTF8String];
	DRM_DWORD customDataSz = (DRM_DWORD)([beginTags length] + [endTags length] + [token length]);
	
	dr = Drm_LeaveDomain_GenerateChallenge( drmIVars->drmAppContext,
										   DRM_REGISTER_NULL_DATA,
										   &oDomainCertInfo.m_oDomainID,
										   customData,
										   customDataSz,
										   pbChallenge,
										   &cbChallenge );
	
    if( dr == DRM_E_BUFFERTOOSMALL )
    {
		ChkMem( pbChallenge = Oem_MemAlloc( cbChallenge ) );
		// This returns 8004C509, DRM_E_DOMAIN_NOT_FOUND, if you're not joined to a domain
		// or if the domain ID is bad.
        ChkDR( Drm_LeaveDomain_GenerateChallenge( drmIVars->drmAppContext,
												 DRM_REGISTER_NULL_DATA,
												 &oDomainCertInfo.m_oDomainID,
												 customData,
												 customDataSz,
												 pbChallenge,
												 &cbChallenge ) );
    }
    else
    {
        ChkDR( dr );
    }
	
	//NSLog(@"DRM leave domain challenge: %s",(unsigned char*)pbChallenge);
	NSMutableURLRequest* request = [self createDrmRequest:(const void*)pbChallenge 
											  messageSize:(NSUInteger)cbChallenge
													  url:drmServerUrl
											   soapAction:SCHDrmSoapActionLeaveDomain];
	
	self.urlConnection = [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
	if (!self.urlConnection)
	{
		[self callFailureDelegate:[self drmError:kSCHDrmNetworkError 
										 message:NSLocalizedString(@"Cannot deregister device because connection can't be created.",@"DRM connection error message")]];
		return;
	}
	self.isJoining = NO;
    
ErrorExit:
	
	if ( pbChallenge )
		Oem_MemFree(pbChallenge);
	if ( !DRM_SUCCEEDED(dr)  ) {
		//NSLog(@"DRM error leaving domain: %08X", dr);
		[self callFailureDelegate:[self drmError:kSCHDrmRegistrationError 
										 message:[NSString stringWithFormat:NSLocalizedString(@"Cannot deregister device because of DRM error: %08X",@"Generic deregistration error message"),dr]]];
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[self callFailureDelegate:[self drmError:kSCHDrmNetworkError 
											  message:[error localizedDescription]]];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)aResponse
{
	if ([aResponse expectedContentLength] < 0)
	{
		[self.urlConnection cancel];
		[self callFailureDelegate:[self drmError:kSCHDrmNetworkError 
										message:NSLocalizedString(@"Cannot register device because URL is invalid.",@"DRM invalid url message")]];
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[self.connectionData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	DRM_RESULT dr = DRM_SUCCESS;
	DRM_RESULT dr2 = DRM_SUCCESS;
    DRM_BYTE *pbResponse = NULL;
    DRM_DWORD cbResponse = 0;
    DRM_DOMAIN_ID domainIdReturned = {{ 0 }};
	
	NSData *drmResponse = self.connectionData;
	if (drmResponse == nil) {
		// This would be weird.
		[self callFailureDelegate:[self drmError:kSCHDrmRegistrationError 
										 message:NSLocalizedString(@"Cannot register device because the server did not respond.",@"Unresponsive license server message.")]];
		return;
	} 
	else {
		pbResponse = (DRM_BYTE*)[drmResponse bytes];
		cbResponse = [drmResponse length];
		pbResponse[cbResponse] = '\0';
        self.serverResponse = [NSString stringWithCString:(const char*)pbResponse encoding:NSUTF8StringEncoding];
	}
	if (self.isJoining) {
		NSLog(@"DRM join domain response: %s",(unsigned char*)pbResponse);
        @synchronized (self) {
            ChkDR( Drm_JoinDomain_ProcessResponse( drmIVars->drmAppContext,
                                                  pbResponse,
                                                  cbResponse,
                                                  &dr2,
                                                  &domainIdReturned ) );
        }
	}
	else {
		NSLog(@"DRM leave domain response: %s",(unsigned char*)pbResponse);
		@synchronized (self) {
			ChkDR( Drm_LeaveDomain_ProcessResponse( drmIVars->drmAppContext,
												   pbResponse,
												   cbResponse,
												   &dr2 ) );
		}
	}
	
ErrorExit:
	if ( DRM_SUCCEEDED(dr)  ) {		
		NSLog(@"Success message from DRM server: %08X", dr2);
		if (self.isJoining) {
			// Retrieve the device ID.
			NSString* deviceID = [self getTagValue:self.serverResponse  //[NSString stringWithCString:(const char*)pbResponse encoding:NSUTF8StringEncoding]
										xmlTag:@"ClientId"];
			[self callSuccessDelegate:deviceID];
		}
		else {
			[self callSuccessDelegate:nil];
		}
        return;
	}
    // Errors that require specific description.
    NSString* priorityErr = [self getPriorityError:dr2];
    if (!priorityErr)
        priorityErr = [self getPriorityError:dr];
    if (priorityErr) {
		[self callFailureDelegate:[self drmError:kSCHDrmRegistrationError 
                                         message:priorityErr]];
        return;
    }
    // Errors for which we only report a code.
	if (self.isJoining) {
		//NSLog(@"DRM error joining domain: %08X", dr);
		[self callFailureDelegate:[self drmError:kSCHDrmRegistrationError 
                                         message:[NSString stringWithFormat:NSLocalizedString(@"Cannot register device because of DRM error: %08X",@"Generic registration error message"),dr]]];
	}
	else {
		//NSLog(@"DRM error leaving domain: %08X", dr);
		[self callFailureDelegate:[self drmError:kSCHDrmRegistrationError 
                                         message:[NSString stringWithFormat:NSLocalizedString(@"Cannot deregister device because of DRM error: %08X",@"Generic deregistration error message"),dr]]];
	}
	
}

- (void)callSuccessDelegate:(NSString *)deviceKey
{
    if([(id)delegate respondsToSelector:@selector(registrationSession:didComplete:)] == YES) {
		[(id)delegate registrationSession:self didComplete:deviceKey];

    }        
}

- (void)callFailureDelegate:(NSError *)error
{
    if([(id)delegate respondsToSelector:@selector(registrationSession:didFailWithError:)] == YES) {
        [(id)delegate registrationSession:self didFailWithError:error];		
    }	    
}

@end
 

@interface SCHDrmLicenseAcquisitionSession ()

- (void)callSuccessDelegate;
- (void)callFailureDelegate:(NSError *)error;

//@property (nonatomic, retain) id<SCHDrmLicenseAcquisitionSessionDelegate> delegate;

@end

#pragma mark -
@implementation SCHDrmLicenseAcquisitionSession 

@synthesize delegate;

-(void) dealloc {
	self.delegate = nil;
	[super dealloc];
}

- (void)acknowledgeLicense:(DRM_LICENSE_RESPONSE*)licenseResponse {
	
    DRM_RESULT dr = DRM_SUCCESS;
    DRM_BYTE *pbChallenge = NULL;
    DRM_DWORD cbChallenge = 0;
    DRM_BYTE *pbResponse = NULL;
    DRM_DWORD cbResponse = 0;
	
	dr = Drm_LicenseAcq_GenerateAck( drmIVars->drmAppContext, licenseResponse, pbChallenge, &cbChallenge );
	if ( dr == DRM_E_BUFFERTOOSMALL )
	{
		pbChallenge = Oem_MemAlloc( cbChallenge );
		ChkDR( Drm_LicenseAcq_GenerateAck( drmIVars->drmAppContext, licenseResponse, pbChallenge, &cbChallenge ));
	}
	else
	{
		ChkDR( dr );
	}
	
	//NSLog(@"DRM license acknowledgment challenge: %s",(unsigned char*)pbChallenge);

    NSMutableURLRequest* request = [self createDrmRequest:(const void*)pbChallenge 
                                              messageSize:(NSUInteger)cbChallenge
                                                      url:drmServerUrl
                                               soapAction:SCHDrmSoapActionAcknowledgeLicense];
    NSURLResponse* urlResponse;
    NSError* err = nil;
    NSData* responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&err];
    if (responseData == nil) {
		NSLog(@"License could not be acknowledged because the server did not respond.");
		return;
	} 
    else if (err != nil) {
		NSLog(@"License could not be acknowledged: %@", [err localizedDescription]);
		return;
	}
	else {
		pbResponse = (DRM_BYTE*)[responseData bytes];
		cbResponse = [responseData length];
		pbResponse[cbResponse] = '\0';
	}
    
    
	NSLog(@"DRM license acknowledgment response: %s",(unsigned char*)pbResponse);
	@synchronized (self) {
		ChkDR( Drm_LicenseAcq_ProcessAckResponse(drmIVars->drmAppContext, pbResponse, cbResponse, NULL) );
	}
	
ErrorExit:
	if ( pbChallenge )
		Oem_MemFree(pbChallenge);
    if ( !DRM_SUCCEEDED(dr)  ) 
        NSLog(@"Cannot acknowledge license because of DRM error: %08X",dr);
	
}

- (void)acquireLicense:(NSString *)token bookID:(SCHBookIdentifier*)identifier {
    DRM_RESULT dr = DRM_SUCCESS;
    DRM_CHAR rgchURL[MAX_URL_SIZE];
    DRM_DWORD cchUrl = MAX_URL_SIZE;
    DRM_BYTE *pbChallenge = NULL;
    DRM_DWORD cbChallenge = 0;
    DRM_DOMAIN_ID domainID;
    DRM_BYTE *pbResponse = NULL;
    DRM_DWORD cbResponse = 0;
    DRM_LICENSE_RESPONSE oLicenseResponse = {0};
	
	if ( token == nil ) {
		NSLog(@"DRM error attempting to acquire license outside login session.");
		return;
	}
	
    NSString* tags1 = @"<CustomData><AuthToken>";
	NSString* tags2 = @"</AuthToken><ContentIdentifier>";
    NSString* tags3 = @"</ContentIdentifier><ContentIdentifierType>";
    NSString* tags4 = @"</ContentIdentifierType></CustomData>";
	
	DRM_CHAR* customData = (DRM_CHAR*)[[[[[[[[NSString stringWithString:tags1] 
										   stringByAppendingString:token] 
                                            stringByAppendingString:tags2]
                                           stringByAppendingString:identifier.isbn]
                                         stringByAppendingString:tags3]
                                        stringByAppendingString:@"ISBN13"]
                                        stringByAppendingString:tags4]
									   UTF8String];
	DRM_DWORD customDataSz = (DRM_DWORD)([tags1 length] + [tags2 length] + [tags3 length] + [tags4 length] + [identifier.isbn length] + [token length] + 6);
    
    [self emptyGUID:&domainID.m_oServiceID];
    [self emptyGUID:&domainID.m_oAccountID];
    domainID.m_dwRevision = 0;
    
	dr = Drm_LicenseAcq_GenerateChallenge( drmIVars->drmAppContext,
										  NULL,
										  0,
										  &domainID,
										  customData,
										  customDataSz,
										  rgchURL,
										  &cchUrl,
										  NULL,
										  0,
										  pbChallenge,
										  &cbChallenge );
	
    
	
    if( dr == DRM_E_BUFFERTOOSMALL )
    {        
		pbChallenge = Oem_MemAlloc( cbChallenge );
        ChkDR( Drm_LicenseAcq_GenerateChallenge( drmIVars->drmAppContext,
												NULL,
												0,
												&domainID,
												customData,
												customDataSz,
												rgchURL,
												&cchUrl,
												NULL,
												0,
												pbChallenge,
												&cbChallenge ) );
    }
    else
    {
        ChkDR( dr );
    }
    
	//NSLog(@"DRM license challenge: %s",(unsigned char*)pbChallenge);
    
    NSMutableURLRequest* request = [self createDrmRequest:(const void*)pbChallenge 
                                              messageSize:(NSUInteger)cbChallenge
                                                      url:drmServerUrl
                                               soapAction:SCHDrmSoapActionAcquireLicense];
    
    NSURLResponse* urlResponse;
    NSError* err = nil;
    NSData* responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&err];
    if (responseData == nil) {
		[self callFailureDelegate:[self drmError:kSCHDrmLicenseAcquisitionError 
										 message:NSLocalizedString(@"License could not be acquired because the server did not respond.",@"Unresponsive license server message.")]];
		return;
	} 
    else if (err != nil) {
		[self callFailureDelegate:[self drmError:kSCHDrmLicenseAcquisitionError 
										 message:[err localizedDescription]]];
		return;
	}
	else {
		pbResponse = (DRM_BYTE*)[responseData bytes];
		cbResponse = [responseData length];
		pbResponse[cbResponse] = '\0';
	}
    
    NSLog(@"DRM license acquisition response: %s",(unsigned char*)pbResponse);
    @synchronized (self) {
        ChkDR( Drm_LicenseAcq_ProcessResponse( drmIVars->drmAppContext,
                                              NULL,
                                              NULL,
                                              pbResponse,
                                              cbResponse,
                                              &oLicenseResponse ) );
    }
    
    ChkDR( oLicenseResponse.m_dwResult );
    for( int idx = 0; idx < oLicenseResponse.m_cAcks; idx++ )
        ChkDR( oLicenseResponse.m_rgoAcks[idx].m_dwResult );
    
    // Failure of acknowledgment does not entail failure of acquisition,
    // so we do not check a returned code.
    [self acknowledgeLicense:&oLicenseResponse];
	
ErrorExit:
	if ( pbChallenge )
		Oem_MemFree(pbChallenge);
    
    if ( DRM_SUCCEEDED(dr)  ) {	
        [self callSuccessDelegate];
        return;
    }
    
    // Errors that require specific description.
    NSString* priorityErr = [self getPriorityError:dr];
    if (priorityErr) {
		[self callFailureDelegate:[self drmError:kSCHDrmLicenseAcquisitionError 
                                         message:priorityErr]];
        return;
    }
    // Errors for which we only report a code.
    [self callFailureDelegate:[self drmError:kSCHDrmLicenseAcquisitionError
                                     message:[NSString stringWithFormat:NSLocalizedString(@"Cannot acquire license because of DRM error: %08X",@"Generic license acquisition error message"),dr]]];
    
}


- (void)callSuccessDelegate
{
    if([(id)self.delegate respondsToSelector:@selector(licenseAcquisitionSession:didComplete:)] == YES) {
		[(id)self.delegate licenseAcquisitionSession:self didComplete:nil];
	
    }        
}

- (void)callFailureDelegate:(NSError *)error
{
	if([(id)self.delegate respondsToSelector:@selector(licenseAcquisitionSession:didFailWithError:)] == YES) {
        [(id)self.delegate licenseAcquisitionSession:self didFailWithError:error];		
    }	    
}

@end

#pragma mark -
@implementation SCHDrmDecryptionSession 

- (BOOL)reportReading {
    NSLog(@"Report reading for book with ID %@", self.bookID);
    
    if ( !self.sessionInitialized ) {
        NSLog(@"DRM error: cannot report reading because DRM is not initialized.");
        return NO;
    }
    
    DRM_RESULT dr = DRM_SUCCESS;   
	@synchronized (self) {		
		ChkDR( Drm_Reader_Commit( drmIVars->drmAppContext,
								 NULL, 
								 NULL ) ); 
	}
ErrorExit:
	if (dr != DRM_SUCCESS) {
		NSLog(@"DRM commit error: %08X",dr);
		
        return NO;
	}
    return YES;
}

- (BOOL)bindToLicense {
    if ( !self.sessionInitialized ) {
        NSLog(@"DRM error: cannot bind to license because DRM is not initialized.");
        return FALSE;
    }
    DRM_RESULT dr = DRM_SUCCESS;
	if ( ![self.boundBookID isEqual:self.bookID] ) { 
		// Search for a license to bind to with the Read right.
		const DRM_CONST_STRING *rgpdstrRights[1] = {0};
		DRM_CONST_STRING readRight;
		readRight.pwszString = [DrmGlobals getDrmGlobals].readRight.pwszString;
		readRight.cchString = [DrmGlobals getDrmGlobals].readRight.cchString;
		// Roundabout assignment needed to get around compiler complaint.
		rgpdstrRights[0] = &readRight; 
		int bufferSz = __CB_DECL(SIZEOF(DRM_CIPHER_CONTEXT));
		for (int i=0;i<bufferSz;++i)
			(drmIVars->drmDecryptContext).rgbBuffer[i] = 0;
		ChkDR( Drm_Reader_Bind( drmIVars->drmAppContext,
							   rgpdstrRights,
							   NO_OF(rgpdstrRights),
							   NULL, 
							   NULL,
							   &drmIVars->drmDecryptContext ) );
		self.boundBookID = self.bookID;
	}
	
ErrorExit:
	//if ([self checkPriorityError:dr])
	//	return NO;
	if (dr != DRM_SUCCESS) {
		NSLog(@"DRM bind error: %08X",dr);
		self.bookID = nil;
		self.boundBookID = nil;
		return NO;
	}
    return YES;
}

- (BOOL)decryptData:(NSData *)data {
    if ( !self.sessionInitialized ) {
        NSLog(@"DRM error: content cannot be decrypted because DRM is not initialized.");
        return FALSE;
    }
    
    DRM_RESULT dr = DRM_SUCCESS;
	
	DRM_AES_COUNTER_MODE_CONTEXT oCtrContext = {0};
	unsigned char* dataBuff = (unsigned char*)[data bytes]; 
	ChkDR(Drm_Reader_Decrypt (&drmIVars->drmDecryptContext,
							  &oCtrContext,
							  dataBuff, 
							  [data length]));
	// At this point, the buffer is PlayReady-decrypted.
	
ErrorExit:
	if (dr != DRM_SUCCESS) {
		NSLog(@"DRM decryption error: %08X",dr);
		self.bookID = nil;
		self.boundBookID = nil;
		return NO;
	}
    // This XOR step is to undo an additional encryption step that was needed for .NET environment.
    for (int i=0;i<[data length];++i)
        dataBuff[i] ^= 0xA0;
    return YES;    
}

@end

