//
//  LibreAccessWebService.m
//  WebAPI
//
//  Created by John S. Eddie on 21/12/2010.
//  Copyright 2010 BitWink. All rights reserved.
//

#import "SCHLibreAccessWebService.h"

#import "BITAPIError.h"
#import "NSNumber+ObjectTypes.h"
#import "SCHAuthenticationManager.h"
#import "BITNetworkActivityManager.h"
#import "UIColor+Extensions.h"
#import "SCHAppStateManager.h"
#import "NSDate+ServerDate.h"
#import "LibreAccessServiceSvc+Binding.h"

static NSString * const kSCHLibreAccessWebServiceUndefinedMethod = @"undefined method";
static NSString * const kSCHLibreAccessWebServiceStatusHolderStatusMessage = @"statusmessage";

static NSInteger const kSCHLibreAccessWebServiceVaid = 33;

/*
 * This class is thread safe when using the Thread Confinement design pattern.
 */

@interface SCHLibreAccessWebService ()

@property (nonatomic, retain) LibreAccessServiceSoap11Binding *binding;

- (NSError *)errorFromStatusMessage:(LibreAccessServiceSvc_StatusHolder *)statusMessage;
- (NSString *)methodNameFromObject:(id)anObject;
- (NSDictionary *)requestInfoFromOperation:(LibreAccessServiceSoap11BindingOperation *)operation;

- (NSDictionary *)objectFromTokenExchange:(LibreAccessServiceSvc_TokenExchangeExResponse *)anObject;
- (NSDictionary *)objectFromAuthenticateDevice:(LibreAccessServiceSvc_AuthenticateDeviceResponse *)anObject;
- (NSDictionary *)objectFromRenewToken:(LibreAccessServiceSvc_RenewTokenResponse *)anObject;
- (NSDictionary *)objectFromProfileItem:(LibreAccessServiceSvc_ProfileItemRecommendations *)anObject;
- (NSDictionary *)objectFromBooksAssignment:(LibreAccessServiceSvc_BooksAssignment *)anObject;
- (NSDictionary *)objectFromContentProfileForRatingsItem:(LibreAccessServiceSvc_ContentProfileForRatingsItem *)anObject;
- (NSDictionary *)objectFromOrderItem:(LibreAccessServiceSvc_OrderItem *)anObject;
- (NSDictionary *)objectFromContentMetadataForRatingsItem:(LibreAccessServiceSvc_ContentMetadataForRatingsItem *)anObject;
- (NSDictionary *)objectFromProfileStatusItem:(LibreAccessServiceSvc_ProfileStatusItem *)anObject;
- (NSDictionary *)objectFromSettingItem:(LibreAccessServiceSvc_SettingItem *)anObject;
- (NSDictionary *)objectFromSettingsStatusItem:(LibreAccessServiceSvc_SettingStatusItem *)anObject;
- (NSDictionary *)objectFromAnnotationsForRatingsItem:(LibreAccessServiceSvc_AnnotationsForRatingsItem *)anObject;
- (NSDictionary *)objectFromAnnotationsContentForRatingsItem:(LibreAccessServiceSvc_AnnotationsContentForRatingsItem *)anObject;
- (NSDictionary *)objectFromPrivateAnnotations:(LibreAccessServiceSvc_PrivateAnnotationsForRatings *)anObject;
- (NSDictionary *)objectFromRating:(LibreAccessServiceSvc_Rating *)anObject;
- (NSDictionary *)objectFromHighlight:(LibreAccessServiceSvc_Highlight *)anObject;
- (NSDictionary *)objectFromLocationText:(LibreAccessServiceSvc_LocationText *)anObject;
- (NSDictionary *)objectFromWordIndex:(LibreAccessServiceSvc_WordIndex *)anObject;
- (NSDictionary *)objectFromNote:(LibreAccessServiceSvc_Note *)anObject;
- (NSDictionary *)objectFromLocationGraphics:(LibreAccessServiceSvc_LocationGraphics *)anObject;
- (NSDictionary *)objectFromBookmark:(LibreAccessServiceSvc_Bookmark *)anObject;
- (NSDictionary *)objectFromLocationBookmark:(LibreAccessServiceSvc_LocationBookmark *)anObject;
- (NSDictionary *)objectFromLastPage:(LibreAccessServiceSvc_LastPage *)anObject;
- (NSDictionary *)objectFromItemsCount:(LibreAccessServiceSvc_ItemsCount *)anObject;
- (NSDictionary *)objectFromFavoriteTypesItem:(LibreAccessServiceSvc_FavoriteTypesItem *)anObject;
- (NSDictionary *)objectFromFavoriteTypesValuesItem:(LibreAccessServiceSvc_FavoriteTypesValuesItem *)anObject;
- (NSDictionary *)objectFromTopFavoritesItem:(LibreAccessServiceSvc_TopFavoritesResponseItem *)anObject;
- (NSDictionary *)objectFromTopFavoritesContentItem:(LibreAccessServiceSvc_TopFavoritesContentItem *)anObject;
- (NSDictionary *)objectFromAnnotationStatusForRatingsItem:(LibreAccessServiceSvc_AnnotationStatusForRatingsItem *)anObject;
- (NSDictionary *)objectFromStatusHolder:(LibreAccessServiceSvc_StatusHolder *)anObject;
- (NSDictionary *)objectFromAnnotationStatusContentForRatingsItem:(LibreAccessServiceSvc_AnnotationStatusContentForRatingsItem *)anObject;
- (NSMutableDictionary *)objectFromPrivateAnnotationsStatus:(LibreAccessServiceSvc_PrivateAnnotationsStatusForRatings *)anObject;
- (NSDictionary *)objectFromAnnotationTypeStatusItem:(LibreAccessServiceSvc_AnnotationTypeStatusItem *)anObject;
- (NSDictionary *)objectFromISBNItem:(LibreAccessServiceSvc_isbnItem *)anObject;

- (id)objectFromTranslate:(id)anObject;
- (void)combineMultipleAnnotationStatusContentBooks:(NSDictionary *)annotationStatusForRatingsItem;
- (void)overwritePrivateAnnotations:(NSDictionary *)existingPrivateAnnotations
             withPrivateAnnotations:(NSDictionary *)newPrivateAnnotations;

- (void)fromObject:(NSDictionary *)object intoSaveProfileItem:(LibreAccessServiceSvc_SaveProfileItem *)intoObject;
- (void)fromObject:(NSDictionary *)object intoISBNItem:(LibreAccessServiceSvc_isbnItem *)intoObject;
- (void)fromObject:(NSDictionary *)object intoSettingItem:(LibreAccessServiceSvc_SettingItem *)intoObject;
- (void)fromObject:(NSDictionary *)object intoAnnotationsRequestContentItem:(LibreAccessServiceSvc_AnnotationsRequestContentItem *)intoObject;
- (void)fromObject:(NSDictionary *)object intoPrivateAnnotationsRequest:(LibreAccessServiceSvc_PrivateAnnotationsRequest *)intoObject;
- (void)fromObject:(NSDictionary *)object intoAnnotationsForRatingsItem:(LibreAccessServiceSvc_AnnotationsForRatingsItem *)intoObject;
- (BOOL)annotationsContentItemHasChanges:(NSDictionary *)annotationsContentItem;
- (void)fromObject:(NSDictionary *)object intoAnnotationsContentForRatingsItem:(LibreAccessServiceSvc_AnnotationsContentForRatingsItem *)intoObject;
- (NSDate *)latestLastModifiedFromPrivateAnnotations:(NSDictionary *)privateAnnotations;
- (void)fromObject:(NSDictionary *)object intoPrivateAnnotations:(LibreAccessServiceSvc_PrivateAnnotationsForRatings *)intoObject;
- (void)fromObject:(NSDictionary *)object intoHighlight:(LibreAccessServiceSvc_Highlight *)intoObject;
- (void)fromObject:(NSDictionary *)object intoLocationText:(LibreAccessServiceSvc_LocationText *)intoObject;
- (void)fromObject:(NSDictionary *)object intoWordIndex:(LibreAccessServiceSvc_WordIndex *)intoObject;
- (void)fromObject:(NSDictionary *)object intoNote:(LibreAccessServiceSvc_Note *)intoObject;
- (void)fromObject:(NSDictionary *)object intoLocationGraphics:(LibreAccessServiceSvc_LocationGraphics *)intoObject;
- (void)fromObject:(NSDictionary *)object intoBookmark:(LibreAccessServiceSvc_Bookmark *)intoObject;
- (void)fromObject:(NSDictionary *)object intoLocationBookmark:(LibreAccessServiceSvc_LocationBookmark *)intoObject;
- (void)fromObject:(NSDictionary *)object intoLastPage:(LibreAccessServiceSvc_LastPage *)intoObject;
- (void)fromObject:(NSDictionary *)object intoRating:(LibreAccessServiceSvc_Rating *)intoObject;
- (void)fromObject:(NSDictionary *)object intoContentProfileAssignmentItem:(LibreAccessServiceSvc_ContentProfileAssignmentItem *)intoObject;
- (void)fromObject:(NSDictionary *)object intoAssignedProfileItem:(LibreAccessServiceSvc_AssignedProfileItem *)intoObject;
- (void)fromObject:(NSDictionary *)object intoReadingStatsDetailItem:(LibreAccessServiceSvc_ReadingStatsDetailItem *)intoObject;
- (void)fromObject:(NSDictionary *)object intoReadingStatsContentItem:(LibreAccessServiceSvc_ReadingStatsContentItem *)intoObject;
- (void)fromObject:(NSDictionary *)object intoReadingStatsEntryItem:(LibreAccessServiceSvc_ReadingStatsEntryItem *)intoObject;
- (void)fromObject:(NSDictionary *)object intoTopFavoritesItem:(LibreAccessServiceSvc_TopFavoritesRequestItem *)intoObject;

- (id)makeNullNil:(id)object;

@end


@implementation SCHLibreAccessWebService

@synthesize binding;

#pragma mark - Object lifecycle

