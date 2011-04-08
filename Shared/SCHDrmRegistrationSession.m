//
//  SCHDrmRegistrationSession.m
//  Scholastic
//
//  Created by John S. Eddie on 10/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHDrmRegistrationSession.h"
#import "SCHDrmRegistrationSessionDelegate.h"
#import "DrmGlobals.h"

@interface SCHDrmRegistrationSession ()

struct SCHDrmIVars {
    DRM_APP_CONTEXT* drmAppContext;
    DRM_BYTE drmRevocationBuffer[REVOCATION_BUFFER_SIZE];
};

- (void)callSuccessDelegate:(NSString *)deviceKey;
- (void)callFailureDelegate:(NSError *)error;

@end

@implementation SCHDrmRegistrationSession 

@synthesize delegate, isJoining;

-(void) dealloc {
	Drm_Uninitialize(drmIVars->drmAppContext); 
	Oem_MemFree(drmIVars->drmAppContext);    
    free(drmIVars);
	self.delegate = nil;
	[super dealloc];
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
	}
	
ErrorExit:
	if ( dr != DRM_SUCCESS ) {
		NSLog(@"DRM initialization error: %08X",dr);
		self.sessionInitialized = NO;
		return;
	}
	self.sessionInitialized = YES;
}

-(id)init 
{
    if((self = [super init])) {
		self.connectionData = [NSMutableData dataWithCapacity:7000];
		drmIVars = calloc(1, sizeof(struct SCHDrmIVars));
        [self initialize];
    }
    return self;
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

- (void)emptyGUID:(DRM_GUID*)guid {
    guid->Data1 = 0;
    guid->Data2 = 0;
    guid->Data3 = 0;
    for (int i=0; i<8; ++i)
        guid->Data4[i] = 0;
}


- (void)registerDevice:(NSString*)token {
	DRM_RESULT dr = DRM_SUCCESS;
    DRM_DOMAIN_ID domainID;
    DRM_DWORD cbChallenge = 0;
    DRM_BYTE *pbChallenge = NULL;
	 
	if ( !self.sessionInitialized ) {
        //NSLog(@"DRM error: cannot join domain because DRM is not initialized.");
		[self callFailureDelegate:[self drmError:kSCHDrmInitializationError 
										 message:@"Cannot join domain because DRM is not initialized."]];
        return;
    }
	
	if ( token == nil ) {
		//NSLog(@"DRM error attempting to join domain outside login session.");
		[self callFailureDelegate:[self drmError:kSCHDrmInitializationError 
										 message:@"Cannot join domain because not user is not logged in."]];
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
		
	NSLog(@"DRM join domain challenge: %s",(unsigned char*)pbChallenge);
	NSMutableURLRequest* request = [self createDrmRequest:(const void*)pbChallenge 
											messageSize:(NSUInteger)cbChallenge
													url:drmServerUrl
											soapAction:SCHDrmSoapActionJoinDomain];
	
	self.urlConnection = [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
	if (!self.urlConnection)
	{
		//NSLog(@"Failed to created url connection for join domain request.");
		[self callFailureDelegate:[self drmError:kSCHDrmNetworkError 
										 message:@"Cannot join domain because connection can't be created."]];
		return;
	}
	self.isJoining = YES;
    
ErrorExit:
	if ( pbChallenge )
		Oem_MemFree(pbChallenge);
	// Standard success values.
	if ( !DRM_SUCCEEDED(dr)  ) {
		NSLog(@"DRM error joining domain: %08X", dr);
		[self callFailureDelegate:[self drmError:kSCHDrmRegistrationError 
									 message:@"Cannot join domain because of DRM error."]];
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
										 message:@"Cannot leave domain because DRM is not initialized."]];
        return;
    }
	
	if ( token == nil ) {
		//NSLog(@"DRM error: attempting to leave domain outside login session.");
		[self callFailureDelegate:[self drmError:kSCHDrmInitializationError 
										 message:@"Cannot leave domain because user is not logged in."]];
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
												 message:@"Cannot leave domain because no domain has been joined."]];
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
	DRM_CHAR* customData = (DRM_CHAR*)[[[[NSString stringWithString:@"<CustomData><AuthToken>"] 
										 stringByAppendingString:token] 
										stringByAppendingString:@"</AuthToken></CustomData>"]
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
	
	NSLog(@"DRM leave domain challenge: %s",(unsigned char*)pbChallenge);
	NSMutableURLRequest* request = [self createDrmRequest:(const void*)pbChallenge 
											  messageSize:(NSUInteger)cbChallenge
													  url:drmServerUrl
											   soapAction:SCHDrmSoapActionLeaveDomain];
	
	self.urlConnection = [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
	if (!self.urlConnection)
	{
		//NSLog(@"Failed to created url connection for join domain request.");
		[self callFailureDelegate:[self drmError:kSCHDrmNetworkError 
										 message:@"Cannot leave domain because connection can't be created."]];
		return;
	}
	self.isJoining = NO;
    
ErrorExit:
	
	if ( pbChallenge )
		Oem_MemFree(pbChallenge);
	if ( !DRM_SUCCEEDED(dr)  ) {
		NSLog(@"DRM error leaving domain: %08X", dr);
		[self callFailureDelegate:[self drmError:kSCHDrmRegistrationError 
										 message:@"Cannot leave domain because of DRM error."]];
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
										 message:@"DRM domain request failed because of invalid url."]];
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
										 message:@"DRM domain request failed because of null server response."]];
		return;
	} 
	else {
		pbResponse = (DRM_BYTE*)[drmResponse bytes];
		cbResponse = [drmResponse length];
		pbResponse[cbResponse] = '\0';
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
		NSLog(@"Message from DRM server: %08X", dr2);
		if (self.isJoining) {
			// Retrieve the device ID.
			NSString* deviceID = [self getTagValue:[NSString stringWithCString:(const char*)pbResponse encoding:NSUTF8StringEncoding]
										xmlTag:@"ClientId"];
			[self callSuccessDelegate:deviceID];
			return;
		}
		else {
			[self callSuccessDelegate:nil];
			return;
		}
	}
	if (self.isJoining) {
		NSLog(@"DRM error joining domain: %08X", dr);
		[self callFailureDelegate:[self drmError:kSCHDrmRegistrationError 
												  message:@"Cannot join domain because of DRM error."]];
	}
	else {
		NSLog(@"DRM error leaving domain: %08X", dr);
		[self callFailureDelegate:[self drmError:kSCHDrmRegistrationError 
												  message:@"Cannot leave domain because of DRM error."]];
	}
	
}

