#import <Foundation/Foundation.h>
#import "USAdditions.h"
#import <libxml/tree.h>
#import "USGlobals.h"
#import <objc/runtime.h>
/* Cookies handling provided by http://en.wikibooks.org/wiki/Programming:WebObjects/Web_Services/Web_Service_Provider */
#import <libxml/parser.h>
#import "xsd.h"
#import "LibreAccessServiceSvc.h"
#import "tns1.h"
@class LibreAccessBinding;
@interface LibreAccessServiceSvc : NSObject {
	
}
+ (LibreAccessBinding *)LibreAccessBinding;
@end
@class LibreAccessBindingResponse;
@class LibreAccessBindingOperation;
@protocol LibreAccessBindingResponseDelegate <NSObject>
- (void) operation:(LibreAccessBindingOperation *)operation completedWithResponse:(LibreAccessBindingResponse *)response;
@end
@interface LibreAccessBinding : NSObject <LibreAccessBindingResponseDelegate> {
	NSURL *address;
	NSTimeInterval timeout;
	NSMutableArray *cookies;
	NSMutableDictionary *customHeaders;
	BOOL logXMLInOut;
	BOOL synchronousOperationComplete;
	NSString *authUsername;
	NSString *authPassword;
    NSMutableArray *operationPointers;
}
@property (nonatomic, copy) NSURL *address;
@property (nonatomic) BOOL logXMLInOut;
@property (nonatomic) NSTimeInterval timeout;
@property (nonatomic, retain) NSMutableArray *cookies;
@property (nonatomic, retain) NSMutableDictionary *customHeaders;
@property (nonatomic, retain) NSString *authUsername;
@property (nonatomic, retain) NSString *authPassword;
@property (nonatomic, retain) NSMutableArray *operationPointers;
+ (NSTimeInterval) defaultTimeout;
- (id)initWithAddress:(NSString *)anAddress;
- (void)sendHTTPCallUsingBody:(NSString *)body soapAction:(NSString *)soapAction forOperation:(LibreAccessBindingOperation *)operation;
- (void)addCookie:(NSHTTPCookie *)toAdd;
- (NSString *)MIMEType;
- (LibreAccessBindingResponse *)TokenExchangeUsingBody:(tns1_TokenExchange *)aBody ;
- (void)TokenExchangeAsyncUsingBody:(tns1_TokenExchange *)aBody  delegate:(id<LibreAccessBindingResponseDelegate>)responseDelegate;
- (LibreAccessBindingResponse *)SharedTokenExchangeUsingBody:(tns1_SharedTokenExchangeRequest *)aBody ;
- (void)SharedTokenExchangeAsyncUsingBody:(tns1_SharedTokenExchangeRequest *)aBody  delegate:(id<LibreAccessBindingResponseDelegate>)responseDelegate;
- (LibreAccessBindingResponse *)AuthenticateDeviceUsingBody:(tns1_AuthenticateDeviceRequest *)aBody ;
- (void)AuthenticateDeviceAsyncUsingBody:(tns1_AuthenticateDeviceRequest *)aBody  delegate:(id<LibreAccessBindingResponseDelegate>)responseDelegate;
- (LibreAccessBindingResponse *)RenewTokenUsingBody:(tns1_RenewTokenRequest *)aBody ;
- (void)RenewTokenAsyncUsingBody:(tns1_RenewTokenRequest *)aBody  delegate:(id<LibreAccessBindingResponseDelegate>)responseDelegate;
- (LibreAccessBindingResponse *)ListBooksAssignmentUsingBody:(tns1_ListBooksAssignmentRequest *)aBody ;
- (void)ListBooksAssignmentAsyncUsingBody:(tns1_ListBooksAssignmentRequest *)aBody  delegate:(id<LibreAccessBindingResponseDelegate>)responseDelegate;
- (LibreAccessBindingResponse *)ListUserContentUsingBody:(tns1_ListUserContent *)aBody ;
- (void)ListUserContentAsyncUsingBody:(tns1_ListUserContent *)aBody  delegate:(id<LibreAccessBindingResponseDelegate>)responseDelegate;
- (LibreAccessBindingResponse *)ListContentMetadataUsingBody:(tns1_ListContentMetadata *)aBody ;
- (void)ListContentMetadataAsyncUsingBody:(tns1_ListContentMetadata *)aBody  delegate:(id<LibreAccessBindingResponseDelegate>)responseDelegate;
- (LibreAccessBindingResponse *)IsEntitledToLicenseUsingParameters:(tns1_EntitledToLicenseRequest *)aParameters ;
- (void)IsEntitledToLicenseAsyncUsingParameters:(tns1_EntitledToLicenseRequest *)aParameters  delegate:(id<LibreAccessBindingResponseDelegate>)responseDelegate;
- (LibreAccessBindingResponse *)SaveReadingStatisticsDetailedUsingParameters:(tns1_SaveReadingStatisticsDetailedRequest *)aParameters ;
- (void)SaveReadingStatisticsDetailedAsyncUsingParameters:(tns1_SaveReadingStatisticsDetailedRequest *)aParameters  delegate:(id<LibreAccessBindingResponseDelegate>)responseDelegate;
- (LibreAccessBindingResponse *)ListReadingStatisticsAggregateUsingParameters:(tns1_ListReadingStatisticsAggregateRequest *)aParameters ;
- (void)ListReadingStatisticsAggregateAsyncUsingParameters:(tns1_ListReadingStatisticsAggregateRequest *)aParameters  delegate:(id<LibreAccessBindingResponseDelegate>)responseDelegate;
- (LibreAccessBindingResponse *)ListReadingStatisticsDetailedUsingParameters:(tns1_ListReadingStatisticsDetailedRequest *)aParameters ;
- (void)ListReadingStatisticsDetailedAsyncUsingParameters:(tns1_ListReadingStatisticsDetailedRequest *)aParameters  delegate:(id<LibreAccessBindingResponseDelegate>)responseDelegate;
- (LibreAccessBindingResponse *)ListReadingStatisticsMonthlyAverageUsingParameters:(tns1_ListReadingStatisticsMonthlyAverageRequest *)aParameters ;
- (void)ListReadingStatisticsMonthlyAverageAsyncUsingParameters:(tns1_ListReadingStatisticsMonthlyAverageRequest *)aParameters  delegate:(id<LibreAccessBindingResponseDelegate>)responseDelegate;
- (LibreAccessBindingResponse *)ListReadingStatisticsAggregateByTitleUsingParameters:(tns1_ListReadingStatisticsAggregateByTitleRequest *)aParameters ;
- (void)ListReadingStatisticsAggregateByTitleAsyncUsingParameters:(tns1_ListReadingStatisticsAggregateByTitleRequest *)aParameters  delegate:(id<LibreAccessBindingResponseDelegate>)responseDelegate;
- (LibreAccessBindingResponse *)ListReadingStatisticsDailyAggregateByTitleUsingParameters:(tns1_ListReadingStatisticsDailyAggregateByTitleRequest *)aParameters ;
- (void)ListReadingStatisticsDailyAggregateByTitleAsyncUsingParameters:(tns1_ListReadingStatisticsDailyAggregateByTitleRequest *)aParameters  delegate:(id<LibreAccessBindingResponseDelegate>)responseDelegate;
- (LibreAccessBindingResponse *)SaveProfileContentAnnotationsUsingParameters:(tns1_SaveProfileContentAnnotationsRequest *)aParameters ;
- (void)SaveProfileContentAnnotationsAsyncUsingParameters:(tns1_SaveProfileContentAnnotationsRequest *)aParameters  delegate:(id<LibreAccessBindingResponseDelegate>)responseDelegate;
- (LibreAccessBindingResponse *)ListProfileContentAnnotationsUsingParameters:(tns1_ListProfileContentAnnotationsRequest *)aParameters ;
- (void)ListProfileContentAnnotationsAsyncUsingParameters:(tns1_ListProfileContentAnnotationsRequest *)aParameters  delegate:(id<LibreAccessBindingResponseDelegate>)responseDelegate;
- (LibreAccessBindingResponse *)GetUserProfilesUsingParameters:(tns1_GetUserProfilesRequest *)aParameters ;
- (void)GetUserProfilesAsyncUsingParameters:(tns1_GetUserProfilesRequest *)aParameters  delegate:(id<LibreAccessBindingResponseDelegate>)responseDelegate;
- (LibreAccessBindingResponse *)SaveUserProfilesUsingParameters:(tns1_SaveUserProfilesRequest *)aParameters ;
- (void)SaveUserProfilesAsyncUsingParameters:(tns1_SaveUserProfilesRequest *)aParameters  delegate:(id<LibreAccessBindingResponseDelegate>)responseDelegate;
- (LibreAccessBindingResponse *)SaveContentProfileAssignmentUsingParameters:(tns1_SaveContentProfileAssignmentRequest *)aParameters ;
- (void)SaveContentProfileAssignmentAsyncUsingParameters:(tns1_SaveContentProfileAssignmentRequest *)aParameters  delegate:(id<LibreAccessBindingResponseDelegate>)responseDelegate;
- (LibreAccessBindingResponse *)GetDeviceInfoUsingParameters:(tns1_GetDeviceInfoRequest *)aParameters ;
- (void)GetDeviceInfoAsyncUsingParameters:(tns1_GetDeviceInfoRequest *)aParameters  delegate:(id<LibreAccessBindingResponseDelegate>)responseDelegate;
- (LibreAccessBindingResponse *)SaveDeviceInfoUsingParameters:(tns1_SaveDeviceInfoRequest *)aParameters ;
- (void)SaveDeviceInfoAsyncUsingParameters:(tns1_SaveDeviceInfoRequest *)aParameters  delegate:(id<LibreAccessBindingResponseDelegate>)responseDelegate;
- (LibreAccessBindingResponse *)SaveNewDomainUsingParameters:(tns1_SaveNewDomainRequest *)aParameters ;
- (void)SaveNewDomainAsyncUsingParameters:(tns1_SaveNewDomainRequest *)aParameters  delegate:(id<LibreAccessBindingResponseDelegate>)responseDelegate;
- (LibreAccessBindingResponse *)DeviceLeftDomainUsingParameters:(tns1_DeviceLeftDomainRequest *)aParameters ;
- (void)DeviceLeftDomainAsyncUsingParameters:(tns1_DeviceLeftDomainRequest *)aParameters  delegate:(id<LibreAccessBindingResponseDelegate>)responseDelegate;
- (LibreAccessBindingResponse *)DeviceCanJoinDomainUsingParameters:(tns1_DeviceCanJoinDomainRequest *)aParameters ;
- (void)DeviceCanJoinDomainAsyncUsingParameters:(tns1_DeviceCanJoinDomainRequest *)aParameters  delegate:(id<LibreAccessBindingResponseDelegate>)responseDelegate;
- (LibreAccessBindingResponse *)GetLicensableStatusUsingParameters:(tns1_GetLicensableStatusRequest *)aParameters ;
- (void)GetLicensableStatusAsyncUsingParameters:(tns1_GetLicensableStatusRequest *)aParameters  delegate:(id<LibreAccessBindingResponseDelegate>)responseDelegate;
- (LibreAccessBindingResponse *)AcknowledgeLicenseUsingParameters:(tns1_AcknowledgeLicenseRequest *)aParameters ;
- (void)AcknowledgeLicenseAsyncUsingParameters:(tns1_AcknowledgeLicenseRequest *)aParameters  delegate:(id<LibreAccessBindingResponseDelegate>)responseDelegate;
- (LibreAccessBindingResponse *)ValidateScreenNameUsingParameters:(tns1_ValidateScreenNameRequest *)aParameters ;
- (void)ValidateScreenNameAsyncUsingParameters:(tns1_ValidateScreenNameRequest *)aParameters  delegate:(id<LibreAccessBindingResponseDelegate>)responseDelegate;
- (LibreAccessBindingResponse *)ValidateUserKeyUsingParameters:(tns1_ValidateUserKeyRequest *)aParameters ;
- (void)ValidateUserKeyAsyncUsingParameters:(tns1_ValidateUserKeyRequest *)aParameters  delegate:(id<LibreAccessBindingResponseDelegate>)responseDelegate;
- (LibreAccessBindingResponse *)DeleteBookShelfEntryUsingParameters:(tns1_DeleteBookShelfEntryRequest *)aParameters ;
- (void)DeleteBookShelfEntryAsyncUsingParameters:(tns1_DeleteBookShelfEntryRequest *)aParameters  delegate:(id<LibreAccessBindingResponseDelegate>)responseDelegate;
- (LibreAccessBindingResponse *)GetLastPageLocationUsingParameters:(tns1_GetLastPageLocationRequest *)aParameters ;
- (void)GetLastPageLocationAsyncUsingParameters:(tns1_GetLastPageLocationRequest *)aParameters  delegate:(id<LibreAccessBindingResponseDelegate>)responseDelegate;
- (LibreAccessBindingResponse *)SaveLastPageLocationUsingParameters:(tns1_SaveLastPageLocationRequest *)aParameters ;
- (void)SaveLastPageLocationAsyncUsingParameters:(tns1_SaveLastPageLocationRequest *)aParameters  delegate:(id<LibreAccessBindingResponseDelegate>)responseDelegate;
- (LibreAccessBindingResponse *)ListFavoriteTypesUsingParameters:(tns1_ListFavoriteTypesRequest *)aParameters ;
- (void)ListFavoriteTypesAsyncUsingParameters:(tns1_ListFavoriteTypesRequest *)aParameters  delegate:(id<LibreAccessBindingResponseDelegate>)responseDelegate;
- (LibreAccessBindingResponse *)SaveUserSettingsUsingParameters:(tns1_SaveUserSettingsRequest *)aParameters ;
- (void)SaveUserSettingsAsyncUsingParameters:(tns1_SaveUserSettingsRequest *)aParameters  delegate:(id<LibreAccessBindingResponseDelegate>)responseDelegate;
- (LibreAccessBindingResponse *)ListUserSettingsUsingParameters:(tns1_ListUserSettingsRequest *)aParameters ;
- (void)ListUserSettingsAsyncUsingParameters:(tns1_ListUserSettingsRequest *)aParameters  delegate:(id<LibreAccessBindingResponseDelegate>)responseDelegate;
- (LibreAccessBindingResponse *)ListApplicationSettingsUsingParameters:(tns1_ListApplicationSettingsRequest *)aParameters ;
- (void)ListApplicationSettingsAsyncUsingParameters:(tns1_ListApplicationSettingsRequest *)aParameters  delegate:(id<LibreAccessBindingResponseDelegate>)responseDelegate;
- (LibreAccessBindingResponse *)SetAccountAutoAssignUsingParameters:(tns1_SetAccountAutoAssignRequest *)aParameters ;
- (void)SetAccountAutoAssignAsyncUsingParameters:(tns1_SetAccountAutoAssignRequest *)aParameters  delegate:(id<LibreAccessBindingResponseDelegate>)responseDelegate;
- (LibreAccessBindingResponse *)SetAccountPasswordRequiredUsingParameters:(tns1_SetAccountPasswordRequiredRequest *)aParameters ;
- (void)SetAccountPasswordRequiredAsyncUsingParameters:(tns1_SetAccountPasswordRequiredRequest *)aParameters  delegate:(id<LibreAccessBindingResponseDelegate>)responseDelegate;
- (LibreAccessBindingResponse *)ListReadBooksUsingParameters:(tns1_ListReadBooksRequest *)aParameters ;
- (void)ListReadBooksAsyncUsingParameters:(tns1_ListReadBooksRequest *)aParameters  delegate:(id<LibreAccessBindingResponseDelegate>)responseDelegate;
- (LibreAccessBindingResponse *)ListLastNProfileReadBooksUsingParameters:(tns1_ListLastNProfileReadBooksRequest *)aParameters ;
- (void)ListLastNProfileReadBooksAsyncUsingParameters:(tns1_ListLastNProfileReadBooksRequest *)aParameters  delegate:(id<LibreAccessBindingResponseDelegate>)responseDelegate;
- (LibreAccessBindingResponse *)ListLastNWordsUsingParameters:(tns1_ListLastNWordsRequest *)aParameters ;
- (void)ListLastNWordsAsyncUsingParameters:(tns1_ListLastNWordsRequest *)aParameters  delegate:(id<LibreAccessBindingResponseDelegate>)responseDelegate;
- (LibreAccessBindingResponse *)RemoveOrderUsingParameters:(tns1_RemoveOrderRequest *)aParameters ;
- (void)RemoveOrderAsyncUsingParameters:(tns1_RemoveOrderRequest *)aParameters  delegate:(id<LibreAccessBindingResponseDelegate>)responseDelegate;
- (LibreAccessBindingResponse *)SaveUserCSRNotesUsingParameters:(tns1_SaveUserCSRNotesRequest *)aParameters ;
- (void)SaveUserCSRNotesAsyncUsingParameters:(tns1_SaveUserCSRNotesRequest *)aParameters  delegate:(id<LibreAccessBindingResponseDelegate>)responseDelegate;
- (LibreAccessBindingResponse *)ListUserCSRNotesUsingParameters:(tns1_ListUserCSRNotesRequest *)aParameters ;
- (void)ListUserCSRNotesAsyncUsingParameters:(tns1_ListUserCSRNotesRequest *)aParameters  delegate:(id<LibreAccessBindingResponseDelegate>)responseDelegate;
- (LibreAccessBindingResponse *)GetKeyIdUsingParameters:(tns1_GetKeyIdRequest *)aParameters ;
- (void)GetKeyIdAsyncUsingParameters:(tns1_GetKeyIdRequest *)aParameters  delegate:(id<LibreAccessBindingResponseDelegate>)responseDelegate;
- (LibreAccessBindingResponse *)SaveDefaultBooksUsingParameters:(tns1_SaveDefaultBooksRequest *)aParameters ;
- (void)SaveDefaultBooksAsyncUsingParameters:(tns1_SaveDefaultBooksRequest *)aParameters  delegate:(id<LibreAccessBindingResponseDelegate>)responseDelegate;
- (LibreAccessBindingResponse *)ListDefaultBooksUsingParameters:(tns1_ListDefaultBooksRequest *)aParameters ;
- (void)ListDefaultBooksAsyncUsingParameters:(tns1_ListDefaultBooksRequest *)aParameters  delegate:(id<LibreAccessBindingResponseDelegate>)responseDelegate;
- (LibreAccessBindingResponse *)RemoveDefaultBooksUsingParameters:(tns1_RemoveDefaultBooksRequest *)aParameters ;
- (void)RemoveDefaultBooksAsyncUsingParameters:(tns1_RemoveDefaultBooksRequest *)aParameters  delegate:(id<LibreAccessBindingResponseDelegate>)responseDelegate;
- (LibreAccessBindingResponse *)AssignBooksToAllUsersUsingParameters:(tns1_AssignBooksToAllUsersRequest *)aParameters ;
- (void)AssignBooksToAllUsersAsyncUsingParameters:(tns1_AssignBooksToAllUsersRequest *)aParameters  delegate:(id<LibreAccessBindingResponseDelegate>)responseDelegate;
- (LibreAccessBindingResponse *)SetLoggingLevelUsingParameters:(tns1_SetLoggingLevelRequest *)aParameters ;
- (void)SetLoggingLevelAsyncUsingParameters:(tns1_SetLoggingLevelRequest *)aParameters  delegate:(id<LibreAccessBindingResponseDelegate>)responseDelegate;
- (LibreAccessBindingResponse *)HealthCheckUsingParameters:(tns1_HealthCheckRequest *)aParameters ;
- (void)HealthCheckAsyncUsingParameters:(tns1_HealthCheckRequest *)aParameters  delegate:(id<LibreAccessBindingResponseDelegate>)responseDelegate;
- (LibreAccessBindingResponse *)GetVersionUsingParameters:(tns1_GetVersionRequest *)aParameters ;
- (void)GetVersionAsyncUsingParameters:(tns1_GetVersionRequest *)aParameters  delegate:(id<LibreAccessBindingResponseDelegate>)responseDelegate;
- (LibreAccessBindingResponse *)ListTopRatingsUsingParameters:(tns1_ListTopRatingsRequest *)aParameters ;
- (void)ListTopRatingsAsyncUsingParameters:(tns1_ListTopRatingsRequest *)aParameters  delegate:(id<LibreAccessBindingResponseDelegate>)responseDelegate;
- (LibreAccessBindingResponse *)SaveRatingsUsingParameters:(tns1_SaveRatingsRequest *)aParameters ;
- (void)SaveRatingsAsyncUsingParameters:(tns1_SaveRatingsRequest *)aParameters  delegate:(id<LibreAccessBindingResponseDelegate>)responseDelegate;
- (LibreAccessBindingResponse *)ListRatingsUsingParameters:(tns1_ListRatingsRequest *)aParameters ;
- (void)ListRatingsAsyncUsingParameters:(tns1_ListRatingsRequest *)aParameters  delegate:(id<LibreAccessBindingResponseDelegate>)responseDelegate;
- (LibreAccessBindingResponse *)DeregisterAllDevicesUsingParameters:(tns1_DeregisterAllDevicesRequest *)aParameters ;
- (void)DeregisterAllDevicesAsyncUsingParameters:(tns1_DeregisterAllDevicesRequest *)aParameters  delegate:(id<LibreAccessBindingResponseDelegate>)responseDelegate;
- (void)addPointerForOperation:(LibreAccessBindingOperation *)operation;
- (void)removePointerForOperation:(LibreAccessBindingOperation *)operation;
- (void)clearBindingOperations;
@end
@interface LibreAccessBindingOperation : NSOperation {
	LibreAccessBinding *binding;
	LibreAccessBindingResponse *response;
	id<LibreAccessBindingResponseDelegate> delegate;
	NSDictionary *responseHeaders;	
	NSMutableData *responseData;
	NSURLConnection *urlConnection;
}
@property (nonatomic, retain) LibreAccessBinding *binding;
@property (nonatomic, readonly) LibreAccessBindingResponse *response;
@property (nonatomic, assign) id<LibreAccessBindingResponseDelegate> delegate;
@property (nonatomic, retain) NSDictionary *responseHeaders;
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, assign) NSTimeInterval serverDateDelta;
@property (nonatomic, retain) NSURLConnection *urlConnection;
- (id)initWithBinding:(LibreAccessBinding *)aBinding delegate:(id<LibreAccessBindingResponseDelegate>)aDelegate;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)clear;
@end
@interface LibreAccessBinding_TokenExchange : LibreAccessBindingOperation {
	tns1_TokenExchange * body;
}
@property (nonatomic, retain) tns1_TokenExchange * body;
- (id)initWithBinding:(LibreAccessBinding *)aBinding delegate:(id<LibreAccessBindingResponseDelegate>)aDelegate
	body:(tns1_TokenExchange *)aBody
