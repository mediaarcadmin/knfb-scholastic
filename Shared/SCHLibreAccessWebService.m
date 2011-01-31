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
#import "SCHAuthenticationManager.h"


static NSString * const kSCHLibreAccessWebServiceUndefinedMethod = @"undefined method";
static NSString * const kSCHLibreAccessWebServiceStatusHolderStatusMessage = @"statusmessage";


@interface SCHLibreAccessWebService ()

- (NSError *)errorFromStatusMessage:(LibreAccessServiceSvc_StatusHolder *)statusMessage;
- (NSString *)methodNameFromObject:(id)anObject;

- (NSDictionary *)objectFromTokenExchangeResponse:(LibreAccessServiceSvc_TokenExchangeResponse *)anObject;
- (NSDictionary *)objectFromProfileItem:(LibreAccessServiceSvc_ProfileItem *)anObject;
- (NSDictionary *)objectFromUserContentItem:(LibreAccessServiceSvc_UserContentItem *)anObject;
- (NSDictionary *)objectFromContentProfileItem:(LibreAccessServiceSvc_ContentProfileItem *)anObject;
- (NSDictionary *)objectFromOrderItem:(LibreAccessServiceSvc_OrderItem *)anObject;
- (NSDictionary *)objectFromContentMetadataItem:(LibreAccessServiceSvc_ContentMetadataItem *)anObject;
- (NSDictionary *)objectFromProfileStatusItem:(LibreAccessServiceSvc_ProfileStatusItem *)anObject;
- (NSDictionary *)objectFromAnnotationsItem:(LibreAccessServiceSvc_AnnotationsItem *)anObject;
- (NSDictionary *)objectFromAnnotationsContentItem:(LibreAccessServiceSvc_AnnotationsContentItem *)anObject;
- (NSDictionary *)objectFromPrivateAnnotations:(LibreAccessServiceSvc_PrivateAnnotations *)anObject;
- (NSDictionary *)objectFromHighlight:(LibreAccessServiceSvc_Highlight *)anObject;
- (NSDictionary *)objectFromLocationText:(LibreAccessServiceSvc_LocationText *)anObject;
- (NSDictionary *)objectFromWordIndex:(LibreAccessServiceSvc_WordIndex *)anObject;
- (NSDictionary *)objectFromNote:(LibreAccessServiceSvc_Note *)anObject;
- (NSDictionary *)objectFromLocationGraphics:(LibreAccessServiceSvc_LocationGraphics *)anObject;
- (NSDictionary *)objectFromCoords:(LibreAccessServiceSvc_Coords *)anObject;
- (NSDictionary *)objectFromFavorite:(LibreAccessServiceSvc_Favorite *)anObject;
- (NSDictionary *)objectFromBookmark:(LibreAccessServiceSvc_Bookmark *)anObject;
- (NSDictionary *)objectFromLastPage:(LibreAccessServiceSvc_LastPage *)anObject;
- (NSDictionary *)objectFromItemsCount:(LibreAccessServiceSvc_ItemsCount *)anObject;

- (id)objectFromTranslate:(id)anObject;

- (void)fromObject:(NSDictionary *)object intoSaveProfileItem:(LibreAccessServiceSvc_SaveProfileItem *)intoObject;
- (void)fromObject:(NSDictionary *)object intoISBNItem:(LibreAccessServiceSvc_isbnItem *)intoObject;
- (void)fromObject:(NSDictionary *)object intoUserSettingsItem:(LibreAccessServiceSvc_UserSettingsItem *)intoObject;
- (void)fromObject:(NSDictionary *)object intoAnnotationsRequestContentItem:(LibreAccessServiceSvc_AnnotationsRequestContentItem *)intoObject;
- (void)fromObject:(NSDictionary *)object intoPrivateAnnotationsRequest:(LibreAccessServiceSvc_PrivateAnnotationsRequest *)intoObject;
- (void)fromObject:(NSDictionary *)object intoAnnotationsItem:(LibreAccessServiceSvc_AnnotationsItem *)intoObject;
- (void)fromObject:(NSDictionary *)object intoAnnotationsContentItem:(LibreAccessServiceSvc_AnnotationsContentItem *)intoObject;
- (void)fromObject:(NSDictionary *)object intoPrivateAnnotations:(LibreAccessServiceSvc_PrivateAnnotations *)intoObject;
- (void)fromObject:(NSDictionary *)object intoHighlight:(LibreAccessServiceSvc_Highlight *)intoObject;
- (void)fromObject:(NSDictionary *)object intoLocationText:(LibreAccessServiceSvc_LocationText *)intoObject;
- (void)fromObject:(NSDictionary *)object intoWordIndex:(LibreAccessServiceSvc_WordIndex *)intoObject;
- (void)fromObject:(NSDictionary *)object intoNote:(LibreAccessServiceSvc_Note *)intoObject;
- (void)fromObject:(NSDictionary *)object intoLocationGraphics:(LibreAccessServiceSvc_LocationGraphics *)intoObject;
- (void)fromObject:(NSDictionary *)object intoCoords:(LibreAccessServiceSvc_Coords *)intoObject;
- (void)fromObject:(NSDictionary *)object intoFavorite:(LibreAccessServiceSvc_Favorite *)intoObject;
- (void)fromObject:(NSDictionary *)object intoBookmark:(LibreAccessServiceSvc_Bookmark *)intoObject;
- (void)fromObject:(NSDictionary *)object intoLastPage:(LibreAccessServiceSvc_LastPage *)intoObject;
- (void)fromObject:(NSDictionary *)object intoContentProfileAssignmentItem:(LibreAccessServiceSvc_ContentProfileAssignmentItem *)intoObject;
- (void)fromObject:(NSDictionary *)object intoAssignedProfileItem:(LibreAccessServiceSvc_AssignedProfileItem *)intoObject;
- (void)fromObject:(NSDictionary *)object intoReadingStatsDetailItem:(LibreAccessServiceSvc_ReadingStatsDetailItem *)intoObject;
- (void)fromObject:(NSDictionary *)object intoReadingStatsContentItem:(LibreAccessServiceSvc_ReadingStatsContentItem *)intoObject;
- (void)fromObject:(NSDictionary *)object intoReadingStatsEntryItem:(LibreAccessServiceSvc_ReadingStatsEntryItem *)intoObject;

- (id)fromObjectTranslate:(id)anObject;

@end


@implementation SCHLibreAccessWebService

#pragma mark -
#pragma mark Memory management

