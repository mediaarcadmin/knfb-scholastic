//
//  SCHComponent.h
//  Scholastic
//
//  Created by John S. Eddie on 04/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SCHComponentDelegate.h"
#import "BITAPIProxyDelegate.h"
#import "SCHAuthenticationManager.h"
#import "SCHLibreAccessWebService.h"

@interface SCHComponent : NSObject <BITAPIProxyDelegate> 
{
}

@property (assign, nonatomic) id<SCHComponentDelegate> delegate;	

- (void)clear;

@end
