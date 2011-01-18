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
- (NSDictionary *)objectFromProfileStatusItem:(LibreAccessServiceSvc_ProfileStatusItem *)anObject;

- (id)objectFromTranslate:(id)anObject;

- (void)fromObject:(NSDictionary *)object intoSaveProfileItem:(LibreAccessServiceSvc_SaveProfileItem **)intoObject;
- (void)fromObject:(NSDictionary *)object intoISBNItem:(LibreAccessServiceSvc_isbnItem **)intoObject;

- (id)fromObjectTranslate:(id)anObject;

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

- (void)saveUserProfiles:(NSString *)aToken forUserProfiles:(NSArray *)userProfiles
{
	LibreAccessServiceSvc_SaveUserProfilesRequest *request = [LibreAccessServiceSvc_SaveUserProfilesRequest new];
	
	request.authtoken = aToken;
	request.SaveProfileList = [[LibreAccessServiceSvc_SaveProfileList alloc] init];
	LibreAccessServiceSvc_SaveProfileItem *item = nil;
	for (id profile in userProfiles) {
		item = [[LibreAccessServiceSvc_SaveProfileItem alloc] init];
		[self fromObject:profile intoObject:&item];		
		[request.SaveProfileList addSaveProfileItem:item];	
		[item release], item = nil;
	}	
	[request.SaveProfileList release];
	
	[binding SaveUserProfilesAsyncUsingParameters:request delegate:self]; 
	
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
		[self fromObject:book intoObject:&item];
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
		} else if([anObject isKindOfClass:[LibreAccessServiceSvc_SaveUserProfilesRequest class]] == YES ||
				  [anObject isKindOfClass:[LibreAccessServiceSvc_SaveUserProfilesResponse class]] == YES ||
				  [anObject isKindOfClass:[LibreAccessServiceSoap12Binding_SaveUserProfiles class]] == YES) {
			ret = kSCHLibreAccessWebServiceSaveUserProfiles;				
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
			ret = [NSDictionary dictionaryWithObject:[self objectFromTranslate:[[anObject ProfileList] ProfileItem]] forKey:kSCHLibreAccessWebServiceProfileList];
		} else if ([anObject isKindOfClass:[LibreAccessServiceSvc_ListUserContentResponse class]] == YES) {
			ret = [NSDictionary dictionaryWithObject:[self objectFromTranslate:[[anObject UserContentList] UserContentItem]] forKey:kSCHLibreAccessWebServiceUserContentList];
		} else if ([anObject isKindOfClass:[LibreAccessServiceSvc_ListContentMetadataResponse class]] == YES) {
			ret = [NSDictionary dictionaryWithObject:[self objectFromTranslate:[[anObject ContentMetadataList] ContentMetadataItem]] forKey:kSCHLibreAccessWebServiceContentMetadataList];
		} else if ([anObject isKindOfClass:[LibreAccessServiceSvc_SaveUserProfilesResponse class]] == YES) {
			ret = [NSDictionary dictionaryWithObject:[self objectFromTranslate:[[anObject ProfileStatusList] ProfileStatusItem]] forKey:kSCHLibreAccessWebServiceProfileStatusList];
		}			
	}
	
	return(ret);
}

- (void)fromObject:(NSDictionary *)object intoObject:(id *)intoObject
{
	if (object != nil && intoObject != nil) {
		if ([*intoObject isKindOfClass:[LibreAccessServiceSvc_SaveProfileItem class]] == YES) {
			[self fromObject:object intoSaveProfileItem:intoObject];
		} else if ([*intoObject isKindOfClass:[LibreAccessServiceSvc_isbnItem class]] == YES) {
			[self fromObject:object intoISBNItem:intoObject];
		}		
	}
}

#pragma mark -
#pragma mark ObjectMapper objectFrom: converter methods 