- (id)init
{
	self = [super init];
	if (self != nil) {
		binding = [[LibreAccessServiceSvc LibreAccessServiceSoap11Binding] retain];
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

- (BOOL)getUserProfiles
{
	BOOL ret = NO;
	
	if ([SCHAuthenticationManager sharedAuthenticationManager].isAuthenticated == YES) {		
		LibreAccessServiceSvc_GetUserProfilesRequest *request = [LibreAccessServiceSvc_GetUserProfilesRequest new];
		
		request.authtoken = [SCHAuthenticationManager sharedAuthenticationManager].aToken;
		
		[binding GetUserProfilesAsyncUsingParameters:request delegate:self]; 
		
		[request release], request = nil;
		ret = YES;
	}
	
	return(ret);	
}

- (BOOL)saveUserProfiles:(NSArray *)userProfiles
{
	BOOL ret = NO;
	
	if ([SCHAuthenticationManager sharedAuthenticationManager].isAuthenticated == YES) {		
		LibreAccessServiceSvc_SaveUserProfilesRequest *request = [LibreAccessServiceSvc_SaveUserProfilesRequest new];
		
		request.authtoken = [SCHAuthenticationManager sharedAuthenticationManager].aToken;
		request.SaveProfileList = [[LibreAccessServiceSvc_SaveProfileList alloc] init];
		LibreAccessServiceSvc_SaveProfileItem *item = nil;
		for (id profile in userProfiles) {
			item = [[LibreAccessServiceSvc_SaveProfileItem alloc] init];
			[self fromObject:profile intoObject:item];		
			[request.SaveProfileList addSaveProfileItem:item];	
			[item release], item = nil;
		}	
		[request.SaveProfileList release];
		
		[binding SaveUserProfilesAsyncUsingParameters:request delegate:self]; 
		
		[request release], request = nil;
		ret = YES;
	}
	
	return(ret);		
}

- (BOOL)listUserContent
{
	BOOL ret = NO;
	
	if ([SCHAuthenticationManager sharedAuthenticationManager].isAuthenticated == YES) {		
		LibreAccessServiceSvc_ListUserContent *request = [LibreAccessServiceSvc_ListUserContent new];
		
		request.authtoken = [SCHAuthenticationManager sharedAuthenticationManager].aToken;
		
		[binding ListUserContentAsyncUsingBody:request delegate:self]; 
		
		[request release], request = nil;	
		ret = YES;
	}
	
	return(ret);			
}

- (BOOL)listContentMetadata:(NSArray *)bookISBNs includeURLs:(BOOL)includeURLs
{
	BOOL ret = NO;
	
	if ([SCHAuthenticationManager sharedAuthenticationManager].isAuthenticated == YES) {				
		LibreAccessServiceSvc_ListContentMetadata *request = [LibreAccessServiceSvc_ListContentMetadata new];
		
		request.authtoken = [SCHAuthenticationManager sharedAuthenticationManager].aToken;
		USBoolean *includeurls = [[USBoolean alloc] initWithBool:includeURLs];
		request.includeurls = includeurls;
		[includeurls release], includeurls = nil;	
		LibreAccessServiceSvc_isbnItem *item = nil;
		for (id book in bookISBNs) {
			item = [[LibreAccessServiceSvc_isbnItem alloc] init];
			[self fromObject:book intoObject:item];
			[request addIsbn13s:item];	
			[item release], item = nil;
		}
		
		[binding ListContentMetadataAsyncUsingBody:request delegate:self]; 
		
		[request release], request = nil;
		ret = YES;
	}
	
	return(ret);				
}

- (BOOL)listUserSettings
{
	BOOL ret = NO;
	
	if ([SCHAuthenticationManager sharedAuthenticationManager].isAuthenticated == YES) {						
		LibreAccessServiceSvc_ListUserSettingsRequest *request = [LibreAccessServiceSvc_ListUserSettingsRequest new];
		
		request.authtoken = [SCHAuthenticationManager sharedAuthenticationManager].aToken;
		
		[binding ListUserSettingsAsyncUsingParameters:request delegate:self]; 
		
		[request release], request = nil;	
		ret = YES;
	}
	
	return(ret);					
}

- (BOOL)saveUserSettings:(NSArray *)settings
{
	BOOL ret = NO;
	
	if ([SCHAuthenticationManager sharedAuthenticationManager].isAuthenticated == YES) {								
		LibreAccessServiceSvc_SaveUserSettingsRequest *request = [LibreAccessServiceSvc_SaveUserSettingsRequest new];
		
		request.authtoken = [SCHAuthenticationManager sharedAuthenticationManager].aToken;
		request.UserSettingsList = [[LibreAccessServiceSvc_UserSettingsList alloc] init];
		LibreAccessServiceSvc_UserSettingsItem *item = nil;
		for (id setting in settings) {
			item = [[LibreAccessServiceSvc_UserSettingsItem alloc] init];
			[self fromObject:setting intoObject:item];
			[request.UserSettingsList addUserSettingsItem:item];	
			[item release], item = nil;
		}
		[request.UserSettingsList release];
		
		[binding SaveUserSettingsAsyncUsingParameters:request delegate:self]; 
		
		[request release], request = nil;
		ret = YES;
	}
	
	return(ret);						
}

- (BOOL)listProfileContentAnnotations:(NSArray *)annotations forProfile:(NSNumber *)profileID
{
	BOOL ret = NO;
	
	if ([SCHAuthenticationManager sharedAuthenticationManager].isAuthenticated == YES) {								
		LibreAccessServiceSvc_ListProfileContentAnnotationsRequest *request = [LibreAccessServiceSvc_ListProfileContentAnnotationsRequest new];
		
		request.authtoken = [SCHAuthenticationManager sharedAuthenticationManager].aToken;
		request.AnnotationsRequestList = [[LibreAccessServiceSvc_AnnotationsRequestList alloc] init];
		request.AnnotationsRequestList.profileID = profileID;
		request.AnnotationsRequestList.AnnotationsRequestItem = [[LibreAccessServiceSvc_AnnotationsRequestItem alloc] init];
		request.AnnotationsRequestList.AnnotationsRequestItem.AnnotationsRequestContentList = [[LibreAccessServiceSvc_AnnotationsRequestContentList alloc] init];
		
		LibreAccessServiceSvc_AnnotationsRequestContentItem *item = nil;
		for (id annotation in annotations) {
			item = [[LibreAccessServiceSvc_AnnotationsRequestContentItem alloc] init];
			[self fromObject:annotation intoObject:item];
			[request.AnnotationsRequestList.AnnotationsRequestItem.AnnotationsRequestContentList addAnnotationsRequestContentItem:item];
			[item release], item = nil;
		}
		[request.AnnotationsRequestList.AnnotationsRequestItem.AnnotationsRequestContentList release];
		[request.AnnotationsRequestList.AnnotationsRequestItem release];
		[request.AnnotationsRequestList release];
		
		[binding ListProfileContentAnnotationsAsyncUsingParameters:request delegate:self]; 
		
		[request release], request = nil;
		ret = YES;
	}
	
	return(ret);							
}

// TODO: implement in Core Data
- (BOOL)saveProfileContentAnnotations:(NSArray *)annotations
{
	BOOL ret = NO;
	
	if ([SCHAuthenticationManager sharedAuthenticationManager].isAuthenticated == YES) {										
		LibreAccessServiceSvc_SaveProfileContentAnnotationsRequest *request = [LibreAccessServiceSvc_SaveProfileContentAnnotationsRequest new];
		
		request.authtoken = [SCHAuthenticationManager sharedAuthenticationManager].aToken;
		request.AnnotationsList = [[LibreAccessServiceSvc_AnnotationsList alloc] init];
		LibreAccessServiceSvc_AnnotationsItem *item = nil;
		for (id annotation in annotations) {
			item = [[LibreAccessServiceSvc_AnnotationsItem alloc] init];
			[self fromObject:annotation intoObject:item];
			[request.AnnotationsList addAnnotationsItem:item];
			[item release], item = nil;
		}
		[request.AnnotationsList release];
		
		[binding SaveProfileContentAnnotationsAsyncUsingParameters:request delegate:self]; 
		
		[request release], request = nil;		
		ret = YES;
	}
	
	return(ret);								
}

- (BOOL)saveContentProfileAssignment:(NSArray *)contentProfileAssignments
{
	BOOL ret = NO;
	
	if ([SCHAuthenticationManager sharedAuthenticationManager].isAuthenticated == YES) {												
		LibreAccessServiceSvc_SaveContentProfileAssignmentRequest *request = [LibreAccessServiceSvc_SaveContentProfileAssignmentRequest new];
		
		request.authtoken = [SCHAuthenticationManager sharedAuthenticationManager].aToken;
		request.ContentProfileAssignmentList = [[LibreAccessServiceSvc_ContentProfileAssignmentList alloc] init];
		LibreAccessServiceSvc_ContentProfileAssignmentItem *item = nil;
		for (id contentProfileAssignment in contentProfileAssignments) {
			item = [[LibreAccessServiceSvc_ContentProfileAssignmentItem alloc] init];
			[self fromObject:contentProfileAssignment intoObject:item];
			[request.ContentProfileAssignmentList addContentProfileAssignmentItem:item];
			[item release], item = nil;
		}
		[request.ContentProfileAssignmentList release];
		
		[binding SaveContentProfileAssignmentAsyncUsingParameters:request delegate:self]; 
		
		[request release], request = nil;	
		ret = YES;
	}
	
	return(ret);									
}

- (BOOL)saveReadingStatisticsDetailed:(NSArray *)readingStatsDetailList
{
	BOOL ret = NO;
	
	if ([SCHAuthenticationManager sharedAuthenticationManager].isAuthenticated == YES) {												
		LibreAccessServiceSvc_SaveReadingStatisticsDetailedRequest *request = [LibreAccessServiceSvc_SaveReadingStatisticsDetailedRequest new];
		
		request.authtoken = [SCHAuthenticationManager sharedAuthenticationManager].aToken;
		request.ReadingStatsDetailList = [[LibreAccessServiceSvc_ReadingStatsDetailList alloc] init];
		LibreAccessServiceSvc_ReadingStatsDetailItem *item = nil;
		for (id readingStatsDetail in readingStatsDetailList) {
			item = [[LibreAccessServiceSvc_ReadingStatsDetailItem alloc] init];
			[self fromObject:readingStatsDetail intoObject:item];
			[request.ReadingStatsDetailList addReadingStatsDetailItem:item];
			[item release], item = nil;
		}
		[request.ReadingStatsDetailList release];
		
		[binding SaveReadingStatisticsDetailedAsyncUsingParameters:request delegate:self]; 
		
		[request release], request = nil;	
		ret = YES;
	}
	
	return(ret);										
}

#pragma mark -
#pragma mark LibreAccessServiceSoap12BindingResponse Delegate methods

- (void)operation:(LibreAccessServiceSoap11BindingOperation *)operation completedWithResponse:(LibreAccessServiceSoap11BindingResponse *)response
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
				status = (LibreAccessServiceSvc_StatusHolder *)[bodyPart valueForKey:kSCHLibreAccessWebServiceStatusHolderStatusMessage];
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
		   [anObject isKindOfClass:[LibreAccessServiceSoap11Binding_TokenExchange class]] == YES) {
			ret = kSCHLibreAccessWebServiceTokenExchange;	
		} else if([anObject isKindOfClass:[LibreAccessServiceSvc_GetUserProfilesRequest class]] == YES ||
				  [anObject isKindOfClass:[LibreAccessServiceSvc_GetUserProfilesResponse class]] == YES ||
				  [anObject isKindOfClass:[LibreAccessServiceSoap11Binding_GetUserProfiles class]] == YES) {
			ret = kSCHLibreAccessWebServiceGetUserProfiles;	
		} else if([anObject isKindOfClass:[LibreAccessServiceSvc_ListUserContent class]] == YES ||
				  [anObject isKindOfClass:[LibreAccessServiceSvc_ListUserContentResponse class]] == YES ||
				  [anObject isKindOfClass:[LibreAccessServiceSoap11Binding_ListUserContent class]] == YES) {
			ret = kSCHLibreAccessWebServiceListUserContent;	
		} else if([anObject isKindOfClass:[LibreAccessServiceSvc_ListContentMetadata class]] == YES ||
				  [anObject isKindOfClass:[LibreAccessServiceSvc_ListContentMetadataResponse class]] == YES ||
				  [anObject isKindOfClass:[LibreAccessServiceSoap11Binding_ListContentMetadata class]] == YES) {
			ret = kSCHLibreAccessWebServiceListContentMetadata;				
		} else if([anObject isKindOfClass:[LibreAccessServiceSvc_SaveUserProfilesRequest class]] == YES ||
				  [anObject isKindOfClass:[LibreAccessServiceSvc_SaveUserProfilesResponse class]] == YES ||
				  [anObject isKindOfClass:[LibreAccessServiceSoap11Binding_SaveUserProfiles class]] == YES) {
			ret = kSCHLibreAccessWebServiceSaveUserProfiles;				
		} else if([anObject isKindOfClass:[LibreAccessServiceSvc_ListUserSettingsRequest class]] == YES ||
				  [anObject isKindOfClass:[LibreAccessServiceSvc_ListUserSettingsResponse class]] == YES ||
				  [anObject isKindOfClass:[LibreAccessServiceSoap11Binding_ListUserSettings class]] == YES) {
			ret = kSCHLibreAccessWebServiceListUserSettings;				
		} else if([anObject isKindOfClass:[LibreAccessServiceSvc_SaveUserSettingsRequest class]] == YES ||
				  [anObject isKindOfClass:[LibreAccessServiceSvc_SaveUserSettingsResponse class]] == YES ||
				  [anObject isKindOfClass:[LibreAccessServiceSoap11Binding_SaveUserSettings class]] == YES) {
			ret = kSCHLibreAccessWebServiceListUserSettings;				
		} else if([anObject isKindOfClass:[LibreAccessServiceSvc_ListProfileContentAnnotationsRequest class]] == YES ||
				  [anObject isKindOfClass:[LibreAccessServiceSvc_ListProfileContentAnnotationsResponse class]] == YES ||
				  [anObject isKindOfClass:[LibreAccessServiceSoap11Binding_ListProfileContentAnnotations class]] == YES) {
			ret = kSCHLibreAccessWebServiceListProfileContentAnnotations;				
		} else if([anObject isKindOfClass:[LibreAccessServiceSvc_SaveProfileContentAnnotationsRequest class]] == YES ||
				  [anObject isKindOfClass:[LibreAccessServiceSvc_SaveProfileContentAnnotationsResponse class]] == YES ||
				  [anObject isKindOfClass:[LibreAccessServiceSoap11Binding_SaveProfileContentAnnotations class]] == YES) {
			ret = kSCHLibreAccessWebServiceSaveProfileContentAnnotations;
		} else if([anObject isKindOfClass:[LibreAccessServiceSvc_SaveContentProfileAssignmentRequest class]] == YES ||
				  [anObject isKindOfClass:[LibreAccessServiceSvc_SaveContentProfileAssignmentResponse class]] == YES ||
				  [anObject isKindOfClass:[LibreAccessServiceSoap11Binding_SaveContentProfileAssignment class]] == YES) {
			ret = kSCHLibreAccessWebServiceSaveContentProfileAssignment;
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
		} else if ([anObject isKindOfClass:[LibreAccessServiceSvc_ListUserSettingsResponse class]] == YES) {
			ret = [NSDictionary dictionaryWithObject:[self objectFromTranslate:[[anObject UserSettingsList] UserSettingsItem]] forKey:kSCHLibreAccessWebServiceUserSettingsList];
		} else if ([anObject isKindOfClass:[LibreAccessServiceSvc_ListProfileContentAnnotationsResponse class]] == YES) {
			NSDictionary *annotationsList = [NSDictionary dictionaryWithObject:[self objectFromTranslate:[[anObject AnnotationsList] AnnotationsItem]] forKey:kSCHLibreAccessWebServiceAnnotationsList];
			NSDictionary *itemsCount = [NSDictionary dictionaryWithObject:[self objectFromItemsCount:[anObject ItemsCount]] forKey:kSCHLibreAccessWebServiceItemsCount];
			ret = [NSDictionary dictionaryWithObject:[NSArray arrayWithObjects:annotationsList, itemsCount, nil] forKey:kSCHLibreAccessWebServiceListProfileContentAnnotations];
		}
	}
	
	return(ret);
}

