//
//  SCHLibreAccessConstants.m
//  Scholastic
//
//  Created by John S. Eddie on 07/10/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHLibreAccessConstants.h"

// Method Constants
NSString * const kSCHLibreAccessWebServiceTokenExchange = @"TokenExchange";
NSString * const kSCHLibreAccessWebServiceAuthenticateDevice = @"AuthenticateDevice";
NSString * const kSCHLibreAccessWebServiceRenewToken = @"RenewToken";
NSString * const kSCHLibreAccessWebServiceGetUserProfiles = @"GetUserProfiles";
NSString * const kSCHLibreAccessWebServiceSaveUserProfiles = @"SaveUserProfiles";
NSString * const kSCHLibreAccessWebServiceListUserContentForRatings = @"ListUserContentForRatings";
NSString * const kSCHLibreAccessWebServiceListFavoriteTypes = @"ListFavoriteTypes";
NSString * const kSCHLibreAccessWebServiceListTopFavorites = @"ListTopFavorites";
NSString * const kSCHLibreAccessWebServiceListContentMetadata = @"ListContentMetadata";
NSString * const kSCHLibreAccessWebServiceListUserSettings = @"ListUserSettings";
NSString * const kSCHLibreAccessWebServiceSaveUserSettings = @"SaveUserSettings";
NSString * const kSCHLibreAccessWebServiceListProfileContentAnnotationsForRatings = @"ListProfileContentAnnotationsForRatings";
NSString * const kSCHLibreAccessWebServiceSaveProfileContentAnnotationsForRatings = @"SaveProfileContentAnnotationsForRatings";
NSString * const kSCHLibreAccessWebServiceSaveContentProfileAssignment = @"SaveContentProfileAssignment";
NSString * const kSCHLibreAccessWebServiceSaveReadingStatisticsDetailed = @"SaveReadingStatisticsDetailed";

