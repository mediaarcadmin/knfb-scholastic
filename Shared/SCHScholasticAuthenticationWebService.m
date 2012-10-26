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
#import "AuthenticateSvc+Binding.h"
#import "SCHScholasticResponseParser.h"

// ProcessRemote Constants
NSString * const kSCHScholasticAuthenticationWebServiceProcessRemote = @"processRemote";
NSString * const kSCHScholasticAuthenticationWebServicePToken = @"pToken";

static NSString * const kSCHScholasticAuthenticationWebServiceAttributeToken = @"token";

/*
 * This class is thread safe when using the Thread Confinement design pattern.
 */

@interface SCHScholasticAuthenticationWebService ()

@property (nonatomic, retain) AuthenticateSoap11Binding *binding;

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

- (void)operation:(AuthenticateSoap11BindingOperation *)operation 
completedWithResponse:(AuthenticateSoap11BindingResponse *)response
{	
	[[BITNetworkActivityManager sharedNetworkActivityManager] hideNetworkActivityIndicator];
	
	if (operation.response.error != nil) {
        if ([(id)self.delegate respondsToSelector:@selector(method:didFailWithError:requestInfo:result:)]) {
            [(id)self.delegate method:kSCHScholasticAuthenticationWebServiceProcessRemote 
                     didFailWithError:[self confirmErrorDomain:operation.response.error 
                                                 forDomainName:@"AuthenticateSoap11BindingResponseHTTP"] 
                          requestInfo:nil result:nil];
        }
	} else {		
		for (id bodyPart in response.bodyParts) {
			if ([bodyPart isKindOfClass:[SOAPFault class]]) {
				[self reportFault:(SOAPFault *)bodyPart 
                        forMethod:kSCHScholasticAuthenticationWebServiceProcessRemote 
                      requestInfo:nil];
				continue;
			}
			
			if ([bodyPart isKindOfClass:[AuthenticateSvc_processRemoteResponse class]]) {
				AuthenticateSvc_processRemoteResponse *processRemoteResponse = (AuthenticateSvc_processRemoteResponse *)bodyPart;
                SCHScholasticResponseParser *scholasticResponseParser = [[[SCHScholasticResponseParser alloc] init] autorelease];
                NSDictionary *responseDictionary = [scholasticResponseParser parseXMLString:processRemoteResponse.return_];
                
                if (responseDictionary == nil) {
                    if([(id)self.delegate respondsToSelector:@selector(method:didFailWithError:requestInfo:result:)]) {
                        NSError *error = [NSError errorWithDomain:kBITAPIErrorDomain 
                                                             code:kSCHScholasticAuthenticationWebServiceErrorCodeUnknown
                                                         userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"An unknown error occured", nil)
                                                                                              forKey:NSLocalizedDescriptionKey]];
                        
                        [(id)self.delegate method:kSCHScholasticAuthenticationWebServiceProcessRemote 
                                 didFailWithError:error 
                                      requestInfo:nil 
                                           result:nil];
                    }                    
                } else {
                    NSString *token = [responseDictionary objectForKey:kSCHScholasticAuthenticationWebServiceAttributeToken];
                    
                    if (token == nil) {
                        if([(id)self.delegate respondsToSelector:@selector(method:didFailWithError:requestInfo:result:)]) {
                            NSError *error = [SCHScholasticResponseParser errorFromDictionary:responseDictionary];
                            
                            if (error == nil) {
                                error = [NSError errorWithDomain:kBITAPIErrorDomain 
                                                            code:kSCHScholasticAuthenticationWebServiceErrorCodeUnknown
                                                        userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"An unknown error occured", nil)
                                                                                             forKey:NSLocalizedDescriptionKey]];                            
                            }
                            
                            [(id)self.delegate method:kSCHScholasticAuthenticationWebServiceProcessRemote 
                                     didFailWithError:error 
                                          requestInfo:nil 
                                               result:nil];
                        }
                    } else if([(id)self.delegate respondsToSelector:@selector(method:didCompleteWithResult:userInfo:)]) {
                        NSDate *serverDate = nil;
                        NSString *responseDateString = [operation.responseHeaders objectForKey:@"Date"];
                        if (responseDateString) {
                            serverDate = [self.rfc822DateFormatter dateFromString:responseDateString];
                        } else {
                            NSLog(@"Warning: no date returned in the response headers. This should be investigated.");
                        }
                        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:(double)operation.serverDateDelta], @"serverDateDelta",
                                                  (serverDate == nil ? (id)[NSNull null] : serverDate), @"serverDate",
                                                  nil];
                        
                        [(id)self.delegate method:kSCHScholasticAuthenticationWebServiceProcessRemote 
                            didCompleteWithResult:[NSDictionary dictionaryWithObject:token 
                                                                              forKey:kSCHScholasticAuthenticationWebServicePToken]
                                         userInfo:userInfo];
                    }
                }
			}
		}
	}
}

@end