- (void)callSuccessDelegate:(NSString *)deviceKey
{
    if([(id)self.delegate respondsToSelector:@selector(registrationSession:didComplete:)] == YES) {
		[(id)self.delegate registrationSession:self didComplete:deviceKey];

    }        
}

- (void)callFailureDelegate:(NSError *)error
{
    if([(id)self.delegate respondsToSelector:@selector(registrationSession:didFailWithError:)] == YES) {
        [(id)self.delegate registrationSession:self didFailWithError:error];		
    }	    
}

@end

/*
#pragma mark -
#pragma mark SCHDrmLicAcquisitionSession

@interface SCHDrmLicAcquisitionSession ()

- (void)callSuccessDelegate;
- (void)callFailureDelegate:(NSError *)error;

@end

@implementation SCHDrmLicAcquisitionSession 


@synthesize bookID, delegate;

-(void) dealloc {
	Drm_Uninitialize(drmIVars->drmAppContext); 
	Oem_MemFree(drmIVars->drmAppContext);    
    free(drmIVars);
	self.bookID = nil;
	self.delegate = nil;
	[super dealloc];
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

-(id)initWithBook:(NSString*)isbn
{
    if((self = [super init])) {
		self.bookID = isbn;
		self.connectionData = [NSMutableData dataWithCapacity:7000];
		drmIVars = calloc(1, sizeof(struct SCHDrmIVars));
        [self initialize];
    }
    return self;
}

- (void)acquireLicense:(NSString *)token {
}


- (void)callSuccessDelegate
{
    //if([(id)self.delegate respondsToSelector:@selector(registrationSession:didComplete:)] == YES) {
	//	[(id)self.delegate registrationSession:self didComplete:deviceKey];
	
    //}        
}

- (void)callFailureDelegate:(NSError *)error
{
	// if([(id)self.delegate respondsToSelector:@selector(registrationSession:didFailWithError:)] == YES) {
    //    [(id)self.delegate registrationSession:self didFailWithError:error];		
    //}	    
}

@end

*/