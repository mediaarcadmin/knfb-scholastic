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
#import "BITNetworkActivityManager.h"


static NSString * const kSCHLibreAccessWebServiceUndefinedMethod = @"undefined method";
static NSString * const kSCHLibreAccessWebServiceStatusHolderStatusMessage = @"statusmessage";

static NSInteger const kSCHLibreAccessWebServiceVaid = 33;

/*
 * This class is thread safe when using the Thread Confinement design pattern.
 */

@interface SCHLibreAccessWebService ()

- (NSError *)errorFromStatusMessage:(LibreAccessServiceSvc_StatusHolder *)statusMessage;
- (NSString *)methodNameFromObject:(id)anObject;

- (NSDictionary *)objectFromTokenExchange:(LibreAccessServiceSvc_TokenExchangeResponse *)anObject;
- (NSDictionary *)objectFromAuthenticateDevice:(LibreAccessServiceSvc_AuthenticateDeviceResponse *)anObject;
- (NSDictionary *)objectFromRenewToken:(LibreAccessServiceSvc_RenewTokenResponse *)anObject;
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
- (NSDictionary *)objectFromFavoriteTypesItem:(LibreAccessServiceSvc_FavoriteTypesItem *)anObject;
- (NSDictionary *)objectFromFavoriteTypesValuesItem:(LibreAccessServiceSvc_FavoriteTypesValuesItem *)anObject;
- (NSDictionary *)objectFromTopFavoritesItem:(LibreAccessServiceSvc_TopFavoritesResponseItem *)anObject;
- (NSDictionary *)objectFromTopFavoritesContentItem:(LibreAccessServiceSvc_TopFavoritesContentItem *)anObject;

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
- (void)fromObject:(NSDictionary *)object intoTopFavoritesItem:(LibreAccessServiceSvc_TopFavoritesRequestItem *)intoObject;

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
	request.vaid = [NSNumber numberWithInt:kSCHLibreAccessWebServiceVaid];
	request.deviceKey = @"";
	request.impersonationkey = @"";
	request.UserName = userName;
	
	[binding TokenExchangeAsyncUsingBody:request delegate:self]; 
	[[BITNetworkActivityManager sharedNetworkActivityManager] showNetworkActivityIndicator];
	
	[request release], request = nil;
}

- (void)authenticateDevice:(NSString *)deviceKey forUserKey:(NSString *)userKey
{
	LibreAccessServiceSvc_AuthenticateDeviceRequest *request = [LibreAccessServiceSvc_AuthenticateDeviceRequest new];
    
	request.vaid = [NSNumber numberWithInt:kSCHLibreAccessWebServiceVaid];
	request.deviceKey = deviceKey;
	request.userKey = userKey;
	
	[binding AuthenticateDeviceAsyncUsingBody:request delegate:self]; 
	[[BITNetworkActivityManager sharedNetworkActivityManager] showNetworkActivityIndicator];
	
	[request release], request = nil;
}

- (void)renewToken:(NSString *)aToken
{
    LibreAccessServiceSvc_RenewTokenRequest *request = [LibreAccessServiceSvc_RenewTokenRequest new];
    
    request.authtoken = aToken;
    
    [binding RenewTokenAsyncUsingBody:request delegate:self]; 
    [[BITNetworkActivityManager sharedNetworkActivityManager] showNetworkActivityIndicator];
    
    [request release], request = nil;
}

- (BOOL)getUserProfiles
{
	BOOL ret = NO;
	
	if ([SCHAuthenticationManager sharedAuthenticationManager].isAuthenticated == YES) {		
		LibreAccessServiceSvc_GetUserProfilesRequest *request = [LibreAccessServiceSvc_GetUserProfilesRequest new];
		
		request.authtoken = [SCHAuthenticationManager sharedAuthenticationManager].aToken;
		
		[binding GetUserProfilesAsyncUsingParameters:request delegate:self]; 
		[[BITNetworkActivityManager sharedNetworkActivityManager] showNetworkActivityIndicator];
		
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
		[[BITNetworkActivityManager sharedNetworkActivityManager] showNetworkActivityIndicator];
		
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
		[[BITNetworkActivityManager sharedNetworkActivityManager] showNetworkActivityIndicator];
		
		[request release], request = nil;	
		ret = YES;
	}
	
	return(ret);			
}

- (BOOL)listFavoriteTypes
{
	BOOL ret = NO;
	
	if ([SCHAuthenticationManager sharedAuthenticationManager].isAuthenticated == YES) {		
		LibreAccessServiceSvc_ListFavoriteTypesRequest *request = [LibreAccessServiceSvc_ListFavoriteTypesRequest new];
		
		request.authtoken = [SCHAuthenticationManager sharedAuthenticationManager].aToken;

		[binding ListFavoriteTypesAsyncUsingParameters:request delegate:self]; 
		[[BITNetworkActivityManager sharedNetworkActivityManager] showNetworkActivityIndicator];
		
		[request release], request = nil;	
		ret = YES;
	}
	
	return(ret);			
}

