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
@class LibreAccessService_1_2_0Soap11Binding;
@interface LibreAccessServiceSvc : NSObject {
	
}
+ (LibreAccessService_1_2_0Soap11Binding *)LibreAccessService_1_2_0Soap11Binding;
@end
@class LibreAccessService_1_2_0Soap11BindingResponse;
@class LibreAccessService_1_2_0Soap11BindingOperation;
@protocol LibreAccessService_1_2_0Soap11BindingResponseDelegate <NSObject>
- (void) operation:(LibreAccessService_1_2_0Soap11BindingOperation *)operation completedWithResponse:(LibreAccessService_1_2_0Soap11BindingResponse *)response;
@end
@interface LibreAccessService_1_2_0Soap11Binding : NSObject <LibreAccessService_1_2_0Soap11BindingResponseDelegate> {
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
- (void)sendHTTPCallUsingBody:(NSString *)body soapAction:(NSString *)soapAction forOperation:(LibreAccessService_1_2_0Soap11BindingOperation *)operation;
- (void)addCookie:(NSHTTPCookie *)toAdd;
- (NSString *)MIMEType;
- (LibreAccessService_1_2_0Soap11BindingResponse *)GetLastPageLocationUsingParameters:(tns1_GetLastPageLocationRequest *)aParameters ;
- (void)GetLastPageLocationAsyncUsingParameters:(tns1_GetLastPageLocationRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessService_1_2_0Soap11BindingResponse *)ListUserContentUsingBody:(tns1_ListUserContent *)aBody ;
- (void)ListUserContentAsyncUsingBody:(tns1_ListUserContent *)aBody  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessService_1_2_0Soap11BindingResponse *)ListFavoriteTypesUsingParameters:(tns1_ListFavoriteTypesRequest *)aParameters ;
- (void)ListFavoriteTypesAsyncUsingParameters:(tns1_ListFavoriteTypesRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessService_1_2_0Soap11BindingResponse *)SaveDefaultBooksUsingParameters:(tns1_SaveDefaultBooksRequest *)aParameters ;
- (void)SaveDefaultBooksAsyncUsingParameters:(tns1_SaveDefaultBooksRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessService_1_2_0Soap11BindingResponse *)SaveDeviceInfoUsingParameters:(tns1_SaveDeviceInfoRequest *)aParameters ;
- (void)SaveDeviceInfoAsyncUsingParameters:(tns1_SaveDeviceInfoRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessService_1_2_0Soap11BindingResponse *)SetAccountPasswordRequiredUsingParameters:(tns1_SetAccountPasswordRequiredRequest *)aParameters ;
- (void)SetAccountPasswordRequiredAsyncUsingParameters:(tns1_SetAccountPasswordRequiredRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessService_1_2_0Soap11BindingResponse *)ListProfileContentAnnotationsUsingParameters:(tns1_ListProfileContentAnnotationsRequest *)aParameters ;
- (void)ListProfileContentAnnotationsAsyncUsingParameters:(tns1_ListProfileContentAnnotationsRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessService_1_2_0Soap11BindingResponse *)GetUserProfilesUsingParameters:(tns1_GetUserProfilesRequest *)aParameters ;
- (void)GetUserProfilesAsyncUsingParameters:(tns1_GetUserProfilesRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessService_1_2_0Soap11BindingResponse *)HealthCheckUsingParameters:(tns1_HealthCheckRequest *)aParameters ;
- (void)HealthCheckAsyncUsingParameters:(tns1_HealthCheckRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessService_1_2_0Soap11BindingResponse *)ListUserCSRNotesUsingParameters:(tns1_ListUserCSRNotesRequest *)aParameters ;
- (void)ListUserCSRNotesAsyncUsingParameters:(tns1_ListUserCSRNotesRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessService_1_2_0Soap11BindingResponse *)ValidateUserKeyUsingParameters:(tns1_ValidateUserKeyRequest *)aParameters ;
- (void)ValidateUserKeyAsyncUsingParameters:(tns1_ValidateUserKeyRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessService_1_2_0Soap11BindingResponse *)ListRatingsUsingParameters:(tns1_ListRatingsRequest *)aParameters ;
- (void)ListRatingsAsyncUsingParameters:(tns1_ListRatingsRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessService_1_2_0Soap11BindingResponse *)SaveLastPageLocationUsingParameters:(tns1_SaveLastPageLocationRequest *)aParameters ;
- (void)SaveLastPageLocationAsyncUsingParameters:(tns1_SaveLastPageLocationRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessService_1_2_0Soap11BindingResponse *)GetDeviceInfoUsingParameters:(tns1_GetDeviceInfoRequest *)aParameters ;
- (void)GetDeviceInfoAsyncUsingParameters:(tns1_GetDeviceInfoRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessService_1_2_0Soap11BindingResponse *)RenewTokenUsingBody:(tns1_RenewTokenRequest *)aBody ;
- (void)RenewTokenAsyncUsingBody:(tns1_RenewTokenRequest *)aBody  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessService_1_2_0Soap11BindingResponse *)ListLastNWordsUsingParameters:(tns1_ListLastNWordsRequest *)aParameters ;
- (void)ListLastNWordsAsyncUsingParameters:(tns1_ListLastNWordsRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessService_1_2_0Soap11BindingResponse *)ListReadingStatisticsDailyAggregateByTitleUsingParameters:(tns1_ListReadingStatisticsDailyAggregateByTitleRequest *)aParameters ;
- (void)ListReadingStatisticsDailyAggregateByTitleAsyncUsingParameters:(tns1_ListReadingStatisticsDailyAggregateByTitleRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessService_1_2_0Soap11BindingResponse *)ListReadingStatisticsMonthlyAverageUsingParameters:(tns1_ListReadingStatisticsMonthlyAverageRequest *)aParameters ;
- (void)ListReadingStatisticsMonthlyAverageAsyncUsingParameters:(tns1_ListReadingStatisticsMonthlyAverageRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessService_1_2_0Soap11BindingResponse *)ListBooksAssignmentUsingBody:(tns1_ListBooksAssignmentRequest *)aBody ;
- (void)ListBooksAssignmentAsyncUsingBody:(tns1_ListBooksAssignmentRequest *)aBody  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessService_1_2_0Soap11BindingResponse *)GetVersionUsingParameters:(tns1_GetVersionRequest *)aParameters ;
- (void)GetVersionAsyncUsingParameters:(tns1_GetVersionRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessService_1_2_0Soap11BindingResponse *)SaveContentProfileAssignmentUsingParameters:(tns1_SaveContentProfileAssignmentRequest *)aParameters ;
- (void)SaveContentProfileAssignmentAsyncUsingParameters:(tns1_SaveContentProfileAssignmentRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessService_1_2_0Soap11BindingResponse *)ListReadingStatisticsDetailedUsingParameters:(tns1_ListReadingStatisticsDetailedRequest *)aParameters ;
- (void)ListReadingStatisticsDetailedAsyncUsingParameters:(tns1_ListReadingStatisticsDetailedRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessService_1_2_0Soap11BindingResponse *)IsEntitledToLicenseUsingParameters:(tns1_EntitledToLicenseRequest *)aParameters ;
- (void)IsEntitledToLicenseAsyncUsingParameters:(tns1_EntitledToLicenseRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessService_1_2_0Soap11BindingResponse *)SaveRatingsUsingParameters:(tns1_SaveRatingsRequest *)aParameters ;
- (void)SaveRatingsAsyncUsingParameters:(tns1_SaveRatingsRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessService_1_2_0Soap11BindingResponse *)SaveNewDomainUsingParameters:(tns1_SaveNewDomainRequest *)aParameters ;
- (void)SaveNewDomainAsyncUsingParameters:(tns1_SaveNewDomainRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessService_1_2_0Soap11BindingResponse *)ListTopRatingsUsingParameters:(tns1_ListTopRatingsRequest *)aParameters ;
- (void)ListTopRatingsAsyncUsingParameters:(tns1_ListTopRatingsRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessService_1_2_0Soap11BindingResponse *)ListLastNProfileReadBooksUsingParameters:(tns1_ListLastNProfileReadBooksRequest *)aParameters ;
- (void)ListLastNProfileReadBooksAsyncUsingParameters:(tns1_ListLastNProfileReadBooksRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessService_1_2_0Soap11BindingResponse *)ListUserSettingsUsingParameters:(tns1_ListUserSettingsRequest *)aParameters ;
- (void)ListUserSettingsAsyncUsingParameters:(tns1_ListUserSettingsRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessService_1_2_0Soap11BindingResponse *)AcknowledgeLicenseUsingParameters:(tns1_AcknowledgeLicenseRequest *)aParameters ;
- (void)AcknowledgeLicenseAsyncUsingParameters:(tns1_AcknowledgeLicenseRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessService_1_2_0Soap11BindingResponse *)GetLicensableStatusUsingParameters:(tns1_GetLicensableStatusRequest *)aParameters ;
- (void)GetLicensableStatusAsyncUsingParameters:(tns1_GetLicensableStatusRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessService_1_2_0Soap11BindingResponse *)GetKeyIdUsingParameters:(tns1_GetKeyIdRequest *)aParameters ;
- (void)GetKeyIdAsyncUsingParameters:(tns1_GetKeyIdRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessService_1_2_0Soap11BindingResponse *)ListReadBooksUsingParameters:(tns1_ListReadBooksRequest *)aParameters ;
- (void)ListReadBooksAsyncUsingParameters:(tns1_ListReadBooksRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessService_1_2_0Soap11BindingResponse *)ListReadingStatisticsAggregateByTitleUsingParameters:(tns1_ListReadingStatisticsAggregateByTitleRequest *)aParameters ;
- (void)ListReadingStatisticsAggregateByTitleAsyncUsingParameters:(tns1_ListReadingStatisticsAggregateByTitleRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessService_1_2_0Soap11BindingResponse *)SaveProfileContentAnnotationsUsingParameters:(tns1_SaveProfileContentAnnotationsRequest *)aParameters ;
- (void)SaveProfileContentAnnotationsAsyncUsingParameters:(tns1_SaveProfileContentAnnotationsRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessService_1_2_0Soap11BindingResponse *)ListReadingStatisticsAggregateUsingParameters:(tns1_ListReadingStatisticsAggregateRequest *)aParameters ;
- (void)ListReadingStatisticsAggregateAsyncUsingParameters:(tns1_ListReadingStatisticsAggregateRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessService_1_2_0Soap11BindingResponse *)ListContentMetadataUsingBody:(tns1_ListContentMetadata *)aBody ;
- (void)ListContentMetadataAsyncUsingBody:(tns1_ListContentMetadata *)aBody  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessService_1_2_0Soap11BindingResponse *)ListProfileRecentAnnotationsUsingParameters:(tns1_ListProfileRecentAnnotationsRequest *)aParameters ;
- (void)ListProfileRecentAnnotationsAsyncUsingParameters:(tns1_ListProfileRecentAnnotationsRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessService_1_2_0Soap11BindingResponse *)SetAccountAutoAssignUsingParameters:(tns1_SetAccountAutoAssignRequest *)aParameters ;
- (void)SetAccountAutoAssignAsyncUsingParameters:(tns1_SetAccountAutoAssignRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessService_1_2_0Soap11BindingResponse *)ListDefaultBooksUsingParameters:(tns1_ListDefaultBooksRequest *)aParameters ;
- (void)ListDefaultBooksAsyncUsingParameters:(tns1_ListDefaultBooksRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessService_1_2_0Soap11BindingResponse *)RemoveDefaultBooksUsingParameters:(tns1_RemoveDefaultBooksRequest *)aParameters ;
- (void)RemoveDefaultBooksAsyncUsingParameters:(tns1_RemoveDefaultBooksRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessService_1_2_0Soap11BindingResponse *)SaveUserSettingsUsingParameters:(tns1_SaveUserSettingsRequest *)aParameters ;
- (void)SaveUserSettingsAsyncUsingParameters:(tns1_SaveUserSettingsRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessService_1_2_0Soap11BindingResponse *)SaveUserProfilesUsingParameters:(tns1_SaveUserProfilesRequest *)aParameters ;
- (void)SaveUserProfilesAsyncUsingParameters:(tns1_SaveUserProfilesRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessService_1_2_0Soap11BindingResponse *)DeviceLeftDomainUsingParameters:(tns1_DeviceLeftDomainRequest *)aParameters ;
- (void)DeviceLeftDomainAsyncUsingParameters:(tns1_DeviceLeftDomainRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessService_1_2_0Soap11BindingResponse *)ListApplicationSettingsUsingParameters:(tns1_ListApplicationSettingsRequest *)aParameters ;
- (void)ListApplicationSettingsAsyncUsingParameters:(tns1_ListApplicationSettingsRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessService_1_2_0Soap11BindingResponse *)TokenExchangeUsingBody:(tns1_TokenExchange *)aBody ;
- (void)TokenExchangeAsyncUsingBody:(tns1_TokenExchange *)aBody  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessService_1_2_0Soap11BindingResponse *)ValidateScreenNameUsingParameters:(tns1_ValidateScreenNameRequest *)aParameters ;
- (void)ValidateScreenNameAsyncUsingParameters:(tns1_ValidateScreenNameRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessService_1_2_0Soap11BindingResponse *)RemoveOrderUsingParameters:(tns1_RemoveOrderRequest *)aParameters ;
- (void)RemoveOrderAsyncUsingParameters:(tns1_RemoveOrderRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessService_1_2_0Soap11BindingResponse *)SaveReadingStatisticsDetailedUsingParameters:(tns1_SaveReadingStatisticsDetailedRequest *)aParameters ;
- (void)SaveReadingStatisticsDetailedAsyncUsingParameters:(tns1_SaveReadingStatisticsDetailedRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessService_1_2_0Soap11BindingResponse *)SharedTokenExchangeUsingBody:(tns1_SharedTokenExchangeRequest *)aBody ;
- (void)SharedTokenExchangeAsyncUsingBody:(tns1_SharedTokenExchangeRequest *)aBody  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessService_1_2_0Soap11BindingResponse *)DeleteBookShelfEntryUsingParameters:(tns1_DeleteBookShelfEntryRequest *)aParameters ;
- (void)DeleteBookShelfEntryAsyncUsingParameters:(tns1_DeleteBookShelfEntryRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessService_1_2_0Soap11BindingResponse *)DeviceCanJoinDomainUsingParameters:(tns1_DeviceCanJoinDomainRequest *)aParameters ;
- (void)DeviceCanJoinDomainAsyncUsingParameters:(tns1_DeviceCanJoinDomainRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessService_1_2_0Soap11BindingResponse *)AuthenticateDeviceUsingBody:(tns1_AuthenticateDeviceRequest *)aBody ;
- (void)AuthenticateDeviceAsyncUsingBody:(tns1_AuthenticateDeviceRequest *)aBody  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessService_1_2_0Soap11BindingResponse *)DeregisterAllDevicesUsingParameters:(tns1_DeregisterAllDevicesRequest *)aParameters ;
- (void)DeregisterAllDevicesAsyncUsingParameters:(tns1_DeregisterAllDevicesRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessService_1_2_0Soap11BindingResponse *)SaveUserCSRNotesUsingParameters:(tns1_SaveUserCSRNotesRequest *)aParameters ;
- (void)SaveUserCSRNotesAsyncUsingParameters:(tns1_SaveUserCSRNotesRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessService_1_2_0Soap11BindingResponse *)AssignBooksToAllUsersUsingParameters:(tns1_AssignBooksToAllUsersRequest *)aParameters ;
- (void)AssignBooksToAllUsersAsyncUsingParameters:(tns1_AssignBooksToAllUsersRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate;
- (void)addPointerForOperation:(LibreAccessService_1_2_0Soap11BindingOperation *)operation;
- (void)removePointerForOperation:(LibreAccessService_1_2_0Soap11BindingOperation *)operation;
- (void)clearBindingOperations;
@end
@interface LibreAccessService_1_2_0Soap11BindingOperation : NSOperation {
	LibreAccessService_1_2_0Soap11Binding *binding;
	LibreAccessService_1_2_0Soap11BindingResponse *response;
	id<LibreAccessService_1_2_0Soap11BindingResponseDelegate> delegate;
	NSDictionary *responseHeaders;	
	NSMutableData *responseData;
	NSURLConnection *urlConnection;
}
@property (nonatomic, retain) LibreAccessService_1_2_0Soap11Binding *binding;
@property (nonatomic, readonly) LibreAccessService_1_2_0Soap11BindingResponse *response;
@property (nonatomic, assign) id<LibreAccessService_1_2_0Soap11BindingResponseDelegate> delegate;
@property (nonatomic, retain) NSDictionary *responseHeaders;
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, assign) NSTimeInterval serverDateDelta;
@property (nonatomic, retain) NSURLConnection *urlConnection;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)aDelegate;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)clear;
@end
@interface LibreAccessService_1_2_0Soap11Binding_GetLastPageLocation : LibreAccessService_1_2_0Soap11BindingOperation {
	tns1_GetLastPageLocationRequest * parameters;
}
@property (nonatomic, retain) tns1_GetLastPageLocationRequest * parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)aDelegate
	parameters:(tns1_GetLastPageLocationRequest *)aParameters
