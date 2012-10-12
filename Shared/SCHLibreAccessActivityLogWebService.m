//
//  SCHLibreAccessActivityLogWebService.m
//  Scholastic
//
//  Created by John S. Eddie on 04/09/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHLibreAccessActivityLogWebService.h"

#import "BITAPIError.h"
#import "NSNumber+ObjectTypes.h"
#import "SCHAuthenticationManager.h"
#import "BITNetworkActivityManager.h"
#import "LibreAccessActivityLogSvc_tns1.h"

static NSString * const kSCHLibreAccessActivityLogWebServiceUndefinedMethod = @"undefined method";
static NSString * const kSCHLibreAccessActivityLogWebServiceStatusHolderStatusMessage = @"statusMessage";

/*
 * This class is thread safe when using the Thread Confinement design pattern.
 */

@interface SCHLibreAccessActivityLogWebService ()

@property (nonatomic, retain) LibreAccessActivityLogSoap11Binding *binding;

- (NSError *)errorFromStatusMessage:(tns1_StatusHolder2 *)statusMessage;
- (NSString *)methodNameFromObject:(id)anObject;

- (NSDictionary *)objectFromSaveActivityLog:(tns1_SaveActivityLogResponse *)anObject;
- (NSDictionary *)objectFromSavedItem:(tns1_SavedItem *)anObject;

- (id)objectFromTranslate:(id)anObject;

- (void)fromObject:(NSDictionary *)object intoLogsList:(tns1_LogsList *)intoObject;
- (void)fromObject:(NSDictionary *)object intoLogItem:(tns1_LogItem *)intoObject;
- (NSDictionary *)objectFromStatusHolder:(tns1_StatusHolder2 *)anObject;

@end

@implementation SCHLibreAccessActivityLogWebService

@synthesize binding;

#pragma mark - Object lifecycle