- (BOOL)listTopFavorites:(NSArray *)favorites withCount:(NSUInteger)count
{
	BOOL ret = NO;
	
	if ([SCHAuthenticationManager sharedAuthenticationManager].isAuthenticated == YES) {		
		LibreAccessServiceSvc_ListTopFavoritesRequest *request = [LibreAccessServiceSvc_ListTopFavoritesRequest new];
		
		request.authtoken = [SCHAuthenticationManager sharedAuthenticationManager].aToken;
		request.count = [NSNumber numberWithInteger:(count < 1 ? 1 : count)];
		request.TopFavoritesRequestList = [[LibreAccessServiceSvc_TopFavoritesRequestList alloc] init];
		LibreAccessServiceSvc_TopFavoritesRequestItem *item = nil;
		for (id favorite in favorites) {
			item = [[LibreAccessServiceSvc_TopFavoritesRequestItem alloc] init];
			[self fromObject:favorite intoObject:item];
			[request.TopFavoritesRequestList addTopFavoritesRequestItem:item];
			[item release], item = nil;
		}
		[request.TopFavoritesRequestList release];
		
		[binding ListTopFavoritesAsyncUsingParameters:request delegate:self]; 
		[[BITNetworkActivityManager sharedNetworkActivityManager] showNetworkActivityIndicator];
		
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
		[[BITNetworkActivityManager sharedNetworkActivityManager] showNetworkActivityIndicator];
		
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
		[[BITNetworkActivityManager sharedNetworkActivityManager] showNetworkActivityIndicator];
		
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
		[[BITNetworkActivityManager sharedNetworkActivityManager] showNetworkActivityIndicator];
		
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
		[[BITNetworkActivityManager sharedNetworkActivityManager] showNetworkActivityIndicator];
		
		[request release], request = nil;
		ret = YES;
	}
	
	return(ret);							
}

// TODO: implement response and add to Core Data
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
		[[BITNetworkActivityManager sharedNetworkActivityManager] showNetworkActivityIndicator];
		
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
		[[BITNetworkActivityManager sharedNetworkActivityManager] showNetworkActivityIndicator];
		
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
		[[BITNetworkActivityManager sharedNetworkActivityManager] showNetworkActivityIndicator];
		
		[request release], request = nil;	
		ret = YES;
	}
	
	return(ret);										
}

#pragma mark -
#pragma mark LibreAccessServiceSoap12BindingResponse Delegate methods