- (void)fromObject:(NSDictionary *)object intoObject:(id)intoObject
{
	if (object != nil && intoObject != nil) {
		if ([intoObject isKindOfClass:[LibreAccessServiceSvc_SaveProfileItem class]] == YES) {
			[self fromObject:object intoSaveProfileItem:intoObject];
		} else if ([intoObject isKindOfClass:[LibreAccessServiceSvc_isbnItem class]] == YES) {
			[self fromObject:object intoISBNItem:intoObject];
		} else if ([intoObject isKindOfClass:[LibreAccessServiceSvc_UserSettingsItem class]] == YES) {
			[self fromObject:object intoUserSettingsItem:intoObject];
		} else if ([intoObject isKindOfClass:[LibreAccessServiceSvc_AnnotationsRequestContentItem class]] == YES) {
			[self fromObject:object intoAnnotationsRequestContentItem:intoObject];
		} else if ([intoObject isKindOfClass:[LibreAccessServiceSvc_AnnotationsItem class]] == YES) {
			[self fromObject:object intoAnnotationsItem:intoObject];
		} else if ([intoObject isKindOfClass:[LibreAccessServiceSvc_ContentProfileAssignmentItem class]] == YES) {
			[self fromObject:object intoContentProfileAssignmentItem:intoObject];
		} else if ([intoObject isKindOfClass:[LibreAccessServiceSvc_ReadingStatsDetailItem class]] == YES) {
			[self fromObject:object intoReadingStatsDetailItem:intoObject];
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
		[objects setObject:[self objectFromTranslate:anObject.Firstname] forKey:kSCHLibreAccessWebServiceFirstName];		
		[objects setObject:[self objectFromTranslate:anObject.Lastname] forKey:kSCHLibreAccessWebServiceLastName];		
		[objects setObject:[self objectFromTranslate:anObject.BirthDay] forKey:kSCHLibreAccessWebServiceBirthday];		
		[objects setObject:[self objectFromTranslate:anObject.screenname] forKey:kSCHLibreAccessWebServiceScreenName];		
		[objects setObject:[self objectFromTranslate:anObject.password] forKey:kSCHLibreAccessWebServicePassword];		
		[objects setObject:[self objectFromTranslate:anObject.userkey] forKey:kSCHLibreAccessWebServiceUserKey];		
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
		[objects setObject:[self objectFromTranslate:[[anObject OrderList] OrderItem]] forKey:kSCHLibreAccessWebServiceOrderList];		
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
		
		[objects setObject:[self objectFromTranslate:anObject.profileID] forKey:kSCHLibreAccessWebServiceProfileID];
		[objects setObject:[self objectFromTranslate:anObject.isFavorite] forKey:kSCHLibreAccessWebServiceIsFavorite];
		[objects setObject:[self objectFromTranslate:anObject.lastPageLocation] forKey:kSCHLibreAccessWebServiceLastPageLocation];
		[objects setObject:[self objectFromTranslate:anObject.lastmodified] forKey:kSCHLibreAccessWebServiceLastModified];
		
		ret = objects;					
	}
	
	return(ret);
}

- (NSDictionary *)objectFromOrderItem:(LibreAccessServiceSvc_OrderItem *)anObject
{
	NSDictionary *ret = nil;
	
	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];
		
		[objects setObject:[self objectFromTranslate:anObject.OrderID] forKey:kSCHLibreAccessWebServiceOrderID];
		[objects setObject:[self objectFromTranslate:anObject.OrderDate] forKey:kSCHLibreAccessWebServiceOrderDate];
		
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
		[objects setObject:[self objectFromTranslate:anObject.EreaderCategories] forKey:kSCHLibreAccessWebServiceeReaderCategories];
		[objects setObject:[self objectFromTranslate:anObject.ProductType] forKey:kSCHLibreAccessWebServiceProductType];
				
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
		[objects setObject:[self objectFromTranslate:anObject.screenname] forKey:kSCHLibreAccessWebServiceScreenName];
		[objects setObject:[self objectFromTranslate:anObject.statuscode] forKey:kSCHLibreAccessWebServiceStatusCode];
		[objects setObject:[self objectFromTranslate:anObject.statusmessage] forKey:kSCHLibreAccessWebServiceStatusMessage];
		
		ret = objects;					
	}
	
	return(ret);
}

