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


// Token Exchange
static NSString * const kSCHLibreAccessWebServiceTokenExchange = @"TokenExchange";

static NSString * const kSCHLibreAccessWebServiceAuthToken = @"authtoken";
static NSString * const kSCHLibreAccessWebServiceExpiresIn = @"expiresIn";
static NSString * const kSCHLibreAccessWebServiceDeviceIsDeregistered = @"deviceIsDeregistered";

// GetUserProfiles
static NSString * const kSCHLibreAccessWebServiceGetUserProfiles = @"GetUserProfiles";

static NSString * const kSCHLibreAccessWebServiceProfileList = @"ProfileList";
static NSString * const kSCHLibreAccessWebServiceAutoAssignContentToProfiles = @"AutoAssignContentToProfiles";
static NSString * const kSCHLibreAccessWebServiceProfilePasswordRequired = @"ProfilePasswordRequired";
static NSString * const kSCHLibreAccessWebServiceFirstname = @"Firstname";
static NSString * const kSCHLibreAccessWebServiceLastname = @"Lastname";
static NSString * const kSCHLibreAccessWebServiceBirthDay = @"BirthDay";
static NSString * const kSCHLibreAccessWebServiceScreenname = @"Screenname";
static NSString * const kSCHLibreAccessWebServicePassword = @"Password";
static NSString * const kSCHLibreAccessWebServiceUserkey = @"Userkey";
static NSString * const kSCHLibreAccessWebServiceType = @"Type";
static NSString * const kSCHLibreAccessWebServiceID = @"ID";
static NSString * const kSCHLibreAccessWebServiceBookshelfStyle = @"BookshelfStyle";
static NSString * const kSCHLibreAccessWebServiceLastModified = @"LastModified";
static NSString * const kSCHLibreAccessWebServiceLastScreenNameModified = @"LastScreenNameModified";
static NSString * const kSCHLibreAccessWebServiceLastPasswordModified = @"LastPasswordModified";
static NSString * const kSCHLibreAccessWebServiceStoryInteractionEnabled = @"StoryInteractionEnabled";

// ListUserContent
static NSString * const kSCHLibreAccessWebServiceListUserContent = @"ListUserContent";

static NSString * const kSCHLibreAccessWebServiceUserContentList = @"UserContentList";
static NSString * const kSCHLibreAccessWebServiceContentIdentifier = @"ContentIdentifier";
static NSString * const kSCHLibreAccessWebServiceContentIdentifierType = @"ContentIdentifierType";
static NSString * const kSCHLibreAccessWebServiceDRMQualifier = @"DRMQualifier";
static NSString * const kSCHLibreAccessWebServiceFormat = @"Format";
static NSString * const kSCHLibreAccessWebServiceVersion = @"Version";
static NSString * const kSCHLibreAccessWebServiceContentProfileList = @"ContentProfileList";
static NSString * const kSCHLibreAccessWebServiceOrderIDList = @"OrderIDList";
//static NSString * const kSCHLibreAccessWebServicelastmodified = @"lastmodified";
static NSString * const kSCHLibreAccessWebServiceDefaultAssignment = @"DefaultAssignment";

// ContentProfileItem
static NSString * const kSCHLibreAccessWebServiceprofileID = @"profileID";
static NSString * const kSCHLibreAccessWebServiceisFavorite = @"isFavorite";
static NSString * const kSCHLibreAccessWebServicelastPageLocation = @"lastPageLocation";
//static NSString * const kSCHLibreAccessWebServicelastmodified = @"lastmodified";

// OrderID
static NSString * const kSCHLibreAccessWebServiceOrderID = @"OrderID";

// ListContentMetadata
static NSString * const kSCHLibreAccessWebServiceListContentMetadata = @"ListContentMetadata";

static NSString * const kSCHLibreAccessWebServiceContentMetadataList = @"ContentMetadataList";
//static NSString * const kSCHLibreAccessWebServiceContentIdentifier = @"ContentIdentifier";
//static NSString * const kSCHLibreAccessWebServiceContentIdentifierType = @"ContentIdentifierType";
static NSString * const kSCHLibreAccessWebServiceTitle = @"Title";
static NSString * const kSCHLibreAccessWebServiceAuthor = @"Author";
static NSString * const kSCHLibreAccessWebServiceDescription = @"Description";
//static NSString * const kSCHLibreAccessWebServiceVersion = @"Version";
static NSString * const kSCHLibreAccessWebServicePageNumber = @"PageNumber";
static NSString * const kSCHLibreAccessWebServiceFileSize = @"FileSize";
//static NSString * const kSCHLibreAccessWebServiceDRMQualifier = @"DRMQualifier";
static NSString * const kSCHLibreAccessWebServiceCoverURL = @"CoverURL";
static NSString * const kSCHLibreAccessWebServiceContentURL = @"ContentURL";
static NSString * const kSCHLibreAccessWebServiceEreaderCategories = @"EreaderCategories";
static NSString * const kSCHLibreAccessWebServiceProductType = @"ProductType";


@interface SCHLibreAccessWebService : BITSOAPProxy <LibreAccessServiceSoap12BindingResponseDelegate, BITObjectMapperProtocol> {
	LibreAccessServiceSoap12Binding *binding;
}

- (void)tokenExchange:(NSString *)pToken forUser:(NSString *)userName;
- (void)getUserProfiles:(NSString *)aToken;
- (void)listUserContent:(NSString *)aToken;
- (void)listContentMetadata:(NSString *)aToken includeURLs:(BOOL)includeURLs forBooks:(NSArray *)bookISBNs;

@end
