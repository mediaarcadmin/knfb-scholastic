//
//  LibreAccessWebService.h
//  WebAPI
//
//  Created by John S. Eddie on 21/12/2010.
//  Copyright 2010 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BITSOAPProxy.h"

#import "LibreAccessServiceSvc.h"
#import "BITObjectMapperProtocol.h"

// Method Constants
extern NSString * const kSCHLibreAccessWebServiceTokenExchange;
extern NSString * const kSCHLibreAccessWebServiceAuthenticateDevice;
extern NSString * const kSCHLibreAccessWebServiceRenewToken;
extern NSString * const kSCHLibreAccessWebServiceGetUserProfiles;
extern NSString * const kSCHLibreAccessWebServiceSaveUserProfiles;
extern NSString * const kSCHLibreAccessWebServiceListUserContent;
extern NSString * const kSCHLibreAccessWebServiceListFavoriteTypes;
extern NSString * const kSCHLibreAccessWebServiceListTopFavorites;
extern NSString * const kSCHLibreAccessWebServiceListContentMetadata;
extern NSString * const kSCHLibreAccessWebServiceListUserSettings;
extern NSString * const kSCHLibreAccessWebServiceSaveUserSettings;
extern NSString * const kSCHLibreAccessWebServiceListProfileContentAnnotations;
extern NSString * const kSCHLibreAccessWebServiceSaveProfileContentAnnotations;
extern NSString * const kSCHLibreAccessWebServiceSaveContentProfileAssignment;
extern NSString * const kSCHLibreAccessWebServiceSaveReadingStatisticsDetailed;