- (id)init
{
	self = [super init];
	if (self != nil) {
		binding = [[LibreAccessServiceSvc SCHLibreAccessServiceSoap11Binding] retain];
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
    self.binding = [LibreAccessServiceSvc SCHLibreAccessServiceSoap11Binding];
    binding.logXMLInOut = NO;		
}

#pragma mark - API Proxy methods

- (void)tokenExchange:(NSString *)pToken forUser:(NSString *)userName
{
	LibreAccessServiceSvc_TokenExchangeEx *request = [LibreAccessServiceSvc_TokenExchangeEx new];

	request.ptoken = pToken;
	request.vaid = [NSNumber numberWithInt:kSCHLibreAccessWebServiceVaid];
	request.deviceKey = @"";
	request.impersonationkey = @"";
	request.UserName = userName;
	
	[self.binding TokenExchangeExAsyncUsingBody:request delegate:self]; 
	[[BITNetworkActivityManager sharedNetworkActivityManager] showNetworkActivityIndicator];
	
	[request release], request = nil;
}

- (void)authenticateDevice:(NSString *)deviceKey forUserKey:(NSString *)userKey
{
	LibreAccessServiceSvc_AuthenticateDeviceRequest *request = [LibreAccessServiceSvc_AuthenticateDeviceRequest new];
    
	request.vaid = [NSNumber numberWithInt:kSCHLibreAccessWebServiceVaid];
	request.deviceKey = deviceKey;
	request.userKey = userKey;
	
	[self.binding AuthenticateDeviceAsyncUsingBody:request delegate:self]; 
	[[BITNetworkActivityManager sharedNetworkActivityManager] showNetworkActivityIndicator];
	
	[request release], request = nil;
}

- (void)renewToken:(NSString *)aToken
{
    LibreAccessServiceSvc_RenewTokenRequest *request = [LibreAccessServiceSvc_RenewTokenRequest new];
    
    request.authtoken = aToken;
    
    [self.binding RenewTokenAsyncUsingBody:request delegate:self]; 
    [[BITNetworkActivityManager sharedNetworkActivityManager] showNetworkActivityIndicator];
    
    [request release], request = nil;
}

- (BOOL)getUserProfiles
{
	BOOL ret = NO;
	
	if ([SCHAuthenticationManager sharedAuthenticationManager].isAuthenticated == YES) {		
		LibreAccessServiceSvc_GetUserProfilesRecommendationsRequest *request = [LibreAccessServiceSvc_GetUserProfilesRecommendationsRequest new];
		
		request.authtoken = [SCHAuthenticationManager sharedAuthenticationManager].aToken;
		
		[self.binding GetUserProfilesRecommendationsAsyncUsingParameters:request delegate:self]; 
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
        id saveProfileList = [[LibreAccessServiceSvc_SaveProfileList alloc] init];
		request.SaveProfileList = saveProfileList;
        [saveProfileList release];
		LibreAccessServiceSvc_SaveProfileItem *item = nil;
		for (id profile in userProfiles) {
			item = [[LibreAccessServiceSvc_SaveProfileItem alloc] init];
			[self fromObject:profile intoObject:item];		
			[request.SaveProfileList addSaveProfileItem:item];	
			[item release], item = nil;
		}	
		
		[self.binding SaveUserProfilesAsyncUsingParameters:request delegate:self]; 
		[[BITNetworkActivityManager sharedNetworkActivityManager] showNetworkActivityIndicator];
		
		[request release], request = nil;
		ret = YES;
	}
	
	return(ret);		
}

// we previously used listUserContent 
- (BOOL)listBooksAssignment
{
	BOOL ret = NO;
	
	if ([SCHAuthenticationManager sharedAuthenticationManager].isAuthenticated == YES) {
		LibreAccessServiceSvc_ListBooksAssignment *request = [LibreAccessServiceSvc_ListBooksAssignment new];
		
		request.authToken = [SCHAuthenticationManager sharedAuthenticationManager].aToken;
		
		[self.binding ListBooksAssignmentAsyncUsingBody:request delegate:self];
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

		[self.binding ListFavoriteTypesAsyncUsingParameters:request delegate:self]; 
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
        id topFavouritesRequestList = [[LibreAccessServiceSvc_TopFavoritesRequestList alloc] init];
		request.TopFavoritesRequestList = topFavouritesRequestList;
        [topFavouritesRequestList release];
		LibreAccessServiceSvc_TopFavoritesRequestItem *item = nil;
		for (id favorite in favorites) {
			item = [[LibreAccessServiceSvc_TopFavoritesRequestItem alloc] init];
			[self fromObject:favorite intoObject:item];
			[request.TopFavoritesRequestList addTopFavoritesRequestItem:item];
			[item release], item = nil;
		}
		
		[self.binding ListTopFavoritesAsyncUsingParameters:request delegate:self]; 
		[[BITNetworkActivityManager sharedNetworkActivityManager] showNetworkActivityIndicator];
		
		[request release], request = nil;	
		ret = YES;
	}
	
	return(ret);			
}

- (BOOL)listContentMetadata:(NSArray *)bookISBNs 
                includeURLs:(BOOL)includeURLs
               coverURLOnly:(BOOL)coverURLOnly
{
	BOOL ret = NO;
	
	if ([SCHAuthenticationManager sharedAuthenticationManager].isAuthenticated == YES) {				
		LibreAccessServiceSvc_ListContentMetadataForRatingsRequest *request = [LibreAccessServiceSvc_ListContentMetadataForRatingsRequest new];
		
		request.authtoken = [SCHAuthenticationManager sharedAuthenticationManager].aToken;
		USBoolean *includeurls = [[USBoolean alloc] initWithBool:includeURLs];
		request.includeurls = includeurls;
		[includeurls release], includeurls = nil;	
        USBoolean *coverurlonly = [[USBoolean alloc] initWithBool:coverURLOnly];        
        request.coverURLOnly = coverurlonly;
        [coverurlonly release], coverurlonly = nil;	
		LibreAccessServiceSvc_isbnItem *item = nil;
		for (id book in bookISBNs) {
			item = [[LibreAccessServiceSvc_isbnItem alloc] init];
			[self fromObject:book intoObject:item];
			[request addIsbn13s:item];	
			[item release], item = nil;
		}
		
		[self.binding ListContentMetadataForRatingsAsyncUsingBody:request delegate:self]; 
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
		LibreAccessServiceSvc_ListUserSettingsExRequest *request = [LibreAccessServiceSvc_ListUserSettingsExRequest new];
		
		request.authtoken = [SCHAuthenticationManager sharedAuthenticationManager].aToken;
		
		[self.binding ListUserSettingsExAsyncUsingParameters:request delegate:self]; 
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
		LibreAccessServiceSvc_SaveUserSettingsExRequest *request = [LibreAccessServiceSvc_SaveUserSettingsExRequest new];
		
		request.authtoken = [SCHAuthenticationManager sharedAuthenticationManager].aToken;
        request.settingsList = [[[LibreAccessServiceSvc_SettingsList alloc] init] autorelease];
		LibreAccessServiceSvc_SettingItem *item = nil;
		for (id setting in settings) {
			item = [[LibreAccessServiceSvc_SettingItem alloc] init];
			[self fromObject:setting intoObject:item];
			[request.settingsList addSettingItem:item];	
			[item release], item = nil;
		}
		
		[self.binding SaveUserSettingsExAsyncUsingParameters:request delegate:self]; 
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
		LibreAccessServiceSvc_ListProfileContentAnnotationsForRatingsRequest *request = [LibreAccessServiceSvc_ListProfileContentAnnotationsForRatingsRequest new];
		
		request.authtoken = [SCHAuthenticationManager sharedAuthenticationManager].aToken;
        LibreAccessServiceSvc_AnnotationsRequestListForRatings *annotationsRequestList = [[LibreAccessServiceSvc_AnnotationsRequestListForRatings alloc] init];
        LibreAccessServiceSvc_AnnotationsRequestItemForRatings *annotationsRequestItem = [[LibreAccessServiceSvc_AnnotationsRequestItemForRatings alloc] init];
        LibreAccessServiceSvc_AnnotationsRequestContentList *annotationsRequestContentList = [[LibreAccessServiceSvc_AnnotationsRequestContentList alloc] init];
		request.AnnotationsRequestList = annotationsRequestList;
		[annotationsRequestList addAnnotationsRequestItem:annotationsRequestItem];
        annotationsRequestItem.profileID = profileID;
		annotationsRequestItem.AnnotationsRequestContentList = annotationsRequestContentList;
		
		LibreAccessServiceSvc_AnnotationsRequestContentItem *item = nil;
		for (id annotation in annotations) {
			item = [[LibreAccessServiceSvc_AnnotationsRequestContentItem alloc] init];
			[self fromObject:annotation intoObject:item];
			[annotationsRequestContentList addAnnotationsRequestContentItem:item];
			[item release], item = nil;
		}
        request.includeRemoved = [[[USBoolean alloc] initWithBool:YES] autorelease];
        [annotationsRequestContentList release];
        [annotationsRequestItem release];        
        [annotationsRequestList release];
		
		[self.binding ListProfileContentAnnotationsForRatingsAsyncUsingParameters:request delegate:self]; 
		[[BITNetworkActivityManager sharedNetworkActivityManager] showNetworkActivityIndicator];
		
		[request release], request = nil;
		ret = YES;
	}
	
	return(ret);							
}

// we save books with a modified LastPage and within each book annotations that 
// have been modified
- (BOOL)saveProfileContentAnnotations:(NSArray *)annotations
{
	BOOL ret = NO;
	
	if ([SCHAuthenticationManager sharedAuthenticationManager].isAuthenticated == YES) {										
		LibreAccessServiceSvc_SaveProfileContentAnnotationsForRatingsRequest *request = [LibreAccessServiceSvc_SaveProfileContentAnnotationsForRatingsRequest new];
		
		request.authtoken = [SCHAuthenticationManager sharedAuthenticationManager].aToken;
        id annotationsList = [[LibreAccessServiceSvc_AnnotationsForRatingsList alloc] init];
		request.AnnotationsList = annotationsList;
        [annotationsList release];
		LibreAccessServiceSvc_AnnotationsForRatingsItem *item = nil;
		for (id annotation in annotations) {
			item = [[LibreAccessServiceSvc_AnnotationsForRatingsItem alloc] init];
			[self fromObject:annotation intoObject:item];
			[request.AnnotationsList addAnnotationsForRatingsItem:item];
			[item release], item = nil;
		}
		
		[self.binding SaveProfileContentAnnotationsForRatingsAsyncUsingParameters:request delegate:self]; 
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
        id contentProfileAssignmentList = [[LibreAccessServiceSvc_ContentProfileAssignmentList alloc] init];
		request.ContentProfileAssignmentList = contentProfileAssignmentList;
        [contentProfileAssignmentList release];
        
		LibreAccessServiceSvc_ContentProfileAssignmentItem *item = nil;
		for (id contentProfileAssignment in contentProfileAssignments) {
			item = [[LibreAccessServiceSvc_ContentProfileAssignmentItem alloc] init];
			[self fromObject:contentProfileAssignment intoObject:item];
			[request.ContentProfileAssignmentList addContentProfileAssignmentItem:item];
			[item release], item = nil;
		}
		
		[self.binding SaveContentProfileAssignmentAsyncUsingParameters:request delegate:self]; 
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
        id newReadingStatsDetailList = [[LibreAccessServiceSvc_ReadingStatsDetailList alloc] init];
		request.ReadingStatsDetailList = newReadingStatsDetailList;
        [newReadingStatsDetailList release];
        
		LibreAccessServiceSvc_ReadingStatsDetailItem *item = nil;
		for (id readingStatsDetail in readingStatsDetailList) {
			item = [[LibreAccessServiceSvc_ReadingStatsDetailItem alloc] init];
			[self fromObject:readingStatsDetail intoObject:item];
			[request.ReadingStatsDetailList addReadingStatsDetailItem:item];
			[item release], item = nil;
		}
		
		[self.binding SaveReadingStatisticsDetailedAsyncUsingParameters:request delegate:self]; 
		[[BITNetworkActivityManager sharedNetworkActivityManager] showNetworkActivityIndicator];
		
		[request release], request = nil;	
		ret = YES;
	}
	
	return(ret);										
}

#pragma mark - LibreAccessServiceSoap12BindingResponse Delegate methods

- (void)operation:(LibreAccessServiceSoap11BindingOperation *)operation completedWithResponse:(LibreAccessServiceSoap11BindingResponse *)response
{	
	[[BITNetworkActivityManager sharedNetworkActivityManager] hideNetworkActivityIndicator];
	
	// just in case we have a stray operation make sure it's bound to the current binding
    if (self.binding == operation.binding ) {
        NSString *methodName = [self methodNameFromObject:operation];
        
        if (operation.response.error != nil) {
            if ([(id)self.delegate respondsToSelector:@selector(method:didFailWithError:requestInfo:result:)]) {
                [(id)self.delegate method:methodName didFailWithError:[self confirmErrorDomain:operation.response.error 
                                                                                 forDomainName:@"LibreAccessServiceSoap11BindingResponseHTTP"]
                              requestInfo:[self requestInfoFromOperation:operation] result:nil];
            }
        } else {
            for (id bodyPart in response.bodyParts) {
                if ([bodyPart isKindOfClass:[SOAPFault class]]) {
                    [self reportFault:(SOAPFault *)bodyPart forMethod:methodName 
                          requestInfo:[self requestInfoFromOperation:operation]];
                    continue;
                }
                
                LibreAccessServiceSvc_StatusHolder *status = nil;
                BOOL errorTriggered = NO;
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
                       [(id)self.delegate respondsToSelector:@selector(method:didFailWithError:requestInfo:result:)]) {
                        errorTriggered = YES;
                        [(id)self.delegate method:methodName didFailWithError:[self errorFromStatusMessage:status] 
                                      requestInfo:[self requestInfoFromOperation:operation]
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
		if([anObject isKindOfClass:[LibreAccessServiceSvc_TokenExchangeEx class]] == YES ||
		   [anObject isKindOfClass:[LibreAccessServiceSvc_TokenExchangeExResponse class]] == YES ||		   
		   [anObject isKindOfClass:[LibreAccessServiceSoap11Binding_TokenExchangeEx class]] == YES) {
			ret = kSCHLibreAccessWebServiceTokenExchange;	
		} else if([anObject isKindOfClass:[LibreAccessServiceSvc_AuthenticateDeviceRequest class]] == YES ||
				  [anObject isKindOfClass:[LibreAccessServiceSvc_AuthenticateDeviceResponse class]] == YES ||
				  [anObject isKindOfClass:[LibreAccessServiceSoap11Binding_AuthenticateDevice class]] == YES) {
			ret = kSCHLibreAccessWebServiceAuthenticateDevice;	
		} else if([anObject isKindOfClass:[LibreAccessServiceSvc_RenewTokenRequest class]] == YES ||
				  [anObject isKindOfClass:[LibreAccessServiceSvc_RenewTokenResponse class]] == YES ||
				  [anObject isKindOfClass:[LibreAccessServiceSoap11Binding_RenewToken class]] == YES) {
			ret = kSCHLibreAccessWebServiceRenewToken;	
		} else if([anObject isKindOfClass:[LibreAccessServiceSvc_GetUserProfilesRecommendationsRequest class]] == YES ||
				  [anObject isKindOfClass:[LibreAccessServiceSvc_GetUserProfilesRecommendationsResponse class]] == YES ||
				  [anObject isKindOfClass:[LibreAccessServiceSoap11Binding_GetUserProfilesRecommendations class]] == YES) {
			ret = kSCHLibreAccessWebServiceGetUserProfiles;	
		} else if([anObject isKindOfClass:[LibreAccessServiceSvc_ListBooksAssignment class]] == YES ||
				  [anObject isKindOfClass:[LibreAccessServiceSvc_ListBooksAssignmentResponse class]] == YES ||
				  [anObject isKindOfClass:[LibreAccessServiceSoap11Binding_ListBooksAssignment class]] == YES) {
			ret = kSCHLibreAccessWebServiceListBooksAssignment;
		} else if([anObject isKindOfClass:[LibreAccessServiceSvc_ListContentMetadataForRatingsRequest class]] == YES ||
				  [anObject isKindOfClass:[LibreAccessServiceSvc_ListContentMetadataForRatingsResponse class]] == YES ||
				  [anObject isKindOfClass:[LibreAccessServiceSoap11Binding_ListContentMetadataForRatings class]] == YES) {
			ret = kSCHLibreAccessWebServiceListContentMetadata;				
		} else if([anObject isKindOfClass:[LibreAccessServiceSvc_SaveUserProfilesRequest class]] == YES ||
				  [anObject isKindOfClass:[LibreAccessServiceSvc_SaveUserProfilesResponse class]] == YES ||
				  [anObject isKindOfClass:[LibreAccessServiceSoap11Binding_SaveUserProfiles class]] == YES) {
			ret = kSCHLibreAccessWebServiceSaveUserProfiles;				
		} else if([anObject isKindOfClass:[LibreAccessServiceSvc_ListUserSettingsExRequest class]] == YES ||
				  [anObject isKindOfClass:[LibreAccessServiceSvc_ListUserSettingsExResponse class]] == YES ||
				  [anObject isKindOfClass:[LibreAccessServiceSoap11Binding_ListUserSettingsEx class]] == YES) {
			ret = kSCHLibreAccessWebServiceListUserSettings;				
		} else if([anObject isKindOfClass:[LibreAccessServiceSvc_SaveUserSettingsExRequest class]] == YES ||
				  [anObject isKindOfClass:[LibreAccessServiceSvc_SaveUserSettingsExResponse class]] == YES ||
				  [anObject isKindOfClass:[LibreAccessServiceSoap11Binding_SaveUserSettingsEx class]] == YES) {
			ret = kSCHLibreAccessWebServiceSaveUserSettings;				
		} else if([anObject isKindOfClass:[LibreAccessServiceSvc_ListProfileContentAnnotationsForRatingsRequest class]] == YES ||
				  [anObject isKindOfClass:[LibreAccessServiceSvc_ListProfileContentAnnotationsForRatingsResponse class]] == YES ||
				  [anObject isKindOfClass:[LibreAccessServiceSoap11Binding_ListProfileContentAnnotationsForRatings class]] == YES) {
			ret = kSCHLibreAccessWebServiceListProfileContentAnnotationsForRatings;				
		} else if([anObject isKindOfClass:[LibreAccessServiceSvc_SaveProfileContentAnnotationsForRatingsRequest class]] == YES ||
				  [anObject isKindOfClass:[LibreAccessServiceSvc_SaveProfileContentAnnotationsForRatingsResponse class]] == YES ||
				  [anObject isKindOfClass:[LibreAccessServiceSoap11Binding_SaveProfileContentAnnotationsForRatings class]] == YES) {
			ret = kSCHLibreAccessWebServiceSaveProfileContentAnnotationsForRatings;
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

- (NSDictionary *)requestInfoFromOperation:(LibreAccessServiceSoap11BindingOperation *)operation
{
    NSDictionary * ret = nil;
    
    if ([operation isKindOfClass:[LibreAccessServiceSoap11Binding_ListContentMetadataForRatings class]] == YES) {
        id body = [(id)operation body];
        
        NSMutableArray *isbnItems = [NSMutableArray array];
        for (LibreAccessServiceSvc_isbnItem *isbnItem in [body isbn13s]) {
            [isbnItems addObject:[self objectFromISBNItem:isbnItem]];
        }
        
        ret = [NSDictionary dictionaryWithObject:isbnItems forKey:kSCHLibreAccessWebServiceListContentMetadata];
    }
    
    return(ret);
}

#pragma mark -
#pragma mark ObjectMapper Protocol methods 
	
- (NSDictionary *)objectFrom:(id)anObject
{
	NSDictionary *ret = nil;
	
	if (anObject != nil) {
		if ([anObject isKindOfClass:[LibreAccessServiceSvc_TokenExchangeExResponse class]] == YES) {
			ret = [self objectFromTokenExchange:anObject];
		} else if ([anObject isKindOfClass:[LibreAccessServiceSvc_AuthenticateDeviceResponse class]] == YES) {
			ret = [self objectFromAuthenticateDevice:anObject];
		} else if ([anObject isKindOfClass:[LibreAccessServiceSvc_RenewTokenResponse class]] == YES) {
			ret = [self objectFromRenewToken:anObject];
		} else if ([anObject isKindOfClass:[LibreAccessServiceSvc_GetUserProfilesRecommendationsResponse class]] == YES) {
			ret = [NSDictionary dictionaryWithObject:[self objectFromTranslate:[[anObject ProfileList] ProfileItem]] forKey:kSCHLibreAccessWebServiceProfileList];
		} else if ([anObject isKindOfClass:[LibreAccessServiceSvc_ListBooksAssignmentResponse class]] == YES) {
			ret = [NSDictionary dictionaryWithObject:[self objectFromTranslate:[[anObject booksAssignmentList] booksAssignment]] forKey:kSCHLibreAccessWebServiceUserContentList];
		} else if ([anObject isKindOfClass:[LibreAccessServiceSvc_ListContentMetadataForRatingsResponse class]] == YES) {
			ret = [NSDictionary dictionaryWithObject:[self objectFromTranslate:[[anObject ContentMetadataForRatingsList] ContentMetadataForRatingsItem]] forKey:kSCHLibreAccessWebServiceContentMetadataList];
		} else if ([anObject isKindOfClass:[LibreAccessServiceSvc_SaveUserProfilesResponse class]] == YES) {
			ret = [NSDictionary dictionaryWithObject:[self objectFromTranslate:[[anObject ProfileStatusList] ProfileStatusItem]] forKey:kSCHLibreAccessWebServiceProfileStatusList];
		} else if ([anObject isKindOfClass:[LibreAccessServiceSvc_ListUserSettingsExResponse class]] == YES) {
			ret = [NSDictionary dictionaryWithObject:[self objectFromTranslate:[[anObject settingsList] settingItem]] forKey:kSCHLibreAccessWebServiceUserSettingsList];
		} else if ([anObject isKindOfClass:[LibreAccessServiceSvc_ListProfileContentAnnotationsForRatingsResponse class]] == YES) {
			NSMutableDictionary *listProfileContentAnnotations = [NSMutableDictionary dictionary];
			
			[listProfileContentAnnotations setObject:[self objectFromTranslate:[[anObject AnnotationsForRatingsList] AnnotationsForRatingsItem]] forKey:kSCHLibreAccessWebServiceAnnotationsList];
			[listProfileContentAnnotations setObject:[self objectFromItemsCount:[anObject ItemsCount]] forKey:kSCHLibreAccessWebServiceItemsCount];			

			ret = [NSDictionary dictionaryWithObject:listProfileContentAnnotations forKey:kSCHLibreAccessWebServiceListProfileContentAnnotationsForRatings];
		} else if ([anObject isKindOfClass:[LibreAccessServiceSvc_SaveContentProfileAssignmentResponse class]] == YES) {
			ret = nil;	// only returns the status so nothing to return
		} else if ([anObject isKindOfClass:[LibreAccessServiceSvc_SaveReadingStatisticsDetailedResponse class]] == YES) {
			ret = nil;	// only returns the status so nothing to return
		} else if ([anObject isKindOfClass:[LibreAccessServiceSvc_ListFavoriteTypesResponse class]] == YES) {
			ret = [NSDictionary dictionaryWithObject:[self objectFromTranslate:[[anObject FavoriteTypesList] FavoriteTypesItem]] forKey:kSCHLibreAccessWebServiceFavoriteTypesList];
		} else if ([anObject isKindOfClass:[LibreAccessServiceSvc_ListTopFavoritesResponse class]] == YES) {
			ret = [NSDictionary dictionaryWithObject:[self objectFromTranslate:[[anObject TopFavoritesResponseList] TopFavoritesResponseItem]] forKey:kSCHLibreAccessWebServiceTopFavoritesList];
		} else if ([anObject isKindOfClass:[LibreAccessServiceSvc_SaveProfileContentAnnotationsForRatingsResponse class]] == YES) {
			ret = [NSDictionary dictionaryWithObject:[self objectFromTranslate:[[anObject AnnotationStatusForRatingsList] AnnotationStatusForRatingsItem]] forKey:kSCHLibreAccessWebServiceAnnotationStatusList];
		} else if ([anObject isKindOfClass:[LibreAccessServiceSvc_SaveUserSettingsExResponse class]] == YES) {
			ret = [NSDictionary dictionaryWithObject:[self objectFromTranslate:[[anObject settingStatusList] settingStatusItem]] forKey:kSCHLibreAccessWebServiceUserSettingsStatusList];
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
		} else if ([intoObject isKindOfClass:[LibreAccessServiceSvc_SettingItem class]] == YES) {
			[self fromObject:object intoSettingItem:intoObject];
		} else if ([intoObject isKindOfClass:[LibreAccessServiceSvc_AnnotationsRequestContentItem class]] == YES) {
			[self fromObject:object intoAnnotationsRequestContentItem:intoObject];
		} else if ([intoObject isKindOfClass:[LibreAccessServiceSvc_AnnotationsForRatingsItem class]] == YES) {
			[self fromObject:object intoAnnotationsForRatingsItem:intoObject];
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

- (NSDictionary *)objectFromTokenExchange:(LibreAccessServiceSvc_TokenExchangeExResponse *)anObject
{
	NSDictionary *ret = nil;
	
	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];
		
		[objects setObject:[self objectFromTranslate:anObject.authtoken] forKey:kSCHLibreAccessWebServiceAuthToken];
		[objects setObject:[self objectFromTranslate:anObject.expiresIn] forKey:kSCHLibreAccessWebServiceExpiresIn];
        [objects setObject:[self objectFromTranslate:anObject.userKey] forKey:kSCHLibreAccessWebServiceUserKey];
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
		[objects setObject:[self objectFromTranslate:anObject.userKey] forKey:kSCHLibreAccessWebServiceUserKey];        

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
		[objects setObject:[self objectFromTranslate:anObject.userKey] forKey:kSCHLibreAccessWebServiceUserKey];        
        
		ret = objects;				
	}
	
	return(ret);
}

- (NSDictionary *)objectFromProfileItem:(LibreAccessServiceSvc_ProfileItemRecommendations *)anObject
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
		[objects setObject:[NSNumber numberWithProfileType:(SCHProfileTypes)anObject.type] forKey:kSCHLibreAccessWebServiceType];		
		[objects setObject:[self objectFromTranslate:anObject.id_] forKey:kSCHLibreAccessWebServiceID];		
		[objects setObject:[NSNumber numberWithBookshelfStyle:(SCHBookshelfStyles)anObject.BookshelfStyle] forKey:kSCHLibreAccessWebServiceBookshelfStyle];		
		[objects setObject:[self objectFromTranslate:anObject.recommendationsOn] forKey:kSCHLibreAccessWebServiceRecommendationsOn];		        
		[objects setObject:[self objectFromTranslate:anObject.LastModified] forKey:kSCHLibreAccessWebServiceLastModified];		
		[objects setObject:[self objectFromTranslate:anObject.LastScreenNameModified] forKey:kSCHLibreAccessWebServiceLastScreenNameModified];		
		[objects setObject:[self objectFromTranslate:anObject.LastPasswordModified] forKey:kSCHLibreAccessWebServiceLastPasswordModified];		
		[objects setObject:[self objectFromTranslate:anObject.storyInteractionEnabled] forKey:kSCHLibreAccessWebServiceStoryInteractionEnabled];		
		
		ret = objects;					
	}
	
	return(ret);
}

- (NSDictionary *)objectFromBooksAssignment:(LibreAccessServiceSvc_BooksAssignment *)anObject
{
	NSDictionary *ret = nil;
	
	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];
		
		[objects setObject:[self objectFromTranslate:anObject.ContentIdentifier] forKey:kSCHLibreAccessWebServiceContentIdentifier];
		[objects setObject:[NSNumber numberWithContentIdentifierType:(SCHContentIdentifierTypes)anObject.ContentIdentifierType] forKey:kSCHLibreAccessWebServiceContentIdentifierType];		
		[objects setObject:[NSNumber numberWithDRMQualifier:(SCHDRMQualifiers)anObject.DRMQualifier] forKey:kSCHLibreAccessWebServiceDRMQualifier];		
		[objects setObject:[self objectFromTranslate:anObject.Format] forKey:kSCHLibreAccessWebServiceFormat];		
		[objects setObject:[self objectFromTranslate:anObject.version] forKey:kSCHLibreAccessWebServiceVersion];
		[objects setObject:[self objectFromTranslate:anObject.averageRating] forKey:kSCHLibreAccessWebServiceAverageRating];
		[objects setObject:[self objectFromTranslate:anObject.lastOrderDate] forKey:kSCHLibreAccessWebServiceLastOrderDate];
		[objects setObject:[self objectFromTranslate:anObject.defaultAssignment] forKey:kSCHLibreAccessWebServiceDefaultAssignment];
        [objects setObject:[self objectFromTranslate:anObject.freeBook] forKey:kSCHLibreAccessWebServiceFreeBook];
		[objects setObject:[self objectFromTranslate:anObject.lastVersion] forKey:kSCHLibreAccessWebServiceLastVersion];
		[objects setObject:[self objectFromTranslate:anObject.quantity] forKey:kSCHLibreAccessWebServiceQuantity];
		[objects setObject:[self objectFromTranslate:anObject.quantityInit] forKey:kSCHLibreAccessWebServiceQuantityInit];
		[objects setObject:[self objectFromTranslate:[[anObject contentProfileList] ContentProfileForRatingsItem]] forKey:kSCHLibreAccessWebServiceProfileList];

        //		[objects setObject:[self objectFromTranslate:[[anObject OrderList] OrderItem]] forKey:kSCHLibreAccessWebServiceOrderList];
//		[objects setObject:[self objectFromTranslate:anObject.lastmodified] forKey:kSCHLibreAccessWebServiceLastModified];
//		
        ret = objects;					
	}
	
	return(ret);
}

- (NSDictionary *)objectFromContentProfileForRatingsItem:(LibreAccessServiceSvc_ContentProfileForRatingsItem *)anObject
{
	NSDictionary *ret = nil;
	
	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];
		
		[objects setObject:[self objectFromTranslate:anObject.profileID] forKey:kSCHLibreAccessWebServiceProfileID];
		[objects setObject:[self objectFromTranslate:anObject.lastPageLocation] forKey:kSCHLibreAccessWebServiceLastPageLocation];
		[objects setObject:[self objectFromTranslate:anObject.lastmodified] forKey:kSCHLibreAccessWebServiceLastModified];
		[objects setObject:[self objectFromTranslate:anObject.rating] forKey:kSCHLibreAccessWebServiceRating];
		
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

- (NSDictionary *)objectFromContentMetadataForRatingsItem:(LibreAccessServiceSvc_ContentMetadataForRatingsItem *)anObject
{
	NSDictionary *ret = nil;
	
	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];
		
		[objects setObject:[self objectFromTranslate:anObject.ContentIdentifier] forKey:kSCHLibreAccessWebServiceContentIdentifier];
		[objects setObject:[NSNumber numberWithContentIdentifierType:(SCHContentIdentifierTypes)anObject.ContentIdentifierType] forKey:kSCHLibreAccessWebServiceContentIdentifierType];
		[objects setObject:[self objectFromTranslate:anObject.Title] forKey:kSCHLibreAccessWebServiceTitle];
		[objects setObject:[self objectFromTranslate:anObject.Author] forKey:kSCHLibreAccessWebServiceAuthor];
		[objects setObject:[self objectFromTranslate:anObject.Description] forKey:kSCHLibreAccessWebServiceDescription];
		[objects setObject:[self objectFromTranslate:anObject.Version] forKey:kSCHLibreAccessWebServiceVersion];
		[objects setObject:[self objectFromTranslate:anObject.PageNumber] forKey:kSCHLibreAccessWebServicePageNumber];
		[objects setObject:[self objectFromTranslate:anObject.FileSize] forKey:kSCHLibreAccessWebServiceFileSize];
		[objects setObject:[NSNumber numberWithDRMQualifier:(SCHDRMQualifiers)anObject.DRMQualifier] forKey:kSCHLibreAccessWebServiceDRMQualifier];
		[objects setObject:[self objectFromTranslate:anObject.CoverURL] forKey:kSCHLibreAccessWebServiceCoverURL];
		[objects setObject:[self objectFromTranslate:anObject.ContentURL] forKey:kSCHLibreAccessWebServiceContentURL];
		[objects setObject:[self objectFromTranslate:anObject.EreaderCategories] forKey:kSCHLibreAccessWebServiceeReaderCategories];
		[objects setObject:[self objectFromTranslate:anObject.Enhanced] forKey:kSCHLibreAccessWebServiceEnhanced];
		[objects setObject:[self objectFromTranslate:anObject.AverageRating] forKey:kSCHLibreAccessWebServiceAverageRating];
				
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
		[objects setObject:[NSNumber numberWithSaveAction:(SCHSaveActions)anObject.action] forKey:kSCHLibreAccessWebServiceAction];
		[objects setObject:[NSNumber numberWithStatusCode:(SCHStatusCodes)anObject.status] forKey:kSCHLibreAccessWebServiceStatus];
		[objects setObject:[self objectFromTranslate:anObject.screenname] forKey:kSCHLibreAccessWebServiceScreenName];
		[objects setObject:[self objectFromTranslate:anObject.statuscode] forKey:kSCHLibreAccessWebServiceStatusCode];
		[objects setObject:[self objectFromTranslate:anObject.statusmessage] forKey:kSCHLibreAccessWebServiceStatusMessage];
		
		ret = objects;					
	}
	
	return(ret);
}

- (NSDictionary *)objectFromSettingItem:(LibreAccessServiceSvc_SettingItem *)anObject
{
	NSDictionary *ret = nil;
	
	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];
		
		[objects setObject:[self objectFromTranslate:anObject.settingName] forKey:kSCHLibreAccessWebServiceSettingName];
		[objects setObject:[self objectFromTranslate:anObject.settingValue] forKey:kSCHLibreAccessWebServiceSettingValue];
		
		ret = objects;					
	}
	
	return(ret);
}