;
@end
@interface LibreAccessBinding_SharedTokenExchange : LibreAccessBindingOperation {
	tns1_SharedTokenExchangeRequest * body;
}
@property (nonatomic, retain) tns1_SharedTokenExchangeRequest * body;
- (id)initWithBinding:(LibreAccessBinding *)aBinding delegate:(id<LibreAccessBindingResponseDelegate>)aDelegate
	body:(tns1_SharedTokenExchangeRequest *)aBody
;
@end
@interface LibreAccessBinding_AuthenticateDevice : LibreAccessBindingOperation {
	tns1_AuthenticateDeviceRequest * body;
}
@property (nonatomic, retain) tns1_AuthenticateDeviceRequest * body;
- (id)initWithBinding:(LibreAccessBinding *)aBinding delegate:(id<LibreAccessBindingResponseDelegate>)aDelegate
	body:(tns1_AuthenticateDeviceRequest *)aBody
;
@end
@interface LibreAccessBinding_RenewToken : LibreAccessBindingOperation {
	tns1_RenewTokenRequest * body;
}
@property (nonatomic, retain) tns1_RenewTokenRequest * body;
- (id)initWithBinding:(LibreAccessBinding *)aBinding delegate:(id<LibreAccessBindingResponseDelegate>)aDelegate
	body:(tns1_RenewTokenRequest *)aBody