// Parameter Constants
NSString * const kSCHLibreAccessWebServiceAction = @"Action";
NSString * const kSCHLibreAccessWebServiceAnnotationStatusContentList = @"AnnotationStatusContentList";
NSString * const kSCHLibreAccessWebServiceAnnotationStatusList = @"AnnotationStatusList";
NSString * const kSCHLibreAccessWebServiceAnnotationsContentItem = @"AnnotationsContentItem";
NSString * const kSCHLibreAccessWebServiceAnnotationsContentList = @"AnnotationsContentList";
NSString * const kSCHLibreAccessWebServiceAnnotationsList = @"AnnotationsList";
NSString * const kSCHLibreAccessWebServiceAssignedBooksOnly = @"AssignedBooksOnly";
NSString * const kSCHLibreAccessWebServiceAssignedProfileList = @"AssignedProfileList";
NSString * const kSCHLibreAccessWebServiceAuthToken = @"AuthToken";
NSString * const kSCHLibreAccessWebServiceAuthor = @"Author";
NSString * const kSCHLibreAccessWebServiceAutoAssignContentToProfiles = @"AutoAssignContentToProfiles";
NSString * const kSCHLibreAccessWebServiceAutoloadContent = @"AutoloadContent";
NSString * const kSCHLibreAccessWebServiceAverageRating = @"AverageRating";
NSString * const kSCHLibreAccessWebServiceBadLoginAttempts = @"BadLoginAttempts";
NSString * const kSCHLibreAccessWebServiceBadLoginDatetimeUTC = @"BadLoginDatetimeUTC";
NSString * const kSCHLibreAccessWebServiceBirthday = @"Birthday";
NSString * const kSCHLibreAccessWebServiceBookmarks = @"Bookmarks";
NSString * const kSCHLibreAccessWebServiceBookmarksAfter = @"BookmarksAfter";
NSString * const kSCHLibreAccessWebServiceBookmarksStatusList = @"BookmarksStatusList";
NSString * const kSCHLibreAccessWebServiceBookshelfStyle = @"BookshelfStyle";
NSString * const kSCHLibreAccessWebServiceColor = @"Color";
NSString * const kSCHLibreAccessWebServiceComponent = @"Component";
NSString * const kSCHLibreAccessWebServiceContentIdentifier = @"ContentIdentifier";
NSString * const kSCHLibreAccessWebServiceContentIdentifierType = @"ContentIdentifierType";
NSString * const kSCHLibreAccessWebServiceContentMetadataList = @"ContentMetadataList";
NSString * const kSCHLibreAccessWebServiceContentProfileList = @"ContentProfileList";
NSString * const kSCHLibreAccessWebServiceContentURL = @"ContentURL";
NSString * const kSCHLibreAccessWebServiceCoords = @"Coords";
NSString * const kSCHLibreAccessWebServiceCoverURL = @"CoverURL";
NSString * const kSCHLibreAccessWebServiceDRMQualifier = @"DRMQualifier";
NSString * const kSCHLibreAccessWebServiceDefaultAssignment = @"DefaultAssignment";
NSString * const kSCHLibreAccessWebServiceDeregistrationConfirmed = @"DeregistrationConfirmed";
NSString * const kSCHLibreAccessWebServiceDescription = @"Description";
NSString * const kSCHLibreAccessWebServiceDeviceId = @"DeviceId";
NSString * const kSCHLibreAccessWebServiceDeviceIsDeregistered = @"DeviceIsDeregistered";
NSString * const kSCHLibreAccessWebServiceDeviceKey = @"DeviceKey";
NSString * const kSCHLibreAccessWebServiceDeviceNickname = @"DeviceNickname";
NSString * const kSCHLibreAccessWebServiceDevicePlatform = @"DevicePlatform";
NSString * const kSCHLibreAccessWebServiceDictionaryLookups = @"DictionaryLookups";
NSString * const kSCHLibreAccessWebServiceDictionaryLookupsList = @"DictionaryLookupsList";
NSString * const kSCHLibreAccessWebServiceDisabled = @"Disabled";
NSString * const kSCHLibreAccessWebServiceEnd = @"End";
NSString * const kSCHLibreAccessWebServiceEndPage = @"EndPage";
NSString * const kSCHLibreAccessWebServiceEnhanced = @"Enhanced";
NSString * const kSCHLibreAccessWebServiceExpiresIn = @"ExpiresIn";
NSString * const kSCHLibreAccessWebServiceFavoriteType = @"FavoriteType";
NSString * const kSCHLibreAccessWebServiceFavoriteTypeValuesList = @"FavoriteTypeValuesList";
NSString * const kSCHLibreAccessWebServiceFavoriteTypesList = @"FavoriteTypesList";
NSString * const kSCHLibreAccessWebServiceFileSize = @"FileSize";
NSString * const kSCHLibreAccessWebServiceFirstName = @"FirstName";
NSString * const kSCHLibreAccessWebServiceFormat = @"Format";
NSString * const kSCHLibreAccessWebServiceFound = @"Found";
NSString * const kSCHLibreAccessWebServiceFreeBook = @"FreeBook";
NSString * const kSCHLibreAccessWebServiceHighlights = @"Highlights";
NSString * const kSCHLibreAccessWebServiceHighlightsAfter = @"HighlightsAfter";
NSString * const kSCHLibreAccessWebServiceHighlightsStatusList = @"HighlightsStatusList";
NSString * const kSCHLibreAccessWebServiceID = @"ID";
NSString * const kSCHLibreAccessWebServiceISBN = @"ISBN";
NSString * const kSCHLibreAccessWebServiceItemsCount = @"ItemsCount";
NSString * const kSCHLibreAccessWebServiceLastActivated = @"LastActivated";
NSString * const kSCHLibreAccessWebServiceLastModified = @"LastModified";
NSString * const kSCHLibreAccessWebServiceLastName = @"LastName";
NSString * const kSCHLibreAccessWebServiceLastPage = @"LastPage";
NSString * const kSCHLibreAccessWebServiceLastPageLocation = @"LastPageLocation";
NSString * const kSCHLibreAccessWebServiceLastPageStatus = @"LastPageStatus";
NSString * const kSCHLibreAccessWebServiceLastPasswordModified = @"LastPasswordModified";
NSString * const kSCHLibreAccessWebServiceLastScreenNameModified = @"LastScreenNameModified";
NSString * const kSCHLibreAccessWebServiceLastVersion = @"LastVersion";
NSString * const kSCHLibreAccessWebServiceLocation = @"Location";
NSString * const kSCHLibreAccessWebServiceLocationPage = @"Location.Page";
NSString * const kSCHLibreAccessWebServiceNotes = @"Notes";
NSString * const kSCHLibreAccessWebServiceNotesAfter = @"NotesAfter";
NSString * const kSCHLibreAccessWebServiceNotesStatusList = @"NotesStatusList";
NSString * const kSCHLibreAccessWebServiceOrderDate = @"OrderDate";
NSString * const kSCHLibreAccessWebServiceOrderID = @"OrderID";
NSString * const kSCHLibreAccessWebServiceOrderList = @"OrderList";
NSString * const kSCHLibreAccessWebServicePage = @"Page";
NSString * const kSCHLibreAccessWebServicePageNumber = @"PageNumber";
NSString * const kSCHLibreAccessWebServicePagesRead = @"PagesRead";
NSString * const kSCHLibreAccessWebServicePassword = @"Password";
NSString * const kSCHLibreAccessWebServicePercentage = @"Percentage";
NSString * const kSCHLibreAccessWebServicePrivateAnnotations = @"PrivateAnnotations";
NSString * const kSCHLibreAccessWebServicePrivateAnnotationsStatus = @"PrivateAnnotationsStatus";
NSString * const kSCHLibreAccessWebServiceProfileContentAnnotations = @"ListProfileContentAnnotations";
NSString * const kSCHLibreAccessWebServiceProfileID = @"ProfileID";
NSString * const kSCHLibreAccessWebServiceProfileList = @"ProfileList";
NSString * const kSCHLibreAccessWebServiceProfilePasswordRequired = @"ProfilePasswordRequired";
NSString * const kSCHLibreAccessWebServiceProfileStatusList = @"ProfileStatusList";
NSString * const kSCHLibreAccessWebServiceRating = @"Rating";
NSString * const kSCHLibreAccessWebServiceRatingStatus = @"RatingStatus";
NSString * const kSCHLibreAccessWebServiceReadingDuration = @"ReadingDuration";
NSString * const kSCHLibreAccessWebServiceReadingStatsContentItem = @"ReadingStatsContentItem";
NSString * const kSCHLibreAccessWebServiceReadingStatsEntryItem = @"ReadingStatsEntryItem";
NSString * const kSCHLibreAccessWebServiceRecommendationsOn = @"RecommendationsOn";
NSString * const kSCHLibreAccessWebServiceRemoveReason = @"RemoveReason";
NSString * const kSCHLibreAccessWebServiceReturned = @"Returned";
NSString * const kSCHLibreAccessWebServiceScreenName = @"ScreenName";
NSString * const kSCHLibreAccessWebServiceSettingName = @"SettingName";
NSString * const kSCHLibreAccessWebServiceSettingValue = @"SettingValue";
NSString * const kSCHLibreAccessWebServiceStart = @"Start";
NSString * const kSCHLibreAccessWebServiceStatus = @"Status";
NSString * const kSCHLibreAccessWebServiceStatusCode = @"StatusCode";
NSString * const kSCHLibreAccessWebServiceStatusHolder = @"StatusHolder";
NSString * const kSCHLibreAccessWebServiceStatusMessage = @"StatusMessage";
NSString * const kSCHLibreAccessWebServiceStoryInteractionEnabled = @"StoryInteractionEnabled";
NSString * const kSCHLibreAccessWebServiceStoryInteractions = @"StoryInteractions";
NSString * const kSCHLibreAccessWebServiceText = @"Text";
NSString * const kSCHLibreAccessWebServiceTimestamp = @"Timestamp";
NSString * const kSCHLibreAccessWebServiceTitle = @"Title";
NSString * const kSCHLibreAccessWebServiceTopFavoritesContentItems = @"TopFavoritesContentItems";
NSString * const kSCHLibreAccessWebServiceTopFavoritesList = @"TopFavoritesList";
NSString * const kSCHLibreAccessWebServiceTopFavoritesType = @"TopFavoritesType";
NSString * const kSCHLibreAccessWebServiceTopFavoritesTypeValue = @"TopFavoritesTypeValue";
NSString * const kSCHLibreAccessWebServiceType = @"Type";
NSString * const kSCHLibreAccessWebServiceUserContentList = @"UserContentList";
NSString * const kSCHLibreAccessWebServiceUserKey = @"UserKey";
NSString * const kSCHLibreAccessWebServiceUserSettingsList = @"UserSettingsList";
NSString * const kSCHLibreAccessWebServiceUserSettingsStatusList = @"UserSettingsStatusList";
NSString * const kSCHLibreAccessWebServiceValue = @"Value";
NSString * const kSCHLibreAccessWebServiceVersion = @"Version";
NSString * const kSCHLibreAccessWebServiceWordIndex = @"WordIndex";
NSString * const kSCHLibreAccessWebServiceX = @"X";
NSString * const kSCHLibreAccessWebServiceY = @"Y";

NSString * const kSCHLibreAccessWebServiceeReaderCategories = @"eReaderCategories";