;
@end
@interface LibreAccessService_1_2_0Soap11Binding_ListUserContent : LibreAccessService_1_2_0Soap11BindingOperation {
	tns1_ListUserContent * body;
}
@property (nonatomic, retain) tns1_ListUserContent * body;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)aDelegate
	body:(tns1_ListUserContent *)aBody
;
@end
@interface LibreAccessService_1_2_0Soap11Binding_ListFavoriteTypes : LibreAccessService_1_2_0Soap11BindingOperation {
	tns1_ListFavoriteTypesRequest * parameters;
}
@property (nonatomic, retain) tns1_ListFavoriteTypesRequest * parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)aDelegate
	parameters:(tns1_ListFavoriteTypesRequest *)aParameters
;
@end
@interface LibreAccessService_1_2_0Soap11Binding_SaveDefaultBooks : LibreAccessService_1_2_0Soap11BindingOperation {
	tns1_SaveDefaultBooksRequest * parameters;
}
@property (nonatomic, retain) tns1_SaveDefaultBooksRequest * parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)aDelegate
	parameters:(tns1_SaveDefaultBooksRequest *)aParameters
;
@end
@interface LibreAccessService_1_2_0Soap11Binding_SaveDeviceInfo : LibreAccessService_1_2_0Soap11BindingOperation {
	tns1_SaveDeviceInfoRequest * parameters;
}
@property (nonatomic, retain) tns1_SaveDeviceInfoRequest * parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)aDelegate
	parameters:(tns1_SaveDeviceInfoRequest *)aParameters
