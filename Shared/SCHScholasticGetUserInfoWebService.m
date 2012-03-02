//
//  SCHScholasticGetUserInfoWebService.m
//  Scholastic
//
//  Created by John Eddie on 21/02/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHScholasticGetUserInfoWebService.h"

#import "BITAPIError.h"
#import "BITNetworkActivityManager.h"
#import "TouchXML.h"

// ProcessRemote Constants
NSString * const kSCHScholasticGetUserInfoWebServiceProcessRemote = @"processRemote";
NSString * const kSCHScholasticGetUserInfoWebServiceCOPPA = @"COPPA";

static NSString * const kSCHScholasticGetUserInfoWebServiceAttribute = @"//attribute";
static NSString * const kSCHScholasticGetUserInfoWebServiceAttributeName = @"name";
static NSString * const kSCHScholasticGetUserInfoWebServiceAttributeValue = @"value";
static NSString * const kSCHScholasticGetUserInfoWebServiceAttributeCOPPA_FLAG_KEY = @"COPPA_FLAG_KEY";
static NSString * const kSCHScholasticGetUserInfoWebServiceAttributeErrorCode = @"errorCode";
static NSString * const kSCHScholasticGetUserInfoWebServiceAttributeErrorDesc = @"errorDesc";

@interface SCHScholasticGetUserInfoWebService ()

@property (nonatomic, retain) GetUserInfoSoap11Binding *binding;

- (NSString *)parseToken:(NSString *)responseXML error:(NSError **)error;

@end

@implementation SCHScholasticGetUserInfoWebService

@synthesize binding;

#pragma mark - Object lifecycle

- (id)init
{
	self = [super init];
	if (self != nil) {
		binding = [[GetUserInfoSvc GetUserInfoSoap11Binding] retain];
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

- (void)getUserInfo:(NSString *)token
{	
	GetUserInfoSvc_processRemote *request = [GetUserInfoSvc_processRemote new];
	
	request.SPSWSXML = [NSString stringWithFormat:@"<SchWS><attribute name=\"clientID\" value=\"LD\"/><attribute name=\"isSingleToken\" value=\"true\"/><attribute name=\"token\" value=\"%@\"/><attribute name=\"requestedProps\" value=\"COPPA_FLAG_KEY\"/></SchWS>", (token == nil ? @"" : token)];
    
	[self.binding processRemoteAsyncUsingParameters:request delegate:self]; 
	[[BITNetworkActivityManager sharedNetworkActivityManager] showNetworkActivityIndicator];
	
	[request release], request = nil;
}

#pragma mark - GetUserInfoSoap11BindingResponse Delegate methods

- (void)operation:(GetUserInfoSoap11BindingOperation *)operation completedWithResponse:(GetUserInfoSoap11BindingResponse *)response
{	
	[[BITNetworkActivityManager sharedNetworkActivityManager] hideNetworkActivityIndicator];
	
	if (operation.response.error != nil) {
        if ([(id)self.delegate respondsToSelector:@selector(method:didFailWithError:requestInfo:result:)]) {
            [(id)self.delegate method:kSCHScholasticGetUserInfoWebServiceProcessRemote didFailWithError:[self confirmErrorDomain:operation.response.error 
                                                                                                                   forDomainName:@"GetUserInfoServiceSoap11BindingResponseHTTP"] 
                          requestInfo:nil result:nil];
        }
	} else {		
		for (id bodyPart in response.bodyParts) {
			if ([bodyPart isKindOfClass:[SOAPFault class]]) {
				[self reportFault:(SOAPFault *)bodyPart forMethod:kSCHScholasticGetUserInfoWebServiceProcessRemote requestInfo:nil];
				continue;
			}
			
			if ([bodyPart isKindOfClass:[GetUserInfoSvc_processRemoteResponse class]]) {
				GetUserInfoSvc_processRemoteResponse *processRemoteResponse = (GetUserInfoSvc_processRemoteResponse *)bodyPart;
				NSError *error = nil;
				NSString *coppaFlag = [self parseToken:processRemoteResponse.return_ error:&error];
               
				if([(id)self.delegate respondsToSelector:@selector(method:didCompleteWithResult:userInfo:)]) {					
                    NSDate *serverDate = [self.rfc822DateFormatter dateFromString:[operation.responseHeaders objectForKey:@"Date"]];
                    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:(double)operation.serverDateDelta], @"serverDateDelta",
                                              (serverDate == nil ? (id)[NSNull null] : serverDate), @"serverDate",
                                              nil];
                    
                    [(id)self.delegate method:kSCHScholasticGetUserInfoWebServiceProcessRemote didCompleteWithResult:
                     [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:[coppaFlag boolValue]] forKey:kSCHScholasticGetUserInfoWebServiceCOPPA]
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
		nodes = [doc nodesForXPath:kSCHScholasticGetUserInfoWebServiceAttribute error:error];
		if (*error == nil) {		
			for (CXMLElement *node in nodes) {
				NSString *attributeName = [[node attributeForName:kSCHScholasticGetUserInfoWebServiceAttributeName] stringValue];
				
				if (attributeName != nil) {
                    if ([attributeName caseInsensitiveCompare:kSCHScholasticGetUserInfoWebServiceAttributeCOPPA_FLAG_KEY] == NSOrderedSame) {
                        ret = [[node attributeForName:kSCHScholasticGetUserInfoWebServiceAttributeValue] stringValue];
                        break;
                    } else if ([attributeName caseInsensitiveCompare:kSCHScholasticGetUserInfoWebServiceAttributeErrorCode] == NSOrderedSame) {
                        errorCode = [[node attributeForName:kSCHScholasticGetUserInfoWebServiceAttributeValue] stringValue];
                    }
                    else if ([attributeName caseInsensitiveCompare:kSCHScholasticGetUserInfoWebServiceAttributeErrorDesc] == NSOrderedSame) {
                        errorDescription = [[node attributeForName:kSCHScholasticGetUserInfoWebServiceAttributeValue] stringValue];
                    }		
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
