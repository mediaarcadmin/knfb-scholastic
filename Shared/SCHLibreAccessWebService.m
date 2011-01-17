//
//  LibreAccessWebService.m
//  WebAPI
//
//  Created by John S. Eddie on 21/12/2010.
//  Copyright 2010 BitWink. All rights reserved.
//

#import "SCHLibreAccessWebService.h"

#import "SCHScholasticWebService.h"
#import "BITAPIError.h"
#import "NSNumber+ObjectTypes.h"


static NSString * const kSCHLibreAccessWebServiceUndefinedMethod = @"undefined method";
static NSString * const kSCHLibreAccessWebServiceStatusMessage = @"statusmessage";


@interface SCHLibreAccessWebService ()

- (NSError *)errorFromStatusMessage:(LibreAccessServiceSvc_StatusHolder *)statusMessage;
- (NSString *)methodNameFromObject:(id)anObject;

- (NSDictionary *)objectFromTokenExchangeResponse:(LibreAccessServiceSvc_TokenExchangeResponse *)anObject;
- (NSDictionary *)objectFromProfileItem:(LibreAccessServiceSvc_ProfileItem *)anObject;
- (NSDictionary *)objectFromUserContentItem:(LibreAccessServiceSvc_UserContentItem *)anObject;
- (NSDictionary *)objectFromContentProfileItem:(LibreAccessServiceSvc_ContentProfileItem *)anObject;
- (NSDictionary *)objectFromOrderIDItem:(LibreAccessServiceSvc_OrderIDItem *)anObject;
- (NSDictionary *)objectFromContentMetadataItem:(LibreAccessServiceSvc_ContentMetadataItem *)anObject;

- (id)objectFromObject:(id)anObject;

@end


@implementation SCHLibreAccessWebService

#pragma mark -
#pragma mark Memory management

- (id)init
{
	self = [super init];
	if (self != nil) {
		binding = [[LibreAccessServiceSvc LibreAccessServiceSoap12Binding] retain];
		binding.logXMLInOut = NO;		
	}
	
	return(self);
}

- (void)dealloc
{
	[binding release], binding = nil;
	
	[super dealloc];
}

#pragma mark -
#pragma mark API Proxy methods

- (void)tokenExchange:(NSString *)pToken forUser:(NSString *)userName
{
	LibreAccessServiceSvc_TokenExchange *request = [LibreAccessServiceSvc_TokenExchange new];

	request.ptoken = pToken;
	request.vaid = [NSNumber numberWithInt:33];
	request.deviceKey = @"";
	request.impersonationkey = @"";
	request.UserName = userName;
	
	[binding TokenExchangeAsyncUsingBody:request delegate:self]; 
	
	[request release], request = nil;
}

- (void)getUserProfiles:(NSString *)aToken
{
	LibreAccessServiceSvc_GetUserProfilesRequest *request = [LibreAccessServiceSvc_GetUserProfilesRequest new];
	
	request.authtoken = aToken;
	
	[binding GetUserProfilesAsyncUsingParameters:request delegate:self]; 
	
	[request release], request = nil;
}

- (void)listUserContent:(NSString *)aToken
{
	LibreAccessServiceSvc_ListUserContent *request = [LibreAccessServiceSvc_ListUserContent new];
	
	request.authtoken = aToken;
	
	[binding ListUserContentAsyncUsingBody:request delegate:self]; 
	
	[request release], request = nil;	
}

- (void)listContentMetadata:(NSString *)aToken includeURLs:(BOOL)includeURLs forBooks:(NSArray *)bookISBNs
{
	LibreAccessServiceSvc_ListContentMetadata *request = [LibreAccessServiceSvc_ListContentMetadata new];
	
	request.authtoken = aToken;
	USBoolean *includeurls = [[USBoolean alloc] initWithBool:includeURLs];
	request.includeurls = includeurls;
	[includeurls release], includeurls = nil;	
	LibreAccessServiceSvc_isbnItem *item = nil;
	for (id book in bookISBNs) {
		item = [[LibreAccessServiceSvc_isbnItem alloc] init];
		item.ISBN = [book objectForKey:kSCHLibreAccessWebServiceContentIdentifier];
		item.Format = [book objectForKey:kSCHLibreAccessWebServiceFormat];
		item.IdentifierType = [[book objectForKey:kSCHLibreAccessWebServiceContentIdentifierType] intValue];
		item.Qualifier = [[book objectForKey:kSCHLibreAccessWebServiceDRMQualifier] intValue];
		[request addIsbn13s:item];	
		[item release], item = nil;
	}
	
	[binding ListContentMetadataAsyncUsingBody:request delegate:self]; 
	
	[request release], request = nil;	
}