;
@end
@interface LibreAccessService_1_2_0Soap11Binding_SetAccountPasswordRequired : LibreAccessService_1_2_0Soap11BindingOperation {
	tns1_SetAccountPasswordRequiredRequest * parameters;
}
@property (nonatomic, retain) tns1_SetAccountPasswordRequiredRequest * parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)aDelegate
	parameters:(tns1_SetAccountPasswordRequiredRequest *)aParameters
;
@end
@interface LibreAccessService_1_2_0Soap11Binding_ListProfileContentAnnotations : LibreAccessService_1_2_0Soap11BindingOperation {
	tns1_ListProfileContentAnnotationsRequest * parameters;
}
@property (nonatomic, retain) tns1_ListProfileContentAnnotationsRequest * parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)aDelegate
	parameters:(tns1_ListProfileContentAnnotationsRequest *)aParameters
;
@end
@interface LibreAccessService_1_2_0Soap11Binding_GetUserProfiles : LibreAccessService_1_2_0Soap11BindingOperation {
	tns1_GetUserProfilesRequest * parameters;
}
@property (nonatomic, retain) tns1_GetUserProfilesRequest * parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)aDelegate
	parameters:(tns1_GetUserProfilesRequest *)aParameters
;
@end
@interface LibreAccessService_1_2_0Soap11Binding_HealthCheck : LibreAccessService_1_2_0Soap11BindingOperation {
	tns1_HealthCheckRequest * parameters;
}
@property (nonatomic, retain) tns1_HealthCheckRequest * parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)aDelegate
	parameters:(tns1_HealthCheckRequest *)aParameters