- (id)init
{
	self = [super init];
	if (self != nil) {
		binding = [[LibreAccessActivityLogSvc SCHLibreAccessActivityLogSoap11Binding] retain];
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

- (void)clear
{
    self.binding = [LibreAccessActivityLogSvc SCHLibreAccessActivityLogSoap11Binding];
    binding.logXMLInOut = NO;
}

#pragma mark - API Proxy methods

- (BOOL)saveActivityLog:(NSArray *)logsList forUserKey:(NSString *)userKey
{
	BOOL ret = NO;

	if ([SCHAuthenticationManager sharedAuthenticationManager].isAuthenticated == YES) {
		tns1_SaveActivityLogRequest *request = [tns1_SaveActivityLogRequest new];

		request.authToken = [SCHAuthenticationManager sharedAuthenticationManager].aToken;
        request.userKey = userKey;
        request.creationDate = [NSDate date];
		for (id log in logsList) {
			tns1_LogsList *item = [[tns1_LogsList alloc] init];
			[self fromObject:log intoObject:item];
			[request addLogsList:item];
			[item release], item = nil;
		}

		[self.binding SaveActivityLogAsyncUsingParameters:request delegate:self];
		[[BITNetworkActivityManager sharedNetworkActivityManager] showNetworkActivityIndicator];

		[request release], request = nil;
		ret = YES;
	}

	return(ret);
}

#pragma mark - LibreAccessBindingResponse Delegate methods

- (void)operation:(LibreAccessActivityLogSoap11BindingOperation *)operation completedWithResponse:(LibreAccessActivityLogSoap11BindingResponse *)response
{
	[[BITNetworkActivityManager sharedNetworkActivityManager] hideNetworkActivityIndicator];

	// just in case we have a stray operation make sure it's bound to the current binding
    if (self.binding == operation.binding ) {
        NSString *methodName = [self methodNameFromObject:operation];

        if (operation.response.error != nil) {
            if ([(id)self.delegate respondsToSelector:@selector(method:didFailWithError:requestInfo:result:)]) {
                [(id)self.delegate method:methodName didFailWithError:[self confirmErrorDomain:operation.response.error
                                                                                 forDomainName:@"LibreAccessActivityLogSoap11BindingResponseHTTP"]
                              requestInfo:nil result:nil];
            }
        } else {
            for (id bodyPart in response.bodyParts) {
                if ([bodyPart isKindOfClass:[SOAPFault class]]) {
                    [self reportFault:(SOAPFault *)bodyPart forMethod:methodName
                          requestInfo:nil];
                    continue;
                }

                tns1_StatusHolder2 *status = nil;
                BOOL errorTriggered = NO;
                @try {
                    status = (tns1_StatusHolder2 *)[bodyPart valueForKey:kSCHLibreAccessActivityLogWebServiceStatusHolderStatusMessage];
                }
                @catch (NSException * e) {
                    // everything has a status message however be defensive
                    status = nil;
                }
                @finally {
                    if(status != nil &&
                       [status isKindOfClass:[tns1_StatusHolder2 class]] == YES &&
                       status.status != tns1_StatusCodes_SUCCESS &&
                       [(id)self.delegate respondsToSelector:@selector(method:didFailWithError:requestInfo:result:)]) {
                        errorTriggered = YES;
                        [(id)self.delegate method:methodName didFailWithError:[self errorFromStatusMessage:status]
                                      requestInfo:nil
                                           result:[self objectFrom:bodyPart]];
                    }
                }

                NSDate *serverDate = [self.rfc822DateFormatter dateFromString:[operation.responseHeaders objectForKey:@"Date"]];
                NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:(double)operation.serverDateDelta], @"serverDateDelta",
                                          (serverDate == nil ? (id)[NSNull null] : serverDate), @"serverDate",
                                          nil];

                if(errorTriggered == NO && [(id)self.delegate respondsToSelector:@selector(method:didCompleteWithResult:userInfo:)]) {
                    [(id)self.delegate method:methodName didCompleteWithResult:[self objectFrom:bodyPart]
                                     userInfo:userInfo];
                }
            }
        }
    }
}

#pragma mark -
#pragma mark Private methods

- (NSError *)errorFromStatusMessage:(tns1_StatusHolder2 *)statusMessage
{
	NSError *ret = nil;

	if (statusMessage != nil && statusMessage.status != tns1_StatusCodes_SUCCESS) {
		NSDictionary *userInfo = nil;

		if (statusMessage.statusMessage != nil) {
			userInfo = [NSDictionary dictionaryWithObject:statusMessage.statusMessage
                                                   forKey:NSLocalizedDescriptionKey];
		}

		ret = [NSError errorWithDomain:kBITAPIErrorDomain
                                  code:[statusMessage.statusCode integerValue]
                              userInfo:userInfo];
	}

	return(ret);
}

- (NSString *)methodNameFromObject:(id)anObject
{
	NSString *ret = kSCHLibreAccessActivityLogWebServiceUndefinedMethod;

	if (anObject != nil) {
		if([anObject isKindOfClass:[tns1_SaveActivityLogRequest class]] == YES ||
		   [anObject isKindOfClass:[tns1_SaveActivityLogResponse class]] == YES ||
		   [anObject isKindOfClass:[LibreAccessActivityLogSoap11Binding_SaveActivityLog class]] == YES) {
			ret = kSCHLibreAccessActivityLogWebServiceSaveActivityLog;
        }
    }

	return(ret);
}

#pragma mark -
#pragma mark ObjectMapper Protocol methods

- (NSDictionary *)objectFrom:(id)anObject
{
    NSDictionary *ret = nil;

    if (anObject != nil) {
        if ([anObject isKindOfClass:[tns1_SaveActivityLogResponse class]] == YES) {
            ret = [self objectFromSaveActivityLog:anObject];
        }
    }

    return(ret);
}