#pragma mark -
#pragma mark LibreAccessServiceSoap12BindingResponse Delegate methods

- (void)operation:(LibreAccessServiceSoap12BindingOperation *)operation completedWithResponse:(LibreAccessServiceSoap12BindingResponse *)response
{	
	NSString *methodName = [self methodNameFromObject:operation];
	
	if (operation.response.error != nil && [(id)self.delegate respondsToSelector:@selector(method:didFailWithError:)]) {
		[(id)self.delegate method:methodName didFailWithError:operation.response.error];
	} else {
		for (id bodyPart in response.bodyParts) {
			if ([bodyPart isKindOfClass:[SOAPFault class]]) {
				[self reportFault:(SOAPFault *)bodyPart forMethod:methodName];
				continue;
			}
			
			LibreAccessServiceSvc_StatusHolder *status = nil;
			@try {
				status = (LibreAccessServiceSvc_StatusHolder *)[bodyPart valueForKey:kSCHLibreAccessWebServiceStatusMessage];
			}
			@catch (NSException * e) {
				// everything has a status message however be defensive
				status = nil;
			}
			@finally {
				if(status != nil && 
				   [status isKindOfClass:[LibreAccessServiceSvc_StatusHolder class]] == YES && 
				   status.status != LibreAccessServiceSvc_statuscodes_SUCCESS &&
				   [(id)self.delegate respondsToSelector:@selector(method:didFailWithError:)]) {
					[(id)self.delegate method:methodName didFailWithError:[self errorFromStatusMessage:status]];			
				}
			}
			
			if([(id)self.delegate respondsToSelector:@selector(method:didCompleteWithResult:)]) {
				[(id)self.delegate method:methodName didCompleteWithResult:[self objectFrom:bodyPart]];									
			}
		}		
	}
}

#pragma mark -
#pragma mark Private methods
				
- (NSError *)errorFromStatusMessage:(LibreAccessServiceSvc_StatusHolder *)statusMessage
{
	NSError *ret = nil;
	
	if (statusMessage != nil && statusMessage.status != LibreAccessServiceSvc_statuscodes_SUCCESS) {					 
		NSDictionary *userInfo = nil;
		
		if (statusMessage.statusmessage != nil) {
			userInfo = [NSDictionary dictionaryWithObject:statusMessage.statusmessage forKey:NSLocalizedDescriptionKey];		
		}
		
		ret = [NSError errorWithDomain:kBITAPIErrorDomain code:[statusMessage.statuscode integerValue] userInfo:userInfo];
	}
	
	return(ret);
}

