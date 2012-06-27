//
//  SCHScholasticAuthenticationWebService.m
//  Scholastic
//
//  Created by John S. Eddie on 21/12/2010.
//  Copyright 2010 BitWink. All rights reserved.
//

#import "SCHScholasticAuthenticationWebService.h"

#import "BITAPIError.h"
#import "BITNetworkActivityManager.h"
#import "TouchXML.h"
#import "AuthenticateSvc+Binding.h"

// ProcessRemote Constants
NSString * const kSCHScholasticAuthenticationWebServiceProcessRemote = @"processRemote";
NSString * const kSCHScholasticAuthenticationWebServicePToken = @"pToken";

static NSString * const kSCHScholasticAuthenticationWebServiceAttribute = @"//attribute";
static NSString * const kSCHScholasticAuthenticationWebServiceAttributeName = @"name";
static NSString * const kSCHScholasticAuthenticationWebServiceAttributeValue = @"value";
static NSString * const kSCHScholasticAuthenticationWebServiceAttributeToken = @"token";
static NSString * const kSCHScholasticAuthenticationWebServiceAttributeErrorCode = @"errorCode";
static NSString * const kSCHScholasticAuthenticationWebServiceAttributeErrorDesc = @"errorDesc";

/*
 * This class is thread safe when using the Thread Confinement design pattern.
 */

@interface SCHScholasticAuthenticationWebService ()

@property (nonatomic, retain) AuthenticateSoap11Binding *binding;

- (NSString *)parseToken:(NSString *)responseXML error:(NSError **)error;

@end


@implementation SCHScholasticAuthenticationWebService

@synthesize binding;

#pragma mark - Object lifecycle

- (id)init
{
	self = [super init];
	if (self != nil) {
		binding = [[AuthenticateSvc SCHAuthenticateSoap11Binding] retain];
		binding.logXMLInOut = NO;		
	}
	
	return(self);
}

- (void)dealloc
{
    [binding clearBindingOperations]; // Will invalidate the delegate on any underway operations        
	[binding release], binding = nil;
	
	[super dealloc];
}

#pragma mark - API Proxy methods

- (void)authenticateUserName:(NSString *)userName withPassword:(NSString *)password
{	
	AuthenticateSvc_processRemote *request = [AuthenticateSvc_processRemote new];
	
    userName = [userName stringByEscapingXML];
    password = [password  stringByEscapingXML];
    
	request.SPSWSXML = [NSString stringWithFormat:@"<SchWS><attribute name=\"clientID\" value=\"KNFB\"/><attribute name=\"isSingleToken\" value=\"true\"/><attribute name=\"userName\" value=\"%@\"/><attribute name=\"password\" value=\"%@\"/></SchWS>",
                        (userName == nil ? @"" : userName), (password == nil ? @"" : password)];
	
	[self.binding processRemoteAsyncUsingParameters:request delegate:self]; 
	[[BITNetworkActivityManager sharedNetworkActivityManager] showNetworkActivityIndicator];
	
	[request release], request = nil;
}

#pragma mark - AuthenticateSoap12BindingResponse Delegate methods