- (NSDictionary *)objectFromSettingsStatusItem:(LibreAccessServiceSvc_SettingStatusItem *)anObject
{
    NSDictionary *ret = nil;
    
    if (anObject != nil) {
        NSMutableDictionary *objects = [NSMutableDictionary dictionary];
        
        [objects setObject:[self objectFromTranslate:anObject.settingName   ] forKey:kSCHLibreAccessWebServiceSettingName];
        [objects setObject:[self objectFromTranslate:anObject.statusMessage] forKey:kSCHLibreAccessWebServiceStatusMessage];
        
        ret = objects;					
    }
    
    return(ret);
}

- (NSDictionary *)objectFromAnnotationsForRatingsItem:(LibreAccessServiceSvc_AnnotationsForRatingsItem *)anObject
{
	NSDictionary *ret = nil;
	
	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];
		
		[objects setObject:[self objectFromTranslate:[[anObject AnnotationsContentForRatingsList] AnnotationsContentForRatingsItem]] forKey:kSCHLibreAccessWebServiceAnnotationsContentList];
		[objects setObject:[self objectFromTranslate:anObject.profileID] forKey:kSCHLibreAccessWebServiceProfileID];
		
		ret = objects;					
	}
	
	return(ret);
}

- (NSDictionary *)objectFromAnnotationsContentForRatingsItem:(LibreAccessServiceSvc_AnnotationsContentForRatingsItem *)anObject
{
	NSDictionary *ret = nil;
	
	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];
		
		[objects setObject:[self objectFromTranslate:anObject.contentIdentifier] forKey:kSCHLibreAccessWebServiceContentIdentifier];
		[objects setObject:[NSNumber numberWithContentIdentifierType:(SCHContentIdentifierTypes)anObject.ContentIdentifierType] forKey:kSCHLibreAccessWebServiceContentIdentifierType];
		[objects setObject:[NSNumber numberWithDRMQualifier:(SCHDRMQualifiers)anObject.drmqualifier] forKey:kSCHLibreAccessWebServiceDRMQualifier];
		[objects setObject:[self objectFromTranslate:anObject.format] forKey:kSCHLibreAccessWebServiceFormat];
		[objects setObject:[self objectFromTranslate:anObject.PrivateAnnotations] forKey:kSCHLibreAccessWebServicePrivateAnnotations];
		
		ret = objects;					
	}
	
	return(ret);
}