- (void)operation:(LibreAccessServiceSoap11BindingOperation *)operation completedWithResponse:(LibreAccessServiceSoap11BindingResponse *)response
{	
	[[BITNetworkActivityManager sharedNetworkActivityManager] hideNetworkActivityIndicator];
	
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
		} else if([anObject isKindOfClass:[LibreAccessServiceSvc_AuthenticateDeviceRequest class]] == YES ||
				  [anObject isKindOfClass:[LibreAccessServiceSvc_AuthenticateDeviceResponse class]] == YES ||
				  [anObject isKindOfClass:[LibreAccessServiceSoap11Binding_AuthenticateDevice class]] == YES) {
			ret = kSCHLibreAccessWebServiceAuthenticateDevice;	
		} else if([anObject isKindOfClass:[LibreAccessServiceSvc_RenewTokenRequest class]] == YES ||
				  [anObject isKindOfClass:[LibreAccessServiceSvc_RenewTokenResponse class]] == YES ||
				  [anObject isKindOfClass:[LibreAccessServiceSoap11Binding_RenewToken class]] == YES) {
			ret = kSCHLibreAccessWebServiceRenewToken;	
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
		} else if([anObject isKindOfClass:[LibreAccessServiceSvc_SaveReadingStatisticsDetailedRequest class]] == YES ||
				  [anObject isKindOfClass:[LibreAccessServiceSvc_SaveReadingStatisticsDetailedResponse class]] == YES ||
				  [anObject isKindOfClass:[LibreAccessServiceSoap11Binding_SaveReadingStatisticsDetailed class]] == YES) {
			ret = kSCHLibreAccessWebServiceSaveReadingStatisticsDetailed;
		} else if([anObject isKindOfClass:[LibreAccessServiceSvc_ListFavoriteTypesRequest class]] == YES ||
				  [anObject isKindOfClass:[LibreAccessServiceSvc_ListFavoriteTypesResponse class]] == YES ||
				  [anObject isKindOfClass:[LibreAccessServiceSoap11Binding_ListFavoriteTypes class]] == YES) {
			ret = kSCHLibreAccessWebServiceListFavoriteTypes;
		} else if([anObject isKindOfClass:[LibreAccessServiceSvc_ListTopFavoritesRequest class]] == YES ||
				  [anObject isKindOfClass:[LibreAccessServiceSvc_ListTopFavoritesResponse class]] == YES ||
				  [anObject isKindOfClass:[LibreAccessServiceSoap11Binding_ListTopFavorites class]] == YES) {
			ret = kSCHLibreAccessWebServiceListTopFavorites;
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
			ret = [self objectFromTokenExchange:anObject];
		} else if ([anObject isKindOfClass:[LibreAccessServiceSvc_AuthenticateDeviceResponse class]] == YES) {
			ret = [self objectFromAuthenticateDevice:anObject];
		} else if ([anObject isKindOfClass:[LibreAccessServiceSvc_RenewTokenResponse class]] == YES) {
			ret = [self objectFromRenewToken:anObject];
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
			NSMutableDictionary *listProfileContentAnnotations = [NSMutableDictionary dictionary];
			
			[listProfileContentAnnotations setObject:[self objectFromTranslate:[[anObject AnnotationsList] AnnotationsItem]] forKey:kSCHLibreAccessWebServiceAnnotationsList];
			[listProfileContentAnnotations setObject:[self objectFromItemsCount:[anObject ItemsCount]] forKey:kSCHLibreAccessWebServiceItemsCount];			

			ret = [NSDictionary dictionaryWithObject:listProfileContentAnnotations forKey:kSCHLibreAccessWebServiceListProfileContentAnnotations];
		} else if ([anObject isKindOfClass:[LibreAccessServiceSvc_SaveContentProfileAssignmentResponse class]] == YES) {
			ret = nil;	// only returns the status so nothing to return
		} else if ([anObject isKindOfClass:[LibreAccessServiceSvc_SaveReadingStatisticsDetailedResponse class]] == YES) {
			ret = nil;	// only returns the status so nothing to return
		} else if ([anObject isKindOfClass:[LibreAccessServiceSvc_ListFavoriteTypesResponse class]] == YES) {
			ret = [NSDictionary dictionaryWithObject:[self objectFromTranslate:[[anObject FavoriteTypesList] FavoriteTypesItem]] forKey:kSCHLibreAccessWebServiceFavoriteTypesList];
		} else if ([anObject isKindOfClass:[LibreAccessServiceSvc_ListTopFavoritesResponse class]] == YES) {
			ret = [NSDictionary dictionaryWithObject:[self objectFromTranslate:[[anObject TopFavoritesResponseList] TopFavoritesResponseItem]] forKey:kSCHLibreAccessWebServiceTopFavoritesList];
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
		} else if ([intoObject isKindOfClass:[LibreAccessServiceSvc_TopFavoritesRequestItem class]] == YES) {
			[self fromObject:object intoTopFavoritesItem:intoObject];
		}
	}
}

#pragma mark -
#pragma mark ObjectMapper objectFrom: converter methods 

- (NSDictionary *)objectFromTokenExchange:(LibreAccessServiceSvc_TokenExchangeResponse *)anObject
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

- (NSDictionary *)objectFromAuthenticateDevice:(LibreAccessServiceSvc_AuthenticateDeviceResponse *)anObject
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

