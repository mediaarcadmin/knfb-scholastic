//
//  SCHScholasticGetUserInfoWebService.h
//  Scholastic
//
//  Created by John Eddie on 21/02/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BITSOAPProxy.h"
#import "GetUserInfoSvc.h"

// ProcessRemote Constants
extern NSString * const kSCHScholasticGetUserInfoWebServiceProcessRemote;
extern NSString * const kSCHScholasticGetUserInfoWebServiceCOPPA;
extern NSString * const kSCHScholasticGetUserInfoWebServiceSPSID;

// Scholastic Errors
typedef enum {
    // an unknown error
    kSCHScholasticGetUserInfoWebServiceErrorCodeUnknown = -1,
    // no error
    kSCHScholasticGetUserInfoWebServiceErrorCodeNone = 0,
    // valid errors from the web service
    kSCHScholasticGetUserInfoWebServiceErrorCodeInvalidToken = 300
} SCHScholasticGetUserInfoWebServiceWebServiceErrorCode;

@interface SCHScholasticGetUserInfoWebService : BITSOAPProxy <GetUserInfoSoap11BindingResponseDelegate> 

- (void)getUserInfo:(NSString *)token;

@end