- (NSDictionary *)objectFromPrivateAnnotations:(LibreAccessServiceSvc_PrivateAnnotationsForRatings *)anObject
{
	NSDictionary *ret = nil;
	
	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];
                
		[objects setObject:[self objectFromTranslate:[anObject.Highlights Highlight]] forKey:kSCHLibreAccessWebServiceHighlights];
        if ([[SCHAppStateManager sharedAppStateManager] canSyncNotes] == YES) {
            [objects setObject:[self objectFromTranslate:[anObject.Notes Note]] forKey:kSCHLibreAccessWebServiceNotes];
        }
		[objects setObject:[self objectFromTranslate:[anObject.Bookmarks Bookmark]] forKey:kSCHLibreAccessWebServiceBookmarks];

		[objects setObject:[self objectFromTranslate:anObject.LastPage] forKey:kSCHLibreAccessWebServiceLastPage];
		[objects setObject:[self objectFromTranslate:anObject.Rating] forKey:kSCHLibreAccessWebServiceRating];
        
		ret = objects;					
	}
	
	return(ret);
}

- (NSDictionary *)objectFromRating:(LibreAccessServiceSvc_Rating *)anObject
{
	NSDictionary *ret = nil;
	
	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];
        
		[objects setObject:[self objectFromTranslate:anObject.rating] forKey:kSCHLibreAccessWebServiceRating];
		[objects setObject:[self objectFromTranslate:anObject.lastmodified] forKey:kSCHLibreAccessWebServiceLastModified];
		[objects setObject:[self objectFromTranslate:anObject.averageRating] forKey:kSCHLibreAccessWebServiceAverageRating];
        
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
		[objects setObject:[NSNumber numberWithSaveAction:(SCHSaveActions)anObject.action] forKey:kSCHLibreAccessWebServiceAction];
		[objects setObject:[self objectFromTranslate:anObject.color] forKey:kSCHLibreAccessWebServiceColor];
		[objects setObject:[self objectFromTranslate:anObject.location] forKey:kSCHLibreAccessWebServiceLocation];
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
		[objects setObject:[self objectFromTranslate:anObject.wordindex] forKey:kSCHLibreAccessWebServiceWordIndex];
		
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
		[objects setObject:[NSNumber numberWithSaveAction:(SCHSaveActions)anObject.action] forKey:kSCHLibreAccessWebServiceAction];
		[objects setObject:[self objectFromTranslate:anObject.location] forKey:kSCHLibreAccessWebServiceLocation];
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
		[objects setObject:[NSNumber numberWithSaveAction:(SCHSaveActions)anObject.action] forKey:kSCHLibreAccessWebServiceAction];
		[objects setObject:[self objectFromTranslate:anObject.text] forKey:kSCHLibreAccessWebServiceText];
		[objects setObject:[self objectFromTranslate:anObject.disabled] forKey:kSCHLibreAccessWebServiceDisabled];
		[objects setObject:[self objectFromTranslate:anObject.location] forKey:kSCHLibreAccessWebServiceLocation];
		[objects setObject:[self objectFromTranslate:anObject.version] forKey:kSCHLibreAccessWebServiceVersion];
		[objects setObject:[self objectFromTranslate:anObject.lastmodified] forKey:kSCHLibreAccessWebServiceLastModified];
		
		ret = objects;					
	}
	
	return(ret);
}