- (NSDictionary *)objectFromRenewToken:(LibreAccessServiceSvc_RenewTokenResponse *)anObject
{
	NSDictionary *ret = nil;
	
	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];
		
		[objects setObject:[self objectFromTranslate:anObject.authtoken] forKey:kSCHLibreAccessWebServiceAuthToken];
		[objects setObject:[self objectFromTranslate:anObject.expiresIn] forKey:kSCHLibreAccessWebServiceExpiresIn];
        
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
		[objects setObject:[NSNumber numberWithProfileType:anObject.type] forKey:kSCHLibreAccessWebServiceType];		
		[objects setObject:[self objectFromTranslate:anObject.id_] forKey:kSCHLibreAccessWebServiceID];		
		[objects setObject:[NSNumber numberWithBookshelfStyle:anObject.BookshelfStyle] forKey:kSCHLibreAccessWebServiceBookshelfStyle];		
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
		[objects setObject:[NSNumber numberWithContentIdentifierType:anObject.ContentIdentifierType] forKey:kSCHLibreAccessWebServiceContentIdentifierType];		
		[objects setObject:[NSNumber numberWithDRMQualifier:anObject.DRMQualifier] forKey:kSCHLibreAccessWebServiceDRMQualifier];		
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
		[objects setObject:[NSNumber numberWithContentIdentifierType:anObject.ContentIdentifierType] forKey:kSCHLibreAccessWebServiceContentIdentifierType];
		[objects setObject:[self objectFromTranslate:anObject.Title] forKey:kSCHLibreAccessWebServiceTitle];
		[objects setObject:[self objectFromTranslate:anObject.Author] forKey:kSCHLibreAccessWebServiceAuthor];
		[objects setObject:[self objectFromTranslate:anObject.Description] forKey:kSCHLibreAccessWebServiceDescription];
		[objects setObject:[self objectFromTranslate:anObject.Version] forKey:kSCHLibreAccessWebServiceVersion];
		[objects setObject:[self objectFromTranslate:anObject.PageNumber] forKey:kSCHLibreAccessWebServicePageNumber];
		[objects setObject:[self objectFromTranslate:anObject.FileSize] forKey:kSCHLibreAccessWebServiceFileSize];
		[objects setObject:[NSNumber numberWithDRMQualifier:anObject.DRMQualifier] forKey:kSCHLibreAccessWebServiceDRMQualifier];
		[objects setObject:[self objectFromTranslate:anObject.CoverURL] forKey:kSCHLibreAccessWebServiceCoverURL];
		[objects setObject:[self objectFromTranslate:anObject.ContentURL] forKey:kSCHLibreAccessWebServiceContentURL];
		[objects setObject:[self objectFromTranslate:anObject.EreaderCategories] forKey:kSCHLibreAccessWebServiceeReaderCategories];
		[objects setObject:[self objectFromTranslate:anObject.Enhanced] forKey:kSCHLibreAccessWebServiceEnhanced];
				
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
		[objects setObject:[NSNumber numberWithSaveAction:anObject.action] forKey:kSCHLibreAccessWebServiceAction];
		[objects setObject:[NSNumber numberWithStatusCode:anObject.status] forKey:kSCHLibreAccessWebServiceStatus];
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
		
		[objects setObject:[NSNumber numberWithUserSettingsType:anObject.SettingType] forKey:kSCHLibreAccessWebServiceSettingType];
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
		
		[objects setObject:[self objectFromTranslate:[[anObject AnnotationsContentList] AnnotationsContentItem]] forKey:kSCHLibreAccessWebServiceAnnotationsContentList];
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
		[objects setObject:[self objectFromPrivateAnnotations:anObject.PrivateAnnotations] forKey:kSCHLibreAccessWebServicePrivateAnnotations];
		
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

- (NSDictionary *)objectFromFavoriteTypesValuesItem:(LibreAccessServiceSvc_FavoriteTypesValuesItem *)anObject
{
	NSDictionary *ret = nil;
	
	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];
		
		[objects setObject:[self objectFromTranslate:anObject.Value] forKey:kSCHLibreAccessWebServiceValue];
		
		ret = objects;					
	}
	
	return(ret);
}

- (NSDictionary *)objectFromFavoriteTypesItem:(LibreAccessServiceSvc_FavoriteTypesItem *)anObject
{
	NSDictionary *ret = nil;
	
	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];
		
		[objects setObject:[NSNumber numberWithTopFavoritesType:anObject.FavoriteType] forKey:kSCHLibreAccessWebServiceFavoriteType];
		[objects setObject:[self objectFromTranslate:[anObject.FavoriteTypeValuesList FavoriteTypesValuesItem]] forKey:kSCHLibreAccessWebServiceFavoriteTypeValuesList];
		
		ret = objects;					
	}
	
	return(ret);
}

- (NSDictionary *)objectFromTopFavoritesItem:(LibreAccessServiceSvc_TopFavoritesResponseItem *)anObject
{
	NSDictionary *ret = nil;
	
	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];
		
		[objects setObject:[NSNumber numberWithTopFavoritesType:anObject.TopFavoritesType] forKey:kSCHLibreAccessWebServiceTopFavoritesType];
		[objects setObject:[self objectFromTranslate:anObject.TopFavoritesTypeValue] forKey:kSCHLibreAccessWebServiceTopFavoritesTypeValue];
		[objects setObject:[self objectFromTranslate:[anObject.TopFavoritesContentItems TopFavoritesContentItem]] forKey:kSCHLibreAccessWebServiceTopFavoritesContentItems];
		
		ret = objects;					
	}
	
	return(ret);
}

