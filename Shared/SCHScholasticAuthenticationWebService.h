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

@interface SCHScholasticAuthenticationWebService : BITSOAPProxy <AuthenticateSoap11BindingResponseDelegate> 
{
}

- (void)authenticateUserName:(NSString *)userName withPassword:(NSString *)password;

@end
