//
//  SCHScholasticWebService.m
//  TestWSDL2ObjC
//
//  Created by John S. Eddie on 21/12/2010.
//  Copyright 2010 BitWink. All rights reserved.
//

#import "SCHScholasticWebService.h"

#import "BITAPIError.h"
#import "BITNetworkActivityManager.h"
#import "TouchXML.h"

// ProcessRemote Constants
NSString * const kSCHScholasticWebServiceProcessRemote = @"processRemote";
NSString * const kSCHScholasticWebServicePToken = @"pToken";

static NSString * const kSCHScholasticWebServiceAttribute = @"//attribute";
static NSString * const kSCHScholasticWebServiceAttributeName = @"name";
static NSString * const kSCHScholasticWebServiceAttributeValue = @"value";
static NSString * const kSCHScholasticWebServiceAttributeToken = @"token";
static NSString * const kSCHScholasticWebServiceAttributeErrorCode = @"errorCode";
static NSString * const kSCHScholasticWebServiceAttributeErrorDesc = @"errorDesc";

/*
 * This class is thread safe when using the Thread Confinement design pattern.
 */

@interface SCHScholasticWebService ()

@property (nonatomic, retain) AuthenticateSoap11Binding *binding;

- (NSString *)parseToken:(NSString *)responseXML error:(NSError **)error;

@end


@implementation SCHScholasticWebService

@synthesize binding;

#pragma mark - Object lifecycle

- (id)init
{
	self = [super init];
	if (self != nil) {
		binding = [[AuthenticateSvc AuthenticateSoap11Binding] retain];
		binding.logXMLInOut = NO;		
	}
	
	return(self);
}

- (void)dealloc
{
	[binding release], binding = nil;
	
	[super dealloc];
}

#pragma mark - API Proxy methods

- (void)authenticateUserName:(NSString *)userName withPassword:(NSString *)password
{	
	AuthenticateSvc_processRemote *request = [AuthenticateSvc_processRemote new];
	
	request.SPSWSXML = [NSString stringWithFormat:@"<SchWS><attribute name=\"clientID\" value=\"KNFB\"/><attribute name=\"isSingleToken\" value=\"true\"/><attribute name=\"userName\" value=\"%@\"/><attribute name=\"password\" value=\"%@\"/></SchWS>", (userName == nil ? @"" : userName), (password == nil ? @"" : password)];
	
	[self.binding processRemoteAsyncUsingParameters:request delegate:self]; 
	[[BITNetworkActivityManager sharedNetworkActivityManager] showNetworkActivityIndicator];
	
	[request release], request = nil;
}

#pragma mark - AuthenticateSoap12BindingResponse Delegate methods

- (void)operation:(AuthenticateSoap11BindingOperation *)operation completedWithResponse:(AuthenticateSoap11BindingResponse *)response
{	
	[[BITNetworkActivityManager sharedNetworkActivityManager] hideNetworkActivityIndicator];
	
	if (operation.response.error != nil && [(id)self.delegate respondsToSelector:@selector(method:didFailWithError:requestInfo:)]) {
		[(id)self.delegate method:kSCHScholasticWebServiceProcessRemote didFailWithError:operation.response.error requestInfo:nil];
	} else {		
		for (id bodyPart in response.bodyParts) {
			if ([bodyPart isKindOfClass:[SOAPFault class]]) {
				[self reportFault:(SOAPFault *)bodyPart forMethod:kSCHScholasticWebServiceProcessRemote requestInfo:nil];
				continue;
			}
			
			if ([bodyPart isKindOfClass:[AuthenticateSvc_processRemoteResponse class]]) {
				AuthenticateSvc_processRemoteResponse *processRemoteResponse = (AuthenticateSvc_processRemoteResponse *)bodyPart;
				NSError *error = nil;
				NSString *token = [self parseToken:processRemoteResponse.return_ error:&error];
				
				if (token == nil) {
					if([(id)self.delegate respondsToSelector:@selector(method:didFailWithError:requestInfo:)]) {
						[(id)self.delegate method:kSCHScholasticWebServiceProcessRemote didFailWithError:error requestInfo:nil];
					}
				} else if([(id)self.delegate respondsToSelector:@selector(method:didCompleteWithResult:)]) {					
					[(id)self.delegate method:kSCHScholasticWebServiceProcessRemote didCompleteWithResult:
					 [NSDictionary dictionaryWithObject:token forKey:kSCHScholasticWebServicePToken]];
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
		nodes = [doc nodesForXPath:kSCHScholasticWebServiceAttribute error:error];
		if (*error == nil) {		
			for (CXMLElement *node in nodes) {
				NSString *attributeName = [[node attributeForName:kSCHScholasticWebServiceAttributeName] stringValue];
				
				if ([attributeName caseInsensitiveCompare:kSCHScholasticWebServiceAttributeToken] == NSOrderedSame) {
					ret = [[node attributeForName:kSCHScholasticWebServiceAttributeValue] stringValue];
					break;
				}
				else if ([attributeName caseInsensitiveCompare:kSCHScholasticWebServiceAttributeErrorCode] == NSOrderedSame) {
					errorCode = [[node attributeForName:kSCHScholasticWebServiceAttributeValue] stringValue];
				}
				else if ([attributeName caseInsensitiveCompare:kSCHScholasticWebServiceAttributeErrorDesc] == NSOrderedSame) {
					errorDescription = [[node attributeForName:kSCHScholasticWebServiceAttributeValue] stringValue];
				}		
			}	
		}
	}
	
	if (errorCode != nil) {
		NSDictionary *userInfo = nil;
		
		if (errorDescription != nil) {
			userInfo = [NSDictionary dictionaryWithObject:errorDescription
												   forKey:NSLocalizedDescriptionKey];		
		}
		
		*error = [NSError errorWithDomain:kBITAPIErrorDomain 
									code:[errorCode integerValue]
								userInfo:userInfo];
	}
	
	[doc release], doc = nil;
	
	return(ret);
}


@end
