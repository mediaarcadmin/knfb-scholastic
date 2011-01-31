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

// Methods
static NSString * const kSCHLibreAccessWebServiceTokenExchange = @"TokenExchange";
static NSString * const kSCHLibreAccessWebServiceGetUserProfiles = @"GetUserProfiles";
static NSString * const kSCHLibreAccessWebServiceSaveUserProfiles = @"SaveUserProfiles";
static NSString * const kSCHLibreAccessWebServiceListUserContent = @"ListUserContent";
static NSString * const kSCHLibreAccessWebServiceListContentMetadata = @"ListContentMetadata";
static NSString * const kSCHLibreAccessWebServiceListUserSettings = @"ListUserSettings";
static NSString * const kSCHLibreAccessWebServiceSaveUserSettings = @"SaveUserSettings";
static NSString * const kSCHLibreAccessWebServiceListProfileContentAnnotations = @"ListProfileContentAnnotations";
static NSString * const kSCHLibreAccessWebServiceSaveProfileContentAnnotations = @"SaveProfileContentAnnotations";
static NSString * const kSCHLibreAccessWebServiceSaveContentProfileAssignment = @"SaveContentProfileAssignment";
static NSString * const kSCHLibreAccessWebServiceSaveReadingStatisticsDetailed = @"SaveReadingStatisticsDetailed";

