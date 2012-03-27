//
//  AuthenticateSvc+Binding.m
//  Scholastic
//
//  Created by John Eddie on 27/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "AuthenticateSvc+Binding.h"

@implementation AuthenticateSvc (Binding)

+ (AuthenticateSoap11Binding *)SCHAuthenticateSoap11Binding
{
    NSLog(@"AuthenticateSoap using: %@", AUTHENTICATION_SERVER_ENDPOINT);
    return [[[AuthenticateSoap11Binding alloc] initWithAddress:AUTHENTICATION_SERVER_ENDPOINT] autorelease];     
}

@end