;
@end
@interface LibreAccessBinding_ListBooksAssignment : LibreAccessBindingOperation {
	tns1_ListBooksAssignmentRequest * body;
}
@property (nonatomic, retain) tns1_ListBooksAssignmentRequest * body;
- (id)initWithBinding:(LibreAccessBinding *)aBinding delegate:(id<LibreAccessBindingResponseDelegate>)aDelegate
	body:(tns1_ListBooksAssignmentRequest *)aBody
;
@end
@interface LibreAccessBinding_ListUserContent : LibreAccessBindingOperation {
	tns1_ListUserContent * body;
}
@property (nonatomic, retain) tns1_ListUserContent * body;
- (id)initWithBinding:(LibreAccessBinding *)aBinding delegate:(id<LibreAccessBindingResponseDelegate>)aDelegate
	body:(tns1_ListUserContent *)aBody
;
@end
@interface LibreAccessBinding_ListContentMetadata : LibreAccessBindingOperation {
	tns1_ListContentMetadata * body;
}
@property (nonatomic, retain) tns1_ListContentMetadata * body;
- (id)initWithBinding:(LibreAccessBinding *)aBinding delegate:(id<LibreAccessBindingResponseDelegate>)aDelegate
	body:(tns1_ListContentMetadata *)aBody
