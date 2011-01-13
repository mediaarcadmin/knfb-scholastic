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

- (void)reportFault:(SOAPFault *)fault forMethod:(NSString *)method
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
						 userInfo:userInfo]];
	}
}

#pragma mark -
#pragma mark API Proxy methods

- (BOOL)isOperational
{
    Reachability *internetReach = [Reachability reachabilityForInternetConnection];
	
	return([internetReach isReachable]);	
}

@end
