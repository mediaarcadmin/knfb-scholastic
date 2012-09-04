//
//  SCHLibreAccessActivityLogWebService.h
//  Scholastic
//
//  Created by John S. Eddie on 04/09/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BITSOAPProxy.h"

#import "LibreAccessActivityLogSvc+Binding.h"
#import "BITObjectMapperProtocol.h"
#import "SCHLibreAccessActivityLogConstants.h"

@interface SCHLibreAccessActivityLogWebService : BITSOAPProxy <LibreAccessActivityLogSoap11BindingResponseDelegate, BITObjectMapperProtocol>

- (void)clear;

- (BOOL)saveActivityLog:(NSArray *)logsList forUserKey:(NSString *)userKey;

@end