// Parameters
static NSString * const kSCHLibreAccessWebServiceAction = @"Action";
static NSString * const kSCHLibreAccessWebServiceAnnotationsContentList = @"AnnotationsContentList";
static NSString * const kSCHLibreAccessWebServiceAnnotationsList = @"AnnotationsList";
static NSString * const kSCHLibreAccessWebServiceAssignedProfileList = @"AssignedProfileList";
static NSString * const kSCHLibreAccessWebServiceAuthToken = @"AuthToken";
static NSString * const kSCHLibreAccessWebServiceAuthor = @"Author";
static NSString * const kSCHLibreAccessWebServiceAutoAssignContentToProfiles = @"AutoAssignContentToProfiles";
static NSString * const kSCHLibreAccessWebServiceBirthday = @"Birthday";
static NSString * const kSCHLibreAccessWebServiceBookmarks = @"Bookmarks";
static NSString * const kSCHLibreAccessWebServiceBookmarksAfter = @"BookmarksAfter";
static NSString * const kSCHLibreAccessWebServiceBookshelfStyle = @"BookshelfStyle";
static NSString * const kSCHLibreAccessWebServiceColor = @"Color";
static NSString * const kSCHLibreAccessWebServiceComponent = @"Component";
static NSString * const kSCHLibreAccessWebServiceContentIdentifier = @"ContentIdentifier";
static NSString * const kSCHLibreAccessWebServiceContentIdentifierType = @"ContentIdentifierType";
static NSString * const kSCHLibreAccessWebServiceContentMetadataList = @"ContentMetadataList";
static NSString * const kSCHLibreAccessWebServiceContentProfileList = @"ContentProfileList";
static NSString * const kSCHLibreAccessWebServiceContentURL = @"ContentURL";
static NSString * const kSCHLibreAccessWebServiceCoords = @"Coords";
static NSString * const kSCHLibreAccessWebServiceCoverURL = @"CoverURL";
static NSString * const kSCHLibreAccessWebServiceDRMQualifier = @"DRMQualifier";
static NSString * const kSCHLibreAccessWebServiceDefaultAssignment = @"DefaultAssignment";
static NSString * const kSCHLibreAccessWebServiceDescription = @"Description";
static NSString * const kSCHLibreAccessWebServiceDeviceIsDeregistered = @"DeviceIsDeregistered";
static NSString * const kSCHLibreAccessWebServiceDeviceKey = @"DeviceKey";
static NSString * const kSCHLibreAccessWebServiceDictionaryLookups = @"DictionaryLookups";
static NSString * const kSCHLibreAccessWebServiceDictionaryLookupsList = @"DictionaryLookupsList";
static NSString * const kSCHLibreAccessWebServiceDisabled = @"Disabled";
static NSString * const kSCHLibreAccessWebServiceEnd = @"End";
static NSString * const kSCHLibreAccessWebServiceEndPage = @"EndPage";
static NSString * const kSCHLibreAccessWebServiceeReaderCategories = @"eReaderCategories";
static NSString * const kSCHLibreAccessWebServiceExpiresIn = @"ExpiresIn";
static NSString * const kSCHLibreAccessWebServiceFavorite = @"Favorite";
static NSString * const kSCHLibreAccessWebServiceFileSize = @"FileSize";
static NSString * const kSCHLibreAccessWebServiceFirstName = @"FirstName";
static NSString * const kSCHLibreAccessWebServiceFormat = @"Format";
static NSString * const kSCHLibreAccessWebServiceFound = @"Found";
static NSString * const kSCHLibreAccessWebServiceHighlights = @"Highlights";
static NSString * const kSCHLibreAccessWebServiceHighlightsAfter = @"HighlightsAfter";
static NSString * const kSCHLibreAccessWebServiceID = @"ID";
static NSString * const kSCHLibreAccessWebServiceISBN = @"ISBN";
static NSString * const kSCHLibreAccessWebServiceIsFavorite = @"IsFavorite";
static NSString * const kSCHLibreAccessWebServiceItemsCount = @"ItemsCount";
static NSString * const kSCHLibreAccessWebServiceLastModified = @"LastModified";
static NSString * const kSCHLibreAccessWebServiceLastName = @"LastName";
static NSString * const kSCHLibreAccessWebServiceLastPage = @"LastPage";
static NSString * const kSCHLibreAccessWebServiceLastPageLocation = @"LastPageLocation";
static NSString * const kSCHLibreAccessWebServiceLastPasswordModified = @"LastPasswordModified";
static NSString * const kSCHLibreAccessWebServiceLastScreenNameModified = @"LastScreenNameModified";
static NSString * const kSCHLibreAccessWebServiceLocation = @"Location";
static NSString * const kSCHLibreAccessWebServiceLocationBookmark = @"LocationBookmark";
static NSString * const kSCHLibreAccessWebServiceLocationGraphics = @"LocationGraphics";
static NSString * const kSCHLibreAccessWebServiceLocationText = @"LocationText";
static NSString * const kSCHLibreAccessWebServiceNotes = @"Notes";
static NSString * const kSCHLibreAccessWebServiceNotesAfter = @"NotesAfter";
static NSString * const kSCHLibreAccessWebServiceOrderDate = @"OrderDate";
static NSString * const kSCHLibreAccessWebServiceOrderID = @"OrderID";
static NSString * const kSCHLibreAccessWebServiceOrderList = @"OrderList";
static NSString * const kSCHLibreAccessWebServicePage = @"Page";
static NSString * const kSCHLibreAccessWebServicePageNumber = @"PageNumber";
static NSString * const kSCHLibreAccessWebServicePagesRead = @"PagesRead";
static NSString * const kSCHLibreAccessWebServicePassword = @"Password";
static NSString * const kSCHLibreAccessWebServicePercentage = @"Percentage";
static NSString * const kSCHLibreAccessWebServicePrivateAnnotations = @"PrivateAnnotations";
static NSString * const kSCHLibreAccessWebServiceProductType = @"ProductType";
static NSString * const kSCHLibreAccessWebServiceProfileContentAnnotations = @"ListProfileContentAnnotations";
static NSString * const kSCHLibreAccessWebServiceProfileID = @"ProfileID";
static NSString * const kSCHLibreAccessWebServiceProfileList = @"ProfileList";
static NSString * const kSCHLibreAccessWebServiceProfilePasswordRequired = @"ProfilePasswordRequired";
static NSString * const kSCHLibreAccessWebServiceProfileStatusList = @"ProfileStatusList";
static NSString * const kSCHLibreAccessWebServiceReadingDuration = @"ReadingDuration";
static NSString * const kSCHLibreAccessWebServiceReadingStatsContentList = @"ReadingStatsContentList";
static NSString * const kSCHLibreAccessWebServiceReturned = @"Returned";
static NSString * const kSCHLibreAccessWebServiceScreenName = @"ScreenName";
static NSString * const kSCHLibreAccessWebServiceSettingType = @"SettingType";
static NSString * const kSCHLibreAccessWebServiceSettingValue = @"SettingValue";
static NSString * const kSCHLibreAccessWebServiceStart = @"Start";
static NSString * const kSCHLibreAccessWebServiceStatus = @"Status";
static NSString * const kSCHLibreAccessWebServiceStatusCode = @"StatusCode";
static NSString * const kSCHLibreAccessWebServiceStatusMessage = @"StatusMessage";
static NSString * const kSCHLibreAccessWebServiceStoryInteractionEnabled = @"StoryInteractionEnabled";
static NSString * const kSCHLibreAccessWebServiceStoryInteractions = @"StoryInteractions";
static NSString * const kSCHLibreAccessWebServiceText = @"Text";
static NSString * const kSCHLibreAccessWebServiceTimestamp = @"Timestamp";
static NSString * const kSCHLibreAccessWebServiceTitle = @"Title";
static NSString * const kSCHLibreAccessWebServiceType = @"Type";
static NSString * const kSCHLibreAccessWebServiceUserContentList = @"UserContentList";
static NSString * const kSCHLibreAccessWebServiceUserKey = @"UserKey";
static NSString * const kSCHLibreAccessWebServiceUserSettingsList = @"UserSettingsList";
static NSString * const kSCHLibreAccessWebServiceValue = @"Value";
static NSString * const kSCHLibreAccessWebServiceVersion = @"Version";
static NSString * const kSCHLibreAccessWebServiceWordIndex = @"WordIndex";
static NSString * const kSCHLibreAccessWebServiceX = @"X";
static NSString * const kSCHLibreAccessWebServiceY = @"Y";


@interface SCHLibreAccessWebService : BITSOAPProxy <LibreAccessServiceSoap11BindingResponseDelegate, BITObjectMapperProtocol> {
	LibreAccessServiceSoap11Binding *binding;
}

- (void)tokenExchange:(NSString *)pToken forUser:(NSString *)userName;
- (BOOL)getUserProfiles;
- (BOOL)saveUserProfiles:(NSArray *)userProfiles;
- (BOOL)listUserContent;
- (BOOL)listContentMetadata:(NSArray *)bookISBNs includeURLs:(BOOL)includeURLs;
- (BOOL)listUserSettings;
- (BOOL)saveUserSettings:(NSArray *)settings;
- (BOOL)listProfileContentAnnotations:(NSArray *)annotations forProfile:(NSNumber *)profileID;
- (BOOL)saveProfileContentAnnotations:(NSArray *)annotations;
- (BOOL)saveContentProfileAssignment:(NSArray *)contentProfileAssignments;
- (BOOL)saveReadingStatisticsDetailed:(NSArray *)readingStatsDetailList;


@end
