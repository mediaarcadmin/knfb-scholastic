//
//  GetUserInfoSvc+Binding.m
//  Scholastic
//
//  Created by John Eddie on 27/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "GetUserInfoSvc+Binding.h"

@implementation GetUserInfoSvc (Binding)

+ (GetUserInfoSoap11Binding *)SCHGetUserInfoSoap11Binding
{
    NSLog(@"GetUserInfoSoap using: %@", GETUSERINFO_SERVER_ENDPOINT);
    return [[[GetUserInfoSoap11Binding alloc] initWithAddress:GETUSERINFO_SERVER_ENDPOINT] autorelease];     
}

@end