- (NSString *)methodNameFromObject:(id)anObject
{
	NSString *ret = kSCHLibreAccessWebServiceUndefinedMethod;
	
	if (anObject != nil) {
		if([anObject isKindOfClass:[LibreAccessServiceSvc_TokenExchange class]] == YES ||
		   [anObject isKindOfClass:[LibreAccessServiceSvc_TokenExchangeResponse class]] == YES ||		   
		   [anObject isKindOfClass:[LibreAccessServiceSoap12Binding_TokenExchange class]] == YES) {
			ret = kSCHLibreAccessWebServiceTokenExchange;	
		} else if([anObject isKindOfClass:[LibreAccessServiceSvc_GetUserProfilesRequest class]] == YES ||
				  [anObject isKindOfClass:[LibreAccessServiceSvc_GetUserProfilesResponse class]] == YES ||
				  [anObject isKindOfClass:[LibreAccessServiceSoap12Binding_GetUserProfiles class]] == YES) {
			ret = kSCHLibreAccessWebServiceGetUserProfiles;	
		} else if([anObject isKindOfClass:[LibreAccessServiceSvc_ListUserContent class]] == YES ||
				  [anObject isKindOfClass:[LibreAccessServiceSvc_ListUserContentResponse class]] == YES ||
				  [anObject isKindOfClass:[LibreAccessServiceSoap12Binding_ListUserContent class]] == YES) {
			ret = kSCHLibreAccessWebServiceListUserContent;	
		} else if([anObject isKindOfClass:[LibreAccessServiceSvc_ListContentMetadata class]] == YES ||
				  [anObject isKindOfClass:[LibreAccessServiceSvc_ListContentMetadataResponse class]] == YES ||
				  [anObject isKindOfClass:[LibreAccessServiceSoap12Binding_ListContentMetadata class]] == YES) {
			ret = kSCHLibreAccessWebServiceListContentMetadata;				
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
		if ([anObject isKindOfClass:[LibreAccessServiceSvc_TokenExchangeResponse class]] == YES) {
			ret = [self objectFromTokenExchangeResponse:anObject];
		} else if ([anObject isKindOfClass:[LibreAccessServiceSvc_GetUserProfilesResponse class]] == YES) {
			ret = [NSDictionary dictionaryWithObject:[self objectFromObject:[[anObject ProfileList] ProfileItem]] forKey:kSCHLibreAccessWebServiceProfileList];
		} else if ([anObject isKindOfClass:[LibreAccessServiceSvc_ListUserContentResponse class]] == YES) {
			ret = [NSDictionary dictionaryWithObject:[self objectFromObject:[[anObject UserContentList] UserContentItem]] forKey:kSCHLibreAccessWebServiceUserContentList];
		} else if ([anObject isKindOfClass:[LibreAccessServiceSvc_ListContentMetadataResponse class]] == YES) {
			ret = [NSDictionary dictionaryWithObject:[self objectFromObject:[[anObject ContentMetadataList] ContentMetadataItem]] forKey:kSCHLibreAccessWebServiceContentMetadataList];
		}			
	}
	
	return(ret);
}

- (id)fromObject:(NSDictionary *)object usingClass:(NSString *)className
{
	id ret = nil;
	
	if (object != nil) {
		ret = [[[NSClassFromString(className) alloc] init] autorelease];
		
		for (NSString *propertyName in object) {
			id value = [object objectForKey:propertyName];
			if (value != nil) {
				[ret setValue:value forKey:propertyName];
			}
		}		
	}
	
	return(ret);
}

#pragma mark -
#pragma mark ObjectMapper Object converter methods 

- (NSDictionary *)objectFromTokenExchangeResponse:(LibreAccessServiceSvc_TokenExchangeResponse *)anObject
{
	NSDictionary *ret = nil;
	
	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];
		
		[objects setObject:[self objectFromObject:anObject.authtoken] forKey:kSCHLibreAccessWebServiceAuthToken];
		[objects setObject:[self objectFromObject:anObject.expiresIn] forKey:kSCHLibreAccessWebServiceExpiresIn];
		[objects setObject:[self objectFromObject:anObject.deviceIsDeregistered] forKey:kSCHLibreAccessWebServiceDeviceIsDeregistered];
				
		ret = objects;				
	}
	
	return(ret);
}