- (void)fromObject:(NSDictionary *)object intoObject:(id)intoObject
{
    if (object != nil && intoObject != nil) {
        if ([intoObject isKindOfClass:[tns1_LogsList class]] == YES) {
            [self fromObject:object intoLogsList:intoObject];
        }
    }
}

#pragma mark -
#pragma mark ObjectMapper objectFrom: converter methods

- (NSDictionary *)objectFromSaveActivityLog:(tns1_SaveActivityLogResponse *)anObject
{
	NSDictionary *ret = nil;

	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];

		[objects setObject:[self objectFromTranslate:[anObject.savedIdsList savedItem]] forKey:kSCHLibreAccessActivityLogWebServiceSavedIdsList];
        
		ret = objects;
	}

	return(ret);
}

- (NSDictionary *)objectFromSavedItem:(tns1_SavedItem *)anObject
{
	NSDictionary *ret = nil;

	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];

		[objects setObject:[self objectFromTranslate:anObject.correlationId] forKey:kSCHLibreAccessActivityLogWebServiceCorrelationID];
		[objects setObject:[self objectFromTranslate:anObject.activityFactId] forKey:kSCHLibreAccessActivityLogWebServiceActivityFactID];

		ret = objects;
	}
    
	return(ret);
}

- (id)objectFromTranslate:(id)anObject
{
	id ret = nil;

	if (anObject == nil) {
		ret = [NSNull null];
	} else if([anObject isKindOfClass:[NSMutableArray class]] == YES) {
		ret = [NSMutableArray array];

		if ([(NSMutableArray *)anObject count] > 0) {
			id firstItem = [anObject objectAtIndex:0];

			if ([firstItem isKindOfClass:[tns1_SavedItem class]] == YES) {
				for (id item in anObject) {
					[ret addObject:[self objectFromSavedItem:item]];
				}
            }
        }
	} else if([anObject isKindOfClass:[USBoolean class]] == YES) {
		ret = [NSNumber numberWithBool:[anObject boolValue]];
    } else if ([anObject isKindOfClass:[tns1_StatusHolder2 class]] == YES) {
        ret = [self objectFromStatusHolder:anObject];
	} else {
		ret = anObject;
	}
    
	return(ret);
}

#pragma mark -
#pragma mark ObjectMapper fromObject: converter methods

- (void)fromObject:(NSDictionary *)object intoLogsList:(tns1_LogsList *)intoObject
{
	if (object != nil && intoObject != nil) {
		intoObject.activityName = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessActivityLogWebServiceActivityName]];
		intoObject.correlationId = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessActivityLogWebServiceCorrelationID]];
		for (NSDictionary *item in [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessActivityLogWebServiceLogItem]]) {
			tns1_LogItem *logItem = [[tns1_LogItem alloc] init];
			[self fromObject:item intoLogItem:logItem];
			[intoObject addLogItem:logItem];
			[logItem release], logItem = nil;
		}
	}
}

- (void)fromObject:(NSDictionary *)object intoLogItem:(tns1_LogItem *)intoObject
{
	if (object != nil && intoObject != nil) {
		intoObject.definitionName = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessActivityLogWebServiceDefinitionName]];
		intoObject.value = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessActivityLogWebServiceValue]];
	}
}

- (NSDictionary *)objectFromStatusHolder:(tns1_StatusHolder2 *)anObject
{
	NSDictionary *ret = nil;

	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];

		[objects setObject:[NSNumber numberWithStatusCode:(SCHStatusCodes)anObject.status] forKey:kSCHLibreAccessActivityLogWebServiceStatus];
		[objects setObject:[self objectFromTranslate:anObject.statusCode] forKey:kSCHLibreAccessActivityLogWebServiceStatusCode];
		[objects setObject:[self objectFromTranslate:anObject.statusMessage] forKey:kSCHLibreAccessActivityLogWebServiceStatusMessage];

		ret = objects;
	}

	return(ret);
}

@end
