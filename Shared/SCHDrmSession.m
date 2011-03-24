//
//  SCHDrmSession.m
//  Scholastic
//
//  Created by Arnold Chien on 3/13/11.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHDrmSession.h"
 
@implementation SCHDrmSession 

@synthesize sessionInitialized, connectionData, urlConnection;

-(void) dealloc {
	self.connectionData = nil;
	self.urlConnection = nil;
	[super dealloc];
}

- (NSError*)drmError:(NSInteger)errCode message:(NSString*)message {
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:message
														 forKey:NSLocalizedDescriptionKey];
	return [NSError errorWithDomain:@"kSCHDrmErrorDomain" code:errCode userInfo:userInfo];
}


- (NSMutableURLRequest *)createDrmRequest:(const void*)msg messageSize:(NSUInteger)msgSize  url:(NSString*)url soapAction:(SCHDrmSoapActionType)action {
	
	NSMutableURLRequest *aRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
	
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

@end
