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
#import "SCHLibreAccessConstants.h"

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