;
@end
@interface LibreAccessService_1_2_0Soap11Binding_ListUserCSRNotes : LibreAccessService_1_2_0Soap11BindingOperation {
	tns1_ListUserCSRNotesRequest * parameters;
}
@property (nonatomic, retain) tns1_ListUserCSRNotesRequest * parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)aDelegate
	parameters:(tns1_ListUserCSRNotesRequest *)aParameters
;
@end
@interface LibreAccessService_1_2_0Soap11Binding_ValidateUserKey : LibreAccessService_1_2_0Soap11BindingOperation {
	tns1_ValidateUserKeyRequest * parameters;
}
@property (nonatomic, retain) tns1_ValidateUserKeyRequest * parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)aDelegate
	parameters:(tns1_ValidateUserKeyRequest *)aParameters
;
@end
@interface LibreAccessService_1_2_0Soap11Binding_ListRatings : LibreAccessService_1_2_0Soap11BindingOperation {
	tns1_ListRatingsRequest * parameters;
}
@property (nonatomic, retain) tns1_ListRatingsRequest * parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)aDelegate
	parameters:(tns1_ListRatingsRequest *)aParameters
;
@end
@interface LibreAccessService_1_2_0Soap11Binding_SaveLastPageLocation : LibreAccessService_1_2_0Soap11BindingOperation {
	tns1_SaveLastPageLocationRequest * parameters;
}
@property (nonatomic, retain) tns1_SaveLastPageLocationRequest * parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)aDelegate
	parameters:(tns1_SaveLastPageLocationRequest *)aParameters