- (NSDictionary *)objectFromTopFavoritesContentItem:(LibreAccessServiceSvc_TopFavoritesContentItem *)anObject
{
	NSDictionary *ret = nil;
	
	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];
		
		[objects setObject:[self objectFromTranslate:anObject.ContentIdentifier] forKey:kSCHLibreAccessWebServiceContentIdentifier];
		[objects setObject:[NSNumber numberWithContentIdentifierType:anObject.ContentIdentifierType] forKey:kSCHLibreAccessWebServiceContentIdentifierType];
		
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
		
		if ([anObject count] > 0) {
			id firstItem = [anObject objectAtIndex:0];
			
			if ([firstItem isKindOfClass:[LibreAccessServiceSvc_ProfileItem class]] == YES) {
				for (id item in anObject) {
					[ret addObject:[self objectFromProfileItem:item]];					
				}
			} else if ([firstItem isKindOfClass:[LibreAccessServiceSvc_UserContentItem class]] == YES) {
				for (id item in anObject) {				
					[ret addObject:[self objectFromUserContentItem:item]];					
				}
			} else if ([firstItem isKindOfClass:[LibreAccessServiceSvc_ContentProfileItem class]] == YES) {
				for (id item in anObject) {
					[ret addObject:[self objectFromContentProfileItem:item]];					
				}
			} else if ([firstItem isKindOfClass:[LibreAccessServiceSvc_OrderItem class]] == YES) {
				for (id item in anObject) {
					[ret addObject:[self objectFromOrderItem:item]];									
				}
			} else if ([firstItem isKindOfClass:[LibreAccessServiceSvc_ContentMetadataItem class]] == YES) {
				for (id item in anObject) {
					[ret addObject:[self objectFromContentMetadataItem:item]];													
				}
			} else if ([firstItem isKindOfClass:[LibreAccessServiceSvc_ProfileStatusItem class]] == YES) {
				for (id item in anObject) {
					[ret addObject:[self objectFromProfileStatusItem:item]];													
				}
			} else if ([firstItem isKindOfClass:[LibreAccessServiceSvc_UserSettingsItem class]] == YES) {
				for (id item in anObject) {
					[ret addObject:[self objectFromUserSettingsItem:item]];	
				}
			} else if ([firstItem isKindOfClass:[LibreAccessServiceSvc_AnnotationsItem class]] == YES) {
				for (id item in anObject) {
					[ret addObject:[self objectFromAnnotationsItem:item]];	
				}
			} else if ([firstItem isKindOfClass:[LibreAccessServiceSvc_AnnotationsContentItem class]] == YES) {
				for (id item in anObject) {
					[ret addObject:[self objectFromAnnotationsContentItem:item]];	
				}
			} else if ([firstItem isKindOfClass:[LibreAccessServiceSvc_PrivateAnnotations class]] == YES) {
				for (id item in anObject) {
					[ret addObject:[self objectFromPrivateAnnotations:item]];	
				}
			} else if ([firstItem isKindOfClass:[LibreAccessServiceSvc_Highlight class]] == YES) {
				for (id item in anObject) {
					[ret addObject:[self objectFromHighlight:item]];	
				}
			} else if ([firstItem isKindOfClass:[LibreAccessServiceSvc_Notes class]] == YES) {
				for (id item in anObject) {
					[ret addObject:[self objectFromNote:item]];
				}
			} else if ([firstItem isKindOfClass:[LibreAccessServiceSvc_FavoriteTypesValuesItem class]] == YES) {
				for (id item in anObject) {
					[ret addObject:[self objectFromFavoriteTypesValuesItem:item]];	
				}
			} else if ([firstItem isKindOfClass:[LibreAccessServiceSvc_FavoriteTypesItem class]] == YES) {
				for (id item in anObject) {
					[ret addObject:[self objectFromFavoriteTypesItem:item]];
				}
			} else if ([firstItem isKindOfClass:[LibreAccessServiceSvc_TopFavoritesResponseItem class]] == YES) {
				for (id item in anObject) {
					[ret addObject:[self objectFromTopFavoritesItem:item]];	
				}
			} else if ([firstItem isKindOfClass:[LibreAccessServiceSvc_TopFavoritesContentItem class]] == YES) {
				for (id item in anObject) {
					[ret addObject:[self objectFromTopFavoritesContentItem:item]];	
				}
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
		intoObject.AutoAssignContentToProfiles = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceAutoAssignContentToProfiles]];
		intoObject.ProfilePasswordRequired = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceProfilePasswordRequired]];
		intoObject.Firstname = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceFirstName]];
		intoObject.Lastname = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceLastName]];
		intoObject.BirthDay = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceBirthday]];
		intoObject.LastModified = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceLastModified]];
		intoObject.screenname = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceScreenName]];
		intoObject.password = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServicePassword]];
		intoObject.userkey = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceUserKey]];
		intoObject.type = [[object valueForKey:kSCHLibreAccessWebServiceType] profileTypeValue];
		intoObject.id_ = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceID]];
		intoObject.action = [[object valueForKey:kSCHLibreAccessWebServiceAction] saveActionValue];
		intoObject.BookshelfStyle = [[object valueForKey:kSCHLibreAccessWebServiceBookshelfStyle] bookshelfStyleValue];
		intoObject.storyInteractionEnabled = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceStoryInteractionEnabled]];
	}
}