- (NSDictionary *)objectFromTokenExchangeResponse:(LibreAccessServiceSvc_TokenExchangeResponse *)anObject
{
	NSDictionary *ret = nil;
	
	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];
		
		[objects setObject:[self objectFromTranslate:anObject.authtoken] forKey:kSCHLibreAccessWebServiceAuthToken];
		[objects setObject:[self objectFromTranslate:anObject.expiresIn] forKey:kSCHLibreAccessWebServiceExpiresIn];
		[objects setObject:[self objectFromTranslate:anObject.deviceIsDeregistered] forKey:kSCHLibreAccessWebServiceDeviceIsDeregistered];
				
		ret = objects;				
	}
	
	return(ret);
}

- (NSDictionary *)objectFromProfileItem:(LibreAccessServiceSvc_ProfileItem *)anObject
{
	NSDictionary *ret = nil;
	
	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];
		
		[objects setObject:[self objectFromTranslate:anObject.AutoAssignContentToProfiles] forKey:kSCHLibreAccessWebServiceAutoAssignContentToProfiles];
		[objects setObject:[self objectFromTranslate:anObject.ProfilePasswordRequired] forKey:kSCHLibreAccessWebServiceProfilePasswordRequired];		
		[objects setObject:[self objectFromTranslate:anObject.Firstname] forKey:kSCHLibreAccessWebServiceFirstname];		
		[objects setObject:[self objectFromTranslate:anObject.Lastname] forKey:kSCHLibreAccessWebServiceLastname];		
		[objects setObject:[self objectFromTranslate:anObject.BirthDay] forKey:kSCHLibreAccessWebServiceBirthDay];		
		[objects setObject:[self objectFromTranslate:anObject.screenname] forKey:kSCHLibreAccessWebServiceScreenname];		
		[objects setObject:[self objectFromTranslate:anObject.password] forKey:kSCHLibreAccessWebServicePassword];		
		[objects setObject:[self objectFromTranslate:anObject.userkey] forKey:kSCHLibreAccessWebServiceUserkey];		
		[objects setObject:[self objectFromTranslate:[NSNumber numberWithProfileType:anObject.type]] forKey:kSCHLibreAccessWebServiceType];		
		[objects setObject:[self objectFromTranslate:anObject.id_] forKey:kSCHLibreAccessWebServiceID];		
		[objects setObject:[self objectFromTranslate:[NSNumber numberWithBookshelfStyle:anObject.BookshelfStyle]] forKey:kSCHLibreAccessWebServiceBookshelfStyle];		
		[objects setObject:[self objectFromTranslate:anObject.LastModified] forKey:kSCHLibreAccessWebServiceLastModified];		
		[objects setObject:[self objectFromTranslate:anObject.LastScreenNameModified] forKey:kSCHLibreAccessWebServiceLastScreenNameModified];		
		[objects setObject:[self objectFromTranslate:anObject.LastPasswordModified] forKey:kSCHLibreAccessWebServiceLastPasswordModified];		
		[objects setObject:[self objectFromTranslate:anObject.storyInteractionEnabled] forKey:kSCHLibreAccessWebServiceStoryInteractionEnabled];		
		
		ret = objects;					
	}
	
	return(ret);
}

- (NSDictionary *)objectFromUserContentItem:(LibreAccessServiceSvc_UserContentItem *)anObject
{
	NSDictionary *ret = nil;
	
	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];
		
		[objects setObject:[self objectFromTranslate:anObject.ContentIdentifier] forKey:kSCHLibreAccessWebServiceContentIdentifier];
		[objects setObject:[self objectFromTranslate:[NSNumber numberWithContentIdentifierType:anObject.ContentIdentifierType]] forKey:kSCHLibreAccessWebServiceContentIdentifierType];		
		[objects setObject:[self objectFromTranslate:[NSNumber numberWithDRMQualifier:anObject.DRMQualifier]] forKey:kSCHLibreAccessWebServiceDRMQualifier];		
		[objects setObject:[self objectFromTranslate:anObject.Format] forKey:kSCHLibreAccessWebServiceFormat];		
		[objects setObject:[self objectFromTranslate:anObject.Version] forKey:kSCHLibreAccessWebServiceVersion];		
		[objects setObject:[self objectFromTranslate:[[anObject ContentProfileList] ContentProfileItem]] forKey:kSCHLibreAccessWebServiceProfileList];
		[objects setObject:[self objectFromTranslate:[[anObject OrderIDList] OrderIDItem]] forKey:kSCHLibreAccessWebServiceOrderIDList];		
		[objects setObject:[self objectFromTranslate:anObject.lastmodified] forKey:kSCHLibreAccessWebServiceLastModified];		
		[objects setObject:[self objectFromTranslate:anObject.DefaultAssignment] forKey:kSCHLibreAccessWebServiceDefaultAssignment];		
			
		ret = objects;					
	}
	
	return(ret);
}

