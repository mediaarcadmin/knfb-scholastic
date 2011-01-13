//
//  BITAPIProxy.h
//  WebAPI
//
//  Created by John S. Eddie on 21/12/2010.
//  Copyright 2010 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BITAPIProxyDelegate.h"

@class ObjectMapper;

@interface BITAPIProxy : NSObject {
	ObjectMapper *mapper;
}

@property (nonatomic, assign) id<BITAPIProxyDelegate> delegate;

- (BOOL)isOperational;

@end