- (void)fromObject:(NSDictionary *)object intoISBNItem:(LibreAccessServiceSvc_isbnItem *)intoObject
{
	if (object != nil && intoObject != nil) {
		intoObject.ISBN = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceContentIdentifier]];
		intoObject.Format = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceFormat]];
		intoObject.IdentifierType = [[object valueForKey:kSCHLibreAccessWebServiceContentIdentifierType] contentIdentifierTypeValue];
		intoObject.Qualifier = [[object valueForKey:kSCHLibreAccessWebServiceDRMQualifier] DRMQualifierValue];
	}
}

- (void)fromObject:(NSDictionary *)object intoUserSettingsItem:(LibreAccessServiceSvc_UserSettingsItem *)intoObject
{
	if (object != nil && intoObject != nil) {
		intoObject.SettingType = [[object valueForKey:kSCHLibreAccessWebServiceSettingType] userSettingsTypeValue];
		intoObject.SettingValue = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceSettingValue]];
	}
}

- (void)fromObject:(NSDictionary *)object intoAnnotationsRequestContentItem:(LibreAccessServiceSvc_AnnotationsRequestContentItem *)intoObject
{
	if (object != nil && intoObject != nil) {
		intoObject.contentIdentifier = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceContentIdentifier]];
		intoObject.ContentIdentifierType = [[object valueForKey:kSCHLibreAccessWebServiceContentIdentifierType] contentIdentifierTypeValue];
		intoObject.drmqualifier = [[object valueForKey:kSCHLibreAccessWebServiceDRMQualifier] DRMQualifierValue];
		intoObject.format = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceFormat]];
		intoObject.PrivateAnnotationsRequest = [[LibreAccessServiceSvc_PrivateAnnotationsRequest alloc] init];
		[self fromObject:[object valueForKey:kSCHLibreAccessWebServicePrivateAnnotations] intoPrivateAnnotationsRequest:intoObject.PrivateAnnotationsRequest];
		[intoObject.PrivateAnnotationsRequest release];
	}
}

- (void)fromObject:(NSDictionary *)object intoPrivateAnnotationsRequest:(LibreAccessServiceSvc_PrivateAnnotationsRequest *)intoObject
{
	if (object != nil && intoObject != nil) {
		intoObject.version = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceVersion]];		
		intoObject.HighlightsAfter = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceHighlightsAfter]];
		intoObject.NotesAfter = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceNotesAfter]];
		intoObject.BookmarksAfter = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceBookmarksAfter]];
	}
}	

- (void)fromObject:(NSDictionary *)object intoAnnotationsItem:(LibreAccessServiceSvc_AnnotationsItem *)intoObject
{
	if (object != nil && intoObject != nil) {
		intoObject.AnnotationsContentList = [[LibreAccessServiceSvc_AnnotationsContentList alloc] init];
		for (NSDictionary *item in [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceAnnotationsContentList]]) {
			LibreAccessServiceSvc_AnnotationsContentItem *annotationsContentItem = [[LibreAccessServiceSvc_AnnotationsContentItem alloc] init];
			[self fromObject:item intoAnnotationsContentItem:annotationsContentItem];
			[intoObject.AnnotationsContentList addAnnotationsContentItem:annotationsContentItem];
			[annotationsContentItem release];
		}
		[intoObject.AnnotationsContentList release];
		intoObject.profileID = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceProfileID]];
	}
}												

- (void)fromObject:(NSDictionary *)object intoAnnotationsContentItem:(LibreAccessServiceSvc_AnnotationsContentItem *)intoObject
{
	if (object != nil && intoObject != nil) {
		intoObject.contentIdentifier = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceContentIdentifier]];
		intoObject.ContentIdentifierType = [[self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceContentIdentifierType]] contentIdentifierTypeValue];
		intoObject.drmqualifier = [[self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceDRMQualifier]] DRMQualifierValue];		
		intoObject.format = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceFormat]];
		intoObject.PrivateAnnotations = [[LibreAccessServiceSvc_PrivateAnnotations alloc] init];
		[self fromObject:[object valueForKey:kSCHLibreAccessWebServicePrivateAnnotations] intoPrivateAnnotations:intoObject.PrivateAnnotations];
		[intoObject.PrivateAnnotations release];
	}
}												