- (NSDictionary *)objectFromLocationBookmark:(LibreAccessServiceSvc_LocationBookmark *)anObject
{
	NSDictionary *ret = nil;
	
	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];
		
		[objects setObject:[self objectFromTranslate:anObject.page] forKey:kSCHLibreAccessWebServicePage];
		
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
		
		[objects setObject:[NSNumber numberWithTopFavoritesType:(SCHTopFavoritesTypes)anObject.FavoriteType] forKey:kSCHLibreAccessWebServiceFavoriteType];
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
		
		[objects setObject:[NSNumber numberWithTopFavoritesType:(SCHTopFavoritesTypes)anObject.TopFavoritesType] forKey:kSCHLibreAccessWebServiceTopFavoritesType];
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
		[objects setObject:[NSNumber numberWithContentIdentifierType:(SCHContentIdentifierTypes)anObject.ContentIdentifierType] forKey:kSCHLibreAccessWebServiceContentIdentifierType];
		
		ret = objects;					
	}
	
	return(ret);
}

- (NSDictionary *)objectFromAnnotationStatusForRatingsItem:(LibreAccessServiceSvc_AnnotationStatusForRatingsItem *)anObject
{
	NSDictionary *ret = nil;
	
	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];
		
		[objects setObject:[self objectFromTranslate:anObject.profileId] forKey:kSCHLibreAccessWebServiceProfileID];
		[objects setObject:[self objectFromTranslate:anObject.statusmessage] forKey:kSCHLibreAccessWebServiceStatusMessage];
		[objects setObject:[self objectFromTranslate:[anObject.AnnotationStatusContentForRatingsList AnnotationStatusContentForRatingsItem]] forKey:kSCHLibreAccessWebServiceAnnotationStatusContentList];
		
		ret = objects;					
	}
	
	return(ret);
}

- (NSDictionary *)objectFromStatusHolder:(LibreAccessServiceSvc_StatusHolder *)anObject
{
	NSDictionary *ret = nil;
	
	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];
		
		[objects setObject:[NSNumber numberWithStatusCode:(SCHStatusCodes)anObject.status] forKey:kSCHLibreAccessWebServiceStatus];
		[objects setObject:[self objectFromTranslate:anObject.statuscode] forKey:kSCHLibreAccessWebServiceStatusCode];
		[objects setObject:[self objectFromTranslate:anObject.statusmessage] forKey:kSCHLibreAccessWebServiceStatusMessage];
		
		ret = objects;					
	}
	
	return(ret);
}

- (NSDictionary *)objectFromAnnotationStatusContentForRatingsItem:(LibreAccessServiceSvc_AnnotationStatusContentForRatingsItem *)anObject
{
	NSDictionary *ret = nil;
	
	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];
		
		[objects setObject:[self objectFromTranslate:anObject.contentIdentifier] forKey:kSCHLibreAccessWebServiceContentIdentifier];
		[objects setObject:[self objectFromTranslate:anObject.statusmessage] forKey:kSCHLibreAccessWebServiceStatusMessage];        
		[objects setObject:[self objectFromTranslate:anObject.PrivateAnnotationsStatus] forKey:kSCHLibreAccessWebServicePrivateAnnotationsStatus];
		[objects setObject:[self objectFromTranslate:anObject.AverageRating] forKey:kSCHLibreAccessWebServiceAverageRating];
		
		ret = objects;					
	}
	
	return(ret);
}

- (NSMutableDictionary *)objectFromPrivateAnnotationsStatus:(LibreAccessServiceSvc_PrivateAnnotationsStatusForRatings *)anObject
{
	NSMutableDictionary *ret = nil;
	
	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];
		
		[objects setObject:[self objectFromTranslate:[anObject.HighlightsStatusList AnnotationTypeStatusItem]] forKey:kSCHLibreAccessWebServiceHighlightsStatusList];
        [objects setObject:[self objectFromTranslate:[anObject.NotesStatusList AnnotationTypeStatusItem]] forKey:kSCHLibreAccessWebServiceNotesStatusList];
        [objects setObject:[self objectFromTranslate:[anObject.BookmarksStatusList AnnotationTypeStatusItem]] forKey:kSCHLibreAccessWebServiceBookmarksStatusList];

        [objects setObject:[self objectFromTranslate:anObject.LastPageStatus] forKey:kSCHLibreAccessWebServiceLastPageStatus];
        [objects setObject:[self objectFromTranslate:anObject.RatingStatus] forKey:kSCHLibreAccessWebServiceRatingStatus];
        
		ret = objects;					
	}
	
	return(ret);
}

- (NSDictionary *)objectFromAnnotationTypeStatusItem:(LibreAccessServiceSvc_AnnotationTypeStatusItem *)anObject
{
	NSDictionary *ret = nil;
	
	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];
		
		[objects setObject:[self objectFromTranslate:anObject.id_] forKey:kSCHLibreAccessWebServiceID];
        [objects setObject:[NSNumber numberWithSaveAction:(SCHSaveActions)anObject.action] forKey:kSCHLibreAccessWebServiceAction];
		[objects setObject:[self objectFromTranslate:anObject.statusmessage] forKey:kSCHLibreAccessWebServiceStatusMessage];
                
		ret = objects;					
	}
	
	return(ret);
}