;
@end
@interface LibreAccessService_1_2_0Soap11Binding_GetDeviceInfo : LibreAccessService_1_2_0Soap11BindingOperation {
	tns1_GetDeviceInfoRequest * parameters;
}
@property (nonatomic, retain) tns1_GetDeviceInfoRequest * parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)aDelegate
	parameters:(tns1_GetDeviceInfoRequest *)aParameters
;
@end
@interface LibreAccessService_1_2_0Soap11Binding_RenewToken : LibreAccessService_1_2_0Soap11BindingOperation {
	tns1_RenewTokenRequest * body;
}
@property (nonatomic, retain) tns1_RenewTokenRequest * body;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)aDelegate
	body:(tns1_RenewTokenRequest *)aBody
;
@end
@interface LibreAccessService_1_2_0Soap11Binding_ListLastNWords : LibreAccessService_1_2_0Soap11BindingOperation {
	tns1_ListLastNWordsRequest * parameters;
}
@property (nonatomic, retain) tns1_ListLastNWordsRequest * parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)aDelegate
	parameters:(tns1_ListLastNWordsRequest *)aParameters
;
@end
@interface LibreAccessService_1_2_0Soap11Binding_ListReadingStatisticsDailyAggregateByTitle : LibreAccessService_1_2_0Soap11BindingOperation {
	tns1_ListReadingStatisticsDailyAggregateByTitleRequest * parameters;
}
@property (nonatomic, retain) tns1_ListReadingStatisticsDailyAggregateByTitleRequest * parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)aDelegate
	parameters:(tns1_ListReadingStatisticsDailyAggregateByTitleRequest *)aParameters
;
@end
@interface LibreAccessService_1_2_0Soap11Binding_ListReadingStatisticsMonthlyAverage : LibreAccessService_1_2_0Soap11BindingOperation {
	tns1_ListReadingStatisticsMonthlyAverageRequest * parameters;
}
@property (nonatomic, retain) tns1_ListReadingStatisticsMonthlyAverageRequest * parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)aDelegate
	parameters:(tns1_ListReadingStatisticsMonthlyAverageRequest *)aParameters
;
@end
@interface LibreAccessService_1_2_0Soap11Binding_ListBooksAssignment : LibreAccessService_1_2_0Soap11BindingOperation {
	tns1_ListBooksAssignmentRequest * body;
}
@property (nonatomic, retain) tns1_ListBooksAssignmentRequest * body;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)aDelegate
	body:(tns1_ListBooksAssignmentRequest *)aBody
;
@end
@interface LibreAccessService_1_2_0Soap11Binding_GetVersion : LibreAccessService_1_2_0Soap11BindingOperation {
	tns1_GetVersionRequest * parameters;
}
@property (nonatomic, retain) tns1_GetVersionRequest * parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)aDelegate
	parameters:(tns1_GetVersionRequest *)aParameters