// Parameter Constants
extern NSString * const kSCHLibreAccessWebServiceAction;
extern NSString * const kSCHLibreAccessWebServiceAnnotationsContentList;
extern NSString * const kSCHLibreAccessWebServiceAnnotationsContentItem;
extern NSString * const kSCHLibreAccessWebServiceAnnotationsList;
extern NSString * const kSCHLibreAccessWebServiceAnnotationStatusList;
extern NSString * const kSCHLibreAccessWebServiceAnnotationStatusContentList;
extern NSString * const kSCHLibreAccessWebServiceAssignedBooksOnly;
extern NSString * const kSCHLibreAccessWebServiceAssignedProfileList;
extern NSString * const kSCHLibreAccessWebServiceAuthToken;
extern NSString * const kSCHLibreAccessWebServiceAuthor;
extern NSString * const kSCHLibreAccessWebServiceAutoAssignContentToProfiles;
extern NSString * const kSCHLibreAccessWebServiceAutoloadContent;
extern NSString * const kSCHLibreAccessWebServiceBadLoginAttempts;
extern NSString * const kSCHLibreAccessWebServiceBadLoginDatetimeUTC;
extern NSString * const kSCHLibreAccessWebServiceBirthday;
extern NSString * const kSCHLibreAccessWebServiceBookmarks;
extern NSString * const kSCHLibreAccessWebServiceBookmarksAfter;
extern NSString * const kSCHLibreAccessWebServiceBookmarksStatusList;
extern NSString * const kSCHLibreAccessWebServiceBookshelfStyle;
extern NSString * const kSCHLibreAccessWebServiceColor;
extern NSString * const kSCHLibreAccessWebServiceComponent;
extern NSString * const kSCHLibreAccessWebServiceContentIdentifier;
extern NSString * const kSCHLibreAccessWebServiceContentIdentifierType;
extern NSString * const kSCHLibreAccessWebServiceContentMetadataList;
extern NSString * const kSCHLibreAccessWebServiceContentProfileList;
extern NSString * const kSCHLibreAccessWebServiceContentURL;
extern NSString * const kSCHLibreAccessWebServiceCoords;
extern NSString * const kSCHLibreAccessWebServiceCoverURL;
extern NSString * const kSCHLibreAccessWebServiceDRMQualifier;
extern NSString * const kSCHLibreAccessWebServiceDefaultAssignment;
extern NSString * const kSCHLibreAccessWebServiceDeregistrationConfirmed;
extern NSString * const kSCHLibreAccessWebServiceDescription;
extern NSString * const kSCHLibreAccessWebServiceDeviceId;
extern NSString * const kSCHLibreAccessWebServiceDeviceIsDeregistered;
extern NSString * const kSCHLibreAccessWebServiceDeviceKey;
extern NSString * const kSCHLibreAccessWebServiceDeviceNickname;
extern NSString * const kSCHLibreAccessWebServiceDevicePlatform;
extern NSString * const kSCHLibreAccessWebServiceDictionaryLookups;
extern NSString * const kSCHLibreAccessWebServiceDictionaryLookupsList;
extern NSString * const kSCHLibreAccessWebServiceDisabled;
extern NSString * const kSCHLibreAccessWebServiceEnd;
extern NSString * const kSCHLibreAccessWebServiceEndPage;
extern NSString * const kSCHLibreAccessWebServiceEnhanced;
extern NSString * const kSCHLibreAccessWebServiceExpiresIn;
extern NSString * const kSCHLibreAccessWebServiceFavoriteType;
extern NSString * const kSCHLibreAccessWebServiceFavoriteTypeValuesList;
extern NSString * const kSCHLibreAccessWebServiceFavoriteTypesList;
extern NSString * const kSCHLibreAccessWebServiceFileSize;
extern NSString * const kSCHLibreAccessWebServiceFirstName;
extern NSString * const kSCHLibreAccessWebServiceFormat;
extern NSString * const kSCHLibreAccessWebServiceFound;
extern NSString * const kSCHLibreAccessWebServiceHighlights;
extern NSString * const kSCHLibreAccessWebServiceHighlightsAfter;
extern NSString * const kSCHLibreAccessWebServiceHighlightsStatusList;
extern NSString * const kSCHLibreAccessWebServiceID;
extern NSString * const kSCHLibreAccessWebServiceISBN;
extern NSString * const kSCHLibreAccessWebServiceIsFavorite;
extern NSString * const kSCHLibreAccessWebServiceItemsCount;
extern NSString * const kSCHLibreAccessWebServiceLastActivated;
extern NSString * const kSCHLibreAccessWebServiceLastModified;
extern NSString * const kSCHLibreAccessWebServiceLastName;
extern NSString * const kSCHLibreAccessWebServiceLastPage;
extern NSString * const kSCHLibreAccessWebServiceLastPageLocation;
extern NSString * const kSCHLibreAccessWebServiceLastPageStatus;
extern NSString * const kSCHLibreAccessWebServiceLastPasswordModified;
extern NSString * const kSCHLibreAccessWebServiceLastScreenNameModified;
extern NSString * const kSCHLibreAccessWebServiceLocation;
extern NSString * const kSCHLibreAccessWebServiceNotes;
extern NSString * const kSCHLibreAccessWebServiceNotesAfter;
extern NSString * const kSCHLibreAccessWebServiceNotesStatusList;
extern NSString * const kSCHLibreAccessWebServiceOrderDate;
extern NSString * const kSCHLibreAccessWebServiceOrderID;
extern NSString * const kSCHLibreAccessWebServiceOrderList;
extern NSString * const kSCHLibreAccessWebServicePage;
extern NSString * const kSCHLibreAccessWebServiceLocationPage;
extern NSString * const kSCHLibreAccessWebServicePageNumber;
extern NSString * const kSCHLibreAccessWebServicePagesRead;
extern NSString * const kSCHLibreAccessWebServicePassword;
extern NSString * const kSCHLibreAccessWebServicePercentage;
extern NSString * const kSCHLibreAccessWebServicePrivateAnnotations;
extern NSString * const kSCHLibreAccessWebServicePrivateAnnotationsStatus;
extern NSString * const kSCHLibreAccessWebServiceProfileContentAnnotations;
extern NSString * const kSCHLibreAccessWebServiceProfileID;
extern NSString * const kSCHLibreAccessWebServiceProfileList;
extern NSString * const kSCHLibreAccessWebServiceProfilePasswordRequired;
extern NSString * const kSCHLibreAccessWebServiceProfileStatusList;
extern NSString * const kSCHLibreAccessWebServiceReadingDuration;
extern NSString * const kSCHLibreAccessWebServiceReadingStatsContentItem;
extern NSString * const kSCHLibreAccessWebServiceReadingStatsEntryItem;
extern NSString * const kSCHLibreAccessWebServiceRemoveReason;
extern NSString * const kSCHLibreAccessWebServiceReturned;
extern NSString * const kSCHLibreAccessWebServiceScreenName;
extern NSString * const kSCHLibreAccessWebServiceSettingType;
extern NSString * const kSCHLibreAccessWebServiceSettingValue;
extern NSString * const kSCHLibreAccessWebServiceStart;
extern NSString * const kSCHLibreAccessWebServiceStatus;
extern NSString * const kSCHLibreAccessWebServiceStatusCode;
extern NSString * const kSCHLibreAccessWebServiceStatusHolder;
extern NSString * const kSCHLibreAccessWebServiceStatusMessage;
extern NSString * const kSCHLibreAccessWebServiceStoryInteractionEnabled;
extern NSString * const kSCHLibreAccessWebServiceStoryInteractions;
extern NSString * const kSCHLibreAccessWebServiceText;
extern NSString * const kSCHLibreAccessWebServiceTimestamp;
extern NSString * const kSCHLibreAccessWebServiceTitle;
extern NSString * const kSCHLibreAccessWebServiceTopFavoritesContentItems;
extern NSString * const kSCHLibreAccessWebServiceTopFavoritesList;
extern NSString * const kSCHLibreAccessWebServiceTopFavoritesType;
extern NSString * const kSCHLibreAccessWebServiceTopFavoritesTypeValue;
extern NSString * const kSCHLibreAccessWebServiceType;
extern NSString * const kSCHLibreAccessWebServiceUserContentList;
extern NSString * const kSCHLibreAccessWebServiceUserKey;
extern NSString * const kSCHLibreAccessWebServiceUserSettingsList;
extern NSString * const kSCHLibreAccessWebServiceValue;
extern NSString * const kSCHLibreAccessWebServiceVersion;
extern NSString * const kSCHLibreAccessWebServiceWordIndex;
extern NSString * const kSCHLibreAccessWebServiceX;
extern NSString * const kSCHLibreAccessWebServiceY;