- (NSDictionary *)objectFromUserSettingsItem:(LibreAccessServiceSvc_UserSettingsItem *)anObject
{
	NSDictionary *ret = nil;
	
	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];
		
		[objects setObject:[self objectFromTranslate:[NSNumber numberWithUserSettingsType:anObject.SettingType]] forKey:kSCHLibreAccessWebServiceSettingType];
		[objects setObject:[self objectFromTranslate:anObject.SettingValue] forKey:kSCHLibreAccessWebServiceSettingValue];
		
		ret = objects;					
	}
	
	return(ret);
}

- (NSDictionary *)objectFromAnnotationsItem:(LibreAccessServiceSvc_AnnotationsItem *)anObject
{
	NSDictionary *ret = nil;
	
	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];
		
		[objects setObject:[NSDictionary dictionaryWithObject:[self objectFromTranslate:[[anObject AnnotationsContentList] AnnotationsContentItem]] forKey:kSCHLibreAccessWebServiceAnnotationsContentList] forKey:kSCHLibreAccessWebServiceAnnotationsContentList];
		[objects setObject:[self objectFromTranslate:anObject.profileID] forKey:kSCHLibreAccessWebServiceProfileID];
		
		ret = objects;					
	}
	
	return(ret);
}

- (NSDictionary *)objectFromAnnotationsContentItem:(LibreAccessServiceSvc_AnnotationsContentItem *)anObject
{
	NSDictionary *ret = nil;
	
	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];
		
		[objects setObject:[self objectFromTranslate:anObject.contentIdentifier] forKey:kSCHLibreAccessWebServiceContentIdentifier];
		[objects setObject:[NSNumber numberWithContentIdentifierType:anObject.ContentIdentifierType] forKey:kSCHLibreAccessWebServiceContentIdentifierType];
		[objects setObject:[NSNumber numberWithDRMQualifier:anObject.drmqualifier] forKey:kSCHLibreAccessWebServiceDRMQualifier];
		[objects setObject:[self objectFromTranslate:anObject.format] forKey:kSCHLibreAccessWebServiceFormat];
		[objects setObject:[self objectFromTranslate:anObject.PrivateAnnotations] forKey:kSCHLibreAccessWebServicePrivateAnnotations];
		
		ret = objects;					
	}
	
	return(ret);
}