;
@end
@interface LibreAccessService_1_2_0Soap11Binding_SaveContentProfileAssignment : LibreAccessService_1_2_0Soap11BindingOperation {
	tns1_SaveContentProfileAssignmentRequest * parameters;
}
@property (nonatomic, retain) tns1_SaveContentProfileAssignmentRequest * parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)aDelegate
	parameters:(tns1_SaveContentProfileAssignmentRequest *)aParameters
;
@end
@interface LibreAccessService_1_2_0Soap11Binding_ListReadingStatisticsDetailed : LibreAccessService_1_2_0Soap11BindingOperation {
	tns1_ListReadingStatisticsDetailedRequest * parameters;
}
@property (nonatomic, retain) tns1_ListReadingStatisticsDetailedRequest * parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)aDelegate
	parameters:(tns1_ListReadingStatisticsDetailedRequest *)aParameters
;
@end
@interface LibreAccessService_1_2_0Soap11Binding_IsEntitledToLicense : LibreAccessService_1_2_0Soap11BindingOperation {
	tns1_EntitledToLicenseRequest * parameters;
}
@property (nonatomic, retain) tns1_EntitledToLicenseRequest * parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)aDelegate
	parameters:(tns1_EntitledToLicenseRequest *)aParameters
;
@end
@interface LibreAccessService_1_2_0Soap11Binding_SaveRatings : LibreAccessService_1_2_0Soap11BindingOperation {
	tns1_SaveRatingsRequest * parameters;
}
@property (nonatomic, retain) tns1_SaveRatingsRequest * parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)aDelegate
	parameters:(tns1_SaveRatingsRequest *)aParameters
;
@end
@interface LibreAccessService_1_2_0Soap11Binding_SaveNewDomain : LibreAccessService_1_2_0Soap11BindingOperation {
	tns1_SaveNewDomainRequest * parameters;
}
@property (nonatomic, retain) tns1_SaveNewDomainRequest * parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)aDelegate
	parameters:(tns1_SaveNewDomainRequest *)aParameters
;
@end
@interface LibreAccessService_1_2_0Soap11Binding_ListTopRatings : LibreAccessService_1_2_0Soap11BindingOperation {
	tns1_ListTopRatingsRequest * parameters;
}
@property (nonatomic, retain) tns1_ListTopRatingsRequest * parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)aDelegate
	parameters:(tns1_ListTopRatingsRequest *)aParameters
;
@end
@interface LibreAccessService_1_2_0Soap11Binding_ListLastNProfileReadBooks : LibreAccessService_1_2_0Soap11BindingOperation {
	tns1_ListLastNProfileReadBooksRequest * parameters;
}
@property (nonatomic, retain) tns1_ListLastNProfileReadBooksRequest * parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)aDelegate
	parameters:(tns1_ListLastNProfileReadBooksRequest *)aParameters
;
@end
@interface LibreAccessService_1_2_0Soap11Binding_ListUserSettings : LibreAccessService_1_2_0Soap11BindingOperation {
	tns1_ListUserSettingsRequest * parameters;
}
@property (nonatomic, retain) tns1_ListUserSettingsRequest * parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)aDelegate
	parameters:(tns1_ListUserSettingsRequest *)aParameters
;
@end
@interface LibreAccessService_1_2_0Soap11Binding_AcknowledgeLicense : LibreAccessService_1_2_0Soap11BindingOperation {
	tns1_AcknowledgeLicenseRequest * parameters;
}
@property (nonatomic, retain) tns1_AcknowledgeLicenseRequest * parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)aDelegate
	parameters:(tns1_AcknowledgeLicenseRequest *)aParameters
;
@end
@interface LibreAccessService_1_2_0Soap11Binding_GetLicensableStatus : LibreAccessService_1_2_0Soap11BindingOperation {
	tns1_GetLicensableStatusRequest * parameters;
}
@property (nonatomic, retain) tns1_GetLicensableStatusRequest * parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)aDelegate
	parameters:(tns1_GetLicensableStatusRequest *)aParameters
;
@end
@interface LibreAccessService_1_2_0Soap11Binding_GetKeyId : LibreAccessService_1_2_0Soap11BindingOperation {
	tns1_GetKeyIdRequest * parameters;
}
@property (nonatomic, retain) tns1_GetKeyIdRequest * parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)aDelegate
	parameters:(tns1_GetKeyIdRequest *)aParameters
;
@end
@interface LibreAccessService_1_2_0Soap11Binding_ListReadBooks : LibreAccessService_1_2_0Soap11BindingOperation {
	tns1_ListReadBooksRequest * parameters;
}
@property (nonatomic, retain) tns1_ListReadBooksRequest * parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)aDelegate
	parameters:(tns1_ListReadBooksRequest *)aParameters
