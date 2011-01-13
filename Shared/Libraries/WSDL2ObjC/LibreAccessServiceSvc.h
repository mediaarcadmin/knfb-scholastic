#import <Foundation/Foundation.h>
#import "USAdditions.h"
#import <libxml/tree.h>
#import "USGlobals.h"
@class LibreAccessServiceSvc_StatusHolder;
@class LibreAccessServiceSvc_ItemsCount;
@class LibreAccessServiceSvc_UserContentItem;
@class LibreAccessServiceSvc_ContentProfileList;
@class LibreAccessServiceSvc_OrderIDList;
@class LibreAccessServiceSvc_isbnItem;
@class LibreAccessServiceSvc_ContentMetadataItem;
@class LibreAccessServiceSvc_ContentProfileAssignmentList;
@class LibreAccessServiceSvc_ContentProfileAssignmentItem;
@class LibreAccessServiceSvc_AssignedProfileList;
@class LibreAccessServiceSvc_TopFavoritesRequestList;
@class LibreAccessServiceSvc_TopFavoritesRequestItem;
@class LibreAccessServiceSvc_TopFavoritesResponseList;
@class LibreAccessServiceSvc_TopFavoritesResponseItem;
@class LibreAccessServiceSvc_TopFavoritesContentItems;
@class LibreAccessServiceSvc_TopFavoritesContentItem;
@class LibreAccessServiceSvc_AssignedProfileItem;
@class LibreAccessServiceSvc_ContentProfileItem;
@class LibreAccessServiceSvc_OrderIDItem;
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
@class LibreAccessServiceSvc_AnnotationsRequestContentItem;
@class LibreAccessServiceSvc_PrivateAnnotationsRequest;
@class LibreAccessServiceSvc_AnnotationsList;
@class LibreAccessServiceSvc_AnnotationsItem;
@class LibreAccessServiceSvc_AnnotationsContentList;
@class LibreAccessServiceSvc_AnnotationsContentItem;
@class LibreAccessServiceSvc_PrivateAnnotations;
@class LibreAccessServiceSvc_Highlights;
@class LibreAccessServiceSvc_Notes;
@class LibreAccessServiceSvc_Bookmarks;
@class LibreAccessServiceSvc_Favorites;
@class LibreAccessServiceSvc_LastPage;
@class LibreAccessServiceSvc_Highlight;
@class LibreAccessServiceSvc_LocationText;
@class LibreAccessServiceSvc_WordIndex;
@class LibreAccessServiceSvc_Note;
@class LibreAccessServiceSvc_LocationGraphics;
@class LibreAccessServiceSvc_Coords;
@class LibreAccessServiceSvc_Bookmark;
@class LibreAccessServiceSvc_LocationBookmark;
@class LibreAccessServiceSvc_Favorite;
@class LibreAccessServiceSvc_AnnotationStatusList;
@class LibreAccessServiceSvc_AnnotationStatusItem;
@class LibreAccessServiceSvc_AnnotationStatusContentList;
@class LibreAccessServiceSvc_AnnotationStatusContentItem;
@class LibreAccessServiceSvc_PrivateAnnotationsStatus;
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
@class LibreAccessServiceSvc_SharedTokenExchangeRequest;
@class LibreAccessServiceSvc_SharedTokenExchangeResponse;
@class LibreAccessServiceSvc_AuthenticateDeviceRequest;
@class LibreAccessServiceSvc_AuthenticateDeviceResponse;
@class LibreAccessServiceSvc_RenewTokenRequest;
@class LibreAccessServiceSvc_RenewTokenResponse;
@class LibreAccessServiceSvc_ListUserContent;
@class LibreAccessServiceSvc_ListUserContentResponse;
@class LibreAccessServiceSvc_UserContentList;
@class LibreAccessServiceSvc_ListContentMetadata;
@class LibreAccessServiceSvc_ListContentMetadataResponse;
@class LibreAccessServiceSvc_ContentMetadataList;
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
@class LibreAccessServiceSvc_ListProfileContentAnnotationsRequest;
@class LibreAccessServiceSvc_ListProfileContentAnnotationsResponse;
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
@class LibreAccessServiceSvc_ListUserSettingsRequest;
@class LibreAccessServiceSvc_ListUserSettingsResponse;
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
@class LibreAccessServiceSvc_HealthCheckResponse;
@class LibreAccessServiceSvc_EndpointsList;
typedef enum {
	LibreAccessServiceSvc_statuscodes_none = 0,
	LibreAccessServiceSvc_statuscodes_SUCCESS,
	LibreAccessServiceSvc_statuscodes_FAIL,
} LibreAccessServiceSvc_statuscodes;
LibreAccessServiceSvc_statuscodes LibreAccessServiceSvc_statuscodes_enumFromString(NSString *string);
NSString * LibreAccessServiceSvc_statuscodes_stringFromEnum(LibreAccessServiceSvc_statuscodes enumValue);
@interface LibreAccessServiceSvc_StatusHolder : NSObject {
	
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
@property (assign) LibreAccessServiceSvc_statuscodes status;
@property (retain) NSNumber * statuscode;
@property (retain) NSString * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ItemsCount : NSObject {
	
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
@property (retain) NSNumber * Returned;
@property (retain) NSNumber * Found;
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
	LibreAccessServiceSvc_ApplicationSettings_UPDATE_VERSION_ON_REPURCHASE,
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
@interface LibreAccessServiceSvc_ContentProfileItem : NSObject {
	
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
@property (retain) NSNumber * profileID;
@property (retain) USBoolean * isFavorite;
@property (retain) NSNumber * lastPageLocation;
@property (retain) NSDate * lastmodified;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ContentProfileList : NSObject {
	
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
@property (readonly) NSMutableArray * ContentProfileItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_OrderIDItem : NSObject {
	
/* elements */
	NSNumber * OrderID;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_OrderIDItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (retain) NSNumber * OrderID;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_OrderIDList : NSObject {
	
/* elements */
	NSMutableArray *OrderIDItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_OrderIDList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addOrderIDItem:(LibreAccessServiceSvc_OrderIDItem *)toAdd;
@property (readonly) NSMutableArray * OrderIDItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_UserContentItem : NSObject {
	
/* elements */
	NSString * ContentIdentifier;
	LibreAccessServiceSvc_ContentIdentifierTypes ContentIdentifierType;
	LibreAccessServiceSvc_drmqualifiers DRMQualifier;
	NSString * Format;
	NSString * Version;
	LibreAccessServiceSvc_ContentProfileList * ContentProfileList;
	LibreAccessServiceSvc_OrderIDList * OrderIDList;
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
@property (retain) NSString * ContentIdentifier;
@property (assign) LibreAccessServiceSvc_ContentIdentifierTypes ContentIdentifierType;
@property (assign) LibreAccessServiceSvc_drmqualifiers DRMQualifier;
@property (retain) NSString * Format;
@property (retain) NSString * Version;
@property (retain) LibreAccessServiceSvc_ContentProfileList * ContentProfileList;
@property (retain) LibreAccessServiceSvc_OrderIDList * OrderIDList;
@property (retain) NSDate * lastmodified;
@property (retain) USBoolean * DefaultAssignment;
/* attributes */
- (NSDictionary *)attributes;
@end
typedef enum {
	LibreAccessServiceSvc_TopFavoritesTypes_none = 0,
	LibreAccessServiceSvc_TopFavoritesTypes_EREADER_CATEGORY,
} LibreAccessServiceSvc_TopFavoritesTypes;
LibreAccessServiceSvc_TopFavoritesTypes LibreAccessServiceSvc_TopFavoritesTypes_enumFromString(NSString *string);
NSString * LibreAccessServiceSvc_TopFavoritesTypes_stringFromEnum(LibreAccessServiceSvc_TopFavoritesTypes enumValue);
@interface LibreAccessServiceSvc_isbnItem : NSObject {
	
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
@property (retain) NSString * ISBN;
@property (retain) NSString * Format;
@property (assign) LibreAccessServiceSvc_ContentIdentifierTypes IdentifierType;
@property (assign) LibreAccessServiceSvc_drmqualifiers Qualifier;
/* attributes */
- (NSDictionary *)attributes;
@end
typedef enum {
	LibreAccessServiceSvc_ProductType_none = 0,
	LibreAccessServiceSvc_ProductType_DIG,
	LibreAccessServiceSvc_ProductType_PRI,
	LibreAccessServiceSvc_ProductType_ENH,
} LibreAccessServiceSvc_ProductType;
LibreAccessServiceSvc_ProductType LibreAccessServiceSvc_ProductType_enumFromString(NSString *string);
NSString * LibreAccessServiceSvc_ProductType_stringFromEnum(LibreAccessServiceSvc_ProductType enumValue);
@interface LibreAccessServiceSvc_ContentMetadataItem : NSObject {
	
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
	LibreAccessServiceSvc_ProductType ProductType;
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
@property (retain) NSString * ContentIdentifier;
@property (assign) LibreAccessServiceSvc_ContentIdentifierTypes ContentIdentifierType;
@property (retain) NSString * Title;
@property (retain) NSString * Author;
@property (retain) NSString * Description;
@property (retain) NSString * Version;
@property (retain) NSNumber * PageNumber;
@property (retain) NSNumber * FileSize;
@property (assign) LibreAccessServiceSvc_drmqualifiers DRMQualifier;
@property (retain) NSString * CoverURL;
@property (retain) NSString * ContentURL;
- (void)addEreaderCategories:(NSString *)toAdd;
@property (readonly) NSMutableArray * EreaderCategories;
@property (assign) LibreAccessServiceSvc_ProductType ProductType;
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
@interface LibreAccessServiceSvc_AssignedProfileItem : NSObject {
	
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
@property (retain) NSNumber * profileID;
@property (assign) LibreAccessServiceSvc_SaveActions action;
@property (retain) NSDate * lastmodified;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AssignedProfileList : NSObject {
	
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
@property (readonly) NSMutableArray * AssignedProfileItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ContentProfileAssignmentItem : NSObject {
	
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
@property (retain) NSString * contentIdentifier;
@property (assign) LibreAccessServiceSvc_ContentIdentifierTypes ContentIdentifierType;
@property (assign) LibreAccessServiceSvc_drmqualifiers drmqualifier;
@property (retain) NSString * format;
@property (retain) LibreAccessServiceSvc_AssignedProfileList * AssignedProfileList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ContentProfileAssignmentList : NSObject {
	
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
@property (readonly) NSMutableArray * ContentProfileAssignmentItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_TopFavoritesRequestItem : NSObject {
	
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
@property (retain) USBoolean * AssignedBooksOnly;
@property (assign) LibreAccessServiceSvc_TopFavoritesTypes TopFavoritesType;
@property (retain) NSString * TopFavoritesTypeValue;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_TopFavoritesRequestList : NSObject {
	
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
@property (readonly) NSMutableArray * TopFavoritesRequestItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_TopFavoritesContentItem : NSObject {
	
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
@property (retain) NSString * ContentIdentifier;
@property (assign) LibreAccessServiceSvc_ContentIdentifierTypes ContentIdentifierType;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_TopFavoritesContentItems : NSObject {
	
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
@property (readonly) NSMutableArray * TopFavoritesContentItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_TopFavoritesResponseItem : NSObject {
	
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
@property (assign) LibreAccessServiceSvc_TopFavoritesTypes TopFavoritesType;
@property (retain) NSString * TopFavoritesTypeValue;
@property (retain) LibreAccessServiceSvc_TopFavoritesContentItems * TopFavoritesContentItems;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_TopFavoritesResponseList : NSObject {
	
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
@property (readonly) NSMutableArray * TopFavoritesResponseItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SaveProfileItem : NSObject {
	
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
@property (retain) USBoolean * AutoAssignContentToProfiles;
@property (retain) USBoolean * ProfilePasswordRequired;
@property (retain) NSString * Firstname;
@property (retain) NSString * Lastname;
@property (retain) NSDate * BirthDay;
@property (retain) NSDate * LastModified;
@property (retain) NSString * screenname;
@property (retain) NSString * password;
@property (retain) NSString * userkey;
@property (assign) LibreAccessServiceSvc_ProfileTypes type;
@property (retain) NSNumber * id_;
@property (assign) LibreAccessServiceSvc_SaveActions action;
@property (assign) LibreAccessServiceSvc_BookshelfStyle BookshelfStyle;
@property (retain) USBoolean * storyInteractionEnabled;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SaveProfileList : NSObject {
	
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
@property (readonly) NSMutableArray * SaveProfileItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ProfileItem : NSObject {
	
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
@property (retain) USBoolean * AutoAssignContentToProfiles;
@property (retain) USBoolean * ProfilePasswordRequired;
@property (retain) NSString * Firstname;
@property (retain) NSString * Lastname;
@property (retain) NSDate * BirthDay;
@property (retain) NSString * screenname;
@property (retain) NSString * password;
@property (retain) NSString * userkey;
@property (assign) LibreAccessServiceSvc_ProfileTypes type;
@property (retain) NSNumber * id_;
@property (assign) LibreAccessServiceSvc_BookshelfStyle BookshelfStyle;
@property (retain) NSDate * LastModified;
@property (retain) NSDate * LastScreenNameModified;
@property (retain) NSDate * LastPasswordModified;
@property (retain) USBoolean * storyInteractionEnabled;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ProfileList : NSObject {
	
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
@property (readonly) NSMutableArray * ProfileItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ApplicationSettingItem : NSObject {
	
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
@property (assign) LibreAccessServiceSvc_ApplicationSettings settingName;
@property (retain) NSString * settingValue;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ApplicationSettingList : NSObject {
	
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
@property (readonly) NSMutableArray * ApplicationSettingItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ProfileStatusItem : NSObject {
	
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
@property (retain) NSNumber * id_;
@property (assign) LibreAccessServiceSvc_SaveActions action;
@property (assign) LibreAccessServiceSvc_statuscodes status;
@property (retain) NSString * screenname;
@property (retain) NSNumber * statuscode;
@property (retain) NSString * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ProfileStatusList : NSObject {
	
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
@property (readonly) NSMutableArray * ProfileStatusItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_DeviceItem : NSObject {
	
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
@property (retain) NSString * DeviceKey;
@property (retain) NSNumber * DeviceId;
@property (retain) USBoolean * AutoloadContent;
@property (retain) NSString * DevicePlatform;
@property (retain) NSString * DeviceNickname;
@property (retain) USBoolean * Active;
@property (retain) NSString * RemoveReason;
@property (retain) NSNumber * BadLoginAttempts;
@property (retain) NSDate * BadLoginDatetimeUTC;
@property (retain) USBoolean * DeregistrationConfirmed;
@property (retain) NSDate * lastmodified;
@property (retain) NSDate * lastactivated;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_DeviceList : NSObject {
	
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
@property (readonly) NSMutableArray * DeviceItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_PrivateAnnotationsRequest : NSObject {
	
/* elements */
	NSDate * HighlightsAfter;
	NSDate * NotesAfter;
	NSDate * BookmarksAfter;
	NSDate * FavoritesAfter;
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
@property (retain) NSDate * HighlightsAfter;
@property (retain) NSDate * NotesAfter;
@property (retain) NSDate * BookmarksAfter;
@property (retain) NSDate * FavoritesAfter;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AnnotationsRequestContentItem : NSObject {
	
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
@property (retain) NSString * contentIdentifier;
@property (assign) LibreAccessServiceSvc_ContentIdentifierTypes ContentIdentifierType;
@property (assign) LibreAccessServiceSvc_drmqualifiers drmqualifier;
@property (retain) NSString * format;
@property (retain) LibreAccessServiceSvc_PrivateAnnotationsRequest * PrivateAnnotationsRequest;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AnnotationsRequestContentList : NSObject {
	
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
@property (readonly) NSMutableArray * AnnotationsRequestContentItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AnnotationsRequestItem : NSObject {
	
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
@property (retain) LibreAccessServiceSvc_AnnotationsRequestContentList * AnnotationsRequestContentList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AnnotationsRequestList : NSObject {
	
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
@property (retain) LibreAccessServiceSvc_AnnotationsRequestItem * AnnotationsRequestItem;
@property (retain) NSNumber * profileID;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_WordIndex : NSObject {
	
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
@property (retain) NSNumber * start;
@property (retain) NSNumber * end;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_LocationText : NSObject {
	
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
@property (retain) NSNumber * page;
@property (retain) LibreAccessServiceSvc_WordIndex * wordindex;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_Highlight : NSObject {
	
/* elements */
	NSNumber * id_;
	LibreAccessServiceSvc_SaveActions action;
	NSString * color;
	LibreAccessServiceSvc_LocationText * location;
	NSNumber * endPage;
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
@property (retain) NSNumber * id_;
@property (assign) LibreAccessServiceSvc_SaveActions action;
@property (retain) NSString * color;
@property (retain) LibreAccessServiceSvc_LocationText * location;
@property (retain) NSNumber * endPage;
@property (retain) NSDate * lastmodified;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_Highlights : NSObject {
	
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
@property (readonly) NSMutableArray * Highlight;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_Coords : NSObject {
	
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
@property (retain) NSNumber * x;
@property (retain) NSNumber * y;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_LocationGraphics : NSObject {
	
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
@property (retain) NSNumber * page;
@property (retain) LibreAccessServiceSvc_Coords * coords;
@property (retain) NSNumber * wordindex;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_Note : NSObject {
	
/* elements */
	NSNumber * id_;
	LibreAccessServiceSvc_SaveActions action;
	LibreAccessServiceSvc_LocationGraphics * location;
	NSString * color;
	NSString * value;
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
@property (retain) NSNumber * id_;
@property (assign) LibreAccessServiceSvc_SaveActions action;
@property (retain) LibreAccessServiceSvc_LocationGraphics * location;
@property (retain) NSString * color;
@property (retain) NSString * value;
@property (retain) NSDate * lastmodified;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_Notes : NSObject {
	
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
@property (readonly) NSMutableArray * Note;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_LocationBookmark : NSObject {
	
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
@property (retain) NSNumber * page;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_Bookmark : NSObject {
	
/* elements */
	NSNumber * id_;
	LibreAccessServiceSvc_SaveActions action;
	NSString * text;
	USBoolean * disabled;
	LibreAccessServiceSvc_LocationBookmark * location;
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
@property (retain) NSNumber * id_;
@property (assign) LibreAccessServiceSvc_SaveActions action;
@property (retain) NSString * text;
@property (retain) USBoolean * disabled;
@property (retain) LibreAccessServiceSvc_LocationBookmark * location;
@property (retain) NSDate * lastmodified;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_Bookmarks : NSObject {
	
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
@property (readonly) NSMutableArray * Bookmark;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_Favorite : NSObject {
	
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
@property (retain) USBoolean * isFavorite;
@property (retain) NSDate * lastmodified;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_Favorites : NSObject {
	
/* elements */
	NSMutableArray *Favorite;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessServiceSvc_Favorites *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addFavorite:(LibreAccessServiceSvc_Favorite *)toAdd;
@property (readonly) NSMutableArray * Favorite;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_LastPage : NSObject {
	
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
@property (retain) NSNumber * lastPageLocation;
@property (retain) NSNumber * percentage;
@property (retain) NSString * component;
@property (retain) NSDate * lastmodified;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_PrivateAnnotations : NSObject {
	
/* elements */
	LibreAccessServiceSvc_Highlights * Highlights;
	LibreAccessServiceSvc_Notes * Notes;
	LibreAccessServiceSvc_Bookmarks * Bookmarks;
	LibreAccessServiceSvc_Favorites * Favorites;
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
@property (retain) LibreAccessServiceSvc_Highlights * Highlights;
@property (retain) LibreAccessServiceSvc_Notes * Notes;
@property (retain) LibreAccessServiceSvc_Bookmarks * Bookmarks;
@property (retain) LibreAccessServiceSvc_Favorites * Favorites;
@property (retain) LibreAccessServiceSvc_LastPage * LastPage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AnnotationsContentItem : NSObject {
	
/* elements */
	NSString * contentIdentifier;
	LibreAccessServiceSvc_ContentIdentifierTypes ContentIdentifierType;
	LibreAccessServiceSvc_drmqualifiers drmqualifier;
	NSString * format;
	NSNumber * version;
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
@property (retain) NSString * contentIdentifier;
@property (assign) LibreAccessServiceSvc_ContentIdentifierTypes ContentIdentifierType;
@property (assign) LibreAccessServiceSvc_drmqualifiers drmqualifier;
@property (retain) NSString * format;
@property (retain) NSNumber * version;
@property (retain) LibreAccessServiceSvc_PrivateAnnotations * PrivateAnnotations;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AnnotationsContentList : NSObject {
	
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
@property (readonly) NSMutableArray * AnnotationsContentItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AnnotationsItem : NSObject {
	
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
@property (retain) LibreAccessServiceSvc_AnnotationsContentList * AnnotationsContentList;
@property (retain) NSNumber * profileID;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AnnotationsList : NSObject {
	
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
@property (readonly) NSMutableArray * AnnotationsItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AnnotationTypeStatusItem : NSObject {
	
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
@property (retain) NSNumber * id_;
@property (assign) LibreAccessServiceSvc_SaveActions action;
@property (retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AnnotationTypeStatusList : NSObject {
	
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
@property (readonly) NSMutableArray * AnnotationTypeStatusItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_PrivateAnnotationsStatus : NSObject {
	
/* elements */
	LibreAccessServiceSvc_AnnotationTypeStatusList * HighlightsStatusList;
	LibreAccessServiceSvc_AnnotationTypeStatusList * NotesStatusList;
	LibreAccessServiceSvc_AnnotationTypeStatusList * BookmarksStatusList;
	LibreAccessServiceSvc_AnnotationTypeStatusList * FavoritesStatusList;
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
@property (retain) LibreAccessServiceSvc_AnnotationTypeStatusList * HighlightsStatusList;
@property (retain) LibreAccessServiceSvc_AnnotationTypeStatusList * NotesStatusList;
@property (retain) LibreAccessServiceSvc_AnnotationTypeStatusList * BookmarksStatusList;
@property (retain) LibreAccessServiceSvc_AnnotationTypeStatusList * FavoritesStatusList;
@property (retain) LibreAccessServiceSvc_AnnotationTypeStatusItem * LastPageStatus;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AnnotationStatusContentItem : NSObject {
	
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
@property (retain) NSString * contentIdentifier;
@property (retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
@property (retain) LibreAccessServiceSvc_PrivateAnnotationsStatus * PrivateAnnotationsStatus;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AnnotationStatusContentList : NSObject {
	
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
@property (readonly) NSMutableArray * AnnotationStatusContentItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AnnotationStatusItem : NSObject {
	
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
@property (retain) NSNumber * profileId;
@property (retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
@property (retain) LibreAccessServiceSvc_AnnotationStatusContentList * AnnotationStatusContentList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AnnotationStatusList : NSObject {
	
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
@property (readonly) NSMutableArray * AnnotationStatusItem;
/* attributes */
- (NSDictionary *)attributes;
@end
typedef enum {
	LibreAccessServiceSvc_aggregationPeriod_none = 0,
	LibreAccessServiceSvc_aggregationPeriod_ALL,
	LibreAccessServiceSvc_aggregationPeriod_WEEK,
	LibreAccessServiceSvc_aggregationPeriod_MONTH,
} LibreAccessServiceSvc_aggregationPeriod;
LibreAccessServiceSvc_aggregationPeriod LibreAccessServiceSvc_aggregationPeriod_enumFromString(NSString *string);
NSString * LibreAccessServiceSvc_aggregationPeriod_stringFromEnum(LibreAccessServiceSvc_aggregationPeriod enumValue);
@interface LibreAccessServiceSvc_ReadingStatsAggregateItem : NSObject {
	
/* elements */
	NSNumber * pagesRead;
	NSNumber * storyInteractions;
	NSNumber * contentOpened;
	NSNumber * dictionaryLookups;
	NSNumber * readEvents;
	NSNumber * readingDuration;
	NSNumber * profileID;
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
@property (retain) NSNumber * pagesRead;
@property (retain) NSNumber * storyInteractions;
@property (retain) NSNumber * contentOpened;
@property (retain) NSNumber * dictionaryLookups;
@property (retain) NSNumber * readEvents;
@property (retain) NSNumber * readingDuration;
@property (retain) NSNumber * profileID;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ReadingStatsAggregateList : NSObject {
	
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
@property (readonly) NSMutableArray * ReadingStatsAggregateItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_DictionaryLookupsList : NSObject {
	
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
@property (readonly) NSMutableArray * dictionaryLookupsItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ReadingStatsEntryItem : NSObject {
	
/* elements */
	NSNumber * readingDuration;
	NSNumber * pagesRead;
	NSNumber * storyInteractions;
	NSNumber * dictionaryLookups;
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
@property (retain) NSNumber * readingDuration;
@property (retain) NSNumber * pagesRead;
@property (retain) NSNumber * storyInteractions;
@property (retain) NSNumber * dictionaryLookups;
@property (retain) NSDate * timestamp;
@property (retain) LibreAccessServiceSvc_DictionaryLookupsList * DictionaryLookupsList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ReadingStatsEntryList : NSObject {
	
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
@property (readonly) NSMutableArray * ReadingStatsEntryItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ReadingStatsContentItem : NSObject {
	
/* elements */
	LibreAccessServiceSvc_ContentIdentifierTypes ContentIdentifierType;
	NSString * contentIdentifier;
	LibreAccessServiceSvc_drmqualifiers drmqualifier;
	NSString * format;
	NSNumber * version;
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
@property (assign) LibreAccessServiceSvc_ContentIdentifierTypes ContentIdentifierType;
@property (retain) NSString * contentIdentifier;
@property (assign) LibreAccessServiceSvc_drmqualifiers drmqualifier;
@property (retain) NSString * format;
@property (retain) NSNumber * version;
@property (retain) LibreAccessServiceSvc_ReadingStatsEntryList * ReadingStatsEntryList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ReadingStatsContentList : NSObject {
	
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
@property (readonly) NSMutableArray * ReadingStatsContentItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ReadingStatsDetailItem : NSObject {
	
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
@property (retain) LibreAccessServiceSvc_ReadingStatsContentList * ReadingStatsContentList;
@property (retain) NSNumber * profileID;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ReadingStatsDetailList : NSObject {
	
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
@property (readonly) NSMutableArray * ReadingStatsDetailItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_BookShelfEntryItem : NSObject {
	
/* elements */
	LibreAccessServiceSvc_ContentIdentifierTypes ContentIdentifierType;
	NSString * contentidentifier;
	LibreAccessServiceSvc_drmqualifiers drmqualifier;
	NSString * format;
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
@property (assign) LibreAccessServiceSvc_ContentIdentifierTypes ContentIdentifierType;
@property (retain) NSString * contentidentifier;
@property (assign) LibreAccessServiceSvc_drmqualifiers drmqualifier;
@property (retain) NSString * format;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_BookshelfEntryList : NSObject {
	
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
@property (readonly) NSMutableArray * BookShelfEntryItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_BookShelfEntryLastPageItem : NSObject {
	
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
@property (assign) LibreAccessServiceSvc_ContentIdentifierTypes ContentIdentifierType;
@property (retain) NSString * contentidentifier;
@property (assign) LibreAccessServiceSvc_drmqualifiers drmqualifier;
@property (retain) NSString * format;
@property (retain) LibreAccessServiceSvc_LastPage * LastPage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_BookshelfEntryLastPageList : NSObject {
	
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
@property (readonly) NSMutableArray * BookShelfEntryLastPageItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ProfileBookshelfEntryItem : NSObject {
	
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
@property (retain) NSNumber * profileId;
@property (retain) LibreAccessServiceSvc_BookshelfEntryLastPageList * BookshelfEntryLastPageList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ProfileBookshelfEntryList : NSObject {
	
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
@property (readonly) NSMutableArray * ProfileBookshelfEntryItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_FavoriteTypesValuesItem : NSObject {
	
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
@property (retain) NSString * Value;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_FavoriteTypeValuesList : NSObject {
	
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
@property (readonly) NSMutableArray * FavoriteTypesValuesItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_FavoriteTypesItem : NSObject {
	
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
@property (assign) LibreAccessServiceSvc_TopFavoritesTypes FavoriteType;
@property (retain) LibreAccessServiceSvc_FavoriteTypeValuesList * FavoriteTypeValuesList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_FavoriteTypesList : NSObject {
	
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
@property (readonly) NSMutableArray * FavoriteTypesItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_UserSettingsItem : NSObject {
	
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
@property (assign) LibreAccessServiceSvc_UserSettingsTypes SettingType;
@property (retain) NSString * SettingValue;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_UserSettingsList : NSObject {
	
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
@property (readonly) NSMutableArray * UserSettingsItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AutoAssignProfilesItem : NSObject {
	
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
@property (retain) NSNumber * profileId;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AutoAssignProfilesList : NSObject {
	
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
@property (readonly) NSMutableArray * AutoAssignProfilesItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ReadBooksProfilesItem : NSObject {
	
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
@property (retain) NSNumber * profileId;
@property (retain) NSDate * lastReadEvent;
@property (retain) NSNumber * lastReadDuration;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ReadBooksProfilesList : NSObject {
	
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
@property (readonly) NSMutableArray * ReadBooksProfilesItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ReadBooksItem : NSObject {
	
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
@property (assign) LibreAccessServiceSvc_ContentIdentifierTypes ContentIdentifierType;
@property (retain) NSString * contentIdentifier;
@property (assign) LibreAccessServiceSvc_drmqualifiers drmqualifier;
@property (retain) NSString * format;
@property (retain) NSNumber * version;
@property (retain) LibreAccessServiceSvc_ReadBooksProfilesList * ReadBooksProfilesList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ReadBooksList : NSObject {
	
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
@property (readonly) NSMutableArray * ReadBooksItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_LastNRequestReadBooksProfilesItem : NSObject {
	
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
@property (retain) NSNumber * profileId;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_LastNRequestReadBooksProfilesList : NSObject {
	
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
@property (readonly) NSMutableArray * LastNRequestReadBooksProfilesItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_LastNReadBooksItem : NSObject {
	
/* elements */
	LibreAccessServiceSvc_ContentIdentifierTypes ContentIdentifierType;
	NSString * contentIdentifier;
	LibreAccessServiceSvc_drmqualifiers drmqualifier;
	NSString * format;
	NSNumber * version;
	NSDate * lastReadEvent;
	NSNumber * lastReadDuration;
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
@property (assign) LibreAccessServiceSvc_ContentIdentifierTypes ContentIdentifierType;
@property (retain) NSString * contentIdentifier;
@property (assign) LibreAccessServiceSvc_drmqualifiers drmqualifier;
@property (retain) NSString * format;
@property (retain) NSNumber * version;
@property (retain) NSDate * lastReadEvent;
@property (retain) NSNumber * lastReadDuration;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_LastNReadBooksList : NSObject {
	
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
@property (readonly) NSMutableArray * LastNReadBooksItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_LastNResponseReadBooksProfilesItem : NSObject {
	
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
@property (retain) NSNumber * profileId;
@property (retain) LibreAccessServiceSvc_LastNReadBooksList * LastNReadBooksList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_LastNResponseReadBooksProfilesList : NSObject {
	
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
@property (readonly) NSMutableArray * LastNResponseReadBooksProfilesItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_LastNRequestWordsItem : NSObject {
	
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
@property (retain) NSNumber * profileId;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_LastNRequestWordsList : NSObject {
	
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
@property (readonly) NSMutableArray * LastNRequestWordsItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_LastNLookedUpWordsItem : NSObject {
	
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
@property (retain) NSString * lookupWord;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_LastNLookedUpWordsList : NSObject {
	
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
@property (readonly) NSMutableArray * LastNLookedUpWordsItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_LastNResponseWordsItem : NSObject {
	
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
@property (retain) NSNumber * profileId;
@property (retain) LibreAccessServiceSvc_LastNLookedUpWordsList * LastNLookedUpWordsList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_LastNResponseWordsList : NSObject {
	
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
@property (readonly) NSMutableArray * LastNResponseWordsItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_NoteItem : NSObject {
	
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
@property (retain) NSString * actor;
@property (retain) NSString * noteText;
@property (retain) NSString * csrUserName;
@property (retain) NSDate * timestamp;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_NotesList : NSObject {
	
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
@property (readonly) NSMutableArray * noteItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_DefaultBooksItem : NSObject {
	
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
@property (retain) NSString * contentidentifier;
@property (assign) LibreAccessServiceSvc_ContentIdentifierTypes contentIdentifierType;
@property (assign) LibreAccessServiceSvc_drmqualifiers DRMQualifier;
@property (retain) NSString * Format;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_DefaultBooksList : NSObject {
	
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
@property (readonly) NSMutableArray * DefaultBooksItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AssignBooksToAllUsersItem : NSObject {
	
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
@property (retain) NSString * userKey;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AssignBooksToAllUsersList : NSObject {
	
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
@property (readonly) NSMutableArray * AssignBooksToAllUsersItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AssignBooksToAllUsersBooksItem : NSObject {
	
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
@property (retain) NSString * contentidentifier;
@property (assign) LibreAccessServiceSvc_ContentIdentifierTypes contentIdentifierType;
@property (assign) LibreAccessServiceSvc_drmqualifiers DRMQualifier;
@property (retain) NSString * Format;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AssignBooksToAllUsersBooksList : NSObject {
	
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
@property (readonly) NSMutableArray * AssignBooksToAllUsersBooksItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_TokenExchange : NSObject {
	
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
@property (retain) NSString * ptoken;
@property (retain) NSNumber * vaid;
@property (retain) NSString * deviceKey;
@property (retain) NSString * impersonationkey;
@property (retain) NSString * UserName;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_TokenExchangeResponse : NSObject {
	
/* elements */
	NSString * authtoken;
	NSNumber * expiresIn;
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
@property (retain) NSString * authtoken;
@property (retain) NSNumber * expiresIn;
@property (retain) USBoolean * deviceIsDeregistered;
@property (retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SharedTokenExchangeRequest : NSObject {
	
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
@property (retain) NSString * ptoken;
@property (retain) NSNumber * vaid;
@property (retain) NSString * deviceKey;
@property (retain) NSString * impersonationkey;
@property (retain) NSString * UserName;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SharedTokenExchangeResponse : NSObject {
	
/* elements */
	NSString * authtoken;
	NSNumber * expires;
	NSNumber * expiresIn;
	NSString * ip;
	NSString * userhash;
	USBoolean * deviceIsDeregistered;
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
@property (retain) NSString * authtoken;
@property (retain) NSNumber * expires;
@property (retain) NSNumber * expiresIn;
@property (retain) NSString * ip;
@property (retain) NSString * userhash;
@property (retain) USBoolean * deviceIsDeregistered;
@property (retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AuthenticateDeviceRequest : NSObject {
	
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
@property (retain) NSNumber * vaid;
@property (retain) NSString * deviceKey;
@property (retain) NSString * userKey;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AuthenticateDeviceResponse : NSObject {
	
/* elements */
	NSString * authtoken;
	NSNumber * expiresIn;
	USBoolean * deviceIsDeregistered;
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
@property (retain) NSString * authtoken;
@property (retain) NSNumber * expiresIn;
@property (retain) USBoolean * deviceIsDeregistered;
@property (retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_RenewTokenRequest : NSObject {
	
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
@property (retain) NSString * authtoken;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_RenewTokenResponse : NSObject {
	
/* elements */
	NSString * authtoken;
	NSNumber * expiresIn;
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
@property (retain) NSString * authtoken;
@property (retain) NSNumber * expiresIn;
@property (retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListUserContent : NSObject {
	
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
@property (retain) NSString * authtoken;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_UserContentList : NSObject {
	
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
@property (readonly) NSMutableArray * UserContentItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListUserContentResponse : NSObject {
	
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
@property (retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
@property (retain) LibreAccessServiceSvc_UserContentList * UserContentList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListContentMetadata : NSObject {
	
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
@property (retain) NSString * authtoken;
@property (retain) USBoolean * includeurls;
- (void)addIsbn13s:(LibreAccessServiceSvc_isbnItem *)toAdd;
@property (readonly) NSMutableArray * isbn13s;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ContentMetadataList : NSObject {
	
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
@property (readonly) NSMutableArray * ContentMetadataItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListContentMetadataResponse : NSObject {
	
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
@property (retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
@property (retain) LibreAccessServiceSvc_ContentMetadataList * ContentMetadataList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_IsEntitledToLicense : NSObject {
	
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
@property (retain) NSString * input;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_IsEntitledToLicenseResponse : NSObject {
	
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
@property (retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
@property (retain) NSString * isEntitled;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_EntitledToLicenceRequest : NSObject {
	
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
@property (retain) NSString * authtoken;
@property (retain) NSString * contentidentifier;
@property (assign) LibreAccessServiceSvc_ContentIdentifierTypes ContentIdentifierType;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SaveReadingStatisticsDetailedRequest : NSObject {
	
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
@property (retain) NSString * authtoken;
@property (retain) LibreAccessServiceSvc_ReadingStatsDetailList * ReadingStatsDetailList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SaveReadingStatisticsDetailedResponse : NSObject {
	
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
@property (retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListReadingStatisticsAggregateRequest : NSObject {
	
/* elements */
	NSString * authtoken;
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
@property (retain) NSString * authtoken;
@property (assign) LibreAccessServiceSvc_aggregationPeriod aggregationPeriod;
@property (retain) USBoolean * countDeletedBooks;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListReadingStatisticsAggregateResponse : NSObject {
	
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
@property (retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
@property (retain) LibreAccessServiceSvc_ReadingStatsAggregateList * ReadingStatsAggregateList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListReadingStatisticsDetailedRequest : NSObject {
	
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
@property (retain) NSString * authtoken;
@property (retain) NSNumber * profileId;
@property (retain) NSDate * begindate;
@property (retain) NSDate * enddate;
@property (retain) USBoolean * countDeletedBooks;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListReadingStatisticsDetailedResponse : NSObject {
	
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
@property (retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
@property (retain) LibreAccessServiceSvc_ReadingStatsDetailList * ReadingStatsDetailList;
@property (retain) LibreAccessServiceSvc_ItemsCount * ItemsCount;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SaveProfileContentAnnotationsRequest : NSObject {
	
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
@property (retain) NSString * authtoken;
@property (retain) LibreAccessServiceSvc_AnnotationsList * AnnotationsList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SaveProfileContentAnnotationsResponse : NSObject {
	
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
@property (retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
@property (retain) LibreAccessServiceSvc_AnnotationStatusList * AnnotationStatusList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListProfileContentAnnotationsRequest : NSObject {
	
/* elements */
	NSString * authtoken;
	LibreAccessServiceSvc_AnnotationsRequestList * AnnotationsRequestList;
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
@property (retain) NSString * authtoken;
@property (retain) LibreAccessServiceSvc_AnnotationsRequestList * AnnotationsRequestList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListProfileContentAnnotationsResponse : NSObject {
	
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
@property (retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
@property (retain) LibreAccessServiceSvc_AnnotationsList * AnnotationsList;
@property (retain) LibreAccessServiceSvc_ItemsCount * ItemsCount;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_GetUserProfilesRequest : NSObject {
	
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
@property (retain) NSString * authtoken;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_GetUserProfilesResponse : NSObject {
	
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
@property (retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
@property (retain) LibreAccessServiceSvc_ProfileList * ProfileList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SaveUserProfilesRequest : NSObject {
	
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
@property (retain) NSString * authtoken;
@property (retain) LibreAccessServiceSvc_SaveProfileList * SaveProfileList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SaveUserProfilesResponse : NSObject {
	
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
@property (retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
@property (retain) LibreAccessServiceSvc_ProfileStatusList * ProfileStatusList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListApplicationSettingsRequest : NSObject {
	
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
@property (retain) NSString * authtoken;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListApplicationSettingsResponse : NSObject {
	
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
@property (retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
@property (retain) LibreAccessServiceSvc_ApplicationSettingList * SettingsList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SaveContentProfileAssignmentRequest : NSObject {
	
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
@property (retain) NSString * authtoken;
@property (retain) LibreAccessServiceSvc_ContentProfileAssignmentList * ContentProfileAssignmentList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SaveContentProfileAssignmentResponse : NSObject {
	
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
@property (retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListTopFavoritesRequest : NSObject {
	
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
@property (retain) NSString * authtoken;
@property (retain) NSNumber * count;
@property (retain) LibreAccessServiceSvc_TopFavoritesRequestList * TopFavoritesRequestList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListTopFavoritesResponse : NSObject {
	
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
@property (retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
@property (retain) LibreAccessServiceSvc_TopFavoritesResponseList * TopFavoritesResponseList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_GetDeviceInfoRequest : NSObject {
	
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
@property (retain) NSString * authtoken;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_GetDeviceInfoResponse : NSObject {
	
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
@property (retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
@property (retain) LibreAccessServiceSvc_DeviceList * DeviceInfoList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SaveDeviceInfoRequest : NSObject {
	
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
@property (retain) NSString * authtoken;
@property (retain) LibreAccessServiceSvc_DeviceList * SaveDeviceList;
@property (assign) LibreAccessServiceSvc_SaveActions action;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SaveDeviceInfoResponse : NSObject {
	
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
@property (retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SaveNewDomainResponse : NSObject {
	
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
@property (retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SaveNewDomainRequest : NSObject {
	
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
@property (retain) NSString * authToken;
@property (retain) NSString * AccountId;
@property (retain) NSNumber * Revision;
@property (retain) NSString * DomainKeyPair;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_DeviceLeftDomainResponse : NSObject {
	
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
@property (retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_DeviceLeftDomainRequest : NSObject {
	
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
@property (retain) NSString * Authtoken;
@property (retain) NSString * DeviceKey;
@property (retain) NSString * ClientId;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_DeviceCanJoinDomainResponse : NSObject {
	
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
@property (retain) NSString * AccountId;
@property (retain) NSString * DomainKeyPair;
@property (retain) NSNumber * Revision;
@property (retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_DeviceCanJoinDomainRequest : NSObject {
	
/* elements */
	NSString * authToken;
	NSString * DeviceNickname;
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
@property (retain) NSString * authToken;
@property (retain) NSString * DeviceNickname;
@property (retain) NSString * DeviceKey;
@property (retain) NSString * ClientId;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_GetLicensableStatusResponse : NSObject {
	
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
@property (retain) NSString * AccountId;
@property (retain) NSNumber * Revision;
@property (retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_GetLicensableStatusRequest : NSObject {
	
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
@property (retain) NSString * authToken;
@property (retain) NSString * KeyId;
@property (retain) NSString * suppliedIdentifier;
@property (retain) NSString * suppliedIdentifierType;
@property (retain) NSString * TransactionId;
@property (retain) NSString * ClientId;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AcknowledgeLicenseResponse : NSObject {
	
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
@property (retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AcknowledgeLicenseRequest : NSObject {
	
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
@property (retain) NSString * TransactionId;
@property (retain) NSString * ClientId;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ValidateScreenNameRequest : NSObject {
	
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
@property (retain) NSString * authtoken;
@property (retain) NSString * screenName;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ValidateScreenNameResponse : NSObject {
	
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
@property (retain) USBoolean * result;
@property (retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ValidateUserKeyRequest : NSObject {
	
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
@property (retain) NSString * authtoken;
@property (retain) NSString * userKey;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ValidateUserKeyResponse : NSObject {
	
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
@property (retain) USBoolean * result;
@property (retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_DeleteBookShelfEntryRequest : NSObject {
	
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
@property (retain) NSString * authtoken;
@property (retain) LibreAccessServiceSvc_BookshelfEntryList * BookShelfEntryList;
@property (retain) USBoolean * cascade;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_DeleteBookShelfEntryResponse : NSObject {
	
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
@property (retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_GetLastPageLocationRequest : NSObject {
	
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
@property (retain) NSString * authtoken;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_GetLastPageLocationResponse : NSObject {
	
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
@property (retain) LibreAccessServiceSvc_ProfileBookshelfEntryList * ProfileBookshelfEntryList;
@property (retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SaveLastPageLocationRequest : NSObject {
	
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
@property (retain) NSString * authtoken;
@property (retain) LibreAccessServiceSvc_ProfileBookshelfEntryList * ProfileBookshelfEntryList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SaveLastPageLocationResponse : NSObject {
	
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
@property (retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListFavoriteTypesRequest : NSObject {
	
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
@property (retain) NSString * authtoken;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListFavoriteTypesResponse : NSObject {
	
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
@property (retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
@property (retain) LibreAccessServiceSvc_FavoriteTypesList * FavoriteTypesList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SaveUserSettingsRequest : NSObject {
	
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
@property (retain) NSString * authtoken;
@property (retain) LibreAccessServiceSvc_UserSettingsList * UserSettingsList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SaveUserSettingsResponse : NSObject {
	
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
@property (retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListUserSettingsRequest : NSObject {
	
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
@property (retain) NSString * authtoken;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListUserSettingsResponse : NSObject {
	
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
@property (retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
@property (retain) LibreAccessServiceSvc_UserSettingsList * UserSettingsList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SetAccountAutoAssignRequest : NSObject {
	
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
@property (retain) NSString * authtoken;
@property (retain) LibreAccessServiceSvc_AutoAssignProfilesList * AutoAssignProfilesList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SetAccountAutoAssignResponse : NSObject {
	
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
@property (retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SetAccountPasswordRequiredRequest : NSObject {
	
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
@property (retain) NSString * authtoken;
@property (retain) USBoolean * passwordRequired;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SetAccountPasswordRequiredResponse : NSObject {
	
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
@property (retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListReadBooksRequest : NSObject {
	
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
@property (retain) NSString * authtoken;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListReadBooksResponse : NSObject {
	
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
@property (retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
@property (retain) LibreAccessServiceSvc_ReadBooksList * ReadBooksList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListLastNProfileReadBooksRequest : NSObject {
	
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
@property (retain) NSString * authtoken;
@property (retain) NSNumber * lastBooksCount;
@property (retain) USBoolean * uniqueBooks;
@property (retain) LibreAccessServiceSvc_LastNRequestReadBooksProfilesList * LastNRequestReadBooksProfilesList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListLastNProfileReadBooksResponse : NSObject {
	
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
@property (retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
@property (retain) LibreAccessServiceSvc_LastNResponseReadBooksProfilesList * LastNResponseReadBooksProfilesList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListLastNWordsRequest : NSObject {
	
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
@property (retain) NSString * authtoken;
@property (retain) NSNumber * lastWordsCount;
@property (retain) NSDate * startDate;
@property (retain) NSDate * endDate;
@property (retain) LibreAccessServiceSvc_LastNRequestWordsList * LastNRequestWordsList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListLastNWordsResponse : NSObject {
	
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
@property (retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
@property (retain) LibreAccessServiceSvc_LastNResponseWordsList * LastNResponseWordsList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_RemoveOrderRequest : NSObject {
	
/* elements */
	NSString * authtoken;
	NSString * userKey;
	NSNumber * orderID;
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
@property (retain) NSString * authtoken;
@property (retain) NSString * userKey;
@property (retain) NSNumber * orderID;
@property (retain) NSString * contentidentifier;
@property (assign) LibreAccessServiceSvc_ContentIdentifierTypes contentIdentifierType;
@property (assign) LibreAccessServiceSvc_drmqualifiers DRMQualifier;
@property (retain) NSString * Format;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_RemoveOrderResponse : NSObject {
	
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
@property (retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SaveUserCSRNotesRequest : NSObject {
	
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
@property (retain) NSString * CSRtoken;
@property (retain) NSString * userKey;
@property (retain) NSString * noteText;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SaveUserCSRNotesResponse : NSObject {
	
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
@property (retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListUserCSRNotesRequest : NSObject {
	
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
@property (retain) NSString * CSRtoken;
@property (retain) NSString * userKey;
@property (retain) NSNumber * lastNNotes;
@property (retain) NSDate * startDate;
@property (retain) NSDate * endDate;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListUserCSRNotesResponse : NSObject {
	
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
@property (retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
@property (retain) LibreAccessServiceSvc_NotesList * notesList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_GetKeyIdRequest : NSObject {
	
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
@property (retain) NSString * contentidentifier;
@property (assign) LibreAccessServiceSvc_ContentIdentifierTypes contentIdentifierType;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_GetKeyIdResponse : NSObject {
	
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
@property (retain) NSString * guid;
@property (retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SaveDefaultBooksRequest : NSObject {
	
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
@property (retain) NSString * CSRtoken;
@property (retain) LibreAccessServiceSvc_DefaultBooksList * BooksList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_SaveDefaultBooksResponse : NSObject {
	
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
@property (retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListDefaultBooksRequest : NSObject {
	
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
@property (retain) NSString * authToken;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_ListDefaultBooksResponse : NSObject {
	
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
@property (retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
@property (retain) LibreAccessServiceSvc_DefaultBooksList * BooksList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_RemoveDefaultBooksRequest : NSObject {
	
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
@property (retain) NSString * CSRtoken;
@property (retain) LibreAccessServiceSvc_DefaultBooksList * BooksList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_RemoveDefaultBooksResponse : NSObject {
	
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
@property (retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AssignBooksToAllUsersRequest : NSObject {
	
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
@property (retain) NSString * CSRtoken;
@property (retain) LibreAccessServiceSvc_AssignBooksToAllUsersList * UsersList;
@property (retain) LibreAccessServiceSvc_AssignBooksToAllUsersBooksList * BooksList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_AssignBooksToAllUsersResponse : NSObject {
	
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
@property (retain) LibreAccessServiceSvc_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_EndpointsList : NSObject {
	
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
@property (readonly) NSMutableArray * Endpoint;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessServiceSvc_HealthCheckResponse : NSObject {
	
/* elements */
	NSNumber * StatusCode;
	NSString * Datapipe;
	NSString * GatewayDatabase;
	NSString * ActivityLogDatabase;
	LibreAccessServiceSvc_EndpointsList * Endpoints;
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
@property (retain) NSNumber * StatusCode;
@property (retain) NSString * Datapipe;
@property (retain) NSString * GatewayDatabase;
@property (retain) NSString * ActivityLogDatabase;
@property (retain) LibreAccessServiceSvc_EndpointsList * Endpoints;
/* attributes */
- (NSDictionary *)attributes;
@end
/* Cookies handling provided by http://en.wikibooks.org/wiki/Programming:WebObjects/Web_Services/Web_Service_Provider */
#import <libxml/parser.h>
#import "xsd.h"
#import "LibreAccessServiceSvc.h"
@class LibreAccessServiceSoap11Binding;
@class LibreAccessServiceSoap11Binding;
@class LibreAccessServiceSoap12Binding;
@class LibreAccessServiceSoap12Binding;
@interface LibreAccessServiceSvc : NSObject {
	
}
+ (LibreAccessServiceSoap11Binding *)LibreAccessServiceSoap11Binding;
+ (LibreAccessServiceSoap11Binding *)LibreAccessServiceSoap11Binding;
+ (LibreAccessServiceSoap12Binding *)LibreAccessServiceSoap12Binding;
+ (LibreAccessServiceSoap12Binding *)LibreAccessServiceSoap12Binding;
@end
@class LibreAccessServiceSoap11BindingResponse;
@class LibreAccessServiceSoap11BindingOperation;
@protocol LibreAccessServiceSoap11BindingResponseDelegate <NSObject>
- (void) operation:(LibreAccessServiceSoap11BindingOperation *)operation completedWithResponse:(LibreAccessServiceSoap11BindingResponse *)response;
@end
@interface LibreAccessServiceSoap11Binding : NSObject <LibreAccessServiceSoap11BindingResponseDelegate> {
	NSURL *address;
	NSTimeInterval defaultTimeout;
	NSMutableArray *cookies;
	BOOL logXMLInOut;
	BOOL synchronousOperationComplete;
	NSString *authUsername;
	NSString *authPassword;
}
@property (copy) NSURL *address;
@property (assign) BOOL logXMLInOut;
@property (assign) NSTimeInterval defaultTimeout;
@property (nonatomic, retain) NSMutableArray *cookies;
@property (nonatomic, retain) NSString *authUsername;
@property (nonatomic, retain) NSString *authPassword;
- (id)initWithAddress:(NSString *)anAddress;
- (void)sendHTTPCallUsingBody:(NSString *)body soapAction:(NSString *)soapAction forOperation:(LibreAccessServiceSoap11BindingOperation *)operation;
- (void)addCookie:(NSHTTPCookie *)toAdd;
- (LibreAccessServiceSoap11BindingResponse *)ValidateScreenNameUsingParameters:(LibreAccessServiceSvc_ValidateScreenNameRequest *)aParameters ;
- (void)ValidateScreenNameAsyncUsingParameters:(LibreAccessServiceSvc_ValidateScreenNameRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)ValidateUserKeyUsingParameters:(LibreAccessServiceSvc_ValidateUserKeyRequest *)aParameters ;
- (void)ValidateUserKeyAsyncUsingParameters:(LibreAccessServiceSvc_ValidateUserKeyRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)AcknowledgeLicenseUsingParameters:(LibreAccessServiceSvc_AcknowledgeLicenseRequest *)aParameters ;
- (void)AcknowledgeLicenseAsyncUsingParameters:(LibreAccessServiceSvc_AcknowledgeLicenseRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)SharedTokenExchangeUsingBody:(LibreAccessServiceSvc_SharedTokenExchangeRequest *)aBody ;
- (void)SharedTokenExchangeAsyncUsingBody:(LibreAccessServiceSvc_SharedTokenExchangeRequest *)aBody  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)SaveUserCSRNotesUsingParameters:(LibreAccessServiceSvc_SaveUserCSRNotesRequest *)aParameters ;
- (void)SaveUserCSRNotesAsyncUsingParameters:(LibreAccessServiceSvc_SaveUserCSRNotesRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)HealthCheckUsing;
- (void)HealthCheckAsyncUsing:(id)noParameter delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
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
- (LibreAccessServiceSoap11BindingResponse *)ListLastNWordsUsingParameters:(LibreAccessServiceSvc_ListLastNWordsRequest *)aParameters ;
- (void)ListLastNWordsAsyncUsingParameters:(LibreAccessServiceSvc_ListLastNWordsRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
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
- (LibreAccessServiceSoap11BindingResponse *)AuthenticateDeviceUsingBody:(LibreAccessServiceSvc_AuthenticateDeviceRequest *)aBody ;
- (void)AuthenticateDeviceAsyncUsingBody:(LibreAccessServiceSvc_AuthenticateDeviceRequest *)aBody  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)ListContentMetadataUsingBody:(LibreAccessServiceSvc_ListContentMetadata *)aBody ;
- (void)ListContentMetadataAsyncUsingBody:(LibreAccessServiceSvc_ListContentMetadata *)aBody  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)ListApplicationSettingsUsingParameters:(LibreAccessServiceSvc_ListApplicationSettingsRequest *)aParameters ;
- (void)ListApplicationSettingsAsyncUsingParameters:(LibreAccessServiceSvc_ListApplicationSettingsRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)SaveUserSettingsUsingParameters:(LibreAccessServiceSvc_SaveUserSettingsRequest *)aParameters ;
- (void)SaveUserSettingsAsyncUsingParameters:(LibreAccessServiceSvc_SaveUserSettingsRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
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
- (LibreAccessServiceSoap11BindingResponse *)ListFavoriteTypesUsingParameters:(LibreAccessServiceSvc_ListFavoriteTypesRequest *)aParameters ;
- (void)ListFavoriteTypesAsyncUsingParameters:(LibreAccessServiceSvc_ListFavoriteTypesRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)GetKeyIdUsingParameters:(LibreAccessServiceSvc_GetKeyIdRequest *)aParameters ;
- (void)GetKeyIdAsyncUsingParameters:(LibreAccessServiceSvc_GetKeyIdRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)SaveDefaultBooksUsingParameters:(LibreAccessServiceSvc_SaveDefaultBooksRequest *)aParameters ;
- (void)SaveDefaultBooksAsyncUsingParameters:(LibreAccessServiceSvc_SaveDefaultBooksRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap11BindingResponse *)SetAccountAutoAssignUsingParameters:(LibreAccessServiceSvc_SetAccountAutoAssignRequest *)aParameters ;
- (void)SetAccountAutoAssignAsyncUsingParameters:(LibreAccessServiceSvc_SetAccountAutoAssignRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
@end
@interface LibreAccessServiceSoap11BindingOperation : NSOperation {
	LibreAccessServiceSoap11Binding *binding;
	LibreAccessServiceSoap11BindingResponse *response;
	id<LibreAccessServiceSoap11BindingResponseDelegate> delegate;
	NSMutableData *responseData;
	NSURLConnection *urlConnection;
}
@property (retain) LibreAccessServiceSoap11Binding *binding;
@property (readonly) LibreAccessServiceSoap11BindingResponse *response;
@property (nonatomic, assign) id<LibreAccessServiceSoap11BindingResponseDelegate> delegate;
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, retain) NSURLConnection *urlConnection;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate;
@end
@interface LibreAccessServiceSoap11Binding_ValidateScreenName : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_ValidateScreenNameRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_ValidateScreenNameRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_ValidateScreenNameRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_ValidateUserKey : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_ValidateUserKeyRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_ValidateUserKeyRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_ValidateUserKeyRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_AcknowledgeLicense : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_AcknowledgeLicenseRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_AcknowledgeLicenseRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_AcknowledgeLicenseRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_SharedTokenExchange : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_SharedTokenExchangeRequest * body;
}
@property (retain) LibreAccessServiceSvc_SharedTokenExchangeRequest * body;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	body:(LibreAccessServiceSvc_SharedTokenExchangeRequest *)aBody
;
@end
@interface LibreAccessServiceSoap11Binding_SaveUserCSRNotes : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_SaveUserCSRNotesRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_SaveUserCSRNotesRequest * parameters;
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
@property (retain) LibreAccessServiceSvc_SaveNewDomainRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_SaveNewDomainRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_ListDefaultBooks : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_ListDefaultBooksRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_ListDefaultBooksRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_ListDefaultBooksRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_ListReadingStatisticsDetailed : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_ListReadingStatisticsDetailedRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_ListReadingStatisticsDetailedRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_ListReadingStatisticsDetailedRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_DeviceCanJoinDomain : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_DeviceCanJoinDomainRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_DeviceCanJoinDomainRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_DeviceCanJoinDomainRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_AssignBooksToAllUsers : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_AssignBooksToAllUsersRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_AssignBooksToAllUsersRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_AssignBooksToAllUsersRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_GetLastPageLocation : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_GetLastPageLocationRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_GetLastPageLocationRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_GetLastPageLocationRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_SaveProfileContentAnnotations : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_SaveProfileContentAnnotationsRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_SaveProfileContentAnnotationsRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_SaveProfileContentAnnotationsRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_RemoveDefaultBooks : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_RemoveDefaultBooksRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_RemoveDefaultBooksRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_RemoveDefaultBooksRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_GetLicensableStatus : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_GetLicensableStatusRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_GetLicensableStatusRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_GetLicensableStatusRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_SaveLastPageLocation : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_SaveLastPageLocationRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_SaveLastPageLocationRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_SaveLastPageLocationRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_ListUserCSRNotes : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_ListUserCSRNotesRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_ListUserCSRNotesRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_ListUserCSRNotesRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_RenewToken : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_RenewTokenRequest * body;
}
@property (retain) LibreAccessServiceSvc_RenewTokenRequest * body;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	body:(LibreAccessServiceSvc_RenewTokenRequest *)aBody
;
@end
@interface LibreAccessServiceSoap11Binding_SaveDeviceInfo : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_SaveDeviceInfoRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_SaveDeviceInfoRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_SaveDeviceInfoRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_ListReadingStatisticsAggregate : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_ListReadingStatisticsAggregateRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_ListReadingStatisticsAggregateRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_ListReadingStatisticsAggregateRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_ListLastNWords : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_ListLastNWordsRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_ListLastNWordsRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_ListLastNWordsRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_DeviceLeftDomain : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_DeviceLeftDomainRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_DeviceLeftDomainRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_DeviceLeftDomainRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_ListReadBooks : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_ListReadBooksRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_ListReadBooksRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_ListReadBooksRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_GetDeviceInfo : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_GetDeviceInfoRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_GetDeviceInfoRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_GetDeviceInfoRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_SaveReadingStatisticsDetailed : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_SaveReadingStatisticsDetailedRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_SaveReadingStatisticsDetailedRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_SaveReadingStatisticsDetailedRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_SaveContentProfileAssignment : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_SaveContentProfileAssignmentRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_SaveContentProfileAssignmentRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_SaveContentProfileAssignmentRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_TokenExchange : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_TokenExchange * body;
}
@property (retain) LibreAccessServiceSvc_TokenExchange * body;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	body:(LibreAccessServiceSvc_TokenExchange *)aBody
;
@end
@interface LibreAccessServiceSoap11Binding_SetAccountPasswordRequired : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_SetAccountPasswordRequiredRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_SetAccountPasswordRequiredRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_SetAccountPasswordRequiredRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_AuthenticateDevice : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_AuthenticateDeviceRequest * body;
}
@property (retain) LibreAccessServiceSvc_AuthenticateDeviceRequest * body;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	body:(LibreAccessServiceSvc_AuthenticateDeviceRequest *)aBody
;
@end
@interface LibreAccessServiceSoap11Binding_ListContentMetadata : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_ListContentMetadata * body;
}
@property (retain) LibreAccessServiceSvc_ListContentMetadata * body;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	body:(LibreAccessServiceSvc_ListContentMetadata *)aBody
;
@end
@interface LibreAccessServiceSoap11Binding_ListApplicationSettings : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_ListApplicationSettingsRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_ListApplicationSettingsRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_ListApplicationSettingsRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_SaveUserSettings : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_SaveUserSettingsRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_SaveUserSettingsRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_SaveUserSettingsRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_ListTopFavorites : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_ListTopFavoritesRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_ListTopFavoritesRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_ListTopFavoritesRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_ListLastNProfileReadBooks : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_ListLastNProfileReadBooksRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_ListLastNProfileReadBooksRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_ListLastNProfileReadBooksRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_SaveUserProfiles : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_SaveUserProfilesRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_SaveUserProfilesRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_SaveUserProfilesRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_GetUserProfiles : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_GetUserProfilesRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_GetUserProfilesRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_GetUserProfilesRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_DeleteBookShelfEntry : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_DeleteBookShelfEntryRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_DeleteBookShelfEntryRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_DeleteBookShelfEntryRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_ListUserSettings : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_ListUserSettingsRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_ListUserSettingsRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_ListUserSettingsRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_IsEntitledToLicense : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_EntitledToLicenceRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_EntitledToLicenceRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_EntitledToLicenceRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_RemoveOrder : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_RemoveOrderRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_RemoveOrderRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_RemoveOrderRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_ListProfileContentAnnotations : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_ListProfileContentAnnotationsRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_ListProfileContentAnnotationsRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_ListProfileContentAnnotationsRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_ListUserContent : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_ListUserContent * body;
}
@property (retain) LibreAccessServiceSvc_ListUserContent * body;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	body:(LibreAccessServiceSvc_ListUserContent *)aBody
;
@end
@interface LibreAccessServiceSoap11Binding_ListFavoriteTypes : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_ListFavoriteTypesRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_ListFavoriteTypesRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_ListFavoriteTypesRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_GetKeyId : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_GetKeyIdRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_GetKeyIdRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_GetKeyIdRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_SaveDefaultBooks : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_SaveDefaultBooksRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_SaveDefaultBooksRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_SaveDefaultBooksRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_SetAccountAutoAssign : LibreAccessServiceSoap11BindingOperation {
	LibreAccessServiceSvc_SetAccountAutoAssignRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_SetAccountAutoAssignRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_SetAccountAutoAssignRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap11Binding_envelope : NSObject {
}
+ (LibreAccessServiceSoap11Binding_envelope *)sharedInstance;
- (NSString *)serializedFormUsingHeaderElements:(NSDictionary *)headerElements bodyElements:(NSDictionary *)bodyElements;
@end
@interface LibreAccessServiceSoap11BindingResponse : NSObject {
	NSArray *headers;
	NSArray *bodyParts;
	NSError *error;
}
@property (retain) NSArray *headers;
@property (retain) NSArray *bodyParts;
@property (retain) NSError *error;
@end
//@class LibreAccessServiceSoap11BindingResponse;
//@class LibreAccessServiceSoap11BindingOperation;
//@protocol LibreAccessServiceSoap11BindingResponseDelegate <NSObject>
//- (void) operation:(LibreAccessServiceSoap11BindingOperation *)operation completedWithResponse:(LibreAccessServiceSoap11BindingResponse *)response;
//@end
//@interface LibreAccessServiceSoap11Binding : NSObject <LibreAccessServiceSoap11BindingResponseDelegate> {
//	NSURL *address;
//	NSTimeInterval defaultTimeout;
//	NSMutableArray *cookies;
//	BOOL logXMLInOut;
//	BOOL synchronousOperationComplete;
//	NSString *authUsername;
//	NSString *authPassword;
//}
//@property (copy) NSURL *address;
//@property (assign) BOOL logXMLInOut;
//@property (assign) NSTimeInterval defaultTimeout;
//@property (nonatomic, retain) NSMutableArray *cookies;
//@property (nonatomic, retain) NSString *authUsername;
//@property (nonatomic, retain) NSString *authPassword;
//- (id)initWithAddress:(NSString *)anAddress;
//- (void)sendHTTPCallUsingBody:(NSString *)body soapAction:(NSString *)soapAction forOperation:(LibreAccessServiceSoap11BindingOperation *)operation;
//- (void)addCookie:(NSHTTPCookie *)toAdd;
//- (LibreAccessServiceSoap11BindingResponse *)ValidateScreenNameUsingParameters:(LibreAccessServiceSvc_ValidateScreenNameRequest *)aParameters ;
//- (void)ValidateScreenNameAsyncUsingParameters:(LibreAccessServiceSvc_ValidateScreenNameRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap11BindingResponse *)ValidateUserKeyUsingParameters:(LibreAccessServiceSvc_ValidateUserKeyRequest *)aParameters ;
//- (void)ValidateUserKeyAsyncUsingParameters:(LibreAccessServiceSvc_ValidateUserKeyRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap11BindingResponse *)AcknowledgeLicenseUsingParameters:(LibreAccessServiceSvc_AcknowledgeLicenseRequest *)aParameters ;
//- (void)AcknowledgeLicenseAsyncUsingParameters:(LibreAccessServiceSvc_AcknowledgeLicenseRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap11BindingResponse *)SharedTokenExchangeUsingBody:(LibreAccessServiceSvc_SharedTokenExchangeRequest *)aBody ;
//- (void)SharedTokenExchangeAsyncUsingBody:(LibreAccessServiceSvc_SharedTokenExchangeRequest *)aBody  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap11BindingResponse *)SaveUserCSRNotesUsingParameters:(LibreAccessServiceSvc_SaveUserCSRNotesRequest *)aParameters ;
//- (void)SaveUserCSRNotesAsyncUsingParameters:(LibreAccessServiceSvc_SaveUserCSRNotesRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap11BindingResponse *)HealthCheckUsing;
//- (void)HealthCheckAsyncUsing delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap11BindingResponse *)SaveNewDomainUsingParameters:(LibreAccessServiceSvc_SaveNewDomainRequest *)aParameters ;
//- (void)SaveNewDomainAsyncUsingParameters:(LibreAccessServiceSvc_SaveNewDomainRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap11BindingResponse *)ListDefaultBooksUsingParameters:(LibreAccessServiceSvc_ListDefaultBooksRequest *)aParameters ;
//- (void)ListDefaultBooksAsyncUsingParameters:(LibreAccessServiceSvc_ListDefaultBooksRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap11BindingResponse *)ListReadingStatisticsDetailedUsingParameters:(LibreAccessServiceSvc_ListReadingStatisticsDetailedRequest *)aParameters ;
//- (void)ListReadingStatisticsDetailedAsyncUsingParameters:(LibreAccessServiceSvc_ListReadingStatisticsDetailedRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap11BindingResponse *)DeviceCanJoinDomainUsingParameters:(LibreAccessServiceSvc_DeviceCanJoinDomainRequest *)aParameters ;
//- (void)DeviceCanJoinDomainAsyncUsingParameters:(LibreAccessServiceSvc_DeviceCanJoinDomainRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap11BindingResponse *)AssignBooksToAllUsersUsingParameters:(LibreAccessServiceSvc_AssignBooksToAllUsersRequest *)aParameters ;
//- (void)AssignBooksToAllUsersAsyncUsingParameters:(LibreAccessServiceSvc_AssignBooksToAllUsersRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap11BindingResponse *)GetLastPageLocationUsingParameters:(LibreAccessServiceSvc_GetLastPageLocationRequest *)aParameters ;
//- (void)GetLastPageLocationAsyncUsingParameters:(LibreAccessServiceSvc_GetLastPageLocationRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap11BindingResponse *)SaveProfileContentAnnotationsUsingParameters:(LibreAccessServiceSvc_SaveProfileContentAnnotationsRequest *)aParameters ;
//- (void)SaveProfileContentAnnotationsAsyncUsingParameters:(LibreAccessServiceSvc_SaveProfileContentAnnotationsRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap11BindingResponse *)RemoveDefaultBooksUsingParameters:(LibreAccessServiceSvc_RemoveDefaultBooksRequest *)aParameters ;
//- (void)RemoveDefaultBooksAsyncUsingParameters:(LibreAccessServiceSvc_RemoveDefaultBooksRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap11BindingResponse *)GetLicensableStatusUsingParameters:(LibreAccessServiceSvc_GetLicensableStatusRequest *)aParameters ;
//- (void)GetLicensableStatusAsyncUsingParameters:(LibreAccessServiceSvc_GetLicensableStatusRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap11BindingResponse *)SaveLastPageLocationUsingParameters:(LibreAccessServiceSvc_SaveLastPageLocationRequest *)aParameters ;
//- (void)SaveLastPageLocationAsyncUsingParameters:(LibreAccessServiceSvc_SaveLastPageLocationRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap11BindingResponse *)ListUserCSRNotesUsingParameters:(LibreAccessServiceSvc_ListUserCSRNotesRequest *)aParameters ;
//- (void)ListUserCSRNotesAsyncUsingParameters:(LibreAccessServiceSvc_ListUserCSRNotesRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap11BindingResponse *)RenewTokenUsingBody:(LibreAccessServiceSvc_RenewTokenRequest *)aBody ;
//- (void)RenewTokenAsyncUsingBody:(LibreAccessServiceSvc_RenewTokenRequest *)aBody  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap11BindingResponse *)SaveDeviceInfoUsingParameters:(LibreAccessServiceSvc_SaveDeviceInfoRequest *)aParameters ;
//- (void)SaveDeviceInfoAsyncUsingParameters:(LibreAccessServiceSvc_SaveDeviceInfoRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap11BindingResponse *)ListReadingStatisticsAggregateUsingParameters:(LibreAccessServiceSvc_ListReadingStatisticsAggregateRequest *)aParameters ;
//- (void)ListReadingStatisticsAggregateAsyncUsingParameters:(LibreAccessServiceSvc_ListReadingStatisticsAggregateRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap11BindingResponse *)ListLastNWordsUsingParameters:(LibreAccessServiceSvc_ListLastNWordsRequest *)aParameters ;
//- (void)ListLastNWordsAsyncUsingParameters:(LibreAccessServiceSvc_ListLastNWordsRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap11BindingResponse *)DeviceLeftDomainUsingParameters:(LibreAccessServiceSvc_DeviceLeftDomainRequest *)aParameters ;
//- (void)DeviceLeftDomainAsyncUsingParameters:(LibreAccessServiceSvc_DeviceLeftDomainRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap11BindingResponse *)ListReadBooksUsingParameters:(LibreAccessServiceSvc_ListReadBooksRequest *)aParameters ;
//- (void)ListReadBooksAsyncUsingParameters:(LibreAccessServiceSvc_ListReadBooksRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap11BindingResponse *)GetDeviceInfoUsingParameters:(LibreAccessServiceSvc_GetDeviceInfoRequest *)aParameters ;
//- (void)GetDeviceInfoAsyncUsingParameters:(LibreAccessServiceSvc_GetDeviceInfoRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap11BindingResponse *)SaveReadingStatisticsDetailedUsingParameters:(LibreAccessServiceSvc_SaveReadingStatisticsDetailedRequest *)aParameters ;
//- (void)SaveReadingStatisticsDetailedAsyncUsingParameters:(LibreAccessServiceSvc_SaveReadingStatisticsDetailedRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap11BindingResponse *)SaveContentProfileAssignmentUsingParameters:(LibreAccessServiceSvc_SaveContentProfileAssignmentRequest *)aParameters ;
//- (void)SaveContentProfileAssignmentAsyncUsingParameters:(LibreAccessServiceSvc_SaveContentProfileAssignmentRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap11BindingResponse *)TokenExchangeUsingBody:(LibreAccessServiceSvc_TokenExchange *)aBody ;
//- (void)TokenExchangeAsyncUsingBody:(LibreAccessServiceSvc_TokenExchange *)aBody  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap11BindingResponse *)SetAccountPasswordRequiredUsingParameters:(LibreAccessServiceSvc_SetAccountPasswordRequiredRequest *)aParameters ;
//- (void)SetAccountPasswordRequiredAsyncUsingParameters:(LibreAccessServiceSvc_SetAccountPasswordRequiredRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap11BindingResponse *)AuthenticateDeviceUsingBody:(LibreAccessServiceSvc_AuthenticateDeviceRequest *)aBody ;
//- (void)AuthenticateDeviceAsyncUsingBody:(LibreAccessServiceSvc_AuthenticateDeviceRequest *)aBody  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap11BindingResponse *)ListContentMetadataUsingBody:(LibreAccessServiceSvc_ListContentMetadata *)aBody ;
//- (void)ListContentMetadataAsyncUsingBody:(LibreAccessServiceSvc_ListContentMetadata *)aBody  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap11BindingResponse *)ListApplicationSettingsUsingParameters:(LibreAccessServiceSvc_ListApplicationSettingsRequest *)aParameters ;
//- (void)ListApplicationSettingsAsyncUsingParameters:(LibreAccessServiceSvc_ListApplicationSettingsRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap11BindingResponse *)SaveUserSettingsUsingParameters:(LibreAccessServiceSvc_SaveUserSettingsRequest *)aParameters ;
//- (void)SaveUserSettingsAsyncUsingParameters:(LibreAccessServiceSvc_SaveUserSettingsRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap11BindingResponse *)ListTopFavoritesUsingParameters:(LibreAccessServiceSvc_ListTopFavoritesRequest *)aParameters ;
//- (void)ListTopFavoritesAsyncUsingParameters:(LibreAccessServiceSvc_ListTopFavoritesRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap11BindingResponse *)ListLastNProfileReadBooksUsingParameters:(LibreAccessServiceSvc_ListLastNProfileReadBooksRequest *)aParameters ;
//- (void)ListLastNProfileReadBooksAsyncUsingParameters:(LibreAccessServiceSvc_ListLastNProfileReadBooksRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap11BindingResponse *)SaveUserProfilesUsingParameters:(LibreAccessServiceSvc_SaveUserProfilesRequest *)aParameters ;
//- (void)SaveUserProfilesAsyncUsingParameters:(LibreAccessServiceSvc_SaveUserProfilesRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap11BindingResponse *)GetUserProfilesUsingParameters:(LibreAccessServiceSvc_GetUserProfilesRequest *)aParameters ;
//- (void)GetUserProfilesAsyncUsingParameters:(LibreAccessServiceSvc_GetUserProfilesRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap11BindingResponse *)DeleteBookShelfEntryUsingParameters:(LibreAccessServiceSvc_DeleteBookShelfEntryRequest *)aParameters ;
//- (void)DeleteBookShelfEntryAsyncUsingParameters:(LibreAccessServiceSvc_DeleteBookShelfEntryRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap11BindingResponse *)ListUserSettingsUsingParameters:(LibreAccessServiceSvc_ListUserSettingsRequest *)aParameters ;
//- (void)ListUserSettingsAsyncUsingParameters:(LibreAccessServiceSvc_ListUserSettingsRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap11BindingResponse *)IsEntitledToLicenseUsingParameters:(LibreAccessServiceSvc_EntitledToLicenceRequest *)aParameters ;
//- (void)IsEntitledToLicenseAsyncUsingParameters:(LibreAccessServiceSvc_EntitledToLicenceRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap11BindingResponse *)RemoveOrderUsingParameters:(LibreAccessServiceSvc_RemoveOrderRequest *)aParameters ;
//- (void)RemoveOrderAsyncUsingParameters:(LibreAccessServiceSvc_RemoveOrderRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap11BindingResponse *)ListProfileContentAnnotationsUsingParameters:(LibreAccessServiceSvc_ListProfileContentAnnotationsRequest *)aParameters ;
//- (void)ListProfileContentAnnotationsAsyncUsingParameters:(LibreAccessServiceSvc_ListProfileContentAnnotationsRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap11BindingResponse *)ListUserContentUsingBody:(LibreAccessServiceSvc_ListUserContent *)aBody ;
//- (void)ListUserContentAsyncUsingBody:(LibreAccessServiceSvc_ListUserContent *)aBody  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap11BindingResponse *)ListFavoriteTypesUsingParameters:(LibreAccessServiceSvc_ListFavoriteTypesRequest *)aParameters ;
//- (void)ListFavoriteTypesAsyncUsingParameters:(LibreAccessServiceSvc_ListFavoriteTypesRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap11BindingResponse *)GetKeyIdUsingParameters:(LibreAccessServiceSvc_GetKeyIdRequest *)aParameters ;
//- (void)GetKeyIdAsyncUsingParameters:(LibreAccessServiceSvc_GetKeyIdRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap11BindingResponse *)SaveDefaultBooksUsingParameters:(LibreAccessServiceSvc_SaveDefaultBooksRequest *)aParameters ;
//- (void)SaveDefaultBooksAsyncUsingParameters:(LibreAccessServiceSvc_SaveDefaultBooksRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap11BindingResponse *)SetAccountAutoAssignUsingParameters:(LibreAccessServiceSvc_SetAccountAutoAssignRequest *)aParameters ;
//- (void)SetAccountAutoAssignAsyncUsingParameters:(LibreAccessServiceSvc_SetAccountAutoAssignRequest *)aParameters  delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)responseDelegate;
//@end
//@interface LibreAccessServiceSoap11BindingOperation : NSOperation {
//	LibreAccessServiceSoap11Binding *binding;
//	LibreAccessServiceSoap11BindingResponse *response;
//	id<LibreAccessServiceSoap11BindingResponseDelegate> delegate;
//	NSMutableData *responseData;
//	NSURLConnection *urlConnection;
//}
//@property (retain) LibreAccessServiceSoap11Binding *binding;
//@property (readonly) LibreAccessServiceSoap11BindingResponse *response;
//@property (nonatomic, assign) id<LibreAccessServiceSoap11BindingResponseDelegate> delegate;
//@property (nonatomic, retain) NSMutableData *responseData;
//@property (nonatomic, retain) NSURLConnection *urlConnection;
//- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate;
//@end
//@interface LibreAccessServiceSoap11Binding_ValidateScreenName : LibreAccessServiceSoap11BindingOperation {
//	LibreAccessServiceSvc_ValidateScreenNameRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_ValidateScreenNameRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_ValidateScreenNameRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap11Binding_ValidateUserKey : LibreAccessServiceSoap11BindingOperation {
//	LibreAccessServiceSvc_ValidateUserKeyRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_ValidateUserKeyRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_ValidateUserKeyRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap11Binding_AcknowledgeLicense : LibreAccessServiceSoap11BindingOperation {
//	LibreAccessServiceSvc_AcknowledgeLicenseRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_AcknowledgeLicenseRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_AcknowledgeLicenseRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap11Binding_SharedTokenExchange : LibreAccessServiceSoap11BindingOperation {
//	LibreAccessServiceSvc_SharedTokenExchangeRequest * body;
//}
//@property (retain) LibreAccessServiceSvc_SharedTokenExchangeRequest * body;
//- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
//	body:(LibreAccessServiceSvc_SharedTokenExchangeRequest *)aBody
//;
//@end
//@interface LibreAccessServiceSoap11Binding_SaveUserCSRNotes : LibreAccessServiceSoap11BindingOperation {
//	LibreAccessServiceSvc_SaveUserCSRNotesRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_SaveUserCSRNotesRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_SaveUserCSRNotesRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap11Binding_HealthCheck : LibreAccessServiceSoap11BindingOperation {
//}
//- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
//;
//@end
//@interface LibreAccessServiceSoap11Binding_SaveNewDomain : LibreAccessServiceSoap11BindingOperation {
//	LibreAccessServiceSvc_SaveNewDomainRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_SaveNewDomainRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_SaveNewDomainRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap11Binding_ListDefaultBooks : LibreAccessServiceSoap11BindingOperation {
//	LibreAccessServiceSvc_ListDefaultBooksRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_ListDefaultBooksRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_ListDefaultBooksRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap11Binding_ListReadingStatisticsDetailed : LibreAccessServiceSoap11BindingOperation {
//	LibreAccessServiceSvc_ListReadingStatisticsDetailedRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_ListReadingStatisticsDetailedRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_ListReadingStatisticsDetailedRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap11Binding_DeviceCanJoinDomain : LibreAccessServiceSoap11BindingOperation {
//	LibreAccessServiceSvc_DeviceCanJoinDomainRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_DeviceCanJoinDomainRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_DeviceCanJoinDomainRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap11Binding_AssignBooksToAllUsers : LibreAccessServiceSoap11BindingOperation {
//	LibreAccessServiceSvc_AssignBooksToAllUsersRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_AssignBooksToAllUsersRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_AssignBooksToAllUsersRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap11Binding_GetLastPageLocation : LibreAccessServiceSoap11BindingOperation {
//	LibreAccessServiceSvc_GetLastPageLocationRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_GetLastPageLocationRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_GetLastPageLocationRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap11Binding_SaveProfileContentAnnotations : LibreAccessServiceSoap11BindingOperation {
//	LibreAccessServiceSvc_SaveProfileContentAnnotationsRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_SaveProfileContentAnnotationsRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_SaveProfileContentAnnotationsRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap11Binding_RemoveDefaultBooks : LibreAccessServiceSoap11BindingOperation {
//	LibreAccessServiceSvc_RemoveDefaultBooksRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_RemoveDefaultBooksRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_RemoveDefaultBooksRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap11Binding_GetLicensableStatus : LibreAccessServiceSoap11BindingOperation {
//	LibreAccessServiceSvc_GetLicensableStatusRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_GetLicensableStatusRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_GetLicensableStatusRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap11Binding_SaveLastPageLocation : LibreAccessServiceSoap11BindingOperation {
//	LibreAccessServiceSvc_SaveLastPageLocationRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_SaveLastPageLocationRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_SaveLastPageLocationRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap11Binding_ListUserCSRNotes : LibreAccessServiceSoap11BindingOperation {
//	LibreAccessServiceSvc_ListUserCSRNotesRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_ListUserCSRNotesRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_ListUserCSRNotesRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap11Binding_RenewToken : LibreAccessServiceSoap11BindingOperation {
//	LibreAccessServiceSvc_RenewTokenRequest * body;
//}
//@property (retain) LibreAccessServiceSvc_RenewTokenRequest * body;
//- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
//	body:(LibreAccessServiceSvc_RenewTokenRequest *)aBody
//;
//@end
//@interface LibreAccessServiceSoap11Binding_SaveDeviceInfo : LibreAccessServiceSoap11BindingOperation {
//	LibreAccessServiceSvc_SaveDeviceInfoRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_SaveDeviceInfoRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_SaveDeviceInfoRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap11Binding_ListReadingStatisticsAggregate : LibreAccessServiceSoap11BindingOperation {
//	LibreAccessServiceSvc_ListReadingStatisticsAggregateRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_ListReadingStatisticsAggregateRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_ListReadingStatisticsAggregateRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap11Binding_ListLastNWords : LibreAccessServiceSoap11BindingOperation {
//	LibreAccessServiceSvc_ListLastNWordsRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_ListLastNWordsRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_ListLastNWordsRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap11Binding_DeviceLeftDomain : LibreAccessServiceSoap11BindingOperation {
//	LibreAccessServiceSvc_DeviceLeftDomainRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_DeviceLeftDomainRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_DeviceLeftDomainRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap11Binding_ListReadBooks : LibreAccessServiceSoap11BindingOperation {
//	LibreAccessServiceSvc_ListReadBooksRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_ListReadBooksRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_ListReadBooksRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap11Binding_GetDeviceInfo : LibreAccessServiceSoap11BindingOperation {
//	LibreAccessServiceSvc_GetDeviceInfoRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_GetDeviceInfoRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_GetDeviceInfoRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap11Binding_SaveReadingStatisticsDetailed : LibreAccessServiceSoap11BindingOperation {
//	LibreAccessServiceSvc_SaveReadingStatisticsDetailedRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_SaveReadingStatisticsDetailedRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_SaveReadingStatisticsDetailedRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap11Binding_SaveContentProfileAssignment : LibreAccessServiceSoap11BindingOperation {
//	LibreAccessServiceSvc_SaveContentProfileAssignmentRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_SaveContentProfileAssignmentRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_SaveContentProfileAssignmentRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap11Binding_TokenExchange : LibreAccessServiceSoap11BindingOperation {
//	LibreAccessServiceSvc_TokenExchange * body;
//}
//@property (retain) LibreAccessServiceSvc_TokenExchange * body;
//- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
//	body:(LibreAccessServiceSvc_TokenExchange *)aBody
//;
//@end
//@interface LibreAccessServiceSoap11Binding_SetAccountPasswordRequired : LibreAccessServiceSoap11BindingOperation {
//	LibreAccessServiceSvc_SetAccountPasswordRequiredRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_SetAccountPasswordRequiredRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_SetAccountPasswordRequiredRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap11Binding_AuthenticateDevice : LibreAccessServiceSoap11BindingOperation {
//	LibreAccessServiceSvc_AuthenticateDeviceRequest * body;
//}
//@property (retain) LibreAccessServiceSvc_AuthenticateDeviceRequest * body;
//- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
//	body:(LibreAccessServiceSvc_AuthenticateDeviceRequest *)aBody
//;
//@end
//@interface LibreAccessServiceSoap11Binding_ListContentMetadata : LibreAccessServiceSoap11BindingOperation {
//	LibreAccessServiceSvc_ListContentMetadata * body;
//}
//@property (retain) LibreAccessServiceSvc_ListContentMetadata * body;
//- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
//	body:(LibreAccessServiceSvc_ListContentMetadata *)aBody
//;
//@end
//@interface LibreAccessServiceSoap11Binding_ListApplicationSettings : LibreAccessServiceSoap11BindingOperation {
//	LibreAccessServiceSvc_ListApplicationSettingsRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_ListApplicationSettingsRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_ListApplicationSettingsRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap11Binding_SaveUserSettings : LibreAccessServiceSoap11BindingOperation {
//	LibreAccessServiceSvc_SaveUserSettingsRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_SaveUserSettingsRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_SaveUserSettingsRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap11Binding_ListTopFavorites : LibreAccessServiceSoap11BindingOperation {
//	LibreAccessServiceSvc_ListTopFavoritesRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_ListTopFavoritesRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_ListTopFavoritesRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap11Binding_ListLastNProfileReadBooks : LibreAccessServiceSoap11BindingOperation {
//	LibreAccessServiceSvc_ListLastNProfileReadBooksRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_ListLastNProfileReadBooksRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_ListLastNProfileReadBooksRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap11Binding_SaveUserProfiles : LibreAccessServiceSoap11BindingOperation {
//	LibreAccessServiceSvc_SaveUserProfilesRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_SaveUserProfilesRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_SaveUserProfilesRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap11Binding_GetUserProfiles : LibreAccessServiceSoap11BindingOperation {
//	LibreAccessServiceSvc_GetUserProfilesRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_GetUserProfilesRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_GetUserProfilesRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap11Binding_DeleteBookShelfEntry : LibreAccessServiceSoap11BindingOperation {
//	LibreAccessServiceSvc_DeleteBookShelfEntryRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_DeleteBookShelfEntryRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_DeleteBookShelfEntryRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap11Binding_ListUserSettings : LibreAccessServiceSoap11BindingOperation {
//	LibreAccessServiceSvc_ListUserSettingsRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_ListUserSettingsRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_ListUserSettingsRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap11Binding_IsEntitledToLicense : LibreAccessServiceSoap11BindingOperation {
//	LibreAccessServiceSvc_EntitledToLicenceRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_EntitledToLicenceRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_EntitledToLicenceRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap11Binding_RemoveOrder : LibreAccessServiceSoap11BindingOperation {
//	LibreAccessServiceSvc_RemoveOrderRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_RemoveOrderRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_RemoveOrderRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap11Binding_ListProfileContentAnnotations : LibreAccessServiceSoap11BindingOperation {
//	LibreAccessServiceSvc_ListProfileContentAnnotationsRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_ListProfileContentAnnotationsRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_ListProfileContentAnnotationsRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap11Binding_ListUserContent : LibreAccessServiceSoap11BindingOperation {
//	LibreAccessServiceSvc_ListUserContent * body;
//}
//@property (retain) LibreAccessServiceSvc_ListUserContent * body;
//- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
//	body:(LibreAccessServiceSvc_ListUserContent *)aBody
//;
//@end
//@interface LibreAccessServiceSoap11Binding_ListFavoriteTypes : LibreAccessServiceSoap11BindingOperation {
//	LibreAccessServiceSvc_ListFavoriteTypesRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_ListFavoriteTypesRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_ListFavoriteTypesRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap11Binding_GetKeyId : LibreAccessServiceSoap11BindingOperation {
//	LibreAccessServiceSvc_GetKeyIdRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_GetKeyIdRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_GetKeyIdRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap11Binding_SaveDefaultBooks : LibreAccessServiceSoap11BindingOperation {
//	LibreAccessServiceSvc_SaveDefaultBooksRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_SaveDefaultBooksRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_SaveDefaultBooksRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap11Binding_SetAccountAutoAssign : LibreAccessServiceSoap11BindingOperation {
//	LibreAccessServiceSvc_SetAccountAutoAssignRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_SetAccountAutoAssignRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap11Binding *)aBinding delegate:(id<LibreAccessServiceSoap11BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_SetAccountAutoAssignRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap11Binding_envelope : NSObject {
//}
//+ (LibreAccessServiceSoap11Binding_envelope *)sharedInstance;
//- (NSString *)serializedFormUsingHeaderElements:(NSDictionary *)headerElements bodyElements:(NSDictionary *)bodyElements;
//@end
//@interface LibreAccessServiceSoap11BindingResponse : NSObject {
//	NSArray *headers;
//	NSArray *bodyParts;
//	NSError *error;
//}
//@property (retain) NSArray *headers;
//@property (retain) NSArray *bodyParts;
//@property (retain) NSError *error;
//@end
@class LibreAccessServiceSoap12BindingResponse;
@class LibreAccessServiceSoap12BindingOperation;
@protocol LibreAccessServiceSoap12BindingResponseDelegate <NSObject>
- (void) operation:(LibreAccessServiceSoap12BindingOperation *)operation completedWithResponse:(LibreAccessServiceSoap12BindingResponse *)response;
@end
@interface LibreAccessServiceSoap12Binding : NSObject <LibreAccessServiceSoap12BindingResponseDelegate> {
	NSURL *address;
	NSTimeInterval defaultTimeout;
	NSMutableArray *cookies;
	BOOL logXMLInOut;
	BOOL synchronousOperationComplete;
	NSString *authUsername;
	NSString *authPassword;
}
@property (copy) NSURL *address;
@property (assign) BOOL logXMLInOut;
@property (assign) NSTimeInterval defaultTimeout;
@property (nonatomic, retain) NSMutableArray *cookies;
@property (nonatomic, retain) NSString *authUsername;
@property (nonatomic, retain) NSString *authPassword;
- (id)initWithAddress:(NSString *)anAddress;
- (void)sendHTTPCallUsingBody:(NSString *)body soapAction:(NSString *)soapAction forOperation:(LibreAccessServiceSoap12BindingOperation *)operation;
- (void)addCookie:(NSHTTPCookie *)toAdd;
- (LibreAccessServiceSoap12BindingResponse *)ValidateScreenNameUsingParameters:(LibreAccessServiceSvc_ValidateScreenNameRequest *)aParameters ;
- (void)ValidateScreenNameAsyncUsingParameters:(LibreAccessServiceSvc_ValidateScreenNameRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap12BindingResponse *)ValidateUserKeyUsingParameters:(LibreAccessServiceSvc_ValidateUserKeyRequest *)aParameters ;
- (void)ValidateUserKeyAsyncUsingParameters:(LibreAccessServiceSvc_ValidateUserKeyRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap12BindingResponse *)AcknowledgeLicenseUsingParameters:(LibreAccessServiceSvc_AcknowledgeLicenseRequest *)aParameters ;
- (void)AcknowledgeLicenseAsyncUsingParameters:(LibreAccessServiceSvc_AcknowledgeLicenseRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap12BindingResponse *)SharedTokenExchangeUsingBody:(LibreAccessServiceSvc_SharedTokenExchangeRequest *)aBody ;
- (void)SharedTokenExchangeAsyncUsingBody:(LibreAccessServiceSvc_SharedTokenExchangeRequest *)aBody  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap12BindingResponse *)SaveUserCSRNotesUsingParameters:(LibreAccessServiceSvc_SaveUserCSRNotesRequest *)aParameters ;
- (void)SaveUserCSRNotesAsyncUsingParameters:(LibreAccessServiceSvc_SaveUserCSRNotesRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap12BindingResponse *)HealthCheckUsing;
- (void)HealthCheckAsyncUsing:(id)noParameter delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap12BindingResponse *)SaveNewDomainUsingParameters:(LibreAccessServiceSvc_SaveNewDomainRequest *)aParameters ;
- (void)SaveNewDomainAsyncUsingParameters:(LibreAccessServiceSvc_SaveNewDomainRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap12BindingResponse *)ListDefaultBooksUsingParameters:(LibreAccessServiceSvc_ListDefaultBooksRequest *)aParameters ;
- (void)ListDefaultBooksAsyncUsingParameters:(LibreAccessServiceSvc_ListDefaultBooksRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap12BindingResponse *)ListReadingStatisticsDetailedUsingParameters:(LibreAccessServiceSvc_ListReadingStatisticsDetailedRequest *)aParameters ;
- (void)ListReadingStatisticsDetailedAsyncUsingParameters:(LibreAccessServiceSvc_ListReadingStatisticsDetailedRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap12BindingResponse *)DeviceCanJoinDomainUsingParameters:(LibreAccessServiceSvc_DeviceCanJoinDomainRequest *)aParameters ;
- (void)DeviceCanJoinDomainAsyncUsingParameters:(LibreAccessServiceSvc_DeviceCanJoinDomainRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap12BindingResponse *)AssignBooksToAllUsersUsingParameters:(LibreAccessServiceSvc_AssignBooksToAllUsersRequest *)aParameters ;
- (void)AssignBooksToAllUsersAsyncUsingParameters:(LibreAccessServiceSvc_AssignBooksToAllUsersRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap12BindingResponse *)GetLastPageLocationUsingParameters:(LibreAccessServiceSvc_GetLastPageLocationRequest *)aParameters ;
- (void)GetLastPageLocationAsyncUsingParameters:(LibreAccessServiceSvc_GetLastPageLocationRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap12BindingResponse *)SaveProfileContentAnnotationsUsingParameters:(LibreAccessServiceSvc_SaveProfileContentAnnotationsRequest *)aParameters ;
- (void)SaveProfileContentAnnotationsAsyncUsingParameters:(LibreAccessServiceSvc_SaveProfileContentAnnotationsRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap12BindingResponse *)RemoveDefaultBooksUsingParameters:(LibreAccessServiceSvc_RemoveDefaultBooksRequest *)aParameters ;
- (void)RemoveDefaultBooksAsyncUsingParameters:(LibreAccessServiceSvc_RemoveDefaultBooksRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap12BindingResponse *)GetLicensableStatusUsingParameters:(LibreAccessServiceSvc_GetLicensableStatusRequest *)aParameters ;
- (void)GetLicensableStatusAsyncUsingParameters:(LibreAccessServiceSvc_GetLicensableStatusRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap12BindingResponse *)SaveLastPageLocationUsingParameters:(LibreAccessServiceSvc_SaveLastPageLocationRequest *)aParameters ;
- (void)SaveLastPageLocationAsyncUsingParameters:(LibreAccessServiceSvc_SaveLastPageLocationRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap12BindingResponse *)ListUserCSRNotesUsingParameters:(LibreAccessServiceSvc_ListUserCSRNotesRequest *)aParameters ;
- (void)ListUserCSRNotesAsyncUsingParameters:(LibreAccessServiceSvc_ListUserCSRNotesRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap12BindingResponse *)RenewTokenUsingBody:(LibreAccessServiceSvc_RenewTokenRequest *)aBody ;
- (void)RenewTokenAsyncUsingBody:(LibreAccessServiceSvc_RenewTokenRequest *)aBody  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap12BindingResponse *)SaveDeviceInfoUsingParameters:(LibreAccessServiceSvc_SaveDeviceInfoRequest *)aParameters ;
- (void)SaveDeviceInfoAsyncUsingParameters:(LibreAccessServiceSvc_SaveDeviceInfoRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap12BindingResponse *)ListReadingStatisticsAggregateUsingParameters:(LibreAccessServiceSvc_ListReadingStatisticsAggregateRequest *)aParameters ;
- (void)ListReadingStatisticsAggregateAsyncUsingParameters:(LibreAccessServiceSvc_ListReadingStatisticsAggregateRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap12BindingResponse *)ListLastNWordsUsingParameters:(LibreAccessServiceSvc_ListLastNWordsRequest *)aParameters ;
- (void)ListLastNWordsAsyncUsingParameters:(LibreAccessServiceSvc_ListLastNWordsRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap12BindingResponse *)DeviceLeftDomainUsingParameters:(LibreAccessServiceSvc_DeviceLeftDomainRequest *)aParameters ;
- (void)DeviceLeftDomainAsyncUsingParameters:(LibreAccessServiceSvc_DeviceLeftDomainRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap12BindingResponse *)ListReadBooksUsingParameters:(LibreAccessServiceSvc_ListReadBooksRequest *)aParameters ;
- (void)ListReadBooksAsyncUsingParameters:(LibreAccessServiceSvc_ListReadBooksRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap12BindingResponse *)GetDeviceInfoUsingParameters:(LibreAccessServiceSvc_GetDeviceInfoRequest *)aParameters ;
- (void)GetDeviceInfoAsyncUsingParameters:(LibreAccessServiceSvc_GetDeviceInfoRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap12BindingResponse *)SaveReadingStatisticsDetailedUsingParameters:(LibreAccessServiceSvc_SaveReadingStatisticsDetailedRequest *)aParameters ;
- (void)SaveReadingStatisticsDetailedAsyncUsingParameters:(LibreAccessServiceSvc_SaveReadingStatisticsDetailedRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap12BindingResponse *)SaveContentProfileAssignmentUsingParameters:(LibreAccessServiceSvc_SaveContentProfileAssignmentRequest *)aParameters ;
- (void)SaveContentProfileAssignmentAsyncUsingParameters:(LibreAccessServiceSvc_SaveContentProfileAssignmentRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap12BindingResponse *)TokenExchangeUsingBody:(LibreAccessServiceSvc_TokenExchange *)aBody ;
- (void)TokenExchangeAsyncUsingBody:(LibreAccessServiceSvc_TokenExchange *)aBody  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap12BindingResponse *)SetAccountPasswordRequiredUsingParameters:(LibreAccessServiceSvc_SetAccountPasswordRequiredRequest *)aParameters ;
- (void)SetAccountPasswordRequiredAsyncUsingParameters:(LibreAccessServiceSvc_SetAccountPasswordRequiredRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap12BindingResponse *)AuthenticateDeviceUsingBody:(LibreAccessServiceSvc_AuthenticateDeviceRequest *)aBody ;
- (void)AuthenticateDeviceAsyncUsingBody:(LibreAccessServiceSvc_AuthenticateDeviceRequest *)aBody  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap12BindingResponse *)ListContentMetadataUsingBody:(LibreAccessServiceSvc_ListContentMetadata *)aBody ;
- (void)ListContentMetadataAsyncUsingBody:(LibreAccessServiceSvc_ListContentMetadata *)aBody  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap12BindingResponse *)ListApplicationSettingsUsingParameters:(LibreAccessServiceSvc_ListApplicationSettingsRequest *)aParameters ;
- (void)ListApplicationSettingsAsyncUsingParameters:(LibreAccessServiceSvc_ListApplicationSettingsRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap12BindingResponse *)SaveUserSettingsUsingParameters:(LibreAccessServiceSvc_SaveUserSettingsRequest *)aParameters ;
- (void)SaveUserSettingsAsyncUsingParameters:(LibreAccessServiceSvc_SaveUserSettingsRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap12BindingResponse *)ListTopFavoritesUsingParameters:(LibreAccessServiceSvc_ListTopFavoritesRequest *)aParameters ;
- (void)ListTopFavoritesAsyncUsingParameters:(LibreAccessServiceSvc_ListTopFavoritesRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap12BindingResponse *)ListLastNProfileReadBooksUsingParameters:(LibreAccessServiceSvc_ListLastNProfileReadBooksRequest *)aParameters ;
- (void)ListLastNProfileReadBooksAsyncUsingParameters:(LibreAccessServiceSvc_ListLastNProfileReadBooksRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap12BindingResponse *)SaveUserProfilesUsingParameters:(LibreAccessServiceSvc_SaveUserProfilesRequest *)aParameters ;
- (void)SaveUserProfilesAsyncUsingParameters:(LibreAccessServiceSvc_SaveUserProfilesRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap12BindingResponse *)GetUserProfilesUsingParameters:(LibreAccessServiceSvc_GetUserProfilesRequest *)aParameters ;
- (void)GetUserProfilesAsyncUsingParameters:(LibreAccessServiceSvc_GetUserProfilesRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap12BindingResponse *)DeleteBookShelfEntryUsingParameters:(LibreAccessServiceSvc_DeleteBookShelfEntryRequest *)aParameters ;
- (void)DeleteBookShelfEntryAsyncUsingParameters:(LibreAccessServiceSvc_DeleteBookShelfEntryRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap12BindingResponse *)ListUserSettingsUsingParameters:(LibreAccessServiceSvc_ListUserSettingsRequest *)aParameters ;
- (void)ListUserSettingsAsyncUsingParameters:(LibreAccessServiceSvc_ListUserSettingsRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap12BindingResponse *)IsEntitledToLicenseUsingParameters:(LibreAccessServiceSvc_EntitledToLicenceRequest *)aParameters ;
- (void)IsEntitledToLicenseAsyncUsingParameters:(LibreAccessServiceSvc_EntitledToLicenceRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap12BindingResponse *)RemoveOrderUsingParameters:(LibreAccessServiceSvc_RemoveOrderRequest *)aParameters ;
- (void)RemoveOrderAsyncUsingParameters:(LibreAccessServiceSvc_RemoveOrderRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap12BindingResponse *)ListProfileContentAnnotationsUsingParameters:(LibreAccessServiceSvc_ListProfileContentAnnotationsRequest *)aParameters ;
- (void)ListProfileContentAnnotationsAsyncUsingParameters:(LibreAccessServiceSvc_ListProfileContentAnnotationsRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap12BindingResponse *)ListUserContentUsingBody:(LibreAccessServiceSvc_ListUserContent *)aBody ;
- (void)ListUserContentAsyncUsingBody:(LibreAccessServiceSvc_ListUserContent *)aBody  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap12BindingResponse *)ListFavoriteTypesUsingParameters:(LibreAccessServiceSvc_ListFavoriteTypesRequest *)aParameters ;
- (void)ListFavoriteTypesAsyncUsingParameters:(LibreAccessServiceSvc_ListFavoriteTypesRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap12BindingResponse *)GetKeyIdUsingParameters:(LibreAccessServiceSvc_GetKeyIdRequest *)aParameters ;
- (void)GetKeyIdAsyncUsingParameters:(LibreAccessServiceSvc_GetKeyIdRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap12BindingResponse *)SaveDefaultBooksUsingParameters:(LibreAccessServiceSvc_SaveDefaultBooksRequest *)aParameters ;
- (void)SaveDefaultBooksAsyncUsingParameters:(LibreAccessServiceSvc_SaveDefaultBooksRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
- (LibreAccessServiceSoap12BindingResponse *)SetAccountAutoAssignUsingParameters:(LibreAccessServiceSvc_SetAccountAutoAssignRequest *)aParameters ;
- (void)SetAccountAutoAssignAsyncUsingParameters:(LibreAccessServiceSvc_SetAccountAutoAssignRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
@end
@interface LibreAccessServiceSoap12BindingOperation : NSOperation {
	LibreAccessServiceSoap12Binding *binding;
	LibreAccessServiceSoap12BindingResponse *response;
	id<LibreAccessServiceSoap12BindingResponseDelegate> delegate;
	NSMutableData *responseData;
	NSURLConnection *urlConnection;
}
@property (retain) LibreAccessServiceSoap12Binding *binding;
@property (readonly) LibreAccessServiceSoap12BindingResponse *response;
@property (nonatomic, assign) id<LibreAccessServiceSoap12BindingResponseDelegate> delegate;
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, retain) NSURLConnection *urlConnection;
- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate;
@end
@interface LibreAccessServiceSoap12Binding_ValidateScreenName : LibreAccessServiceSoap12BindingOperation {
	LibreAccessServiceSvc_ValidateScreenNameRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_ValidateScreenNameRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_ValidateScreenNameRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap12Binding_ValidateUserKey : LibreAccessServiceSoap12BindingOperation {
	LibreAccessServiceSvc_ValidateUserKeyRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_ValidateUserKeyRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_ValidateUserKeyRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap12Binding_AcknowledgeLicense : LibreAccessServiceSoap12BindingOperation {
	LibreAccessServiceSvc_AcknowledgeLicenseRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_AcknowledgeLicenseRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_AcknowledgeLicenseRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap12Binding_SharedTokenExchange : LibreAccessServiceSoap12BindingOperation {
	LibreAccessServiceSvc_SharedTokenExchangeRequest * body;
}
@property (retain) LibreAccessServiceSvc_SharedTokenExchangeRequest * body;
- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
	body:(LibreAccessServiceSvc_SharedTokenExchangeRequest *)aBody
;
@end
@interface LibreAccessServiceSoap12Binding_SaveUserCSRNotes : LibreAccessServiceSoap12BindingOperation {
	LibreAccessServiceSvc_SaveUserCSRNotesRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_SaveUserCSRNotesRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_SaveUserCSRNotesRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap12Binding_HealthCheck : LibreAccessServiceSoap12BindingOperation {
}
- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
;
@end
@interface LibreAccessServiceSoap12Binding_SaveNewDomain : LibreAccessServiceSoap12BindingOperation {
	LibreAccessServiceSvc_SaveNewDomainRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_SaveNewDomainRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_SaveNewDomainRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap12Binding_ListDefaultBooks : LibreAccessServiceSoap12BindingOperation {
	LibreAccessServiceSvc_ListDefaultBooksRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_ListDefaultBooksRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_ListDefaultBooksRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap12Binding_ListReadingStatisticsDetailed : LibreAccessServiceSoap12BindingOperation {
	LibreAccessServiceSvc_ListReadingStatisticsDetailedRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_ListReadingStatisticsDetailedRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_ListReadingStatisticsDetailedRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap12Binding_DeviceCanJoinDomain : LibreAccessServiceSoap12BindingOperation {
	LibreAccessServiceSvc_DeviceCanJoinDomainRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_DeviceCanJoinDomainRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_DeviceCanJoinDomainRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap12Binding_AssignBooksToAllUsers : LibreAccessServiceSoap12BindingOperation {
	LibreAccessServiceSvc_AssignBooksToAllUsersRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_AssignBooksToAllUsersRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_AssignBooksToAllUsersRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap12Binding_GetLastPageLocation : LibreAccessServiceSoap12BindingOperation {
	LibreAccessServiceSvc_GetLastPageLocationRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_GetLastPageLocationRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_GetLastPageLocationRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap12Binding_SaveProfileContentAnnotations : LibreAccessServiceSoap12BindingOperation {
	LibreAccessServiceSvc_SaveProfileContentAnnotationsRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_SaveProfileContentAnnotationsRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_SaveProfileContentAnnotationsRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap12Binding_RemoveDefaultBooks : LibreAccessServiceSoap12BindingOperation {
	LibreAccessServiceSvc_RemoveDefaultBooksRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_RemoveDefaultBooksRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_RemoveDefaultBooksRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap12Binding_GetLicensableStatus : LibreAccessServiceSoap12BindingOperation {
	LibreAccessServiceSvc_GetLicensableStatusRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_GetLicensableStatusRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_GetLicensableStatusRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap12Binding_SaveLastPageLocation : LibreAccessServiceSoap12BindingOperation {
	LibreAccessServiceSvc_SaveLastPageLocationRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_SaveLastPageLocationRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_SaveLastPageLocationRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap12Binding_ListUserCSRNotes : LibreAccessServiceSoap12BindingOperation {
	LibreAccessServiceSvc_ListUserCSRNotesRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_ListUserCSRNotesRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_ListUserCSRNotesRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap12Binding_RenewToken : LibreAccessServiceSoap12BindingOperation {
	LibreAccessServiceSvc_RenewTokenRequest * body;
}
@property (retain) LibreAccessServiceSvc_RenewTokenRequest * body;
- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
	body:(LibreAccessServiceSvc_RenewTokenRequest *)aBody
;
@end
@interface LibreAccessServiceSoap12Binding_SaveDeviceInfo : LibreAccessServiceSoap12BindingOperation {
	LibreAccessServiceSvc_SaveDeviceInfoRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_SaveDeviceInfoRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_SaveDeviceInfoRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap12Binding_ListReadingStatisticsAggregate : LibreAccessServiceSoap12BindingOperation {
	LibreAccessServiceSvc_ListReadingStatisticsAggregateRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_ListReadingStatisticsAggregateRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_ListReadingStatisticsAggregateRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap12Binding_ListLastNWords : LibreAccessServiceSoap12BindingOperation {
	LibreAccessServiceSvc_ListLastNWordsRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_ListLastNWordsRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_ListLastNWordsRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap12Binding_DeviceLeftDomain : LibreAccessServiceSoap12BindingOperation {
	LibreAccessServiceSvc_DeviceLeftDomainRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_DeviceLeftDomainRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_DeviceLeftDomainRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap12Binding_ListReadBooks : LibreAccessServiceSoap12BindingOperation {
	LibreAccessServiceSvc_ListReadBooksRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_ListReadBooksRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_ListReadBooksRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap12Binding_GetDeviceInfo : LibreAccessServiceSoap12BindingOperation {
	LibreAccessServiceSvc_GetDeviceInfoRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_GetDeviceInfoRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_GetDeviceInfoRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap12Binding_SaveReadingStatisticsDetailed : LibreAccessServiceSoap12BindingOperation {
	LibreAccessServiceSvc_SaveReadingStatisticsDetailedRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_SaveReadingStatisticsDetailedRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_SaveReadingStatisticsDetailedRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap12Binding_SaveContentProfileAssignment : LibreAccessServiceSoap12BindingOperation {
	LibreAccessServiceSvc_SaveContentProfileAssignmentRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_SaveContentProfileAssignmentRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_SaveContentProfileAssignmentRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap12Binding_TokenExchange : LibreAccessServiceSoap12BindingOperation {
	LibreAccessServiceSvc_TokenExchange * body;
}
@property (retain) LibreAccessServiceSvc_TokenExchange * body;
- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
	body:(LibreAccessServiceSvc_TokenExchange *)aBody
;
@end
@interface LibreAccessServiceSoap12Binding_SetAccountPasswordRequired : LibreAccessServiceSoap12BindingOperation {
	LibreAccessServiceSvc_SetAccountPasswordRequiredRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_SetAccountPasswordRequiredRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_SetAccountPasswordRequiredRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap12Binding_AuthenticateDevice : LibreAccessServiceSoap12BindingOperation {
	LibreAccessServiceSvc_AuthenticateDeviceRequest * body;
}
@property (retain) LibreAccessServiceSvc_AuthenticateDeviceRequest * body;
- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
	body:(LibreAccessServiceSvc_AuthenticateDeviceRequest *)aBody
;
@end
@interface LibreAccessServiceSoap12Binding_ListContentMetadata : LibreAccessServiceSoap12BindingOperation {
	LibreAccessServiceSvc_ListContentMetadata * body;
}
@property (retain) LibreAccessServiceSvc_ListContentMetadata * body;
- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
	body:(LibreAccessServiceSvc_ListContentMetadata *)aBody
;
@end
@interface LibreAccessServiceSoap12Binding_ListApplicationSettings : LibreAccessServiceSoap12BindingOperation {
	LibreAccessServiceSvc_ListApplicationSettingsRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_ListApplicationSettingsRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_ListApplicationSettingsRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap12Binding_SaveUserSettings : LibreAccessServiceSoap12BindingOperation {
	LibreAccessServiceSvc_SaveUserSettingsRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_SaveUserSettingsRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_SaveUserSettingsRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap12Binding_ListTopFavorites : LibreAccessServiceSoap12BindingOperation {
	LibreAccessServiceSvc_ListTopFavoritesRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_ListTopFavoritesRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_ListTopFavoritesRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap12Binding_ListLastNProfileReadBooks : LibreAccessServiceSoap12BindingOperation {
	LibreAccessServiceSvc_ListLastNProfileReadBooksRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_ListLastNProfileReadBooksRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_ListLastNProfileReadBooksRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap12Binding_SaveUserProfiles : LibreAccessServiceSoap12BindingOperation {
	LibreAccessServiceSvc_SaveUserProfilesRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_SaveUserProfilesRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_SaveUserProfilesRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap12Binding_GetUserProfiles : LibreAccessServiceSoap12BindingOperation {
	LibreAccessServiceSvc_GetUserProfilesRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_GetUserProfilesRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_GetUserProfilesRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap12Binding_DeleteBookShelfEntry : LibreAccessServiceSoap12BindingOperation {
	LibreAccessServiceSvc_DeleteBookShelfEntryRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_DeleteBookShelfEntryRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_DeleteBookShelfEntryRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap12Binding_ListUserSettings : LibreAccessServiceSoap12BindingOperation {
	LibreAccessServiceSvc_ListUserSettingsRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_ListUserSettingsRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_ListUserSettingsRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap12Binding_IsEntitledToLicense : LibreAccessServiceSoap12BindingOperation {
	LibreAccessServiceSvc_EntitledToLicenceRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_EntitledToLicenceRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_EntitledToLicenceRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap12Binding_RemoveOrder : LibreAccessServiceSoap12BindingOperation {
	LibreAccessServiceSvc_RemoveOrderRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_RemoveOrderRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_RemoveOrderRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap12Binding_ListProfileContentAnnotations : LibreAccessServiceSoap12BindingOperation {
	LibreAccessServiceSvc_ListProfileContentAnnotationsRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_ListProfileContentAnnotationsRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_ListProfileContentAnnotationsRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap12Binding_ListUserContent : LibreAccessServiceSoap12BindingOperation {
	LibreAccessServiceSvc_ListUserContent * body;
}
@property (retain) LibreAccessServiceSvc_ListUserContent * body;
- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
	body:(LibreAccessServiceSvc_ListUserContent *)aBody
;
@end
@interface LibreAccessServiceSoap12Binding_ListFavoriteTypes : LibreAccessServiceSoap12BindingOperation {
	LibreAccessServiceSvc_ListFavoriteTypesRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_ListFavoriteTypesRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_ListFavoriteTypesRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap12Binding_GetKeyId : LibreAccessServiceSoap12BindingOperation {
	LibreAccessServiceSvc_GetKeyIdRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_GetKeyIdRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_GetKeyIdRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap12Binding_SaveDefaultBooks : LibreAccessServiceSoap12BindingOperation {
	LibreAccessServiceSvc_SaveDefaultBooksRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_SaveDefaultBooksRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_SaveDefaultBooksRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap12Binding_SetAccountAutoAssign : LibreAccessServiceSoap12BindingOperation {
	LibreAccessServiceSvc_SetAccountAutoAssignRequest * parameters;
}
@property (retain) LibreAccessServiceSvc_SetAccountAutoAssignRequest * parameters;
- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessServiceSvc_SetAccountAutoAssignRequest *)aParameters
;
@end
@interface LibreAccessServiceSoap12Binding_envelope : NSObject {
}
+ (LibreAccessServiceSoap12Binding_envelope *)sharedInstance;
- (NSString *)serializedFormUsingHeaderElements:(NSDictionary *)headerElements bodyElements:(NSDictionary *)bodyElements;
@end
@interface LibreAccessServiceSoap12BindingResponse : NSObject {
	NSArray *headers;
	NSArray *bodyParts;
	NSError *error;
}
@property (retain) NSArray *headers;
@property (retain) NSArray *bodyParts;
@property (retain) NSError *error;
@end
//@class LibreAccessServiceSoap12BindingResponse;
//@class LibreAccessServiceSoap12BindingOperation;
// @protocol LibreAccessServiceSoap12BindingResponseDelegate <NSObject>
// - (void) operation:(LibreAccessServiceSoap12BindingOperation *)operation completedWithResponse:(LibreAccessServiceSoap12BindingResponse *)response;
// @end
//@interface LibreAccessServiceSoap12Binding : NSObject <LibreAccessServiceSoap12BindingResponseDelegate> {
//	NSURL *address;
//	NSTimeInterval defaultTimeout;
//	NSMutableArray *cookies;
//	BOOL logXMLInOut;
//	BOOL synchronousOperationComplete;
//	NSString *authUsername;
//	NSString *authPassword;
//}
//@property (copy) NSURL *address;
//@property (assign) BOOL logXMLInOut;
//@property (assign) NSTimeInterval defaultTimeout;
//@property (nonatomic, retain) NSMutableArray *cookies;
//@property (nonatomic, retain) NSString *authUsername;
//@property (nonatomic, retain) NSString *authPassword;
//- (id)initWithAddress:(NSString *)anAddress;
//- (void)sendHTTPCallUsingBody:(NSString *)body soapAction:(NSString *)soapAction forOperation:(LibreAccessServiceSoap12BindingOperation *)operation;
//- (void)addCookie:(NSHTTPCookie *)toAdd;
//- (LibreAccessServiceSoap12BindingResponse *)ValidateScreenNameUsingParameters:(LibreAccessServiceSvc_ValidateScreenNameRequest *)aParameters ;
//- (void)ValidateScreenNameAsyncUsingParameters:(LibreAccessServiceSvc_ValidateScreenNameRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap12BindingResponse *)ValidateUserKeyUsingParameters:(LibreAccessServiceSvc_ValidateUserKeyRequest *)aParameters ;
//- (void)ValidateUserKeyAsyncUsingParameters:(LibreAccessServiceSvc_ValidateUserKeyRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap12BindingResponse *)AcknowledgeLicenseUsingParameters:(LibreAccessServiceSvc_AcknowledgeLicenseRequest *)aParameters ;
//- (void)AcknowledgeLicenseAsyncUsingParameters:(LibreAccessServiceSvc_AcknowledgeLicenseRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap12BindingResponse *)SharedTokenExchangeUsingBody:(LibreAccessServiceSvc_SharedTokenExchangeRequest *)aBody ;
//- (void)SharedTokenExchangeAsyncUsingBody:(LibreAccessServiceSvc_SharedTokenExchangeRequest *)aBody  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap12BindingResponse *)SaveUserCSRNotesUsingParameters:(LibreAccessServiceSvc_SaveUserCSRNotesRequest *)aParameters ;
//- (void)SaveUserCSRNotesAsyncUsingParameters:(LibreAccessServiceSvc_SaveUserCSRNotesRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap12BindingResponse *)HealthCheckUsing;
//- (void)HealthCheckAsyncUsing delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap12BindingResponse *)SaveNewDomainUsingParameters:(LibreAccessServiceSvc_SaveNewDomainRequest *)aParameters ;
//- (void)SaveNewDomainAsyncUsingParameters:(LibreAccessServiceSvc_SaveNewDomainRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap12BindingResponse *)ListDefaultBooksUsingParameters:(LibreAccessServiceSvc_ListDefaultBooksRequest *)aParameters ;
//- (void)ListDefaultBooksAsyncUsingParameters:(LibreAccessServiceSvc_ListDefaultBooksRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap12BindingResponse *)ListReadingStatisticsDetailedUsingParameters:(LibreAccessServiceSvc_ListReadingStatisticsDetailedRequest *)aParameters ;
//- (void)ListReadingStatisticsDetailedAsyncUsingParameters:(LibreAccessServiceSvc_ListReadingStatisticsDetailedRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap12BindingResponse *)DeviceCanJoinDomainUsingParameters:(LibreAccessServiceSvc_DeviceCanJoinDomainRequest *)aParameters ;
//- (void)DeviceCanJoinDomainAsyncUsingParameters:(LibreAccessServiceSvc_DeviceCanJoinDomainRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap12BindingResponse *)AssignBooksToAllUsersUsingParameters:(LibreAccessServiceSvc_AssignBooksToAllUsersRequest *)aParameters ;
//- (void)AssignBooksToAllUsersAsyncUsingParameters:(LibreAccessServiceSvc_AssignBooksToAllUsersRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap12BindingResponse *)GetLastPageLocationUsingParameters:(LibreAccessServiceSvc_GetLastPageLocationRequest *)aParameters ;
//- (void)GetLastPageLocationAsyncUsingParameters:(LibreAccessServiceSvc_GetLastPageLocationRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap12BindingResponse *)SaveProfileContentAnnotationsUsingParameters:(LibreAccessServiceSvc_SaveProfileContentAnnotationsRequest *)aParameters ;
//- (void)SaveProfileContentAnnotationsAsyncUsingParameters:(LibreAccessServiceSvc_SaveProfileContentAnnotationsRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap12BindingResponse *)RemoveDefaultBooksUsingParameters:(LibreAccessServiceSvc_RemoveDefaultBooksRequest *)aParameters ;
//- (void)RemoveDefaultBooksAsyncUsingParameters:(LibreAccessServiceSvc_RemoveDefaultBooksRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap12BindingResponse *)GetLicensableStatusUsingParameters:(LibreAccessServiceSvc_GetLicensableStatusRequest *)aParameters ;
//- (void)GetLicensableStatusAsyncUsingParameters:(LibreAccessServiceSvc_GetLicensableStatusRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap12BindingResponse *)SaveLastPageLocationUsingParameters:(LibreAccessServiceSvc_SaveLastPageLocationRequest *)aParameters ;
//- (void)SaveLastPageLocationAsyncUsingParameters:(LibreAccessServiceSvc_SaveLastPageLocationRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap12BindingResponse *)ListUserCSRNotesUsingParameters:(LibreAccessServiceSvc_ListUserCSRNotesRequest *)aParameters ;
//- (void)ListUserCSRNotesAsyncUsingParameters:(LibreAccessServiceSvc_ListUserCSRNotesRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap12BindingResponse *)RenewTokenUsingBody:(LibreAccessServiceSvc_RenewTokenRequest *)aBody ;
//- (void)RenewTokenAsyncUsingBody:(LibreAccessServiceSvc_RenewTokenRequest *)aBody  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap12BindingResponse *)SaveDeviceInfoUsingParameters:(LibreAccessServiceSvc_SaveDeviceInfoRequest *)aParameters ;
//- (void)SaveDeviceInfoAsyncUsingParameters:(LibreAccessServiceSvc_SaveDeviceInfoRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap12BindingResponse *)ListReadingStatisticsAggregateUsingParameters:(LibreAccessServiceSvc_ListReadingStatisticsAggregateRequest *)aParameters ;
//- (void)ListReadingStatisticsAggregateAsyncUsingParameters:(LibreAccessServiceSvc_ListReadingStatisticsAggregateRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap12BindingResponse *)ListLastNWordsUsingParameters:(LibreAccessServiceSvc_ListLastNWordsRequest *)aParameters ;
//- (void)ListLastNWordsAsyncUsingParameters:(LibreAccessServiceSvc_ListLastNWordsRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap12BindingResponse *)DeviceLeftDomainUsingParameters:(LibreAccessServiceSvc_DeviceLeftDomainRequest *)aParameters ;
//- (void)DeviceLeftDomainAsyncUsingParameters:(LibreAccessServiceSvc_DeviceLeftDomainRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap12BindingResponse *)ListReadBooksUsingParameters:(LibreAccessServiceSvc_ListReadBooksRequest *)aParameters ;
//- (void)ListReadBooksAsyncUsingParameters:(LibreAccessServiceSvc_ListReadBooksRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap12BindingResponse *)GetDeviceInfoUsingParameters:(LibreAccessServiceSvc_GetDeviceInfoRequest *)aParameters ;
//- (void)GetDeviceInfoAsyncUsingParameters:(LibreAccessServiceSvc_GetDeviceInfoRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap12BindingResponse *)SaveReadingStatisticsDetailedUsingParameters:(LibreAccessServiceSvc_SaveReadingStatisticsDetailedRequest *)aParameters ;
//- (void)SaveReadingStatisticsDetailedAsyncUsingParameters:(LibreAccessServiceSvc_SaveReadingStatisticsDetailedRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap12BindingResponse *)SaveContentProfileAssignmentUsingParameters:(LibreAccessServiceSvc_SaveContentProfileAssignmentRequest *)aParameters ;
//- (void)SaveContentProfileAssignmentAsyncUsingParameters:(LibreAccessServiceSvc_SaveContentProfileAssignmentRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap12BindingResponse *)TokenExchangeUsingBody:(LibreAccessServiceSvc_TokenExchange *)aBody ;
//- (void)TokenExchangeAsyncUsingBody:(LibreAccessServiceSvc_TokenExchange *)aBody  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap12BindingResponse *)SetAccountPasswordRequiredUsingParameters:(LibreAccessServiceSvc_SetAccountPasswordRequiredRequest *)aParameters ;
//- (void)SetAccountPasswordRequiredAsyncUsingParameters:(LibreAccessServiceSvc_SetAccountPasswordRequiredRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap12BindingResponse *)AuthenticateDeviceUsingBody:(LibreAccessServiceSvc_AuthenticateDeviceRequest *)aBody ;
//- (void)AuthenticateDeviceAsyncUsingBody:(LibreAccessServiceSvc_AuthenticateDeviceRequest *)aBody  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap12BindingResponse *)ListContentMetadataUsingBody:(LibreAccessServiceSvc_ListContentMetadata *)aBody ;
//- (void)ListContentMetadataAsyncUsingBody:(LibreAccessServiceSvc_ListContentMetadata *)aBody  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap12BindingResponse *)ListApplicationSettingsUsingParameters:(LibreAccessServiceSvc_ListApplicationSettingsRequest *)aParameters ;
//- (void)ListApplicationSettingsAsyncUsingParameters:(LibreAccessServiceSvc_ListApplicationSettingsRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap12BindingResponse *)SaveUserSettingsUsingParameters:(LibreAccessServiceSvc_SaveUserSettingsRequest *)aParameters ;
//- (void)SaveUserSettingsAsyncUsingParameters:(LibreAccessServiceSvc_SaveUserSettingsRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap12BindingResponse *)ListTopFavoritesUsingParameters:(LibreAccessServiceSvc_ListTopFavoritesRequest *)aParameters ;
//- (void)ListTopFavoritesAsyncUsingParameters:(LibreAccessServiceSvc_ListTopFavoritesRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap12BindingResponse *)ListLastNProfileReadBooksUsingParameters:(LibreAccessServiceSvc_ListLastNProfileReadBooksRequest *)aParameters ;
//- (void)ListLastNProfileReadBooksAsyncUsingParameters:(LibreAccessServiceSvc_ListLastNProfileReadBooksRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap12BindingResponse *)SaveUserProfilesUsingParameters:(LibreAccessServiceSvc_SaveUserProfilesRequest *)aParameters ;
//- (void)SaveUserProfilesAsyncUsingParameters:(LibreAccessServiceSvc_SaveUserProfilesRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap12BindingResponse *)GetUserProfilesUsingParameters:(LibreAccessServiceSvc_GetUserProfilesRequest *)aParameters ;
//- (void)GetUserProfilesAsyncUsingParameters:(LibreAccessServiceSvc_GetUserProfilesRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap12BindingResponse *)DeleteBookShelfEntryUsingParameters:(LibreAccessServiceSvc_DeleteBookShelfEntryRequest *)aParameters ;
//- (void)DeleteBookShelfEntryAsyncUsingParameters:(LibreAccessServiceSvc_DeleteBookShelfEntryRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap12BindingResponse *)ListUserSettingsUsingParameters:(LibreAccessServiceSvc_ListUserSettingsRequest *)aParameters ;
//- (void)ListUserSettingsAsyncUsingParameters:(LibreAccessServiceSvc_ListUserSettingsRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap12BindingResponse *)IsEntitledToLicenseUsingParameters:(LibreAccessServiceSvc_EntitledToLicenceRequest *)aParameters ;
//- (void)IsEntitledToLicenseAsyncUsingParameters:(LibreAccessServiceSvc_EntitledToLicenceRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap12BindingResponse *)RemoveOrderUsingParameters:(LibreAccessServiceSvc_RemoveOrderRequest *)aParameters ;
//- (void)RemoveOrderAsyncUsingParameters:(LibreAccessServiceSvc_RemoveOrderRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap12BindingResponse *)ListProfileContentAnnotationsUsingParameters:(LibreAccessServiceSvc_ListProfileContentAnnotationsRequest *)aParameters ;
//- (void)ListProfileContentAnnotationsAsyncUsingParameters:(LibreAccessServiceSvc_ListProfileContentAnnotationsRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap12BindingResponse *)ListUserContentUsingBody:(LibreAccessServiceSvc_ListUserContent *)aBody ;
//- (void)ListUserContentAsyncUsingBody:(LibreAccessServiceSvc_ListUserContent *)aBody  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap12BindingResponse *)ListFavoriteTypesUsingParameters:(LibreAccessServiceSvc_ListFavoriteTypesRequest *)aParameters ;
//- (void)ListFavoriteTypesAsyncUsingParameters:(LibreAccessServiceSvc_ListFavoriteTypesRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap12BindingResponse *)GetKeyIdUsingParameters:(LibreAccessServiceSvc_GetKeyIdRequest *)aParameters ;
//- (void)GetKeyIdAsyncUsingParameters:(LibreAccessServiceSvc_GetKeyIdRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap12BindingResponse *)SaveDefaultBooksUsingParameters:(LibreAccessServiceSvc_SaveDefaultBooksRequest *)aParameters ;
//- (void)SaveDefaultBooksAsyncUsingParameters:(LibreAccessServiceSvc_SaveDefaultBooksRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
//- (LibreAccessServiceSoap12BindingResponse *)SetAccountAutoAssignUsingParameters:(LibreAccessServiceSvc_SetAccountAutoAssignRequest *)aParameters ;
//- (void)SetAccountAutoAssignAsyncUsingParameters:(LibreAccessServiceSvc_SetAccountAutoAssignRequest *)aParameters  delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)responseDelegate;
//@end
//@interface LibreAccessServiceSoap12BindingOperation : NSOperation {
//	LibreAccessServiceSoap12Binding *binding;
//	LibreAccessServiceSoap12BindingResponse *response;
//	id<LibreAccessServiceSoap12BindingResponseDelegate> delegate;
//	NSMutableData *responseData;
//	NSURLConnection *urlConnection;
//}
//@property (retain) LibreAccessServiceSoap12Binding *binding;
//@property (readonly) LibreAccessServiceSoap12BindingResponse *response;
//@property (nonatomic, assign) id<LibreAccessServiceSoap12BindingResponseDelegate> delegate;
//@property (nonatomic, retain) NSMutableData *responseData;
//@property (nonatomic, retain) NSURLConnection *urlConnection;
//- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate;
//@end
//@interface LibreAccessServiceSoap12Binding_ValidateScreenName : LibreAccessServiceSoap12BindingOperation {
//	LibreAccessServiceSvc_ValidateScreenNameRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_ValidateScreenNameRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_ValidateScreenNameRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap12Binding_ValidateUserKey : LibreAccessServiceSoap12BindingOperation {
//	LibreAccessServiceSvc_ValidateUserKeyRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_ValidateUserKeyRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_ValidateUserKeyRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap12Binding_AcknowledgeLicense : LibreAccessServiceSoap12BindingOperation {
//	LibreAccessServiceSvc_AcknowledgeLicenseRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_AcknowledgeLicenseRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_AcknowledgeLicenseRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap12Binding_SharedTokenExchange : LibreAccessServiceSoap12BindingOperation {
//	LibreAccessServiceSvc_SharedTokenExchangeRequest * body;
//}
//@property (retain) LibreAccessServiceSvc_SharedTokenExchangeRequest * body;
//- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
//	body:(LibreAccessServiceSvc_SharedTokenExchangeRequest *)aBody
//;
//@end
//@interface LibreAccessServiceSoap12Binding_SaveUserCSRNotes : LibreAccessServiceSoap12BindingOperation {
//	LibreAccessServiceSvc_SaveUserCSRNotesRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_SaveUserCSRNotesRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_SaveUserCSRNotesRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap12Binding_HealthCheck : LibreAccessServiceSoap12BindingOperation {
//}
//- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
//;
//@end
//@interface LibreAccessServiceSoap12Binding_SaveNewDomain : LibreAccessServiceSoap12BindingOperation {
//	LibreAccessServiceSvc_SaveNewDomainRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_SaveNewDomainRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_SaveNewDomainRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap12Binding_ListDefaultBooks : LibreAccessServiceSoap12BindingOperation {
//	LibreAccessServiceSvc_ListDefaultBooksRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_ListDefaultBooksRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_ListDefaultBooksRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap12Binding_ListReadingStatisticsDetailed : LibreAccessServiceSoap12BindingOperation {
//	LibreAccessServiceSvc_ListReadingStatisticsDetailedRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_ListReadingStatisticsDetailedRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_ListReadingStatisticsDetailedRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap12Binding_DeviceCanJoinDomain : LibreAccessServiceSoap12BindingOperation {
//	LibreAccessServiceSvc_DeviceCanJoinDomainRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_DeviceCanJoinDomainRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_DeviceCanJoinDomainRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap12Binding_AssignBooksToAllUsers : LibreAccessServiceSoap12BindingOperation {
//	LibreAccessServiceSvc_AssignBooksToAllUsersRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_AssignBooksToAllUsersRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_AssignBooksToAllUsersRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap12Binding_GetLastPageLocation : LibreAccessServiceSoap12BindingOperation {
//	LibreAccessServiceSvc_GetLastPageLocationRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_GetLastPageLocationRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_GetLastPageLocationRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap12Binding_SaveProfileContentAnnotations : LibreAccessServiceSoap12BindingOperation {
//	LibreAccessServiceSvc_SaveProfileContentAnnotationsRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_SaveProfileContentAnnotationsRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_SaveProfileContentAnnotationsRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap12Binding_RemoveDefaultBooks : LibreAccessServiceSoap12BindingOperation {
//	LibreAccessServiceSvc_RemoveDefaultBooksRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_RemoveDefaultBooksRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_RemoveDefaultBooksRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap12Binding_GetLicensableStatus : LibreAccessServiceSoap12BindingOperation {
//	LibreAccessServiceSvc_GetLicensableStatusRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_GetLicensableStatusRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_GetLicensableStatusRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap12Binding_SaveLastPageLocation : LibreAccessServiceSoap12BindingOperation {
//	LibreAccessServiceSvc_SaveLastPageLocationRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_SaveLastPageLocationRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_SaveLastPageLocationRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap12Binding_ListUserCSRNotes : LibreAccessServiceSoap12BindingOperation {
//	LibreAccessServiceSvc_ListUserCSRNotesRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_ListUserCSRNotesRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_ListUserCSRNotesRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap12Binding_RenewToken : LibreAccessServiceSoap12BindingOperation {
//	LibreAccessServiceSvc_RenewTokenRequest * body;
//}
//@property (retain) LibreAccessServiceSvc_RenewTokenRequest * body;
//- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
//	body:(LibreAccessServiceSvc_RenewTokenRequest *)aBody
//;
//@end
//@interface LibreAccessServiceSoap12Binding_SaveDeviceInfo : LibreAccessServiceSoap12BindingOperation {
//	LibreAccessServiceSvc_SaveDeviceInfoRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_SaveDeviceInfoRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_SaveDeviceInfoRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap12Binding_ListReadingStatisticsAggregate : LibreAccessServiceSoap12BindingOperation {
//	LibreAccessServiceSvc_ListReadingStatisticsAggregateRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_ListReadingStatisticsAggregateRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_ListReadingStatisticsAggregateRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap12Binding_ListLastNWords : LibreAccessServiceSoap12BindingOperation {
//	LibreAccessServiceSvc_ListLastNWordsRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_ListLastNWordsRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_ListLastNWordsRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap12Binding_DeviceLeftDomain : LibreAccessServiceSoap12BindingOperation {
//	LibreAccessServiceSvc_DeviceLeftDomainRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_DeviceLeftDomainRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_DeviceLeftDomainRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap12Binding_ListReadBooks : LibreAccessServiceSoap12BindingOperation {
//	LibreAccessServiceSvc_ListReadBooksRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_ListReadBooksRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_ListReadBooksRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap12Binding_GetDeviceInfo : LibreAccessServiceSoap12BindingOperation {
//	LibreAccessServiceSvc_GetDeviceInfoRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_GetDeviceInfoRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_GetDeviceInfoRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap12Binding_SaveReadingStatisticsDetailed : LibreAccessServiceSoap12BindingOperation {
//	LibreAccessServiceSvc_SaveReadingStatisticsDetailedRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_SaveReadingStatisticsDetailedRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_SaveReadingStatisticsDetailedRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap12Binding_SaveContentProfileAssignment : LibreAccessServiceSoap12BindingOperation {
//	LibreAccessServiceSvc_SaveContentProfileAssignmentRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_SaveContentProfileAssignmentRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_SaveContentProfileAssignmentRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap12Binding_TokenExchange : LibreAccessServiceSoap12BindingOperation {
//	LibreAccessServiceSvc_TokenExchange * body;
//}
//@property (retain) LibreAccessServiceSvc_TokenExchange * body;
//- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
//	body:(LibreAccessServiceSvc_TokenExchange *)aBody
//;
//@end
//@interface LibreAccessServiceSoap12Binding_SetAccountPasswordRequired : LibreAccessServiceSoap12BindingOperation {
//	LibreAccessServiceSvc_SetAccountPasswordRequiredRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_SetAccountPasswordRequiredRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_SetAccountPasswordRequiredRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap12Binding_AuthenticateDevice : LibreAccessServiceSoap12BindingOperation {
//	LibreAccessServiceSvc_AuthenticateDeviceRequest * body;
//}
//@property (retain) LibreAccessServiceSvc_AuthenticateDeviceRequest * body;
//- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
//	body:(LibreAccessServiceSvc_AuthenticateDeviceRequest *)aBody
//;
//@end
//@interface LibreAccessServiceSoap12Binding_ListContentMetadata : LibreAccessServiceSoap12BindingOperation {
//	LibreAccessServiceSvc_ListContentMetadata * body;
//}
//@property (retain) LibreAccessServiceSvc_ListContentMetadata * body;
//- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
//	body:(LibreAccessServiceSvc_ListContentMetadata *)aBody
//;
//@end
//@interface LibreAccessServiceSoap12Binding_ListApplicationSettings : LibreAccessServiceSoap12BindingOperation {
//	LibreAccessServiceSvc_ListApplicationSettingsRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_ListApplicationSettingsRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_ListApplicationSettingsRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap12Binding_SaveUserSettings : LibreAccessServiceSoap12BindingOperation {
//	LibreAccessServiceSvc_SaveUserSettingsRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_SaveUserSettingsRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_SaveUserSettingsRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap12Binding_ListTopFavorites : LibreAccessServiceSoap12BindingOperation {
//	LibreAccessServiceSvc_ListTopFavoritesRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_ListTopFavoritesRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_ListTopFavoritesRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap12Binding_ListLastNProfileReadBooks : LibreAccessServiceSoap12BindingOperation {
//	LibreAccessServiceSvc_ListLastNProfileReadBooksRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_ListLastNProfileReadBooksRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_ListLastNProfileReadBooksRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap12Binding_SaveUserProfiles : LibreAccessServiceSoap12BindingOperation {
//	LibreAccessServiceSvc_SaveUserProfilesRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_SaveUserProfilesRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_SaveUserProfilesRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap12Binding_GetUserProfiles : LibreAccessServiceSoap12BindingOperation {
//	LibreAccessServiceSvc_GetUserProfilesRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_GetUserProfilesRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_GetUserProfilesRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap12Binding_DeleteBookShelfEntry : LibreAccessServiceSoap12BindingOperation {
//	LibreAccessServiceSvc_DeleteBookShelfEntryRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_DeleteBookShelfEntryRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_DeleteBookShelfEntryRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap12Binding_ListUserSettings : LibreAccessServiceSoap12BindingOperation {
//	LibreAccessServiceSvc_ListUserSettingsRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_ListUserSettingsRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_ListUserSettingsRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap12Binding_IsEntitledToLicense : LibreAccessServiceSoap12BindingOperation {
//	LibreAccessServiceSvc_EntitledToLicenceRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_EntitledToLicenceRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_EntitledToLicenceRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap12Binding_RemoveOrder : LibreAccessServiceSoap12BindingOperation {
//	LibreAccessServiceSvc_RemoveOrderRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_RemoveOrderRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_RemoveOrderRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap12Binding_ListProfileContentAnnotations : LibreAccessServiceSoap12BindingOperation {
//	LibreAccessServiceSvc_ListProfileContentAnnotationsRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_ListProfileContentAnnotationsRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_ListProfileContentAnnotationsRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap12Binding_ListUserContent : LibreAccessServiceSoap12BindingOperation {
//	LibreAccessServiceSvc_ListUserContent * body;
//}
//@property (retain) LibreAccessServiceSvc_ListUserContent * body;
//- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
//	body:(LibreAccessServiceSvc_ListUserContent *)aBody
//;
//@end
//@interface LibreAccessServiceSoap12Binding_ListFavoriteTypes : LibreAccessServiceSoap12BindingOperation {
//	LibreAccessServiceSvc_ListFavoriteTypesRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_ListFavoriteTypesRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_ListFavoriteTypesRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap12Binding_GetKeyId : LibreAccessServiceSoap12BindingOperation {
//	LibreAccessServiceSvc_GetKeyIdRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_GetKeyIdRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_GetKeyIdRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap12Binding_SaveDefaultBooks : LibreAccessServiceSoap12BindingOperation {
//	LibreAccessServiceSvc_SaveDefaultBooksRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_SaveDefaultBooksRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_SaveDefaultBooksRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap12Binding_SetAccountAutoAssign : LibreAccessServiceSoap12BindingOperation {
//	LibreAccessServiceSvc_SetAccountAutoAssignRequest * parameters;
//}
//@property (retain) LibreAccessServiceSvc_SetAccountAutoAssignRequest * parameters;
//- (id)initWithBinding:(LibreAccessServiceSoap12Binding *)aBinding delegate:(id<LibreAccessServiceSoap12BindingResponseDelegate>)aDelegate
//	parameters:(LibreAccessServiceSvc_SetAccountAutoAssignRequest *)aParameters
//;
//@end
//@interface LibreAccessServiceSoap12Binding_envelope : NSObject {
//}
//+ (LibreAccessServiceSoap12Binding_envelope *)sharedInstance;
//- (NSString *)serializedFormUsingHeaderElements:(NSDictionary *)headerElements bodyElements:(NSDictionary *)bodyElements;
//@end
//@interface LibreAccessServiceSoap12BindingResponse : NSObject {
//	NSArray *headers;
//	NSArray *bodyParts;
//	NSError *error;
//}
//@property (retain) NSArray *headers;
//@property (retain) NSArray *bodyParts;
//@property (retain) NSError *error;
//@end