- (NSDictionary *)objectFromPrivateAnnotations:(LibreAccessServiceSvc_PrivateAnnotations *)anObject
{
	NSDictionary *ret = nil;
	
	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];
		
		[objects setObject:[self objectFromTranslate:[anObject.Highlights Highlight]] forKey:kSCHLibreAccessWebServiceHighlights];
		[objects setObject:[self objectFromTranslate:[anObject.Notes Note]] forKey:kSCHLibreAccessWebServiceNotes];
		[objects setObject:[self objectFromTranslate:[anObject.Bookmarks Bookmark]] forKey:kSCHLibreAccessWebServiceBookmarks];
		[objects setObject:[self objectFromFavorite:anObject.Favorite] forKey:kSCHLibreAccessWebServiceFavorite];
		[objects setObject:[self objectFromLastPage:anObject.LastPage] forKey:kSCHLibreAccessWebServiceLastPage];
		
		ret = objects;					
	}
	
	return(ret);
}

- (NSDictionary *)objectFromHighlight:(LibreAccessServiceSvc_Highlight *)anObject
{
	NSDictionary *ret = nil;
	
	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];
		
		[objects setObject:[self objectFromTranslate:anObject.id_] forKey:kSCHLibreAccessWebServiceID];
		[objects setObject:[NSNumber numberWithSaveAction:anObject.action] forKey:kSCHLibreAccessWebServiceAction];
		[objects setObject:[self objectFromTranslate:anObject.color] forKey:kSCHLibreAccessWebServiceColor];
		[objects setObject:[self objectFromLocationText:anObject.location] forKey:kSCHLibreAccessWebServiceLocation];
		[objects setObject:[self objectFromTranslate:anObject.endPage] forKey:kSCHLibreAccessWebServiceEndPage];
		[objects setObject:[self objectFromTranslate:anObject.version] forKey:kSCHLibreAccessWebServiceVersion];		
		[objects setObject:[self objectFromTranslate:anObject.lastmodified] forKey:kSCHLibreAccessWebServiceLastModified];
		
		ret = objects;					
	}
	
	return(ret);
}

- (NSDictionary *)objectFromLocationText:(LibreAccessServiceSvc_LocationText *)anObject
{
	NSDictionary *ret = nil;
	
	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];
		
		[objects setObject:[self objectFromTranslate:anObject.page] forKey:kSCHLibreAccessWebServicePage];
		[objects setObject:[self objectFromWordIndex:anObject.wordindex] forKey:kSCHLibreAccessWebServiceWordIndex];
		
		ret = objects;					
	}
	
	return(ret);
}

- (NSDictionary *)objectFromWordIndex:(LibreAccessServiceSvc_WordIndex *)anObject
{
	NSDictionary *ret = nil;
	
	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];
		
		[objects setObject:[self objectFromTranslate:anObject.start] forKey:kSCHLibreAccessWebServiceStart];
		[objects setObject:[self objectFromTranslate:anObject.end] forKey:kSCHLibreAccessWebServiceEnd];
		
		ret = objects;					
	}
	
	return(ret);
}

- (NSDictionary *)objectFromNote:(LibreAccessServiceSvc_Note *)anObject
{
	NSDictionary *ret = nil;
	
	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];
		
		[objects setObject:[self objectFromTranslate:anObject.id_] forKey:kSCHLibreAccessWebServiceID];
		[objects setObject:[NSNumber numberWithSaveAction:anObject.action] forKey:kSCHLibreAccessWebServiceAction];
		[objects setObject:[self objectFromLocationGraphics:anObject.location] forKey:kSCHLibreAccessWebServiceLocationGraphics];
		[objects setObject:[self objectFromTranslate:anObject.color] forKey:kSCHLibreAccessWebServiceColor];
		[objects setObject:[self objectFromTranslate:anObject.value] forKey:kSCHLibreAccessWebServiceValue];
		[objects setObject:[self objectFromTranslate:anObject.version] forKey:kSCHLibreAccessWebServiceVersion];
		[objects setObject:[self objectFromTranslate:anObject.lastmodified] forKey:kSCHLibreAccessWebServiceLastModified];
		
		ret = objects;					
	}
	
	return(ret);
}

- (NSDictionary *)objectFromLocationGraphics:(LibreAccessServiceSvc_LocationGraphics *)anObject
{
	NSDictionary *ret = nil;
	
	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];
		
		[objects setObject:[self objectFromTranslate:anObject.page] forKey:kSCHLibreAccessWebServicePage];
		[objects setObject:[self objectFromCoords:anObject.coords] forKey:kSCHLibreAccessWebServiceCoords];
		[objects setObject:[self objectFromTranslate:anObject.wordindex] forKey:kSCHLibreAccessWebServiceWordIndex];
		
		ret = objects;					
	}
	
	return(ret);
}

- (NSDictionary *)objectFromCoords:(LibreAccessServiceSvc_Coords *)anObject
{
	NSDictionary *ret = nil;
	
	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];
		
		[objects setObject:[self objectFromTranslate:anObject.x] forKey:kSCHLibreAccessWebServiceX];
		[objects setObject:[self objectFromTranslate:anObject.y] forKey:kSCHLibreAccessWebServiceY];
		
		ret = objects;					
	}
	
	return(ret);
}

