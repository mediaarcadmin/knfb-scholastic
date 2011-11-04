//
//  BITSOAPProxy.m
//  WebAPI
//
//  Created by John S. Eddie on 21/12/2010.
//  Copyright 2010 BitWink. All rights reserved.
//

#import "BITSOAPProxy.h"

#import "USAdditions.h"
#import "Reachability.h"
#import "BITAPIError.h"

@implementation BITSOAPProxy

- (void)reportFault:(SOAPFault *)fault forMethod:(NSString *)method requestInfo:(NSDictionary *)requestInfo
{
	if (fault != nil && [(id)self.delegate respondsToSelector:@selector(method:didFailWithError:)] == YES) {
		NSDictionary *userInfo = nil;

		if (fault.simpleFaultString != nil) {
			userInfo = [NSDictionary dictionaryWithObject:fault.simpleFaultString
												   forKey:NSLocalizedDescriptionKey];		
		}

		[(id)self.delegate method:method didFailWithError:
		 [NSError errorWithDomain:kBITAPIErrorDomain 
							 code:kBITAPIFaultError 
						 userInfo:userInfo]
                      requestInfo:requestInfo
                           result:nil];
	}
}

- (NSError *)confirmErrorDomain:(NSError *)error
{
    // if this is a SOAP error domain  and not a connectivity error domain 
    // change the domain to BITAPIError
    if ([[error domain] isEqualToString:@"LibreAccessServiceSoap11BindingResponseHTTP"] == YES) {
        error = [NSError errorWithDomain:kBITAPIErrorDomain 
                                    code:[error code] 
                                userInfo:[error userInfo]];
    }
    
    return error;
}

#pragma mark -
#pragma mark API Proxy methods

- (BOOL)isOperational
{
    Reachability *internetReach = [Reachability reachabilityForInternetConnection];
	
	return([internetReach isReachable]);	
}

@end
