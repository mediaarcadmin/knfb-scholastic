#import <Foundation/Foundation.h>
#import "USAdditions.h"
#import <libxml/tree.h>
#import "USGlobals.h"
#import <objc/runtime.h>
@class tns1_DBSchemaErrorList;
@class tns1_DBSchemaErrorItem;
@class tns1_StatusHolder;
@class tns1_ItemsCount;
@class tns1_UserContentItem;
@class tns1_ContentProfileList;
@class tns1_OrderList;
@class tns1_isbnItem;
@class tns1_ContentMetadataItem;
@class tns1_ContentProfileAssignmentList;
@class tns1_ContentProfileAssignmentItem;
@class tns1_AssignedProfileList;
@class tns1_TopRatingsRequestList;
@class tns1_TopRatingsRequestItem;
@class tns1_TopRatingsResponseList;
@class tns1_TopRatingsResponseItem;
@class tns1_TopRatingsContentItems;
@class tns1_TopRatingsContentItem;
@class tns1_AssignedProfileItem;
@class tns1_ContentProfileItem;
@class tns1_OrderItem;
@class tns1_CorpInfo;
@class tns1_OrderSourceInfo;
@class tns1_SaveProfileList;
@class tns1_SaveProfileItem;
@class tns1_ProfileList;
@class tns1_ProfileItem;
@class tns1_ProfileStatusList;
@class tns1_ProfileStatusItem;
@class tns1_DeviceItem;
@class tns1_DeviceList;
@class tns1_AnnotationsRequestList;
@class tns1_AnnotationsRequestItem;
@class tns1_AnnotationsRequestContentList;
@class tns1_AnnotationsRequestContentItem;
@class tns1_PrivateAnnotationsRequest;
@class tns1_AnnotationsList;
@class tns1_AnnotationsItem;
@class tns1_AnnotationsContentList;
@class tns1_AnnotationsContentItem;
@class tns1_PrivateAnnotations;
@class tns1_Highlights;
@class tns1_Notes;
@class tns1_Bookmarks;
@class tns1_LastPage;
@class tns1_Rating;
@class tns1_Highlight;
@class tns1_LocationText;
@class tns1_WordIndex;
@class tns1_Note;
@class tns1_LocationGraphics;
@class tns1_Coords;
@class tns1_Bookmark;
@class tns1_LocationBookmark;
@class tns1_Favorite;
@class tns1_AnnotationStatusList;
@class tns1_AnnotationStatusItem;
@class tns1_AnnotationStatusContentList;
@class tns1_AnnotationStatusContentItem;
@class tns1_PrivateAnnotationsStatus;
@class tns1_AnnotationTypeStatusList;
@class tns1_AnnotationTypeStatusItem;
@class tns1_ReadingStatsAggregateList;
@class tns1_ReadingStatsAggregateItem;
@class tns1_ReadingStatsDetailList;
@class tns1_ReadingStatsDetailItem;
@class tns1_ReadingStatsContentList;
@class tns1_ReadingStatsContentItem;
@class tns1_ReadingStatsEntryList;
@class tns1_ReadingStatsEntryItem;
@class tns1_DictionaryLookupsList;
@class tns1_QuizTrialsList;
@class tns1_QuizTrialsItem;
@class tns1_LookupWordList;
@class tns1_MonthlyAverageProfileList;
@class tns1_MonthlyAverageProfileItem;
@class tns1_MonthlyAverageList;
@class tns1_MonthlyAverageItem;
@class tns1_AggregateByTitleProfileList;
@class tns1_AggregateByTitleProfileItem;
@class tns1_AggregateByTitleList;
@class tns1_AggregateByTitleItem;
@class tns1_BookIdentifier;
@class tns1_QuizItem;
@class tns1_DailyAggregateByTitleProfileList;
@class tns1_DailyAggregateByTitleProfileItem;
@class tns1_DailyAggregateByTitleList;
@class tns1_DailyAggregateByTitleItem;
@class tns1_BookIdentifierList;
@class tns1_BookshelfEntryList;
@class tns1_BookShelfEntryItem;
@class tns1_ProfileIdList;
@class tns1_ProfileBookshelfEntryList;
@class tns1_ProfileBookshelfEntryItem;
@class tns1_BookshelfEntryLastPageList;
@class tns1_BookShelfEntryLastPageItem;
@class tns1_FavoriteTypesList;
@class tns1_FavoriteTypesItem;
@class tns1_FavoriteTypeValuesList;
@class tns1_FavoriteTypesValuesItem;
@class tns1_SettingsList;
@class tns1_SettingItem;
@class tns1_SettingStatusList;
@class tns1_SettingStatusItem;
@class tns1_AutoAssignProfilesList;
@class tns1_AutoAssignProfilesItem;
@class tns1_ReadBooksList;
@class tns1_ReadBooksItem;
@class tns1_ReadBooksProfilesList;
@class tns1_ReadBooksProfilesItem;
@class tns1_LastNRequestReadBooksProfilesList;
@class tns1_LastNRequestReadBooksProfilesItem;
@class tns1_LastNResponseReadBooksProfilesList;
@class tns1_LastNResponseReadBooksProfilesItem;
@class tns1_LastNReadBooksList;
@class tns1_LastNReadBooksItem;
@class tns1_LastNRequestWordsList;
@class tns1_LastNRequestWordsItem;
@class tns1_LastNResponseWordsList;
@class tns1_LastNResponseWordsItem;
@class tns1_LastNLookedUpWordsList;
@class tns1_LastNLookedUpWordsItem;
@class tns1_NotesList;
@class tns1_NoteItem;
@class tns1_DefaultBooksList;
@class tns1_DefaultBooksItem;
@class tns1_AssignBooksToAllUsersList;
@class tns1_AssignBooksToAllUsersItem;
@class tns1_AssignBooksToAllUsersBooksList;
@class tns1_AssignBooksToAllUsersBooksItem;
@class tns1_ListRatingsRequestList;
@class tns1_ListRatingsItem;
@class tns1_ListRatingsContentList;
@class tns1_ListRatingsContentItem;
@class tns1_RatingsStatusList;
@class tns1_RatingsStatusItem;
@class tns1_ProfileRatingsStatusList;
@class tns1_ProfileRatingsStatusItem;
@class tns1_RatingsList;
@class tns1_RatingsItem;
@class tns1_ProfileRatingsList;
@class tns1_ProfileRatingsItem;
@class tns1_TokenExchange;
@class tns1_TokenExchangeResponse;
@class tns1_SharedTokenExchangeRequest;
@class tns1_SharedTokenExchangeResponse;
@class tns1_AuthenticateDeviceRequest;
@class tns1_AuthenticateDeviceResponse;
@class tns1_RenewTokenRequest;
@class tns1_RenewTokenResponse;
@class tns1_ListBooksAssignmentRequest;
@class tns1_ListBooksAssignmentResponse;
@class tns1_booksAssignmentList;
@class tns1_BooksAssignment;
@class tns1_ListUserContent;
@class tns1_ListUserContentResponse;
@class tns1_UserContentList;
@class tns1_ListContentMetadata;
@class tns1_ListContentMetadataResponse;
@class tns1_ContentMetadataList;
@class tns1_IsEntitledToLicenseResponse;
@class tns1_EntitledToLicenseRequest;
@class tns1_SaveReadingStatisticsDetailedRequest;
@class tns1_SaveReadingStatisticsDetailedResponse;
@class tns1_ListReadingStatisticsAggregateRequest;
@class tns1_ListReadingStatisticsAggregateResponse;
@class tns1_ListReadingStatisticsDetailedRequest;
@class tns1_ListReadingStatisticsDetailedResponse;
@class tns1_ListReadingStatisticsMonthlyAverageRequest;
@class tns1_ListReadingStatisticsMonthlyAverageResponse;
@class tns1_ListReadingStatisticsAggregateByTitleRequest;
@class tns1_ListReadingStatisticsAggregateByTitleResponse;
@class tns1_ListReadingStatisticsDailyAggregateByTitleRequest;
@class tns1_ListReadingStatisticsDailyAggregateByTitleResponse;
@class tns1_SaveProfileContentAnnotationsRequest;
@class tns1_SaveProfileContentAnnotationsResponse;
@class tns1_ListProfileContentAnnotationsRequest;
@class tns1_ListProfileContentAnnotationsResponse;
@class tns1_GetUserProfilesRequest;
@class tns1_GetUserProfilesResponse;
@class tns1_SaveUserProfilesRequest;
@class tns1_SaveUserProfilesResponse;
@class tns1_ListApplicationSettingsRequest;
@class tns1_ListApplicationSettingsResponse;
@class tns1_SaveContentProfileAssignmentRequest;
@class tns1_SaveContentProfileAssignmentResponse;
@class tns1_GetDeviceInfoRequest;
@class tns1_GetDeviceInfoResponse;
@class tns1_SaveDeviceInfoRequest;
@class tns1_SaveDeviceInfoResponse;
@class tns1_SaveNewDomainResponse;
@class tns1_SaveNewDomainRequest;
@class tns1_DeviceLeftDomainResponse;
@class tns1_DeviceLeftDomainRequest;
@class tns1_DeviceCanJoinDomainResponse;
@class tns1_DeviceCanJoinDomainRequest;
@class tns1_GetLicensableStatusResponse;
@class tns1_GetLicensableStatusRequest;
@class tns1_AcknowledgeLicenseResponse;
@class tns1_AcknowledgeLicenseRequest;
@class tns1_ValidateScreenNameRequest;
@class tns1_ValidateScreenNameResponse;
@class tns1_ValidateUserKeyRequest;
@class tns1_ValidateUserKeyResponse;
@class tns1_DeleteBookShelfEntryRequest;
@class tns1_DeleteBookShelfEntryResponse;
@class tns1_GetLastPageLocationRequest;
@class tns1_GetLastPageLocationResponse;
@class tns1_SaveLastPageLocationRequest;
@class tns1_SaveLastPageLocationResponse;
@class tns1_ListFavoriteTypesRequest;
@class tns1_ListFavoriteTypesResponse;
@class tns1_SaveUserSettingsRequest;
@class tns1_SaveUserSettingsResponse;
@class tns1_ListUserSettingsRequest;
@class tns1_ListUserSettingsResponse;
@class tns1_SetAccountAutoAssignRequest;
@class tns1_SetAccountAutoAssignResponse;
@class tns1_SetAccountPasswordRequiredRequest;
@class tns1_SetAccountPasswordRequiredResponse;
@class tns1_ListReadBooksRequest;
@class tns1_ListReadBooksResponse;
@class tns1_ListLastNProfileReadBooksRequest;
@class tns1_ListLastNProfileReadBooksResponse;
@class tns1_ListLastNWordsRequest;
@class tns1_ListLastNWordsResponse;
@class tns1_RemoveOrderRequest;
@class tns1_RemoveOrderResponse;
@class tns1_SaveUserCSRNotesRequest;
@class tns1_SaveUserCSRNotesResponse;
@class tns1_ListUserCSRNotesRequest;
@class tns1_ListUserCSRNotesResponse;
@class tns1_GetKeyIdRequest;
@class tns1_GetKeyIdResponse;
@class tns1_SaveDefaultBooksRequest;
@class tns1_SaveDefaultBooksResponse;
@class tns1_ListDefaultBooksRequest;
@class tns1_ListDefaultBooksResponse;
@class tns1_RemoveDefaultBooksRequest;
@class tns1_RemoveDefaultBooksResponse;
@class tns1_AssignBooksToAllUsersRequest;
@class tns1_AssignBooksToAllUsersResponse;
@class tns1_SetLoggingLevelRequest;
@class tns1_SetLoggingLevelResponse;
@class tns1_HealthCheckRequest;
@class tns1_HealthCheckResponse;
@class tns1_EndpointsList;
@class tns1_DBSchemaError;
@class tns1_GetVersionRequest;
@class tns1_GetVersionResponse;
@class tns1_ListTopRatingsRequest;
@class tns1_ListTopRatingsResponse;
@class tns1_SaveRatingsRequest;
@class tns1_SaveRatingsResponse;
@class tns1_ListRatingsRequest;
@class tns1_ListRatingsResponse;
@class tns1_DeregisterAllDevicesRequest;
@class tns1_DeregisterAllDevicesResponse;
typedef enum {
	tns1_statuscodes_none = 0,
	tns1_statuscodes_SUCCESS,
	tns1_statuscodes_FAIL,
} tns1_statuscodes;
tns1_statuscodes tns1_statuscodes_enumFromString(NSString *string);
NSString * tns1_statuscodes_stringFromEnum(tns1_statuscodes enumValue);
typedef enum {
	tns1_ErrorType_none = 0,
	tns1_ErrorType_WARNING,
	tns1_ErrorType_ERROR,
} tns1_ErrorType;
tns1_ErrorType tns1_ErrorType_enumFromString(NSString *string);
NSString * tns1_ErrorType_stringFromEnum(tns1_ErrorType enumValue);
@interface tns1_DBSchemaErrorItem : NSObject <NSCoding> {
/* elements */
	NSString * errorCode;
	NSString * error;
	tns1_ErrorType type;
	NSString * description;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_DBSchemaErrorItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * errorCode;
@property (nonatomic, retain) NSString * error;
@property (nonatomic, assign) tns1_ErrorType type;
@property (nonatomic, retain) NSString * description;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_DBSchemaErrorList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *errorItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_DBSchemaErrorList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addErrorItem:(tns1_DBSchemaErrorItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * errorItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_StatusHolder : NSObject <NSCoding> {
/* elements */
	tns1_statuscodes status;
	NSNumber * statuscode;
	NSString * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_StatusHolder *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, assign) tns1_statuscodes status;
@property (nonatomic, retain) NSNumber * statuscode;
@property (nonatomic, retain) NSString * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ItemsCount : NSObject <NSCoding> {
/* elements */
	NSNumber * Returned;
	NSNumber * Found;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ItemsCount *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * Returned;
@property (nonatomic, retain) NSNumber * Found;
/* attributes */
- (NSDictionary *)attributes;
@end
typedef enum {
	tns1_ProfileTypes_none = 0,
	tns1_ProfileTypes_PARENT,
	tns1_ProfileTypes_CHILD,
} tns1_ProfileTypes;
tns1_ProfileTypes tns1_ProfileTypes_enumFromString(NSString *string);
NSString * tns1_ProfileTypes_stringFromEnum(tns1_ProfileTypes enumValue);
typedef enum {
	tns1_BookshelfStyle_none = 0,
	tns1_BookshelfStyle_YOUNG_CHILD,
	tns1_BookshelfStyle_OLDER_CHILD,
	tns1_BookshelfStyle_ADULT,
} tns1_BookshelfStyle;
tns1_BookshelfStyle tns1_BookshelfStyle_enumFromString(NSString *string);
NSString * tns1_BookshelfStyle_stringFromEnum(tns1_BookshelfStyle enumValue);
typedef enum {
	tns1_ContentIdentifierTypes_none = 0,
	tns1_ContentIdentifierTypes_ISBN13,
} tns1_ContentIdentifierTypes;
tns1_ContentIdentifierTypes tns1_ContentIdentifierTypes_enumFromString(NSString *string);
NSString * tns1_ContentIdentifierTypes_stringFromEnum(tns1_ContentIdentifierTypes enumValue);
typedef enum {
	tns1_drmqualifiers_none = 0,
	tns1_drmqualifiers_FULL_WITH_DRM,
	tns1_drmqualifiers_FULL_NO_DRM,
	tns1_drmqualifiers_SAMPLE,
} tns1_drmqualifiers;
tns1_drmqualifiers tns1_drmqualifiers_enumFromString(NSString *string);
NSString * tns1_drmqualifiers_stringFromEnum(tns1_drmqualifiers enumValue);
@interface tns1_ContentProfileItem : NSObject <NSCoding> {
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
+ (tns1_ContentProfileItem *)deserializeNode:(xmlNodePtr)cur;
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
@interface tns1_ContentProfileList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *contentProfileItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ContentProfileList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addContentProfileItem:(tns1_ContentProfileItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * contentProfileItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_CorpInfo : NSObject <NSCoding> {
/* elements */
	NSString * transactionIdSourceField;
	NSNumber * transactionId;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_CorpInfo *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * transactionIdSourceField;
@property (nonatomic, retain) NSNumber * transactionId;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_OrderSourceInfo : NSObject <NSCoding> {
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
+ (tns1_OrderSourceInfo *)deserializeNode:(xmlNodePtr)cur;
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
@interface tns1_OrderItem : NSObject <NSCoding> {
/* elements */
	tns1_CorpInfo * corpInfo;
	tns1_OrderSourceInfo * orderSourceInfo;
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
+ (tns1_OrderItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) tns1_CorpInfo * corpInfo;
@property (nonatomic, retain) tns1_OrderSourceInfo * orderSourceInfo;
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
@interface tns1_OrderList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *OrderItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_OrderList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addOrderItem:(tns1_OrderItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * OrderItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_UserContentItem : NSObject <NSCoding> {
/* elements */
	NSString * ContentIdentifier;
	tns1_ContentIdentifierTypes ContentIdentifierType;
	tns1_drmqualifiers DRMQualifier;
	NSString * Format;
	NSString * Version;
	NSNumber * AverageRating;
	NSNumber * numVotes;
	tns1_ContentProfileList * ContentProfileForRatingsList;
	tns1_OrderList * OrderList;
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
+ (tns1_UserContentItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * ContentIdentifier;
@property (nonatomic, assign) tns1_ContentIdentifierTypes ContentIdentifierType;
@property (nonatomic, assign) tns1_drmqualifiers DRMQualifier;
@property (nonatomic, retain) NSString * Format;
@property (nonatomic, retain) NSString * Version;
@property (nonatomic, retain) NSNumber * AverageRating;
@property (nonatomic, retain) NSNumber * numVotes;
@property (nonatomic, retain) tns1_ContentProfileList * ContentProfileForRatingsList;
@property (nonatomic, retain) tns1_OrderList * OrderList;
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
	tns1_TopFavoritesTypes_none = 0,
	tns1_TopFavoritesTypes_EREADER_CATEGORY,
	tns1_TopFavoritesTypes_EREADER_CATEGORY_CLASS,
} tns1_TopFavoritesTypes;
tns1_TopFavoritesTypes tns1_TopFavoritesTypes_enumFromString(NSString *string);
NSString * tns1_TopFavoritesTypes_stringFromEnum(tns1_TopFavoritesTypes enumValue);
@interface tns1_isbnItem : NSObject <NSCoding> {
/* elements */
	NSString * ISBN;
	NSString * Format;
	tns1_ContentIdentifierTypes IdentifierType;
	tns1_drmqualifiers Qualifier;
	NSNumber * version;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_isbnItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * ISBN;
@property (nonatomic, retain) NSString * Format;
@property (nonatomic, assign) tns1_ContentIdentifierTypes IdentifierType;
@property (nonatomic, assign) tns1_drmqualifiers Qualifier;
@property (nonatomic, retain) NSNumber * version;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ContentMetadataItem : NSObject <NSCoding> {
/* elements */
	NSString * ContentIdentifier;
	tns1_ContentIdentifierTypes ContentIdentifierType;
	NSNumber * AverageRating;
	NSNumber * numVotes;
	NSString * Title;
	NSString * Author;
	NSString * Description;
	NSString * Version;
	NSNumber * PageNumber;
	NSNumber * FileSize;
	tns1_drmqualifiers DRMQualifier;
	NSString * CoverURL;
	NSString * ContentURL;
	NSMutableArray *EreaderCategories;
	USBoolean * Enhanced;
	NSString * ThumbnailURL;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ContentMetadataItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * ContentIdentifier;
@property (nonatomic, assign) tns1_ContentIdentifierTypes ContentIdentifierType;
@property (nonatomic, retain) NSNumber * AverageRating;
@property (nonatomic, retain) NSNumber * numVotes;
@property (nonatomic, retain) NSString * Title;
@property (nonatomic, retain) NSString * Author;
@property (nonatomic, retain) NSString * Description;
@property (nonatomic, retain) NSString * Version;
@property (nonatomic, retain) NSNumber * PageNumber;
@property (nonatomic, retain) NSNumber * FileSize;
@property (nonatomic, assign) tns1_drmqualifiers DRMQualifier;
@property (nonatomic, retain) NSString * CoverURL;
@property (nonatomic, retain) NSString * ContentURL;
- (void)addEreaderCategories:(NSString *)toAdd;
@property (nonatomic, readonly) NSMutableArray * EreaderCategories;
@property (nonatomic, retain) USBoolean * Enhanced;
@property (nonatomic, retain) NSString * ThumbnailURL;
/* attributes */
- (NSDictionary *)attributes;
@end
typedef enum {
	tns1_SaveActions_none = 0,
	tns1_SaveActions_CREATE,
	tns1_SaveActions_UPDATE,
	tns1_SaveActions_REMOVE,
} tns1_SaveActions;
tns1_SaveActions tns1_SaveActions_enumFromString(NSString *string);
NSString * tns1_SaveActions_stringFromEnum(tns1_SaveActions enumValue);
@interface tns1_AssignedProfileItem : NSObject <NSCoding> {
/* elements */
	NSNumber * profileID;
	tns1_SaveActions action;
	NSDate * lastmodified;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_AssignedProfileItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * profileID;
@property (nonatomic, assign) tns1_SaveActions action;
@property (nonatomic, retain) NSDate * lastmodified;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_AssignedProfileList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *AssignedProfileItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_AssignedProfileList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addAssignedProfileItem:(tns1_AssignedProfileItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * AssignedProfileItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ContentProfileAssignmentItem : NSObject <NSCoding> {
/* elements */
	NSString * contentIdentifier;
	tns1_ContentIdentifierTypes ContentIdentifierType;
	tns1_drmqualifiers drmqualifier;
	NSString * format;
	tns1_AssignedProfileList * AssignedProfileList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ContentProfileAssignmentItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * contentIdentifier;
@property (nonatomic, assign) tns1_ContentIdentifierTypes ContentIdentifierType;
@property (nonatomic, assign) tns1_drmqualifiers drmqualifier;
@property (nonatomic, retain) NSString * format;
@property (nonatomic, retain) tns1_AssignedProfileList * AssignedProfileList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ContentProfileAssignmentList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *ContentProfileAssignmentItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ContentProfileAssignmentList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addContentProfileAssignmentItem:(tns1_ContentProfileAssignmentItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * ContentProfileAssignmentItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_TopRatingsRequestItem : NSObject <NSCoding> {
/* elements */
	tns1_TopFavoritesTypes TopRatingsType;
	NSString * TopRatingsTypeValue;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_TopRatingsRequestItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, assign) tns1_TopFavoritesTypes TopRatingsType;
@property (nonatomic, retain) NSString * TopRatingsTypeValue;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_TopRatingsRequestList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *TopRatingsRequestItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_TopRatingsRequestList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addTopRatingsRequestItem:(tns1_TopRatingsRequestItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * TopRatingsRequestItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_TopRatingsContentItem : NSObject <NSCoding> {
/* elements */
	NSString * ContentIdentifier;
	tns1_ContentIdentifierTypes ContentIdentifierType;
	NSNumber * AverageRating;
	NSNumber * numVotes;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_TopRatingsContentItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * ContentIdentifier;
@property (nonatomic, assign) tns1_ContentIdentifierTypes ContentIdentifierType;
@property (nonatomic, retain) NSNumber * AverageRating;
@property (nonatomic, retain) NSNumber * numVotes;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_TopRatingsContentItems : NSObject <NSCoding> {
/* elements */
	NSMutableArray *TopRatingsContentItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_TopRatingsContentItems *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addTopRatingsContentItem:(tns1_TopRatingsContentItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * TopRatingsContentItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_TopRatingsResponseItem : NSObject <NSCoding> {
/* elements */
	tns1_TopFavoritesTypes TopRatingsType;
	NSString * TopRatingsTypeValue;
	tns1_TopRatingsContentItems * TopRatingsContentItems;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_TopRatingsResponseItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, assign) tns1_TopFavoritesTypes TopRatingsType;
@property (nonatomic, retain) NSString * TopRatingsTypeValue;
@property (nonatomic, retain) tns1_TopRatingsContentItems * TopRatingsContentItems;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_TopRatingsResponseList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *TopRatingsResponseItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_TopRatingsResponseList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addTopRatingsResponseItem:(tns1_TopRatingsResponseItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * TopRatingsResponseItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_SaveProfileItem : NSObject <NSCoding> {
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
	tns1_ProfileTypes type;
	NSNumber * id_;
	tns1_SaveActions action;
	tns1_BookshelfStyle BookshelfStyle;
	USBoolean * storyInteractionEnabled;
	USBoolean * recommendationsOn;
	USBoolean * allowReadThrough;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_SaveProfileItem *)deserializeNode:(xmlNodePtr)cur;
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
@property (nonatomic, assign) tns1_ProfileTypes type;
@property (nonatomic, retain) NSNumber * id_;
@property (nonatomic, assign) tns1_SaveActions action;
@property (nonatomic, assign) tns1_BookshelfStyle BookshelfStyle;
@property (nonatomic, retain) USBoolean * storyInteractionEnabled;
@property (nonatomic, retain) USBoolean * recommendationsOn;
@property (nonatomic, retain) USBoolean * allowReadThrough;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_SaveProfileList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *SaveProfileItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_SaveProfileList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addSaveProfileItem:(tns1_SaveProfileItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * SaveProfileItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ProfileItem : NSObject <NSCoding> {
/* elements */
	USBoolean * AutoAssignContentToProfiles;
	USBoolean * ProfilePasswordRequired;
	NSString * Firstname;
	NSString * Lastname;
	NSDate * BirthDay;
	NSString * screenname;
	NSString * password;
	NSString * userkey;
	tns1_ProfileTypes type;
	NSNumber * id_;
	tns1_BookshelfStyle BookshelfStyle;
	NSDate * LastModified;
	NSDate * LastScreenNameModified;
	NSDate * LastPasswordModified;
	USBoolean * storyInteractionEnabled;
	USBoolean * recommendationsOn;
	USBoolean * allowReadThrough;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ProfileItem *)deserializeNode:(xmlNodePtr)cur;
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
@property (nonatomic, assign) tns1_ProfileTypes type;
@property (nonatomic, retain) NSNumber * id_;
@property (nonatomic, assign) tns1_BookshelfStyle BookshelfStyle;
@property (nonatomic, retain) NSDate * LastModified;
@property (nonatomic, retain) NSDate * LastScreenNameModified;
@property (nonatomic, retain) NSDate * LastPasswordModified;
@property (nonatomic, retain) USBoolean * storyInteractionEnabled;
@property (nonatomic, retain) USBoolean * recommendationsOn;
@property (nonatomic, retain) USBoolean * allowReadThrough;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ProfileList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *ProfileItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ProfileList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addProfileItem:(tns1_ProfileItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * ProfileItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ProfileStatusItem : NSObject <NSCoding> {
/* elements */
	NSNumber * id_;
	tns1_SaveActions action;
	tns1_statuscodes status;
	NSString * screenname;
	NSNumber * statuscode;
	NSString * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ProfileStatusItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * id_;
@property (nonatomic, assign) tns1_SaveActions action;
@property (nonatomic, assign) tns1_statuscodes status;
@property (nonatomic, retain) NSString * screenname;
@property (nonatomic, retain) NSNumber * statuscode;
@property (nonatomic, retain) NSString * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ProfileStatusList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *ProfileStatusItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ProfileStatusList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addProfileStatusItem:(tns1_ProfileStatusItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * ProfileStatusItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_DeviceItem : NSObject <NSCoding> {
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
+ (tns1_DeviceItem *)deserializeNode:(xmlNodePtr)cur;
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
@interface tns1_DeviceList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *DeviceItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_DeviceList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addDeviceItem:(tns1_DeviceItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * DeviceItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_PrivateAnnotationsRequest : NSObject <NSCoding> {
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
+ (tns1_PrivateAnnotationsRequest *)deserializeNode:(xmlNodePtr)cur;
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
@interface tns1_AnnotationsRequestContentItem : NSObject <NSCoding> {
/* elements */
	NSString * contentIdentifier;
	tns1_ContentIdentifierTypes ContentIdentifierType;
	tns1_drmqualifiers drmqualifier;
	NSString * format;
	tns1_PrivateAnnotationsRequest * PrivateAnnotationsRequest;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_AnnotationsRequestContentItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * contentIdentifier;
@property (nonatomic, assign) tns1_ContentIdentifierTypes ContentIdentifierType;
@property (nonatomic, assign) tns1_drmqualifiers drmqualifier;
@property (nonatomic, retain) NSString * format;
@property (nonatomic, retain) tns1_PrivateAnnotationsRequest * PrivateAnnotationsRequest;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_AnnotationsRequestContentList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *AnnotationsRequestContentItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_AnnotationsRequestContentList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addAnnotationsRequestContentItem:(tns1_AnnotationsRequestContentItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * AnnotationsRequestContentItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_AnnotationsRequestItem : NSObject <NSCoding> {
/* elements */
	tns1_AnnotationsRequestContentList * AnnotationsRequestContentList;
	NSNumber * profileID;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_AnnotationsRequestItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) tns1_AnnotationsRequestContentList * AnnotationsRequestContentList;
@property (nonatomic, retain) NSNumber * profileID;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_AnnotationsRequestList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *AnnotationsRequestItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_AnnotationsRequestList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addAnnotationsRequestItem:(tns1_AnnotationsRequestItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * AnnotationsRequestItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_WordIndex : NSObject <NSCoding> {
/* elements */
	NSNumber * start;
	NSNumber * end;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_WordIndex *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * start;
@property (nonatomic, retain) NSNumber * end;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_LocationText : NSObject <NSCoding> {
/* elements */
	NSNumber * page;
	tns1_WordIndex * wordindex;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_LocationText *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * page;
@property (nonatomic, retain) tns1_WordIndex * wordindex;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_Highlight : NSObject <NSCoding> {
/* elements */
	NSNumber * id_;
	tns1_SaveActions action;
	NSString * color;
	tns1_LocationText * location;
	NSNumber * endPage;
	NSNumber * version;
	NSDate * lastmodified;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_Highlight *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * id_;
@property (nonatomic, assign) tns1_SaveActions action;
@property (nonatomic, retain) NSString * color;
@property (nonatomic, retain) tns1_LocationText * location;
@property (nonatomic, retain) NSNumber * endPage;
@property (nonatomic, retain) NSNumber * version;
@property (nonatomic, retain) NSDate * lastmodified;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_Highlights : NSObject <NSCoding> {
/* elements */
	NSMutableArray *Highlight;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_Highlights *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addHighlight:(tns1_Highlight *)toAdd;
@property (nonatomic, readonly) NSMutableArray * Highlight;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_Coords : NSObject <NSCoding> {
/* elements */
	NSNumber * x;
	NSNumber * y;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_Coords *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * x;
@property (nonatomic, retain) NSNumber * y;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_LocationGraphics : NSObject <NSCoding> {
/* elements */
	NSNumber * page;
	tns1_Coords * coords;
	NSNumber * wordindex;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_LocationGraphics *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * page;
@property (nonatomic, retain) tns1_Coords * coords;
@property (nonatomic, retain) NSNumber * wordindex;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_Note : NSObject <NSCoding> {
/* elements */
	NSNumber * id_;
	tns1_SaveActions action;
	tns1_LocationGraphics * location;
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
+ (tns1_Note *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * id_;
@property (nonatomic, assign) tns1_SaveActions action;
@property (nonatomic, retain) tns1_LocationGraphics * location;
@property (nonatomic, retain) NSString * color;
@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) NSNumber * version;
@property (nonatomic, retain) NSDate * lastmodified;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_Notes : NSObject <NSCoding> {
/* elements */
	NSMutableArray *Note;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_Notes *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addNote:(tns1_Note *)toAdd;
@property (nonatomic, readonly) NSMutableArray * Note;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_LocationBookmark : NSObject <NSCoding> {
/* elements */
	NSNumber * page;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_LocationBookmark *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * page;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_Bookmark : NSObject <NSCoding> {
/* elements */
	NSNumber * id_;
	tns1_SaveActions action;
	NSString * text;
	USBoolean * disabled;
	tns1_LocationBookmark * location;
	NSNumber * version;
	NSDate * lastmodified;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_Bookmark *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * id_;
@property (nonatomic, assign) tns1_SaveActions action;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) USBoolean * disabled;
@property (nonatomic, retain) tns1_LocationBookmark * location;
@property (nonatomic, retain) NSNumber * version;
@property (nonatomic, retain) NSDate * lastmodified;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_Bookmarks : NSObject <NSCoding> {
/* elements */
	NSMutableArray *Bookmark;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_Bookmarks *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addBookmark:(tns1_Bookmark *)toAdd;
@property (nonatomic, readonly) NSMutableArray * Bookmark;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_LastPage : NSObject <NSCoding> {
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
+ (tns1_LastPage *)deserializeNode:(xmlNodePtr)cur;
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
@interface tns1_Rating : NSObject <NSCoding> {
/* elements */
	NSNumber * rating;
	NSDate * lastmodified;
	NSNumber * averageRating;
	NSNumber * numVotes;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_Rating *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSDate * lastmodified;
@property (nonatomic, retain) NSNumber * averageRating;
@property (nonatomic, retain) NSNumber * numVotes;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_PrivateAnnotations : NSObject <NSCoding> {
/* elements */
	tns1_Highlights * Highlights;
	tns1_Notes * Notes;
	tns1_Bookmarks * Bookmarks;
	tns1_LastPage * LastPage;
	tns1_Rating * Rating;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_PrivateAnnotations *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) tns1_Highlights * Highlights;
@property (nonatomic, retain) tns1_Notes * Notes;
@property (nonatomic, retain) tns1_Bookmarks * Bookmarks;
@property (nonatomic, retain) tns1_LastPage * LastPage;
@property (nonatomic, retain) tns1_Rating * Rating;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_AnnotationsContentItem : NSObject <NSCoding> {
/* elements */
	NSString * contentIdentifier;
	tns1_ContentIdentifierTypes ContentIdentifierType;
	tns1_drmqualifiers drmqualifier;
	NSString * format;
	tns1_PrivateAnnotations * PrivateAnnotations;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_AnnotationsContentItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * contentIdentifier;
@property (nonatomic, assign) tns1_ContentIdentifierTypes ContentIdentifierType;
@property (nonatomic, assign) tns1_drmqualifiers drmqualifier;
@property (nonatomic, retain) NSString * format;
@property (nonatomic, retain) tns1_PrivateAnnotations * PrivateAnnotations;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_AnnotationsContentList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *AnnotationsContentItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_AnnotationsContentList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addAnnotationsContentItem:(tns1_AnnotationsContentItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * AnnotationsContentItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_AnnotationsItem : NSObject <NSCoding> {
/* elements */
	tns1_AnnotationsContentList * AnnotationsContentList;
	NSNumber * profileID;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_AnnotationsItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) tns1_AnnotationsContentList * AnnotationsContentList;
@property (nonatomic, retain) NSNumber * profileID;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_AnnotationsList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *AnnotationsItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_AnnotationsList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addAnnotationsItem:(tns1_AnnotationsItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * AnnotationsItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_Favorite : NSObject <NSCoding> {
/* elements */
	USBoolean * isFavorite;
	NSDate * lastmodified;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_Favorite *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) USBoolean * isFavorite;
@property (nonatomic, retain) NSDate * lastmodified;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_AnnotationTypeStatusItem : NSObject <NSCoding> {
/* elements */
	NSNumber * id_;
	tns1_SaveActions action;
	tns1_StatusHolder * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_AnnotationTypeStatusItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * id_;
@property (nonatomic, assign) tns1_SaveActions action;
@property (nonatomic, retain) tns1_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_AnnotationTypeStatusList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *AnnotationTypeStatusItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_AnnotationTypeStatusList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addAnnotationTypeStatusItem:(tns1_AnnotationTypeStatusItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * AnnotationTypeStatusItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_PrivateAnnotationsStatus : NSObject <NSCoding> {
/* elements */
	tns1_AnnotationTypeStatusList * HighlightsStatusList;
	tns1_AnnotationTypeStatusList * NotesStatusList;
	tns1_AnnotationTypeStatusList * BookmarksStatusList;
	tns1_AnnotationTypeStatusItem * FavoriteStatus;
	tns1_AnnotationTypeStatusItem * LastPageStatus;
	tns1_AnnotationTypeStatusItem * RatingStatus;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_PrivateAnnotationsStatus *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) tns1_AnnotationTypeStatusList * HighlightsStatusList;
@property (nonatomic, retain) tns1_AnnotationTypeStatusList * NotesStatusList;
@property (nonatomic, retain) tns1_AnnotationTypeStatusList * BookmarksStatusList;
@property (nonatomic, retain) tns1_AnnotationTypeStatusItem * FavoriteStatus;
@property (nonatomic, retain) tns1_AnnotationTypeStatusItem * LastPageStatus;
@property (nonatomic, retain) tns1_AnnotationTypeStatusItem * RatingStatus;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_AnnotationStatusContentItem : NSObject <NSCoding> {
/* elements */
	NSString * contentIdentifier;
	NSNumber * AverageRating;
	NSNumber * numVotes;
	tns1_StatusHolder * statusmessage;
	tns1_PrivateAnnotationsStatus * PrivateAnnotationsStatus;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_AnnotationStatusContentItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * contentIdentifier;
@property (nonatomic, retain) NSNumber * AverageRating;
@property (nonatomic, retain) NSNumber * numVotes;
@property (nonatomic, retain) tns1_StatusHolder * statusmessage;
@property (nonatomic, retain) tns1_PrivateAnnotationsStatus * PrivateAnnotationsStatus;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_AnnotationStatusContentList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *AnnotationStatusContentItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_AnnotationStatusContentList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addAnnotationStatusContentItem:(tns1_AnnotationStatusContentItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * AnnotationStatusContentItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_AnnotationStatusItem : NSObject <NSCoding> {
/* elements */
	NSNumber * profileId;
	tns1_StatusHolder * statusmessage;
	tns1_AnnotationStatusContentList * AnnotationStatusContentList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_AnnotationStatusItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * profileId;
@property (nonatomic, retain) tns1_StatusHolder * statusmessage;
@property (nonatomic, retain) tns1_AnnotationStatusContentList * AnnotationStatusContentList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_AnnotationStatusList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *AnnotationStatusItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_AnnotationStatusList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addAnnotationStatusItem:(tns1_AnnotationStatusItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * AnnotationStatusItem;
/* attributes */
- (NSDictionary *)attributes;
@end
typedef enum {
	tns1_aggregationPeriod_none = 0,
	tns1_aggregationPeriod_ALL,
	tns1_aggregationPeriod_WEEK,
	tns1_aggregationPeriod_MONTH,
	tns1_aggregationPeriod_COMBINED,
} tns1_aggregationPeriod;
tns1_aggregationPeriod tns1_aggregationPeriod_enumFromString(NSString *string);
NSString * tns1_aggregationPeriod_stringFromEnum(tns1_aggregationPeriod enumValue);
@interface tns1_ReadingStatsAggregateItem : NSObject <NSCoding> {
/* elements */
	NSNumber * pagesRead;
	NSNumber * storyInteractions;
	NSNumber * contentOpened;
	NSNumber * dictionaryLookups;
	NSNumber * readEvents;
	NSNumber * readingDuration;
	NSNumber * profileID;
	tns1_aggregationPeriod period;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ReadingStatsAggregateItem *)deserializeNode:(xmlNodePtr)cur;
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
@property (nonatomic, assign) tns1_aggregationPeriod period;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ReadingStatsAggregateList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *ReadingStatsAggregateItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ReadingStatsAggregateList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addReadingStatsAggregateItem:(tns1_ReadingStatsAggregateItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * ReadingStatsAggregateItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_DictionaryLookupsList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *dictionaryLookupsItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_DictionaryLookupsList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addDictionaryLookupsItem:(NSString *)toAdd;
@property (nonatomic, readonly) NSMutableArray * dictionaryLookupsItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_QuizTrialsItem : NSObject <NSCoding> {
/* elements */
	NSNumber * quizScore;
	NSNumber * quizTotal;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_QuizTrialsItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * quizScore;
@property (nonatomic, retain) NSNumber * quizTotal;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_QuizTrialsList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *quizTrialsItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_QuizTrialsList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addQuizTrialsItem:(tns1_QuizTrialsItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * quizTrialsItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ReadingStatsEntryItem : NSObject <NSCoding> {
/* elements */
	NSNumber * readingDuration;
	NSNumber * pagesRead;
	NSNumber * storyInteractions;
	NSNumber * dictionaryLookups;
	NSString * deviceKey;
	NSDate * timestamp;
	tns1_DictionaryLookupsList * DictionaryLookupsList;
	tns1_QuizTrialsList * quizResults;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ReadingStatsEntryItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * readingDuration;
@property (nonatomic, retain) NSNumber * pagesRead;
@property (nonatomic, retain) NSNumber * storyInteractions;
@property (nonatomic, retain) NSNumber * dictionaryLookups;
@property (nonatomic, retain) NSString * deviceKey;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) tns1_DictionaryLookupsList * DictionaryLookupsList;
@property (nonatomic, retain) tns1_QuizTrialsList * quizResults;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ReadingStatsEntryList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *ReadingStatsEntryItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ReadingStatsEntryList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addReadingStatsEntryItem:(tns1_ReadingStatsEntryItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * ReadingStatsEntryItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ReadingStatsContentItem : NSObject <NSCoding> {
/* elements */
	tns1_ContentIdentifierTypes ContentIdentifierType;
	NSString * contentIdentifier;
	tns1_drmqualifiers drmqualifier;
	NSString * format;
	tns1_ReadingStatsEntryList * ReadingStatsEntryList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ReadingStatsContentItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, assign) tns1_ContentIdentifierTypes ContentIdentifierType;
@property (nonatomic, retain) NSString * contentIdentifier;
@property (nonatomic, assign) tns1_drmqualifiers drmqualifier;
@property (nonatomic, retain) NSString * format;
@property (nonatomic, retain) tns1_ReadingStatsEntryList * ReadingStatsEntryList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ReadingStatsContentList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *ReadingStatsContentItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ReadingStatsContentList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addReadingStatsContentItem:(tns1_ReadingStatsContentItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * ReadingStatsContentItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ReadingStatsDetailItem : NSObject <NSCoding> {
/* elements */
	tns1_ReadingStatsContentList * ReadingStatsContentList;
	NSNumber * profileID;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ReadingStatsDetailItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) tns1_ReadingStatsContentList * ReadingStatsContentList;
@property (nonatomic, retain) NSNumber * profileID;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ReadingStatsDetailList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *ReadingStatsDetailItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ReadingStatsDetailList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addReadingStatsDetailItem:(tns1_ReadingStatsDetailItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * ReadingStatsDetailItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_LookupWordList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *lookupWordItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_LookupWordList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addLookupWordItem:(NSString *)toAdd;
@property (nonatomic, readonly) NSMutableArray * lookupWordItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_MonthlyAverageItem : NSObject <NSCoding> {
/* elements */
	NSNumber * month;
	NSNumber * year;
	NSString * guidedReadingLevel;
	NSNumber * eBooksCompleted;
	NSNumber * readingDuration;
	NSString * eBookLexileLevel;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_MonthlyAverageItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * month;
@property (nonatomic, retain) NSNumber * year;
@property (nonatomic, retain) NSString * guidedReadingLevel;
@property (nonatomic, retain) NSNumber * eBooksCompleted;
@property (nonatomic, retain) NSNumber * readingDuration;
@property (nonatomic, retain) NSString * eBookLexileLevel;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_MonthlyAverageList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *monthlyAverageItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_MonthlyAverageList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addMonthlyAverageItem:(tns1_MonthlyAverageItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * monthlyAverageItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_MonthlyAverageProfileItem : NSObject <NSCoding> {
/* elements */
	NSNumber * profileID;
	tns1_MonthlyAverageList * monthlyAverageList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_MonthlyAverageProfileItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * profileID;
@property (nonatomic, retain) tns1_MonthlyAverageList * monthlyAverageList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_MonthlyAverageProfileList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *monthlyAverageProfileItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_MonthlyAverageProfileList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addMonthlyAverageProfileItem:(tns1_MonthlyAverageProfileItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * monthlyAverageProfileItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_BookIdentifier : NSObject <NSCoding> {
/* elements */
	NSString * contentIdentifier;
	tns1_ContentIdentifierTypes contentIdentifierType;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_BookIdentifier *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * contentIdentifier;
@property (nonatomic, assign) tns1_ContentIdentifierTypes contentIdentifierType;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_QuizItem : NSObject <NSCoding> {
/* elements */
	NSNumber * firstScore;
	NSNumber * bestScore;
	NSNumber * total;
	NSDate * lastTimestamp;
	NSNumber * numberOfTrials;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_QuizItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * firstScore;
@property (nonatomic, retain) NSNumber * bestScore;
@property (nonatomic, retain) NSNumber * total;
@property (nonatomic, retain) NSDate * lastTimestamp;
@property (nonatomic, retain) NSNumber * numberOfTrials;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_AggregateByTitleItem : NSObject <NSCoding> {
/* elements */
	tns1_BookIdentifier * bookIdentifier;
	NSNumber * readingDuration;
	NSDate * lastReadTimestamp;
	NSNumber * pagesRead;
	tns1_QuizItem * quizItem;
	tns1_LookupWordList * lookupWordList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_AggregateByTitleItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) tns1_BookIdentifier * bookIdentifier;
@property (nonatomic, retain) NSNumber * readingDuration;
@property (nonatomic, retain) NSDate * lastReadTimestamp;
@property (nonatomic, retain) NSNumber * pagesRead;
@property (nonatomic, retain) tns1_QuizItem * quizItem;
@property (nonatomic, retain) tns1_LookupWordList * lookupWordList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_AggregateByTitleList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *aggregateByTitleItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_AggregateByTitleList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addAggregateByTitleItem:(tns1_AggregateByTitleItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * aggregateByTitleItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_AggregateByTitleProfileItem : NSObject <NSCoding> {
/* elements */
	NSNumber * profileID;
	tns1_AggregateByTitleList * aggregateByTitleList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_AggregateByTitleProfileItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * profileID;
@property (nonatomic, retain) tns1_AggregateByTitleList * aggregateByTitleList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_AggregateByTitleProfileList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *aggregateByTitleProfileItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_AggregateByTitleProfileList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addAggregateByTitleProfileItem:(tns1_AggregateByTitleProfileItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * aggregateByTitleProfileItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_DailyAggregateByTitleItem : NSObject <NSCoding> {
/* elements */
	NSDate * date;
	tns1_BookIdentifier * bookIdentifier;
	NSNumber * readingDuration;
	NSNumber * pagesRead;
	NSNumber * timesRead;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_DailyAggregateByTitleItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) tns1_BookIdentifier * bookIdentifier;
@property (nonatomic, retain) NSNumber * readingDuration;
@property (nonatomic, retain) NSNumber * pagesRead;
@property (nonatomic, retain) NSNumber * timesRead;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_DailyAggregateByTitleList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *dailyAggregateByTitleItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_DailyAggregateByTitleList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addDailyAggregateByTitleItem:(tns1_DailyAggregateByTitleItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * dailyAggregateByTitleItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_DailyAggregateByTitleProfileItem : NSObject <NSCoding> {
/* elements */
	NSNumber * profileID;
	tns1_DailyAggregateByTitleList * dailyAggregateByTitleList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_DailyAggregateByTitleProfileItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * profileID;
@property (nonatomic, retain) tns1_DailyAggregateByTitleList * dailyAggregateByTitleList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_DailyAggregateByTitleProfileList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *dailyAggregateByTitleProfileItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_DailyAggregateByTitleProfileList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addDailyAggregateByTitleProfileItem:(tns1_DailyAggregateByTitleProfileItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * dailyAggregateByTitleProfileItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_BookIdentifierList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *bookIdentifier;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_BookIdentifierList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addBookIdentifier:(tns1_BookIdentifier *)toAdd;
@property (nonatomic, readonly) NSMutableArray * bookIdentifier;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ProfileIdList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *profileId;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ProfileIdList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addProfileId:(NSNumber *)toAdd;
@property (nonatomic, readonly) NSMutableArray * profileId;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_BookShelfEntryItem : NSObject <NSCoding> {
/* elements */
	tns1_ContentIdentifierTypes ContentIdentifierType;
	NSString * contentidentifier;
	tns1_drmqualifiers drmqualifier;
	NSString * format;
	NSNumber * quantity;
	NSString * notes;
	tns1_ProfileIdList * profileIdList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_BookShelfEntryItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, assign) tns1_ContentIdentifierTypes ContentIdentifierType;
@property (nonatomic, retain) NSString * contentidentifier;
@property (nonatomic, assign) tns1_drmqualifiers drmqualifier;
@property (nonatomic, retain) NSString * format;
@property (nonatomic, retain) NSNumber * quantity;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) tns1_ProfileIdList * profileIdList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_BookshelfEntryList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *BookShelfEntryItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_BookshelfEntryList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addBookShelfEntryItem:(tns1_BookShelfEntryItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * BookShelfEntryItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_BookShelfEntryLastPageItem : NSObject <NSCoding> {
/* elements */
	tns1_ContentIdentifierTypes ContentIdentifierType;
	NSString * contentidentifier;
	tns1_drmqualifiers drmqualifier;
	NSString * format;
	tns1_LastPage * LastPage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_BookShelfEntryLastPageItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, assign) tns1_ContentIdentifierTypes ContentIdentifierType;
@property (nonatomic, retain) NSString * contentidentifier;
@property (nonatomic, assign) tns1_drmqualifiers drmqualifier;
@property (nonatomic, retain) NSString * format;
@property (nonatomic, retain) tns1_LastPage * LastPage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_BookshelfEntryLastPageList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *BookShelfEntryLastPageItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_BookshelfEntryLastPageList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addBookShelfEntryLastPageItem:(tns1_BookShelfEntryLastPageItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * BookShelfEntryLastPageItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ProfileBookshelfEntryItem : NSObject <NSCoding> {
/* elements */
	NSNumber * profileId;
	tns1_BookshelfEntryLastPageList * BookshelfEntryLastPageList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ProfileBookshelfEntryItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * profileId;
@property (nonatomic, retain) tns1_BookshelfEntryLastPageList * BookshelfEntryLastPageList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ProfileBookshelfEntryList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *ProfileBookshelfEntryItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ProfileBookshelfEntryList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addProfileBookshelfEntryItem:(tns1_ProfileBookshelfEntryItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * ProfileBookshelfEntryItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_FavoriteTypesValuesItem : NSObject <NSCoding> {
/* elements */
	NSString * Value;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_FavoriteTypesValuesItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * Value;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_FavoriteTypeValuesList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *FavoriteTypesValuesItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_FavoriteTypeValuesList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addFavoriteTypesValuesItem:(tns1_FavoriteTypesValuesItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * FavoriteTypesValuesItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_FavoriteTypesItem : NSObject <NSCoding> {
/* elements */
	tns1_TopFavoritesTypes FavoriteType;
	tns1_FavoriteTypeValuesList * FavoriteTypeValuesList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_FavoriteTypesItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, assign) tns1_TopFavoritesTypes FavoriteType;
@property (nonatomic, retain) tns1_FavoriteTypeValuesList * FavoriteTypeValuesList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_FavoriteTypesList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *FavoriteTypesItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_FavoriteTypesList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addFavoriteTypesItem:(tns1_FavoriteTypesItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * FavoriteTypesItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_SettingItem : NSObject <NSCoding> {
/* elements */
	NSString * settingName;
	NSString * settingValue;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_SettingItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * settingName;
@property (nonatomic, retain) NSString * settingValue;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_SettingsList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *settingItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_SettingsList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addSettingItem:(tns1_SettingItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * settingItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_SettingStatusItem : NSObject <NSCoding> {
/* elements */
	NSString * settingName;
	tns1_StatusHolder * statusMessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_SettingStatusItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * settingName;
@property (nonatomic, retain) tns1_StatusHolder * statusMessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_SettingStatusList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *settingStatusItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_SettingStatusList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addSettingStatusItem:(tns1_SettingStatusItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * settingStatusItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_AutoAssignProfilesItem : NSObject <NSCoding> {
/* elements */
	NSNumber * profileId;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_AutoAssignProfilesItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * profileId;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_AutoAssignProfilesList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *AutoAssignProfilesItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_AutoAssignProfilesList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addAutoAssignProfilesItem:(tns1_AutoAssignProfilesItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * AutoAssignProfilesItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ReadBooksProfilesItem : NSObject <NSCoding> {
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
+ (tns1_ReadBooksProfilesItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * profileId;
@property (nonatomic, retain) NSDate * lastReadEvent;
@property (nonatomic, retain) NSNumber * lastReadDuration;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ReadBooksProfilesList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *ReadBooksProfilesItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ReadBooksProfilesList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addReadBooksProfilesItem:(tns1_ReadBooksProfilesItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * ReadBooksProfilesItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ReadBooksItem : NSObject <NSCoding> {
/* elements */
	tns1_ContentIdentifierTypes ContentIdentifierType;
	NSString * contentIdentifier;
	tns1_drmqualifiers drmqualifier;
	NSString * format;
	NSNumber * version;
	tns1_ReadBooksProfilesList * ReadBooksProfilesList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ReadBooksItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, assign) tns1_ContentIdentifierTypes ContentIdentifierType;
@property (nonatomic, retain) NSString * contentIdentifier;
@property (nonatomic, assign) tns1_drmqualifiers drmqualifier;
@property (nonatomic, retain) NSString * format;
@property (nonatomic, retain) NSNumber * version;
@property (nonatomic, retain) tns1_ReadBooksProfilesList * ReadBooksProfilesList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ReadBooksList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *ReadBooksItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ReadBooksList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addReadBooksItem:(tns1_ReadBooksItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * ReadBooksItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_LastNRequestReadBooksProfilesItem : NSObject <NSCoding> {
/* elements */
	NSNumber * profileId;
	tns1_BookIdentifierList * bookIdentifierList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_LastNRequestReadBooksProfilesItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * profileId;
@property (nonatomic, retain) tns1_BookIdentifierList * bookIdentifierList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_LastNRequestReadBooksProfilesList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *LastNRequestReadBooksProfilesItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_LastNRequestReadBooksProfilesList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addLastNRequestReadBooksProfilesItem:(tns1_LastNRequestReadBooksProfilesItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * LastNRequestReadBooksProfilesItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_LastNReadBooksItem : NSObject <NSCoding> {
/* elements */
	tns1_ContentIdentifierTypes ContentIdentifierType;
	NSString * contentIdentifier;
	tns1_drmqualifiers drmqualifier;
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
+ (tns1_LastNReadBooksItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, assign) tns1_ContentIdentifierTypes ContentIdentifierType;
@property (nonatomic, retain) NSString * contentIdentifier;
@property (nonatomic, assign) tns1_drmqualifiers drmqualifier;
@property (nonatomic, retain) NSString * format;
@property (nonatomic, retain) NSNumber * version;
@property (nonatomic, retain) NSDate * lastReadEvent;
@property (nonatomic, retain) NSNumber * lastReadDuration;
@property (nonatomic, retain) NSNumber * lastReadPages;
@property (nonatomic, retain) NSNumber * lastPageLocation;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_LastNReadBooksList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *LastNReadBooksItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_LastNReadBooksList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addLastNReadBooksItem:(tns1_LastNReadBooksItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * LastNReadBooksItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_LastNResponseReadBooksProfilesItem : NSObject <NSCoding> {
/* elements */
	NSNumber * profileId;
	tns1_LastNReadBooksList * LastNReadBooksList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_LastNResponseReadBooksProfilesItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * profileId;
@property (nonatomic, retain) tns1_LastNReadBooksList * LastNReadBooksList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_LastNResponseReadBooksProfilesList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *LastNResponseReadBooksProfilesItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_LastNResponseReadBooksProfilesList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addLastNResponseReadBooksProfilesItem:(tns1_LastNResponseReadBooksProfilesItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * LastNResponseReadBooksProfilesItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_LastNRequestWordsItem : NSObject <NSCoding> {
/* elements */
	NSNumber * profileId;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_LastNRequestWordsItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * profileId;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_LastNRequestWordsList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *LastNRequestWordsItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_LastNRequestWordsList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addLastNRequestWordsItem:(tns1_LastNRequestWordsItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * LastNRequestWordsItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_LastNLookedUpWordsItem : NSObject <NSCoding> {
/* elements */
	NSString * lookupWord;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_LastNLookedUpWordsItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * lookupWord;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_LastNLookedUpWordsList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *LastNLookedUpWordsItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_LastNLookedUpWordsList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addLastNLookedUpWordsItem:(tns1_LastNLookedUpWordsItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * LastNLookedUpWordsItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_LastNResponseWordsItem : NSObject <NSCoding> {
/* elements */
	NSNumber * profileId;
	tns1_LastNLookedUpWordsList * LastNLookedUpWordsList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_LastNResponseWordsItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * profileId;
@property (nonatomic, retain) tns1_LastNLookedUpWordsList * LastNLookedUpWordsList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_LastNResponseWordsList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *LastNResponseWordsItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_LastNResponseWordsList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addLastNResponseWordsItem:(tns1_LastNResponseWordsItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * LastNResponseWordsItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_NoteItem : NSObject <NSCoding> {
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
+ (tns1_NoteItem *)deserializeNode:(xmlNodePtr)cur;
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
@interface tns1_NotesList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *noteItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_NotesList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addNoteItem:(tns1_NoteItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * noteItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_DefaultBooksItem : NSObject <NSCoding> {
/* elements */
	NSString * contentidentifier;
	tns1_ContentIdentifierTypes contentIdentifierType;
	tns1_drmqualifiers DRMQualifier;
	NSString * Format;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_DefaultBooksItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * contentidentifier;
@property (nonatomic, assign) tns1_ContentIdentifierTypes contentIdentifierType;
@property (nonatomic, assign) tns1_drmqualifiers DRMQualifier;
@property (nonatomic, retain) NSString * Format;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_DefaultBooksList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *DefaultBooksItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_DefaultBooksList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addDefaultBooksItem:(tns1_DefaultBooksItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * DefaultBooksItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_AssignBooksToAllUsersItem : NSObject <NSCoding> {
/* elements */
	NSString * userKey;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_AssignBooksToAllUsersItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * userKey;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_AssignBooksToAllUsersList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *AssignBooksToAllUsersItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_AssignBooksToAllUsersList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addAssignBooksToAllUsersItem:(tns1_AssignBooksToAllUsersItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * AssignBooksToAllUsersItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_AssignBooksToAllUsersBooksItem : NSObject <NSCoding> {
/* elements */
	NSString * contentidentifier;
	tns1_ContentIdentifierTypes contentIdentifierType;
	tns1_drmqualifiers DRMQualifier;
	NSString * Format;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_AssignBooksToAllUsersBooksItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * contentidentifier;
@property (nonatomic, assign) tns1_ContentIdentifierTypes contentIdentifierType;
@property (nonatomic, assign) tns1_drmqualifiers DRMQualifier;
@property (nonatomic, retain) NSString * Format;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_AssignBooksToAllUsersBooksList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *AssignBooksToAllUsersBooksItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_AssignBooksToAllUsersBooksList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addAssignBooksToAllUsersBooksItem:(tns1_AssignBooksToAllUsersBooksItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * AssignBooksToAllUsersBooksItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ListRatingsContentItem : NSObject <NSCoding> {
/* elements */
	NSString * contentIdentifier;
	tns1_ContentIdentifierTypes contentIdentifierType;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ListRatingsContentItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * contentIdentifier;
@property (nonatomic, assign) tns1_ContentIdentifierTypes contentIdentifierType;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ListRatingsContentList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *listRatingsContentItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ListRatingsContentList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addListRatingsContentItem:(tns1_ListRatingsContentItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * listRatingsContentItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ListRatingsItem : NSObject <NSCoding> {
/* elements */
	tns1_ListRatingsContentList * listRatingsContentList;
	NSNumber * profileId;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ListRatingsItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) tns1_ListRatingsContentList * listRatingsContentList;
@property (nonatomic, retain) NSNumber * profileId;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ListRatingsRequestList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *listRatingsItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ListRatingsRequestList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addListRatingsItem:(tns1_ListRatingsItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * listRatingsItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ProfileRatingsStatusItem : NSObject <NSCoding> {
/* elements */
	NSString * contentIdentifier;
	tns1_ContentIdentifierTypes contentIdentifierType;
	tns1_Rating * rating;
	tns1_StatusHolder * statusMessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ProfileRatingsStatusItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * contentIdentifier;
@property (nonatomic, assign) tns1_ContentIdentifierTypes contentIdentifierType;
@property (nonatomic, retain) tns1_Rating * rating;
@property (nonatomic, retain) tns1_StatusHolder * statusMessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ProfileRatingsStatusList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *profileRatingsStatusItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ProfileRatingsStatusList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addProfileRatingsStatusItem:(tns1_ProfileRatingsStatusItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * profileRatingsStatusItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_RatingsStatusItem : NSObject <NSCoding> {
/* elements */
	NSNumber * profileId;
	tns1_StatusHolder * statusMessage;
	tns1_ProfileRatingsStatusList * profileRatingsStatusList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_RatingsStatusItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * profileId;
@property (nonatomic, retain) tns1_StatusHolder * statusMessage;
@property (nonatomic, retain) tns1_ProfileRatingsStatusList * profileRatingsStatusList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_RatingsStatusList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *ratingsStatusItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_RatingsStatusList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addRatingsStatusItem:(tns1_RatingsStatusItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * ratingsStatusItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ProfileRatingsItem : NSObject <NSCoding> {
/* elements */
	NSString * contentIdentifier;
	tns1_ContentIdentifierTypes contentIdentifierType;
	tns1_Rating * rating;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ProfileRatingsItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * contentIdentifier;
@property (nonatomic, assign) tns1_ContentIdentifierTypes contentIdentifierType;
@property (nonatomic, retain) tns1_Rating * rating;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ProfileRatingsList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *profileRatingsItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ProfileRatingsList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addProfileRatingsItem:(tns1_ProfileRatingsItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * profileRatingsItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_RatingsItem : NSObject <NSCoding> {
/* elements */
	tns1_ProfileRatingsList * profileRatingsList;
	NSNumber * profileId;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_RatingsItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) tns1_ProfileRatingsList * profileRatingsList;
@property (nonatomic, retain) NSNumber * profileId;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_RatingsList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *ratingsItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_RatingsList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addRatingsItem:(tns1_RatingsItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * ratingsItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_TokenExchange : NSObject <NSCoding> {
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
+ (tns1_TokenExchange *)deserializeNode:(xmlNodePtr)cur;
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
@interface tns1_TokenExchangeResponse : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
	NSNumber * expiresIn;
	NSString * userKey;
	NSNumber * userType;
	USBoolean * deviceIsDeregistered;
	USBoolean * isNewUser;
	USBoolean * isCoppa;
	tns1_StatusHolder * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_TokenExchangeResponse *)deserializeNode:(xmlNodePtr)cur;
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
@property (nonatomic, retain) tns1_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_SharedTokenExchangeRequest : NSObject <NSCoding> {
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
+ (tns1_SharedTokenExchangeRequest *)deserializeNode:(xmlNodePtr)cur;
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
@interface tns1_SharedTokenExchangeResponse : NSObject <NSCoding> {
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
	tns1_StatusHolder * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_SharedTokenExchangeResponse *)deserializeNode:(xmlNodePtr)cur;
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
@property (nonatomic, retain) tns1_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_AuthenticateDeviceRequest : NSObject <NSCoding> {
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
+ (tns1_AuthenticateDeviceRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * vaid;
@property (nonatomic, retain) NSString * deviceKey;
@property (nonatomic, retain) NSString * userKey;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_AuthenticateDeviceResponse : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
	NSNumber * expiresIn;
	USBoolean * deviceIsDeregistered;
	NSString * userKey;
	tns1_StatusHolder * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_AuthenticateDeviceResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
@property (nonatomic, retain) NSNumber * expiresIn;
@property (nonatomic, retain) USBoolean * deviceIsDeregistered;
@property (nonatomic, retain) NSString * userKey;
@property (nonatomic, retain) tns1_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_RenewTokenRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_RenewTokenRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_RenewTokenResponse : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
	NSNumber * expiresIn;
	NSString * userKey;
	tns1_StatusHolder * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_RenewTokenResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
@property (nonatomic, retain) NSNumber * expiresIn;
@property (nonatomic, retain) NSString * userKey;
@property (nonatomic, retain) tns1_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ListBooksAssignmentRequest : NSObject <NSCoding> {
/* elements */
	NSString * authToken;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ListBooksAssignmentRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authToken;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_BooksAssignment : NSObject <NSCoding> {
/* elements */
	NSString * ContentIdentifier;
	tns1_ContentIdentifierTypes ContentIdentifierType;
	tns1_drmqualifiers DRMQualifier;
	NSString * Format;
	NSNumber * version;
	NSNumber * averageRating;
	NSNumber * numVotes;
	NSDate * lastOrderDate;
	USBoolean * defaultAssignment;
	USBoolean * freeBook;
	NSNumber * lastVersion;
	NSNumber * quantity;
	NSNumber * quantityInit;
	tns1_ContentProfileList * contentProfileList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_BooksAssignment *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * ContentIdentifier;
@property (nonatomic, assign) tns1_ContentIdentifierTypes ContentIdentifierType;
@property (nonatomic, assign) tns1_drmqualifiers DRMQualifier;
@property (nonatomic, retain) NSString * Format;
@property (nonatomic, retain) NSNumber * version;
@property (nonatomic, retain) NSNumber * averageRating;
@property (nonatomic, retain) NSNumber * numVotes;
@property (nonatomic, retain) NSDate * lastOrderDate;
@property (nonatomic, retain) USBoolean * defaultAssignment;
@property (nonatomic, retain) USBoolean * freeBook;
@property (nonatomic, retain) NSNumber * lastVersion;
@property (nonatomic, retain) NSNumber * quantity;
@property (nonatomic, retain) NSNumber * quantityInit;
@property (nonatomic, retain) tns1_ContentProfileList * contentProfileList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_booksAssignmentList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *booksAssignment;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_booksAssignmentList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addBooksAssignment:(tns1_BooksAssignment *)toAdd;
@property (nonatomic, readonly) NSMutableArray * booksAssignment;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ListBooksAssignmentResponse : NSObject <NSCoding> {
/* elements */
	tns1_StatusHolder * statusMessage;
	tns1_booksAssignmentList * booksAssignmentList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ListBooksAssignmentResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) tns1_StatusHolder * statusMessage;
@property (nonatomic, retain) tns1_booksAssignmentList * booksAssignmentList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ListUserContent : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ListUserContent *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_UserContentList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *userContentItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_UserContentList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addUserContentItem:(tns1_UserContentItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * userContentItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ListUserContentResponse : NSObject <NSCoding> {
/* elements */
	tns1_StatusHolder * statusmessage;
	tns1_UserContentList * userContentList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ListUserContentResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) tns1_StatusHolder * statusmessage;
@property (nonatomic, retain) tns1_UserContentList * userContentList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ListContentMetadata : NSObject <NSCoding> {
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
+ (tns1_ListContentMetadata *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
@property (nonatomic, retain) USBoolean * includeurls;
@property (nonatomic, retain) USBoolean * coverURLOnly;
- (void)addIsbn13s:(tns1_isbnItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * isbn13s;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ContentMetadataList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *ContentMetadataItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ContentMetadataList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addContentMetadataItem:(tns1_ContentMetadataItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * ContentMetadataItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ListContentMetadataResponse : NSObject <NSCoding> {
/* elements */
	tns1_StatusHolder * statusmessage;
	tns1_ContentMetadataList * ContentMetadataList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ListContentMetadataResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) tns1_StatusHolder * statusmessage;
@property (nonatomic, retain) tns1_ContentMetadataList * ContentMetadataList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_IsEntitledToLicenseResponse : NSObject <NSCoding> {
/* elements */
	tns1_StatusHolder * statusmessage;
	NSString * isEntitled;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_IsEntitledToLicenseResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) tns1_StatusHolder * statusmessage;
@property (nonatomic, retain) NSString * isEntitled;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_EntitledToLicenseRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
	NSString * contentidentifier;
	tns1_ContentIdentifierTypes ContentIdentifierType;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_EntitledToLicenseRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
@property (nonatomic, retain) NSString * contentidentifier;
@property (nonatomic, assign) tns1_ContentIdentifierTypes ContentIdentifierType;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_SaveReadingStatisticsDetailedRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
	tns1_ReadingStatsDetailList * ReadingStatsDetailList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_SaveReadingStatisticsDetailedRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
@property (nonatomic, retain) tns1_ReadingStatsDetailList * ReadingStatsDetailList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_SaveReadingStatisticsDetailedResponse : NSObject <NSCoding> {
/* elements */
	tns1_StatusHolder * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_SaveReadingStatisticsDetailedResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) tns1_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ListReadingStatisticsAggregateRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
	NSNumber * profileId;
	tns1_aggregationPeriod aggregationPeriod;
	USBoolean * countDeletedBooks;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ListReadingStatisticsAggregateRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
@property (nonatomic, retain) NSNumber * profileId;
@property (nonatomic, assign) tns1_aggregationPeriod aggregationPeriod;
@property (nonatomic, retain) USBoolean * countDeletedBooks;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ListReadingStatisticsAggregateResponse : NSObject <NSCoding> {
/* elements */
	tns1_StatusHolder * statusmessage;
	tns1_ReadingStatsAggregateList * ReadingStatsAggregateList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ListReadingStatisticsAggregateResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) tns1_StatusHolder * statusmessage;
@property (nonatomic, retain) tns1_ReadingStatsAggregateList * ReadingStatsAggregateList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ListReadingStatisticsDetailedRequest : NSObject <NSCoding> {
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
+ (tns1_ListReadingStatisticsDetailedRequest *)deserializeNode:(xmlNodePtr)cur;
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
@interface tns1_ListReadingStatisticsDetailedResponse : NSObject <NSCoding> {
/* elements */
	tns1_StatusHolder * statusmessage;
	tns1_ReadingStatsDetailList * ReadingStatsDetailList;
	tns1_ItemsCount * ItemsCount;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ListReadingStatisticsDetailedResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) tns1_StatusHolder * statusmessage;
@property (nonatomic, retain) tns1_ReadingStatsDetailList * ReadingStatsDetailList;
@property (nonatomic, retain) tns1_ItemsCount * ItemsCount;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ListReadingStatisticsMonthlyAverageRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
	tns1_ProfileIdList * profileIdList;
	NSNumber * numberOfMonths;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ListReadingStatisticsMonthlyAverageRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
@property (nonatomic, retain) tns1_ProfileIdList * profileIdList;
@property (nonatomic, retain) NSNumber * numberOfMonths;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ListReadingStatisticsMonthlyAverageResponse : NSObject <NSCoding> {
/* elements */
	tns1_StatusHolder * statusmessage;
	tns1_MonthlyAverageProfileList * monthlyAverageProfileList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ListReadingStatisticsMonthlyAverageResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) tns1_StatusHolder * statusmessage;
@property (nonatomic, retain) tns1_MonthlyAverageProfileList * monthlyAverageProfileList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ListReadingStatisticsAggregateByTitleRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
	tns1_ProfileIdList * profileIdList;
	tns1_BookIdentifierList * bookIdentifierList;
	NSNumber * maxWordCount;
	NSDate * lastReadDate;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ListReadingStatisticsAggregateByTitleRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
@property (nonatomic, retain) tns1_ProfileIdList * profileIdList;
@property (nonatomic, retain) tns1_BookIdentifierList * bookIdentifierList;
@property (nonatomic, retain) NSNumber * maxWordCount;
@property (nonatomic, retain) NSDate * lastReadDate;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ListReadingStatisticsAggregateByTitleResponse : NSObject <NSCoding> {
/* elements */
	tns1_StatusHolder * statusmessage;
	tns1_AggregateByTitleProfileList * aggregateByTitleProfileList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ListReadingStatisticsAggregateByTitleResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) tns1_StatusHolder * statusmessage;
@property (nonatomic, retain) tns1_AggregateByTitleProfileList * aggregateByTitleProfileList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ListReadingStatisticsDailyAggregateByTitleRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
	tns1_ProfileIdList * profileIdList;
	NSNumber * numberOfDays;
	tns1_BookIdentifierList * bookIdentifierList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ListReadingStatisticsDailyAggregateByTitleRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
@property (nonatomic, retain) tns1_ProfileIdList * profileIdList;
@property (nonatomic, retain) NSNumber * numberOfDays;
@property (nonatomic, retain) tns1_BookIdentifierList * bookIdentifierList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ListReadingStatisticsDailyAggregateByTitleResponse : NSObject <NSCoding> {
/* elements */
	tns1_StatusHolder * statusmessage;
	tns1_DailyAggregateByTitleProfileList * dailyAggregateByTitleProfileList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ListReadingStatisticsDailyAggregateByTitleResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) tns1_StatusHolder * statusmessage;
@property (nonatomic, retain) tns1_DailyAggregateByTitleProfileList * dailyAggregateByTitleProfileList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_SaveProfileContentAnnotationsRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
	tns1_AnnotationsList * AnnotationsList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_SaveProfileContentAnnotationsRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
@property (nonatomic, retain) tns1_AnnotationsList * AnnotationsList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_SaveProfileContentAnnotationsResponse : NSObject <NSCoding> {
/* elements */
	tns1_StatusHolder * statusmessage;
	tns1_AnnotationStatusList * AnnotationStatusForRatingsList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_SaveProfileContentAnnotationsResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) tns1_StatusHolder * statusmessage;
@property (nonatomic, retain) tns1_AnnotationStatusList * AnnotationStatusForRatingsList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ListProfileContentAnnotationsRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
	tns1_AnnotationsRequestList * AnnotationsRequestList;
	USBoolean * includeRemoved;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ListProfileContentAnnotationsRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
@property (nonatomic, retain) tns1_AnnotationsRequestList * AnnotationsRequestList;
@property (nonatomic, retain) USBoolean * includeRemoved;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ListProfileContentAnnotationsResponse : NSObject <NSCoding> {
/* elements */
	tns1_StatusHolder * statusmessage;
	tns1_AnnotationsList * AnnotationsList;
	tns1_ItemsCount * ItemsCount;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ListProfileContentAnnotationsResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) tns1_StatusHolder * statusmessage;
@property (nonatomic, retain) tns1_AnnotationsList * AnnotationsList;
@property (nonatomic, retain) tns1_ItemsCount * ItemsCount;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_GetUserProfilesRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_GetUserProfilesRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_GetUserProfilesResponse : NSObject <NSCoding> {
/* elements */
	tns1_StatusHolder * statusmessage;
	tns1_ProfileList * ProfileList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_GetUserProfilesResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) tns1_StatusHolder * statusmessage;
@property (nonatomic, retain) tns1_ProfileList * ProfileList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_SaveUserProfilesRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
	tns1_SaveProfileList * SaveProfileList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_SaveUserProfilesRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
@property (nonatomic, retain) tns1_SaveProfileList * SaveProfileList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_SaveUserProfilesResponse : NSObject <NSCoding> {
/* elements */
	tns1_StatusHolder * statusmessage;
	tns1_ProfileStatusList * ProfileStatusList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_SaveUserProfilesResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) tns1_StatusHolder * statusmessage;
@property (nonatomic, retain) tns1_ProfileStatusList * ProfileStatusList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ListApplicationSettingsRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ListApplicationSettingsRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ListApplicationSettingsResponse : NSObject <NSCoding> {
/* elements */
	tns1_StatusHolder * statusmessage;
	tns1_SettingsList * settingsList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ListApplicationSettingsResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) tns1_StatusHolder * statusmessage;
@property (nonatomic, retain) tns1_SettingsList * settingsList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_SaveContentProfileAssignmentRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
	tns1_ContentProfileAssignmentList * ContentProfileAssignmentList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_SaveContentProfileAssignmentRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
@property (nonatomic, retain) tns1_ContentProfileAssignmentList * ContentProfileAssignmentList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_SaveContentProfileAssignmentResponse : NSObject <NSCoding> {
/* elements */
	tns1_StatusHolder * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_SaveContentProfileAssignmentResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) tns1_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_GetDeviceInfoRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_GetDeviceInfoRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_GetDeviceInfoResponse : NSObject <NSCoding> {
/* elements */
	tns1_StatusHolder * statusmessage;
	tns1_DeviceList * DeviceInfoList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_GetDeviceInfoResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) tns1_StatusHolder * statusmessage;
@property (nonatomic, retain) tns1_DeviceList * DeviceInfoList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_SaveDeviceInfoRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
	tns1_DeviceList * SaveDeviceList;
	tns1_SaveActions action;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_SaveDeviceInfoRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
@property (nonatomic, retain) tns1_DeviceList * SaveDeviceList;
@property (nonatomic, assign) tns1_SaveActions action;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_SaveDeviceInfoResponse : NSObject <NSCoding> {
/* elements */
	tns1_StatusHolder * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_SaveDeviceInfoResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) tns1_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_SaveNewDomainResponse : NSObject <NSCoding> {
/* elements */
	tns1_StatusHolder * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_SaveNewDomainResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) tns1_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_SaveNewDomainRequest : NSObject <NSCoding> {
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
+ (tns1_SaveNewDomainRequest *)deserializeNode:(xmlNodePtr)cur;
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
@interface tns1_DeviceLeftDomainResponse : NSObject <NSCoding> {
/* elements */
	tns1_StatusHolder * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_DeviceLeftDomainResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) tns1_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_DeviceLeftDomainRequest : NSObject <NSCoding> {
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
+ (tns1_DeviceLeftDomainRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * Authtoken;
@property (nonatomic, retain) NSString * DeviceKey;
@property (nonatomic, retain) NSString * ClientId;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_DeviceCanJoinDomainResponse : NSObject <NSCoding> {
/* elements */
	NSString * AccountId;
	NSString * DomainKeyPair;
	NSNumber * Revision;
	tns1_StatusHolder * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_DeviceCanJoinDomainResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * AccountId;
@property (nonatomic, retain) NSString * DomainKeyPair;
@property (nonatomic, retain) NSNumber * Revision;
@property (nonatomic, retain) tns1_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_DeviceCanJoinDomainRequest : NSObject <NSCoding> {
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
+ (tns1_DeviceCanJoinDomainRequest *)deserializeNode:(xmlNodePtr)cur;
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
@interface tns1_GetLicensableStatusResponse : NSObject <NSCoding> {
/* elements */
	NSString * AccountId;
	NSNumber * Revision;
	tns1_StatusHolder * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_GetLicensableStatusResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * AccountId;
@property (nonatomic, retain) NSNumber * Revision;
@property (nonatomic, retain) tns1_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_GetLicensableStatusRequest : NSObject <NSCoding> {
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
+ (tns1_GetLicensableStatusRequest *)deserializeNode:(xmlNodePtr)cur;
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
@interface tns1_AcknowledgeLicenseResponse : NSObject <NSCoding> {
/* elements */
	tns1_StatusHolder * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_AcknowledgeLicenseResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) tns1_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_AcknowledgeLicenseRequest : NSObject <NSCoding> {
/* elements */
	NSString * TransactionId;
	NSString * ClientId;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_AcknowledgeLicenseRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * TransactionId;
@property (nonatomic, retain) NSString * ClientId;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ValidateScreenNameRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
	NSString * screenName;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ValidateScreenNameRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
@property (nonatomic, retain) NSString * screenName;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ValidateScreenNameResponse : NSObject <NSCoding> {
/* elements */
	USBoolean * result;
	tns1_StatusHolder * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ValidateScreenNameResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) USBoolean * result;
@property (nonatomic, retain) tns1_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ValidateUserKeyRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
	NSString * userKey;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ValidateUserKeyRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
@property (nonatomic, retain) NSString * userKey;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ValidateUserKeyResponse : NSObject <NSCoding> {
/* elements */
	USBoolean * result;
	tns1_StatusHolder * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ValidateUserKeyResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) USBoolean * result;
@property (nonatomic, retain) tns1_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_DeleteBookShelfEntryRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
	tns1_BookshelfEntryList * BookShelfEntryList;
	USBoolean * cascade;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_DeleteBookShelfEntryRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
@property (nonatomic, retain) tns1_BookshelfEntryList * BookShelfEntryList;
@property (nonatomic, retain) USBoolean * cascade;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_DeleteBookShelfEntryResponse : NSObject <NSCoding> {
/* elements */
	tns1_StatusHolder * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_DeleteBookShelfEntryResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) tns1_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_GetLastPageLocationRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_GetLastPageLocationRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_GetLastPageLocationResponse : NSObject <NSCoding> {
/* elements */
	tns1_ProfileBookshelfEntryList * ProfileBookshelfEntryList;
	tns1_StatusHolder * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_GetLastPageLocationResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) tns1_ProfileBookshelfEntryList * ProfileBookshelfEntryList;
@property (nonatomic, retain) tns1_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_SaveLastPageLocationRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
	tns1_ProfileBookshelfEntryList * ProfileBookshelfEntryList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_SaveLastPageLocationRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
@property (nonatomic, retain) tns1_ProfileBookshelfEntryList * ProfileBookshelfEntryList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_SaveLastPageLocationResponse : NSObject <NSCoding> {
/* elements */
	tns1_StatusHolder * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_SaveLastPageLocationResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) tns1_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ListFavoriteTypesRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ListFavoriteTypesRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ListFavoriteTypesResponse : NSObject <NSCoding> {
/* elements */
	tns1_StatusHolder * statusmessage;
	tns1_FavoriteTypesList * FavoriteTypesList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ListFavoriteTypesResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) tns1_StatusHolder * statusmessage;
@property (nonatomic, retain) tns1_FavoriteTypesList * FavoriteTypesList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_SaveUserSettingsRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
	tns1_SettingsList * settingsList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_SaveUserSettingsRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
@property (nonatomic, retain) tns1_SettingsList * settingsList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_SaveUserSettingsResponse : NSObject <NSCoding> {
/* elements */
	tns1_StatusHolder * statusmessage;
	tns1_SettingStatusList * settingStatusList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_SaveUserSettingsResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) tns1_StatusHolder * statusmessage;
@property (nonatomic, retain) tns1_SettingStatusList * settingStatusList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ListUserSettingsRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ListUserSettingsRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ListUserSettingsResponse : NSObject <NSCoding> {
/* elements */
	tns1_StatusHolder * statusmessage;
	tns1_SettingsList * settingsList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ListUserSettingsResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) tns1_StatusHolder * statusmessage;
@property (nonatomic, retain) tns1_SettingsList * settingsList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_SetAccountAutoAssignRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
	tns1_AutoAssignProfilesList * AutoAssignProfilesList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_SetAccountAutoAssignRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
@property (nonatomic, retain) tns1_AutoAssignProfilesList * AutoAssignProfilesList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_SetAccountAutoAssignResponse : NSObject <NSCoding> {
/* elements */
	tns1_StatusHolder * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_SetAccountAutoAssignResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) tns1_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_SetAccountPasswordRequiredRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
	USBoolean * passwordRequired;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_SetAccountPasswordRequiredRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
@property (nonatomic, retain) USBoolean * passwordRequired;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_SetAccountPasswordRequiredResponse : NSObject <NSCoding> {
/* elements */
	tns1_StatusHolder * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_SetAccountPasswordRequiredResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) tns1_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ListReadBooksRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ListReadBooksRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ListReadBooksResponse : NSObject <NSCoding> {
/* elements */
	tns1_StatusHolder * statusmessage;
	tns1_ReadBooksList * ReadBooksList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ListReadBooksResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) tns1_StatusHolder * statusmessage;
@property (nonatomic, retain) tns1_ReadBooksList * ReadBooksList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ListLastNProfileReadBooksRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
	NSNumber * lastBooksCount;
	USBoolean * uniqueBooks;
	tns1_LastNRequestReadBooksProfilesList * LastNRequestReadBooksProfilesList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ListLastNProfileReadBooksRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
@property (nonatomic, retain) NSNumber * lastBooksCount;
@property (nonatomic, retain) USBoolean * uniqueBooks;
@property (nonatomic, retain) tns1_LastNRequestReadBooksProfilesList * LastNRequestReadBooksProfilesList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ListLastNProfileReadBooksResponse : NSObject <NSCoding> {
/* elements */
	tns1_StatusHolder * statusmessage;
	tns1_LastNResponseReadBooksProfilesList * LastNResponseReadBooksProfilesList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ListLastNProfileReadBooksResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) tns1_StatusHolder * statusmessage;
@property (nonatomic, retain) tns1_LastNResponseReadBooksProfilesList * LastNResponseReadBooksProfilesList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ListLastNWordsRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
	NSNumber * lastWordsCount;
	NSDate * startDate;
	NSDate * endDate;
	tns1_LastNRequestWordsList * LastNRequestWordsList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ListLastNWordsRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
@property (nonatomic, retain) NSNumber * lastWordsCount;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) tns1_LastNRequestWordsList * LastNRequestWordsList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ListLastNWordsResponse : NSObject <NSCoding> {
/* elements */
	tns1_StatusHolder * statusmessage;
	tns1_LastNResponseWordsList * LastNResponseWordsList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ListLastNWordsResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) tns1_StatusHolder * statusmessage;
@property (nonatomic, retain) tns1_LastNResponseWordsList * LastNResponseWordsList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_RemoveOrderRequest : NSObject <NSCoding> {
/* elements */
	NSString * authtoken;
	NSString * userKey;
	NSString * orderID;
	NSString * contentidentifier;
	tns1_ContentIdentifierTypes contentIdentifierType;
	tns1_drmqualifiers DRMQualifier;
	NSString * Format;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_RemoveOrderRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authtoken;
@property (nonatomic, retain) NSString * userKey;
@property (nonatomic, retain) NSString * orderID;
@property (nonatomic, retain) NSString * contentidentifier;
@property (nonatomic, assign) tns1_ContentIdentifierTypes contentIdentifierType;
@property (nonatomic, assign) tns1_drmqualifiers DRMQualifier;
@property (nonatomic, retain) NSString * Format;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_RemoveOrderResponse : NSObject <NSCoding> {
/* elements */
	tns1_StatusHolder * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_RemoveOrderResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) tns1_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_SaveUserCSRNotesRequest : NSObject <NSCoding> {
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
+ (tns1_SaveUserCSRNotesRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * CSRtoken;
@property (nonatomic, retain) NSString * userKey;
@property (nonatomic, retain) NSString * noteText;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_SaveUserCSRNotesResponse : NSObject <NSCoding> {
/* elements */
	tns1_StatusHolder * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_SaveUserCSRNotesResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) tns1_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ListUserCSRNotesRequest : NSObject <NSCoding> {
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
+ (tns1_ListUserCSRNotesRequest *)deserializeNode:(xmlNodePtr)cur;
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
@interface tns1_ListUserCSRNotesResponse : NSObject <NSCoding> {
/* elements */
	tns1_StatusHolder * statusmessage;
	tns1_NotesList * notesList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ListUserCSRNotesResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) tns1_StatusHolder * statusmessage;
@property (nonatomic, retain) tns1_NotesList * notesList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_GetKeyIdRequest : NSObject <NSCoding> {
/* elements */
	NSString * contentidentifier;
	tns1_ContentIdentifierTypes contentIdentifierType;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_GetKeyIdRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * contentidentifier;
@property (nonatomic, assign) tns1_ContentIdentifierTypes contentIdentifierType;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_GetKeyIdResponse : NSObject <NSCoding> {
/* elements */
	NSString * guid;
	tns1_StatusHolder * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_GetKeyIdResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) tns1_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_SaveDefaultBooksRequest : NSObject <NSCoding> {
/* elements */
	NSString * CSRtoken;
	tns1_DefaultBooksList * BooksList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_SaveDefaultBooksRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * CSRtoken;
@property (nonatomic, retain) tns1_DefaultBooksList * BooksList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_SaveDefaultBooksResponse : NSObject <NSCoding> {
/* elements */
	tns1_StatusHolder * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_SaveDefaultBooksResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) tns1_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ListDefaultBooksRequest : NSObject <NSCoding> {
/* elements */
	NSString * authToken;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ListDefaultBooksRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authToken;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ListDefaultBooksResponse : NSObject <NSCoding> {
/* elements */
	tns1_StatusHolder * statusmessage;
	tns1_DefaultBooksList * BooksList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ListDefaultBooksResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) tns1_StatusHolder * statusmessage;
@property (nonatomic, retain) tns1_DefaultBooksList * BooksList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_RemoveDefaultBooksRequest : NSObject <NSCoding> {
/* elements */
	NSString * CSRtoken;
	tns1_DefaultBooksList * BooksList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_RemoveDefaultBooksRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * CSRtoken;
@property (nonatomic, retain) tns1_DefaultBooksList * BooksList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_RemoveDefaultBooksResponse : NSObject <NSCoding> {
/* elements */
	tns1_StatusHolder * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_RemoveDefaultBooksResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) tns1_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_AssignBooksToAllUsersRequest : NSObject <NSCoding> {
/* elements */
	NSString * CSRtoken;
	tns1_AssignBooksToAllUsersList * UsersList;
	tns1_AssignBooksToAllUsersBooksList * BooksList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_AssignBooksToAllUsersRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * CSRtoken;
@property (nonatomic, retain) tns1_AssignBooksToAllUsersList * UsersList;
@property (nonatomic, retain) tns1_AssignBooksToAllUsersBooksList * BooksList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_AssignBooksToAllUsersResponse : NSObject <NSCoding> {
/* elements */
	tns1_StatusHolder * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_AssignBooksToAllUsersResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) tns1_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_SetLoggingLevelRequest : NSObject <NSCoding> {
/* elements */
	NSString * CSRtoken;
	NSString * Level;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_SetLoggingLevelRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * CSRtoken;
@property (nonatomic, retain) NSString * Level;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_SetLoggingLevelResponse : NSObject <NSCoding> {
/* elements */
	tns1_StatusHolder * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_SetLoggingLevelResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) tns1_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_HealthCheckRequest : NSObject <NSCoding> {
/* elements */
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_HealthCheckRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_EndpointsList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *Endpoint;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_EndpointsList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addEndpoint:(NSString *)toAdd;
@property (nonatomic, readonly) NSMutableArray * Endpoint;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_DBSchemaError : NSObject <NSCoding> {
/* elements */
	NSDate * lastDBModify;
	tns1_DBSchemaErrorList * errorList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_DBSchemaError *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSDate * lastDBModify;
@property (nonatomic, retain) tns1_DBSchemaErrorList * errorList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_HealthCheckResponse : NSObject <NSCoding> {
/* elements */
	NSNumber * statusCode;
	NSString * datapipe;
	NSString * gatewayDatabase;
	NSString * activityLogDatabase;
	tns1_EndpointsList * endpoints;
	NSString * currentDBVersion;
	NSString * LAversion;
	tns1_DBSchemaError * DBSchemaErrors;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_HealthCheckResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * statusCode;
@property (nonatomic, retain) NSString * datapipe;
@property (nonatomic, retain) NSString * gatewayDatabase;
@property (nonatomic, retain) NSString * activityLogDatabase;
@property (nonatomic, retain) tns1_EndpointsList * endpoints;
@property (nonatomic, retain) NSString * currentDBVersion;
@property (nonatomic, retain) NSString * LAversion;
@property (nonatomic, retain) tns1_DBSchemaError * DBSchemaErrors;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_GetVersionRequest : NSObject <NSCoding> {
/* elements */
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_GetVersionRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_GetVersionResponse : NSObject <NSCoding> {
/* elements */
	NSString * version;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_GetVersionResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * version;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ListTopRatingsRequest : NSObject <NSCoding> {
/* elements */
	NSString * authToken;
	NSNumber * count;
	tns1_TopRatingsRequestList * topRatingsRequestList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ListTopRatingsRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authToken;
@property (nonatomic, retain) NSNumber * count;
@property (nonatomic, retain) tns1_TopRatingsRequestList * topRatingsRequestList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ListTopRatingsResponse : NSObject <NSCoding> {
/* elements */
	tns1_StatusHolder * statusMessage;
	tns1_TopRatingsResponseList * topRatingsResponseList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ListTopRatingsResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) tns1_StatusHolder * statusMessage;
@property (nonatomic, retain) tns1_TopRatingsResponseList * topRatingsResponseList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_SaveRatingsRequest : NSObject <NSCoding> {
/* elements */
	NSString * authToken;
	tns1_RatingsList * ratingsList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_SaveRatingsRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authToken;
@property (nonatomic, retain) tns1_RatingsList * ratingsList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_SaveRatingsResponse : NSObject <NSCoding> {
/* elements */
	tns1_StatusHolder * statusMessage;
	tns1_RatingsStatusList * ratingsList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_SaveRatingsResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) tns1_StatusHolder * statusMessage;
@property (nonatomic, retain) tns1_RatingsStatusList * ratingsList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ListRatingsRequest : NSObject <NSCoding> {
/* elements */
	NSString * authToken;
	tns1_ListRatingsRequestList * ratingsList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ListRatingsRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authToken;
@property (nonatomic, retain) tns1_ListRatingsRequestList * ratingsList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_ListRatingsResponse : NSObject <NSCoding> {
/* elements */
	tns1_StatusHolder * statusMessage;
	tns1_RatingsStatusList * ratingsList;
	tns1_ItemsCount * itemsCount;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_ListRatingsResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) tns1_StatusHolder * statusMessage;
@property (nonatomic, retain) tns1_RatingsStatusList * ratingsList;
@property (nonatomic, retain) tns1_ItemsCount * itemsCount;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_DeregisterAllDevicesRequest : NSObject <NSCoding> {
/* elements */
	NSString * authToken;
	USBoolean * deregistrationConfirmed;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_DeregisterAllDevicesRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authToken;
@property (nonatomic, retain) USBoolean * deregistrationConfirmed;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_DeregisterAllDevicesResponse : NSObject <NSCoding> {
/* elements */
	tns1_StatusHolder * statusMessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_DeregisterAllDevicesResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) tns1_StatusHolder * statusMessage;
/* attributes */
- (NSDictionary *)attributes;
@end