- (NSDictionary *)objectFromProfileItem:(LibreAccessServiceSvc_ProfileItem *)anObject
{
	NSDictionary *ret = nil;
	
	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];
		
		[objects setObject:[self objectFromObject:anObject.AutoAssignContentToProfiles] forKey:kSCHLibreAccessWebServiceAutoAssignContentToProfiles];
		[objects setObject:[self objectFromObject:anObject.ProfilePasswordRequired] forKey:kSCHLibreAccessWebServiceProfilePasswordRequired];		
		[objects setObject:[self objectFromObject:anObject.Firstname] forKey:kSCHLibreAccessWebServiceFirstname];		
		[objects setObject:[self objectFromObject:anObject.Lastname] forKey:kSCHLibreAccessWebServiceLastname];		
		[objects setObject:[self objectFromObject:anObject.BirthDay] forKey:kSCHLibreAccessWebServiceBirthDay];		
		[objects setObject:[self objectFromObject:anObject.screenname] forKey:kSCHLibreAccessWebServiceScreenname];		
		[objects setObject:[self objectFromObject:anObject.password] forKey:kSCHLibreAccessWebServicePassword];		
		[objects setObject:[self objectFromObject:anObject.userkey] forKey:kSCHLibreAccessWebServiceUserkey];		
		[objects setObject:[self objectFromObject:[NSNumber numberWithProfileType:anObject.type]] forKey:kSCHLibreAccessWebServiceType];		
		[objects setObject:[self objectFromObject:anObject.id_] forKey:kSCHLibreAccessWebServiceID];		
		[objects setObject:[self objectFromObject:[NSNumber numberWithBookshelfStyle:anObject.BookshelfStyle]] forKey:kSCHLibreAccessWebServiceBookshelfStyle];		
		[objects setObject:[self objectFromObject:anObject.LastModified] forKey:kSCHLibreAccessWebServiceLastModified];		
		[objects setObject:[self objectFromObject:anObject.LastScreenNameModified] forKey:kSCHLibreAccessWebServiceLastScreenNameModified];		
		[objects setObject:[self objectFromObject:anObject.LastPasswordModified] forKey:kSCHLibreAccessWebServiceLastPasswordModified];		
		[objects setObject:[self objectFromObject:anObject.storyInteractionEnabled] forKey:kSCHLibreAccessWebServiceStoryInteractionEnabled];		
		
		ret = objects;					
	}
	
	return(ret);
}

- (NSDictionary *)objectFromUserContentItem:(LibreAccessServiceSvc_UserContentItem *)anObject
{
	NSDictionary *ret = nil;
	
	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];
		
		[objects setObject:[self objectFromObject:anObject.ContentIdentifier] forKey:kSCHLibreAccessWebServiceContentIdentifier];
		[objects setObject:[self objectFromObject:[NSNumber numberWithContentIdentifierType:anObject.ContentIdentifierType]] forKey:kSCHLibreAccessWebServiceContentIdentifierType];		
		[objects setObject:[self objectFromObject:[NSNumber numberWithDRMQualifier:anObject.DRMQualifier]] forKey:kSCHLibreAccessWebServiceDRMQualifier];		
		[objects setObject:[self objectFromObject:anObject.Format] forKey:kSCHLibreAccessWebServiceFormat];		
		[objects setObject:[self objectFromObject:anObject.Version] forKey:kSCHLibreAccessWebServiceVersion];		
		[objects setObject:[self objectFromObject:[[anObject ContentProfileList] ContentProfileItem]] forKey:kSCHLibreAccessWebServiceProfileList];
		[objects setObject:[self objectFromObject:[[anObject OrderIDList] OrderIDItem]] forKey:kSCHLibreAccessWebServiceOrderIDList];		
		[objects setObject:[self objectFromObject:anObject.lastmodified] forKey:kSCHLibreAccessWebServiceLastModified];		
		[objects setObject:[self objectFromObject:anObject.DefaultAssignment] forKey:kSCHLibreAccessWebServiceDefaultAssignment];		
			
		ret = objects;					
	}
	
	return(ret);
}

- (NSDictionary *)objectFromContentProfileItem:(LibreAccessServiceSvc_ContentProfileItem *)anObject
{
	NSDictionary *ret = nil;
	
	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];
		
		[objects setObject:[self objectFromObject:anObject.profileID] forKey:kSCHLibreAccessWebServiceprofileID];
		[objects setObject:[self objectFromObject:anObject.isFavorite] forKey:kSCHLibreAccessWebServiceisFavorite];
		[objects setObject:[self objectFromObject:anObject.lastPageLocation] forKey:kSCHLibreAccessWebServicelastPageLocation];
		[objects setObject:[self objectFromObject:anObject.lastmodified] forKey:kSCHLibreAccessWebServiceLastModified];
		
		ret = objects;					
	}
	
	return(ret);
}

