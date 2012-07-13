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

@synthesize rfc822DateFormatter;

#pragma mark - Object lifecycle

- (void)dealloc
{
	[rfc822DateFormatter release], rfc822DateFormatter = nil;
    
	[super dealloc];
}

#pragma mark - Accessor methods

- (NSDateFormatter *)rfc822DateFormatter
{
    if (rfc822DateFormatter == nil) {
        rfc822DateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *en_US_POSIX = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease];
        [rfc822DateFormatter setLocale:en_US_POSIX];
        [rfc822DateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss zzz"]; 
    }
    
    return rfc822DateFormatter;
}

#pragma mark - methods

- (void)reportFault:(SOAPFault *)fault forMethod:(NSString *)method requestInfo:(NSDictionary *)requestInfo
{
	if (fault != nil && [(id)self.delegate respondsToSelector:@selector(method:didFailWithError:requestInfo:result:)] == YES) {
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
                  forDomainName:(NSString *)domainName
{
    NSError *ret = error;
    
    // if this is a SOAP error domain and not a connectivity error domain change
    // the domain to BITAPIError and move the technical description to faliure 
    // reason replacing with user facing text
    if (domainName != nil &&
        [[error domain] isEqualToString:domainName] == YES) {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        
        if ([error userInfo] != nil) {
            NSString *originalLocalizedDescription = [[error userInfo] objectForKey:NSLocalizedDescriptionKey];
            
            [userInfo addEntriesFromDictionary:[error userInfo]];
            if (originalLocalizedDescription != nil) {
                [userInfo setObject:originalLocalizedDescription forKey:NSLocalizedFailureReasonErrorKey];
            }
        }
        
        [userInfo setObject:NSLocalizedString(@"A problem occured talking to the server.", nil) forKey:NSLocalizedDescriptionKey];
        
        ret = [NSError errorWithDomain:kBITAPIErrorDomain 
                                    code:[error code] 
                                userInfo:[NSDictionary dictionaryWithDictionary:userInfo]];
    }
    
    return ret;
}

- (id)fromObjectTranslate:(id)anObject
{
	static Class boolClass = nil;
	id ret = nil;
	
	if (boolClass == nil) {
		boolClass = [[[NSNumber numberWithBool:YES] class] retain];
	}
	
	if (anObject != nil) {
		if (anObject == [NSNull null]) {
			ret = nil;
		} else if ([anObject isKindOfClass:boolClass] == YES) {
			ret = [[[USBoolean alloc] initWithBool:[anObject boolValue]] autorelease];
		} else {
			ret = anObject;
		}
	}
	
	return(ret);
}

#pragma mark -
#pragma mark API Proxy methods

- (BOOL)isOperational
{
    Reachability *internetReach = [Reachability reachabilityForInternetConnection];
	
	return([internetReach isReachable]);	
}

@end
