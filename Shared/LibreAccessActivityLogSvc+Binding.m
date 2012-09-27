//
//  LibreAccessActivityLogSvc+Binding.m
//  Scholastic
//
//  Created by John S. Eddie on 04/09/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "LibreAccessActivityLogSvc+Binding.h"

@implementation LibreAccessActivityLogSvc (Binding)

+ (LibreAccessActivityLogSoap11Binding *)SCHLibreAccessActivityLogSoap11Binding
{
    NSLog(@"LibreAccessActivityLogSoap using: %@", ACTIVITY_LOG_SERVER_ENDPOINT);
    return [[[LibreAccessActivityLogSoap11Binding alloc] initWithAddress:ACTIVITY_LOG_SERVER_ENDPOINT] autorelease];
}

@end