- (NSDictionary *)objectFromOrderIDItem:(LibreAccessServiceSvc_OrderIDItem *)anObject
{
	NSDictionary *ret = nil;
	
	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];
		
		[objects setObject:[self objectFromObject:anObject.OrderID] forKey:kSCHLibreAccessWebServiceOrderID];
		
		ret = objects;					
	}
	
	return(ret);
}

- (NSDictionary *)objectFromContentMetadataItem:(LibreAccessServiceSvc_ContentMetadataItem *)anObject
{
	NSDictionary *ret = nil;
	
	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];
		
		[objects setObject:[self objectFromObject:anObject.ContentIdentifier] forKey:kSCHLibreAccessWebServiceContentIdentifier];
		[objects setObject:[self objectFromObject:[NSNumber numberWithContentIdentifierType:anObject.ContentIdentifierType]] forKey:kSCHLibreAccessWebServiceContentIdentifierType];
		[objects setObject:[self objectFromObject:anObject.Title] forKey:kSCHLibreAccessWebServiceTitle];
		[objects setObject:[self objectFromObject:anObject.Author] forKey:kSCHLibreAccessWebServiceAuthor];
		[objects setObject:[self objectFromObject:anObject.Description] forKey:kSCHLibreAccessWebServiceDescription];
		[objects setObject:[self objectFromObject:anObject.Version] forKey:kSCHLibreAccessWebServiceVersion];
		[objects setObject:[self objectFromObject:anObject.PageNumber] forKey:kSCHLibreAccessWebServicePageNumber];
		[objects setObject:[self objectFromObject:anObject.FileSize] forKey:kSCHLibreAccessWebServiceFileSize];
		[objects setObject:[self objectFromObject:[NSNumber numberWithDRMQualifier:anObject.DRMQualifier]] forKey:kSCHLibreAccessWebServiceDRMQualifier];
		[objects setObject:[self objectFromObject:anObject.CoverURL] forKey:kSCHLibreAccessWebServiceCoverURL];
		[objects setObject:[self objectFromObject:anObject.ContentURL] forKey:kSCHLibreAccessWebServiceContentURL];
//		[objects setObject:[self objectFromObject:anObject.EreaderCategories] forKey:kLibreAccessWebServiceEreaderCategories];
		[objects setObject:[self objectFromObject:[NSNumber numberWithProductType:anObject.ProductType]] forKey:kSCHLibreAccessWebServiceProductType];
				
		ret = objects;					
	}
	
	return(ret);
}

- (id)objectFromObject:(id)anObject
{
	id ret = nil;
	
	if (anObject == nil) {
		ret = [NSNull null];
	} else if([anObject isKindOfClass:[NSMutableArray class]] == YES) {
		ret = [NSMutableArray array];
		
		for (id item in anObject) {
			if ([item isKindOfClass:[LibreAccessServiceSvc_ProfileItem class]] == YES) {
				[ret addObject:[self objectFromProfileItem:item]];					
			} else if ([item isKindOfClass:[LibreAccessServiceSvc_UserContentItem class]] == YES) {
				[ret addObject:[self objectFromUserContentItem:item]];					
			} else if ([item isKindOfClass:[LibreAccessServiceSvc_ContentProfileItem class]] == YES) {
				[ret addObject:[self objectFromContentProfileItem:item]];					
			} else if ([item isKindOfClass:[LibreAccessServiceSvc_OrderIDItem class]] == YES) {
				[ret addObject:[self objectFromOrderIDItem:item]];									
			} else if ([item isKindOfClass:[LibreAccessServiceSvc_ContentMetadataItem class]] == YES) {
				[ret addObject:[self objectFromContentMetadataItem:item]];													
			}			
		}		
	} else if([anObject isKindOfClass:[USBoolean class]] == YES) {
		ret = [NSNumber numberWithBool:[anObject boolValue]];
	} else {
		ret = anObject;
	}
	
	return(ret);
}


@end
