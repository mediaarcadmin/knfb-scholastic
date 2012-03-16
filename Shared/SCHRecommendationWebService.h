//
//  SCHRecommendationWebService.h
//  Scholastic
//
//  Created by John Eddie on 13/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BITSOAPProxy.h"
#import "QHTTPOperation.h"

// Constants
extern NSString * const kSCHRecommendationWebServiceRetrieveRecommendationsForProfile;
extern NSString * const kSCHRecommendationWebServiceRetrieveRecommendationsForBooks;

@interface SCHRecommendationWebService : BITSOAPProxy <QHTTPOperationDelegate> 

- (void)clear;

- (BOOL)retrieveRecommendationsForProfileWithAges:(NSArray *)ages;
- (BOOL)retrieveRecommendationsForBooks:(NSArray *)books;

@end
