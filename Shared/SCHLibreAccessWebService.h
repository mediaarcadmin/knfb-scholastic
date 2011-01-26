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

// Parameters
static NSString * const kSCHLibreAccessWebServiceAction = @"action";
static NSString * const kSCHLibreAccessWebServiceAnnotationsContentList = @"AnnotationsContentList";
static NSString * const kSCHLibreAccessWebServiceAnnotationsList = @"AnnotationsList";
static NSString * const kSCHLibreAccessWebServiceAssignedProfileList = @"AssignedProfileList";
static NSString * const kSCHLibreAccessWebServiceAuthToken = @"authtoken";
static NSString * const kSCHLibreAccessWebServiceAuthor = @"Author";
static NSString * const kSCHLibreAccessWebServiceAutoAssignContentToProfiles = @"AutoAssignContentToProfiles";
static NSString * const kSCHLibreAccessWebServiceBirthDay = @"BirthDay";
static NSString * const kSCHLibreAccessWebServiceBookmarks = @"Bookmarks";
static NSString * const kSCHLibreAccessWebServiceBookmarksAfter = @"BookmarksAfter";
static NSString * const kSCHLibreAccessWebServiceBookshelfStyle = @"BookshelfStyle";
static NSString * const kSCHLibreAccessWebServiceColor = @"color";
static NSString * const kSCHLibreAccessWebServiceComponent = @"component";
static NSString * const kSCHLibreAccessWebServiceContentIdentifier = @"ContentIdentifier";
static NSString * const kSCHLibreAccessWebServiceContentIdentifierType = @"ContentIdentifierType";
static NSString * const kSCHLibreAccessWebServiceContentMetadataList = @"ContentMetadataList";
static NSString * const kSCHLibreAccessWebServiceContentProfileList = @"ContentProfileList";
static NSString * const kSCHLibreAccessWebServiceContentURL = @"ContentURL";
static NSString * const kSCHLibreAccessWebServiceCoords = @"coords";
static NSString * const kSCHLibreAccessWebServiceCoverURL = @"CoverURL";
static NSString * const kSCHLibreAccessWebServiceDRMQualifier = @"DRMQualifier";
static NSString * const kSCHLibreAccessWebServiceDefaultAssignment = @"DefaultAssignment";
static NSString * const kSCHLibreAccessWebServiceDescription = @"Description";
static NSString * const kSCHLibreAccessWebServiceDeviceIsDeregistered = @"deviceIsDeregistered";
static NSString * const kSCHLibreAccessWebServiceDeviceKey = @"deviceKey";
static NSString * const kSCHLibreAccessWebServiceDictionaryLookups = @"dictionaryLookups";
static NSString * const kSCHLibreAccessWebServiceDictionaryLookupsList = @"DictionaryLookupsList";
static NSString * const kSCHLibreAccessWebServiceDisabled = @"disabled";
static NSString * const kSCHLibreAccessWebServiceEnd = @"end";
static NSString * const kSCHLibreAccessWebServiceEndPage = @"endPage";
static NSString * const kSCHLibreAccessWebServiceEreaderCategories = @"EreaderCategories";
static NSString * const kSCHLibreAccessWebServiceExpiresIn = @"expiresIn";
static NSString * const kSCHLibreAccessWebServiceFavorite = @"Favorite";
static NSString * const kSCHLibreAccessWebServiceFileSize = @"FileSize";
static NSString * const kSCHLibreAccessWebServiceFirstname = @"Firstname";
static NSString * const kSCHLibreAccessWebServiceFormat = @"Format";
static NSString * const kSCHLibreAccessWebServiceHighlights = @"Highlights";
static NSString * const kSCHLibreAccessWebServiceHighlightsAfter = @"HighlightsAfter";
static NSString * const kSCHLibreAccessWebServiceID = @"ID";
static NSString * const kSCHLibreAccessWebServiceISBN = @"ISBN";
static NSString * const kSCHLibreAccessWebServiceIsFavorite = @"isFavorite";
static NSString * const kSCHLibreAccessWebServiceLastModified = @"LastModified";
static NSString * const kSCHLibreAccessWebServiceLastPage = @"LastPage";
static NSString * const kSCHLibreAccessWebServiceLastPageLocation = @"lastPageLocation";
static NSString * const kSCHLibreAccessWebServiceLastPasswordModified = @"LastPasswordModified";
static NSString * const kSCHLibreAccessWebServiceLastScreenNameModified = @"LastScreenNameModified";
static NSString * const kSCHLibreAccessWebServiceLastname = @"Lastname";
static NSString * const kSCHLibreAccessWebServiceLocation = @"location";
static NSString * const kSCHLibreAccessWebServiceLocationBookmark = @"location";
static NSString * const kSCHLibreAccessWebServiceLocationGraphics = @"location";
static NSString * const kSCHLibreAccessWebServiceLocationText = @"location";
static NSString * const kSCHLibreAccessWebServiceNotes = @"Notes";
static NSString * const kSCHLibreAccessWebServiceNotesAfter = @"NotesAfter";
static NSString * const kSCHLibreAccessWebServiceOrderDate = @"OrderDate";
static NSString * const kSCHLibreAccessWebServiceOrderID = @"OrderID";
static NSString * const kSCHLibreAccessWebServiceOrderList = @"OrderList";
static NSString * const kSCHLibreAccessWebServicePage = @"page";
static NSString * const kSCHLibreAccessWebServicePageNumber = @"PageNumber";
static NSString * const kSCHLibreAccessWebServicePagesRead = @"pagesRead";
static NSString * const kSCHLibreAccessWebServicePassword = @"Password";
static NSString * const kSCHLibreAccessWebServicePercentage = @"percentage";
static NSString * const kSCHLibreAccessWebServicePrivateAnnotations = @"PrivateAnnotations";
static NSString * const kSCHLibreAccessWebServiceProductType = @"ProductType";
static NSString * const kSCHLibreAccessWebServiceProfileID = @"profileID";
static NSString * const kSCHLibreAccessWebServiceProfileList = @"ProfileList";
static NSString * const kSCHLibreAccessWebServiceProfilePasswordRequired = @"ProfilePasswordRequired";
static NSString * const kSCHLibreAccessWebServiceProfileStatusList = @"ProfileStatusList";
static NSString * const kSCHLibreAccessWebServiceReadingDuration = @"readingDuration";
static NSString * const kSCHLibreAccessWebServiceReadingStatsContentList = @"ReadingStatsContentList";
static NSString * const kSCHLibreAccessWebServiceScreenname = @"Screenname";
static NSString * const kSCHLibreAccessWebServiceSettingType = @"SettingType";
static NSString * const kSCHLibreAccessWebServiceSettingValue = @"SettingValue";
static NSString * const kSCHLibreAccessWebServiceStart = @"start";
static NSString * const kSCHLibreAccessWebServiceStatus = @"status";
static NSString * const kSCHLibreAccessWebServiceStatuscode = @"statuscode";
static NSString * const kSCHLibreAccessWebServiceStatusmessage = @"statusmessage";
static NSString * const kSCHLibreAccessWebServiceStoryInteractionEnabled = @"StoryInteractionEnabled";
static NSString * const kSCHLibreAccessWebServiceStoryInteractions = @"storyInteractions";
static NSString * const kSCHLibreAccessWebServiceText = @"text";
static NSString * const kSCHLibreAccessWebServiceTimestamp = @"timestamp";
static NSString * const kSCHLibreAccessWebServiceTitle = @"Title";
static NSString * const kSCHLibreAccessWebServiceType = @"Type";
static NSString * const kSCHLibreAccessWebServiceUserContentList = @"UserContentList";
static NSString * const kSCHLibreAccessWebServiceUserSettingsList = @"UserSettingsList";
static NSString * const kSCHLibreAccessWebServiceUserkey = @"Userkey";
static NSString * const kSCHLibreAccessWebServiceValue = @"value";
static NSString * const kSCHLibreAccessWebServiceVersion = @"Version";
static NSString * const kSCHLibreAccessWebServiceWordIndex = @"wordindex";
static NSString * const kSCHLibreAccessWebServiceX = @"x";
static NSString * const kSCHLibreAccessWebServiceY = @"y";


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