- (NSDictionary *)objectFromISBNItem:(LibreAccessServiceSvc_isbnItem *)anObject
{
	NSDictionary *ret = nil;
	
	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];
		
		[objects setObject:[self objectFromTranslate:anObject.ISBN] forKey:kSCHLibreAccessWebServiceContentIdentifier];
        [objects setObject:[self objectFromTranslate:anObject.Format] forKey:kSCHLibreAccessWebServiceFormat];
		[objects setObject:[NSNumber numberWithContentIdentifierType:(SCHContentIdentifierTypes)anObject.IdentifierType] forKey:kSCHLibreAccessWebServiceContentIdentifierType];
		[objects setObject:[NSNumber numberWithDRMQualifier:(SCHDRMQualifiers)anObject.Qualifier] forKey:kSCHLibreAccessWebServiceDRMQualifier];
        
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
			
			if ([firstItem isKindOfClass:[LibreAccessServiceSvc_ProfileItemRecommendations class]] == YES) {
				for (id item in anObject) {
					[ret addObject:[self objectFromProfileItem:item]];					
				}
			} else if ([firstItem isKindOfClass:[LibreAccessServiceSvc_BooksAssignment class]] == YES) {
				for (id item in anObject) {				
					[ret addObject:[self objectFromBooksAssignment:item]];
				}
			} else if ([firstItem isKindOfClass:[LibreAccessServiceSvc_ContentProfileForRatingsItem class]] == YES) {
				for (id item in anObject) {
					[ret addObject:[self objectFromContentProfileForRatingsItem:item]];					
				}
			} else if ([firstItem isKindOfClass:[LibreAccessServiceSvc_OrderItem class]] == YES) {
				for (id item in anObject) {
					[ret addObject:[self objectFromOrderItem:item]];									
				}
			} else if ([firstItem isKindOfClass:[LibreAccessServiceSvc_ContentMetadataForRatingsItem class]] == YES) {
				for (id item in anObject) {
					[ret addObject:[self objectFromContentMetadataForRatingsItem:item]];													
				}
			} else if ([firstItem isKindOfClass:[LibreAccessServiceSvc_ProfileStatusItem class]] == YES) {
				for (id item in anObject) {
					[ret addObject:[self objectFromProfileStatusItem:item]];													
				}
			} else if ([firstItem isKindOfClass:[LibreAccessServiceSvc_SettingItem class]] == YES) {
				for (id item in anObject) {
					[ret addObject:[self objectFromSettingItem:item]];	
				}
			} else if ([firstItem isKindOfClass:[LibreAccessServiceSvc_AnnotationsForRatingsItem class]] == YES) {
				for (id item in anObject) {
					[ret addObject:[self objectFromAnnotationsForRatingsItem:item]];	
				}
			} else if ([firstItem isKindOfClass:[LibreAccessServiceSvc_AnnotationsContentForRatingsItem class]] == YES) {
				for (id item in anObject) {
					[ret addObject:[self objectFromAnnotationsContentForRatingsItem:item]];	
				}
			} else if ([firstItem isKindOfClass:[LibreAccessServiceSvc_PrivateAnnotationsForRatings class]] == YES) {
				for (id item in anObject) {
					[ret addObject:[self objectFromPrivateAnnotations:item]];	
				}
			} else if ([firstItem isKindOfClass:[LibreAccessServiceSvc_Rating class]] == YES) {
				for (id item in anObject) {
					[ret addObject:[self objectFromRating:item]];	
				}                
			} else if ([firstItem isKindOfClass:[LibreAccessServiceSvc_Highlight class]] == YES) {
				for (id item in anObject) {
					[ret addObject:[self objectFromHighlight:item]];	
				}
			} else if ([firstItem isKindOfClass:[LibreAccessServiceSvc_Note class]] == YES) {
				for (id item in anObject) {
					[ret addObject:[self objectFromNote:item]];
				}
            } else if ([firstItem isKindOfClass:[LibreAccessServiceSvc_Bookmark class]] == YES) {
				for (id item in anObject) {
					[ret addObject:[self objectFromBookmark:item]];
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
			} else if ([firstItem isKindOfClass:[LibreAccessServiceSvc_AnnotationStatusForRatingsItem class]] == YES) {
				for (id item in anObject) {
                    // the server sends a separate AnnotationStatusContentItem
                    // for each bookmark/note/highlight/rating/last page (it 
                    // shouldnt but it does) so we combine them here
                    NSDictionary *newAnnotationStatusForRatingsItem = [self objectFromAnnotationStatusForRatingsItem:item];

                    if (newAnnotationStatusForRatingsItem != nil) {
                        NSNumber *newProfileID = [self makeNullNil:[newAnnotationStatusForRatingsItem objectForKey:kSCHLibreAccessWebServiceProfileID]];
                        NSUInteger statusAlreadyExists = NSNotFound;
                        
                        if (newProfileID != nil) {
                            statusAlreadyExists = [ret indexOfObjectPassingTest:^BOOL (id obj, NSUInteger idx, BOOL *stop) {
                                NSNumber *currentProfileID = [self makeNullNil:[obj objectForKey:kSCHLibreAccessWebServiceProfileID]];
                                if ([currentProfileID isEqualToNumber:newProfileID] == YES) {
                                    *stop = YES;
                                    return YES;
                                } else {
                                    return NO;
                                }
                            }];
                        }
                        
                        if (statusAlreadyExists == NSNotFound) {
                            [self combineMultipleAnnotationStatusContentBooks:newAnnotationStatusForRatingsItem];
                            [ret addObject:newAnnotationStatusForRatingsItem];	
                        } else {
                            NSDictionary *existingAnnotationStatusForRatingsItem = [ret objectAtIndex:statusAlreadyExists];
                            NSArray *existingAnnotationStatusContentList = [self makeNullNil:[existingAnnotationStatusForRatingsItem objectForKey:kSCHLibreAccessWebServiceAnnotationStatusContentList]];
                            NSArray *newAnnotationStatusContentList = [self makeNullNil:[newAnnotationStatusForRatingsItem objectForKey:kSCHLibreAccessWebServiceAnnotationStatusContentList]];
                            
                            for (NSDictionary *newAnnotationStatusContent in newAnnotationStatusContentList) {
                                NSString *newContentIdentifier = [self makeNullNil:[newAnnotationStatusContent objectForKey:kSCHLibreAccessWebServiceContentIdentifier]];                                
                                NSIndexSet *existingBooks = nil;
                                
                                if (newContentIdentifier != nil) {
                                    existingBooks = [existingAnnotationStatusContentList indexesOfObjectsPassingTest:^BOOL (id obj, NSUInteger idx, BOOL *stop) {
                                        NSString *currentContentIdentifer = [self makeNullNil:[obj objectForKey:kSCHLibreAccessWebServiceContentIdentifier]];
                                        return [currentContentIdentifer isEqualToString:newContentIdentifier];
                                    }];
                                }
                                
                                [existingBooks enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                                    NSDictionary *existingBook = [existingAnnotationStatusContentList objectAtIndex:idx];
                                    
                                    [self overwritePrivateAnnotations:[self makeNullNil:[existingBook objectForKey:kSCHLibreAccessWebServicePrivateAnnotationsStatus]]
                                               withPrivateAnnotations:[self makeNullNil:[newAnnotationStatusContent objectForKey:kSCHLibreAccessWebServicePrivateAnnotationsStatus]]];                                                                        
                                }];
                            }
                        }
                    }
				}
			} else if ([firstItem isKindOfClass:[LibreAccessServiceSvc_AnnotationStatusContentForRatingsItem class]] == YES) {
				for (id item in anObject) {
					[ret addObject:[self objectFromAnnotationStatusContentForRatingsItem:item]];	
				}                
			} else if ([firstItem isKindOfClass:[LibreAccessServiceSvc_AnnotationTypeStatusItem class]] == YES) {
				for (id item in anObject) {
					[ret addObject:[self objectFromAnnotationTypeStatusItem:item]];	
				}                                
			} else if ([firstItem isKindOfClass:[LibreAccessServiceSvc_ProfileStatusItem class]] == YES) {
				for (id item in anObject) {
					[ret addObject:[self objectFromProfileStatusItem:item]];	
				}                                
			} else if ([firstItem isKindOfClass:[LibreAccessServiceSvc_SettingStatusItem class]] == YES) {
				for (id item in anObject) {
					[ret addObject:[self objectFromSettingsStatusItem:item]];	
				}                                
			}
        }		
	} else if([anObject isKindOfClass:[USBoolean class]] == YES) {
		ret = [NSNumber numberWithBool:[anObject boolValue]];
    } else if ([anObject isKindOfClass:[LibreAccessServiceSvc_StatusHolder class]] == YES) {
        ret = [self objectFromStatusHolder:anObject];	
    } else if ([anObject isKindOfClass:[LibreAccessServiceSvc_PrivateAnnotationsStatusForRatings class]] == YES) {
        ret = [self objectFromPrivateAnnotationsStatus:anObject];	
    } else if ([anObject isKindOfClass:[LibreAccessServiceSvc_AnnotationTypeStatusItem class]] == YES) {
        ret = [self objectFromAnnotationTypeStatusItem:anObject];	
    } else if ([anObject isKindOfClass:[LibreAccessServiceSvc_PrivateAnnotationsForRatings class]] == YES) {
        ret = [self objectFromPrivateAnnotations:anObject];	                        
    } else if ([anObject isKindOfClass:[LibreAccessServiceSvc_LocationText class]] == YES) {
        ret = [self objectFromLocationText:anObject];	                
    } else if ([anObject isKindOfClass:[LibreAccessServiceSvc_WordIndex class]] == YES) {
        ret = [self objectFromWordIndex:anObject];	                        
    } else if ([anObject isKindOfClass:[LibreAccessServiceSvc_LocationGraphics class]] == YES) {
        ret = [self objectFromLocationGraphics:anObject];	                        
    } else if ([anObject isKindOfClass:[LibreAccessServiceSvc_LocationBookmark class]] == YES) {
        ret = [self objectFromLocationBookmark:anObject];	                        
    } else if ([anObject isKindOfClass:[LibreAccessServiceSvc_LastPage class]] == YES) {
        ret = [self objectFromLastPage:anObject];
    } else if ([anObject isKindOfClass:[LibreAccessServiceSvc_Rating class]] == YES) {
        ret = [self objectFromRating:anObject];
	} else {
		ret = anObject;
	}

	return(ret);
}

- (void)combineMultipleAnnotationStatusContentBooks:(NSDictionary *)annotationStatusForRatingsItem
{
    NSMutableArray *annotationStatusContentList = [self makeNullNil:[annotationStatusForRatingsItem objectForKey:kSCHLibreAccessWebServiceAnnotationStatusContentList]];
    
    if ([annotationStatusContentList count] > 1) {
        for (NSUInteger idx = 1; idx < [annotationStatusContentList count]; idx++) {
            NSDictionary *annotationStatusContent = [annotationStatusContentList objectAtIndex:idx];
            NSString *contentIdentifier = [self makeNullNil:[annotationStatusContent objectForKey:kSCHLibreAccessWebServiceContentIdentifier]];                                
            NSIndexSet *existingBooks = nil;
            
            if (contentIdentifier != nil) {
                existingBooks = [annotationStatusContentList indexesOfObjectsPassingTest:^BOOL (id obj, NSUInteger idx, BOOL *stop) {
                    NSString *currentContentIdentifer = [self makeNullNil:[obj objectForKey:kSCHLibreAccessWebServiceContentIdentifier]];
                    return (obj != annotationStatusContent &&
                        [currentContentIdentifer isEqualToString:contentIdentifier]);
                }];
            }
            
            NSMutableIndexSet *deleteBooks = [NSMutableIndexSet indexSet];
            [existingBooks enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                NSDictionary *duplicateBook = [annotationStatusContentList objectAtIndex:idx];
                
                if (duplicateBook != annotationStatusContent) {
                    [self overwritePrivateAnnotations:[self makeNullNil:[annotationStatusContent objectForKey:kSCHLibreAccessWebServicePrivateAnnotationsStatus]]
                               withPrivateAnnotations:[self makeNullNil:[duplicateBook objectForKey:kSCHLibreAccessWebServicePrivateAnnotationsStatus]]];                                                                        
                    
                    [deleteBooks addIndex:idx];
                }
            }];
            [annotationStatusContentList removeObjectsAtIndexes:deleteBooks];
        }
    }
}

- (void)overwritePrivateAnnotations:(NSMutableDictionary *)existingPrivateAnnotations
             withPrivateAnnotations:(NSDictionary *)newPrivateAnnotations
{        
    if (existingPrivateAnnotations != nil && newPrivateAnnotations != nil &&
        existingPrivateAnnotations != newPrivateAnnotations) {
        NSDictionary *newHighlights = [self makeNullNil:[newPrivateAnnotations objectForKey:kSCHLibreAccessWebServiceHighlightsStatusList]];
        if ([newHighlights count] > 0) {
            [existingPrivateAnnotations setValue:newHighlights forKey:kSCHLibreAccessWebServiceHighlightsStatusList];
        }
        NSDictionary *newNotes = [self makeNullNil:[newPrivateAnnotations objectForKey:kSCHLibreAccessWebServiceNotesStatusList]];                
        if ([newNotes count] > 0) {
            [existingPrivateAnnotations setValue:newNotes forKey:kSCHLibreAccessWebServiceNotesStatusList];
        }                
        NSDictionary *newBookmarks = [self makeNullNil:[newPrivateAnnotations objectForKey:kSCHLibreAccessWebServiceBookmarksStatusList]];                                
        if ([newBookmarks count] > 0) {
            [existingPrivateAnnotations setValue:newBookmarks forKey:kSCHLibreAccessWebServiceBookmarksStatusList];
        }
        
        NSDictionary *newLastPage = [self makeNullNil:[newPrivateAnnotations objectForKey:kSCHLibreAccessWebServiceLastPageStatus]];                                                
        if (newLastPage != nil) {
            [existingPrivateAnnotations setValue:newLastPage forKey:kSCHLibreAccessWebServiceLastPageStatus];
        }                
        NSDictionary *newRating = [self makeNullNil:[newPrivateAnnotations objectForKey:kSCHLibreAccessWebServiceRatingStatus]];                                 
        if (newRating != nil) {
            [existingPrivateAnnotations setValue:newRating forKey:kSCHLibreAccessWebServiceRatingStatus];
        }
    }
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
		intoObject.type = (LibreAccessServiceSvc_ProfileTypes)[[object valueForKey:kSCHLibreAccessWebServiceType] profileTypeValue];
		intoObject.action = (LibreAccessServiceSvc_SaveActions)[[self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceAction]] saveActionValue];
        if (intoObject.action != kSCHSaveActionsCreate) {
            intoObject.id_ = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceID]];
		} else {
            intoObject.id_ = [NSNumber numberWithInt:0];
        }
		intoObject.BookshelfStyle = (LibreAccessServiceSvc_BookshelfStyle)[[object valueForKey:kSCHLibreAccessWebServiceBookshelfStyle] bookshelfStyleValue];
		intoObject.storyInteractionEnabled = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceStoryInteractionEnabled]];
	}
}

- (void)fromObject:(NSDictionary *)object intoISBNItem:(LibreAccessServiceSvc_isbnItem *)intoObject
{
	if (object != nil && intoObject != nil) {
		intoObject.ISBN = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceContentIdentifier]];
        // hard coded to XPS, same as the windows application
//		intoObject.Format = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceFormat]];
        intoObject.Format = @"XPS";
		intoObject.IdentifierType = (LibreAccessServiceSvc_ContentIdentifierTypes)[[object valueForKey:kSCHLibreAccessWebServiceContentIdentifierType] contentIdentifierTypeValue];
		intoObject.Qualifier = (LibreAccessServiceSvc_drmqualifiers)[[object valueForKey:kSCHLibreAccessWebServiceDRMQualifier] DRMQualifierValue];
	}
}

- (void)fromObject:(NSDictionary *)object intoSettingItem:(LibreAccessServiceSvc_SettingItem *)intoObject
{
	if (object != nil && intoObject != nil) {
		intoObject.settingName = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceSettingName]];
		intoObject.settingValue = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceSettingValue]];
	}
}

