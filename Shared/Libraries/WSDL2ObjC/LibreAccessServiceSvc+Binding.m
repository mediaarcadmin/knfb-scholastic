//
//  LibreAccessServiceSvc+Binding.m
//  Scholastic
//
//  Created by John Eddie on 27/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "LibreAccessServiceSvc+Binding.h"

@implementation LibreAccessServiceSvc (Binding)

+ (LibreAccessServiceSoap11Binding *)SCHLibreAccessServiceSoap11Binding
{
    NSLog(@"LibreAccessServiceSoap using: %@", LIBREDIGITAL_SERVER_ENDPOINT);
    return [[[LibreAccessServiceSoap11Binding alloc] initWithAddress:LIBREDIGITAL_SERVER_ENDPOINT] autorelease];
}

@end