- (NSDictionary *)objectFromFavorite:(LibreAccessServiceSvc_Favorite *)anObject
{
	NSDictionary *ret = nil;
	
	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];
		
		[objects setObject:[self objectFromTranslate:anObject.isFavorite] forKey:kSCHLibreAccessWebServiceIsFavorite];
		[objects setObject:[self objectFromTranslate:anObject.lastmodified] forKey:kSCHLibreAccessWebServiceLastModified];
		
		ret = objects;					
	}
	
	return(ret);
}

- (NSDictionary *)objectFromBookmark:(LibreAccessServiceSvc_Bookmark *)anObject
{
	NSDictionary *ret = nil;
	
	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];
		
		[objects setObject:[self objectFromTranslate:anObject.id_] forKey:kSCHLibreAccessWebServiceID];
		[objects setObject:[NSNumber numberWithSaveAction:anObject.action] forKey:kSCHLibreAccessWebServiceAction];
		[objects setObject:[self objectFromTranslate:anObject.text] forKey:kSCHLibreAccessWebServiceText];
		[objects setObject:[self objectFromTranslate:anObject.disabled] forKey:kSCHLibreAccessWebServiceDisabled];
		[objects setObject:[self objectFromTranslate:[anObject.location page]] forKey:kSCHLibreAccessWebServiceLocation];
		[objects setObject:[self objectFromTranslate:anObject.version] forKey:kSCHLibreAccessWebServiceVersion];
		[objects setObject:[self objectFromTranslate:anObject.lastmodified] forKey:kSCHLibreAccessWebServiceLastModified];
		
		ret = objects;					
	}
	
	return(ret);
}

- (NSDictionary *)objectFromLastPage:(LibreAccessServiceSvc_LastPage *)anObject
{
	NSDictionary *ret = nil;
	
	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];
		
		[objects setObject:[self objectFromTranslate:anObject.lastPageLocation] forKey:kSCHLibreAccessWebServiceLastPageLocation];
		[objects setObject:[self objectFromTranslate:anObject.percentage] forKey:kSCHLibreAccessWebServicePercentage];
		[objects setObject:[self objectFromTranslate:anObject.component] forKey:kSCHLibreAccessWebServiceComponent];
		[objects setObject:[self objectFromTranslate:anObject.lastmodified] forKey:kSCHLibreAccessWebServiceLastModified];
		
		ret = objects;					
	}
	
	return(ret);
}

- (NSDictionary *)objectFromItemsCount:(LibreAccessServiceSvc_ItemsCount *)anObject
{
	NSDictionary *ret = nil;
	
	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];
		
		[objects setObject:[self objectFromTranslate:anObject.Returned] forKey:kSCHLibreAccessWebServiceReturned];
		[objects setObject:[self objectFromTranslate:anObject.Found] forKey:kSCHLibreAccessWebServiceFound];
		
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
			} else if ([item isKindOfClass:[LibreAccessServiceSvc_OrderItem class]] == YES) {
				[ret addObject:[self objectFromOrderItem:item]];									
			} else if ([item isKindOfClass:[LibreAccessServiceSvc_ContentMetadataItem class]] == YES) {
				[ret addObject:[self objectFromContentMetadataItem:item]];													
			} else if ([item isKindOfClass:[LibreAccessServiceSvc_ProfileStatusItem class]] == YES) {
				[ret addObject:[self objectFromProfileStatusItem:item]];													
			} else if ([item isKindOfClass:[LibreAccessServiceSvc_UserSettingsItem class]] == YES) {
				[ret addObject:[self objectFromUserSettingsItem:item]];	
			} else if ([item isKindOfClass:[LibreAccessServiceSvc_AnnotationsItem class]] == YES) {
				[ret addObject:[self objectFromAnnotationsItem:item]];	
			} else if ([item isKindOfClass:[LibreAccessServiceSvc_AnnotationsContentItem class]] == YES) {
				[ret addObject:[self objectFromAnnotationsContentItem:item]];	
			} else if ([item isKindOfClass:[LibreAccessServiceSvc_PrivateAnnotations class]] == YES) {
				[ret addObject:[self objectFromPrivateAnnotations:item]];	
			} else if ([item isKindOfClass:[LibreAccessServiceSvc_Highlight class]] == YES) {
				[ret addObject:[self objectFromHighlight:item]];	
			} else if ([item isKindOfClass:[LibreAccessServiceSvc_Notes class]] == YES) {
				[ret addObject:[self objectFromNote:item]];	
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

- (void)fromObject:(NSDictionary *)object intoSaveProfileItem:(LibreAccessServiceSvc_SaveProfileItem *)intoObject
{
	if (object != nil && intoObject != nil) {
		intoObject.AutoAssignContentToProfiles = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceAutoAssignContentToProfiles]];
		intoObject.ProfilePasswordRequired = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceProfilePasswordRequired]];
		intoObject.Firstname = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceFirstName]];
		intoObject.Lastname = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceLastName]];
		intoObject.BirthDay = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceBirthday]];
		intoObject.LastModified = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceLastModified]];
		intoObject.screenname = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceScreenName]];
		intoObject.password = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServicePassword]];
		intoObject.userkey = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceUserKey]];
		intoObject.type = [[object objectForKey:kSCHLibreAccessWebServiceType] profileTypeValue];
		intoObject.id_ = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceID]];
		intoObject.action = [[object objectForKey:kSCHLibreAccessWebServiceAction] saveActionValue];
		intoObject.BookshelfStyle = [[object objectForKey:kSCHLibreAccessWebServiceBookshelfStyle] bookshelfStyleValue];
		intoObject.storyInteractionEnabled = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceStoryInteractionEnabled]];
	}
}

- (void)fromObject:(NSDictionary *)object intoISBNItem:(LibreAccessServiceSvc_isbnItem *)intoObject
{
	if (object != nil && intoObject != nil) {
		intoObject.ISBN = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceContentIdentifier]];
		intoObject.Format = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceFormat]];
		intoObject.IdentifierType = [[object objectForKey:kSCHLibreAccessWebServiceContentIdentifierType] contentIdentifierTypeValue];
		intoObject.Qualifier = [[object objectForKey:kSCHLibreAccessWebServiceDRMQualifier] DRMQualifierValue];
	}
}

- (void)fromObject:(NSDictionary *)object intoUserSettingsItem:(LibreAccessServiceSvc_UserSettingsItem *)intoObject
{
	if (object != nil && intoObject != nil) {
		intoObject.SettingType = [[object objectForKey:kSCHLibreAccessWebServiceSettingType] userSettingsTypeValue];
		intoObject.SettingValue = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceSettingValue]];
	}
}