;
@end
@interface LibreAccessService_1_2_0Soap11Binding_ListReadingStatisticsAggregateByTitle : LibreAccessService_1_2_0Soap11BindingOperation {
	tns1_ListReadingStatisticsAggregateByTitleRequest * parameters;
}
@property (nonatomic, retain) tns1_ListReadingStatisticsAggregateByTitleRequest * parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)aDelegate
	parameters:(tns1_ListReadingStatisticsAggregateByTitleRequest *)aParameters
;
@end
@interface LibreAccessService_1_2_0Soap11Binding_SaveProfileContentAnnotations : LibreAccessService_1_2_0Soap11BindingOperation {
	tns1_SaveProfileContentAnnotationsRequest * parameters;
}
@property (nonatomic, retain) tns1_SaveProfileContentAnnotationsRequest * parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)aDelegate
	parameters:(tns1_SaveProfileContentAnnotationsRequest *)aParameters
;
@end
@interface LibreAccessService_1_2_0Soap11Binding_ListReadingStatisticsAggregate : LibreAccessService_1_2_0Soap11BindingOperation {
	tns1_ListReadingStatisticsAggregateRequest * parameters;
}
@property (nonatomic, retain) tns1_ListReadingStatisticsAggregateRequest * parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)aDelegate
	parameters:(tns1_ListReadingStatisticsAggregateRequest *)aParameters
;
@end
@interface LibreAccessService_1_2_0Soap11Binding_ListContentMetadata : LibreAccessService_1_2_0Soap11BindingOperation {
	tns1_ListContentMetadata * body;
}
@property (nonatomic, retain) tns1_ListContentMetadata * body;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)aDelegate
	body:(tns1_ListContentMetadata *)aBody
;
@end
@interface LibreAccessService_1_2_0Soap11Binding_ListProfileRecentAnnotations : LibreAccessService_1_2_0Soap11BindingOperation {
	tns1_ListProfileRecentAnnotationsRequest * parameters;
}
@property (nonatomic, retain) tns1_ListProfileRecentAnnotationsRequest * parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)aDelegate
	parameters:(tns1_ListProfileRecentAnnotationsRequest *)aParameters
;
@end
@interface LibreAccessService_1_2_0Soap11Binding_SetAccountAutoAssign : LibreAccessService_1_2_0Soap11BindingOperation {
	tns1_SetAccountAutoAssignRequest * parameters;
}
@property (nonatomic, retain) tns1_SetAccountAutoAssignRequest * parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)aDelegate
	parameters:(tns1_SetAccountAutoAssignRequest *)aParameters
;
@end
@interface LibreAccessService_1_2_0Soap11Binding_ListDefaultBooks : LibreAccessService_1_2_0Soap11BindingOperation {
	tns1_ListDefaultBooksRequest * parameters;
}
@property (nonatomic, retain) tns1_ListDefaultBooksRequest * parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)aDelegate
	parameters:(tns1_ListDefaultBooksRequest *)aParameters
;
@end
@interface LibreAccessService_1_2_0Soap11Binding_RemoveDefaultBooks : LibreAccessService_1_2_0Soap11BindingOperation {
	tns1_RemoveDefaultBooksRequest * parameters;
}
@property (nonatomic, retain) tns1_RemoveDefaultBooksRequest * parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)aDelegate
	parameters:(tns1_RemoveDefaultBooksRequest *)aParameters
;
@end
@interface LibreAccessService_1_2_0Soap11Binding_SaveUserSettings : LibreAccessService_1_2_0Soap11BindingOperation {
	tns1_SaveUserSettingsRequest * parameters;
}
@property (nonatomic, retain) tns1_SaveUserSettingsRequest * parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)aDelegate
	parameters:(tns1_SaveUserSettingsRequest *)aParameters
;
@end
@interface LibreAccessService_1_2_0Soap11Binding_SaveUserProfiles : LibreAccessService_1_2_0Soap11BindingOperation {
	tns1_SaveUserProfilesRequest * parameters;
}
@property (nonatomic, retain) tns1_SaveUserProfilesRequest * parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)aDelegate
	parameters:(tns1_SaveUserProfilesRequest *)aParameters
;
@end
@interface LibreAccessService_1_2_0Soap11Binding_DeviceLeftDomain : LibreAccessService_1_2_0Soap11BindingOperation {
	tns1_DeviceLeftDomainRequest * parameters;
}
@property (nonatomic, retain) tns1_DeviceLeftDomainRequest * parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)aDelegate
	parameters:(tns1_DeviceLeftDomainRequest *)aParameters
;
@end
@interface LibreAccessService_1_2_0Soap11Binding_ListApplicationSettings : LibreAccessService_1_2_0Soap11BindingOperation {
	tns1_ListApplicationSettingsRequest * parameters;
}
@property (nonatomic, retain) tns1_ListApplicationSettingsRequest * parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)aDelegate
	parameters:(tns1_ListApplicationSettingsRequest *)aParameters
