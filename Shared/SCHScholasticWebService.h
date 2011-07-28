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

// ProcessRemote Constants
extern NSString * const kSCHScholasticWebServiceProcessRemote;
extern NSString * const kSCHScholasticWebServicePToken;

@interface SCHScholasticWebService : BITSOAPProxy <AuthenticateSoap11BindingResponseDelegate> 
{
}

- (void)authenticateUserName:(NSString *)userName withPassword:(NSString *)password;

@end