- (void)fromObject:(NSDictionary *)object intoAnnotationsRequestContentItem:(LibreAccessServiceSvc_AnnotationsRequestContentItem *)intoObject
{
	if (object != nil && intoObject != nil) {
		intoObject.contentIdentifier = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceContentIdentifier]];
		intoObject.ContentIdentifierType = [[object objectForKey:kSCHLibreAccessWebServiceContentIdentifierType] contentIdentifierTypeValue];
		intoObject.drmqualifier = [[object objectForKey:kSCHLibreAccessWebServiceDRMQualifier] DRMQualifierValue];
		intoObject.format = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceFormat]];
		intoObject.PrivateAnnotationsRequest = [[LibreAccessServiceSvc_PrivateAnnotationsRequest alloc] init];
		[self fromObject:[object objectForKey:kSCHLibreAccessWebServicePrivateAnnotations] intoPrivateAnnotationsRequest:intoObject.PrivateAnnotationsRequest];
		[intoObject.PrivateAnnotationsRequest release];
	}
}

- (void)fromObject:(NSDictionary *)object intoPrivateAnnotationsRequest:(LibreAccessServiceSvc_PrivateAnnotationsRequest *)intoObject
{
	if (object != nil && intoObject != nil) {
		intoObject.version = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceVersion]];		
		intoObject.HighlightsAfter = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceHighlightsAfter]];
		intoObject.NotesAfter = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceNotesAfter]];
		intoObject.BookmarksAfter = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceBookmarksAfter]];
	}
}	

- (void)fromObject:(NSDictionary *)object intoAnnotationsItem:(LibreAccessServiceSvc_AnnotationsItem *)intoObject
{
	if (object != nil && intoObject != nil) {
		intoObject.AnnotationsContentList = [[LibreAccessServiceSvc_AnnotationsContentList alloc] init];
		for (NSDictionary *item in [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceAnnotationsContentList]]) {
			LibreAccessServiceSvc_AnnotationsContentItem *annotationsContentItem = [[LibreAccessServiceSvc_AnnotationsContentItem alloc] init];
			[self fromObject:item intoAnnotationsContentItem:annotationsContentItem];
			[intoObject.AnnotationsContentList addAnnotationsContentItem:annotationsContentItem];
			[annotationsContentItem release];
		}
		[intoObject.AnnotationsContentList release];
		intoObject.profileID = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceProfileID]];
	}
}												

- (void)fromObject:(NSDictionary *)object intoAnnotationsContentItem:(LibreAccessServiceSvc_AnnotationsContentItem *)intoObject
{
	if (object != nil && intoObject != nil) {
		intoObject.contentIdentifier = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceContentIdentifier]];
		intoObject.ContentIdentifierType = [[self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceContentIdentifierType]] contentIdentifierType];
		intoObject.drmqualifier = [[self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceDRMQualifier]] DRMQualifier];		
		intoObject.format = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceFormat]];
		intoObject.PrivateAnnotations = [[LibreAccessServiceSvc_PrivateAnnotations alloc] init];
		[self fromObject:[object objectForKey:kSCHLibreAccessWebServicePrivateAnnotations] intoPrivateAnnotations:intoObject.PrivateAnnotations];
		[intoObject.PrivateAnnotations release];
	}
}												

- (void)fromObject:(NSDictionary *)object intoPrivateAnnotations:(LibreAccessServiceSvc_PrivateAnnotations *)intoObject
{
	if (object != nil && intoObject != nil) {
		intoObject.Highlights = [[LibreAccessServiceSvc_Highlights alloc] init];
		for (NSDictionary *item in [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceHighlights]]) {
			LibreAccessServiceSvc_Highlight *highlight = [[LibreAccessServiceSvc_Highlight alloc] init];
			[self fromObject:item intoHighlight:highlight];
			[intoObject.Highlights addHighlight:highlight];
			[highlight release], highlight = nil;
		}
		[intoObject.Highlights release];
		
		intoObject.Notes = [[LibreAccessServiceSvc_Notes alloc] init];
		for (NSDictionary *item in [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceNotes]]) {
			LibreAccessServiceSvc_Note *note = [[LibreAccessServiceSvc_Note alloc] init];
			[self fromObject:item intoNote:note];
			[intoObject.Notes addNote:note];
			[note release], note = nil;
		}									
		[intoObject.Notes release];
		
		intoObject.Bookmarks = [[LibreAccessServiceSvc_Bookmarks alloc] init];
		for (NSDictionary *item in [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceBookmarks]]) {
			LibreAccessServiceSvc_Bookmark *bookmark = [[LibreAccessServiceSvc_Bookmark alloc] init];
			[self fromObject:item intoBookmark:bookmark];
			[intoObject.Bookmarks addBookmark:bookmark];
			[bookmark release], bookmark = nil;
		}									
		[intoObject.Bookmarks release];
		
		intoObject.Favorite = [[LibreAccessServiceSvc_Favorite alloc] init];
		[self fromObject:[self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceFavorite]] intoFavorite:intoObject.Favorite];
		[intoObject.Favorite release];
		
		intoObject.LastPage = [[LibreAccessServiceSvc_LastPage alloc] init];
		[self fromObject:[self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceLastPage]] intoLastPage:intoObject.LastPage];
		[intoObject.LastPage release];		
	}
}												

- (void)fromObject:(NSDictionary *)object intoHighlight:(LibreAccessServiceSvc_Highlight *)intoObject
{
	if (object != nil && intoObject != nil) {
		intoObject.id_ = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceID]];
		intoObject.action = [[self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceAction]] saveActionValue];
		intoObject.color = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceColor]];		
		intoObject.location = [[LibreAccessServiceSvc_LocationText alloc] init];
		[self fromObject:[self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceLocationText]] intoLocationText:intoObject.location];
		[intoObject.location release];
		intoObject.endPage = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceEndPage]];		
		intoObject.version = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceVersion]];				
		intoObject.lastmodified = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceLastModified]];				
	}	
}

- (void)fromObject:(NSDictionary *)object intoLocationText:(LibreAccessServiceSvc_LocationText *)intoObject
{
	if (object != nil && intoObject != nil) {
		intoObject.page = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServicePage]];
		intoObject.wordindex = [[LibreAccessServiceSvc_WordIndex alloc] init];		
		[self fromObject:[self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceWordIndex]] intoWordIndex:intoObject.wordindex];
		[intoObject.wordindex release];
	}	
}

- (void)fromObject:(NSDictionary *)object intoWordIndex:(LibreAccessServiceSvc_WordIndex *)intoObject
{
	if (object != nil && intoObject != nil) {
		intoObject.start = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceStart]];
		intoObject.end = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceEnd]];		
	}	
}

- (void)fromObject:(NSDictionary *)object intoNote:(LibreAccessServiceSvc_Note *)intoObject
{
	if (object != nil && intoObject != nil) {
		intoObject.id_ = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceID]];
		intoObject.action = [[self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceAction]] saveActionValue];
		intoObject.location = [[LibreAccessServiceSvc_LocationGraphics alloc] init];
		[self fromObject:[self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceLocationGraphics]] intoLocationGraphics:intoObject.location];
		[intoObject.location release];
		intoObject.color = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceColor]];
		intoObject.value = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceValue]];		
		intoObject.version = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceVersion]];				
		intoObject.lastmodified = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceLastModified]];				
	}	
}