;
@end
@interface LibreAccessBinding_IsEntitledToLicense : LibreAccessBindingOperation {
	tns1_EntitledToLicenseRequest * parameters;
}
@property (nonatomic, retain) tns1_EntitledToLicenseRequest * parameters;
- (id)initWithBinding:(LibreAccessBinding *)aBinding delegate:(id<LibreAccessBindingResponseDelegate>)aDelegate
	parameters:(tns1_EntitledToLicenseRequest *)aParameters
;
@end
@interface LibreAccessBinding_SaveReadingStatisticsDetailed : LibreAccessBindingOperation {
	tns1_SaveReadingStatisticsDetailedRequest * parameters;
}
@property (nonatomic, retain) tns1_SaveReadingStatisticsDetailedRequest * parameters;
- (id)initWithBinding:(LibreAccessBinding *)aBinding delegate:(id<LibreAccessBindingResponseDelegate>)aDelegate
	parameters:(tns1_SaveReadingStatisticsDetailedRequest *)aParameters
;
@end
@interface LibreAccessBinding_ListReadingStatisticsAggregate : LibreAccessBindingOperation {
	tns1_ListReadingStatisticsAggregateRequest * parameters;
}
@property (nonatomic, retain) tns1_ListReadingStatisticsAggregateRequest * parameters;
- (id)initWithBinding:(LibreAccessBinding *)aBinding delegate:(id<LibreAccessBindingResponseDelegate>)aDelegate
	parameters:(tns1_ListReadingStatisticsAggregateRequest *)aParameters