extern NSString * const kSCHLibreAccessWebServiceeReaderCategories;

@interface SCHLibreAccessWebService : BITSOAPProxy <LibreAccessServiceSoap11BindingResponseDelegate, BITObjectMapperProtocol> 
{
}

- (void)clear;

- (void)tokenExchange:(NSString *)pToken forUser:(NSString *)userName;
- (void)authenticateDevice:(NSString *)deviceKey forUserKey:(NSString *)userKey;
- (void)renewToken:(NSString *)aToken;
- (BOOL)getUserProfiles;
- (BOOL)saveUserProfiles:(NSArray *)userProfiles;
- (BOOL)listUserContent;
- (BOOL)listFavoriteTypes;
- (BOOL)listTopFavorites:(NSArray *)favorites withCount:(NSUInteger)count;
- (BOOL)listContentMetadata:(NSArray *)bookISBNs includeURLs:(BOOL)includeURLs;
- (BOOL)listUserSettings;
- (BOOL)saveUserSettings:(NSArray *)settings;
- (BOOL)listProfileContentAnnotations:(NSArray *)annotations forProfile:(NSNumber *)profileID;
- (BOOL)saveProfileContentAnnotations:(NSArray *)annotations;
- (BOOL)saveContentProfileAssignment:(NSArray *)contentProfileAssignments;
- (BOOL)saveReadingStatisticsDetailed:(NSArray *)readingStatsDetailList;


@end
