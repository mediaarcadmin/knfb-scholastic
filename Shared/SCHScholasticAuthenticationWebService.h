//
//  SCHScholasticAuthenticationWebService.h
//  Scholastic
//
//  Created by John S. Eddie on 21/12/2010.
//  Copyright 2010 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BITSOAPProxy.h"
#import "AuthenticateSvc.h"

// ProcessRemote Constants
extern NSString * const kSCHScholasticAuthenticationWebServiceProcessRemote;
extern NSString * const kSCHScholasticAuthenticationWebServicePToken;

// Scholastic Errors
typedef enum {
    // an unknown error
    kSCHScholasticAuthenticationWebServiceErrorCodeUnknown = -1,
    // no error
    kSCHScholasticAuthenticationWebServiceErrorCodeNone = 0,
    // valid errors from the web service
    kSCHScholasticAuthenticationWebServiceErrorCodeInvalidUsernamePassword = 200
} SCHScholasticAuthenticationWebServiceErrorCode;

@interface SCHScholasticAuthenticationWebService : BITSOAPProxy <AuthenticateSoap11BindingResponseDelegate> 
{
}

- (void)authenticateUserName:(NSString *)userName withPassword:(NSString *)password;

@end
