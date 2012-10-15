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
#import "GetUserInfoSvc+Binding.h"
#import "SCHScholasticResponseParser.h"

// ProcessRemote Constants
NSString * const kSCHScholasticGetUserInfoWebServiceProcessRemote = @"processRemote";
NSString * const kSCHScholasticGetUserInfoWebServiceCOPPA = @"COPPA";
NSString * const kSCHScholasticGetUserInfoWebServiceSPSID = @"SPSID";

static NSString * const kSCHScholasticGetUserInfoWebServiceAttributeCOPPA_FLAG_KEY = @"COPPA_FLAG_KEY";
static NSString * const kSCHScholasticGetUserInfoWebServiceAttributeSPSID = @"spsid";

/*
 * This class is thread safe when using the Thread Confinement design pattern.
 */

@interface SCHScholasticGetUserInfoWebService ()

@property (nonatomic, retain) GetUserInfoSoap11Binding *binding;

@end

@implementation SCHScholasticGetUserInfoWebService

@synthesize binding;

#pragma mark - Object lifecycle

- (id)init
{
	self = [super init];
	if (self != nil) {
		binding = [[GetUserInfoSvc SCHGetUserInfoSoap11Binding] retain];
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

- (void)getUserInfo:(NSString *)token
{	
	GetUserInfoSvc_processRemote *request = [GetUserInfoSvc_processRemote new];
    // other requestedProps properties: spsid, SCS_TOOLS_ROLES_KEY, FIRST_NAME_KEY,LAST_NAME_KEY, COPPA_FLAG_KEY
	request.SPSWSXML = [NSString stringWithFormat:@"<SchWS><attribute name=\"clientID\" value=\"LD\"/><attribute name=\"isSingleToken\" value=\"true\"/><attribute name=\"token\" value=\"%@\"/><attribute name=\"requestedProps\" value=\"spsid,COPPA_FLAG_KEY\"/></SchWS>", (token == nil ? @"" : token)];
    
	[self.binding processRemoteAsyncUsingParameters:request delegate:self]; 
	[[BITNetworkActivityManager sharedNetworkActivityManager] showNetworkActivityIndicator];
	
	[request release], request = nil;
}

#pragma mark - GetUserInfoSoap11BindingResponse Delegate methods

- (void)operation:(GetUserInfoSoap11BindingOperation *)operation 
completedWithResponse:(GetUserInfoSoap11BindingResponse *)response
{	
	[[BITNetworkActivityManager sharedNetworkActivityManager] hideNetworkActivityIndicator];
	
	if (operation.response.error != nil) {
        if ([(id)self.delegate respondsToSelector:@selector(method:didFailWithError:requestInfo:result:)]) {
            [(id)self.delegate method:kSCHScholasticGetUserInfoWebServiceProcessRemote 
                     didFailWithError:[self confirmErrorDomain:operation.response.error 
                                                 forDomainName:@"GetUserInfoServiceSoap11BindingResponseHTTP"] 
                          requestInfo:nil result:nil];
        }
	} else {		
		for (id bodyPart in response.bodyParts) {
			if ([bodyPart isKindOfClass:[SOAPFault class]]) {
				[self reportFault:(SOAPFault *)bodyPart 
                        forMethod:kSCHScholasticGetUserInfoWebServiceProcessRemote 
                      requestInfo:nil];
				continue;
			}
			
			if ([bodyPart isKindOfClass:[GetUserInfoSvc_processRemoteResponse class]]) {
				GetUserInfoSvc_processRemoteResponse *processRemoteResponse = (GetUserInfoSvc_processRemoteResponse *)bodyPart;
                SCHScholasticResponseParser *scholasticResponseParser = [[[SCHScholasticResponseParser alloc] init] autorelease];
                NSDictionary *responseDictionary = [scholasticResponseParser parseXMLString:processRemoteResponse.return_];
				
                if (responseDictionary == nil) {
                    if([(id)self.delegate respondsToSelector:@selector(method:didFailWithError:requestInfo:result:)]) {
                        NSError *error = [NSError errorWithDomain:kBITAPIErrorDomain 
                                                             code:kSCHScholasticGetUserInfoWebServiceErrorCodeUnknown
                                                         userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"An unknown error occured", nil)
                                                                                              forKey:NSLocalizedDescriptionKey]];
                        
                        [(id)self.delegate method:kSCHScholasticGetUserInfoWebServiceProcessRemote 
                                 didFailWithError:error 
                                      requestInfo:nil 
                                           result:nil];
                    }                    
                } else {
                    NSString *coppaFlag = [responseDictionary objectForKey:kSCHScholasticGetUserInfoWebServiceAttributeCOPPA_FLAG_KEY];
                    NSString *spsId = [responseDictionary objectForKey:kSCHScholasticGetUserInfoWebServiceAttributeSPSID];
                    
                    if (coppaFlag == nil && spsId == nil) {
                        if([(id)self.delegate respondsToSelector:@selector(method:didFailWithError:requestInfo:result:)]) {                        
                            NSError *error = [SCHScholasticResponseParser errorFromDictionary:responseDictionary];
                            
                            if (error == nil) {
                                error = [NSError errorWithDomain:kBITAPIErrorDomain 
                                                            code:kSCHScholasticGetUserInfoWebServiceErrorCodeUnknown
                                                        userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"An unknown error occured", nil)
                                                                                             forKey:NSLocalizedDescriptionKey]];                            
                            }
    
                            [(id)self.delegate method:kSCHScholasticGetUserInfoWebServiceProcessRemote 
                                     didFailWithError:error 
                                          requestInfo:nil 
                                               result:nil];
                        }
                    } else if([(id)self.delegate respondsToSelector:@selector(method:didCompleteWithResult:userInfo:)]) {					
                        NSDate *serverDate = [self.rfc822DateFormatter dateFromString:[operation.responseHeaders objectForKey:@"Date"]];
                        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:(double)operation.serverDateDelta], @"serverDateDelta",
                                                  (serverDate == nil ? (id)[NSNull null] : serverDate), @"serverDate",
                                                  nil];
                        NSMutableDictionary *result = [NSMutableDictionary dictionary];

                        if (coppaFlag != nil) {
                            NSNumber *coppaValue = nil;
                            if (coppaFlag == (id)[NSNull null]) {
                                coppaValue = [NSNumber numberWithBool:NO];
                            } else {
                                coppaValue = [NSNumber numberWithBool:[coppaFlag boolValue]];
                            }
                            [result setObject:coppaValue forKey:kSCHScholasticGetUserInfoWebServiceCOPPA];
                        }
                                                
                        if (spsId != nil) {
                            [result setObject:spsId forKey:kSCHScholasticGetUserInfoWebServiceSPSID];
                        }
                            
                        [(id)self.delegate method:kSCHScholasticGetUserInfoWebServiceProcessRemote 
                            didCompleteWithResult:[NSDictionary dictionaryWithDictionary:result]
                                         userInfo:userInfo];
                    }
                }
            }
		}
	}
}

@end
