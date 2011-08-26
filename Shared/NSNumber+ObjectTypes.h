//
//  NSNumber+ObjectTypes.h
//  Scholastic
//
//  Created by John S. Eddie on 17/01/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	kSCHStatusCreated = 0,
	kSCHStatusUnmodified,
	kSCHStatusModified,
	kSCHStatusDeleted,
    kSCHStatusSyncUpdate,		
} SCHStatus;

typedef enum {
	kSCHStatusCodesNone = 0,
	kSCHStatusCodesSuccess,
	kSCHStatusCodesFail,
} SCHStatusCodes;

typedef enum {
	kSCHProfileTypesNone = 0,
	kSCHProfileTypesPARENT,
	kSCHProfileTypesCHILD,
} SCHProfileTypes;

typedef enum {
	kSCHBookshelfStyleNone = 0,
	kSCHBookshelfStyleYoungChild,
	kSCHBookshelfStyleOlderChild,
	kSCHBookshelfStyleAdult,
} SCHBookshelfStyles;

typedef enum {
	kSCHContentIdentifierTypesNone = 0,
	kSCHContentItemContentIdentifierTypesISBN13,
} SCHContentIdentifierTypes;

typedef enum {
	kSCHDRMQualifiersNone = 0,
	kSCHDRMQualifiersFullWithDRM,
	kSCHDRMQualifiersFullNoDRM,
	kSCHDRMQualifiersSample,
} SCHDRMQualifiers;

typedef enum {
	kSCHSaveActionsNone = 0,
	kSCHSaveActionsCreate,
	kSCHSaveActionsUpdate,
	kSCHSaveActionsRemove,
} SCHSaveActions;

typedef enum {
	kSCHUserSettingsTypesNone = 0,
	kSCHUserSettingsTypesStoreReadStat,
	kSCHUserSettingsTypesDisableAutoAssign,
} SCHUserSettingsTypes;

typedef enum {
	kSCHTopFavoritesTypesNone = 0,
	kSCHTopFavoritesTypeseReaderCategory,
	kSCHTopFavoritesTypeseReaderCategoryClass,
} SCHTopFavoritesTypes;

typedef enum {
	kSCHDataStoreTypesStandard,
	kSCHDataStoreTypesSample,
} SCHDataStoreTypes;

@interface NSNumber (ObjectTypes)

+ (NSNumber *)numberWithStatus:(SCHStatus)value;
- (id)initWithStatus:(SCHStatus)value;
- (SCHStatus)statusValue;

+ (NSNumber *)numberWithStatusCode:(SCHStatusCodes)value;
- (id)initWithStatusCode:(SCHStatusCodes)value;
- (SCHStatusCodes)statusCodeValue;

+ (NSNumber *)numberWithProfileType:(SCHProfileTypes)value;
- (id)initWithProfileType:(SCHProfileTypes)value;
- (SCHProfileTypes)profileTypeValue;

+ (NSNumber *)numberWithBookshelfStyle:(SCHBookshelfStyles)value;
- (id)initWithBookshelfStyle:(SCHBookshelfStyles)value;
- (SCHBookshelfStyles)bookshelfStyleValue;

+ (NSNumber *)numberWithContentIdentifierType:(SCHContentIdentifierTypes)value;
- (id)initWithContentIdentifierType:(SCHContentIdentifierTypes)value;
- (SCHContentIdentifierTypes)contentIdentifierTypeValue;

+ (NSNumber *)numberWithDRMQualifier:(SCHDRMQualifiers)value;
- (id)initWithDRMQualifier:(SCHDRMQualifiers)value;
- (SCHDRMQualifiers)DRMQualifierValue;

+ (NSNumber *)numberWithSaveAction:(SCHSaveActions)value;
- (id)initWithSaveAction:(SCHSaveActions)value;
- (SCHSaveActions)saveActionValue;

+ (NSNumber *)numberWithUserSettingsType:(SCHUserSettingsTypes)value;
- (id)initWithUserSettingsType:(SCHUserSettingsTypes)value;
- (SCHUserSettingsTypes)userSettingsTypeValue;

+ (NSNumber *)numberWithTopFavoritesType:(SCHTopFavoritesTypes)value;
- (id)initWithTopFavoritesType:(SCHTopFavoritesTypes)value;
- (SCHTopFavoritesTypes)topFavoritesTypeValue;

+ (NSNumber *)numberWithDataStoreType:(SCHDataStoreTypes)value;
- (id)initWithDataStoreType:(SCHDataStoreTypes)value;
- (SCHDataStoreTypes)dataStoreTypeValue;

@end