- (NSDictionary *)objectFromContentProfileItem:(LibreAccessServiceSvc_ContentProfileItem *)anObject
{
	NSDictionary *ret = nil;
	
	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];
		
		[objects setObject:[self objectFromTranslate:anObject.profileID] forKey:kSCHLibreAccessWebServiceprofileID];
		[objects setObject:[self objectFromTranslate:anObject.isFavorite] forKey:kSCHLibreAccessWebServiceisFavorite];
		[objects setObject:[self objectFromTranslate:anObject.lastPageLocation] forKey:kSCHLibreAccessWebServicelastPageLocation];
		[objects setObject:[self objectFromTranslate:anObject.lastmodified] forKey:kSCHLibreAccessWebServiceLastModified];
		
		ret = objects;					
	}
	
	return(ret);
}

- (NSDictionary *)objectFromOrderIDItem:(LibreAccessServiceSvc_OrderIDItem *)anObject
{
	NSDictionary *ret = nil;
	
	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];
		
		[objects setObject:[self objectFromTranslate:anObject.OrderID] forKey:kSCHLibreAccessWebServiceOrderID];
		
		ret = objects;					
	}
	
	return(ret);
}

- (NSDictionary *)objectFromContentMetadataItem:(LibreAccessServiceSvc_ContentMetadataItem *)anObject
{
	NSDictionary *ret = nil;
	
	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];
		
		[objects setObject:[self objectFromTranslate:anObject.ContentIdentifier] forKey:kSCHLibreAccessWebServiceContentIdentifier];
		[objects setObject:[self objectFromTranslate:[NSNumber numberWithContentIdentifierType:anObject.ContentIdentifierType]] forKey:kSCHLibreAccessWebServiceContentIdentifierType];
		[objects setObject:[self objectFromTranslate:anObject.Title] forKey:kSCHLibreAccessWebServiceTitle];
		[objects setObject:[self objectFromTranslate:anObject.Author] forKey:kSCHLibreAccessWebServiceAuthor];
		[objects setObject:[self objectFromTranslate:anObject.Description] forKey:kSCHLibreAccessWebServiceDescription];
		[objects setObject:[self objectFromTranslate:anObject.Version] forKey:kSCHLibreAccessWebServiceVersion];
		[objects setObject:[self objectFromTranslate:anObject.PageNumber] forKey:kSCHLibreAccessWebServicePageNumber];
		[objects setObject:[self objectFromTranslate:anObject.FileSize] forKey:kSCHLibreAccessWebServiceFileSize];
		[objects setObject:[self objectFromTranslate:[NSNumber numberWithDRMQualifier:anObject.DRMQualifier]] forKey:kSCHLibreAccessWebServiceDRMQualifier];
		[objects setObject:[self objectFromTranslate:anObject.CoverURL] forKey:kSCHLibreAccessWebServiceCoverURL];
		[objects setObject:[self objectFromTranslate:anObject.ContentURL] forKey:kSCHLibreAccessWebServiceContentURL];
//		[objects setObject:[self objectFromTranslate:anObject.EreaderCategories] forKey:kLibreAccessWebServiceEreaderCategories];
		[objects setObject:[self objectFromTranslate:[NSNumber numberWithProductType:anObject.ProductType]] forKey:kSCHLibreAccessWebServiceProductType];
				
		ret = objects;					
	}
	
	return(ret);
}