;
@end
@interface LibreAccessBinding_ListReadingStatisticsDetailed : LibreAccessBindingOperation {
	tns1_ListReadingStatisticsDetailedRequest * parameters;
}
@property (nonatomic, retain) tns1_ListReadingStatisticsDetailedRequest * parameters;
- (id)initWithBinding:(LibreAccessBinding *)aBinding delegate:(id<LibreAccessBindingResponseDelegate>)aDelegate
	parameters:(tns1_ListReadingStatisticsDetailedRequest *)aParameters
;
@end
@interface LibreAccessBinding_ListReadingStatisticsMonthlyAverage : LibreAccessBindingOperation {
	tns1_ListReadingStatisticsMonthlyAverageRequest * parameters;
}
@property (nonatomic, retain) tns1_ListReadingStatisticsMonthlyAverageRequest * parameters;
- (id)initWithBinding:(LibreAccessBinding *)aBinding delegate:(id<LibreAccessBindingResponseDelegate>)aDelegate
	parameters:(tns1_ListReadingStatisticsMonthlyAverageRequest *)aParameters
;
@end
@interface LibreAccessBinding_ListReadingStatisticsAggregateByTitle : LibreAccessBindingOperation {
	tns1_ListReadingStatisticsAggregateByTitleRequest * parameters;
}
@property (nonatomic, retain) tns1_ListReadingStatisticsAggregateByTitleRequest * parameters;
- (id)initWithBinding:(LibreAccessBinding *)aBinding delegate:(id<LibreAccessBindingResponseDelegate>)aDelegate
	parameters:(tns1_ListReadingStatisticsAggregateByTitleRequest *)aParameters
;
@end
@interface LibreAccessBinding_ListReadingStatisticsDailyAggregateByTitle : LibreAccessBindingOperation {
	tns1_ListReadingStatisticsDailyAggregateByTitleRequest * parameters;
}
@property (nonatomic, retain) tns1_ListReadingStatisticsDailyAggregateByTitleRequest * parameters;
- (id)initWithBinding:(LibreAccessBinding *)aBinding delegate:(id<LibreAccessBindingResponseDelegate>)aDelegate
	parameters:(tns1_ListReadingStatisticsDailyAggregateByTitleRequest *)aParameters
;
@end
@interface LibreAccessBinding_SaveProfileContentAnnotations : LibreAccessBindingOperation {
	tns1_SaveProfileContentAnnotationsRequest * parameters;
}
@property (nonatomic, retain) tns1_SaveProfileContentAnnotationsRequest * parameters;
- (id)initWithBinding:(LibreAccessBinding *)aBinding delegate:(id<LibreAccessBindingResponseDelegate>)aDelegate
	parameters:(tns1_SaveProfileContentAnnotationsRequest *)aParameters
;
@end
@interface LibreAccessBinding_ListProfileContentAnnotations : LibreAccessBindingOperation {
	tns1_ListProfileContentAnnotationsRequest * parameters;
}
@property (nonatomic, retain) tns1_ListProfileContentAnnotationsRequest * parameters;
- (id)initWithBinding:(LibreAccessBinding *)aBinding delegate:(id<LibreAccessBindingResponseDelegate>)aDelegate
	parameters:(tns1_ListProfileContentAnnotationsRequest *)aParameters
;
@end
@interface LibreAccessBinding_GetUserProfiles : LibreAccessBindingOperation {
	tns1_GetUserProfilesRequest * parameters;
}
@property (nonatomic, retain) tns1_GetUserProfilesRequest * parameters;
- (id)initWithBinding:(LibreAccessBinding *)aBinding delegate:(id<LibreAccessBindingResponseDelegate>)aDelegate
	parameters:(tns1_GetUserProfilesRequest *)aParameters