;
@end
@interface LibreAccessService_1_2_0Soap11Binding_TokenExchange : LibreAccessService_1_2_0Soap11BindingOperation {
	tns1_TokenExchange * body;
}
@property (nonatomic, retain) tns1_TokenExchange * body;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)aDelegate
	body:(tns1_TokenExchange *)aBody
;
@end
@interface LibreAccessService_1_2_0Soap11Binding_ValidateScreenName : LibreAccessService_1_2_0Soap11BindingOperation {
	tns1_ValidateScreenNameRequest * parameters;
}
@property (nonatomic, retain) tns1_ValidateScreenNameRequest * parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)aDelegate
	parameters:(tns1_ValidateScreenNameRequest *)aParameters
;
@end
@interface LibreAccessService_1_2_0Soap11Binding_RemoveOrder : LibreAccessService_1_2_0Soap11BindingOperation {
	tns1_RemoveOrderRequest * parameters;
}
@property (nonatomic, retain) tns1_RemoveOrderRequest * parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)aDelegate
	parameters:(tns1_RemoveOrderRequest *)aParameters
;
@end
@interface LibreAccessService_1_2_0Soap11Binding_SaveReadingStatisticsDetailed : LibreAccessService_1_2_0Soap11BindingOperation {
	tns1_SaveReadingStatisticsDetailedRequest * parameters;
}
@property (nonatomic, retain) tns1_SaveReadingStatisticsDetailedRequest * parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)aDelegate
	parameters:(tns1_SaveReadingStatisticsDetailedRequest *)aParameters
;
@end
@interface LibreAccessService_1_2_0Soap11Binding_SharedTokenExchange : LibreAccessService_1_2_0Soap11BindingOperation {
	tns1_SharedTokenExchangeRequest * body;
}
@property (nonatomic, retain) tns1_SharedTokenExchangeRequest * body;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)aDelegate
	body:(tns1_SharedTokenExchangeRequest *)aBody
;
@end
@interface LibreAccessService_1_2_0Soap11Binding_DeleteBookShelfEntry : LibreAccessService_1_2_0Soap11BindingOperation {
	tns1_DeleteBookShelfEntryRequest * parameters;
}
@property (nonatomic, retain) tns1_DeleteBookShelfEntryRequest * parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)aDelegate
	parameters:(tns1_DeleteBookShelfEntryRequest *)aParameters
;
@end
@interface LibreAccessService_1_2_0Soap11Binding_DeviceCanJoinDomain : LibreAccessService_1_2_0Soap11BindingOperation {
	tns1_DeviceCanJoinDomainRequest * parameters;
}
@property (nonatomic, retain) tns1_DeviceCanJoinDomainRequest * parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)aDelegate
	parameters:(tns1_DeviceCanJoinDomainRequest *)aParameters
;
@end
@interface LibreAccessService_1_2_0Soap11Binding_AuthenticateDevice : LibreAccessService_1_2_0Soap11BindingOperation {
	tns1_AuthenticateDeviceRequest * body;
}
@property (nonatomic, retain) tns1_AuthenticateDeviceRequest * body;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)aDelegate
	body:(tns1_AuthenticateDeviceRequest *)aBody
;
@end
@interface LibreAccessService_1_2_0Soap11Binding_DeregisterAllDevices : LibreAccessService_1_2_0Soap11BindingOperation {
	tns1_DeregisterAllDevicesRequest * parameters;
}
@property (nonatomic, retain) tns1_DeregisterAllDevicesRequest * parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)aDelegate
	parameters:(tns1_DeregisterAllDevicesRequest *)aParameters
;
@end
@interface LibreAccessService_1_2_0Soap11Binding_SaveUserCSRNotes : LibreAccessService_1_2_0Soap11BindingOperation {
	tns1_SaveUserCSRNotesRequest * parameters;
}
@property (nonatomic, retain) tns1_SaveUserCSRNotesRequest * parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)aDelegate
	parameters:(tns1_SaveUserCSRNotesRequest *)aParameters
;
@end
@interface LibreAccessService_1_2_0Soap11Binding_AssignBooksToAllUsers : LibreAccessService_1_2_0Soap11BindingOperation {
	tns1_AssignBooksToAllUsersRequest * parameters;
}
@property (nonatomic, retain) tns1_AssignBooksToAllUsersRequest * parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)aDelegate
	parameters:(tns1_AssignBooksToAllUsersRequest *)aParameters
;
@end
@interface LibreAccessService_1_2_0Soap11Binding_envelope : NSObject {
}
+ (LibreAccessService_1_2_0Soap11Binding_envelope *)sharedInstance;
- (NSString *)serializedFormUsingHeaderElements:(NSDictionary *)headerElements bodyElements:(NSDictionary *)bodyElements bodyKeys:(NSArray *)bodyKeys;
@end
@interface LibreAccessService_1_2_0Soap11BindingResponse : NSObject {
	NSArray *headers;
	NSArray *bodyParts;
	NSError *error;
}
@property (nonatomic, retain) NSArray *headers;
@property (nonatomic, retain) NSArray *bodyParts;
@property (nonatomic, retain) NSError *error;
@end
