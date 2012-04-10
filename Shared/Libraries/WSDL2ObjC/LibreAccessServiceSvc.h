#import <Foundation/Foundation.h>
#import "USAdditions.h"
#import <libxml/tree.h>
#import "USGlobals.h"
#import <objc/runtime.h>
@class LibreAccessServiceSvc_DBSchemaErrorList;
@class LibreAccessServiceSvc_DBSchemaErrorItem;
@class LibreAccessServiceSvc_StatusHolder;
@class LibreAccessServiceSvc_ItemsCount;
@class LibreAccessServiceSvc_UserContentItem;
@class LibreAccessServiceSvc_ContentProfileList;
@class LibreAccessServiceSvc_OrderList;
@class LibreAccessServiceSvc_UserContentItemEx;
@class LibreAccessServiceSvc_UserContentForRatingsItem;
@class LibreAccessServiceSvc_ContentProfileForRatingsList;
@class LibreAccessServiceSvc_OrderListForRatings;
@class LibreAccessServiceSvc_isbnItem;
@class LibreAccessServiceSvc_ContentMetadataItem;
@class LibreAccessServiceSvc_ContentMetadataForRatingsItem;
@class LibreAccessServiceSvc_ContentProfileAssignmentList;
@class LibreAccessServiceSvc_ContentProfileAssignmentItem;
@class LibreAccessServiceSvc_AssignedProfileList;
@class LibreAccessServiceSvc_TopFavoritesRequestList;
@class LibreAccessServiceSvc_TopFavoritesRequestItem;
@class LibreAccessServiceSvc_TopRatingsRequestList;
@class LibreAccessServiceSvc_TopRatingsRequestItem;
@class LibreAccessServiceSvc_TopFavoritesResponseList;
@class LibreAccessServiceSvc_TopFavoritesResponseItem;
@class LibreAccessServiceSvc_TopFavoritesContentItems;
@class LibreAccessServiceSvc_TopFavoritesContentItem;
@class LibreAccessServiceSvc_TopRatingsResponseList;
@class LibreAccessServiceSvc_TopRatingsResponseItem;
@class LibreAccessServiceSvc_TopRatingsContentItems;
@class LibreAccessServiceSvc_TopRatingsContentItem;
@class LibreAccessServiceSvc_AssignedProfileItem;
@class LibreAccessServiceSvc_ContentProfileItem;
@class LibreAccessServiceSvc_ContentProfileForRatingsItem;
@class LibreAccessServiceSvc_OrderItem;
@class LibreAccessServiceSvc_OrderItemForRatings;
@class LibreAccessServiceSvc_CorpInfo;
@class LibreAccessServiceSvc_OrderSourceInfo;
@class LibreAccessServiceSvc_SaveProfileList;
@class LibreAccessServiceSvc_SaveProfileItem;
@class LibreAccessServiceSvc_ProfileList;
@class LibreAccessServiceSvc_ProfileItem;
@class LibreAccessServiceSvc_ApplicationSettingList;
@class LibreAccessServiceSvc_ApplicationSettingItem;
@class LibreAccessServiceSvc_ProfileStatusList;
@class LibreAccessServiceSvc_ProfileStatusItem;
@class LibreAccessServiceSvc_DeviceItem;
@class LibreAccessServiceSvc_DeviceList;
@class LibreAccessServiceSvc_AnnotationsRequestList;
@class LibreAccessServiceSvc_AnnotationsRequestItem;
@class LibreAccessServiceSvc_AnnotationsRequestContentList;
@class LibreAccessServiceSvc_AnnotationsRequestListForRatings;
@class LibreAccessServiceSvc_AnnotationsRequestItemForRatings;
@class LibreAccessServiceSvc_AnnotationsRequestContentItem;
@class LibreAccessServiceSvc_PrivateAnnotationsRequest;
@class LibreAccessServiceSvc_AnnotationsList;
@class LibreAccessServiceSvc_AnnotationsItem;
@class LibreAccessServiceSvc_AnnotationsContentList;
@class LibreAccessServiceSvc_AnnotationsContentItem;
@class LibreAccessServiceSvc_PrivateAnnotations;
@class LibreAccessServiceSvc_AnnotationsForRatingsList;
@class LibreAccessServiceSvc_AnnotationsForRatingsItem;
@class LibreAccessServiceSvc_AnnotationsContentForRatingsList;
@class LibreAccessServiceSvc_AnnotationsContentForRatingsItem;
@class LibreAccessServiceSvc_PrivateAnnotationsForRatings;
@class LibreAccessServiceSvc_Highlights;
@class LibreAccessServiceSvc_Notes;
@class LibreAccessServiceSvc_Bookmarks;
@class LibreAccessServiceSvc_Favorite;
@class LibreAccessServiceSvc_LastPage;
@class LibreAccessServiceSvc_Rating;
@class LibreAccessServiceSvc_Highlight;
@class LibreAccessServiceSvc_LocationText;
@class LibreAccessServiceSvc_WordIndex;
@class LibreAccessServiceSvc_Note;
@class LibreAccessServiceSvc_LocationGraphics;
@class LibreAccessServiceSvc_Coords;
@class LibreAccessServiceSvc_Bookmark;
@class LibreAccessServiceSvc_LocationBookmark;
@class LibreAccessServiceSvc_AnnotationStatusList;
@class LibreAccessServiceSvc_AnnotationStatusItem;
@class LibreAccessServiceSvc_AnnotationStatusContentList;
@class LibreAccessServiceSvc_AnnotationStatusContentItem;
@class LibreAccessServiceSvc_PrivateAnnotationsStatus;
@class LibreAccessServiceSvc_AnnotationStatusForRatingsList;
@class LibreAccessServiceSvc_AnnotationStatusForRatingsItem;
@class LibreAccessServiceSvc_AnnotationStatusContentForRatingsList;
@class LibreAccessServiceSvc_AnnotationStatusContentForRatingsItem;
@class LibreAccessServiceSvc_PrivateAnnotationsStatusForRatings;
@class LibreAccessServiceSvc_AnnotationTypeStatusList;
@class LibreAccessServiceSvc_AnnotationTypeStatusItem;
@class LibreAccessServiceSvc_ReadingStatsAggregateList;
@class LibreAccessServiceSvc_ReadingStatsAggregateItem;
@class LibreAccessServiceSvc_ReadingStatsDetailList;
@class LibreAccessServiceSvc_ReadingStatsDetailItem;
@class LibreAccessServiceSvc_ReadingStatsContentList;
@class LibreAccessServiceSvc_ReadingStatsContentItem;
@class LibreAccessServiceSvc_ReadingStatsEntryList;
@class LibreAccessServiceSvc_ReadingStatsEntryItem;
@class LibreAccessServiceSvc_DictionaryLookupsList;
@class LibreAccessServiceSvc_BookshelfEntryList;
@class LibreAccessServiceSvc_BookShelfEntryItem;
@class LibreAccessServiceSvc_ProfileIdList;
@class LibreAccessServiceSvc_ProfileBookshelfEntryList;
@class LibreAccessServiceSvc_ProfileBookshelfEntryItem;
@class LibreAccessServiceSvc_BookshelfEntryLastPageList;
@class LibreAccessServiceSvc_BookShelfEntryLastPageItem;
@class LibreAccessServiceSvc_FavoriteTypesList;
@class LibreAccessServiceSvc_FavoriteTypesItem;
@class LibreAccessServiceSvc_FavoriteTypeValuesList;
@class LibreAccessServiceSvc_FavoriteTypesValuesItem;
@class LibreAccessServiceSvc_UserSettingsList;
@class LibreAccessServiceSvc_UserSettingsItem;
@class LibreAccessServiceSvc_SettingsList;
@class LibreAccessServiceSvc_SettingItem;
@class LibreAccessServiceSvc_SettingStatusList;
@class LibreAccessServiceSvc_SettingStatusItem;
@class LibreAccessServiceSvc_AutoAssignProfilesList;
@class LibreAccessServiceSvc_AutoAssignProfilesItem;
@class LibreAccessServiceSvc_ReadBooksList;
@class LibreAccessServiceSvc_ReadBooksItem;
@class LibreAccessServiceSvc_ReadBooksProfilesList;
@class LibreAccessServiceSvc_ReadBooksProfilesItem;
@class LibreAccessServiceSvc_LastNRequestReadBooksProfilesList;
@class LibreAccessServiceSvc_LastNRequestReadBooksProfilesItem;
@class LibreAccessServiceSvc_LastNResponseReadBooksProfilesList;
@class LibreAccessServiceSvc_LastNResponseReadBooksProfilesItem;
@class LibreAccessServiceSvc_LastNReadBooksList;
@class LibreAccessServiceSvc_LastNReadBooksItem;
@class LibreAccessServiceSvc_LastNRequestWordsList;
@class LibreAccessServiceSvc_LastNRequestWordsItem;
@class LibreAccessServiceSvc_LastNResponseWordsList;
@class LibreAccessServiceSvc_LastNResponseWordsItem;
@class LibreAccessServiceSvc_LastNLookedUpWordsList;
@class LibreAccessServiceSvc_LastNLookedUpWordsItem;
@class LibreAccessServiceSvc_NotesList;
@class LibreAccessServiceSvc_NoteItem;
@class LibreAccessServiceSvc_DefaultBooksList;
@class LibreAccessServiceSvc_DefaultBooksItem;
@class LibreAccessServiceSvc_AssignBooksToAllUsersList;
@class LibreAccessServiceSvc_AssignBooksToAllUsersItem;
@class LibreAccessServiceSvc_AssignBooksToAllUsersBooksList;
@class LibreAccessServiceSvc_AssignBooksToAllUsersBooksItem;
@class LibreAccessServiceSvc_TokenExchange;
@class LibreAccessServiceSvc_TokenExchangeResponse;
@class LibreAccessServiceSvc_TokenExchangeEx;
@class LibreAccessServiceSvc_TokenExchangeExResponse;
@class LibreAccessServiceSvc_TokenExchangeExCoppaRequest;
@class LibreAccessServiceSvc_TokenExchangeExCoppaResponse;
@class LibreAccessServiceSvc_SharedTokenExchangeRequest;
@class LibreAccessServiceSvc_SharedTokenExchangeResponse;
@class LibreAccessServiceSvc_AuthenticateDeviceRequest;
@class LibreAccessServiceSvc_AuthenticateDeviceResponse;
@class LibreAccessServiceSvc_RenewTokenRequest;
@class LibreAccessServiceSvc_RenewTokenResponse;
@class LibreAccessServiceSvc_ListUserContent;
@class LibreAccessServiceSvc_ListUserContentResponse;
@class LibreAccessServiceSvc_UserContentList;
@class LibreAccessServiceSvc_ListUserContentEx;
@class LibreAccessServiceSvc_ListUserContentExResponse;
@class LibreAccessServiceSvc_UserContentListEx;
@class LibreAccessServiceSvc_ListUserContentForRatingsRequest;
@class LibreAccessServiceSvc_ListUserContentForRatingsResponse;
@class LibreAccessServiceSvc_UserContentForRatings;
@class LibreAccessServiceSvc_ListContentMetadata;
@class LibreAccessServiceSvc_ListContentMetadataResponse;
@class LibreAccessServiceSvc_ContentMetadataList;
@class LibreAccessServiceSvc_ListContentMetadataForRatingsRequest;
@class LibreAccessServiceSvc_ListContentMetadataForRatingsResponse;
@class LibreAccessServiceSvc_ContentMetadataForRatingsList;
@class LibreAccessServiceSvc_IsEntitledToLicense;
@class LibreAccessServiceSvc_IsEntitledToLicenseResponse;
@class LibreAccessServiceSvc_EntitledToLicenceRequest;
@class LibreAccessServiceSvc_SaveReadingStatisticsDetailedRequest;
@class LibreAccessServiceSvc_SaveReadingStatisticsDetailedResponse;
@class LibreAccessServiceSvc_ListReadingStatisticsAggregateRequest;
@class LibreAccessServiceSvc_ListReadingStatisticsAggregateResponse;
@class LibreAccessServiceSvc_ListReadingStatisticsDetailedRequest;
@class LibreAccessServiceSvc_ListReadingStatisticsDetailedResponse;
@class LibreAccessServiceSvc_SaveProfileContentAnnotationsRequest;
@class LibreAccessServiceSvc_SaveProfileContentAnnotationsResponse;
@class LibreAccessServiceSvc_SaveProfileContentAnnotationsForRatingsRequest;
@class LibreAccessServiceSvc_SaveProfileContentAnnotationsForRatingsResponse;
@class LibreAccessServiceSvc_ListProfileContentAnnotationsRequest;
@class LibreAccessServiceSvc_ListProfileContentAnnotationsResponse;
@class LibreAccessServiceSvc_ListProfileContentAnnotationsForRatingsRequest;
@class LibreAccessServiceSvc_ListProfileContentAnnotationsForRatingsResponse;
@class LibreAccessServiceSvc_GetUserProfilesRequest;
@class LibreAccessServiceSvc_GetUserProfilesResponse;
@class LibreAccessServiceSvc_SaveUserProfilesRequest;
@class LibreAccessServiceSvc_SaveUserProfilesResponse;
@class LibreAccessServiceSvc_ListApplicationSettingsRequest;
@class LibreAccessServiceSvc_ListApplicationSettingsResponse;
@class LibreAccessServiceSvc_SaveContentProfileAssignmentRequest;
@class LibreAccessServiceSvc_SaveContentProfileAssignmentResponse;
@class LibreAccessServiceSvc_ListTopFavoritesRequest;
@class LibreAccessServiceSvc_ListTopFavoritesResponse;
@class LibreAccessServiceSvc_GetDeviceInfoRequest;
@class LibreAccessServiceSvc_GetDeviceInfoResponse;
@class LibreAccessServiceSvc_SaveDeviceInfoRequest;
@class LibreAccessServiceSvc_SaveDeviceInfoResponse;
@class LibreAccessServiceSvc_SaveNewDomainResponse;
@class LibreAccessServiceSvc_SaveNewDomainRequest;
@class LibreAccessServiceSvc_DeviceLeftDomainResponse;
@class LibreAccessServiceSvc_DeviceLeftDomainRequest;
@class LibreAccessServiceSvc_DeviceCanJoinDomainResponse;
@class LibreAccessServiceSvc_DeviceCanJoinDomainRequest;
@class LibreAccessServiceSvc_GetLicensableStatusResponse;
@class LibreAccessServiceSvc_GetLicensableStatusRequest;
@class LibreAccessServiceSvc_AcknowledgeLicenseResponse;
@class LibreAccessServiceSvc_AcknowledgeLicenseRequest;
@class LibreAccessServiceSvc_ValidateScreenNameRequest;
@class LibreAccessServiceSvc_ValidateScreenNameResponse;
@class LibreAccessServiceSvc_ValidateUserKeyRequest;
@class LibreAccessServiceSvc_ValidateUserKeyResponse;
@class LibreAccessServiceSvc_DeleteBookShelfEntryRequest;
@class LibreAccessServiceSvc_DeleteBookShelfEntryResponse;
@class LibreAccessServiceSvc_GetLastPageLocationRequest;
@class LibreAccessServiceSvc_GetLastPageLocationResponse;
@class LibreAccessServiceSvc_SaveLastPageLocationRequest;
@class LibreAccessServiceSvc_SaveLastPageLocationResponse;
@class LibreAccessServiceSvc_ListFavoriteTypesRequest;
@class LibreAccessServiceSvc_ListFavoriteTypesResponse;
@class LibreAccessServiceSvc_SaveUserSettingsRequest;
@class LibreAccessServiceSvc_SaveUserSettingsResponse;
@class LibreAccessServiceSvc_SaveUserSettingsExRequest;
@class LibreAccessServiceSvc_SaveUserSettingsExResponse;
@class LibreAccessServiceSvc_ListUserSettingsRequest;
@class LibreAccessServiceSvc_ListUserSettingsResponse;
@class LibreAccessServiceSvc_ListUserSettingsExRequest;
@class LibreAccessServiceSvc_ListUserSettingsExResponse;
@class LibreAccessServiceSvc_SetAccountAutoAssignRequest;
@class LibreAccessServiceSvc_SetAccountAutoAssignResponse;
@class LibreAccessServiceSvc_SetAccountPasswordRequiredRequest;
@class LibreAccessServiceSvc_SetAccountPasswordRequiredResponse;
@class LibreAccessServiceSvc_ListReadBooksRequest;
@class LibreAccessServiceSvc_ListReadBooksResponse;
@class LibreAccessServiceSvc_ListLastNProfileReadBooksRequest;
@class LibreAccessServiceSvc_ListLastNProfileReadBooksResponse;
@class LibreAccessServiceSvc_ListLastNWordsRequest;
@class LibreAccessServiceSvc_ListLastNWordsResponse;
@class LibreAccessServiceSvc_RemoveOrderRequest;
@class LibreAccessServiceSvc_RemoveOrderResponse;
@class LibreAccessServiceSvc_SaveUserCSRNotesRequest;
@class LibreAccessServiceSvc_SaveUserCSRNotesResponse;
@class LibreAccessServiceSvc_ListUserCSRNotesRequest;
@class LibreAccessServiceSvc_ListUserCSRNotesResponse;
@class LibreAccessServiceSvc_GetKeyIdRequest;
@class LibreAccessServiceSvc_GetKeyIdResponse;
@class LibreAccessServiceSvc_SaveDefaultBooksRequest;
@class LibreAccessServiceSvc_SaveDefaultBooksResponse;
@class LibreAccessServiceSvc_ListDefaultBooksRequest;
@class LibreAccessServiceSvc_ListDefaultBooksResponse;
@class LibreAccessServiceSvc_RemoveDefaultBooksRequest;
@class LibreAccessServiceSvc_RemoveDefaultBooksResponse;
@class LibreAccessServiceSvc_AssignBooksToAllUsersRequest;
@class LibreAccessServiceSvc_AssignBooksToAllUsersResponse;
@class LibreAccessServiceSvc_SetLoggingLevelRequest;
@class LibreAccessServiceSvc_SetLoggingLevelResponse;
@class LibreAccessServiceSvc_HealthCheckResponse;
@class LibreAccessServiceSvc_EndpointsList;
@class LibreAccessServiceSvc_DBSchemaError;
@class LibreAccessServiceSvc_ListAvailableDumps;
@class LibreAccessServiceSvc_UserKeysList;
@class LibreAccessServiceSvc_ListAvailableDumpsResponse;
@class LibreAccessServiceSvc_DumpListAvailable;
@class LibreAccessServiceSvc_DumpItemAvailable;
@class LibreAccessServiceSvc_GetVersionRequest;
@class LibreAccessServiceSvc_GetVersionResponse;
@class LibreAccessServiceSvc_ListTopRatingsRequest;
@class LibreAccessServiceSvc_ListTopRatingsResponse;
typedef enum {
	LibreAccessServiceSvc_statuscodes_none = 0,
	LibreAccessServiceSvc_statuscodes_SUCCESS,
	LibreAccessServiceSvc_statuscodes_FAIL,
} LibreAccessServiceSvc_statuscodes;
LibreAccessServiceSvc_statuscodes LibreAccessServiceSvc_statuscodes_enumFromString(NSString *string);
NSString * LibreAccessServiceSvc_statuscodes_stringFromEnum(LibreAccessServiceSvc_statuscodes enumValue);
typedef enum {
	LibreAccessServiceSvc_ErrorType_none = 0,
	LibreAccessServiceSvc_ErrorType_WARNING,
	LibreAccessServiceSvc_ErrorType_ERROR,
} LibreAccessServiceSvc_ErrorType;
LibreAccessServiceSvc_ErrorType LibreAccessServiceSvc_ErrorType_enumFromString(NSString *string);
NSString * LibreAccessServiceSvc_ErrorType_stringFromEnum(LibreAccessServiceSvc_ErrorType enumValue);
@interface LibreAccessServiceSvc_DBSchemaErrorItem : NSObject <NSCoding> {
/* elements */
	NSString * errorCode;
	NSString * error;
	LibreAccessServiceSvc_ErrorType type;
	NSString * description;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_DBSchemaErrorItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * errorCode;
@property (nonatomic, retain) NSString * error;
@property (nonatomic, assign) LibreAccessServiceSvc_ErrorType type;
@property (nonatomic, retain) NSString * description;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_DBSchemaErrorList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *errorItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_DBSchemaErrorList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addErrorItem:(LibreAccessServiceSvc_DBSchemaErrorItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * errorItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_StatusHolder : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_statuscodes status;
	NSNumber * statuscode;
	NSString * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_StatusHolder *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, assign) LibreAccessServiceSvc_statuscodes status;
@property (nonatomic, retain) NSNumber * statuscode;
@property (nonatomic, retain) NSString * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ItemsCount : NSObject <NSCoding> {
/* elements */
	NSNumber * Returned;
	NSNumber * Found;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ItemsCount *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * Returned;
@property (nonatomic, retain) NSNumber * Found;
/* attributes */
- (NSDictionary *)attributes;
@end
typedef enum {
	LibreAccessServiceSvc_ProfileTypes_none = 0,
	LibreAccessServiceSvc_ProfileTypes_PARENT,
	LibreAccessServiceSvc_ProfileTypes_CHILD,
} LibreAccessServiceSvc_ProfileTypes;
LibreAccessServiceSvc_ProfileTypes LibreAccessServiceSvc_ProfileTypes_enumFromString(NSString *string);
NSString * LibreAccessServiceSvc_ProfileTypes_stringFromEnum(LibreAccessServiceSvc_ProfileTypes enumValue);
typedef enum {
	LibreAccessServiceSvc_BookshelfStyle_none = 0,
	LibreAccessServiceSvc_BookshelfStyle_YOUNG_CHILD,
	LibreAccessServiceSvc_BookshelfStyle_OLDER_CHILD,
	LibreAccessServiceSvc_BookshelfStyle_ADULT,
} LibreAccessServiceSvc_BookshelfStyle;
LibreAccessServiceSvc_BookshelfStyle LibreAccessServiceSvc_BookshelfStyle_enumFromString(NSString *string);
NSString * LibreAccessServiceSvc_BookshelfStyle_stringFromEnum(LibreAccessServiceSvc_BookshelfStyle enumValue);
typedef enum {
	LibreAccessServiceSvc_UserSettingsTypes_none = 0,
	LibreAccessServiceSvc_UserSettingsTypes_STORE_READ_STAT,
	LibreAccessServiceSvc_UserSettingsTypes_DISABLE_AUTOASSIGN,
} LibreAccessServiceSvc_UserSettingsTypes;
LibreAccessServiceSvc_UserSettingsTypes LibreAccessServiceSvc_UserSettingsTypes_enumFromString(NSString *string);
NSString * LibreAccessServiceSvc_UserSettingsTypes_stringFromEnum(LibreAccessServiceSvc_UserSettingsTypes enumValue);
typedef enum {
	LibreAccessServiceSvc_ApplicationSettings_none = 0,
	LibreAccessServiceSvc_ApplicationSettings_MAX_PROFILES,
	LibreAccessServiceSvc_ApplicationSettings_MAX_DEVICES,
	LibreAccessServiceSvc_ApplicationSettings_REPLACE_SAMPLE,
	LibreAccessServiceSvc_ApplicationSettings_SAMPLE_FULL_COEXISTS,
	LibreAccessServiceSvc_ApplicationSettings_APPLICATION_SESSION_TIMEOUT,
	LibreAccessServiceSvc_ApplicationSettings_AUTOASSIGN_LEVEL,
	LibreAccessServiceSvc_ApplicationSettings_PASSWORD_REQUIRED_LEVEL,
	LibreAccessServiceSvc_ApplicationSettings_BOOK_ASSIGNMENT_LIMIT,
	LibreAccessServiceSvc_ApplicationSettings_UNASSIGNED_BOOKS_TOP,
	LibreAccessServiceSvc_ApplicationSettings_DELETE_ANNOTATIONS_CASCADE,
	LibreAccessServiceSvc_ApplicationSettings_DELETE_READSTAT_CASCADE,
	LibreAccessServiceSvc_ApplicationSettings_ENCRYPT_METHOD,
	LibreAccessServiceSvc_ApplicationSettings_ENCRYPT_KEY,
	LibreAccessServiceSvc_ApplicationSettings_FREE_BOOKS_ASSIGNMENT_LIMIT,
	LibreAccessServiceSvc_ApplicationSettings_ALLOW_MULTIPLE_LICENSES,
	LibreAccessServiceSvc_ApplicationSettings_DEFAULT_FORMAT,
	LibreAccessServiceSvc_ApplicationSettings_AUTHENTICATION_ENDPOINT,
	LibreAccessServiceSvc_ApplicationSettings_VERSION_INFO_EXPIRES,
	LibreAccessServiceSvc_ApplicationSettings_UNREGISTERED_DEVICES_LIMIT,
	LibreAccessServiceSvc_ApplicationSettings_DEACTIVATE_ON_DEREGISTER,
	LibreAccessServiceSvc_ApplicationSettings_CONTENT_URL_TTL,
	LibreAccessServiceSvc_ApplicationSettings_COVER_URL_TTL,
} LibreAccessServiceSvc_ApplicationSettings;
LibreAccessServiceSvc_ApplicationSettings LibreAccessServiceSvc_ApplicationSettings_enumFromString(NSString *string);
NSString * LibreAccessServiceSvc_ApplicationSettings_stringFromEnum(LibreAccessServiceSvc_ApplicationSettings enumValue);
typedef enum {
	LibreAccessServiceSvc_ContentIdentifierTypes_none = 0,
	LibreAccessServiceSvc_ContentIdentifierTypes_ISBN13,
} LibreAccessServiceSvc_ContentIdentifierTypes;
LibreAccessServiceSvc_ContentIdentifierTypes LibreAccessServiceSvc_ContentIdentifierTypes_enumFromString(NSString *string);
NSString * LibreAccessServiceSvc_ContentIdentifierTypes_stringFromEnum(LibreAccessServiceSvc_ContentIdentifierTypes enumValue);
typedef enum {
	LibreAccessServiceSvc_drmqualifiers_none = 0,
	LibreAccessServiceSvc_drmqualifiers_FULL_WITH_DRM,
	LibreAccessServiceSvc_drmqualifiers_FULL_NO_DRM,
	LibreAccessServiceSvc_drmqualifiers_SAMPLE,
} LibreAccessServiceSvc_drmqualifiers;
LibreAccessServiceSvc_drmqualifiers LibreAccessServiceSvc_drmqualifiers_enumFromString(NSString *string);
NSString * LibreAccessServiceSvc_drmqualifiers_stringFromEnum(LibreAccessServiceSvc_drmqualifiers enumValue);
@interface LibreAccessServiceSvc_ContentProfileItem : NSObject <NSCoding> {
/* elements */
	NSNumber * profileID;
	USBoolean * isFavorite;
	NSNumber * lastPageLocation;
	NSDate * lastmodified;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ContentProfileItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * profileID;
@property (nonatomic, retain) USBoolean * isFavorite;
@property (nonatomic, retain) NSNumber * lastPageLocation;
@property (nonatomic, retain) NSDate * lastmodified;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ContentProfileList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *ContentProfileItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ContentProfileList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addContentProfileItem:(LibreAccessServiceSvc_ContentProfileItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * ContentProfileItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_OrderItem : NSObject <NSCoding> {
/* elements */
	NSString * OrderID;
	NSDate * OrderDate;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_OrderItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * OrderID;
@property (nonatomic, retain) NSDate * OrderDate;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_OrderList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *OrderItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_OrderList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addOrderItem:(LibreAccessServiceSvc_OrderItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * OrderItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_UserContentItem : NSObject <NSCoding> {
/* elements */
	NSString * ContentIdentifier;
	LibreAccessServiceSvc_ContentIdentifierTypes ContentIdentifierType;
	LibreAccessServiceSvc_drmqualifiers DRMQualifier;
	NSString * Format;
	NSString * Version;
	LibreAccessServiceSvc_ContentProfileList * ContentProfileList;
	LibreAccessServiceSvc_OrderList * OrderList;
	NSDate * lastmodified;
	USBoolean * DefaultAssignment;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_UserContentItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * ContentIdentifier;
@property (nonatomic, assign) LibreAccessServiceSvc_ContentIdentifierTypes ContentIdentifierType;
@property (nonatomic, assign) LibreAccessServiceSvc_drmqualifiers DRMQualifier;
@property (nonatomic, retain) NSString * Format;
@property (nonatomic, retain) NSString * Version;
@property (nonatomic, retain) LibreAccessServiceSvc_ContentProfileList * ContentProfileList;
@property (nonatomic, retain) LibreAccessServiceSvc_OrderList * OrderList;
@property (nonatomic, retain) NSDate * lastmodified;
@property (nonatomic, retain) USBoolean * DefaultAssignment;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_UserContentItemEx : LibreAccessServiceSvc_UserContentItem {
/* elements */
	USBoolean * FreeBook;
	NSString * LastVersion;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_UserContentItemEx *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) USBoolean * FreeBook;
@property (nonatomic, retain) NSString * LastVersion;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ContentProfileForRatingsItem : NSObject <NSCoding> {
/* elements */
	NSNumber * profileID;
	USBoolean * isFavorite;
	NSNumber * rating;
	NSNumber * lastPageLocation;
	NSDate * lastmodified;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ContentProfileForRatingsItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * profileID;
@property (nonatomic, retain) USBoolean * isFavorite;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSNumber * lastPageLocation;
@property (nonatomic, retain) NSDate * lastmodified;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ContentProfileForRatingsList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *ContentProfileForRatingsItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ContentProfileForRatingsList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addContentProfileForRatingsItem:(LibreAccessServiceSvc_ContentProfileForRatingsItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * ContentProfileForRatingsItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_CorpInfo : NSObject <NSCoding> {
/* elements */
	NSString * transactionIdSourceField;
	NSNumber * transactionId;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_CorpInfo *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * transactionIdSourceField;
@property (nonatomic, retain) NSNumber * transactionId;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_OrderSourceInfo : NSObject <NSCoding> {
/* elements */
	NSString * srcSystem;
	NSString * srcFile;
	NSNumber * srcKey;
	NSNumber * srcUserId;
	NSString * srcHost;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_OrderSourceInfo *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * srcSystem;
@property (nonatomic, retain) NSString * srcFile;
@property (nonatomic, retain) NSNumber * srcKey;
@property (nonatomic, retain) NSNumber * srcUserId;
@property (nonatomic, retain) NSString * srcHost;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_OrderItemForRatings : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_CorpInfo * corpInfo;
	LibreAccessServiceSvc_OrderSourceInfo * orderSourceInfo;
	NSString * orderIdSourceField;
	NSString * orderId;
	NSDate * orderDate;
	NSString * contentGroup;
	NSString * childId;
	NSString * teacherId;
	NSString * refId3;
	NSString * refId4;
	NSString * refId5;
	NSDate * transactionDate;
	NSString * UCN;
	NSNumber * quantity;
	NSNumber * quantityInit;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_OrderItemForRatings *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessServiceSvc_CorpInfo * corpInfo;
@property (nonatomic, retain) LibreAccessServiceSvc_OrderSourceInfo * orderSourceInfo;
@property (nonatomic, retain) NSString * orderIdSourceField;
@property (nonatomic, retain) NSString * orderId;
@property (nonatomic, retain) NSDate * orderDate;
@property (nonatomic, retain) NSString * contentGroup;
@property (nonatomic, retain) NSString * childId;
@property (nonatomic, retain) NSString * teacherId;
@property (nonatomic, retain) NSString * refId3;
@property (nonatomic, retain) NSString * refId4;
@property (nonatomic, retain) NSString * refId5;
@property (nonatomic, retain) NSDate * transactionDate;
@property (nonatomic, retain) NSString * UCN;
@property (nonatomic, retain) NSNumber * quantity;
@property (nonatomic, retain) NSNumber * quantityInit;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_OrderListForRatings : NSObject <NSCoding> {
/* elements */
	NSMutableArray *OrderItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_OrderListForRatings *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addOrderItem:(LibreAccessServiceSvc_OrderItemForRatings *)toAdd;
@property (nonatomic, readonly) NSMutableArray * OrderItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_UserContentForRatingsItem : NSObject <NSCoding> {
/* elements */
	NSString * ContentIdentifier;
	LibreAccessServiceSvc_ContentIdentifierTypes ContentIdentifierType;
	LibreAccessServiceSvc_drmqualifiers DRMQualifier;
	NSString * Format;
	NSString * Version;
	NSNumber * AverageRating;
	LibreAccessServiceSvc_ContentProfileForRatingsList * ContentProfileForRatingsList;
	LibreAccessServiceSvc_OrderListForRatings * OrderList;
	NSDate * lastmodified;
	USBoolean * DefaultAssignment;
	USBoolean * FreeBook;
	NSString * LastVersion;
	NSNumber * Quantity;
	NSNumber * QuantityInit;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_UserContentForRatingsItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * ContentIdentifier;
@property (nonatomic, assign) LibreAccessServiceSvc_ContentIdentifierTypes ContentIdentifierType;
@property (nonatomic, assign) LibreAccessServiceSvc_drmqualifiers DRMQualifier;
@property (nonatomic, retain) NSString * Format;
@property (nonatomic, retain) NSString * Version;
@property (nonatomic, retain) NSNumber * AverageRating;
@property (nonatomic, retain) LibreAccessServiceSvc_ContentProfileForRatingsList * ContentProfileForRatingsList;
@property (nonatomic, retain) LibreAccessServiceSvc_OrderListForRatings * OrderList;
@property (nonatomic, retain) NSDate * lastmodified;
@property (nonatomic, retain) USBoolean * DefaultAssignment;
@property (nonatomic, retain) USBoolean * FreeBook;
@property (nonatomic, retain) NSString * LastVersion;
@property (nonatomic, retain) NSNumber * Quantity;
@property (nonatomic, retain) NSNumber * QuantityInit;
/* attributes */
- (NSDictionary *)attributes;
@end
typedef enum {
	LibreAccessServiceSvc_TopFavoritesTypes_none = 0,
	LibreAccessServiceSvc_TopFavoritesTypes_EREADER_CATEGORY,
	LibreAccessServiceSvc_TopFavoritesTypes_EREADER_CATEGORY_CLASS,
} LibreAccessServiceSvc_TopFavoritesTypes;
LibreAccessServiceSvc_TopFavoritesTypes LibreAccessServiceSvc_TopFavoritesTypes_enumFromString(NSString *string);
NSString * LibreAccessServiceSvc_TopFavoritesTypes_stringFromEnum(LibreAccessServiceSvc_TopFavoritesTypes enumValue);
@interface LibreAccessServiceSvc_isbnItem : NSObject <NSCoding> {
/* elements */
	NSString * ISBN;
	NSString * Format;
	LibreAccessServiceSvc_ContentIdentifierTypes IdentifierType;
	LibreAccessServiceSvc_drmqualifiers Qualifier;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_isbnItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * ISBN;
@property (nonatomic, retain) NSString * Format;
@property (nonatomic, assign) LibreAccessServiceSvc_ContentIdentifierTypes IdentifierType;
@property (nonatomic, assign) LibreAccessServiceSvc_drmqualifiers Qualifier;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ContentMetadataItem : NSObject <NSCoding> {
/* elements */
	NSString * ContentIdentifier;
	LibreAccessServiceSvc_ContentIdentifierTypes ContentIdentifierType;
	NSString * Title;
	NSString * Author;
	NSString * Description;
	NSString * Version;
	NSNumber * PageNumber;
	NSNumber * FileSize;
	LibreAccessServiceSvc_drmqualifiers DRMQualifier;
	NSString * CoverURL;
	NSString * ContentURL;
	NSMutableArray *EreaderCategories;
	USBoolean * Enhanced;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ContentMetadataItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * ContentIdentifier;
@property (nonatomic, assign) LibreAccessServiceSvc_ContentIdentifierTypes ContentIdentifierType;
@property (nonatomic, retain) NSString * Title;
@property (nonatomic, retain) NSString * Author;
@property (nonatomic, retain) NSString * Description;
@property (nonatomic, retain) NSString * Version;
@property (nonatomic, retain) NSNumber * PageNumber;
@property (nonatomic, retain) NSNumber * FileSize;
@property (nonatomic, assign) LibreAccessServiceSvc_drmqualifiers DRMQualifier;
@property (nonatomic, retain) NSString * CoverURL;
@property (nonatomic, retain) NSString * ContentURL;
- (void)addEreaderCategories:(NSString *)toAdd;
@property (nonatomic, readonly) NSMutableArray * EreaderCategories;
@property (nonatomic, retain) USBoolean * Enhanced;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ContentMetadataForRatingsItem : NSObject <NSCoding> {
/* elements */
	NSString * ContentIdentifier;
	LibreAccessServiceSvc_ContentIdentifierTypes ContentIdentifierType;
	NSNumber * AverageRating;
	NSString * Title;
	NSString * Author;
	NSString * Description;
	NSString * Version;
	NSNumber * PageNumber;
	NSNumber * FileSize;
	LibreAccessServiceSvc_drmqualifiers DRMQualifier;
	NSString * CoverURL;
	NSString * ContentURL;
	NSMutableArray *EreaderCategories;
	USBoolean * Enhanced;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ContentMetadataForRatingsItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * ContentIdentifier;
@property (nonatomic, assign) LibreAccessServiceSvc_ContentIdentifierTypes ContentIdentifierType;
@property (nonatomic, retain) NSNumber * AverageRating;
@property (nonatomic, retain) NSString * Title;
@property (nonatomic, retain) NSString * Author;
@property (nonatomic, retain) NSString * Description;
@property (nonatomic, retain) NSString * Version;
@property (nonatomic, retain) NSNumber * PageNumber;
@property (nonatomic, retain) NSNumber * FileSize;
@property (nonatomic, assign) LibreAccessServiceSvc_drmqualifiers DRMQualifier;
@property (nonatomic, retain) NSString * CoverURL;
@property (nonatomic, retain) NSString * ContentURL;
- (void)addEreaderCategories:(NSString *)toAdd;
@property (nonatomic, readonly) NSMutableArray * EreaderCategories;
@property (nonatomic, retain) USBoolean * Enhanced;
/* attributes */
- (NSDictionary *)attributes;
@end
typedef enum {
	LibreAccessServiceSvc_SaveActions_none = 0,
	LibreAccessServiceSvc_SaveActions_CREATE,
	LibreAccessServiceSvc_SaveActions_UPDATE,
	LibreAccessServiceSvc_SaveActions_REMOVE,
} LibreAccessServiceSvc_SaveActions;
LibreAccessServiceSvc_SaveActions LibreAccessServiceSvc_SaveActions_enumFromString(NSString *string);
NSString * LibreAccessServiceSvc_SaveActions_stringFromEnum(LibreAccessServiceSvc_SaveActions enumValue);
@interface LibreAccessServiceSvc_AssignedProfileItem : NSObject <NSCoding> {
/* elements */
	NSNumber * profileID;
	LibreAccessServiceSvc_SaveActions action;
	NSDate * lastmodified;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_AssignedProfileItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * profileID;
@property (nonatomic, assign) LibreAccessServiceSvc_SaveActions action;
@property (nonatomic, retain) NSDate * lastmodified;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AssignedProfileList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *AssignedProfileItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_AssignedProfileList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addAssignedProfileItem:(LibreAccessServiceSvc_AssignedProfileItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * AssignedProfileItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ContentProfileAssignmentItem : NSObject <NSCoding> {
/* elements */
	NSString * contentIdentifier;
	LibreAccessServiceSvc_ContentIdentifierTypes ContentIdentifierType;
	LibreAccessServiceSvc_drmqualifiers drmqualifier;
	NSString * format;
	LibreAccessServiceSvc_AssignedProfileList * AssignedProfileList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ContentProfileAssignmentItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * contentIdentifier;
@property (nonatomic, assign) LibreAccessServiceSvc_ContentIdentifierTypes ContentIdentifierType;
@property (nonatomic, assign) LibreAccessServiceSvc_drmqualifiers drmqualifier;
@property (nonatomic, retain) NSString * format;
@property (nonatomic, retain) LibreAccessServiceSvc_AssignedProfileList * AssignedProfileList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ContentProfileAssignmentList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *ContentProfileAssignmentItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ContentProfileAssignmentList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addContentProfileAssignmentItem:(LibreAccessServiceSvc_ContentProfileAssignmentItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * ContentProfileAssignmentItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_TopFavoritesRequestItem : NSObject <NSCoding> {
/* elements */
	USBoolean * AssignedBooksOnly;
	LibreAccessServiceSvc_TopFavoritesTypes TopFavoritesType;
	NSString * TopFavoritesTypeValue;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_TopFavoritesRequestItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) USBoolean * AssignedBooksOnly;
@property (nonatomic, assign) LibreAccessServiceSvc_TopFavoritesTypes TopFavoritesType;
@property (nonatomic, retain) NSString * TopFavoritesTypeValue;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_TopFavoritesRequestList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *TopFavoritesRequestItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_TopFavoritesRequestList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addTopFavoritesRequestItem:(LibreAccessServiceSvc_TopFavoritesRequestItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * TopFavoritesRequestItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_TopRatingsRequestItem : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_TopFavoritesTypes TopRatingsType;
	NSString * TopRatingsTypeValue;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_TopRatingsRequestItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, assign) LibreAccessServiceSvc_TopFavoritesTypes TopRatingsType;
@property (nonatomic, retain) NSString * TopRatingsTypeValue;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_TopRatingsRequestList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *TopRatingsRequestItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_TopRatingsRequestList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addTopRatingsRequestItem:(LibreAccessServiceSvc_TopRatingsRequestItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * TopRatingsRequestItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_TopFavoritesContentItem : NSObject <NSCoding> {
/* elements */
	NSString * ContentIdentifier;
	LibreAccessServiceSvc_ContentIdentifierTypes ContentIdentifierType;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_TopFavoritesContentItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * ContentIdentifier;
@property (nonatomic, assign) LibreAccessServiceSvc_ContentIdentifierTypes ContentIdentifierType;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_TopFavoritesContentItems : NSObject <NSCoding> {
/* elements */
	NSMutableArray *TopFavoritesContentItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_TopFavoritesContentItems *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addTopFavoritesContentItem:(LibreAccessServiceSvc_TopFavoritesContentItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * TopFavoritesContentItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_TopFavoritesResponseItem : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_TopFavoritesTypes TopFavoritesType;
	NSString * TopFavoritesTypeValue;
	LibreAccessServiceSvc_TopFavoritesContentItems * TopFavoritesContentItems;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_TopFavoritesResponseItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, assign) LibreAccessServiceSvc_TopFavoritesTypes TopFavoritesType;
@property (nonatomic, retain) NSString * TopFavoritesTypeValue;
@property (nonatomic, retain) LibreAccessServiceSvc_TopFavoritesContentItems * TopFavoritesContentItems;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_TopFavoritesResponseList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *TopFavoritesResponseItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_TopFavoritesResponseList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addTopFavoritesResponseItem:(LibreAccessServiceSvc_TopFavoritesResponseItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * TopFavoritesResponseItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_TopRatingsContentItem : NSObject <NSCoding> {
/* elements */
	NSString * ContentIdentifier;
	LibreAccessServiceSvc_ContentIdentifierTypes ContentIdentifierType;
	NSNumber * AverageRating;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_TopRatingsContentItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * ContentIdentifier;
@property (nonatomic, assign) LibreAccessServiceSvc_ContentIdentifierTypes ContentIdentifierType;
@property (nonatomic, retain) NSNumber * AverageRating;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_TopRatingsContentItems : NSObject <NSCoding> {
/* elements */
	NSMutableArray *TopRatingsContentItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_TopRatingsContentItems *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addTopRatingsContentItem:(LibreAccessServiceSvc_TopRatingsContentItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * TopRatingsContentItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_TopRatingsResponseItem : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_TopFavoritesTypes TopRatingsType;
	NSString * TopRatingsTypeValue;
	LibreAccessServiceSvc_TopRatingsContentItems * TopRatingsContentItems;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_TopRatingsResponseItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, assign) LibreAccessServiceSvc_TopFavoritesTypes TopRatingsType;
@property (nonatomic, retain) NSString * TopRatingsTypeValue;
@property (nonatomic, retain) LibreAccessServiceSvc_TopRatingsContentItems * TopRatingsContentItems;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_TopRatingsResponseList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *TopRatingsResponseItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_TopRatingsResponseList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addTopRatingsResponseItem:(LibreAccessServiceSvc_TopRatingsResponseItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * TopRatingsResponseItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SaveProfileItem : NSObject <NSCoding> {
/* elements */
	USBoolean * AutoAssignContentToProfiles;
	USBoolean * ProfilePasswordRequired;
	NSString * Firstname;
	NSString * Lastname;
	NSDate * BirthDay;
	NSDate * LastModified;
	NSString * screenname;
	NSString * password;
	NSString * userkey;
	LibreAccessServiceSvc_ProfileTypes type;
	NSNumber * id_;
	LibreAccessServiceSvc_SaveActions action;
	LibreAccessServiceSvc_BookshelfStyle BookshelfStyle;
	USBoolean * storyInteractionEnabled;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_SaveProfileItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) USBoolean * AutoAssignContentToProfiles;
@property (nonatomic, retain) USBoolean * ProfilePasswordRequired;
@property (nonatomic, retain) NSString * Firstname;
@property (nonatomic, retain) NSString * Lastname;
@property (nonatomic, retain) NSDate * BirthDay;
@property (nonatomic, retain) NSDate * LastModified;
@property (nonatomic, retain) NSString * screenname;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * userkey;
@property (nonatomic, assign) LibreAccessServiceSvc_ProfileTypes type;
@property (nonatomic, retain) NSNumber * id_;
@property (nonatomic, assign) LibreAccessServiceSvc_SaveActions action;
@property (nonatomic, assign) LibreAccessServiceSvc_BookshelfStyle BookshelfStyle;
@property (nonatomic, retain) USBoolean * storyInteractionEnabled;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SaveProfileList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *SaveProfileItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_SaveProfileList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addSaveProfileItem:(LibreAccessServiceSvc_SaveProfileItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * SaveProfileItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ProfileItem : NSObject <NSCoding> {
/* elements */
	USBoolean * AutoAssignContentToProfiles;
	USBoolean * ProfilePasswordRequired;
	NSString * Firstname;
	NSString * Lastname;
	NSDate * BirthDay;
	NSString * screenname;
	NSString * password;
	NSString * userkey;
	LibreAccessServiceSvc_ProfileTypes type;
	NSNumber * id_;
	LibreAccessServiceSvc_BookshelfStyle BookshelfStyle;
	NSDate * LastModified;
	NSDate * LastScreenNameModified;
	NSDate * LastPasswordModified;
	USBoolean * storyInteractionEnabled;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ProfileItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) USBoolean * AutoAssignContentToProfiles;
@property (nonatomic, retain) USBoolean * ProfilePasswordRequired;
@property (nonatomic, retain) NSString * Firstname;
@property (nonatomic, retain) NSString * Lastname;
@property (nonatomic, retain) NSDate * BirthDay;
@property (nonatomic, retain) NSString * screenname;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * userkey;
@property (nonatomic, assign) LibreAccessServiceSvc_ProfileTypes type;
@property (nonatomic, retain) NSNumber * id_;
@property (nonatomic, assign) LibreAccessServiceSvc_BookshelfStyle BookshelfStyle;
@property (nonatomic, retain) NSDate * LastModified;
@property (nonatomic, retain) NSDate * LastScreenNameModified;
@property (nonatomic, retain) NSDate * LastPasswordModified;
@property (nonatomic, retain) USBoolean * storyInteractionEnabled;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ProfileList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *ProfileItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ProfileList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addProfileItem:(LibreAccessServiceSvc_ProfileItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * ProfileItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ApplicationSettingItem : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_ApplicationSettings settingName;
	NSString * settingValue;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ApplicationSettingItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, assign) LibreAccessServiceSvc_ApplicationSettings settingName;
@property (nonatomic, retain) NSString * settingValue;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ApplicationSettingList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *ApplicationSettingItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ApplicationSettingList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addApplicationSettingItem:(LibreAccessServiceSvc_ApplicationSettingItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * ApplicationSettingItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ProfileStatusItem : NSObject <NSCoding> {
/* elements */
	NSNumber * id_;
	LibreAccessServiceSvc_SaveActions action;
	LibreAccessServiceSvc_statuscodes status;
	NSString * screenname;
	NSNumber * statuscode;
	NSString * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ProfileStatusItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * id_;
@property (nonatomic, assign) LibreAccessServiceSvc_SaveActions action;
@property (nonatomic, assign) LibreAccessServiceSvc_statuscodes status;
@property (nonatomic, retain) NSString * screenname;
@property (nonatomic, retain) NSNumber * statuscode;
@property (nonatomic, retain) NSString * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ProfileStatusList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *ProfileStatusItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ProfileStatusList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addProfileStatusItem:(LibreAccessServiceSvc_ProfileStatusItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * ProfileStatusItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_DeviceItem : NSObject <NSCoding> {
/* elements */
	NSString * DeviceKey;
	NSNumber * DeviceId;
	USBoolean * AutoloadContent;
	NSString * DevicePlatform;
	NSString * DeviceNickname;
	USBoolean * Active;
	NSString * RemoveReason;
	NSNumber * BadLoginAttempts;
	NSDate * BadLoginDatetimeUTC;
	USBoolean * DeregistrationConfirmed;
	NSDate * lastmodified;
	NSDate * lastactivated;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_DeviceItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * DeviceKey;
@property (nonatomic, retain) NSNumber * DeviceId;
@property (nonatomic, retain) USBoolean * AutoloadContent;
@property (nonatomic, retain) NSString * DevicePlatform;
@property (nonatomic, retain) NSString * DeviceNickname;
@property (nonatomic, retain) USBoolean * Active;
@property (nonatomic, retain) NSString * RemoveReason;
@property (nonatomic, retain) NSNumber * BadLoginAttempts;
@property (nonatomic, retain) NSDate * BadLoginDatetimeUTC;
@property (nonatomic, retain) USBoolean * DeregistrationConfirmed;
@property (nonatomic, retain) NSDate * lastmodified;
@property (nonatomic, retain) NSDate * lastactivated;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_DeviceList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *DeviceItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_DeviceList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addDeviceItem:(LibreAccessServiceSvc_DeviceItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * DeviceItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_PrivateAnnotationsRequest : NSObject <NSCoding> {
/* elements */
	NSNumber * version;
	NSDate * HighlightsAfter;
	NSDate * NotesAfter;
	NSDate * BookmarksAfter;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_PrivateAnnotationsRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * version;
@property (nonatomic, retain) NSDate * HighlightsAfter;
@property (nonatomic, retain) NSDate * NotesAfter;
@property (nonatomic, retain) NSDate * BookmarksAfter;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AnnotationsRequestContentItem : NSObject <NSCoding> {
/* elements */
	NSString * contentIdentifier;
	LibreAccessServiceSvc_ContentIdentifierTypes ContentIdentifierType;
	LibreAccessServiceSvc_drmqualifiers drmqualifier;
	NSString * format;
	LibreAccessServiceSvc_PrivateAnnotationsRequest * PrivateAnnotationsRequest;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_AnnotationsRequestContentItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * contentIdentifier;
@property (nonatomic, assign) LibreAccessServiceSvc_ContentIdentifierTypes ContentIdentifierType;
@property (nonatomic, assign) LibreAccessServiceSvc_drmqualifiers drmqualifier;
@property (nonatomic, retain) NSString * format;
@property (nonatomic, retain) LibreAccessServiceSvc_PrivateAnnotationsRequest * PrivateAnnotationsRequest;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AnnotationsRequestContentList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *AnnotationsRequestContentItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_AnnotationsRequestContentList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addAnnotationsRequestContentItem:(LibreAccessServiceSvc_AnnotationsRequestContentItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * AnnotationsRequestContentItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AnnotationsRequestItem : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_AnnotationsRequestContentList * AnnotationsRequestContentList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_AnnotationsRequestItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessServiceSvc_AnnotationsRequestContentList * AnnotationsRequestContentList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AnnotationsRequestList : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_AnnotationsRequestItem * AnnotationsRequestItem;
	NSNumber * profileID;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_AnnotationsRequestList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessServiceSvc_AnnotationsRequestItem * AnnotationsRequestItem;
@property (nonatomic, retain) NSNumber * profileID;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AnnotationsRequestItemForRatings : LibreAccessServiceSvc_AnnotationsRequestItem {
/* elements */
	NSNumber * profileID;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_AnnotationsRequestItemForRatings *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * profileID;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AnnotationsRequestListForRatings : NSObject <NSCoding> {
/* elements */
	NSMutableArray *AnnotationsRequestItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_AnnotationsRequestListForRatings *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addAnnotationsRequestItem:(LibreAccessServiceSvc_AnnotationsRequestItemForRatings *)toAdd;
@property (nonatomic, readonly) NSMutableArray * AnnotationsRequestItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_WordIndex : NSObject <NSCoding> {
/* elements */
	NSNumber * start;
	NSNumber * end;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_WordIndex *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * start;
@property (nonatomic, retain) NSNumber * end;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_LocationText : NSObject <NSCoding> {
/* elements */
	NSNumber * page;
	LibreAccessServiceSvc_WordIndex * wordindex;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_LocationText *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * page;
@property (nonatomic, retain) LibreAccessServiceSvc_WordIndex * wordindex;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_Highlight : NSObject <NSCoding> {
/* elements */
	NSNumber * id_;
	LibreAccessServiceSvc_SaveActions action;
	NSString * color;
	LibreAccessServiceSvc_LocationText * location;
	NSNumber * endPage;
	NSNumber * version;
	NSDate * lastmodified;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_Highlight *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * id_;
@property (nonatomic, assign) LibreAccessServiceSvc_SaveActions action;
@property (nonatomic, retain) NSString * color;
@property (nonatomic, retain) LibreAccessServiceSvc_LocationText * location;
@property (nonatomic, retain) NSNumber * endPage;
@property (nonatomic, retain) NSNumber * version;
@property (nonatomic, retain) NSDate * lastmodified;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_Highlights : NSObject <NSCoding> {
/* elements */
	NSMutableArray *Highlight;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_Highlights *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addHighlight:(LibreAccessServiceSvc_Highlight *)toAdd;
@property (nonatomic, readonly) NSMutableArray * Highlight;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_Coords : NSObject <NSCoding> {
/* elements */
	NSNumber * x;
	NSNumber * y;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_Coords *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * x;
@property (nonatomic, retain) NSNumber * y;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_LocationGraphics : NSObject <NSCoding> {
/* elements */
	NSNumber * page;
	LibreAccessServiceSvc_Coords * coords;
	NSNumber * wordindex;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_LocationGraphics *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * page;
@property (nonatomic, retain) LibreAccessServiceSvc_Coords * coords;
@property (nonatomic, retain) NSNumber * wordindex;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_Note : NSObject <NSCoding> {
/* elements */
	NSNumber * id_;
	LibreAccessServiceSvc_SaveActions action;
	LibreAccessServiceSvc_LocationGraphics * location;
	NSString * color;
	NSString * value;
	NSNumber * version;
	NSDate * lastmodified;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_Note *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * id_;
@property (nonatomic, assign) LibreAccessServiceSvc_SaveActions action;
@property (nonatomic, retain) LibreAccessServiceSvc_LocationGraphics * location;
@property (nonatomic, retain) NSString * color;
@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) NSNumber * version;
@property (nonatomic, retain) NSDate * lastmodified;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_Notes : NSObject <NSCoding> {
/* elements */
	NSMutableArray *Note;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_Notes *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addNote:(LibreAccessServiceSvc_Note *)toAdd;
@property (nonatomic, readonly) NSMutableArray * Note;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_LocationBookmark : NSObject <NSCoding> {
/* elements */
	NSNumber * page;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_LocationBookmark *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * page;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_Bookmark : NSObject <NSCoding> {
/* elements */
	NSNumber * id_;
	LibreAccessServiceSvc_SaveActions action;
	NSString * text;
	USBoolean * disabled;
	LibreAccessServiceSvc_LocationBookmark * location;
	NSNumber * version;
	NSDate * lastmodified;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_Bookmark *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * id_;
@property (nonatomic, assign) LibreAccessServiceSvc_SaveActions action;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) USBoolean * disabled;
@property (nonatomic, retain) LibreAccessServiceSvc_LocationBookmark * location;
@property (nonatomic, retain) NSNumber * version;
@property (nonatomic, retain) NSDate * lastmodified;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_Bookmarks : NSObject <NSCoding> {
/* elements */
	NSMutableArray *Bookmark;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_Bookmarks *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addBookmark:(LibreAccessServiceSvc_Bookmark *)toAdd;
@property (nonatomic, readonly) NSMutableArray * Bookmark;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_Favorite : NSObject <NSCoding> {
/* elements */
	USBoolean * isFavorite;
	NSDate * lastmodified;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_Favorite *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) USBoolean * isFavorite;
@property (nonatomic, retain) NSDate * lastmodified;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_LastPage : NSObject <NSCoding> {
/* elements */
	NSNumber * lastPageLocation;
	NSNumber * percentage;
	NSString * component;
	NSDate * lastmodified;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_LastPage *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * lastPageLocation;
@property (nonatomic, retain) NSNumber * percentage;
@property (nonatomic, retain) NSString * component;
@property (nonatomic, retain) NSDate * lastmodified;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_PrivateAnnotations : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_Highlights * Highlights;
	LibreAccessServiceSvc_Notes * Notes;
	LibreAccessServiceSvc_Bookmarks * Bookmarks;
	LibreAccessServiceSvc_Favorite * Favorite;
	LibreAccessServiceSvc_LastPage * LastPage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_PrivateAnnotations *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessServiceSvc_Highlights * Highlights;
@property (nonatomic, retain) LibreAccessServiceSvc_Notes * Notes;
@property (nonatomic, retain) LibreAccessServiceSvc_Bookmarks * Bookmarks;
@property (nonatomic, retain) LibreAccessServiceSvc_Favorite * Favorite;
@property (nonatomic, retain) LibreAccessServiceSvc_LastPage * LastPage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AnnotationsContentItem : NSObject <NSCoding> {
/* elements */
	NSString * contentIdentifier;
	LibreAccessServiceSvc_ContentIdentifierTypes ContentIdentifierType;
	LibreAccessServiceSvc_drmqualifiers drmqualifier;
	NSString * format;
	LibreAccessServiceSvc_PrivateAnnotations * PrivateAnnotations;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_AnnotationsContentItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * contentIdentifier;
@property (nonatomic, assign) LibreAccessServiceSvc_ContentIdentifierTypes ContentIdentifierType;
@property (nonatomic, assign) LibreAccessServiceSvc_drmqualifiers drmqualifier;
@property (nonatomic, retain) NSString * format;
@property (nonatomic, retain) LibreAccessServiceSvc_PrivateAnnotations * PrivateAnnotations;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AnnotationsContentList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *AnnotationsContentItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_AnnotationsContentList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addAnnotationsContentItem:(LibreAccessServiceSvc_AnnotationsContentItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * AnnotationsContentItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AnnotationsItem : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_AnnotationsContentList * AnnotationsContentList;
	NSNumber * profileID;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_AnnotationsItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessServiceSvc_AnnotationsContentList * AnnotationsContentList;
@property (nonatomic, retain) NSNumber * profileID;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AnnotationsList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *AnnotationsItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_AnnotationsList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addAnnotationsItem:(LibreAccessServiceSvc_AnnotationsItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * AnnotationsItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_Rating : NSObject <NSCoding> {
/* elements */
	NSNumber * rating;
	NSDate * lastmodified;
	NSNumber * averageRating;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_Rating *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSDate * lastmodified;
@property (nonatomic, retain) NSNumber * averageRating;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_PrivateAnnotationsForRatings : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_Highlights * Highlights;
	LibreAccessServiceSvc_Notes * Notes;
	LibreAccessServiceSvc_Bookmarks * Bookmarks;
	LibreAccessServiceSvc_LastPage * LastPage;
	LibreAccessServiceSvc_Rating * Rating;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_PrivateAnnotationsForRatings *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessServiceSvc_Highlights * Highlights;
@property (nonatomic, retain) LibreAccessServiceSvc_Notes * Notes;
@property (nonatomic, retain) LibreAccessServiceSvc_Bookmarks * Bookmarks;
@property (nonatomic, retain) LibreAccessServiceSvc_LastPage * LastPage;
@property (nonatomic, retain) LibreAccessServiceSvc_Rating * Rating;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AnnotationsContentForRatingsItem : NSObject <NSCoding> {
/* elements */
	NSString * contentIdentifier;
	LibreAccessServiceSvc_ContentIdentifierTypes ContentIdentifierType;
	LibreAccessServiceSvc_drmqualifiers drmqualifier;
	NSString * format;
	LibreAccessServiceSvc_PrivateAnnotationsForRatings * PrivateAnnotations;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_AnnotationsContentForRatingsItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * contentIdentifier;
@property (nonatomic, assign) LibreAccessServiceSvc_ContentIdentifierTypes ContentIdentifierType;
@property (nonatomic, assign) LibreAccessServiceSvc_drmqualifiers drmqualifier;
@property (nonatomic, retain) NSString * format;
@property (nonatomic, retain) LibreAccessServiceSvc_PrivateAnnotationsForRatings * PrivateAnnotations;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AnnotationsContentForRatingsList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *AnnotationsContentForRatingsItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_AnnotationsContentForRatingsList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addAnnotationsContentForRatingsItem:(LibreAccessServiceSvc_AnnotationsContentForRatingsItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * AnnotationsContentForRatingsItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AnnotationsForRatingsItem : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_AnnotationsContentForRatingsList * AnnotationsContentForRatingsList;
	NSNumber * profileID;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_AnnotationsForRatingsItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessServiceSvc_AnnotationsContentForRatingsList * AnnotationsContentForRatingsList;
@property (nonatomic, retain) NSNumber * profileID;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AnnotationsForRatingsList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *AnnotationsForRatingsItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_AnnotationsForRatingsList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addAnnotationsForRatingsItem:(LibreAccessServiceSvc_AnnotationsForRatingsItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * AnnotationsForRatingsItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AnnotationTypeStatusItem : NSObject <NSCoding> {
/* elements */
	NSNumber * id_;
	LibreAccessServiceSvc_SaveActions action;
	LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_AnnotationTypeStatusItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * id_;
@property (nonatomic, assign) LibreAccessServiceSvc_SaveActions action;
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AnnotationTypeStatusList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *AnnotationTypeStatusItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_AnnotationTypeStatusList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addAnnotationTypeStatusItem:(LibreAccessServiceSvc_AnnotationTypeStatusItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * AnnotationTypeStatusItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_PrivateAnnotationsStatus : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_AnnotationTypeStatusList * HighlightsStatusList;
	LibreAccessServiceSvc_AnnotationTypeStatusList * NotesStatusList;
	LibreAccessServiceSvc_AnnotationTypeStatusList * BookmarksStatusList;
	LibreAccessServiceSvc_AnnotationTypeStatusItem * FavoriteStatus;
	LibreAccessServiceSvc_AnnotationTypeStatusItem * LastPageStatus;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_PrivateAnnotationsStatus *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessServiceSvc_AnnotationTypeStatusList * HighlightsStatusList;
@property (nonatomic, retain) LibreAccessServiceSvc_AnnotationTypeStatusList * NotesStatusList;
@property (nonatomic, retain) LibreAccessServiceSvc_AnnotationTypeStatusList * BookmarksStatusList;
@property (nonatomic, retain) LibreAccessServiceSvc_AnnotationTypeStatusItem * FavoriteStatus;
@property (nonatomic, retain) LibreAccessServiceSvc_AnnotationTypeStatusItem * LastPageStatus;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AnnotationStatusContentItem : NSObject <NSCoding> {
/* elements */
	NSString * contentIdentifier;
	LibreAccessServiceSvc_StatusHolder * statusmessage;
	LibreAccessServiceSvc_PrivateAnnotationsStatus * PrivateAnnotationsStatus;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_AnnotationStatusContentItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * contentIdentifier;
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
@property (nonatomic, retain) LibreAccessServiceSvc_PrivateAnnotationsStatus * PrivateAnnotationsStatus;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AnnotationStatusContentList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *AnnotationStatusContentItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_AnnotationStatusContentList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addAnnotationStatusContentItem:(LibreAccessServiceSvc_AnnotationStatusContentItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * AnnotationStatusContentItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AnnotationStatusItem : NSObject <NSCoding> {
/* elements */
	NSNumber * profileId;
	LibreAccessServiceSvc_StatusHolder * statusmessage;
	LibreAccessServiceSvc_AnnotationStatusContentList * AnnotationStatusContentList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_AnnotationStatusItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * profileId;
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
@property (nonatomic, retain) LibreAccessServiceSvc_AnnotationStatusContentList * AnnotationStatusContentList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AnnotationStatusList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *AnnotationStatusItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_AnnotationStatusList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addAnnotationStatusItem:(LibreAccessServiceSvc_AnnotationStatusItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * AnnotationStatusItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_PrivateAnnotationsStatusForRatings : LibreAccessServiceSvc_PrivateAnnotationsStatus {
/* elements */
	LibreAccessServiceSvc_AnnotationTypeStatusItem * RatingStatus;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_PrivateAnnotationsStatusForRatings *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessServiceSvc_AnnotationTypeStatusItem * RatingStatus;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AnnotationStatusContentForRatingsItem : NSObject <NSCoding> {
/* elements */
	NSString * contentIdentifier;
	NSNumber * AverageRating;
	LibreAccessServiceSvc_StatusHolder * statusmessage;
	LibreAccessServiceSvc_PrivateAnnotationsStatusForRatings * PrivateAnnotationsStatus;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_AnnotationStatusContentForRatingsItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * contentIdentifier;
@property (nonatomic, retain) NSNumber * AverageRating;
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
@property (nonatomic, retain) LibreAccessServiceSvc_PrivateAnnotationsStatusForRatings * PrivateAnnotationsStatus;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AnnotationStatusContentForRatingsList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *AnnotationStatusContentForRatingsItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_AnnotationStatusContentForRatingsList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addAnnotationStatusContentForRatingsItem:(LibreAccessServiceSvc_AnnotationStatusContentForRatingsItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * AnnotationStatusContentForRatingsItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AnnotationStatusForRatingsItem : NSObject <NSCoding> {
/* elements */
	NSNumber * profileId;
	LibreAccessServiceSvc_StatusHolder * statusmessage;
	LibreAccessServiceSvc_AnnotationStatusContentForRatingsList * AnnotationStatusContentForRatingsList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_AnnotationStatusForRatingsItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * profileId;
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
@property (nonatomic, retain) LibreAccessServiceSvc_AnnotationStatusContentForRatingsList * AnnotationStatusContentForRatingsList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AnnotationStatusForRatingsList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *AnnotationStatusForRatingsItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_AnnotationStatusForRatingsList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addAnnotationStatusForRatingsItem:(LibreAccessServiceSvc_AnnotationStatusForRatingsItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * AnnotationStatusForRatingsItem;
/* attributes */
- (NSDictionary *)attributes;
@end
typedef enum {
	LibreAccessServiceSvc_aggregationPeriod_none = 0,
	LibreAccessServiceSvc_aggregationPeriod_ALL,
	LibreAccessServiceSvc_aggregationPeriod_WEEK,
	LibreAccessServiceSvc_aggregationPeriod_MONTH,
	LibreAccessServiceSvc_aggregationPeriod_COMBINED,
} LibreAccessServiceSvc_aggregationPeriod;
LibreAccessServiceSvc_aggregationPeriod LibreAccessServiceSvc_aggregationPeriod_enumFromString(NSString *string);
NSString * LibreAccessServiceSvc_aggregationPeriod_stringFromEnum(LibreAccessServiceSvc_aggregationPeriod enumValue);
@interface LibreAccessServiceSvc_ReadingStatsAggregateItem : NSObject <NSCoding> {
/* elements */
	NSNumber * pagesRead;
	NSNumber * storyInteractions;
	NSNumber * contentOpened;
	NSNumber * dictionaryLookups;
	NSNumber * readEvents;
	NSNumber * readingDuration;
	NSNumber * profileID;
	LibreAccessServiceSvc_aggregationPeriod period;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ReadingStatsAggregateItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * pagesRead;
@property (nonatomic, retain) NSNumber * storyInteractions;
@property (nonatomic, retain) NSNumber * contentOpened;
@property (nonatomic, retain) NSNumber * dictionaryLookups;
@property (nonatomic, retain) NSNumber * readEvents;
@property (nonatomic, retain) NSNumber * readingDuration;
@property (nonatomic, retain) NSNumber * profileID;
@property (nonatomic, assign) LibreAccessServiceSvc_aggregationPeriod period;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ReadingStatsAggregateList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *ReadingStatsAggregateItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ReadingStatsAggregateList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addReadingStatsAggregateItem:(LibreAccessServiceSvc_ReadingStatsAggregateItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * ReadingStatsAggregateItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_DictionaryLookupsList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *dictionaryLookupsItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_DictionaryLookupsList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addDictionaryLookupsItem:(NSString *)toAdd;
@property (nonatomic, readonly) NSMutableArray * dictionaryLookupsItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ReadingStatsEntryItem : NSObject <NSCoding> {
/* elements */
	NSNumber * readingDuration;
	NSNumber * pagesRead;
	NSNumber * storyInteractions;
	NSNumber * dictionaryLookups;
	NSString * deviceKey;
	NSDate * timestamp;
	LibreAccessServiceSvc_DictionaryLookupsList * DictionaryLookupsList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ReadingStatsEntryItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * readingDuration;
@property (nonatomic, retain) NSNumber * pagesRead;
@property (nonatomic, retain) NSNumber * storyInteractions;
@property (nonatomic, retain) NSNumber * dictionaryLookups;
@property (nonatomic, retain) NSString * deviceKey;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) LibreAccessServiceSvc_DictionaryLookupsList * DictionaryLookupsList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ReadingStatsEntryList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *ReadingStatsEntryItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ReadingStatsEntryList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addReadingStatsEntryItem:(LibreAccessServiceSvc_ReadingStatsEntryItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * ReadingStatsEntryItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ReadingStatsContentItem : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_ContentIdentifierTypes ContentIdentifierType;
	NSString * contentIdentifier;
	LibreAccessServiceSvc_drmqualifiers drmqualifier;
	NSString * format;
	LibreAccessServiceSvc_ReadingStatsEntryList * ReadingStatsEntryList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ReadingStatsContentItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, assign) LibreAccessServiceSvc_ContentIdentifierTypes ContentIdentifierType;
@property (nonatomic, retain) NSString * contentIdentifier;
@property (nonatomic, assign) LibreAccessServiceSvc_drmqualifiers drmqualifier;
@property (nonatomic, retain) NSString * format;
@property (nonatomic, retain) LibreAccessServiceSvc_ReadingStatsEntryList * ReadingStatsEntryList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ReadingStatsContentList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *ReadingStatsContentItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ReadingStatsContentList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addReadingStatsContentItem:(LibreAccessServiceSvc_ReadingStatsContentItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * ReadingStatsContentItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ReadingStatsDetailItem : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_ReadingStatsContentList * ReadingStatsContentList;
	NSNumber * profileID;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ReadingStatsDetailItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessServiceSvc_ReadingStatsContentList * ReadingStatsContentList;
@property (nonatomic, retain) NSNumber * profileID;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ReadingStatsDetailList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *ReadingStatsDetailItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ReadingStatsDetailList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addReadingStatsDetailItem:(LibreAccessServiceSvc_ReadingStatsDetailItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * ReadingStatsDetailItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ProfileIdList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *profileId;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ProfileIdList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addProfileId:(NSNumber *)toAdd;
@property (nonatomic, readonly) NSMutableArray * profileId;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_BookShelfEntryItem : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_ContentIdentifierTypes ContentIdentifierType;
	NSString * contentidentifier;
	LibreAccessServiceSvc_drmqualifiers drmqualifier;
	NSString * format;
	NSNumber * quantity;
	NSString * notes;
	LibreAccessServiceSvc_ProfileIdList * profileIdList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_BookShelfEntryItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, assign) LibreAccessServiceSvc_ContentIdentifierTypes ContentIdentifierType;
@property (nonatomic, retain) NSString * contentidentifier;
@property (nonatomic, assign) LibreAccessServiceSvc_drmqualifiers drmqualifier;
@property (nonatomic, retain) NSString * format;
@property (nonatomic, retain) NSNumber * quantity;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) LibreAccessServiceSvc_ProfileIdList * profileIdList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_BookshelfEntryList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *BookShelfEntryItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_BookshelfEntryList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addBookShelfEntryItem:(LibreAccessServiceSvc_BookShelfEntryItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * BookShelfEntryItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_BookShelfEntryLastPageItem : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_ContentIdentifierTypes ContentIdentifierType;
	NSString * contentidentifier;
	LibreAccessServiceSvc_drmqualifiers drmqualifier;
	NSString * format;
	LibreAccessServiceSvc_LastPage * LastPage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_BookShelfEntryLastPageItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, assign) LibreAccessServiceSvc_ContentIdentifierTypes ContentIdentifierType;
@property (nonatomic, retain) NSString * contentidentifier;
@property (nonatomic, assign) LibreAccessServiceSvc_drmqualifiers drmqualifier;
@property (nonatomic, retain) NSString * format;
@property (nonatomic, retain) LibreAccessServiceSvc_LastPage * LastPage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_BookshelfEntryLastPageList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *BookShelfEntryLastPageItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_BookshelfEntryLastPageList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addBookShelfEntryLastPageItem:(LibreAccessServiceSvc_BookShelfEntryLastPageItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * BookShelfEntryLastPageItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ProfileBookshelfEntryItem : NSObject <NSCoding> {
/* elements */
	NSNumber * profileId;
	LibreAccessServiceSvc_BookshelfEntryLastPageList * BookshelfEntryLastPageList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ProfileBookshelfEntryItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * profileId;
@property (nonatomic, retain) LibreAccessServiceSvc_BookshelfEntryLastPageList * BookshelfEntryLastPageList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ProfileBookshelfEntryList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *ProfileBookshelfEntryItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ProfileBookshelfEntryList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addProfileBookshelfEntryItem:(LibreAccessServiceSvc_ProfileBookshelfEntryItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * ProfileBookshelfEntryItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_FavoriteTypesValuesItem : NSObject <NSCoding> {
/* elements */
	NSString * Value;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_FavoriteTypesValuesItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * Value;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_FavoriteTypeValuesList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *FavoriteTypesValuesItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_FavoriteTypeValuesList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addFavoriteTypesValuesItem:(LibreAccessServiceSvc_FavoriteTypesValuesItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * FavoriteTypesValuesItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_FavoriteTypesItem : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_TopFavoritesTypes FavoriteType;
	LibreAccessServiceSvc_FavoriteTypeValuesList * FavoriteTypeValuesList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_FavoriteTypesItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, assign) LibreAccessServiceSvc_TopFavoritesTypes FavoriteType;
@property (nonatomic, retain) LibreAccessServiceSvc_FavoriteTypeValuesList * FavoriteTypeValuesList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_FavoriteTypesList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *FavoriteTypesItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_FavoriteTypesList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addFavoriteTypesItem:(LibreAccessServiceSvc_FavoriteTypesItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * FavoriteTypesItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_UserSettingsItem : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_UserSettingsTypes SettingType;
	NSString * SettingValue;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_UserSettingsItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, assign) LibreAccessServiceSvc_UserSettingsTypes SettingType;
@property (nonatomic, retain) NSString * SettingValue;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_UserSettingsList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *UserSettingsItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_UserSettingsList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addUserSettingsItem:(LibreAccessServiceSvc_UserSettingsItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * UserSettingsItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SettingItem : NSObject <NSCoding> {
/* elements */
	NSString * settingName;
	NSString * settingValue;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_SettingItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * settingName;
@property (nonatomic, retain) NSString * settingValue;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SettingsList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *settingItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_SettingsList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addSettingItem:(LibreAccessServiceSvc_SettingItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * settingItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SettingStatusItem : NSObject <NSCoding> {
/* elements */
	NSString * settingName;
	LibreAccessServiceSvc_StatusHolder * statusMessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_SettingStatusItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * settingName;
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusMessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SettingStatusList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *settingStatusItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_SettingStatusList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addSettingStatusItem:(LibreAccessServiceSvc_SettingStatusItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * settingStatusItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AutoAssignProfilesItem : NSObject <NSCoding> {
/* elements */
	NSNumber * profileId;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_AutoAssignProfilesItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * profileId;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AutoAssignProfilesList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *AutoAssignProfilesItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_AutoAssignProfilesList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addAutoAssignProfilesItem:(LibreAccessServiceSvc_AutoAssignProfilesItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * AutoAssignProfilesItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ReadBooksProfilesItem : NSObject <NSCoding> {
/* elements */
	NSNumber * profileId;
	NSDate * lastReadEvent;
	NSNumber * lastReadDuration;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ReadBooksProfilesItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * profileId;
@property (nonatomic, retain) NSDate * lastReadEvent;
@property (nonatomic, retain) NSNumber * lastReadDuration;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ReadBooksProfilesList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *ReadBooksProfilesItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ReadBooksProfilesList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addReadBooksProfilesItem:(LibreAccessServiceSvc_ReadBooksProfilesItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * ReadBooksProfilesItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ReadBooksItem : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_ContentIdentifierTypes ContentIdentifierType;
	NSString * contentIdentifier;
	LibreAccessServiceSvc_drmqualifiers drmqualifier;
	NSString * format;
	NSNumber * version;
	LibreAccessServiceSvc_ReadBooksProfilesList * ReadBooksProfilesList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ReadBooksItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, assign) LibreAccessServiceSvc_ContentIdentifierTypes ContentIdentifierType;
@property (nonatomic, retain) NSString * contentIdentifier;
@property (nonatomic, assign) LibreAccessServiceSvc_drmqualifiers drmqualifier;
@property (nonatomic, retain) NSString * format;
@property (nonatomic, retain) NSNumber * version;
@property (nonatomic, retain) LibreAccessServiceSvc_ReadBooksProfilesList * ReadBooksProfilesList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ReadBooksList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *ReadBooksItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ReadBooksList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addReadBooksItem:(LibreAccessServiceSvc_ReadBooksItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * ReadBooksItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_LastNRequestReadBooksProfilesItem : NSObject <NSCoding> {
/* elements */
	NSNumber * profileId;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_LastNRequestReadBooksProfilesItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * profileId;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_LastNRequestReadBooksProfilesList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *LastNRequestReadBooksProfilesItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_LastNRequestReadBooksProfilesList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addLastNRequestReadBooksProfilesItem:(LibreAccessServiceSvc_LastNRequestReadBooksProfilesItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * LastNRequestReadBooksProfilesItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_LastNReadBooksItem : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_ContentIdentifierTypes ContentIdentifierType;
	NSString * contentIdentifier;
	LibreAccessServiceSvc_drmqualifiers drmqualifier;
	NSString * format;
	NSNumber * version;
	NSDate * lastReadEvent;
	NSNumber * lastReadDuration;
	NSNumber * lastReadPages;
	NSNumber * lastPageLocation;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_LastNReadBooksItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, assign) LibreAccessServiceSvc_ContentIdentifierTypes ContentIdentifierType;
@property (nonatomic, retain) NSString * contentIdentifier;
@property (nonatomic, assign) LibreAccessServiceSvc_drmqualifiers drmqualifier;
@property (nonatomic, retain) NSString * format;
@property (nonatomic, retain) NSNumber * version;
@property (nonatomic, retain) NSDate * lastReadEvent;
@property (nonatomic, retain) NSNumber * lastReadDuration;
@property (nonatomic, retain) NSNumber * lastReadPages;
@property (nonatomic, retain) NSNumber * lastPageLocation;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_LastNReadBooksList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *LastNReadBooksItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_LastNReadBooksList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addLastNReadBooksItem:(LibreAccessServiceSvc_LastNReadBooksItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * LastNReadBooksItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_LastNResponseReadBooksProfilesItem : NSObject <NSCoding> {
/* elements */
	NSNumber * profileId;
	LibreAccessServiceSvc_LastNReadBooksList * LastNReadBooksList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_LastNResponseReadBooksProfilesItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * profileId;
@property (nonatomic, retain) LibreAccessServiceSvc_LastNReadBooksList * LastNReadBooksList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_LastNResponseReadBooksProfilesList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *LastNResponseReadBooksProfilesItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_LastNResponseReadBooksProfilesList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addLastNResponseReadBooksProfilesItem:(LibreAccessServiceSvc_LastNResponseReadBooksProfilesItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * LastNResponseReadBooksProfilesItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_LastNRequestWordsItem : NSObject <NSCoding> {
/* elements */
	NSNumber * profileId;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_LastNRequestWordsItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * profileId;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_LastNRequestWordsList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *LastNRequestWordsItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_LastNRequestWordsList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addLastNRequestWordsItem:(LibreAccessServiceSvc_LastNRequestWordsItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * LastNRequestWordsItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_LastNLookedUpWordsItem : NSObject <NSCoding> {
/* elements */
	NSString * lookupWord;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_LastNLookedUpWordsItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * lookupWord;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_LastNLookedUpWordsList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *LastNLookedUpWordsItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_LastNLookedUpWordsList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addLastNLookedUpWordsItem:(LibreAccessServiceSvc_LastNLookedUpWordsItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * LastNLookedUpWordsItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_LastNResponseWordsItem : NSObject <NSCoding> {
/* elements */
	NSNumber * profileId;
	LibreAccessServiceSvc_LastNLookedUpWordsList * LastNLookedUpWordsList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_LastNResponseWordsItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * profileId;
@property (nonatomic, retain) LibreAccessServiceSvc_LastNLookedUpWordsList * LastNLookedUpWordsList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_LastNResponseWordsList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *LastNResponseWordsItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_LastNResponseWordsList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addLastNResponseWordsItem:(LibreAccessServiceSvc_LastNResponseWordsItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * LastNResponseWordsItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_NoteItem : NSObject <NSCoding> {
/* elements */
	NSString * actor;
	NSString * noteText;
	NSString * csrUserName;
	NSDate * timestamp;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_NoteItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * actor;
@property (nonatomic, retain) NSString * noteText;
@property (nonatomic, retain) NSString * csrUserName;
@property (nonatomic, retain) NSDate * timestamp;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_NotesList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *noteItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_NotesList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addNoteItem:(LibreAccessServiceSvc_NoteItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * noteItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_DefaultBooksItem : NSObject <NSCoding> {
/* elements */
	NSString * contentidentifier;
	LibreAccessServiceSvc_ContentIdentifierTypes contentIdentifierType;
	LibreAccessServiceSvc_drmqualifiers DRMQualifier;
	NSString * Format;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_DefaultBooksItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * contentidentifier;
@property (nonatomic, assign) LibreAccessServiceSvc_ContentIdentifierTypes contentIdentifierType;
@property (nonatomic, assign) LibreAccessServiceSvc_drmqualifiers DRMQualifier;
@property (nonatomic, retain) NSString * Format;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_DefaultBooksList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *DefaultBooksItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_DefaultBooksList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addDefaultBooksItem:(LibreAccessServiceSvc_DefaultBooksItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * DefaultBooksItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AssignBooksToAllUsersItem : NSObject <NSCoding> {
/* elements */
	NSString * userKey;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_AssignBooksToAllUsersItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * userKey;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AssignBooksToAllUsersList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *AssignBooksToAllUsersItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_AssignBooksToAllUsersList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addAssignBooksToAllUsersItem:(LibreAccessServiceSvc_AssignBooksToAllUsersItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * AssignBooksToAllUsersItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AssignBooksToAllUsersBooksItem : NSObject <NSCoding> {
/* elements */
	NSString * contentidentifier;
	LibreAccessServiceSvc_ContentIdentifierTypes contentIdentifierType;
	LibreAccessServiceSvc_drmqualifiers DRMQualifier;
	NSString * Format;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_AssignBooksToAllUsersBooksItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * contentidentifier;
@property (nonatomic, assign) LibreAccessServiceSvc_ContentIdentifierTypes contentIdentifierType;
@property (nonatomic, assign) LibreAccessServiceSvc_drmqualifiers DRMQualifier;
@property (nonatomic, retain) NSString * Format;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AssignBooksToAllUsersBooksList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *AssignBooksToAllUsersBooksItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_AssignBooksToAllUsersBooksList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addAssignBooksToAllUsersBooksItem:(LibreAccessServiceSvc_AssignBooksToAllUsersBooksItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * AssignBooksToAllUsersBooksItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_TokenExchange : NSObject <NSCoding> {
/* elements */
	NSString * ptoken;
	NSNumber * vaid;
	NSString * deviceKey;
	NSString * impersonationkey;
	NSString * UserName;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_TokenExchange *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * ptoken;
@property (nonatomic, retain) NSNumber * vaid;
@property (nonatomic, retain) NSString * deviceKey;
@property (nonatomic, retain) NSString * impersonationkey;
@property (nonatomic, retain) NSString * UserName;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_TokenExchangeResponse : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
	NSNumber * expiresIn;
	NSNumber * userType;
	USBoolean * deviceIsDeregistered;
	LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_TokenExchangeResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
@property (nonatomic, retain) NSNumber * expiresIn;
@property (nonatomic, retain) NSNumber * userType;
@property (nonatomic, retain) USBoolean * deviceIsDeregistered;
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_TokenExchangeEx : NSObject <NSCoding> {
/* elements */
	NSString * ptoken;
	NSNumber * vaid;
	NSString * deviceKey;
	NSString * impersonationkey;
	NSString * UserName;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_TokenExchangeEx *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * ptoken;
@property (nonatomic, retain) NSNumber * vaid;
@property (nonatomic, retain) NSString * deviceKey;
@property (nonatomic, retain) NSString * impersonationkey;
@property (nonatomic, retain) NSString * UserName;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_TokenExchangeExResponse : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
	NSNumber * expiresIn;
	NSString * userKey;
	NSNumber * userType;
	USBoolean * deviceIsDeregistered;
	USBoolean * isNewUser;
	LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_TokenExchangeExResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
@property (nonatomic, retain) NSNumber * expiresIn;
@property (nonatomic, retain) NSString * userKey;
@property (nonatomic, retain) NSNumber * userType;
@property (nonatomic, retain) USBoolean * deviceIsDeregistered;
@property (nonatomic, retain) USBoolean * isNewUser;
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_TokenExchangeExCoppaRequest : NSObject <NSCoding> {
/* elements */
	NSString * ptoken;
	NSNumber * vaid;
	NSString * deviceKey;
	NSString * impersonationkey;
	NSString * UserName;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_TokenExchangeExCoppaRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * ptoken;
@property (nonatomic, retain) NSNumber * vaid;
@property (nonatomic, retain) NSString * deviceKey;
@property (nonatomic, retain) NSString * impersonationkey;
@property (nonatomic, retain) NSString * UserName;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_TokenExchangeExCoppaResponse : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
	NSNumber * expiresIn;
	NSString * userKey;
	NSNumber * userType;
	USBoolean * deviceIsDeregistered;
	USBoolean * isNewUser;
	USBoolean * isCoppa;
	LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_TokenExchangeExCoppaResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
@property (nonatomic, retain) NSNumber * expiresIn;
@property (nonatomic, retain) NSString * userKey;
@property (nonatomic, retain) NSNumber * userType;
@property (nonatomic, retain) USBoolean * deviceIsDeregistered;
@property (nonatomic, retain) USBoolean * isNewUser;
@property (nonatomic, retain) USBoolean * isCoppa;
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SharedTokenExchangeRequest : NSObject <NSCoding> {
/* elements */
	NSString * ptoken;
	NSNumber * vaid;
	NSString * deviceKey;
	NSString * impersonationkey;
	NSString * UserName;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_SharedTokenExchangeRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * ptoken;
@property (nonatomic, retain) NSNumber * vaid;
@property (nonatomic, retain) NSString * deviceKey;
@property (nonatomic, retain) NSString * impersonationkey;
@property (nonatomic, retain) NSString * UserName;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SharedTokenExchangeResponse : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
	NSNumber * expires;
	NSNumber * expiresIn;
	NSString * ip;
	NSString * userKey;
	NSString * userhash;
	NSNumber * userType;
	USBoolean * deviceIsDeregistered;
	USBoolean * isNewUser;
	USBoolean * isCoppa;
	LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_SharedTokenExchangeResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
@property (nonatomic, retain) NSNumber * expires;
@property (nonatomic, retain) NSNumber * expiresIn;
@property (nonatomic, retain) NSString * ip;
@property (nonatomic, retain) NSString * userKey;
@property (nonatomic, retain) NSString * userhash;
@property (nonatomic, retain) NSNumber * userType;
@property (nonatomic, retain) USBoolean * deviceIsDeregistered;
@property (nonatomic, retain) USBoolean * isNewUser;
@property (nonatomic, retain) USBoolean * isCoppa;
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AuthenticateDeviceRequest : NSObject <NSCoding> {
/* elements */
	NSNumber * vaid;
	NSString * deviceKey;
	NSString * userKey;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_AuthenticateDeviceRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * vaid;
@property (nonatomic, retain) NSString * deviceKey;
@property (nonatomic, retain) NSString * userKey;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AuthenticateDeviceResponse : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
	NSNumber * expiresIn;
	USBoolean * deviceIsDeregistered;
	NSString * userKey;
	LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_AuthenticateDeviceResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
@property (nonatomic, retain) NSNumber * expiresIn;
@property (nonatomic, retain) USBoolean * deviceIsDeregistered;
@property (nonatomic, retain) NSString * userKey;
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_RenewTokenRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_RenewTokenRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_RenewTokenResponse : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
	NSNumber * expiresIn;
	NSString * userKey;
	LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_RenewTokenResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
@property (nonatomic, retain) NSNumber * expiresIn;
@property (nonatomic, retain) NSString * userKey;
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListUserContent : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ListUserContent *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_UserContentList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *UserContentItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_UserContentList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addUserContentItem:(LibreAccessServiceSvc_UserContentItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * UserContentItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListUserContentResponse : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_StatusHolder * statusmessage;
	LibreAccessServiceSvc_UserContentList * UserContentList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ListUserContentResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
@property (nonatomic, retain) LibreAccessServiceSvc_UserContentList * UserContentList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListUserContentEx : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ListUserContentEx *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_UserContentListEx : NSObject <NSCoding> {
/* elements */
	NSMutableArray *UserContentItemEx;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_UserContentListEx *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addUserContentItemEx:(LibreAccessServiceSvc_UserContentItemEx *)toAdd;
@property (nonatomic, readonly) NSMutableArray * UserContentItemEx;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListUserContentExResponse : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_StatusHolder * statusmessage;
	LibreAccessServiceSvc_UserContentListEx * UserContentListEx;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ListUserContentExResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
@property (nonatomic, retain) LibreAccessServiceSvc_UserContentListEx * UserContentListEx;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListUserContentForRatingsRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ListUserContentForRatingsRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_UserContentForRatings : NSObject <NSCoding> {
/* elements */
	NSMutableArray *UserContentForRatingsItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_UserContentForRatings *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addUserContentForRatingsItem:(LibreAccessServiceSvc_UserContentForRatingsItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * UserContentForRatingsItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListUserContentForRatingsResponse : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_StatusHolder * statusmessage;
	LibreAccessServiceSvc_UserContentForRatings * UserContentForRatings;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ListUserContentForRatingsResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
@property (nonatomic, retain) LibreAccessServiceSvc_UserContentForRatings * UserContentForRatings;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListContentMetadata : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
	USBoolean * includeurls;
	NSMutableArray *isbn13s;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ListContentMetadata *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
@property (nonatomic, retain) USBoolean * includeurls;
- (void)addIsbn13s:(LibreAccessServiceSvc_isbnItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * isbn13s;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ContentMetadataList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *ContentMetadataItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ContentMetadataList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addContentMetadataItem:(LibreAccessServiceSvc_ContentMetadataItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * ContentMetadataItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListContentMetadataResponse : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_StatusHolder * statusmessage;
	LibreAccessServiceSvc_ContentMetadataList * ContentMetadataList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ListContentMetadataResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
@property (nonatomic, retain) LibreAccessServiceSvc_ContentMetadataList * ContentMetadataList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListContentMetadataForRatingsRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
	USBoolean * includeurls;
	USBoolean * coverURLOnly;
	NSMutableArray *isbn13s;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ListContentMetadataForRatingsRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
@property (nonatomic, retain) USBoolean * includeurls;
@property (nonatomic, retain) USBoolean * coverURLOnly;
- (void)addIsbn13s:(LibreAccessServiceSvc_isbnItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * isbn13s;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ContentMetadataForRatingsList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *ContentMetadataForRatingsItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ContentMetadataForRatingsList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addContentMetadataForRatingsItem:(LibreAccessServiceSvc_ContentMetadataForRatingsItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * ContentMetadataForRatingsItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListContentMetadataForRatingsResponse : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_StatusHolder * statusmessage;
	LibreAccessServiceSvc_ContentMetadataForRatingsList * ContentMetadataForRatingsList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ListContentMetadataForRatingsResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
@property (nonatomic, retain) LibreAccessServiceSvc_ContentMetadataForRatingsList * ContentMetadataForRatingsList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_IsEntitledToLicense : NSObject <NSCoding> {
/* elements */
	NSString * input;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_IsEntitledToLicense *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * input;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_IsEntitledToLicenseResponse : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_StatusHolder * statusmessage;
	NSString * isEntitled;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_IsEntitledToLicenseResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
@property (nonatomic, retain) NSString * isEntitled;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_EntitledToLicenceRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
	NSString * contentidentifier;
	LibreAccessServiceSvc_ContentIdentifierTypes ContentIdentifierType;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_EntitledToLicenceRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
@property (nonatomic, retain) NSString * contentidentifier;
@property (nonatomic, assign) LibreAccessServiceSvc_ContentIdentifierTypes ContentIdentifierType;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SaveReadingStatisticsDetailedRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
	LibreAccessServiceSvc_ReadingStatsDetailList * ReadingStatsDetailList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_SaveReadingStatisticsDetailedRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
@property (nonatomic, retain) LibreAccessServiceSvc_ReadingStatsDetailList * ReadingStatsDetailList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SaveReadingStatisticsDetailedResponse : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_SaveReadingStatisticsDetailedResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListReadingStatisticsAggregateRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
	NSNumber * profileId;
	LibreAccessServiceSvc_aggregationPeriod aggregationPeriod;
	USBoolean * countDeletedBooks;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ListReadingStatisticsAggregateRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
@property (nonatomic, retain) NSNumber * profileId;
@property (nonatomic, assign) LibreAccessServiceSvc_aggregationPeriod aggregationPeriod;
@property (nonatomic, retain) USBoolean * countDeletedBooks;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListReadingStatisticsAggregateResponse : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_StatusHolder * statusmessage;
	LibreAccessServiceSvc_ReadingStatsAggregateList * ReadingStatsAggregateList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ListReadingStatisticsAggregateResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
@property (nonatomic, retain) LibreAccessServiceSvc_ReadingStatsAggregateList * ReadingStatsAggregateList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListReadingStatisticsDetailedRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
	NSNumber * profileId;
	NSDate * begindate;
	NSDate * enddate;
	USBoolean * countDeletedBooks;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ListReadingStatisticsDetailedRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
@property (nonatomic, retain) NSNumber * profileId;
@property (nonatomic, retain) NSDate * begindate;
@property (nonatomic, retain) NSDate * enddate;
@property (nonatomic, retain) USBoolean * countDeletedBooks;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListReadingStatisticsDetailedResponse : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_StatusHolder * statusmessage;
	LibreAccessServiceSvc_ReadingStatsDetailList * ReadingStatsDetailList;
	LibreAccessServiceSvc_ItemsCount * ItemsCount;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ListReadingStatisticsDetailedResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
@property (nonatomic, retain) LibreAccessServiceSvc_ReadingStatsDetailList * ReadingStatsDetailList;
@property (nonatomic, retain) LibreAccessServiceSvc_ItemsCount * ItemsCount;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SaveProfileContentAnnotationsRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
	LibreAccessServiceSvc_AnnotationsList * AnnotationsList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_SaveProfileContentAnnotationsRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
@property (nonatomic, retain) LibreAccessServiceSvc_AnnotationsList * AnnotationsList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SaveProfileContentAnnotationsResponse : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_StatusHolder * statusmessage;
	LibreAccessServiceSvc_AnnotationStatusList * AnnotationStatusList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_SaveProfileContentAnnotationsResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
@property (nonatomic, retain) LibreAccessServiceSvc_AnnotationStatusList * AnnotationStatusList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SaveProfileContentAnnotationsForRatingsRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
	LibreAccessServiceSvc_AnnotationsForRatingsList * AnnotationsList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_SaveProfileContentAnnotationsForRatingsRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
@property (nonatomic, retain) LibreAccessServiceSvc_AnnotationsForRatingsList * AnnotationsList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SaveProfileContentAnnotationsForRatingsResponse : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_StatusHolder * statusmessage;
	LibreAccessServiceSvc_AnnotationStatusForRatingsList * AnnotationStatusForRatingsList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_SaveProfileContentAnnotationsForRatingsResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
@property (nonatomic, retain) LibreAccessServiceSvc_AnnotationStatusForRatingsList * AnnotationStatusForRatingsList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListProfileContentAnnotationsRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
	LibreAccessServiceSvc_AnnotationsRequestList * AnnotationsRequestList;
	USBoolean * includeRemoved;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ListProfileContentAnnotationsRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
@property (nonatomic, retain) LibreAccessServiceSvc_AnnotationsRequestList * AnnotationsRequestList;
@property (nonatomic, retain) USBoolean * includeRemoved;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListProfileContentAnnotationsResponse : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_StatusHolder * statusmessage;
	LibreAccessServiceSvc_AnnotationsList * AnnotationsList;
	LibreAccessServiceSvc_ItemsCount * ItemsCount;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ListProfileContentAnnotationsResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
@property (nonatomic, retain) LibreAccessServiceSvc_AnnotationsList * AnnotationsList;
@property (nonatomic, retain) LibreAccessServiceSvc_ItemsCount * ItemsCount;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListProfileContentAnnotationsForRatingsRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
	LibreAccessServiceSvc_AnnotationsRequestListForRatings * AnnotationsRequestList;
	USBoolean * includeRemoved;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ListProfileContentAnnotationsForRatingsRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
@property (nonatomic, retain) LibreAccessServiceSvc_AnnotationsRequestListForRatings * AnnotationsRequestList;
@property (nonatomic, retain) USBoolean * includeRemoved;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListProfileContentAnnotationsForRatingsResponse : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_StatusHolder * statusmessage;
	LibreAccessServiceSvc_AnnotationsForRatingsList * AnnotationsForRatingsList;
	LibreAccessServiceSvc_ItemsCount * ItemsCount;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ListProfileContentAnnotationsForRatingsResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
@property (nonatomic, retain) LibreAccessServiceSvc_AnnotationsForRatingsList * AnnotationsForRatingsList;
@property (nonatomic, retain) LibreAccessServiceSvc_ItemsCount * ItemsCount;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_GetUserProfilesRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_GetUserProfilesRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_GetUserProfilesResponse : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_StatusHolder * statusmessage;
	LibreAccessServiceSvc_ProfileList * ProfileList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_GetUserProfilesResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
@property (nonatomic, retain) LibreAccessServiceSvc_ProfileList * ProfileList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SaveUserProfilesRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
	LibreAccessServiceSvc_SaveProfileList * SaveProfileList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_SaveUserProfilesRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
@property (nonatomic, retain) LibreAccessServiceSvc_SaveProfileList * SaveProfileList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SaveUserProfilesResponse : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_StatusHolder * statusmessage;
	LibreAccessServiceSvc_ProfileStatusList * ProfileStatusList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_SaveUserProfilesResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
@property (nonatomic, retain) LibreAccessServiceSvc_ProfileStatusList * ProfileStatusList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListApplicationSettingsRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ListApplicationSettingsRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListApplicationSettingsResponse : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_StatusHolder * statusmessage;
	LibreAccessServiceSvc_ApplicationSettingList * SettingsList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ListApplicationSettingsResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
@property (nonatomic, retain) LibreAccessServiceSvc_ApplicationSettingList * SettingsList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SaveContentProfileAssignmentRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
	LibreAccessServiceSvc_ContentProfileAssignmentList * ContentProfileAssignmentList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_SaveContentProfileAssignmentRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
@property (nonatomic, retain) LibreAccessServiceSvc_ContentProfileAssignmentList * ContentProfileAssignmentList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SaveContentProfileAssignmentResponse : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_SaveContentProfileAssignmentResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListTopFavoritesRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
	NSNumber * count;
	LibreAccessServiceSvc_TopFavoritesRequestList * TopFavoritesRequestList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ListTopFavoritesRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
@property (nonatomic, retain) NSNumber * count;
@property (nonatomic, retain) LibreAccessServiceSvc_TopFavoritesRequestList * TopFavoritesRequestList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListTopFavoritesResponse : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_StatusHolder * statusmessage;
	LibreAccessServiceSvc_TopFavoritesResponseList * TopFavoritesResponseList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ListTopFavoritesResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
@property (nonatomic, retain) LibreAccessServiceSvc_TopFavoritesResponseList * TopFavoritesResponseList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_GetDeviceInfoRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_GetDeviceInfoRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_GetDeviceInfoResponse : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_StatusHolder * statusmessage;
	LibreAccessServiceSvc_DeviceList * DeviceInfoList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_GetDeviceInfoResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
@property (nonatomic, retain) LibreAccessServiceSvc_DeviceList * DeviceInfoList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SaveDeviceInfoRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
	LibreAccessServiceSvc_DeviceList * SaveDeviceList;
	LibreAccessServiceSvc_SaveActions action;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_SaveDeviceInfoRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
@property (nonatomic, retain) LibreAccessServiceSvc_DeviceList * SaveDeviceList;
@property (nonatomic, assign) LibreAccessServiceSvc_SaveActions action;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SaveDeviceInfoResponse : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_SaveDeviceInfoResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SaveNewDomainResponse : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_SaveNewDomainResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SaveNewDomainRequest : NSObject <NSCoding> {
/* elements */
	NSString * authToken;
	NSString * AccountId;
	NSNumber * Revision;
	NSString * DomainKeyPair;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_SaveNewDomainRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authToken;
@property (nonatomic, retain) NSString * AccountId;
@property (nonatomic, retain) NSNumber * Revision;
@property (nonatomic, retain) NSString * DomainKeyPair;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_DeviceLeftDomainResponse : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_DeviceLeftDomainResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_DeviceLeftDomainRequest : NSObject <NSCoding> {
/* elements */
	NSString * Authtoken;
	NSString * DeviceKey;
	NSString * ClientId;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_DeviceLeftDomainRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * Authtoken;
@property (nonatomic, retain) NSString * DeviceKey;
@property (nonatomic, retain) NSString * ClientId;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_DeviceCanJoinDomainResponse : NSObject <NSCoding> {
/* elements */
	NSString * AccountId;
	NSString * DomainKeyPair;
	NSNumber * Revision;
	LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_DeviceCanJoinDomainResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * AccountId;
@property (nonatomic, retain) NSString * DomainKeyPair;
@property (nonatomic, retain) NSNumber * Revision;
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_DeviceCanJoinDomainRequest : NSObject <NSCoding> {
/* elements */
	NSString * authToken;
	NSString * DeviceNickname;
	NSString * DevicePlatform;
	NSString * DeviceKey;
	NSString * ClientId;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_DeviceCanJoinDomainRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authToken;
@property (nonatomic, retain) NSString * DeviceNickname;
@property (nonatomic, retain) NSString * DevicePlatform;
@property (nonatomic, retain) NSString * DeviceKey;
@property (nonatomic, retain) NSString * ClientId;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_GetLicensableStatusResponse : NSObject <NSCoding> {
/* elements */
	NSString * AccountId;
	NSNumber * Revision;
	LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_GetLicensableStatusResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * AccountId;
@property (nonatomic, retain) NSNumber * Revision;
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_GetLicensableStatusRequest : NSObject <NSCoding> {
/* elements */
	NSString * authToken;
	NSString * KeyId;
	NSString * suppliedIdentifier;
	NSString * suppliedIdentifierType;
	NSString * TransactionId;
	NSString * ClientId;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_GetLicensableStatusRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authToken;
@property (nonatomic, retain) NSString * KeyId;
@property (nonatomic, retain) NSString * suppliedIdentifier;
@property (nonatomic, retain) NSString * suppliedIdentifierType;
@property (nonatomic, retain) NSString * TransactionId;
@property (nonatomic, retain) NSString * ClientId;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AcknowledgeLicenseResponse : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_AcknowledgeLicenseResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AcknowledgeLicenseRequest : NSObject <NSCoding> {
/* elements */
	NSString * TransactionId;
	NSString * ClientId;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_AcknowledgeLicenseRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * TransactionId;
@property (nonatomic, retain) NSString * ClientId;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ValidateScreenNameRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
	NSString * screenName;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ValidateScreenNameRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
@property (nonatomic, retain) NSString * screenName;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ValidateScreenNameResponse : NSObject <NSCoding> {
/* elements */
	USBoolean * result;
	LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ValidateScreenNameResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) USBoolean * result;
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ValidateUserKeyRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
	NSString * userKey;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ValidateUserKeyRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
@property (nonatomic, retain) NSString * userKey;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ValidateUserKeyResponse : NSObject <NSCoding> {
/* elements */
	USBoolean * result;
	LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ValidateUserKeyResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) USBoolean * result;
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_DeleteBookShelfEntryRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
	LibreAccessServiceSvc_BookshelfEntryList * BookShelfEntryList;
	USBoolean * cascade;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_DeleteBookShelfEntryRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
@property (nonatomic, retain) LibreAccessServiceSvc_BookshelfEntryList * BookShelfEntryList;
@property (nonatomic, retain) USBoolean * cascade;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_DeleteBookShelfEntryResponse : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_DeleteBookShelfEntryResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_GetLastPageLocationRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_GetLastPageLocationRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_GetLastPageLocationResponse : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_ProfileBookshelfEntryList * ProfileBookshelfEntryList;
	LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_GetLastPageLocationResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessServiceSvc_ProfileBookshelfEntryList * ProfileBookshelfEntryList;
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SaveLastPageLocationRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
	LibreAccessServiceSvc_ProfileBookshelfEntryList * ProfileBookshelfEntryList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_SaveLastPageLocationRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
@property (nonatomic, retain) LibreAccessServiceSvc_ProfileBookshelfEntryList * ProfileBookshelfEntryList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SaveLastPageLocationResponse : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_SaveLastPageLocationResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListFavoriteTypesRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ListFavoriteTypesRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListFavoriteTypesResponse : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_StatusHolder * statusmessage;
	LibreAccessServiceSvc_FavoriteTypesList * FavoriteTypesList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ListFavoriteTypesResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
@property (nonatomic, retain) LibreAccessServiceSvc_FavoriteTypesList * FavoriteTypesList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SaveUserSettingsRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
	LibreAccessServiceSvc_UserSettingsList * UserSettingsList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_SaveUserSettingsRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
@property (nonatomic, retain) LibreAccessServiceSvc_UserSettingsList * UserSettingsList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SaveUserSettingsResponse : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_SaveUserSettingsResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SaveUserSettingsExRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
	LibreAccessServiceSvc_SettingsList * settingsList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_SaveUserSettingsExRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
@property (nonatomic, retain) LibreAccessServiceSvc_SettingsList * settingsList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SaveUserSettingsExResponse : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_StatusHolder * statusmessage;
	LibreAccessServiceSvc_SettingStatusList * settingStatusList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_SaveUserSettingsExResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
@property (nonatomic, retain) LibreAccessServiceSvc_SettingStatusList * settingStatusList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListUserSettingsRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ListUserSettingsRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListUserSettingsResponse : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_StatusHolder * statusmessage;
	LibreAccessServiceSvc_UserSettingsList * UserSettingsList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ListUserSettingsResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
@property (nonatomic, retain) LibreAccessServiceSvc_UserSettingsList * UserSettingsList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListUserSettingsExRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ListUserSettingsExRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListUserSettingsExResponse : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_StatusHolder * statusmessage;
	LibreAccessServiceSvc_SettingsList * settingsList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ListUserSettingsExResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
@property (nonatomic, retain) LibreAccessServiceSvc_SettingsList * settingsList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SetAccountAutoAssignRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
	LibreAccessServiceSvc_AutoAssignProfilesList * AutoAssignProfilesList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_SetAccountAutoAssignRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
@property (nonatomic, retain) LibreAccessServiceSvc_AutoAssignProfilesList * AutoAssignProfilesList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SetAccountAutoAssignResponse : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_SetAccountAutoAssignResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SetAccountPasswordRequiredRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
	USBoolean * passwordRequired;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_SetAccountPasswordRequiredRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
@property (nonatomic, retain) USBoolean * passwordRequired;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SetAccountPasswordRequiredResponse : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_SetAccountPasswordRequiredResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListReadBooksRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ListReadBooksRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListReadBooksResponse : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_StatusHolder * statusmessage;
	LibreAccessServiceSvc_ReadBooksList * ReadBooksList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ListReadBooksResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
@property (nonatomic, retain) LibreAccessServiceSvc_ReadBooksList * ReadBooksList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListLastNProfileReadBooksRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
	NSNumber * lastBooksCount;
	USBoolean * uniqueBooks;
	LibreAccessServiceSvc_LastNRequestReadBooksProfilesList * LastNRequestReadBooksProfilesList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ListLastNProfileReadBooksRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
@property (nonatomic, retain) NSNumber * lastBooksCount;
@property (nonatomic, retain) USBoolean * uniqueBooks;
@property (nonatomic, retain) LibreAccessServiceSvc_LastNRequestReadBooksProfilesList * LastNRequestReadBooksProfilesList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListLastNProfileReadBooksResponse : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_StatusHolder * statusmessage;
	LibreAccessServiceSvc_LastNResponseReadBooksProfilesList * LastNResponseReadBooksProfilesList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ListLastNProfileReadBooksResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
@property (nonatomic, retain) LibreAccessServiceSvc_LastNResponseReadBooksProfilesList * LastNResponseReadBooksProfilesList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListLastNWordsRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
	NSNumber * lastWordsCount;
	NSDate * startDate;
	NSDate * endDate;
	LibreAccessServiceSvc_LastNRequestWordsList * LastNRequestWordsList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ListLastNWordsRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
@property (nonatomic, retain) NSNumber * lastWordsCount;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) LibreAccessServiceSvc_LastNRequestWordsList * LastNRequestWordsList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListLastNWordsResponse : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_StatusHolder * statusmessage;
	LibreAccessServiceSvc_LastNResponseWordsList * LastNResponseWordsList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ListLastNWordsResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
@property (nonatomic, retain) LibreAccessServiceSvc_LastNResponseWordsList * LastNResponseWordsList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_RemoveOrderRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
	NSString * userKey;
	NSString * orderID;
	NSString * contentidentifier;
	LibreAccessServiceSvc_ContentIdentifierTypes contentIdentifierType;
	LibreAccessServiceSvc_drmqualifiers DRMQualifier;
	NSString * Format;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_RemoveOrderRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
@property (nonatomic, retain) NSString * userKey;
@property (nonatomic, retain) NSString * orderID;
@property (nonatomic, retain) NSString * contentidentifier;
@property (nonatomic, assign) LibreAccessServiceSvc_ContentIdentifierTypes contentIdentifierType;
@property (nonatomic, assign) LibreAccessServiceSvc_drmqualifiers DRMQualifier;
@property (nonatomic, retain) NSString * Format;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_RemoveOrderResponse : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_RemoveOrderResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SaveUserCSRNotesRequest : NSObject <NSCoding> {
/* elements */
	NSString * CSRtoken;
	NSString * userKey;
	NSString * noteText;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_SaveUserCSRNotesRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * CSRtoken;
@property (nonatomic, retain) NSString * userKey;
@property (nonatomic, retain) NSString * noteText;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SaveUserCSRNotesResponse : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_SaveUserCSRNotesResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListUserCSRNotesRequest : NSObject <NSCoding> {
/* elements */
	NSString * CSRtoken;
	NSString * userKey;
	NSNumber * lastNNotes;
	NSDate * startDate;
	NSDate * endDate;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ListUserCSRNotesRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * CSRtoken;
@property (nonatomic, retain) NSString * userKey;
@property (nonatomic, retain) NSNumber * lastNNotes;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSDate * endDate;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListUserCSRNotesResponse : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_StatusHolder * statusmessage;
	LibreAccessServiceSvc_NotesList * notesList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ListUserCSRNotesResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
@property (nonatomic, retain) LibreAccessServiceSvc_NotesList * notesList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_GetKeyIdRequest : NSObject <NSCoding> {
/* elements */
	NSString * contentidentifier;
	LibreAccessServiceSvc_ContentIdentifierTypes contentIdentifierType;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_GetKeyIdRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * contentidentifier;
@property (nonatomic, assign) LibreAccessServiceSvc_ContentIdentifierTypes contentIdentifierType;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_GetKeyIdResponse : NSObject <NSCoding> {
/* elements */
	NSString * guid;
	LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_GetKeyIdResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SaveDefaultBooksRequest : NSObject <NSCoding> {
/* elements */
	NSString * CSRtoken;
	LibreAccessServiceSvc_DefaultBooksList * BooksList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_SaveDefaultBooksRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * CSRtoken;
@property (nonatomic, retain) LibreAccessServiceSvc_DefaultBooksList * BooksList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SaveDefaultBooksResponse : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_SaveDefaultBooksResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListDefaultBooksRequest : NSObject <NSCoding> {
/* elements */
	NSString * authToken;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ListDefaultBooksRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authToken;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListDefaultBooksResponse : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_StatusHolder * statusmessage;
	LibreAccessServiceSvc_DefaultBooksList * BooksList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ListDefaultBooksResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
@property (nonatomic, retain) LibreAccessServiceSvc_DefaultBooksList * BooksList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_RemoveDefaultBooksRequest : NSObject <NSCoding> {
/* elements */
	NSString * CSRtoken;
	LibreAccessServiceSvc_DefaultBooksList * BooksList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_RemoveDefaultBooksRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * CSRtoken;
@property (nonatomic, retain) LibreAccessServiceSvc_DefaultBooksList * BooksList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_RemoveDefaultBooksResponse : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_RemoveDefaultBooksResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AssignBooksToAllUsersRequest : NSObject <NSCoding> {
/* elements */
	NSString * CSRtoken;
	LibreAccessServiceSvc_AssignBooksToAllUsersList * UsersList;
	LibreAccessServiceSvc_AssignBooksToAllUsersBooksList * BooksList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_AssignBooksToAllUsersRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * CSRtoken;
@property (nonatomic, retain) LibreAccessServiceSvc_AssignBooksToAllUsersList * UsersList;
@property (nonatomic, retain) LibreAccessServiceSvc_AssignBooksToAllUsersBooksList * BooksList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AssignBooksToAllUsersResponse : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_AssignBooksToAllUsersResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SetLoggingLevelRequest : NSObject <NSCoding> {
/* elements */
	NSString * CSRtoken;
	NSString * Level;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_SetLoggingLevelRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * CSRtoken;
@property (nonatomic, retain) NSString * Level;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SetLoggingLevelResponse : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_SetLoggingLevelResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_EndpointsList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *Endpoint;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_EndpointsList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addEndpoint:(NSString *)toAdd;
@property (nonatomic, readonly) NSMutableArray * Endpoint;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_DBSchemaError : NSObject <NSCoding> {
/* elements */
	NSDate * lastDBModify;
	LibreAccessServiceSvc_DBSchemaErrorList * errorList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_DBSchemaError *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSDate * lastDBModify;
@property (nonatomic, retain) LibreAccessServiceSvc_DBSchemaErrorList * errorList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_HealthCheckResponse : NSObject <NSCoding> {
/* elements */
	NSNumber * statusCode;
	NSString * datapipe;
	NSString * gatewayDatabase;
	NSString * activityLogDatabase;
	LibreAccessServiceSvc_EndpointsList * endpoints;
	NSString * currentDBVersion;
	NSString * LAversion;
	LibreAccessServiceSvc_DBSchemaError * DBSchemaErrors;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_HealthCheckResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * statusCode;
@property (nonatomic, retain) NSString * datapipe;
@property (nonatomic, retain) NSString * gatewayDatabase;
@property (nonatomic, retain) NSString * activityLogDatabase;
@property (nonatomic, retain) LibreAccessServiceSvc_EndpointsList * endpoints;
@property (nonatomic, retain) NSString * currentDBVersion;
@property (nonatomic, retain) NSString * LAversion;
@property (nonatomic, retain) LibreAccessServiceSvc_DBSchemaError * DBSchemaErrors;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_UserKeysList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *userKey;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_UserKeysList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addUserKey:(NSString *)toAdd;
@property (nonatomic, readonly) NSMutableArray * userKey;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListAvailableDumps : NSObject <NSCoding> {
/* elements */
	NSString * CSRtoken;
	LibreAccessServiceSvc_UserKeysList * userKeysList;
	NSDate * minTimestamp;
	NSDate * maxTimestamp;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ListAvailableDumps *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * CSRtoken;
@property (nonatomic, retain) LibreAccessServiceSvc_UserKeysList * userKeysList;
@property (nonatomic, retain) NSDate * minTimestamp;
@property (nonatomic, retain) NSDate * maxTimestamp;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_DumpItemAvailable : NSObject <NSCoding> {
/* elements */
	NSString * userKey;
	NSString * deviceKey;
	NSDate * timestamp;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_DumpItemAvailable *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * userKey;
@property (nonatomic, retain) NSString * deviceKey;
@property (nonatomic, retain) NSDate * timestamp;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_DumpListAvailable : NSObject <NSCoding> {
/* elements */
	NSMutableArray *dumpItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_DumpListAvailable *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addDumpItem:(LibreAccessServiceSvc_DumpItemAvailable *)toAdd;
@property (nonatomic, readonly) NSMutableArray * dumpItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListAvailableDumpsResponse : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_StatusHolder * statusmessage;
	LibreAccessServiceSvc_DumpListAvailable * dumpItems;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ListAvailableDumpsResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
@property (nonatomic, retain) LibreAccessServiceSvc_DumpListAvailable * dumpItems;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_GetVersionRequest : NSObject <NSCoding> {
/* elements */
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_GetVersionRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_GetVersionResponse : NSObject <NSCoding> {
/* elements */
	NSString * version;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_GetVersionResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * version;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListTopRatingsRequest : NSObject <NSCoding> {
/* elements */
	NSString * authToken;
	NSNumber * count;
	LibreAccessServiceSvc_TopRatingsRequestList * topRatingsRequestList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ListTopRatingsRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authToken;
@property (nonatomic, retain) NSNumber * count;
@property (nonatomic, retain) LibreAccessServiceSvc_TopRatingsRequestList * topRatingsRequestList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListTopRatingsResponse : NSObject <NSCoding> {
/* elements */
	LibreAccessServiceSvc_StatusHolder * statusMessage;
	LibreAccessServiceSvc_TopRatingsResponseList * topRatingsResponseList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_ListTopRatingsResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessServiceSvc_StatusHolder * statusMessage;
@property (nonatomic, retain) LibreAccessServiceSvc_TopRatingsResponseList * topRatingsResponseList;
/* attributes */
- (NSDictionary *)attributes;
@end
/* Cookies handling provided by http://en.wikibooks.org/wiki/Programming:WebObjects/Web_Services/Web_Service_Provider */
#import <libxml/parser.h>
#import "xsd.h"
#import "LibreAccessServiceSvc.h"
@class LibreAccessServiceSoap11Binding;
@interface LibreAccessServiceSvc : NSObject {
	
}
+ (LibreAccessServiceSoap11Binding *)LibreAccessServiceSoap11Binding;
@end
@class LibreAccessServiceSoap11BindingResponse;
@class LibreAccessServiceSoap11BindingOperation;
@protocol LibreAccessServiceSoap11BindingResponseDelegate <NSObject>
- (void) operation:(LibreAccessServiceSoap11BindingOperation *)operation completedWithResponse:(LibreAccessServiceSoap11BindingResponse *)response;
@end
@interface LibreAccessServiceSoap11Binding : NSObject <LibreAccessServiceSoap11BindingResponseDelegate> {
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
- (void)sendHTTPCallUsingBody:(NSString *)body soapAction:(NSString *)soapAction forOperation:(LibreAccessServiceSoap11BindingOperation *)operation;
- (void)addCookie:(NSHTTPCookie *)toAdd;
- (NSString *)MIMEType;
- (LibreAccessServiceSoap11BindingResponse *)ValidateScreenNameUsingParameters:(LibreAccessServiceSvc_ValidateScreenNameRequest *)aParameters ;
- (void)ValidateScreenNameAsyncUsingParameters:(LibreAccessServiceSvc_ValidateScreenNameRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)ListProfileContentAnnotationsForRatingsUsingParameters:(LibreAccessServiceSvc_ListProfileContentAnnotationsForRatingsRequest *)aParameters ;
- (void)ListProfileContentAnnotationsForRatingsAsyncUsingParameters:(LibreAccessServiceSvc_ListProfileContentAnnotationsForRatingsRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)ValidateUserKeyUsingParameters:(LibreAccessServiceSvc_ValidateUserKeyRequest *)aParameters ;
- (void)ValidateUserKeyAsyncUsingParameters:(LibreAccessServiceSvc_ValidateUserKeyRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)AcknowledgeLicenseUsingParameters:(LibreAccessServiceSvc_AcknowledgeLicenseRequest *)aParameters ;
- (void)AcknowledgeLicenseAsyncUsingParameters:(LibreAccessServiceSvc_AcknowledgeLicenseRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)SharedTokenExchangeUsingBody:(LibreAccessServiceSvc_SharedTokenExchangeRequest *)aBody ;
- (void)SharedTokenExchangeAsyncUsingBody:(LibreAccessServiceSvc_SharedTokenExchangeRequest *)aBody  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)SaveUserCSRNotesUsingParameters:(LibreAccessServiceSvc_SaveUserCSRNotesRequest *)aParameters ;
- (void)SaveUserCSRNotesAsyncUsingParameters:(LibreAccessServiceSvc_SaveUserCSRNotesRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)HealthCheck:(id)noParameters;
- (void)HealthCheckAsync:(id)noParameters delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)SaveNewDomainUsingParameters:(LibreAccessServiceSvc_SaveNewDomainRequest *)aParameters ;
- (void)SaveNewDomainAsyncUsingParameters:(LibreAccessServiceSvc_SaveNewDomainRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)ListDefaultBooksUsingParameters:(LibreAccessServiceSvc_ListDefaultBooksRequest *)aParameters ;
- (void)ListDefaultBooksAsyncUsingParameters:(LibreAccessServiceSvc_ListDefaultBooksRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)ListReadingStatisticsDetailedUsingParameters:(LibreAccessServiceSvc_ListReadingStatisticsDetailedRequest *)aParameters ;
- (void)ListReadingStatisticsDetailedAsyncUsingParameters:(LibreAccessServiceSvc_ListReadingStatisticsDetailedRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)DeviceCanJoinDomainUsingParameters:(LibreAccessServiceSvc_DeviceCanJoinDomainRequest *)aParameters ;
- (void)DeviceCanJoinDomainAsyncUsingParameters:(LibreAccessServiceSvc_DeviceCanJoinDomainRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)AssignBooksToAllUsersUsingParameters:(LibreAccessServiceSvc_AssignBooksToAllUsersRequest *)aParameters ;
- (void)AssignBooksToAllUsersAsyncUsingParameters:(LibreAccessServiceSvc_AssignBooksToAllUsersRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)SaveProfileContentAnnotationsForRatingsUsingParameters:(LibreAccessServiceSvc_SaveProfileContentAnnotationsForRatingsRequest *)aParameters ;
- (void)SaveProfileContentAnnotationsForRatingsAsyncUsingParameters:(LibreAccessServiceSvc_SaveProfileContentAnnotationsForRatingsRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)ListUserSettingsExUsingParameters:(LibreAccessServiceSvc_ListUserSettingsExRequest *)aParameters ;
- (void)ListUserSettingsExAsyncUsingParameters:(LibreAccessServiceSvc_ListUserSettingsExRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)ListUserContentForRatingsUsingBody:(LibreAccessServiceSvc_ListUserContentForRatingsRequest *)aBody ;
- (void)ListUserContentForRatingsAsyncUsingBody:(LibreAccessServiceSvc_ListUserContentForRatingsRequest *)aBody  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)GetLastPageLocationUsingParameters:(LibreAccessServiceSvc_GetLastPageLocationRequest *)aParameters ;
- (void)GetLastPageLocationAsyncUsingParameters:(LibreAccessServiceSvc_GetLastPageLocationRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)SaveProfileContentAnnotationsUsingParameters:(LibreAccessServiceSvc_SaveProfileContentAnnotationsRequest *)aParameters ;
- (void)SaveProfileContentAnnotationsAsyncUsingParameters:(LibreAccessServiceSvc_SaveProfileContentAnnotationsRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)RemoveDefaultBooksUsingParameters:(LibreAccessServiceSvc_RemoveDefaultBooksRequest *)aParameters ;
- (void)RemoveDefaultBooksAsyncUsingParameters:(LibreAccessServiceSvc_RemoveDefaultBooksRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)GetLicensableStatusUsingParameters:(LibreAccessServiceSvc_GetLicensableStatusRequest *)aParameters ;
- (void)GetLicensableStatusAsyncUsingParameters:(LibreAccessServiceSvc_GetLicensableStatusRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)SaveLastPageLocationUsingParameters:(LibreAccessServiceSvc_SaveLastPageLocationRequest *)aParameters ;
- (void)SaveLastPageLocationAsyncUsingParameters:(LibreAccessServiceSvc_SaveLastPageLocationRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)ListUserCSRNotesUsingParameters:(LibreAccessServiceSvc_ListUserCSRNotesRequest *)aParameters ;
- (void)ListUserCSRNotesAsyncUsingParameters:(LibreAccessServiceSvc_ListUserCSRNotesRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)RenewTokenUsingBody:(LibreAccessServiceSvc_RenewTokenRequest *)aBody ;
- (void)RenewTokenAsyncUsingBody:(LibreAccessServiceSvc_RenewTokenRequest *)aBody  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)SaveDeviceInfoUsingParameters:(LibreAccessServiceSvc_SaveDeviceInfoRequest *)aParameters ;
- (void)SaveDeviceInfoAsyncUsingParameters:(LibreAccessServiceSvc_SaveDeviceInfoRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)ListReadingStatisticsAggregateUsingParameters:(LibreAccessServiceSvc_ListReadingStatisticsAggregateRequest *)aParameters ;
- (void)ListReadingStatisticsAggregateAsyncUsingParameters:(LibreAccessServiceSvc_ListReadingStatisticsAggregateRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)ListTopRatingsUsingParameters:(LibreAccessServiceSvc_ListTopRatingsRequest *)aParameters ;
- (void)ListTopRatingsAsyncUsingParameters:(LibreAccessServiceSvc_ListTopRatingsRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)ListLastNWordsUsingParameters:(LibreAccessServiceSvc_ListLastNWordsRequest *)aParameters ;
- (void)ListLastNWordsAsyncUsingParameters:(LibreAccessServiceSvc_ListLastNWordsRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)TokenExchangeExUsingBody:(LibreAccessServiceSvc_TokenExchangeEx *)aBody ;
- (void)TokenExchangeExAsyncUsingBody:(LibreAccessServiceSvc_TokenExchangeEx *)aBody  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)DeviceLeftDomainUsingParameters:(LibreAccessServiceSvc_DeviceLeftDomainRequest *)aParameters ;
- (void)DeviceLeftDomainAsyncUsingParameters:(LibreAccessServiceSvc_DeviceLeftDomainRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)ListReadBooksUsingParameters:(LibreAccessServiceSvc_ListReadBooksRequest *)aParameters ;
- (void)ListReadBooksAsyncUsingParameters:(LibreAccessServiceSvc_ListReadBooksRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)GetDeviceInfoUsingParameters:(LibreAccessServiceSvc_GetDeviceInfoRequest *)aParameters ;
- (void)GetDeviceInfoAsyncUsingParameters:(LibreAccessServiceSvc_GetDeviceInfoRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)SaveReadingStatisticsDetailedUsingParameters:(LibreAccessServiceSvc_SaveReadingStatisticsDetailedRequest *)aParameters ;
- (void)SaveReadingStatisticsDetailedAsyncUsingParameters:(LibreAccessServiceSvc_SaveReadingStatisticsDetailedRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)SaveContentProfileAssignmentUsingParameters:(LibreAccessServiceSvc_SaveContentProfileAssignmentRequest *)aParameters ;
- (void)SaveContentProfileAssignmentAsyncUsingParameters:(LibreAccessServiceSvc_SaveContentProfileAssignmentRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)TokenExchangeUsingBody:(LibreAccessServiceSvc_TokenExchange *)aBody ;
- (void)TokenExchangeAsyncUsingBody:(LibreAccessServiceSvc_TokenExchange *)aBody  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)SetAccountPasswordRequiredUsingParameters:(LibreAccessServiceSvc_SetAccountPasswordRequiredRequest *)aParameters ;
- (void)SetAccountPasswordRequiredAsyncUsingParameters:(LibreAccessServiceSvc_SetAccountPasswordRequiredRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)GetVersionUsingParameters:(LibreAccessServiceSvc_GetVersionRequest *)aParameters ;
- (void)GetVersionAsyncUsingParameters:(LibreAccessServiceSvc_GetVersionRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)ListUserContentExUsingBody:(LibreAccessServiceSvc_ListUserContentEx *)aBody ;
- (void)ListUserContentExAsyncUsingBody:(LibreAccessServiceSvc_ListUserContentEx *)aBody  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)SaveUserSettingsUsingParameters:(LibreAccessServiceSvc_SaveUserSettingsRequest *)aParameters ;
- (void)SaveUserSettingsAsyncUsingParameters:(LibreAccessServiceSvc_SaveUserSettingsRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)TokenExchangeExCoppaUsingBody:(LibreAccessServiceSvc_TokenExchangeExCoppaRequest *)aBody ;
- (void)TokenExchangeExCoppaAsyncUsingBody:(LibreAccessServiceSvc_TokenExchangeExCoppaRequest *)aBody  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)AuthenticateDeviceUsingBody:(LibreAccessServiceSvc_AuthenticateDeviceRequest *)aBody ;
- (void)AuthenticateDeviceAsyncUsingBody:(LibreAccessServiceSvc_AuthenticateDeviceRequest *)aBody  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)ListContentMetadataUsingBody:(LibreAccessServiceSvc_ListContentMetadata *)aBody ;
- (void)ListContentMetadataAsyncUsingBody:(LibreAccessServiceSvc_ListContentMetadata *)aBody  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)ListApplicationSettingsUsingParameters:(LibreAccessServiceSvc_ListApplicationSettingsRequest *)aParameters ;
- (void)ListApplicationSettingsAsyncUsingParameters:(LibreAccessServiceSvc_ListApplicationSettingsRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)ListTopFavoritesUsingParameters:(LibreAccessServiceSvc_ListTopFavoritesRequest *)aParameters ;
- (void)ListTopFavoritesAsyncUsingParameters:(LibreAccessServiceSvc_ListTopFavoritesRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)ListLastNProfileReadBooksUsingParameters:(LibreAccessServiceSvc_ListLastNProfileReadBooksRequest *)aParameters ;
- (void)ListLastNProfileReadBooksAsyncUsingParameters:(LibreAccessServiceSvc_ListLastNProfileReadBooksRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)SaveUserProfilesUsingParameters:(LibreAccessServiceSvc_SaveUserProfilesRequest *)aParameters ;
- (void)SaveUserProfilesAsyncUsingParameters:(LibreAccessServiceSvc_SaveUserProfilesRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)GetUserProfilesUsingParameters:(LibreAccessServiceSvc_GetUserProfilesRequest *)aParameters ;
- (void)GetUserProfilesAsyncUsingParameters:(LibreAccessServiceSvc_GetUserProfilesRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)DeleteBookShelfEntryUsingParameters:(LibreAccessServiceSvc_DeleteBookShelfEntryRequest *)aParameters ;
- (void)DeleteBookShelfEntryAsyncUsingParameters:(LibreAccessServiceSvc_DeleteBookShelfEntryRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)SetLoggingLevelUsingParameters:(LibreAccessServiceSvc_SetLoggingLevelRequest *)aParameters ;
- (void)SetLoggingLevelAsyncUsingParameters:(LibreAccessServiceSvc_SetLoggingLevelRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)SaveUserSettingsExUsingParameters:(LibreAccessServiceSvc_SaveUserSettingsExRequest *)aParameters ;
- (void)SaveUserSettingsExAsyncUsingParameters:(LibreAccessServiceSvc_SaveUserSettingsExRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)ListUserSettingsUsingParameters:(LibreAccessServiceSvc_ListUserSettingsRequest *)aParameters ;
- (void)ListUserSettingsAsyncUsingParameters:(LibreAccessServiceSvc_ListUserSettingsRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)IsEntitledToLicenseUsingParameters:(LibreAccessServiceSvc_EntitledToLicenceRequest *)aParameters ;
- (void)IsEntitledToLicenseAsyncUsingParameters:(LibreAccessServiceSvc_EntitledToLicenceRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)RemoveOrderUsingParameters:(LibreAccessServiceSvc_RemoveOrderRequest *)aParameters ;
- (void)RemoveOrderAsyncUsingParameters:(LibreAccessServiceSvc_RemoveOrderRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)ListProfileContentAnnotationsUsingParameters:(LibreAccessServiceSvc_ListProfileContentAnnotationsRequest *)aParameters ;
- (void)ListProfileContentAnnotationsAsyncUsingParameters:(LibreAccessServiceSvc_ListProfileContentAnnotationsRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)ListUserContentUsingBody:(LibreAccessServiceSvc_ListUserContent *)aBody ;
- (void)ListUserContentAsyncUsingBody:(LibreAccessServiceSvc_ListUserContent *)aBody  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)ListAvailableDumpsUsingParameters:(LibreAccessServiceSvc_ListAvailableDumps *)aParameters ;
- (void)ListAvailableDumpsAsyncUsingParameters:(LibreAccessServiceSvc_ListAvailableDumps *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)SaveDefaultBooksUsingParameters:(LibreAccessServiceSvc_SaveDefaultBooksRequest *)aParameters ;
- (void)SaveDefaultBooksAsyncUsingParameters:(LibreAccessServiceSvc_SaveDefaultBooksRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)ListFavoriteTypesUsingParameters:(LibreAccessServiceSvc_ListFavoriteTypesRequest *)aParameters ;
- (void)ListFavoriteTypesAsyncUsingParameters:(LibreAccessServiceSvc_ListFavoriteTypesRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)ListContentMetadataForRatingsUsingBody:(LibreAccessServiceSvc_ListContentMetadataForRatingsRequest *)aBody ;
- (void)ListContentMetadataForRatingsAsyncUsingBody:(LibreAccessServiceSvc_ListContentMetadataForRatingsRequest *)aBody  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)GetKeyIdUsingParameters:(LibreAccessServiceSvc_GetKeyIdRequest *)aParameters ;
- (void)GetKeyIdAsyncUsingParameters:(LibreAccessServiceSvc_GetKeyIdRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)SetAccountAutoAssignUsingParameters:(LibreAccessServiceSvc_SetAccountAutoAssignRequest *)aParameters ;
- (void)SetAccountAutoAssignAsyncUsingParameters:(LibreAccessServiceSvc_SetAccountAutoAssignRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (void)addPointerForOperation:(LibreAccessServiceSoap11BindingOperation *)operation;
- (void)removePointerForOperation:(LibreAccessServiceSoap11BindingOperation *)operation;
- (void)clearBindingOperations;
@end
@interface LibreAccessServiceSoap11BindingOperation : NSOperation {
	LibreAccessServiceSoap11Binding *binding;
	LibreAccessServiceSoap11BindingResponse *response;
	id<LibreAccessServiceSoap11BindingResponseDelegate> delegate;
	NSDictionary *responseHeaders;	
	NSMutableData *responseData;
	NSURLConnection *urlConnection;
}
@property (nonatomic, retain) LibreAccessServiceSoap11Binding *binding;
@property (nonatomic, readonly) LibreAccessServiceSoap11BindingResponse *response;
@property (nonatomic, assign) id<LibreAccessServiceSoap11BindingResponseDelegate> delegate;
@property (nonatomic, retain) NSDictionary *responseHeaders;
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, assign) NSTimeInterval serverDateDelta;
@property (nonatomic, retain) NSURLConnection *urlConnection;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)clear;
@end
@interface LibreAccessServiceSoap11Binding_ValidateScreenName : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_ValidateScreenNameRequest * parameters;
}
@property (nonatomic, retain) LibreAccessServiceSvc_ValidateScreenNameRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_ValidateScreenNameRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_ListProfileContentAnnotationsForRatings : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_ListProfileContentAnnotationsForRatingsRequest * parameters;
}
@property (nonatomic, retain) LibreAccessServiceSvc_ListProfileContentAnnotationsForRatingsRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_ListProfileContentAnnotationsForRatingsRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_ValidateUserKey : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_ValidateUserKeyRequest * parameters;
}
@property (nonatomic, retain) LibreAccessServiceSvc_ValidateUserKeyRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_ValidateUserKeyRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_AcknowledgeLicense : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_AcknowledgeLicenseRequest * parameters;
}
@property (nonatomic, retain) LibreAccessServiceSvc_AcknowledgeLicenseRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_AcknowledgeLicenseRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_SharedTokenExchange : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_SharedTokenExchangeRequest * body;
}
@property (nonatomic, retain) LibreAccessServiceSvc_SharedTokenExchangeRequest * body;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	body:(LibreAccessServiceSvc_SharedTokenExchangeRequest *)aBody
;
@end
@interface LibreAccessServiceSoap11Binding_SaveUserCSRNotes : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_SaveUserCSRNotesRequest * parameters;
}
@property (nonatomic, retain) LibreAccessServiceSvc_SaveUserCSRNotesRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_SaveUserCSRNotesRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_HealthCheck : LibreAccessServiceSoap11BindingOperation {
}
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
;
@end
@interface LibreAccessServiceSoap11Binding_SaveNewDomain : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_SaveNewDomainRequest * parameters;
}
@property (nonatomic, retain) LibreAccessServiceSvc_SaveNewDomainRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_SaveNewDomainRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_ListDefaultBooks : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_ListDefaultBooksRequest * parameters;
}
@property (nonatomic, retain) LibreAccessServiceSvc_ListDefaultBooksRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_ListDefaultBooksRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_ListReadingStatisticsDetailed : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_ListReadingStatisticsDetailedRequest * parameters;
}
@property (nonatomic, retain) LibreAccessServiceSvc_ListReadingStatisticsDetailedRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_ListReadingStatisticsDetailedRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_DeviceCanJoinDomain : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_DeviceCanJoinDomainRequest * parameters;
}
@property (nonatomic, retain) LibreAccessServiceSvc_DeviceCanJoinDomainRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_DeviceCanJoinDomainRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_AssignBooksToAllUsers : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_AssignBooksToAllUsersRequest * parameters;
}
@property (nonatomic, retain) LibreAccessServiceSvc_AssignBooksToAllUsersRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_AssignBooksToAllUsersRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_SaveProfileContentAnnotationsForRatings : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_SaveProfileContentAnnotationsForRatingsRequest * parameters;
}
@property (nonatomic, retain) LibreAccessServiceSvc_SaveProfileContentAnnotationsForRatingsRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_SaveProfileContentAnnotationsForRatingsRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_ListUserSettingsEx : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_ListUserSettingsExRequest * parameters;
}
@property (nonatomic, retain) LibreAccessServiceSvc_ListUserSettingsExRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_ListUserSettingsExRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_ListUserContentForRatings : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_ListUserContentForRatingsRequest * body;
}
@property (nonatomic, retain) LibreAccessServiceSvc_ListUserContentForRatingsRequest * body;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	body:(LibreAccessServiceSvc_ListUserContentForRatingsRequest *)aBody
;
@end
@interface LibreAccessServiceSoap11Binding_GetLastPageLocation : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_GetLastPageLocationRequest * parameters;
}
@property (nonatomic, retain) LibreAccessServiceSvc_GetLastPageLocationRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_GetLastPageLocationRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_SaveProfileContentAnnotations : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_SaveProfileContentAnnotationsRequest * parameters;
}
@property (nonatomic, retain) LibreAccessServiceSvc_SaveProfileContentAnnotationsRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_SaveProfileContentAnnotationsRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_RemoveDefaultBooks : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_RemoveDefaultBooksRequest * parameters;
}
@property (nonatomic, retain) LibreAccessServiceSvc_RemoveDefaultBooksRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_RemoveDefaultBooksRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_GetLicensableStatus : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_GetLicensableStatusRequest * parameters;
}
@property (nonatomic, retain) LibreAccessServiceSvc_GetLicensableStatusRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_GetLicensableStatusRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_SaveLastPageLocation : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_SaveLastPageLocationRequest * parameters;
}
@property (nonatomic, retain) LibreAccessServiceSvc_SaveLastPageLocationRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_SaveLastPageLocationRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_ListUserCSRNotes : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_ListUserCSRNotesRequest * parameters;
}
@property (nonatomic, retain) LibreAccessServiceSvc_ListUserCSRNotesRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_ListUserCSRNotesRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_RenewToken : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_RenewTokenRequest * body;
}
@property (nonatomic, retain) LibreAccessServiceSvc_RenewTokenRequest * body;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	body:(LibreAccessServiceSvc_RenewTokenRequest *)aBody
;
@end
@interface LibreAccessServiceSoap11Binding_SaveDeviceInfo : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_SaveDeviceInfoRequest * parameters;
}
@property (nonatomic, retain) LibreAccessServiceSvc_SaveDeviceInfoRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_SaveDeviceInfoRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_ListReadingStatisticsAggregate : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_ListReadingStatisticsAggregateRequest * parameters;
}
@property (nonatomic, retain) LibreAccessServiceSvc_ListReadingStatisticsAggregateRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_ListReadingStatisticsAggregateRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_ListTopRatings : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_ListTopRatingsRequest * parameters;
}
@property (nonatomic, retain) LibreAccessServiceSvc_ListTopRatingsRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_ListTopRatingsRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_ListLastNWords : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_ListLastNWordsRequest * parameters;
}
@property (nonatomic, retain) LibreAccessServiceSvc_ListLastNWordsRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_ListLastNWordsRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_TokenExchangeEx : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_TokenExchangeEx * body;
}
@property (nonatomic, retain) LibreAccessServiceSvc_TokenExchangeEx * body;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	body:(LibreAccessServiceSvc_TokenExchangeEx *)aBody
;
@end
@interface LibreAccessServiceSoap11Binding_DeviceLeftDomain : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_DeviceLeftDomainRequest * parameters;
}
@property (nonatomic, retain) LibreAccessServiceSvc_DeviceLeftDomainRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_DeviceLeftDomainRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_ListReadBooks : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_ListReadBooksRequest * parameters;
}
@property (nonatomic, retain) LibreAccessServiceSvc_ListReadBooksRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_ListReadBooksRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_GetDeviceInfo : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_GetDeviceInfoRequest * parameters;
}
@property (nonatomic, retain) LibreAccessServiceSvc_GetDeviceInfoRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_GetDeviceInfoRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_SaveReadingStatisticsDetailed : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_SaveReadingStatisticsDetailedRequest * parameters;
}
@property (nonatomic, retain) LibreAccessServiceSvc_SaveReadingStatisticsDetailedRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_SaveReadingStatisticsDetailedRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_SaveContentProfileAssignment : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_SaveContentProfileAssignmentRequest * parameters;
}
@property (nonatomic, retain) LibreAccessServiceSvc_SaveContentProfileAssignmentRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_SaveContentProfileAssignmentRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_TokenExchange : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_TokenExchange * body;
}
@property (nonatomic, retain) LibreAccessServiceSvc_TokenExchange * body;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	body:(LibreAccessServiceSvc_TokenExchange *)aBody
;
@end
@interface LibreAccessServiceSoap11Binding_SetAccountPasswordRequired : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_SetAccountPasswordRequiredRequest * parameters;
}
@property (nonatomic, retain) LibreAccessServiceSvc_SetAccountPasswordRequiredRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_SetAccountPasswordRequiredRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_GetVersion : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_GetVersionRequest * parameters;
}
@property (nonatomic, retain) LibreAccessServiceSvc_GetVersionRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_GetVersionRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_ListUserContentEx : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_ListUserContentEx * body;
}
@property (nonatomic, retain) LibreAccessServiceSvc_ListUserContentEx * body;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	body:(LibreAccessServiceSvc_ListUserContentEx *)aBody
;
@end
@interface LibreAccessServiceSoap11Binding_SaveUserSettings : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_SaveUserSettingsRequest * parameters;
}
@property (nonatomic, retain) LibreAccessServiceSvc_SaveUserSettingsRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_SaveUserSettingsRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_TokenExchangeExCoppa : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_TokenExchangeExCoppaRequest * body;
}
@property (nonatomic, retain) LibreAccessServiceSvc_TokenExchangeExCoppaRequest * body;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	body:(LibreAccessServiceSvc_TokenExchangeExCoppaRequest *)aBody
;
@end
@interface LibreAccessServiceSoap11Binding_AuthenticateDevice : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_AuthenticateDeviceRequest * body;
}
@property (nonatomic, retain) LibreAccessServiceSvc_AuthenticateDeviceRequest * body;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	body:(LibreAccessServiceSvc_AuthenticateDeviceRequest *)aBody
;
@end
@interface LibreAccessServiceSoap11Binding_ListContentMetadata : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_ListContentMetadata * body;
}
@property (nonatomic, retain) LibreAccessServiceSvc_ListContentMetadata * body;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	body:(LibreAccessServiceSvc_ListContentMetadata *)aBody
;
@end
@interface LibreAccessServiceSoap11Binding_ListApplicationSettings : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_ListApplicationSettingsRequest * parameters;
}
@property (nonatomic, retain) LibreAccessServiceSvc_ListApplicationSettingsRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_ListApplicationSettingsRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_ListTopFavorites : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_ListTopFavoritesRequest * parameters;
}
@property (nonatomic, retain) LibreAccessServiceSvc_ListTopFavoritesRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_ListTopFavoritesRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_ListLastNProfileReadBooks : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_ListLastNProfileReadBooksRequest * parameters;
}
@property (nonatomic, retain) LibreAccessServiceSvc_ListLastNProfileReadBooksRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_ListLastNProfileReadBooksRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_SaveUserProfiles : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_SaveUserProfilesRequest * parameters;
}
@property (nonatomic, retain) LibreAccessServiceSvc_SaveUserProfilesRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_SaveUserProfilesRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_GetUserProfiles : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_GetUserProfilesRequest * parameters;
}
@property (nonatomic, retain) LibreAccessServiceSvc_GetUserProfilesRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_GetUserProfilesRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_DeleteBookShelfEntry : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_DeleteBookShelfEntryRequest * parameters;
}
@property (nonatomic, retain) LibreAccessServiceSvc_DeleteBookShelfEntryRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_DeleteBookShelfEntryRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_SetLoggingLevel : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_SetLoggingLevelRequest * parameters;
}
@property (nonatomic, retain) LibreAccessServiceSvc_SetLoggingLevelRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_SetLoggingLevelRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_SaveUserSettingsEx : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_SaveUserSettingsExRequest * parameters;
}
@property (nonatomic, retain) LibreAccessServiceSvc_SaveUserSettingsExRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_SaveUserSettingsExRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_ListUserSettings : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_ListUserSettingsRequest * parameters;
}
@property (nonatomic, retain) LibreAccessServiceSvc_ListUserSettingsRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_ListUserSettingsRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_IsEntitledToLicense : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_EntitledToLicenceRequest * parameters;
}
@property (nonatomic, retain) LibreAccessServiceSvc_EntitledToLicenceRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_EntitledToLicenceRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_RemoveOrder : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_RemoveOrderRequest * parameters;
}
@property (nonatomic, retain) LibreAccessServiceSvc_RemoveOrderRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_RemoveOrderRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_ListProfileContentAnnotations : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_ListProfileContentAnnotationsRequest * parameters;
}
@property (nonatomic, retain) LibreAccessServiceSvc_ListProfileContentAnnotationsRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_ListProfileContentAnnotationsRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_ListUserContent : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_ListUserContent * body;
}
@property (nonatomic, retain) LibreAccessServiceSvc_ListUserContent * body;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	body:(LibreAccessServiceSvc_ListUserContent *)aBody
;
@end
@interface LibreAccessServiceSoap11Binding_ListAvailableDumps : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_ListAvailableDumps * parameters;
}
@property (nonatomic, retain) LibreAccessServiceSvc_ListAvailableDumps * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_ListAvailableDumps *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_SaveDefaultBooks : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_SaveDefaultBooksRequest * parameters;
}
@property (nonatomic, retain) LibreAccessServiceSvc_SaveDefaultBooksRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_SaveDefaultBooksRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_ListFavoriteTypes : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_ListFavoriteTypesRequest * parameters;
}
@property (nonatomic, retain) LibreAccessServiceSvc_ListFavoriteTypesRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_ListFavoriteTypesRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_ListContentMetadataForRatings : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_ListContentMetadataForRatingsRequest * body;
}
@property (nonatomic, retain) LibreAccessServiceSvc_ListContentMetadataForRatingsRequest * body;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	body:(LibreAccessServiceSvc_ListContentMetadataForRatingsRequest *)aBody
;
@end
@interface LibreAccessServiceSoap11Binding_GetKeyId : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_GetKeyIdRequest * parameters;
}
@property (nonatomic, retain) LibreAccessServiceSvc_GetKeyIdRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_GetKeyIdRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_SetAccountAutoAssign : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_SetAccountAutoAssignRequest * parameters;
}
@property (nonatomic, retain) LibreAccessServiceSvc_SetAccountAutoAssignRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_SetAccountAutoAssignRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_envelope : NSObject {
}
+ (LibreAccessServiceSoap11Binding_envelope *)sharedInstance;
- (NSString *)serializedFormUsingHeaderElements:(NSDictionary *)headerElements bodyElements:(NSDictionary *)bodyElements bodyKeys:(NSArray *)bodyKeys;
@end
@interface LibreAccessServiceSoap11BindingResponse : NSObject {
	NSArray *headers;
	NSArray *bodyParts;
	NSError *error;
}
@property (nonatomic, retain) NSArray *headers;
@property (nonatomic, retain) NSArray *bodyParts;
@property (nonatomic, retain) NSError *error;
@end