;
@end
@interface LibreAccessBinding_SaveUserProfiles : LibreAccessBindingOperation {
	tns1_SaveUserProfilesRequest * parameters;
}
@property (nonatomic, retain) tns1_SaveUserProfilesRequest * parameters;
- (id)initWithBinding:(LibreAccessBinding *)aBinding delegate:(id<LibreAccessBindingResponseDelegate>)aDelegate
	parameters:(tns1_SaveUserProfilesRequest *)aParameters
;
@end
@interface LibreAccessBinding_SaveContentProfileAssignment : LibreAccessBindingOperation {
	tns1_SaveContentProfileAssignmentRequest * parameters;
}
@property (nonatomic, retain) tns1_SaveContentProfileAssignmentRequest * parameters;
- (id)initWithBinding:(LibreAccessBinding *)aBinding delegate:(id<LibreAccessBindingResponseDelegate>)aDelegate
	parameters:(tns1_SaveContentProfileAssignmentRequest *)aParameters
;
@end
@interface LibreAccessBinding_GetDeviceInfo : LibreAccessBindingOperation {
	tns1_GetDeviceInfoRequest * parameters;
}
@property (nonatomic, retain) tns1_GetDeviceInfoRequest * parameters;
- (id)initWithBinding:(LibreAccessBinding *)aBinding delegate:(id<LibreAccessBindingResponseDelegate>)aDelegate
	parameters:(tns1_GetDeviceInfoRequest *)aParameters
;
@end
@interface LibreAccessBinding_SaveDeviceInfo : LibreAccessBindingOperation {
	tns1_SaveDeviceInfoRequest * parameters;
}
@property (nonatomic, retain) tns1_SaveDeviceInfoRequest * parameters;
- (id)initWithBinding:(LibreAccessBinding *)aBinding delegate:(id<LibreAccessBindingResponseDelegate>)aDelegate
	parameters:(tns1_SaveDeviceInfoRequest *)aParameters
;
@end
@interface LibreAccessBinding_SaveNewDomain : LibreAccessBindingOperation {
	tns1_SaveNewDomainRequest * parameters;
}
@property (nonatomic, retain) tns1_SaveNewDomainRequest * parameters;
- (id)initWithBinding:(LibreAccessBinding *)aBinding delegate:(id<LibreAccessBindingResponseDelegate>)aDelegate
	parameters:(tns1_SaveNewDomainRequest *)aParameters
;
@end
@interface LibreAccessBinding_DeviceLeftDomain : LibreAccessBindingOperation {
	tns1_DeviceLeftDomainRequest * parameters;
}
@property (nonatomic, retain) tns1_DeviceLeftDomainRequest * parameters;
- (id)initWithBinding:(LibreAccessBinding *)aBinding delegate:(id<LibreAccessBindingResponseDelegate>)aDelegate
	parameters:(tns1_DeviceLeftDomainRequest *)aParameters
;
@end
@interface LibreAccessBinding_DeviceCanJoinDomain : LibreAccessBindingOperation {
	tns1_DeviceCanJoinDomainRequest * parameters;
}
@property (nonatomic, retain) tns1_DeviceCanJoinDomainRequest * parameters;
- (id)initWithBinding:(LibreAccessBinding *)aBinding delegate:(id<LibreAccessBindingResponseDelegate>)aDelegate
	parameters:(tns1_DeviceCanJoinDomainRequest *)aParameters
;
@end
@interface LibreAccessBinding_GetLicensableStatus : LibreAccessBindingOperation {
	tns1_GetLicensableStatusRequest * parameters;
}
@property (nonatomic, retain) tns1_GetLicensableStatusRequest * parameters;
- (id)initWithBinding:(LibreAccessBinding *)aBinding delegate:(id<LibreAccessBindingResponseDelegate>)aDelegate
	parameters:(tns1_GetLicensableStatusRequest *)aParameters
;
@end
@interface LibreAccessBinding_AcknowledgeLicense : LibreAccessBindingOperation {
	tns1_AcknowledgeLicenseRequest * parameters;
}
@property (nonatomic, retain) tns1_AcknowledgeLicenseRequest * parameters;
- (id)initWithBinding:(LibreAccessBinding *)aBinding delegate:(id<LibreAccessBindingResponseDelegate>)aDelegate
	parameters:(tns1_AcknowledgeLicenseRequest *)aParameters
;
@end
@interface LibreAccessBinding_ValidateScreenName : LibreAccessBindingOperation {
	tns1_ValidateScreenNameRequest * parameters;
}
@property (nonatomic, retain) tns1_ValidateScreenNameRequest * parameters;
- (id)initWithBinding:(LibreAccessBinding *)aBinding delegate:(id<LibreAccessBindingResponseDelegate>)aDelegate
	parameters:(tns1_ValidateScreenNameRequest *)aParameters
;
@end
@interface LibreAccessBinding_ValidateUserKey : LibreAccessBindingOperation {
	tns1_ValidateUserKeyRequest * parameters;
}
@property (nonatomic, retain) tns1_ValidateUserKeyRequest * parameters;
- (id)initWithBinding:(LibreAccessBinding *)aBinding delegate:(id<LibreAccessBindingResponseDelegate>)aDelegate
	parameters:(tns1_ValidateUserKeyRequest *)aParameters
;
@end
@interface LibreAccessBinding_DeleteBookShelfEntry : LibreAccessBindingOperation {
	tns1_DeleteBookShelfEntryRequest * parameters;
}
@property (nonatomic, retain) tns1_DeleteBookShelfEntryRequest * parameters;
- (id)initWithBinding:(LibreAccessBinding *)aBinding delegate:(id<LibreAccessBindingResponseDelegate>)aDelegate
	parameters:(tns1_DeleteBookShelfEntryRequest *)aParameters
;
@end
@interface LibreAccessBinding_GetLastPageLocation : LibreAccessBindingOperation {
	tns1_GetLastPageLocationRequest * parameters;
}
@property (nonatomic, retain) tns1_GetLastPageLocationRequest * parameters;
- (id)initWithBinding:(LibreAccessBinding *)aBinding delegate:(id<LibreAccessBindingResponseDelegate>)aDelegate
	parameters:(tns1_GetLastPageLocationRequest *)aParameters