- (void)operation:(AuthenticateSoap11BindingOperation *)operation completedWithResponse:(AuthenticateSoap11BindingResponse *)response
{	
	[[BITNetworkActivityManager sharedNetworkActivityManager] hideNetworkActivityIndicator];
	
	if (operation.response.error != nil) {
        if ([(id)self.delegate respondsToSelector:@selector(method:didFailWithError:requestInfo:result:)]) {
            [(id)self.delegate method:kSCHScholasticAuthenticationWebServiceProcessRemote didFailWithError:[self confirmErrorDomain:operation.response.error 
                                                                                                                      forDomainName:@"AuthenticateSoap11BindingResponseHTTP"] 
                          requestInfo:nil result:nil];
        }
	} else {		
		for (id bodyPart in response.bodyParts) {
			if ([bodyPart isKindOfClass:[SOAPFault class]]) {
				[self reportFault:(SOAPFault *)bodyPart forMethod:kSCHScholasticAuthenticationWebServiceProcessRemote requestInfo:nil];
				continue;
			}
			
			if ([bodyPart isKindOfClass:[AuthenticateSvc_processRemoteResponse class]]) {
				AuthenticateSvc_processRemoteResponse *processRemoteResponse = (AuthenticateSvc_processRemoteResponse *)bodyPart;
				NSError *error = nil;
				NSString *token = [self parseToken:processRemoteResponse.return_ error:&error];
				
				if (token == nil) {
					if([(id)self.delegate respondsToSelector:@selector(method:didFailWithError:requestInfo:result:)]) {
						[(id)self.delegate method:kSCHScholasticAuthenticationWebServiceProcessRemote didFailWithError:error 
                                      requestInfo:nil 
                                           result:nil];
					}
				} else if([(id)self.delegate respondsToSelector:@selector(method:didCompleteWithResult:userInfo:)]) {					
                    NSDate *serverDate = [self.rfc822DateFormatter dateFromString:[operation.responseHeaders objectForKey:@"Date"]];
                    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:(double)operation.serverDateDelta], @"serverDateDelta",
                                              (serverDate == nil ? (id)[NSNull null] : serverDate), @"serverDate",
                                              nil];
                                
					[(id)self.delegate method:kSCHScholasticAuthenticationWebServiceProcessRemote didCompleteWithResult:
					 [NSDictionary dictionaryWithObject:token forKey:kSCHScholasticAuthenticationWebServicePToken]
                                     userInfo:userInfo];
				}
			}
		}
	}
}

#pragma mark -
#pragma mark Private methods

- (NSString *)parseToken:(NSString *)responseXML error:(NSError **)error
{
	CXMLDocument *doc = [[CXMLDocument alloc] initWithXMLString:responseXML options:0 error:error];
	NSArray *nodes = nil;
	NSString *ret = nil;
	NSString *errorCode = nil;
	NSString *errorDescription = nil;
	
	if (*error == nil) {
		nodes = [doc nodesForXPath:kSCHScholasticAuthenticationWebServiceAttribute error:error];
		if (*error == nil) {		
			for (CXMLElement *node in nodes) {
				NSString *attributeName = [[node attributeForName:kSCHScholasticAuthenticationWebServiceAttributeName] stringValue];
				
				if (attributeName != nil) {
                    if ([attributeName caseInsensitiveCompare:kSCHScholasticAuthenticationWebServiceAttributeToken] == NSOrderedSame) {
                        ret = [[node attributeForName:kSCHScholasticAuthenticationWebServiceAttributeValue] stringValue];
                        break;
                    } else if ([attributeName caseInsensitiveCompare:kSCHScholasticAuthenticationWebServiceAttributeErrorCode] == NSOrderedSame) {
                        errorCode = [[node attributeForName:kSCHScholasticAuthenticationWebServiceAttributeValue] stringValue];
                    }
                    else if ([attributeName caseInsensitiveCompare:kSCHScholasticAuthenticationWebServiceAttributeErrorDesc] == NSOrderedSame) {
                        errorDescription = [[node attributeForName:kSCHScholasticAuthenticationWebServiceAttributeValue] stringValue];
                    }		
                }
			}	
		}
	}
	
    if (errorCode != nil || ret == nil) {
        SCHScholasticAuthenticationWebServiceErrorCode tokenErrorCode = (errorCode == nil ? 
                                                                         kSCHScholasticAuthenticationWebServiceErrorCodeUnknown : 
                                                                         [errorCode integerValue]);
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:(errorDescription == nil ? 
                                                                     @"An unknown error occured" : 
                                                                     errorDescription)
                                                             forKey:NSLocalizedDescriptionKey];		
        
        *error = [NSError errorWithDomain:kBITAPIErrorDomain 
                                     code:tokenErrorCode
                                 userInfo:userInfo];
	}
	
	[doc release], doc = nil;
	
	return(ret);
}

@end
