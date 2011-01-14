//
//  SCHScholasticWebService.h
//  TestWSDL2ObjC
//
//  Created by John S. Eddie on 21/12/2010.
//  Copyright 2010 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BITSOAPProxy.h"

#import "AuthenticateSvc.h"

// ProcessRemote
static NSString * const kSCHScholasticWebServiceProcessRemote = @"processRemote";
static NSString * const kSCHScholasticWebServicePToken = @"pToken";


@interface SCHScholasticWebService : BITSOAPProxy <AuthenticateSoap12BindingResponseDelegate> {
	AuthenticateSoap12Binding *binding;
}

- (void)authenticateUserName:(NSString *)userName withPassword:(NSString *)password;

@end