- (void)fromObject:(NSDictionary *)object intoAnnotationsRequestContentItem:(LibreAccessServiceSvc_AnnotationsRequestContentItem *)intoObject
{
	if (object != nil && intoObject != nil) {
		intoObject.contentIdentifier = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceContentIdentifier]];
		intoObject.ContentIdentifierType = (LibreAccessServiceSvc_ContentIdentifierTypes)[[object valueForKey:kSCHLibreAccessWebServiceContentIdentifierType] contentIdentifierTypeValue];
		intoObject.drmqualifier = (LibreAccessServiceSvc_drmqualifiers)[[object valueForKey:kSCHLibreAccessWebServiceDRMQualifier] DRMQualifierValue];
		intoObject.format = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceFormat]];
        id privateAnnotationsRequest = [[LibreAccessServiceSvc_PrivateAnnotationsRequest alloc] init];
		intoObject.PrivateAnnotationsRequest = privateAnnotationsRequest;
        [privateAnnotationsRequest release];
		[self fromObject:[object valueForKey:kSCHLibreAccessWebServicePrivateAnnotations] intoPrivateAnnotationsRequest:intoObject.PrivateAnnotationsRequest];
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

// we only save those annotation content items that have changed, i.e. the last page or rating has also change
- (void)fromObject:(NSDictionary *)object intoAnnotationsForRatingsItem:(LibreAccessServiceSvc_AnnotationsForRatingsItem *)intoObject
{
	if (object != nil && intoObject != nil) {
        id annotationsContentList = [[LibreAccessServiceSvc_AnnotationsContentForRatingsList alloc] init];
		intoObject.AnnotationsContentForRatingsList = annotationsContentList;
        [annotationsContentList release];
		for (NSDictionary *item in [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceAnnotationsContentItem]]) {
            if ([self annotationsContentItemHasChanges:item] == YES) {
                LibreAccessServiceSvc_AnnotationsContentForRatingsItem *annotationsContentItem = [[LibreAccessServiceSvc_AnnotationsContentForRatingsItem alloc] init];
                [self fromObject:item intoAnnotationsContentForRatingsItem:annotationsContentItem];
                [intoObject.AnnotationsContentForRatingsList addAnnotationsContentForRatingsItem:annotationsContentItem];
                [annotationsContentItem release];
            }
		}
		intoObject.profileID = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceProfileID]];
	}
}												

- (BOOL)annotationsContentItemHasChanges:(NSDictionary *)annotationsContentItem
{
    BOOL ret = NO;
    
    if (annotationsContentItem != nil) {
		NSDictionary *privateAnnotations = [annotationsContentItem valueForKey:kSCHLibreAccessWebServicePrivateAnnotations];        
        if (privateAnnotations != nil) {
            NSDictionary *lastPage = [privateAnnotations valueForKey:kSCHLibreAccessWebServiceLastPage];
            if (lastPage != nil) {
                if ([[lastPage valueForKey:kSCHLibreAccessWebServiceAction] saveActionValue] != kSCHSaveActionsNone) {
                    ret = YES;
                }
            }
            NSDictionary *rating = [privateAnnotations valueForKey:kSCHLibreAccessWebServiceRating];
            if (rating != nil) {
                if ([[rating valueForKey:kSCHLibreAccessWebServiceAction] saveActionValue] != kSCHSaveActionsNone) {
                    ret = YES;
                }
            }
            
        }
    }
    
    return ret;
}

- (void)fromObject:(NSDictionary *)object intoAnnotationsContentForRatingsItem:(LibreAccessServiceSvc_AnnotationsContentForRatingsItem *)intoObject
{
	if (object != nil && intoObject != nil) {
		intoObject.contentIdentifier = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceContentIdentifier]];
		intoObject.ContentIdentifierType = (LibreAccessServiceSvc_ContentIdentifierTypes)[[self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceContentIdentifierType]] contentIdentifierTypeValue];
		intoObject.drmqualifier = (LibreAccessServiceSvc_drmqualifiers)[[self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceDRMQualifier]] DRMQualifierValue];		
		intoObject.format = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceFormat]];
        id privateAnnotations = [[LibreAccessServiceSvc_PrivateAnnotationsForRatings alloc] init];
		intoObject.PrivateAnnotations = privateAnnotations;
        [privateAnnotations release];
		[self fromObject:[object valueForKey:kSCHLibreAccessWebServicePrivateAnnotations] intoPrivateAnnotations:intoObject.PrivateAnnotations];
	}
}												

// returns the most recent last modified date
- (NSDate *)latestLastModifiedFromPrivateAnnotations:(NSDictionary *)privateAnnotations
{
    NSDate *ret = nil;
    NSDate *lastModified = nil;
    
    if (privateAnnotations != nil) {
        for (NSDictionary *item in [self fromObjectTranslate:[privateAnnotations valueForKey:kSCHLibreAccessWebServiceHighlights]]) {
            if ([[self fromObjectTranslate:[item valueForKey:kSCHLibreAccessWebServiceAction]] saveActionValue] != kSCHSaveActionsNone) {
                lastModified = [self fromObjectTranslate:[item valueForKey:kSCHLibreAccessWebServiceLastModified]];
                if (lastModified != nil && 
                    (ret == nil || [ret earlierDate:lastModified] == ret)) {
                    ret = lastModified;
                }
            }
		}

        if ([[SCHAppStateManager sharedAppStateManager] canSyncNotes] == YES) {
            for (NSDictionary *item in [self fromObjectTranslate:[privateAnnotations valueForKey:kSCHLibreAccessWebServiceNotes]]) {
                if ([[self fromObjectTranslate:[item valueForKey:kSCHLibreAccessWebServiceAction]] saveActionValue] != kSCHSaveActionsNone) {
                    lastModified = [self fromObjectTranslate:[item valueForKey:kSCHLibreAccessWebServiceLastModified]];
                    if (lastModified != nil && 
                        (ret == nil || [ret earlierDate:lastModified] == ret)) {
                        ret = lastModified;
                    }
                }
            }
        }

        for (NSDictionary *item in [self fromObjectTranslate:[privateAnnotations valueForKey:kSCHLibreAccessWebServiceBookmarks]]) {
            if ([[self fromObjectTranslate:[item valueForKey:kSCHLibreAccessWebServiceAction]] saveActionValue] != kSCHSaveActionsNone) {
                lastModified = [self fromObjectTranslate:[item valueForKey:kSCHLibreAccessWebServiceLastModified]];
                if (lastModified != nil && 
                    (ret == nil || [ret earlierDate:lastModified] == ret)) {
                    ret = lastModified;
                }
            }
		}

        NSDictionary *lastPage = [self fromObjectTranslate:[privateAnnotations valueForKey:kSCHLibreAccessWebServiceLastPage]];
        if (lastPage != nil) {
            lastModified = [self fromObjectTranslate:[lastPage valueForKey:kSCHLibreAccessWebServiceLastModified]];
            if (lastModified != nil && 
                (ret == nil || [ret earlierDate:lastModified] == ret)) {
                ret = lastModified;
            }            
        }
        
        NSDictionary *rating = [self fromObjectTranslate:[privateAnnotations valueForKey:kSCHLibreAccessWebServiceRating]];
        if (rating != nil) {
            lastModified = [self fromObjectTranslate:[rating valueForKey:kSCHLibreAccessWebServiceLastModified]];
            if (lastModified != nil && 
                (ret == nil || [ret earlierDate:lastModified] == ret)) {
                ret = lastModified;
            }            
        }
        
    }
    
    return ret;
}

// only creates annotation objects that have a status, i.e. need to be saved
- (void)fromObject:(NSDictionary *)object intoPrivateAnnotations:(LibreAccessServiceSvc_PrivateAnnotationsForRatings *)intoObject
{
	if (object != nil && intoObject != nil) {
        id highlights = [[LibreAccessServiceSvc_Highlights alloc] init];
		intoObject.Highlights = highlights;
        [highlights release];
		for (NSDictionary *item in [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceHighlights]]) {
			if ([[self fromObjectTranslate:[item valueForKey:kSCHLibreAccessWebServiceAction]] saveActionValue] != kSCHSaveActionsNone) {
                LibreAccessServiceSvc_Highlight *highlight = [[LibreAccessServiceSvc_Highlight alloc] init];
                [self fromObject:item intoHighlight:highlight];
                [intoObject.Highlights addHighlight:highlight];
                [highlight release], highlight = nil;
            }
		}
		
        id notes = [[LibreAccessServiceSvc_Notes alloc] init];
		intoObject.Notes = notes;
        [notes release];
        if ([[SCHAppStateManager sharedAppStateManager] canSyncNotes] == YES) {
            for (NSDictionary *item in [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceNotes]]) {
                if ([[self fromObjectTranslate:[item valueForKey:kSCHLibreAccessWebServiceAction]] saveActionValue] != kSCHSaveActionsNone) {
                    LibreAccessServiceSvc_Note *note = [[LibreAccessServiceSvc_Note alloc] init];
                    [self fromObject:item intoNote:note];
                    [intoObject.Notes addNote:note];
                    [note release], note = nil;
                }
            }
		}
		
        id bookmarks = [[LibreAccessServiceSvc_Bookmarks alloc] init];
		intoObject.Bookmarks = bookmarks;
        [bookmarks release];
		for (NSDictionary *item in [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceBookmarks]]) {
            if ([[self fromObjectTranslate:[item valueForKey:kSCHLibreAccessWebServiceAction]] saveActionValue] != kSCHSaveActionsNone) {
                LibreAccessServiceSvc_Bookmark *bookmark = [[LibreAccessServiceSvc_Bookmark alloc] init];
                [self fromObject:item intoBookmark:bookmark];
                [intoObject.Bookmarks addBookmark:bookmark];
                [bookmark release], bookmark = nil;
            }
		}
        
        id lastPage = [[LibreAccessServiceSvc_LastPage alloc] init];
		intoObject.LastPage = lastPage;
        [lastPage release];
		[self fromObject:[self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceLastPage]] intoLastPage:intoObject.LastPage];
        
        id rating = [[LibreAccessServiceSvc_Rating alloc] init];
		intoObject.Rating = rating;
        [rating release];
		[self fromObject:[self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceRating]] intoRating:intoObject.Rating];
	}
}												

- (void)fromObject:(NSDictionary *)object intoHighlight:(LibreAccessServiceSvc_Highlight *)intoObject
{
	if (object != nil && intoObject != nil) {
		intoObject.action = (LibreAccessServiceSvc_SaveActions)[[self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceAction]] saveActionValue];
        if (intoObject.action != kSCHSaveActionsCreate) {
            intoObject.id_ = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceID]];
		}
		intoObject.color = [object valueForKey:kSCHLibreAccessWebServiceColor];	
        id location = [[LibreAccessServiceSvc_LocationText alloc] init];
		intoObject.location = location;
        [location release];
		[self fromObject:[self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceLocation]] intoLocationText:intoObject.location];
		intoObject.endPage = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceEndPage]];		
		intoObject.version = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceVersion]];				
		intoObject.lastmodified = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceLastModified]];				
	}	
}

- (void)fromObject:(NSDictionary *)object intoLocationText:(LibreAccessServiceSvc_LocationText *)intoObject
{
	if (object != nil && intoObject != nil) {
		intoObject.page = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServicePage]];
        id wordIndex = [[LibreAccessServiceSvc_WordIndex alloc] init];
		intoObject.wordindex = wordIndex;
        [wordIndex release];
		[self fromObject:[self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceWordIndex]] intoWordIndex:intoObject.wordindex];
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
		intoObject.action = (LibreAccessServiceSvc_SaveActions)[[self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceAction]] saveActionValue];
        if (intoObject.action != kSCHSaveActionsCreate) {
            intoObject.id_ = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceID]];
		}
        id location = [[LibreAccessServiceSvc_LocationGraphics alloc] init];
		intoObject.location = location;
        [location release];
		[self fromObject:[self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceLocation]] intoLocationGraphics:intoObject.location];
		intoObject.color = [object valueForKey:kSCHLibreAccessWebServiceColor];
		intoObject.value = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceValue]];		
		intoObject.version = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceVersion]];				
		intoObject.lastmodified = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceLastModified]];				
	}	
}