- (void)fromObject:(NSDictionary *)object intoPrivateAnnotations:(LibreAccessServiceSvc_PrivateAnnotations *)intoObject
{
	if (object != nil && intoObject != nil) {
		intoObject.Highlights = [[LibreAccessServiceSvc_Highlights alloc] init];
		for (NSDictionary *item in [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceHighlights]]) {
			LibreAccessServiceSvc_Highlight *highlight = [[LibreAccessServiceSvc_Highlight alloc] init];
			[self fromObject:item intoHighlight:highlight];
			[intoObject.Highlights addHighlight:highlight];
			[highlight release], highlight = nil;
		}
		[intoObject.Highlights release];
		
		intoObject.Notes = [[LibreAccessServiceSvc_Notes alloc] init];
		for (NSDictionary *item in [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceNotes]]) {
			LibreAccessServiceSvc_Note *note = [[LibreAccessServiceSvc_Note alloc] init];
			[self fromObject:item intoNote:note];
			[intoObject.Notes addNote:note];
			[note release], note = nil;
		}									
		[intoObject.Notes release];
		
		intoObject.Bookmarks = [[LibreAccessServiceSvc_Bookmarks alloc] init];
		for (NSDictionary *item in [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceBookmarks]]) {
			LibreAccessServiceSvc_Bookmark *bookmark = [[LibreAccessServiceSvc_Bookmark alloc] init];
			[self fromObject:item intoBookmark:bookmark];
			[intoObject.Bookmarks addBookmark:bookmark];
			[bookmark release], bookmark = nil;
		}									
		[intoObject.Bookmarks release];
		
		intoObject.Favorite = [[LibreAccessServiceSvc_Favorite alloc] init];
		[self fromObject:[self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceFavorite]] intoFavorite:intoObject.Favorite];
		[intoObject.Favorite release];
		
		intoObject.LastPage = [[LibreAccessServiceSvc_LastPage alloc] init];
		[self fromObject:[self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceLastPage]] intoLastPage:intoObject.LastPage];
		[intoObject.LastPage release];		
	}
}												

- (void)fromObject:(NSDictionary *)object intoHighlight:(LibreAccessServiceSvc_Highlight *)intoObject
{
	if (object != nil && intoObject != nil) {
		intoObject.id_ = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceID]];
		intoObject.action = [[self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceAction]] saveActionValue];
		intoObject.color = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceColor]];		
		intoObject.location = [[LibreAccessServiceSvc_LocationText alloc] init];
		[self fromObject:[self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceLocationText]] intoLocationText:intoObject.location];
		[intoObject.location release];
		intoObject.endPage = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceEndPage]];		
		intoObject.version = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceVersion]];				
		intoObject.lastmodified = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceLastModified]];				
	}	
}

- (void)fromObject:(NSDictionary *)object intoLocationText:(LibreAccessServiceSvc_LocationText *)intoObject
{
	if (object != nil && intoObject != nil) {
		intoObject.page = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServicePage]];
		intoObject.wordindex = [[LibreAccessServiceSvc_WordIndex alloc] init];		
		[self fromObject:[self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceWordIndex]] intoWordIndex:intoObject.wordindex];
		[intoObject.wordindex release];
	}	
}

- (void)fromObject:(NSDictionary *)object intoWordIndex:(LibreAccessServiceSvc_WordIndex *)intoObject
{
	if (object != nil && intoObject != nil) {
		intoObject.start = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceStart]];
		intoObject.end = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceEnd]];		
	}	
}

- (void)fromObject:(NSDictionary *)object intoNote:(LibreAccessServiceSvc_Note *)intoObject
{
	if (object != nil && intoObject != nil) {
		intoObject.id_ = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceID]];
		intoObject.action = [[self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceAction]] saveActionValue];
		intoObject.location = [[LibreAccessServiceSvc_LocationGraphics alloc] init];
		[self fromObject:[self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceLocationGraphics]] intoLocationGraphics:intoObject.location];
		[intoObject.location release];
		intoObject.color = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceColor]];
		intoObject.value = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceValue]];		
		intoObject.version = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceVersion]];				
		intoObject.lastmodified = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceLastModified]];				
	}	
}

- (void)fromObject:(NSDictionary *)object intoLocationGraphics:(LibreAccessServiceSvc_LocationGraphics *)intoObject
{
	if (object != nil && intoObject != nil) {
		intoObject.page = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServicePage]];
		intoObject.coords = [[LibreAccessServiceSvc_Coords alloc] init];
		[self fromObject:[self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceCoords]] intoCoords:intoObject.coords];
		[intoObject.coords release];
		intoObject.wordindex = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceWordIndex]];
	}	
}

- (void)fromObject:(NSDictionary *)object intoCoords:(LibreAccessServiceSvc_Coords *)intoObject
{
	if (object != nil && intoObject != nil) {
		intoObject.x = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceX]];
		intoObject.y = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceY]];
	}	
}

- (void)fromObject:(NSDictionary *)object intoFavorite:(LibreAccessServiceSvc_Favorite *)intoObject
{
	if (object != nil && intoObject != nil) {
		intoObject.isFavorite = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceIsFavorite]];
		intoObject.lastmodified = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceLastModified]];				
	}	
}