- (NSDictionary *)objectFromProfileStatusItem:(LibreAccessServiceSvc_ProfileStatusItem *)anObject
{
	NSDictionary *ret = nil;
	
	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];
		
		[objects setObject:[self objectFromTranslate:anObject.id_] forKey:kSCHLibreAccessWebServiceID];
		[objects setObject:[self objectFromTranslate:[NSNumber numberWithSaveAction:anObject.action]] forKey:kSCHLibreAccessWebServiceAction];
		[objects setObject:[self objectFromTranslate:[NSNumber numberWithStatusCode:anObject.status]] forKey:kSCHLibreAccessWebServiceStatus];
		[objects setObject:[self objectFromTranslate:anObject.screenname] forKey:kSCHLibreAccessWebServiceScreenname];
		[objects setObject:[self objectFromTranslate:anObject.statuscode] forKey:kSCHLibreAccessWebServiceStatuscode];
		[objects setObject:[self objectFromTranslate:anObject.statusmessage] forKey:kSCHLibreAccessWebServiceStatusmessage];
		
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
			} else if ([item isKindOfClass:[LibreAccessServiceSvc_ProfileStatusItem class]] == YES) {
				[ret addObject:[self objectFromProfileStatusItem:item]];													
			}		
		}		
	} else if([anObject isKindOfClass:[USBoolean class]] == YES) {
		ret = [NSNumber numberWithBool:[anObject boolValue]];
	} else {
		ret = anObject;
	}

	return(ret);
}

#pragma mark -
#pragma mark ObjectMapper fromObject: converter methods 

- (void)fromObject:(NSDictionary *)object intoSaveProfileItem:(LibreAccessServiceSvc_SaveProfileItem **)intoObject
{
	if (object != nil && intoObject != nil) {
		(*intoObject).AutoAssignContentToProfiles = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceAutoAssignContentToProfiles]];
		(*intoObject).ProfilePasswordRequired = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceProfilePasswordRequired]];
		(*intoObject).Firstname = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceFirstname]];
		(*intoObject).Lastname = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceLastname]];
		(*intoObject).BirthDay = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceBirthDay]];
		(*intoObject).LastModified = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceLastModified]];
		(*intoObject).screenname = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceScreenname]];
		(*intoObject).password = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServicePassword]];
		(*intoObject).userkey = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceUserkey]];
		(*intoObject).type = [[object objectForKey:kSCHLibreAccessWebServiceType] profileTypeValue];
		(*intoObject).id_ = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceID]];
		(*intoObject).action = [[object objectForKey:kSCHLibreAccessWebServiceAction] saveActionValue];
		(*intoObject).BookshelfStyle = [[object objectForKey:kSCHLibreAccessWebServiceBookshelfStyle] bookshelfStyleValue];
		(*intoObject).storyInteractionEnabled = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceStoryInteractionEnabled]];
	}
}

- (void)fromObject:(NSDictionary *)object intoISBNItem:(LibreAccessServiceSvc_isbnItem **)intoObject
{
	if (object != nil && intoObject != nil) {
		(*intoObject).ISBN = [object objectForKey:kSCHLibreAccessWebServiceContentIdentifier];
		(*intoObject).Format = [object objectForKey:kSCHLibreAccessWebServiceFormat];
		(*intoObject).IdentifierType = [[object objectForKey:kSCHLibreAccessWebServiceContentIdentifierType] contentIdentifierTypeValue];
		(*intoObject).Qualifier = [[object objectForKey:kSCHLibreAccessWebServiceDRMQualifier] DRMQualifierValue];
	}
}

- (id)fromObjectTranslate:(id)anObject
{
	static Class boolClass = nil;
	id ret = nil;
	
	if (boolClass == nil) {
		boolClass = [[[NSNumber numberWithBool:YES] class] retain];
	}
	
	if (anObject != nil) {
		if ([anObject isKindOfClass:boolClass] == YES) {
			ret = [[[USBoolean alloc] initWithBool:[anObject boolValue]] autorelease];
		} else if (anObject == [NSNull null]) {
			ret = nil;
		} else {
			ret = anObject;
		}
	}
	
	return(ret);
}


@end