;
@end
@interface LibreAccessBinding_SaveLastPageLocation : LibreAccessBindingOperation {
	tns1_SaveLastPageLocationRequest * parameters;
}
@property (nonatomic, retain) tns1_SaveLastPageLocationRequest * parameters;
- (id)initWithBinding:(LibreAccessBinding *)aBinding delegate:(id<LibreAccessBindingResponseDelegate>)aDelegate
	parameters:(tns1_SaveLastPageLocationRequest *)aParameters
;
@end
@interface LibreAccessBinding_ListFavoriteTypes : LibreAccessBindingOperation {
	tns1_ListFavoriteTypesRequest * parameters;
}
@property (nonatomic, retain) tns1_ListFavoriteTypesRequest * parameters;
- (id)initWithBinding:(LibreAccessBinding *)aBinding delegate:(id<LibreAccessBindingResponseDelegate>)aDelegate
	parameters:(tns1_ListFavoriteTypesRequest *)aParameters
;
@end
@interface LibreAccessBinding_SaveUserSettings : LibreAccessBindingOperation {
	tns1_SaveUserSettingsRequest * parameters;
}
@property (nonatomic, retain) tns1_SaveUserSettingsRequest * parameters;
- (id)initWithBinding:(LibreAccessBinding *)aBinding delegate:(id<LibreAccessBindingResponseDelegate>)aDelegate
	parameters:(tns1_SaveUserSettingsRequest *)aParameters
;
@end
@interface LibreAccessBinding_ListUserSettings : LibreAccessBindingOperation {
	tns1_ListUserSettingsRequest * parameters;
}
@property (nonatomic, retain) tns1_ListUserSettingsRequest * parameters;
- (id)initWithBinding:(LibreAccessBinding *)aBinding delegate:(id<LibreAccessBindingResponseDelegate>)aDelegate
	parameters:(tns1_ListUserSettingsRequest *)aParameters
;
@end
@interface LibreAccessBinding_ListApplicationSettings : LibreAccessBindingOperation {
	tns1_ListApplicationSettingsRequest * parameters;
}
@property (nonatomic, retain) tns1_ListApplicationSettingsRequest * parameters;
- (id)initWithBinding:(LibreAccessBinding *)aBinding delegate:(id<LibreAccessBindingResponseDelegate>)aDelegate
	parameters:(tns1_ListApplicationSettingsRequest *)aParameters
;
@end
@interface LibreAccessBinding_SetAccountAutoAssign : LibreAccessBindingOperation {
	tns1_SetAccountAutoAssignRequest * parameters;
}
@property (nonatomic, retain) tns1_SetAccountAutoAssignRequest * parameters;
- (id)initWithBinding:(LibreAccessBinding *)aBinding delegate:(id<LibreAccessBindingResponseDelegate>)aDelegate
	parameters:(tns1_SetAccountAutoAssignRequest *)aParameters
;
@end
@interface LibreAccessBinding_SetAccountPasswordRequired : LibreAccessBindingOperation {
	tns1_SetAccountPasswordRequiredRequest * parameters;
}
@property (nonatomic, retain) tns1_SetAccountPasswordRequiredRequest * parameters;
- (id)initWithBinding:(LibreAccessBinding *)aBinding delegate:(id<LibreAccessBindingResponseDelegate>)aDelegate
	parameters:(tns1_SetAccountPasswordRequiredRequest *)aParameters
;
@end
@interface LibreAccessBinding_ListReadBooks : LibreAccessBindingOperation {
	tns1_ListReadBooksRequest * parameters;
}
@property (nonatomic, retain) tns1_ListReadBooksRequest * parameters;
- (id)initWithBinding:(LibreAccessBinding *)aBinding delegate:(id<LibreAccessBindingResponseDelegate>)aDelegate
	parameters:(tns1_ListReadBooksRequest *)aParameters
;
@end
@interface LibreAccessBinding_ListLastNProfileReadBooks : LibreAccessBindingOperation {
	tns1_ListLastNProfileReadBooksRequest * parameters;
}
@property (nonatomic, retain) tns1_ListLastNProfileReadBooksRequest * parameters;
- (id)initWithBinding:(LibreAccessBinding *)aBinding delegate:(id<LibreAccessBindingResponseDelegate>)aDelegate
	parameters:(tns1_ListLastNProfileReadBooksRequest *)aParameters
;
@end
@interface LibreAccessBinding_ListLastNWords : LibreAccessBindingOperation {
	tns1_ListLastNWordsRequest * parameters;
}
@property (nonatomic, retain) tns1_ListLastNWordsRequest * parameters;
- (id)initWithBinding:(LibreAccessBinding *)aBinding delegate:(id<LibreAccessBindingResponseDelegate>)aDelegate
	parameters:(tns1_ListLastNWordsRequest *)aParameters
;
@end
@interface LibreAccessBinding_RemoveOrder : LibreAccessBindingOperation {
	tns1_RemoveOrderRequest * parameters;
}
@property (nonatomic, retain) tns1_RemoveOrderRequest * parameters;
- (id)initWithBinding:(LibreAccessBinding *)aBinding delegate:(id<LibreAccessBindingResponseDelegate>)aDelegate
	parameters:(tns1_RemoveOrderRequest *)aParameters
;
@end
@interface LibreAccessBinding_SaveUserCSRNotes : LibreAccessBindingOperation {
	tns1_SaveUserCSRNotesRequest * parameters;
}
@property (nonatomic, retain) tns1_SaveUserCSRNotesRequest * parameters;
- (id)initWithBinding:(LibreAccessBinding *)aBinding delegate:(id<LibreAccessBindingResponseDelegate>)aDelegate
	parameters:(tns1_SaveUserCSRNotesRequest *)aParameters
;
@end
@interface LibreAccessBinding_ListUserCSRNotes : LibreAccessBindingOperation {
	tns1_ListUserCSRNotesRequest * parameters;
}
@property (nonatomic, retain) tns1_ListUserCSRNotesRequest * parameters;
- (id)initWithBinding:(LibreAccessBinding *)aBinding delegate:(id<LibreAccessBindingResponseDelegate>)aDelegate
	parameters:(tns1_ListUserCSRNotesRequest *)aParameters