- (void)fromObject:(NSDictionary *)object intoBookmark:(LibreAccessServiceSvc_Bookmark *)intoObject
{
	if (object != nil && intoObject != nil) {
		intoObject.id_ = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceID]];
		intoObject.action = [[self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceAction]] saveActionValue];
		intoObject.text = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceText]];
		intoObject.disabled = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceDisabled]];		
		intoObject.location = [[LibreAccessServiceSvc_LocationBookmark alloc] init];
		intoObject.location.page = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceLocationBookmark]];
		[intoObject.location release];
		intoObject.version = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceVersion]];						
		intoObject.lastmodified = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceLastModified]];				
	}	
}

- (void)fromObject:(NSDictionary *)object intoLastPage:(LibreAccessServiceSvc_LastPage *)intoObject
{
	if (object != nil && intoObject != nil) {
		intoObject.lastPageLocation = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceLastPageLocation]];
		intoObject.percentage = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServicePercentage]];
		intoObject.component = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceComponent]];
		intoObject.lastmodified = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceLastModified]];						
	}	
}

- (void)fromObject:(NSDictionary *)object intoContentProfileAssignmentItem:(LibreAccessServiceSvc_ContentProfileAssignmentItem *)intoObject
{
	if (object != nil && intoObject != nil) {
		intoObject.contentIdentifier = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceContentIdentifier]];
		intoObject.ContentIdentifierType = [[self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceContentIdentifierType]] contentIdentifierTypeValue];
		intoObject.drmqualifier = [[self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceDRMQualifier]] DRMQualifierValue];		
		intoObject.format = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceFormat]];
		intoObject.AssignedProfileList = [[LibreAccessServiceSvc_AssignedProfileList alloc] init];
		for (NSDictionary *item in [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceAssignedProfileList]]) {
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
		intoObject.profileID = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceProfileID]];
		intoObject.action = [[self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceAction]] saveActionValue];
		intoObject.lastmodified = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceLastModified]];				
	}	
}

- (void)fromObject:(NSDictionary *)object intoReadingStatsDetailItem:(LibreAccessServiceSvc_ReadingStatsDetailItem *)intoObject
{
	if (object != nil && intoObject != nil) {
		intoObject.ReadingStatsContentList = [[LibreAccessServiceSvc_ReadingStatsContentList alloc] init];
		for (NSDictionary *item in [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceReadingStatsContentList]]) {
			LibreAccessServiceSvc_ReadingStatsContentItem *readingStatsContentItem = [[LibreAccessServiceSvc_ReadingStatsContentItem alloc] init];
			[self fromObject:item intoReadingStatsContentItem:readingStatsContentItem];
			[intoObject.ReadingStatsContentList addReadingStatsContentItem:readingStatsContentItem];
			[readingStatsContentItem release], readingStatsContentItem = nil;
		}
		[intoObject.ReadingStatsContentList release];
		intoObject.profileID = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceProfileID]];
	}	
}

- (void)fromObject:(NSDictionary *)object intoReadingStatsContentItem:(LibreAccessServiceSvc_ReadingStatsContentItem *)intoObject
{
	if (object != nil && intoObject != nil) {
		intoObject.ContentIdentifierType = [[self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceContentIdentifierType]] contentIdentifierTypeValue];
		intoObject.contentIdentifier = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceContentIdentifier]];
		intoObject.drmqualifier = [[self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceDRMQualifier]] DRMQualifierValue];		
		intoObject.format = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceFormat]];
		intoObject.ReadingStatsEntryList = [[LibreAccessServiceSvc_ReadingStatsEntryList alloc] init];
		for (NSDictionary *item in [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceReadingStatsContentList]]) {
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
		intoObject.readingDuration = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceReadingDuration]];
		intoObject.pagesRead = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServicePagesRead]];
		intoObject.storyInteractions = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceStoryInteractions]];
		intoObject.dictionaryLookups = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceDictionaryLookups]];
		intoObject.deviceKey = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceDeviceKey]];
		intoObject.timestamp = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceTimestamp]];				
		intoObject.DictionaryLookupsList = [[LibreAccessServiceSvc_DictionaryLookupsList alloc] init];
		for (NSString *item in [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceDictionaryLookupsList]]) {
			[intoObject.DictionaryLookupsList addDictionaryLookupsItem:item];
		}
		[intoObject.DictionaryLookupsList release];
	}	
}

- (void)fromObject:(NSDictionary *)object intoTopFavoritesItem:(LibreAccessServiceSvc_TopFavoritesRequestItem *)intoObject
{
	if (object != nil && intoObject != nil) {
		intoObject.AssignedBooksOnly = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceAssignedBooksOnly]];
		intoObject.TopFavoritesType = [[self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceTopFavoritesType]] topFavoritesTypeValue];
		intoObject.TopFavoritesTypeValue = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceTopFavoritesTypeValue]];
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