- (void)fromObject:(NSDictionary *)object intoLocationGraphics:(LibreAccessServiceSvc_LocationGraphics *)intoObject
{
	if (object != nil && intoObject != nil) {
		intoObject.page = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServicePage]];
        id coords = [[LibreAccessServiceSvc_Coords alloc] init];
		intoObject.coords = coords;
		[coords release];
        // default values as Scholastic doesnt actually use these values
		intoObject.coords.x = [NSNumber numberWithInteger:0];
        intoObject.coords.y = [NSNumber numberWithInteger:0];
//		intoObject.wordindex = nil;
	}	
}

- (void)fromObject:(NSDictionary *)object intoBookmark:(LibreAccessServiceSvc_Bookmark *)intoObject
{
	if (object != nil && intoObject != nil) {
		intoObject.action = (LibreAccessServiceSvc_SaveActions)[[self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceAction]] saveActionValue];
        if (intoObject.action != kSCHSaveActionsCreate) {
            intoObject.id_ = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceID]];
		}
		intoObject.text = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceText]];
		intoObject.disabled = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceDisabled]];
		id location = [[LibreAccessServiceSvc_LocationBookmark alloc] init];
		intoObject.location = location;
		[location release];
		[self fromObject:[self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceLocation]] intoLocationBookmark:intoObject.location];
		intoObject.version = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceVersion]];						
		intoObject.lastmodified = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceLastModified]];				
	}	
}

- (void)fromObject:(NSDictionary *)object intoLocationBookmark:(LibreAccessServiceSvc_LocationBookmark *)intoObject
{
	if (object != nil && intoObject != nil) {
		intoObject.page = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServicePage]];
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

- (void)fromObject:(NSDictionary *)object intoRating:(LibreAccessServiceSvc_Rating *)intoObject
{
	if (object != nil && intoObject != nil) {
        if ([[SCHAppStateManager sharedAppStateManager] isCOPPACompliant] == YES) {
            intoObject.rating = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceRating]];
        } else {
            intoObject.rating = [NSNumber numberWithInteger:0];
        }
		intoObject.lastmodified = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceLastModified]];						
        intoObject.averageRating = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceAverageRating]]; 
	}	
}

- (void)fromObject:(NSDictionary *)object intoContentProfileAssignmentItem:(LibreAccessServiceSvc_ContentProfileAssignmentItem *)intoObject
{
	if (object != nil && intoObject != nil) {
		intoObject.contentIdentifier = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceContentIdentifier]];
		intoObject.ContentIdentifierType = (LibreAccessServiceSvc_ContentIdentifierTypes)[[self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceContentIdentifierType]] contentIdentifierTypeValue];
		intoObject.drmqualifier = (LibreAccessServiceSvc_drmqualifiers)[[self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceDRMQualifier]] DRMQualifierValue];		
		intoObject.format = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceFormat]];
        id assignedProfileList = [[LibreAccessServiceSvc_AssignedProfileList alloc] init];
		intoObject.AssignedProfileList = assignedProfileList;
        [assignedProfileList release];
		for (NSDictionary *item in [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceAssignedProfileList]]) {
			LibreAccessServiceSvc_AssignedProfileItem *contentProfileAssignmentItem = [[LibreAccessServiceSvc_AssignedProfileItem alloc] init];
			[self fromObject:item intoAssignedProfileItem:contentProfileAssignmentItem];
			[intoObject.AssignedProfileList addAssignedProfileItem:contentProfileAssignmentItem];
			[contentProfileAssignmentItem release], contentProfileAssignmentItem = nil;
		}
	}	
}

- (void)fromObject:(NSDictionary *)object intoAssignedProfileItem:(LibreAccessServiceSvc_AssignedProfileItem *)intoObject
{
	if (object != nil && intoObject != nil) {
		intoObject.profileID = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceProfileID]];
		intoObject.action = (LibreAccessServiceSvc_SaveActions)[[self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceAction]] saveActionValue];
		intoObject.lastmodified = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceLastModified]];				
	}	
}

- (void)fromObject:(NSDictionary *)object intoReadingStatsDetailItem:(LibreAccessServiceSvc_ReadingStatsDetailItem *)intoObject
{
	if (object != nil && intoObject != nil) {
        id readingStatsContentList = [[LibreAccessServiceSvc_ReadingStatsContentList alloc] init];
		intoObject.ReadingStatsContentList = readingStatsContentList;
        [readingStatsContentList release];
		for (NSDictionary *item in [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceReadingStatsContentItem]]) {
			LibreAccessServiceSvc_ReadingStatsContentItem *readingStatsContentItem = [[LibreAccessServiceSvc_ReadingStatsContentItem alloc] init];
			[self fromObject:item intoReadingStatsContentItem:readingStatsContentItem];
			[intoObject.ReadingStatsContentList addReadingStatsContentItem:readingStatsContentItem];
			[readingStatsContentItem release], readingStatsContentItem = nil;
		}
		intoObject.profileID = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceProfileID]];
	}	
}

- (void)fromObject:(NSDictionary *)object intoReadingStatsContentItem:(LibreAccessServiceSvc_ReadingStatsContentItem *)intoObject
{
	if (object != nil && intoObject != nil) {
		intoObject.ContentIdentifierType = (LibreAccessServiceSvc_ContentIdentifierTypes)[[self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceContentIdentifierType]] contentIdentifierTypeValue];
		intoObject.contentIdentifier = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceContentIdentifier]];
		intoObject.drmqualifier = (LibreAccessServiceSvc_drmqualifiers)[[self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceDRMQualifier]] DRMQualifierValue];		
		intoObject.format = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceFormat]];
        id readingStatsEntryList = [[LibreAccessServiceSvc_ReadingStatsEntryList alloc] init];
		intoObject.ReadingStatsEntryList = readingStatsEntryList;
        [readingStatsEntryList release];
		for (NSDictionary *item in [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceReadingStatsEntryItem]]) {
			LibreAccessServiceSvc_ReadingStatsEntryItem *readingStatsEntryItem = [[LibreAccessServiceSvc_ReadingStatsEntryItem alloc] init];
			[self fromObject:item intoReadingStatsEntryItem:readingStatsEntryItem];
			[intoObject.ReadingStatsEntryList addReadingStatsEntryItem:readingStatsEntryItem];
			[readingStatsEntryItem release], readingStatsEntryItem = nil;
		}
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
        id dictionaryLookupsList = [[LibreAccessServiceSvc_DictionaryLookupsList alloc] init];
		intoObject.DictionaryLookupsList = dictionaryLookupsList;
        [dictionaryLookupsList release];
		for (NSString *item in [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceDictionaryLookupsList]]) {
			[intoObject.DictionaryLookupsList addDictionaryLookupsItem:item];
		}
	}	
}

- (void)fromObject:(NSDictionary *)object intoTopFavoritesItem:(LibreAccessServiceSvc_TopFavoritesRequestItem *)intoObject
{
	if (object != nil && intoObject != nil) {
		intoObject.AssignedBooksOnly = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceAssignedBooksOnly]];
		intoObject.TopFavoritesType = (LibreAccessServiceSvc_TopFavoritesTypes)[[self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceTopFavoritesType]] topFavoritesTypeValue];
		intoObject.TopFavoritesTypeValue = [self fromObjectTranslate:[object valueForKey:kSCHLibreAccessWebServiceTopFavoritesTypeValue]];
	}	
}

- (id)makeNullNil:(id)object
{
    return(object == [NSNull null] ? nil : object);
}
                                                  
#pragma mark - Internal Debug Methods

// Call this from GDB with:
// call [[[[SCHSyncManager sharedSyncManager] profileSyncComponent] libreAccessWebService] debugCreateDefaultBookshelf]
// continue
- (void)debugCreateDefaultBookshelf
{
    NSMutableDictionary *item = [NSMutableDictionary dictionary];
    [item setValue:[NSNumber numberWithBool:YES] forKey:kSCHLibreAccessWebServiceAutoAssignContentToProfiles];
    [item setValue:[NSNumber numberWithBool:NO] forKey:kSCHLibreAccessWebServiceProfilePasswordRequired];
    [item setValue:@"John" forKey:kSCHLibreAccessWebServiceFirstName];
    [item setValue:@"Doe" forKey:kSCHLibreAccessWebServiceLastName];
    [item setValue:[NSDate date] forKey:kSCHLibreAccessWebServiceBirthday];
    [item setValue:[NSDate date] forKey:kSCHLibreAccessWebServiceLastModified];
    [item setValue:@"John Doe" forKey:kSCHLibreAccessWebServiceScreenName];
    [item setValue:@"" forKey:kSCHLibreAccessWebServicePassword];
//    [item setValue:@"Key" forKey:kSCHLibreAccessWebServiceUserKey];
    [item setValue:[NSNumber numberWithInt:LibreAccessServiceSvc_ProfileTypes_CHILD] forKey:kSCHLibreAccessWebServiceType];
    [item setValue:[NSNumber numberWithInt:0] forKey:kSCHLibreAccessWebServiceID];
    [item setValue:[NSNumber numberWithInt:LibreAccessServiceSvc_SaveActions_CREATE] forKey:kSCHLibreAccessWebServiceAction];
    [item setValue:[NSNumber numberWithInt:LibreAccessServiceSvc_BookshelfStyle_OLDER_CHILD] forKey:kSCHLibreAccessWebServiceBookshelfStyle];
    [item setValue:[NSNumber numberWithBool:YES] forKey:kSCHLibreAccessWebServiceStoryInteractionEnabled];
    [item setValue:[NSNumber numberWithInt:LibreAccessServiceSvc_SaveActions_CREATE] forKey:kSCHLibreAccessWebServiceAction];
    
    [self performSelector:@selector(saveUserProfiles:) withObject:[NSArray arrayWithObject:item] afterDelay:0.1f];
    
}

// Call this from GDB with:
// call [[[[SCHSyncManager sharedSyncManager] profileSyncComponent] libreAccessWebService] debugAssignBook:isbn toProfile:profile]
// continue
- (void)debugAssignBook:(NSString *)isbn toProfile:(NSUInteger)profileID
{
    
    /*
     NSNumber * profileID;
     LibreAccessServiceSvc_SaveActions action;
     NSDate * lastmodified;
     */
    
    NSMutableDictionary *profileList = [NSMutableDictionary dictionary];
    [profileList setValue:[NSNumber numberWithInt:profileID] forKey:kSCHLibreAccessWebServiceProfileID];
    [profileList setValue:[NSNumber numberWithInt:LibreAccessServiceSvc_SaveActions_CREATE] forKey:kSCHLibreAccessWebServiceAction];
    [profileList setValue:[NSDate date] forKey:kSCHLibreAccessWebServiceLastModified];
     
     /*
      NSString * contentIdentifier;
      LibreAccessServiceSvc_ContentIdentifierTypes ContentIdentifierType;
      LibreAccessServiceSvc_drmqualifiers drmqualifier;
      NSString * format;
      LibreAccessServiceSvc_AssignedProfileList * AssignedProfileList;
      */
    
    NSMutableDictionary *item = [NSMutableDictionary dictionary];
    [item setValue:isbn forKey:kSCHLibreAccessWebServiceContentIdentifier];
    [item setValue:[NSNumber numberWithInt:LibreAccessServiceSvc_ContentIdentifierTypes_ISBN13] forKey:kSCHLibreAccessWebServiceContentIdentifierType];
    [item setValue:[NSNumber numberWithInt:LibreAccessServiceSvc_drmqualifiers_FULL_NO_DRM] forKey:kSCHLibreAccessWebServiceDRMQualifier];
    [item setValue:@"XPS" forKey:kSCHLibreAccessWebServiceFormat];
    [item setValue:[NSArray arrayWithObject:profileList] forKey:kSCHLibreAccessWebServiceAssignedProfileList];
    
    [self performSelector:@selector(saveContentProfileAssignment:) withObject:[NSArray arrayWithObject:item] afterDelay:0.1f];
    
}

@end