- (void)fromObject:(NSDictionary *)object intoLocationGraphics:(LibreAccessServiceSvc_LocationGraphics *)intoObject
{
	if (object != nil && intoObject != nil) {
		intoObject.page = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServicePage]];
		intoObject.coords = [[LibreAccessServiceSvc_Coords alloc] init];
		[self fromObject:[self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceCoords]] intoCoords:intoObject.coords];
		[intoObject.coords release];
		intoObject.wordindex = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceWordIndex]];
	}	
}

- (void)fromObject:(NSDictionary *)object intoCoords:(LibreAccessServiceSvc_Coords *)intoObject
{
	if (object != nil && intoObject != nil) {
		intoObject.x = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceX]];
		intoObject.y = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceY]];
	}	
}

- (void)fromObject:(NSDictionary *)object intoFavorite:(LibreAccessServiceSvc_Favorite *)intoObject
{
	if (object != nil && intoObject != nil) {
		intoObject.isFavorite = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceIsFavorite]];
		intoObject.lastmodified = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceLastModified]];				
	}	
}

- (void)fromObject:(NSDictionary *)object intoBookmark:(LibreAccessServiceSvc_Bookmark *)intoObject
{
	if (object != nil && intoObject != nil) {
		intoObject.id_ = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceID]];
		intoObject.action = [[self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceAction]] saveActionValue];
		intoObject.text = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceText]];
		intoObject.disabled = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceDisabled]];		
		intoObject.location = [[LibreAccessServiceSvc_LocationBookmark alloc] init];
		intoObject.location.page = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceLocationBookmark]];
		[intoObject.location release];
		intoObject.version = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceVersion]];						
		intoObject.lastmodified = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceLastModified]];				
	}	
}

- (void)fromObject:(NSDictionary *)object intoLastPage:(LibreAccessServiceSvc_LastPage *)intoObject
{
	if (object != nil && intoObject != nil) {
		intoObject.lastPageLocation = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceLastPageLocation]];
		intoObject.percentage = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServicePercentage]];
		intoObject.component = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceComponent]];
		intoObject.lastmodified = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceLastModified]];						
	}	
}

- (void)fromObject:(NSDictionary *)object intoContentProfileAssignmentItem:(LibreAccessServiceSvc_ContentProfileAssignmentItem *)intoObject
{
	if (object != nil && intoObject != nil) {
		intoObject.contentIdentifier = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceContentIdentifier]];
		intoObject.ContentIdentifierType = [[self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceContentIdentifierType]] contentIdentifierType];
		intoObject.drmqualifier = [[self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceDRMQualifier]] DRMQualifier];		
		intoObject.format = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceFormat]];
		intoObject.AssignedProfileList = [[LibreAccessServiceSvc_AssignedProfileList alloc] init];
		for (NSDictionary *item in [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceAssignedProfileList]]) {
			LibreAccessServiceSvc_AssignedProfileItem *contentProfileAssignmentItem = [[LibreAccessServiceSvc_AssignedProfileItem alloc] init];
			[self fromObject:item intoAssignedProfileItem:contentProfileAssignmentItem];
			[intoObject.AssignedProfileList addAssignedProfileItem:contentProfileAssignmentItem];
			[contentProfileAssignmentItem release], contentProfileAssignmentItem = nil;
		}
		[intoObject.AssignedProfileList release];
	}	
}

- (void)fromObject:(NSDictionary *)object intoAssignedProfileItem:(LibreAccessServiceSvc_AssignedProfileItem *)intoObject
{
	if (object != nil && intoObject != nil) {
		intoObject.profileID = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceProfileID]];
		intoObject.action = [[self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceAction]] saveActionValue];
		intoObject.lastmodified = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceLastModified]];				
	}	
}

- (void)fromObject:(NSDictionary *)object intoReadingStatsDetailItem:(LibreAccessServiceSvc_ReadingStatsDetailItem *)intoObject
{
	if (object != nil && intoObject != nil) {
		intoObject.ReadingStatsContentList = [[LibreAccessServiceSvc_ReadingStatsContentList alloc] init];
		for (NSDictionary *item in [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceReadingStatsContentList]]) {
			LibreAccessServiceSvc_ReadingStatsContentItem *readingStatsContentItem = [[LibreAccessServiceSvc_ReadingStatsContentItem alloc] init];
			[self fromObject:item intoReadingStatsContentItem:readingStatsContentItem];
			[intoObject.ReadingStatsContentList addReadingStatsContentItem:readingStatsContentItem];
			[readingStatsContentItem release], readingStatsContentItem = nil;
		}
		[intoObject.ReadingStatsContentList release];
		intoObject.profileID = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceProfileID]];
	}	
}

- (void)fromObject:(NSDictionary *)object intoReadingStatsContentItem:(LibreAccessServiceSvc_ReadingStatsContentItem *)intoObject
{
	if (object != nil && intoObject != nil) {
		intoObject.ContentIdentifierType = [[self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceContentIdentifierType]] contentIdentifierType];
		intoObject.contentIdentifier = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceContentIdentifier]];
		intoObject.drmqualifier = [[self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceDRMQualifier]] DRMQualifier];		
		intoObject.format = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceFormat]];
		intoObject.ReadingStatsEntryList = [[LibreAccessServiceSvc_ReadingStatsEntryList alloc] init];
		for (NSDictionary *item in [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceReadingStatsContentList]]) {
			LibreAccessServiceSvc_ReadingStatsEntryItem *readingStatsEntryItem = [[LibreAccessServiceSvc_ReadingStatsEntryItem alloc] init];
			[self fromObject:item intoReadingStatsEntryItem:readingStatsEntryItem];
			[intoObject.ReadingStatsEntryList addReadingStatsEntryItem:readingStatsEntryItem];
			[readingStatsEntryItem release], readingStatsEntryItem = nil;
		}
		[intoObject.ReadingStatsEntryList release];
	}	
}

- (void)fromObject:(NSDictionary *)object intoReadingStatsEntryItem:(LibreAccessServiceSvc_ReadingStatsEntryItem *)intoObject
{
	if (object != nil && intoObject != nil) {
		intoObject.readingDuration = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceReadingDuration]];
		intoObject.pagesRead = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServicePagesRead]];
		intoObject.storyInteractions = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceStoryInteractions]];
		intoObject.dictionaryLookups = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceDictionaryLookups]];
		intoObject.deviceKey = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceDeviceKey]];
		intoObject.timestamp = [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceTimestamp]];				
		intoObject.DictionaryLookupsList = [[LibreAccessServiceSvc_DictionaryLookupsList alloc] init];
		for (NSString *item in [self fromObjectTranslate:[object objectForKey:kSCHLibreAccessWebServiceDictionaryLookupsList]]) {
			[intoObject.DictionaryLookupsList addDictionaryLookupsItem:item];
		}
		[intoObject.DictionaryLookupsList release];
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


@end