;
@end
@interface LibreAccessBinding_GetKeyId : LibreAccessBindingOperation {
	tns1_GetKeyIdRequest * parameters;
}
@property (nonatomic, retain) tns1_GetKeyIdRequest * parameters;
- (id)initWithBinding:(LibreAccessBinding *)aBinding delegate:(id<LibreAccessBindingResponseDelegate>)aDelegate
	parameters:(tns1_GetKeyIdRequest *)aParameters
;
@end
@interface LibreAccessBinding_SaveDefaultBooks : LibreAccessBindingOperation {
	tns1_SaveDefaultBooksRequest * parameters;
}
@property (nonatomic, retain) tns1_SaveDefaultBooksRequest * parameters;
- (id)initWithBinding:(LibreAccessBinding *)aBinding delegate:(id<LibreAccessBindingResponseDelegate>)aDelegate
	parameters:(tns1_SaveDefaultBooksRequest *)aParameters
;
@end
@interface LibreAccessBinding_ListDefaultBooks : LibreAccessBindingOperation {
	tns1_ListDefaultBooksRequest * parameters;
}
@property (nonatomic, retain) tns1_ListDefaultBooksRequest * parameters;
- (id)initWithBinding:(LibreAccessBinding *)aBinding delegate:(id<LibreAccessBindingResponseDelegate>)aDelegate
	parameters:(tns1_ListDefaultBooksRequest *)aParameters
;
@end
@interface LibreAccessBinding_RemoveDefaultBooks : LibreAccessBindingOperation {
	tns1_RemoveDefaultBooksRequest * parameters;
}
@property (nonatomic, retain) tns1_RemoveDefaultBooksRequest * parameters;
- (id)initWithBinding:(LibreAccessBinding *)aBinding delegate:(id<LibreAccessBindingResponseDelegate>)aDelegate
	parameters:(tns1_RemoveDefaultBooksRequest *)aParameters
;
@end
@interface LibreAccessBinding_AssignBooksToAllUsers : LibreAccessBindingOperation {
	tns1_AssignBooksToAllUsersRequest * parameters;
}
@property (nonatomic, retain) tns1_AssignBooksToAllUsersRequest * parameters;
- (id)initWithBinding:(LibreAccessBinding *)aBinding delegate:(id<LibreAccessBindingResponseDelegate>)aDelegate
	parameters:(tns1_AssignBooksToAllUsersRequest *)aParameters
;
@end
@interface LibreAccessBinding_SetLoggingLevel : LibreAccessBindingOperation {
	tns1_SetLoggingLevelRequest * parameters;
}
@property (nonatomic, retain) tns1_SetLoggingLevelRequest * parameters;
- (id)initWithBinding:(LibreAccessBinding *)aBinding delegate:(id<LibreAccessBindingResponseDelegate>)aDelegate
	parameters:(tns1_SetLoggingLevelRequest *)aParameters
;
@end
@interface LibreAccessBinding_HealthCheck : LibreAccessBindingOperation {
	tns1_HealthCheckRequest * parameters;
}
@property (nonatomic, retain) tns1_HealthCheckRequest * parameters;
- (id)initWithBinding:(LibreAccessBinding *)aBinding delegate:(id<LibreAccessBindingResponseDelegate>)aDelegate
	parameters:(tns1_HealthCheckRequest *)aParameters
;
@end
@interface LibreAccessBinding_GetVersion : LibreAccessBindingOperation {
	tns1_GetVersionRequest * parameters;
}
@property (nonatomic, retain) tns1_GetVersionRequest * parameters;
- (id)initWithBinding:(LibreAccessBinding *)aBinding delegate:(id<LibreAccessBindingResponseDelegate>)aDelegate
	parameters:(tns1_GetVersionRequest *)aParameters
;
@end
@interface LibreAccessBinding_ListTopRatings : LibreAccessBindingOperation {
	tns1_ListTopRatingsRequest * parameters;
}
@property (nonatomic, retain) tns1_ListTopRatingsRequest * parameters;
- (id)initWithBinding:(LibreAccessBinding *)aBinding delegate:(id<LibreAccessBindingResponseDelegate>)aDelegate
	parameters:(tns1_ListTopRatingsRequest *)aParameters
;
@end
@interface LibreAccessBinding_SaveRatings : LibreAccessBindingOperation {
	tns1_SaveRatingsRequest * parameters;
}
@property (nonatomic, retain) tns1_SaveRatingsRequest * parameters;
- (id)initWithBinding:(LibreAccessBinding *)aBinding delegate:(id<LibreAccessBindingResponseDelegate>)aDelegate
	parameters:(tns1_SaveRatingsRequest *)aParameters
;
@end
@interface LibreAccessBinding_ListRatings : LibreAccessBindingOperation {
	tns1_ListRatingsRequest * parameters;
}
@property (nonatomic, retain) tns1_ListRatingsRequest * parameters;
- (id)initWithBinding:(LibreAccessBinding *)aBinding delegate:(id<LibreAccessBindingResponseDelegate>)aDelegate
	parameters:(tns1_ListRatingsRequest *)aParameters
;
@end
@interface LibreAccessBinding_DeregisterAllDevices : LibreAccessBindingOperation {
	tns1_DeregisterAllDevicesRequest * parameters;
}
@property (nonatomic, retain) tns1_DeregisterAllDevicesRequest * parameters;
- (id)initWithBinding:(LibreAccessBinding *)aBinding delegate:(id<LibreAccessBindingResponseDelegate>)aDelegate
	parameters:(tns1_DeregisterAllDevicesRequest *)aParameters
;
@end
@interface LibreAccessBinding_envelope : NSObject {
}
+ (LibreAccessBinding_envelope *)sharedInstance;
- (NSString *)serializedFormUsingHeaderElements:(NSDictionary *)headerElements bodyElements:(NSDictionary *)bodyElements bodyKeys:(NSArray *)bodyKeys;
@end
@interface LibreAccessBindingResponse : NSObject {
	NSArray *headers;
	NSArray *bodyParts;
	NSError *error;
}
@property (nonatomic, retain) NSArray *headers;
@property (nonatomic, retain) NSArray *bodyParts;
@property (nonatomic, retain) NSError *error;
@end
